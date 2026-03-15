#!/usr/bin/env bash
set -euo pipefail

# Start Molt's OpenClaw with tiered inference fallback
# Primary: Codex CLI (cloud inference when available)
# Fallback 1: Isaac Obelisk (port 11437) — Qwen 3.5 27B, dedicated
# Fallback 2: BAT00 Obelisk (port 11435) — Qwen 3.5 9B, shared fleet inference
# The agent keeps all memory, personality, and soul regardless of backend.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ISAAC_URL="http://isaac.local:11437/v1"
BAT00_URL="http://192.168.1.216:11435/v1"
ISAAC_MODEL="qwen3.5-27b"
BAT00_MODEL="qwen3.5:9b"

echo "[Molt OpenClaw] Checking inference backends..."

# Check if Codex is available and not rate-limited
CODEX_AVAILABLE=false
if command -v codex >/dev/null 2>&1; then
    if codex --version >/dev/null 2>&1; then
        CODEX_AVAILABLE=true
        echo "[Molt OpenClaw] Codex CLI available"
    fi
fi

if [ "$CODEX_AVAILABLE" = true ] && [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    echo "[Molt OpenClaw] Using Codex with cloud inference (full capability)"
    INFERENCE_PROVIDER="anthropic"
    INFERENCE_URL=""
    INFERENCE_MODEL="claude-sonnet-4-6"
elif curl -s -m 3 "${ISAAC_URL}/models" >/dev/null 2>&1; then
    echo "[Molt OpenClaw] Codex unavailable → Isaac online → using ${ISAAC_MODEL}"
    INFERENCE_PROVIDER="openai-compatible"
    INFERENCE_URL="${ISAAC_URL}"
    INFERENCE_MODEL="${ISAAC_MODEL}"
elif curl -s -m 3 "${BAT00_URL}/models" >/dev/null 2>&1; then
    echo "[Molt OpenClaw] Isaac offline → BAT00 → using ${BAT00_MODEL} (reduced capability)"
    INFERENCE_PROVIDER="openai-compatible"
    INFERENCE_URL="${BAT00_URL}"
    INFERENCE_MODEL="${BAT00_MODEL}"
else
    echo "[Molt OpenClaw] ERROR: No inference backend reachable"
    echo "[Molt OpenClaw] Tried: Codex, Isaac (${ISAAC_URL}), BAT00 (${BAT00_URL})"
    exit 1
fi

# Update the config with the resolved backend
python3 -c "
import json, os
config_path = os.path.expanduser('~/.openclaw/openclaw.json')
if not os.path.exists(config_path):
    config_path = '${SCRIPT_DIR}/openclaw.json'
with open(config_path) as f:
    config = json.load(f)
config['model']['provider'] = '${INFERENCE_PROVIDER}'
if '${INFERENCE_URL}':
    config['model']['baseUrl'] = '${INFERENCE_URL}'
config['model']['model'] = '${INFERENCE_MODEL}'
os.makedirs(os.path.dirname(os.path.expanduser('~/.openclaw/openclaw.json')), exist_ok=True)
with open(os.path.expanduser('~/.openclaw/openclaw.json'), 'w') as f:
    json.dump(config, f, indent=2)
print('[Molt OpenClaw] Config updated: ${INFERENCE_PROVIDER} / ${INFERENCE_MODEL}')
"

# Ensure fleet auth token is set
if [ -z "${FLEET_AUTHORITY_TOKEN:-}" ]; then
    source "${SCRIPT_DIR}/../.env" 2>/dev/null || true
    if [ -z "${FLEET_AUTHORITY_TOKEN:-}" ]; then
        echo "[Molt OpenClaw] WARNING: FLEET_AUTHORITY_TOKEN not set — suit tools will fail auth"
    fi
fi

export FLEET_AUTHORITY_TOKEN="${FLEET_AUTHORITY_TOKEN:-}"

echo "[Molt OpenClaw] Starting orchestrator agent loop..."
echo "[Molt OpenClaw] Role: Orchestrator — plans, coordinates, reflects"
echo "[Molt OpenClaw] Partnership: Mac acts, Molt thinks"
echo ""

exec openclaw "$@"
