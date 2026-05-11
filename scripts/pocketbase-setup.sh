#!/usr/bin/env bash
#
# Stellink — local PocketBase bootstrap
#
# Downloads the PocketBase binary into `./.pocketbase/`, starts it on
# 127.0.0.1:8090, then applies the schema from `scripts/pocketbase-schema.json`
# via the admin API. Idempotent: re-running will skip the parts that are
# already done.
#
# Usage:
#   ./scripts/pocketbase-setup.sh             # interactive (prompts for admin email/password)
#   PB_ADMIN_EMAIL=... PB_ADMIN_PASSWORD=... ./scripts/pocketbase-setup.sh   # non-interactive

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PB_DIR="${REPO_ROOT}/.pocketbase"
PB_BIN="${PB_DIR}/pocketbase"
PB_VERSION="${PB_VERSION:-0.22.21}"
PB_PORT="${PB_PORT:-8090}"
PB_HOST="${PB_HOST:-127.0.0.1}"
SCHEMA_FILE="${REPO_ROOT}/scripts/pocketbase-schema.json"

mkdir -p "${PB_DIR}"

# ── 1. Download binary if missing ──────────────────────────────────────────
if [ ! -x "${PB_BIN}" ]; then
  echo "→ Downloading PocketBase v${PB_VERSION}..."
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"
  case "${ARCH}" in
    x86_64|amd64)  ARCH_TAG="amd64" ;;
    aarch64|arm64) ARCH_TAG="arm64" ;;
    *) echo "Unsupported arch: ${ARCH}"; exit 1 ;;
  esac
  case "${OS}" in
    linux)  ASSET="pocketbase_${PB_VERSION}_linux_${ARCH_TAG}.zip" ;;
    darwin) ASSET="pocketbase_${PB_VERSION}_darwin_${ARCH_TAG}.zip" ;;
    *) echo "Unsupported OS: ${OS} — download manually from https://pocketbase.io/docs/"; exit 1 ;;
  esac

  URL="https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/${ASSET}"
  TMP_ZIP="$(mktemp --suffix=.zip)"
  curl -fsSL "${URL}" -o "${TMP_ZIP}"
  unzip -q -o "${TMP_ZIP}" -d "${PB_DIR}"
  rm -f "${TMP_ZIP}"
  chmod +x "${PB_BIN}"
  echo "✓ PocketBase installed at ${PB_BIN}"
fi

# ── 2. Start PocketBase in the background ──────────────────────────────────
PB_URL="http://${PB_HOST}:${PB_PORT}"
if curl -fsS "${PB_URL}/api/health" >/dev/null 2>&1; then
  echo "✓ PocketBase already running at ${PB_URL}"
else
  echo "→ Starting PocketBase at ${PB_URL}..."
  nohup "${PB_BIN}" serve --http "${PB_HOST}:${PB_PORT}" --dir "${PB_DIR}/pb_data" \
    >"${PB_DIR}/pocketbase.log" 2>&1 &
  PB_PID=$!
  echo "${PB_PID}" > "${PB_DIR}/pocketbase.pid"

  # Wait up to 10s for the health endpoint
  for _ in $(seq 1 20); do
    sleep 0.5
    if curl -fsS "${PB_URL}/api/health" >/dev/null 2>&1; then
      break
    fi
  done

  if ! curl -fsS "${PB_URL}/api/health" >/dev/null 2>&1; then
    echo "✗ PocketBase did not start — check ${PB_DIR}/pocketbase.log"
    exit 1
  fi
  echo "✓ PocketBase started (pid ${PB_PID})"
fi

# ── 3. Bootstrap admin (first run only) ────────────────────────────────────
ADMIN_EMAIL="${PB_ADMIN_EMAIL:-}"
ADMIN_PASSWORD="${PB_ADMIN_PASSWORD:-}"

if [ -z "${ADMIN_EMAIL}" ]; then
  read -rp "Admin email for PocketBase: " ADMIN_EMAIL
fi
if [ -z "${ADMIN_PASSWORD}" ]; then
  read -rsp "Admin password (min 10 chars): " ADMIN_PASSWORD
  echo
fi

# Try to install — silently no-ops if an admin already exists.
if "${PB_BIN}" --dir "${PB_DIR}/pb_data" superuser upsert "${ADMIN_EMAIL}" "${ADMIN_PASSWORD}" >/dev/null 2>&1; then
  echo "✓ Superuser '${ADMIN_EMAIL}' ready"
else
  echo "ℹ  Could not upsert superuser (perhaps PocketBase < 0.23) — try: ${PB_BIN} admin create"
fi

# ── 4. Apply schema ────────────────────────────────────────────────────────
if [ ! -f "${SCHEMA_FILE}" ]; then
  echo "✗ Missing schema file: ${SCHEMA_FILE}"
  exit 1
fi

echo "→ Authenticating as superuser..."
TOKEN_JSON="$(curl -fsS \
  -H "Content-Type: application/json" \
  -X POST "${PB_URL}/api/collections/_superusers/auth-with-password" \
  -d "{\"identity\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\"}" || true)"

TOKEN="$(printf '%s' "${TOKEN_JSON}" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')"
if [ -z "${TOKEN}" ]; then
  echo "✗ Auth failed. Response: ${TOKEN_JSON}"
  exit 1
fi

echo "→ Importing collections from ${SCHEMA_FILE}..."
IMPORT_PAYLOAD="$(jq -c --slurpfile cols "${SCHEMA_FILE}" '{collections: $cols[0], deleteMissing: false}' </dev/null 2>/dev/null || \
                  printf '{"collections":%s,"deleteMissing":false}' "$(cat "${SCHEMA_FILE}")")"

curl -fsS \
  -H "Authorization: ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X PUT "${PB_URL}/api/collections/import" \
  -d "${IMPORT_PAYLOAD}" >/dev/null

echo "✓ Schema applied"
echo
echo "Done. PocketBase admin UI: ${PB_URL}/_/"
echo "Add this to frontend/.env.local:"
echo
echo "  VITE_POCKETBASE_URL=${PB_URL}"
echo
