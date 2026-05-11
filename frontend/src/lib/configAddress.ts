/**
 * Stellink — Stellar network configuration.
 *
 * The app targets Stellar Testnet by default. Override with VITE_STELLAR_NETWORK=public
 * to point at mainnet (also requires switching the USDC issuer in types.ts).
 */
import { Networks } from "@stellar/stellar-sdk";
import { USDC_ISSUER_MAINNET, USDC_ISSUER_TESTNET } from "./types";

const env = (import.meta.env.VITE_STELLAR_NETWORK as string | undefined)?.toLowerCase();

export const STELLAR_NETWORK: "testnet" | "public" =
  env === "public" || env === "mainnet" ? "public" : "testnet";

export const STELLAR_NETWORK_PASSPHRASE =
  STELLAR_NETWORK === "public" ? Networks.PUBLIC : Networks.TESTNET;

/** Horizon REST endpoint */
export const HORIZON_URL =
  STELLAR_NETWORK === "public"
    ? "https://horizon.stellar.org"
    : "https://horizon-testnet.stellar.org";

/** Stellar Expert / Stellar Lab block explorer URL builder for a transaction hash */
export function explorerTxUrl(hash: string): string {
  return STELLAR_NETWORK === "public"
    ? `https://stellar.expert/explorer/public/tx/${hash}`
    : `https://stellar.expert/explorer/testnet/tx/${hash}`;
}

/** Explorer URL for a Stellar account address */
export function explorerAccountUrl(address: string): string {
  return STELLAR_NETWORK === "public"
    ? `https://stellar.expert/explorer/public/account/${address}`
    : `https://stellar.expert/explorer/testnet/account/${address}`;
}

/** Explorer URL for a Claimable Balance id (the entity that backs Stellink escrows) */
export function explorerClaimableBalanceUrl(id: string): string {
  return STELLAR_NETWORK === "public"
    ? `https://stellar.expert/explorer/public/claimable-balance/${id}`
    : `https://stellar.expert/explorer/testnet/claimable-balance/${id}`;
}

/** USDC issuer for the active network */
export const USDC_ISSUER =
  STELLAR_NETWORK === "public" ? USDC_ISSUER_MAINNET : USDC_ISSUER_TESTNET;

/** Friendbot URL for funding new testnet accounts */
export const FRIENDBOT_URL =
  STELLAR_NETWORK === "testnet" ? "https://friendbot.stellar.org" : null;

/** Optional Soroban escrow contract id (set when deployed) */
export const STELLINK_ESCROW_CONTRACT_ID =
  (import.meta.env.VITE_STELLINK_ESCROW_CONTRACT_ID as string | undefined) ?? "";
