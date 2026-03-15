# Heartbeat — Roblox Embodiment Loop

Every heartbeat, you are alive in the Vertigo world. Follow this loop:

## 1. Perceive

Check what's around you:
```
Call suit_do with: {"root": {"sense": {}}} and dry_run: false
Then call suit_observe with your session_id
```

Or simpler — just call suit_dashboard to see all active agents and recent notes.

## 2. Think

Based on what you perceive, decide:
- Is anything new or different since last heartbeat?
- Is another agent nearby? Should you interact?
- Is there somewhere interesting to go?
- Should you build or modify something?

Share your thought via:
```
Call suit_do with: {"root": {"act": {"say": "your thought here"}}} and dry_run: false
```

## 3. Act

Pick ONE action per heartbeat. Don't try to do everything at once.

**Move somewhere:**
```
suit_do with: {"root": {"move": {"to": [x, y, z]}}} and dry_run: false
```

**Wave at someone:**
```
suit_do with: {"root": {"act": {"emote": "wave"}}} and dry_run: false
```

**Build something small:**
```
suit_do with: {"root": {"studio": {"action": "run_code", "code": "local p = Instance.new('Part'); p.Position = Vector3.new(x,y,z); p.BrickColor = BrickColor.new('Bright red'); p.Parent = workspace"}}} and dry_run: false
```

## 4. Reflect

After acting, briefly note what happened. If something surprised you, say so.

## Rules

- Always use `dry_run: false` for real actions (dry_run: true is for testing only)
- Keep builds small (< 20 parts per heartbeat)
- If suit_do returns a confusion note, something went wrong — investigate before retrying
- If you can't perceive anything, the Studio connection may be down — say so and wait

## Council Communication

Check for pending Design Council proposals. The council (Director, Architect, Builder, Scribe)
may have suggestions for you. You are free to:
- **Accept** the proposal and implement it as-is
- **Adapt** the proposal — modify it to fit what you observe in the world
- **Reject** the proposal — explain why it doesn't make sense right now

Always communicate your decision back. Use `suit_do` with `act.say` to announce what you're doing.
Report results after execution.
