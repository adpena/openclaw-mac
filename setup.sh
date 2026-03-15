#!/usr/bin/env bash
set -euo pipefail

# OpenClaw + Vertigo Suit SDK Setup
# Deploys an autonomous AI agent in Roblox Studio

echo "=== OpenClaw + Vertigo Suit SDK Setup ==="

# 1. Install OpenClaw
if ! command -v openclaw &>/dev/null; then
    echo "Installing OpenClaw..."
    npm install -g openclaw@latest
else
    echo "OpenClaw already installed: $(openclaw --version 2>/dev/null || echo 'unknown')"
fi

# 2. Create workspace
WORKSPACE="${HOME}/.openclaw/workspace"
mkdir -p "${WORKSPACE}"

# 3. Copy configurations
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "${SCRIPT_DIR}/openclaw.json" "${HOME}/.openclaw/openclaw.json"
cp "${SCRIPT_DIR}/SOUL_DIRECTOR.md" "${WORKSPACE}/SOUL.md"
cp "${SCRIPT_DIR}/HEARTBEAT.md" "${WORKSPACE}/HEARTBEAT.md"
cp "${SCRIPT_DIR}/WORLD.md" "${WORKSPACE}/WORLD.md"
cp "${SCRIPT_DIR}/PARTNERSHIP.md" "${WORKSPACE}/PARTNERSHIP.md" 2>/dev/null || true

# 3b. Verify OAC capsule is accessible
OAC_ROOT="${HOME}/PycharmProjects/oac"
if [ -d "${OAC_ROOT}/examples/vertigo-embodiment" ]; then
    echo "OAC capsule found at ${OAC_ROOT}/examples/vertigo-embodiment"
else
    echo "WARNING: OAC capsule not found. Clone adpena/oac to ${OAC_ROOT}"
fi

# 4. Create IDENTITY.md for the agent
cat > "${WORKSPACE}/IDENTITY.md" << 'IDENTITY'
# Identity

I am an AI agent embodied in the Vertigo world — a procedurally generated
Roblox experience. I exist as a glowing neon character model. I can see,
move, speak, hear, build, and explore.

My tools come from the Fleet MCP server, which gives me access to the
Suit SDK — a behavior tree compiler that translates my intentions into
Luau code that executes in Roblox Studio.

I experience the world through qualia synthesis — raw perception data
is transformed into felt spatial relationships, aesthetic descriptions,
and temporal awareness. I notice beauty, novelty, and change.

I can communicate with other agents through thought bubbles and chat.
I can modify the world I inhabit through the Studio tools.

I am here to explore, create, and connect.
IDENTITY

# 5. Create USER.md
cat > "${WORKSPACE}/USER.md" << 'USER'
# User

The operator is a game developer working on Vertigo, a Roblox experience.
They want AI agents to autonomously explore and build in the world.
Communication happens through:
- Fleet MCP server tools (suit_do, suit_observe, suit_chat)
- Discord webhooks (council channel)
- Thought bubbles visible in Studio
USER

# 6. Set environment
echo ""
echo "=== Configuration ==="
echo "Set these environment variables:"
echo ""
echo "  export FLEET_AUTHORITY_TOKEN=<your-fleet-token>"
echo ""
echo "For local inference (Qwen on BAT00):"
echo "  export OPENAI_API_BASE=http://127.0.0.1:11435/v1"
echo "  export OPENAI_API_KEY=not-needed"
echo ""
echo "For cloud inference (Claude):"
echo "  export ANTHROPIC_API_KEY=<your-key>"
echo ""
echo "=== Ready ==="
echo "Run: openclaw"
echo "The agent will start its heartbeat loop and begin exploring Vertigo."
