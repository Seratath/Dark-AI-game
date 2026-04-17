# Changelog

This file records meaningful historical events after they stop being active workboard state.

Use tags such as:

- `Designed`
- `Started`
- `Delivered`
- `Changed`
- `Deferred`
- `Abandoned`
- `Blocked`
- `Audited`
- `Decided`

Each entry should be brief and should reference:

- the record being logged
- the `Origin`
- the `Parent`
- what happened
- why it happened

```md
## YYYY-MM-DD

### Delivered - ACT-001
- Origin: IDE-001
- Parent: DEC-001
- What:
- Why:
```

## 2026-04-05

### Designed - IDE-001
- Origin: IDE-001
- Parent: none
- What: Captured the initial game concept for a probe-led Roblox 4X MMORTS with rebirth-gated galaxy tiers, automation-focused planet managers, and readable real-time fleet combat.
- Why: The project needed an agreed design baseline before implementation and balancing work could start.

### Decided - DEC-001
- Origin: IDE-001
- Parent: IDE-001
- What: Chose to introduce complexity in layers and keep the initial design v1-safe for Roblox rather than exposing all strategic systems at once.
- Why: The concept spans many progression and simulation layers and needed an explicit scope discipline rule.

### Decided - DEC-002
- Origin: IDE-001
- Parent: IDE-001
- What: Chose shared compute as the primary empire-scaling pressure across the player probe and cloned managers.
- Why: Colony count alone would not support the desired mix of manual play, automation, and strategic tradeoffs.

### Delivered - ACT-001
- Origin: IDE-001
- Parent: DEC-001
- What: Replaced the design doc templates with a first concrete pass covering project goals, core principles, system rules, progression flow, rebirth behavior, resource categories, PvE anchors, and watchpoints.
- Why: The repo had structure but no actual game design source of truth.

### Decided - DEC-003
- Origin: IDE-001
- Parent: IDE-001
- What: Trimmed the v1 scope to a PvE empire-building core loop and moved rebirth, PvP, travel lanes, and fog of war out of active requirements.
- Why: The first playable version needs to prove the core colony and fleet loop before wider meta and map-complexity systems are added.

### Delivered - ACT-003
- Origin: IDE-001
- Parent: DEC-003
- What: Added a dedicated asset breakdown covering world, probe, colony, fleet, PvE, UI, audio, and animation needs with v1 priority bands and modular production guidance.
- Why: The project needed a production-facing asset plan to understand what content is required for the first playable version.

### Decided - DEC-004
- Origin: IDE-001
- Parent: ACT-003
- What: Chose a borrow-first asset sourcing strategy for the mock-up, with clean swap boundaries and early replacement reserved for signature assets.
- Why: The fastest path to a playable mock-up is to use free Roblox assets where safe and defer bespoke art until the core loop is validated.

### Decided - DEC-005
- Origin: IDE-001
- Parent: DEC-004
- What: Added functional-first Creator Store intake guidance plus a lightweight qualitative tagging pass for borrowed assets.
- Why: The project needs to move quickly with borrowed assets while still flagging placeholders that are not suitable to keep beyond prototype use.
