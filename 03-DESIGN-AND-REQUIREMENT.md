# Dark AI Game - Design and Requirement

This file records the current project-specific system behavior, requirements, formulas, and balance-facing or state-facing rules.

If runtime code and this file disagree, runtime wins until this file is updated.

For project direction, see `02-GOAL-AND-PRINCIPLES.md`.
For current work and ownership, see `04-WORKBOARD.md`.
For process rules, see `01-COLLABORATION-AND-ENGAGEMENT.md`.

## Core Runtime Curves

### Server Tier Scale

```text
V1 target: one playable server configuration with a controlled node count sized for readable empire building and PvE testing.
Future server tiers and larger maps are roadmap items, not v1 requirements.
```

### Progression Flow

```text
Tutorial (colony start)
-> resource quests
-> unlock
-> expansion quests
-> unlock
-> combat quests
-> boss encounter
-> empire growth milestone
```

## Current System Rules

### World Structure

- The strategic map is a 3D node network with controlled verticality so players can navigate without getting lost.
- V1 nodes should all be solar systems to keep generation, UX, and economy simpler.
- Solar-system nodes can contain multiple planets and local resource opportunities.
- Node value should vary in composition, but surrounding areas should be weighted so that starting positions have broadly comparable total opportunity.
- Fog of war is not required for v1.

### Travel and Map Control

- The player probe can free-fly through space and is not restricted to lane-only travel.
- Travel lanes are not required for v1.
- The v1 map should optimize for understandable movement between systems without relying on hidden-information mechanics.

### Starting State

- The default starting fantasy is a Von Neumann probe beginning with limited infrastructure and broad but shallow capability.
- A standard starting colony pattern should include one immediately habitable large planet, three good resource planets, and two terraform candidates unless the specific starting template is revised later.
- The probe begins with broad capability but limited depth, then specializes through research, class choices, and empire development.

### Planet Management

- Colonization creates a cloned probe manager assigned to the planet.
- Planet managers should feel like intelligent agents rather than silent automation widgets.
- Planet control should support at least three operating modes:
- direct player control
- guided focus selection such as "make this an energy planet"
- manager-led optimization with player-selected priorities
- Planet managers may handle build queues, specialization, repair, defense preparation, and local production according to their assigned mode.
- More capable or more active automation should consume more shared compute.

### Compute and Empire Capacity

- Shared compute is the primary empire-cap resource for the player and all cloned managers.
- Compute creates both a soft cap and a hard cap by tying empire scale to manager effectiveness and automation level, not only to colony count.
- Players can exceed purely passive management limits by doing more work themselves, but cannot ignore compute pressure entirely.
- Research may improve compute efficiency and some management caps within a server tier.
- Large cap increases that materially alter overall scale should be treated as future-version progression rather than v1 balance assumptions.

### Resources

- Initial launch resource set:
- Ore
- Energy
- Population Support
- Research
- Influence
- Exotic Matter
- Ore is the baseline material for construction and standard fleet production.
- Energy powers upkeep, shields, and advanced processes.
- Population Support represents the sustainment needed for colony growth and invasion readiness.
- Research unlocks technology and progression systems.
- Influence supports governance, doctrines, commands, and some expansion friction.
- Exotic Matter is rare and should gate powerful research, modules, events, or end-tier upgrades.

### Probe Progression

- The probe is always recoverable after defeat and represents the player's continuity object within a run.
- Probe combat power and utility should vary by class choice, but early progression should emphasize breadth over deep specialization.
- The probe can contribute through combat, support, colonization, scanning, and local empire actions.

### Rebirth Structure

- Rebirth and cross-run progression are future features and are not part of v1 requirements.

### Offline and Session Continuity

- V1 should save and restore the player's empire state cleanly between sessions.
- Offline simulation, contested ownership recovery, and advanced server reassignment are future concerns rather than v1 requirements.

### Fleets and Combat

- Space combat should present as real-time visible battle with ships firing readable attacks such as lasers, projectiles, or missiles.
- Actual combat resolution is state-driven and should calculate each action from current fleet state when a unit's timer resolves.
- Fleet composition affects both stats and behavior.
- Early v1 fleet roles are:
- Scout: speed and perception focus
- Fighter: dexterity and strike focus
- Support: endurance and regeneration focus
- Fleets should have both a fleet-count cap and a max unit-value cap per fleet.
- Ship lines may include multiple versions where older variants remain relevant through different powers rather than only worse stats.
- Special powers may target priorities, alter timing, or shift effective combat probability rather than requiring bespoke full simulation for every effect.

### Invasions and Defense

- Ground conflict is abstracted into invasion and resistance power rather than direct manual unit tactics.
- Fleet bombardment contributes to invasion success.
- Underlying ships, modifiers, abilities, and planetary defenses should feed the invasion and resistance profile.
- Planetary conquest should not be reducible to a single flat score if targeted abilities or defensive counters are present.

### PvE Pressure

- Pirates are a baseline roaming PvE threat that attacks nearby targets and creates ambient risk.
- Pirates should be dangerous enough to punish weakness and recovery states without overwhelming stable empires.
- Periodic boss or event encounters should create shared objectives with meaningful rewards.
- Initial recognizable PvE event anchors include:
- pirate dreadnought encounters
- hostile anomaly or drone swarms
- ancient defense platforms guarding valuable rewards

## Current Requirements

- The early game must teach the core loop of mining, colonizing, specializing, and expanding before deep strategy layers unlock.
- The game must support both hands-on players and players who prefer automation-heavy empire play.
- Homeworlds must be raidable but not permanently destroyable.
- Successful raids on a homeworld should create a protected recovery state to reduce griefing.
- Players must always retain a comeback path through their probe even after severe losses.
- Node generation must target fairness by local area weighting, not by forcing identical system templates.
- PvP is not a v1 requirement.
- Travel lanes and fog of war are not v1 requirements.
- Rebirth and cross-run progression are not v1 requirements.

## Known Watchpoints

- Too many simultaneous progression layers can overwhelm players before the automation fantasy has time to pay off.
- Real-time combat presentation must stay cheap enough for Roblox while still feeling responsive and readable.
- A 3D map can become disorienting if vertical spread is too aggressive or if route readability is weak.
- Compute must create interesting pressure without turning automation into a punishment mechanic.
- The design should not keep roadmap systems half-alive in v1 if they are not actively improving the first playable loop.

## Update Rule

If code changes:

- formulas
- caps
- progression curves
- unlock rules
- persistence assumptions
- state or constraint rules

update this file in the same pass.
