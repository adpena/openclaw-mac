# OpenClaw + Vertigo Suit SDK — Autonomous Roblox Embodiment

Deploy an autonomous AI agent that lives inside Roblox Studio using [OpenClaw](https://openclaw.ai) and the Vertigo Suit SDK.

## Quick Start

### Prerequisites
- Roblox Studio running on the Mac Mini with a place file loaded
- Fleet MCP server running: `http://192.168.1.112:8850/mcp`
- `FLEET_AUTHORITY_TOKEN` set in your environment

### Install OpenClaw
```bash
npm install -g openclaw@latest
openclaw onboard
```

### Configure
```bash
# Copy the config to your OpenClaw workspace
cp openclaw.json ~/.openclaw/openclaw.json
cp SOUL_DIRECTOR.md ~/.openclaw/workspace/SOUL.md
cp HEARTBEAT.md ~/.openclaw/workspace/HEARTBEAT.md

# Set your fleet auth token
export FLEET_AUTHORITY_TOKEN=your_token_here
```

### Run
```bash
# Start the Director agent
openclaw
# The agent will perceive, think, and act every 60 seconds
```

## How It Works

```
OpenClaw Agent Loop (every 60s)
  ├── Read HEARTBEAT.md → perception/action instructions
  ├── Call suit_observe → see nearby objects, zone
  ├── LLM thinks → decides what to do
  ├── Call suit_do → compile Luau → execute in Studio
  │   ├── Agent moves, speaks, builds
  │   └── Thought bubble updates for other observers
  └── Record experience → memory for next heartbeat
```

## Architecture

- **OpenClaw**: Autonomous agent framework (Node.js, SOUL/HEARTBEAT pattern)
- **Fleet MCP Server**: Exposes 30+ suit tools over HTTP/SSE with auth
- **Suit SDK**: Compiles behavior trees to Luau (Python + Rust dual backend)
- **rbx-studio-mcp**: Binary that bridges Roblox Studio's Lua VM via JSON-RPC
- **Roblox Studio**: Where the agent is embodied as a Neon character model

## Available Tools

The fleet MCP server exposes these suit tools to OpenClaw:

| Tool | What it does |
|------|-------------|
| `suit_do` | One-shot: compile + execute + return results |
| `suit_observe` | See what's nearby (perception) |
| `suit_compile` | Compile a program to Luau |
| `suit_studio_mode` | Get/set Studio mode (Edit/Play/Stop) |
| `suit_dashboard` | Operator overview of all agents |
| `suit_emergency_stop` | Kill switch — stop all agents |
| `suit_experience_query` | Query past experience for reflection |
| `suit_session_history` | Review all past sessions |

## Multiple Agents

Edit `openclaw.json` to add more agents. Each gets its own SOUL, heartbeat interval, and character in Studio. The N-agent orchestrator handles character provisioning automatically.

## Human Control

Any human with access to the fleet MCP server can control agents:
- Send commands via the MCP tools (Claude Code, Codex, or curl)
- Override agent behavior by calling `suit_do` directly
- Use `suit_emergency_stop` to halt all agents
- Communicate via thought bubbles by calling `suit_do` with `act.say`
