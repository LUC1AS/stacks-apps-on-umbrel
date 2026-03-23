#!/usr/bin/env bash

export APP_CHAINHOOK_IP="10.21.21.102"
export APP_CHAINHOOK_PORT="20456"
export APP_CHAINHOOK_INGESTION_PORT="20455"
export APP_CHAINHOOK_REDIS_IP="10.21.21.103"

CONFIG="${UMBREL_ROOT}/app-data/stacks-chainhook/data/config/chainhook.toml"

set -e

sed -i  -e "s@APP_BITCOIN_NODE_IP@$APP_BITCOIN_NODE_IP@" \
        -e "s@APP_BITCOIN_RPC_PORT@$APP_BITCOIN_RPC_PORT@" \
        -e "s@APP_BITCOIN_RPC_USER@$APP_BITCOIN_RPC_USER@" \
        -e "s@APP_BITCOIN_RPC_PASS@$APP_BITCOIN_RPC_PASS@" \
        -e "s@APP_STACKS_BLOCKCHAIN_IP@$APP_STACKS_BLOCKCHAIN_IP@" \
        -e "s@APP_STACKS_CORE_RPC_PORT@$APP_STACKS_CORE_RPC_PORT@" \
        -e "s@APP_CHAINHOOK_PORT@$APP_CHAINHOOK_PORT@" \
        -e "s@APP_CHAINHOOK_INGESTION_PORT@$APP_CHAINHOOK_INGESTION_PORT@" \
        "$CONFIG"

# Register chainhook as an event observer in the stacks-blockchain Config.toml.
# This enables the Stacks node to forward block events to Chainhook.
# Restart the Stacks Node app after installing Chainhook for this to take effect.
STACKS_CONFIG="${UMBREL_ROOT}/app-data/stacks-blockchain/data/config/Config.toml"
if [ -f "$STACKS_CONFIG" ] && ! grep -q "$APP_CHAINHOOK_IP:$APP_CHAINHOOK_INGESTION_PORT" "$STACKS_CONFIG"; then
    printf '\n[[events_observer]]\nendpoint = "%s:%s"\nretry_count = 255\nevents_keys = ["*"]\n' \
        "$APP_CHAINHOOK_IP" "$APP_CHAINHOOK_INGESTION_PORT" >> "$STACKS_CONFIG"
fi
