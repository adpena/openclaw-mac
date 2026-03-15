#!/usr/bin/env bash
set -euo pipefail

# Start Mac's OpenClaw with graceful inference fallback
# Primary: Isaac Obelisk (port 11437) — Qwen 3.5 27B, dedicated
# Fallback: BAT00 Obelisk (port 11435) — Qwen 3.5 9B, shared fleet inference
# The agent keeps all memory, personality, and soul regardless of backend.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ISAAC_URL="http://isaac.local:11437/v1"
BAT00_URL="http://bat00.local:11435/v1"
ISAAC_MODEL="qwen3.5-27b"
BAT00_MODEL="qwen3.5:9b"

echo "[Mac OpenClaw] Checking inference backends..."

# Gentle single probe — don't hammer Isaac during LoRA training
if curl -s -m 3 "${ISAAC_URL}/models" >/dev/null 2>&1; then
    echo "[Mac OpenClaw] Isaac online → using ${ISAAC_MODEL} (full capability)"
    INFERENCE_URL="${ISAAC_URL}"
    INFERENCE_MODEL="${ISAAC_MODEL}"
else
    echo "[Mac OpenClaw] Isaac offline → falling back to BAT00 ${BAT00_MODEL} (reduced capability)"
    echo "[Mac OpenClaw] Note: same soul, same memory, just less deep thinking"
    INFERENCE_URL="${BAT00_URL}"
    INFERENCE_MODEL="${BAT00_MODEL}"
fi

# Update the config with the resolved backend
python3 -c "
import json
with open('$HOME/.openclaw/openclaw.json') as f:
    config = json.load(f)
config['model']['baseUrl'] = '${INFERENCE_URL}'
config['model']['model'] = '${INFERENCE_MODEL}'
# Patch fleet MCP URL from env var for DHCP resilience
try:
    config['agents']['defaults']['mcp']['servers']['vertigo-fleet']['url'] = '${FLEET_MCP_URL}'
except (KeyError, TypeError):
    pass
with open('$HOME/.openclaw/openclaw.json', 'w') as f:
    json.dump(config, f, indent=2)
print('[Mac OpenClaw] Config updated: ${INFERENCE_URL} / ${INFERENCE_MODEL}')
"

# Fleet MCP URL — mDNS hostname with env var override
FLEET_MCP_URL="${FLEET_MCP_URL:-http://Alejandros-Mac-mini.local:8850/mcp}"
export FLEET_MCP_URL

# Ensure fleet auth token is set
if [ -z "${FLEET_AUTHORITY_TOKEN:-}" ]; then
    source "${SCRIPT_DIR}/../.env" 2>/dev/null || true
    if [ -z "${FLEET_AUTHORITY_TOKEN:-}" ]; then
        echo "[Mac OpenClaw] WARNING: FLEET_AUTHORITY_TOKEN not set — suit tools will fail auth"
    fi
fi

export FLEET_AUTHORITY_TOKEN="${FLEET_AUTHORITY_TOKEN:-}"

echo "[Mac OpenClaw] Starting embodied agent loop..."
echo "[Mac OpenClaw] Soul: Pete — explorer and builder"
echo "[Mac OpenClaw] World: Vertigo — floating platforms, caves, and vertigo"
echo ""

exec openclaw "$@"
