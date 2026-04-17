# Project Docs Structure

This repo uses a small numbered documentation set so humans and AI collaborators can find the right source of truth quickly and keep it in sync with low overhead.

## Core Docs

### `00-README.md`

This file. Explains the structure and where information belongs.

### `01-COLLABORATION-AND-ENGAGEMENT.md`

How work should be coordinated across humans and AI:

- claiming work
- ownership rules
- escalation rules
- review expectations
- documentation sync expectations

### `02-GOAL-AND-PRINCIPLES.md`

The stable north star for the project:

- what is being built
- why it should feel the way it does
- core product and design principles
- constraints and non-goals

### `03-DESIGN-AND-REQUIREMENT.md`

The reference for project-specific system behavior and requirements:

- formulas
- scaling curves
- caps
- functional constraints
- runtime or state rules

### `04-WORKBOARD.md`

The operational source of truth for execution.

Use it for:

- ideas
- decisions
- actions
- ownership and reviewers
- dependencies and sequencing
- closure notes and audit findings

### `05-CHANGELOG.md`

Historical event log for deliveries, redirects, abandoned work, audits, and notable changes once they are no longer active workboard state.

### `06-ASSET-BREAKDOWN.md`

Production-facing asset planning for the current playable scope:

- asset groups
- v1 versus later priority
- modular kit opportunities
- UI, VFX, audio, and 3D content needs

## Working Rules

- Keep collaboration rules in `01`, stable intent in `02`, project-specific requirements in `03`, active work in `04`, historical events in `05`, and production asset planning in `06`.
- Prefer updating one clear source rather than duplicating the same information across files.
- If an item is only partially implemented, say so explicitly.
- If work stops, shifts, or is superseded, close or re-state the affected workboard item before starting the next item unless explicitly told not to.

## Hard Rules

- No new meaningful work without a record in the workboard.
- No context switch without a closure or handoff note unless explicitly told to skip it.
- No audit without either a clear "no drift found" closeout or spawned follow-up records.

## Record Model

The workboard uses three core record types:

- `IDE`: idea or concept
- `DEC`: decision
- `ACT`: action

Every meaningful record should carry:

- `ID`
- `Origin`
- `Parent`

Lineage rules:

- `Origin` is the first source in the chain.
- `Parent` is the immediate previous step.
- Root items use themselves as `Origin` and `none` as `Parent`.
- Spawned items inherit `Origin` and set `Parent` to the immediate source.

## Labels

Core shared fields:

- `Priority`: `Must`, `Should`, `Nice`
- `Owner`
- `Reviewer`
- `Dependencies`

Recommended tags:

- `Area`: project-specific, but keep it short and controlled
- `Audit scope`: `Runtime`, `Docs`, `UX`, `Tests`, `Save data` or project equivalents

Keep the vocabulary small. If a label is not clearly earning its keep, do not add it.

## Template Examples

### `02-GOAL-AND-PRINCIPLES.md` Example

```md
# Project Name - Goal and Principles

## Project Goal

Build a cooperative survival crafting game that supports short sessions while still rewarding long-term settlement planning.

## Product North Star

The game should feel:

- readable in the first five minutes
- strategically deep over many sessions
- collaborative rather than chaotic in multiplayer

## Core Experience Principles

### 1. Player intent should stay legible

- Important decisions should be visible in the main play surface.
- Players should not need nested menus for routine tasks.

### 2. Early progression should teach tradeoffs

- Early upgrades should force specialization.
- Players should not unlock every strong path in the first session.

## Current Directional Constraints

- The settlement screen should remain the main planning surface.
- Permanent progression should not remove mid-run survival pressure.

## Current Non-Goals

- PvP balance
- marketplace or trading systems
- procedural story generation
```

### `03-DESIGN-AND-REQUIREMENT.md` Example

```md
# Project Name - Systems and Requirements

## Core Runtime Curves

### Enemy Health

Health(wave) = ceil(1.18 ^ wave)

### Currency Gain

Coins(clear) = 5 + floor(wave / 2)

## Current System Rules

### Progression Layers

- within-run upgrades
- per-session unlocks
- long-term account progression

### Constraint Rules

- healing items cannot exceed inventory cap
- boss waves occur every 10 levels
- permanent upgrades can increase caps, but not remove them entirely

## Known Watchpoints

- sustain must not outscale incoming damage too early
- progression must not flatten wave identity
```

Rule of thumb:

- if it explains why the project exists or what good feels like, it belongs in `02`
- if it explains what the system must do or how it currently behaves, it belongs in `03`

### `05-CHANGELOG.md` Example

```md
## 2026-04-05

### Designed - IDE-004
- Origin: IDE-004
- Parent: none
- What: Captured a concept for class-based elemental enemies.
- Why: Enemy identity was too flat.

### Decided - DEC-002
- Origin: IDE-004
- Parent: IDE-004
- What: Agreed that elemental enemies should appear only after zone 2.
- Why: Protect early-game readability.

### Delivered - ACT-019
- Origin: IDE-004
- Parent: DEC-002
- What: Implemented the first elemental enemy set and spawn gating.
- Why: Put the agreed design into runtime.
```
