# Dark AI Game - Goal and Principles

This is the stable north-star document for the project.

Use it to answer:

- What are we building?
- What should the user or player experience feel like?
- What principles should guide implementation choices?
- What should not drift as features are added?

For project-specific system rules, see `03-DESIGN-AND-REQUIREMENT.md`.
For active work, status, ownership, and backlog decisions, see `04-WORKBOARD.md`.
For collaboration rules, see `01-COLLABORATION-AND-ENGAGEMENT.md`.

## Project Goal

Build a Roblox-friendly 4X-inspired space strategy game where the player is a Von Neumann probe that personally explores, founds, automates, and defends a growing machine empire. The first version should prove that probe-led empire building is fun and readable before adding wider meta-progression or multi-tier galaxy scaling.

## Product North Star

The game should feel like a readable, hands-on version of grand strategy: players should always feel physically present in the universe, capable of making a meaningful difference through their own actions, while still building toward large-scale empire control and fleet warfare.

It should feel like:

- present and embodied rather than abstract
- strategically expandable without becoming instantly overwhelming
- rewarding for both active micromanagers and guided or automated players

## Core Experience Principles

### 1. The player is really there

- The player is a vulnerable but important probe unit, not an invisible commander camera.
- Expansion, scouting, colonization, and support actions should feel stronger when the player personally shows up.
- New players should be able to understand the fantasy through what the probe does in space, not only through menus.

### 2. Scale should unfold in layers

- Early play should focus on mining, founding, and one-system management before wider empire concerns appear.
- The first playable version should prioritize a strong core loop over broad progression scaffolding.
- Complexity should be introduced as an earned reward, not dumped on the player at once.

### 3. Automation is a feature, not a surrender

- Cloned probe managers should make planets feel inhabited and intelligent.
- Players should be able to choose between direct control, guided presets, and delegated execution.
- Automation should reduce friction while still consuming meaningful empire resources and leaving room for skillful play.

### 4. Macro strategy should stay legible

- Map expansion, fleet movement, and territory value should be understandable at a glance.
- Different node layouts can vary, but the surrounding opportunity within a starting area should stay broadly fair.
- Battles should look alive in real time while remaining driven by clear underlying stats and rules.

### 5. Loss should hurt without ending the run

- Raids, destroyed fleets, and lost outposts should create setbacks and recovery stories.
- A player should retain a comeback path through their probe and protected homeworld rules.
- Anti-griefing protections matter more than pure simulation realism.

## Current Directional Constraints

- The project should target Roblox-feasible v1 scope and avoid designs that require heavyweight full simulation to feel good.
- The world should be 3D, but navigation depth should be limited enough that players do not feel spatially lost.
- The first playable version should focus on a single-run empire-builder experience rather than cross-run meta systems.
- PvE should carry the initial game experience; PvP is out of scope for v1.

## Current Non-Goals

- Detailed PvP balance for launch
- Rebirth and cross-run progression systems in v1
- Fully manual planet play at late empire scale
- Hard simulation realism for logistics, orbital mechanics, or combat physics
- Permanent elimination that can lock a player out of progression

## Success Lens

A good change usually improves one or more of these without damaging the others:

- player understanding of what to do next
- feeling of personal probe impact within a larger empire
- strategic depth gained per unit of complexity added
- smooth play for both active and automation-heavy styles
