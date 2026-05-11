/**
 * PocketBase client for Stellink.
 *
 * PocketBase is a single-binary backend with embedded SQLite. Contributors
 * download the `pocketbase` binary, run `./pocketbase serve`, and they get
 * an instant REST API + admin UI on http://127.0.0.1:8090.
 *
 * If `VITE_POCKETBASE_URL` is unset, the app falls back to localStorage and
 * remains fully functional — links just become device-scoped.
 */

import PocketBase from "pocketbase";

const url = (import.meta.env.VITE_POCKETBASE_URL as string | undefined)?.trim();

export const pb: PocketBase | null = url ? new PocketBase(url) : null;

export const isPocketBaseEnabled = !!pb;

if (!pb) {
  // eslint-disable-next-line no-console
  console.warn(
    "[pocketbase] VITE_POCKETBASE_URL not set — falling back to localStorage only."
  );
}

/** Collection name shared by every PocketBase deployment of Stellink. */
export const LINKS_COLLECTION = "payment_links";
