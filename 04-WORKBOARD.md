# Dark AI Game - Workboard

This is the operational source of truth for active work, ownership, priorities, open decisions, and audit activity.

Use this file for:

- live ideas and concepts
- decisions that need resolution or have resolved direction
- actions such as implementation, audit, review, cleanup, or migration work
- ownership and reviewer assignment
- dependencies and sequencing
- closure notes and handoff notes

## Record Types

- `IDE`: idea or concept
- `DEC`: decision
- `ACT`: action

## Lineage Rules

Every meaningful record must preserve:

1. the first source in the chain
2. the immediate previous source

Required fields:

- `ID`
- `Origin`
- `Parent`

Rules:

- Root item: `Origin` is the same as `ID`, and `Parent` is `none`
- Spawned item: inherit `Origin` from the parent item
- Spawned item: set `Parent` to the immediate item that spawned it

## Shared Labels

Priority labels:

- `Must`
- `Should`
- `Nice`

Recommended tags:

- `Area`: [define your project’s short list]
- `Audit scope`: `Runtime`, `Docs`, `UX`, `Tests`, `Save data` or project equivalents

## Closure Rules

An action is not safely closed unless it has both:

1. a correct status
2. a closure note

Suggested closeout labels:

- `Closure:`
- `Remaining:`
- `Follow-up:`
- `Handoff:`

## Templates

```md
### IDE-XXX - Title

- ID: IDE-XXX
- Type: Idea
- Origin: IDE-XXX
- Parent: none
- Area:
- Priority:
- Status: Proposed
- Owner:
- Reviewer:
- Dependencies:
- Summary:
- Why it matters:
- Follow-up:
```

```md
### DEC-XXX - Title

- ID: DEC-XXX
- Type: Decision
- Origin:
- Parent:
- Area:
- Priority:
- Status: Proposed
- Owner:
- Reviewer:
- Dependencies:
- Decision:
- Why:
- Outcome:
- Follow-up:
```

```md
### ACT-XXX - Title

- ID: ACT-XXX
- Type: Action
- Origin:
- Parent:
- Area:
- Audit scope:
- Priority:
- Status: Proposed
- Owner:
- Reviewer:
- Dependencies:
- Summary:
- Why it matters:
- Next check:
- Closure:
- Remaining:
- Follow-up:
```

## Current Snapshot

- Current focus: Establish the first v1-safe game direction, system rules, and progression model for the Roblox 4X prototype.
- Main architectural direction: Doc-first design with explicit constraints before implementation or economy balancing.
- Main product direction: A probe-led, automation-friendly PvE empire builder with readable real-time fleet combat.

## Live Records

### IDE-001 - Probe-led Roblox 4X foundation

- ID: IDE-001
- Type: Idea
- Origin: IDE-001
- Parent: none
- Area: Product
- Priority: Must
- Status: Designed
- Owner: Shared
- Reviewer: Shared
- Dependencies: none
- Summary: Define the core player fantasy, progression loop, map structure, automation model, combat shape, and rebirth framing for the initial game concept.
- Why it matters: The project needs a concrete source of truth before implementation, balancing, or Roblox-specific prototyping begins.
- Follow-up: Spawn implementation-facing design actions for map generation, progression data, and combat simulation prototypes.

### DEC-001 - Favor v1-safe layered complexity

- ID: DEC-001
- Type: Decision
- Origin: IDE-001
- Parent: IDE-001
- Area: Product
- Priority: Must
- Status: Decided
- Owner: Shared
- Reviewer: Shared
- Dependencies: IDE-001
- Decision: Keep the design intentionally v1-safe by introducing complexity in layers through quests, unlocks, automation modes, and rebirth tiers rather than exposing the full strategy surface at once.
- Why: The concept has many progression axes and needs guardrails to stay readable and Roblox-feasible.
- Outcome: Direction captured in `02-GOAL-AND-PRINCIPLES.md` and `03-DESIGN-AND-REQUIREMENT.md`.
- Follow-up: Use this constraint when sizing any first playable milestone.

### DEC-002 - Use compute as empire scaling pressure

- ID: DEC-002
- Type: Decision
- Origin: IDE-001
- Parent: IDE-001
- Area: Economy
- Priority: Must
- Status: Decided
- Owner: Shared
- Reviewer: Shared
- Dependencies: IDE-001
- Decision: Use shared compute across the player probe and cloned managers as the primary empire-cap resource, creating both soft and hard pressure based on automation effectiveness rather than colony count alone.
- Why: This preserves strategic choice, supports different play styles, and gives automation an explicit tradeoff.
- Outcome: Compute is now the baseline capacity rule for colony and automation planning.
- Follow-up: Define a first-pass compute formula and manager mode costs.

### DEC-003 - Trim v1 to empire-building core loop

- ID: DEC-003
- Type: Decision
- Origin: IDE-001
- Parent: IDE-001
- Area: Scope
- Priority: Must
- Status: Decided
- Owner: Shared
- Reviewer: Shared
- Dependencies: DEC-001
- Decision: Remove rebirth, PvP, travel lanes, and fog of war from v1 scope and focus the first playable version on a PvE empire-building loop.
- Why: These systems add complexity and production risk but are not required to prove the core game is fun.
- Outcome: The active design now centers on colonization, planet management, compute pressure, fleet building, pirates, and boss encounters.
- Follow-up: Break the v1 loop into implementation-ready prototype actions.

### ACT-001 - Author initial design source of truth

- ID: ACT-001
- Type: Action
- Origin: IDE-001
- Parent: DEC-001
- Area: Docs
- Audit scope: Docs
- Priority: Must
- Status: Done
- Owner: Codex
- Reviewer: Shared
- Dependencies: IDE-001, DEC-001, DEC-002, DEC-003
- Summary: Write the initial project goal, core experience principles, system rules, progression rules, and known watchpoints into the numbered design docs.
- Why it matters: The repo started with templates only, so active work would have drifted immediately without a documented baseline.
- Next check: Convert the highest-risk areas into explicit prototype or balancing actions.
- Closure: Completed the first pass of `02` and `03`, then reduced the active scope to a slimmer v1 focused on single-run PvE empire building.
- Remaining: Numerical balance, persistence rules, map generation details, combat math, and prototype slicing still need deeper design.
- Follow-up: Add concrete actions for node generation, compute formulas, planet manager behaviors, and battle resolution rules.

### ACT-003 - Capture v1 asset production breakdown

- ID: ACT-003
- Type: Action
- Origin: IDE-001
- Parent: DEC-003
- Area: Content
- Audit scope: UX
- Priority: Must
- Status: Done
- Owner: Codex
- Reviewer: Shared
- Dependencies: ACT-001, DEC-003
- Summary: Create a production-facing asset breakdown for the trimmed v1 scope, grouped by reusable asset families and priority bands.
- Why it matters: The project needs a realistic view of content scope before art production or Roblox assembly work starts.
- Next check: Turn the highest-priority asset packs into implementation-ready content tickets.
- Closure: Added `06-ASSET-BREAKDOWN.md` and linked it into the repo structure.
- Remaining: Visual style direction, exact asset counts, and ownership by discipline still need to be decided.
- Follow-up: Define a visual style guide and convert Pack A into concrete build tasks.

### DEC-004 - Borrow assets by default for mock-up

- ID: DEC-004
- Type: Decision
- Origin: IDE-001
- Parent: ACT-003
- Area: Content
- Priority: Must
- Status: Decided
- Owner: Shared
- Reviewer: Shared
- Dependencies: ACT-003
- Decision: For the first mock-up, borrow Roblox free assets by default where swap-safe, and reserve early custom production for signature identity assets.
- Why: Fast placeholder sourcing reduces production cost and lets the team validate the game loop before investing heavily in bespoke art.
- Outcome: The asset plan now distinguishes borrow-friendly groups, early-replacement groups, and swap-safety rules.
- Follow-up: Create a search and intake checklist for Creator Store sourcing.

### DEC-005 - Use functional-first Creator Store intake

- ID: DEC-005
- Type: Decision
- Origin: IDE-001
- Parent: DEC-004
- Area: Content
- Priority: Must
- Status: Decided
- Owner: Shared
- Reviewer: Shared
- Dependencies: DEC-004
- Decision: Use a functional-first intake rule for Creator Store assets during mock-up, then tag accepted assets as `Keep for now`, `Prototype only`, or `Reject` through a lightweight qualitative pass.
- Why: The mock-up needs speed, but the team also needs a simple way to identify assets that should not quietly become permanent.
- Outcome: The asset plan now includes sourcing criteria, rejection rules, suitability tags, and a suggested intake checklist.
- Follow-up: Build a concrete shortlist of candidate Creator Store searches for Pack A assets.

## Audit Queue

### ACT-002 - Audit future implementation against design docs

- ID: ACT-002
- Type: Action
- Origin: IDE-001
- Parent: ACT-001
- Area: Docs
- Audit scope: Runtime
- Priority: Should
- Status: Proposed
- Owner: Shared
- Reviewer: Shared
- Dependencies: ACT-001
- Summary: Audit the first implementation pass for drift against the documented v1 progression, compute, and empire-management rules.
- Why it matters: This project depends on docs remaining source of truth while the design is still evolving quickly.
- Next check: After the first prototype branch or first runtime systems land.
- Closure:
- Remaining:
- Follow-up:
