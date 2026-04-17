# Dark AI Game - Asset Breakdown

This file records the current asset production view for the project.

Use it to answer:

- What asset groups are required for the current playable scope?
- Which assets are mandatory for v1 versus later?
- Which assets should be built as modular kits or reusable families?
- Which assets are UI, VFX, audio, or 3D content rather than gameplay code?

For project direction, see `02-GOAL-AND-PRINCIPLES.md`.
For system rules and v1 feature scope, see `03-DESIGN-AND-REQUIREMENT.md`.
For active work and ownership, see `04-WORKBOARD.md`.

## Asset Planning Rules

- Prefer reusable asset families over one-off bespoke pieces.
- Every v1 asset should support the trimmed PvE empire-builder scope first.
- If an asset exists only for a roadmap system, do not treat it as a v1 requirement.
- Favor stylized readability and production speed over realism-heavy detail.
- For mock-up work, borrow existing free assets by default when they can be wrapped safely and replaced later.

## Mock-Up Sourcing Strategy

### Default Rule

- For the first playable mock-up, prefer borrowed Roblox free assets unless the asset is central to game identity or hard to swap later.

### Swap-Safety Rules

- Gameplay code should point to project-owned asset slots, not directly to raw borrowed marketplace instances.
- Every borrowed asset should be rewrapped into the project's own folder, package, or content structure before use in gameplay scenes.
- Remove, disable, or ignore embedded scripts from borrowed assets unless they are explicitly reviewed and intentionally kept.
- Normalize borrowed assets for scale, pivot, naming, collision, and material behavior before relying on them.
- Keep a simple mapping layer between gameplay role and current visual asset so art can be swapped without code rewrites.

### Replace-First Rule

- Replace signature assets first once custom production begins.
- Signature assets currently mean:
- the player probe
- main faction ship family
- colony structure kit
- boss visuals
- core UI identity elements

### Safe-To-Borrow-Longest Rule

- The safest asset groups to keep borrowed the longest are:
- environment dressing
- asteroid fields
- generic planets and stars
- placeholder VFX
- ambient audio
- temporary pirate or neutral enemy visuals

## Creator Store Usage Guidance

### Core Rule

- For borrowed mock-up assets, faster and functional is better than polished but slow to source.

### Primary Intake Goal

- Use Creator Store assets to get the feature playable quickly, not to solve final art direction during mock-up.

### Search Priorities

- Prioritize assets that are:
- visually readable at gameplay distance
- easy to import and rewrap
- low-friction to test in scene
- close enough in function even if not perfect in theme

### Reject-Immediately Conditions

- embedded scripts that are unclear, unnecessary, or unsafe
- broken scaling or pivots that are more work to fix than to replace
- excessive visual noise that harms readability
- obviously poor performance behavior
- assets that cannot be cleanly repackaged into the project's own structure

### Functional-First Acceptance Rule

- A borrowed asset is acceptable for mock-up if it:
- performs the intended gameplay role clearly
- can be normalized quickly
- does not create technical debt in code or scene structure
- is good enough to let the team test the loop now

### Qualitative Suitability Pass

- After an asset is accepted for mock-up use, give it a simple qualitative review for long-term suitability.
- The purpose of this pass is not to block mock-up progress.
- The purpose is to mark whether the asset should likely be replaced later.

### Suitability Tags

- `Keep for now`: functional, readable, and thematically close enough to survive beyond early mock-up.
- `Prototype only`: functional enough for testing, but likely to be replaced because of theme, readability, quality, or identity mismatch.
- `Reject`: not worth integrating because it fails functional or technical checks.

### Typical Reasons To Mark `Prototype only`

- art style clashes with the intended machine-empire or sci-fi tone
- silhouette is readable but generic
- too detailed, too noisy, or too toy-like for the desired feel
- feels off-brand for player-facing signature content
- works in isolation but does not fit the broader asset family

### Intake Workflow

1. Search for the fastest functional candidate.
2. Import and remove or isolate any embedded logic.
3. Normalize scale, pivot, naming, collision, and materials.
4. Rewrap into project-owned asset folders or packages.
5. Test in the target gameplay scene.
6. Mark the asset as `Keep for now`, `Prototype only`, or `Reject`.
7. If `Prototype only`, keep using it for speed unless it starts blocking readability or theme decisions.

### Logging Guidance

- Do not spend extra time documenting every rejected asset during rapid mock-up.
- Do record any borrowed asset that becomes part of the working prototype set.
- If an asset is `Prototype only`, note the likely replacement reason so future cleanup is easier.

## Priority Bands

### Must For V1

- Required to ship the first playable empire-builder loop.

### Should After V1 Core

- Strongly improves clarity, variety, or feel, but is not required to prove the loop.

### Later

- Tied to roadmap systems or polish passes that should wait until the core loop is validated.

## Asset Groups

### 1. World and Map Assets

#### Purpose

Support navigation, system identity, environmental readability, and PvE encounter spaces.

#### Must For V1

- starfield skybox or space backdrop
- system node marker
- solar system visual anchor such as star, orbit ring, or beacon
- planet models for `small`, `medium`, and `large`
- material or surface variants for:
- habitable
- resource-focused
- terraform-candidate
- barren
- asteroid field set

#### Should After V1 Core

- stronger local system silhouettes
- orbital debris and derelict dressing
- anomaly visual markers
- richer star classes and color variation

#### Later

- travel lane visuals
- fog-of-war treatments
- gateway or rebirth event visuals

#### Reuse Notes

- Use one planet base family with material swaps and a few silhouette differences rather than unique planet meshes for every world.
- Use scalable map markers so the same marker language can support systems, events, bosses, and owned territory.
- This group is highly borrow-friendly for mock-up work and low risk to replace later.

### 2. Probe and Empire Identity Assets

#### Purpose

Represent the player as a real unit in space and provide readable ownership and progression cues.

#### Must For V1

- player probe base model
- probe movement effects such as engine trail or thrust glow
- probe scan effect
- probe hit and destruction feedback
- empire color application system
- owned-object marker set for planets, fleets, and structures

#### Should After V1 Core

- probe upgrade attachments such as scanner pods, weapon pods, cargo modules
- clone or manager portraits
- faction crest or insignia treatment

#### Later

- class-specific probe silhouettes
- rebirth-state probe visuals
- deep cosmetic customization sets

#### Reuse Notes

- Build the probe with attachment points so upgrades can be added later without replacing the base model.
- Ownership markers should share shapes and colors with the UI icon language.
- This group should be custom earlier than most other groups because it carries player identity.

### 3. Planet and Colony Assets

#### Purpose

Show colony growth, specialization, automation state, and recoverable damage without requiring a full city-builder art load.

#### Must For V1

- colony core structure
- mining structure
- energy structure
- research structure
- defense structure
- shipyard or orbital dock structure
- construction-in-progress state
- damaged state

#### Should After V1 Core

- stronger specialization silhouettes so a mining world and research world read differently at a glance
- terraform progress visuals
- automation-mode indicators for manager behavior

#### Later

- richer settlement sprawl
- biome-specific building sets
- advanced orbital megastructure visuals

#### Reuse Notes

- Build structures as a modular kit with shared bases and swappable tops or side modules.
- Planet specialization should read through a small number of strong shape and color differences rather than many unique buildings.
- Borrowed placeholders are acceptable for mock-up, but this group should be replaced fairly early because it strongly shapes the empire-builder feel.

### 4. Fleet and Combat Assets

#### Purpose

Support readable fleet composition, combat roles, and satisfying battle feedback.

#### Must For V1

- `Scout` ship model
- `Fighter` ship model
- `Support` ship model
- fleet commander or flagship marker
- weapon effects:
- laser
- ballistic or gatling
- missile
- shield-hit flash
- hull-hit feedback
- explosion or destruction effect

#### Should After V1 Core

- stronger ship upgrade silhouettes
- role-specific engine trails
- support aura or repair effects
- fleet formation markers

#### Later

- travel-mode versus combat-mode stance visuals
- large capital ship families
- unique ability-specific VFX sets

#### Reuse Notes

- Use a shared ship style language so the three v1 ship classes look related while still being readable by silhouette.
- Ship assets should work both as combat visuals and as follow or orbit representations if Roblox pet-style presentation is used.
- Borrowed ships are acceptable for mock-up, but the main player-facing ship family should be replaced once the core loop is proven.

### 5. PvE Enemy Assets

#### Purpose

Create the threat set for the v1 PvE loop without needing PvP content to carry the game.

#### Must For V1

- pirate scout ship
- pirate raider ship
- pirate boss or dreadnought
- ancient defense platform
- hostile drone or anomaly enemy
- salvage crate or reward container
- boss warning or spawn marker

#### Should After V1 Core

- faction-specific pirate visuals
- elite enemy variants
- environmental hazard set pieces

#### Later

- PvP faction differentiation assets
- neutral empire visuals
- event-chain-specific enemy families

#### Reuse Notes

- Pirate assets can be built as corrupted or rougher versions of the main ship language to save production time.
- Bosses should be larger or shaped differently enough to be recognized instantly from normal enemies.
- This group is a good candidate for longer-lived borrowed placeholders than the player's own empire assets.

### 6. UI Icon and Panel Assets

#### Purpose

Make empire management and combat state understandable without overloading the player with text.

#### Must For V1

- resource icons for:
- Ore
- Energy
- Population Support
- Research
- Influence
- Exotic Matter
- ship role icons
- planet focus icons
- compute icon
- shield, hull, invasion, and resistance icons
- quest or objective panel treatment
- map or node symbols

#### Should After V1 Core

- rarity frames or research tier treatments
- better alert states
- manager-mode portraits or badges

#### Later

- PvP status indicators
- rebirth progression panels
- advanced diplomacy symbols

#### Reuse Notes

- Use one icon family and one panel language across economy, fleets, and planets to keep the interface learnable.
- Keep icons bold and simple enough to read at Roblox scale.
- Placeholder borrowed UI art is fine for mock-up, but final identity should move to project-owned UI assets.

### 7. Audio Assets

#### Purpose

Provide readable feedback and help the game feel active even when visual simulation is lightweight.

#### Must For V1

- UI click, confirm, and warning sounds
- probe engine or movement sound
- scan sound
- weapon sounds by family
- shield-hit sound
- hull-hit sound
- explosion sound
- ambient space bed
- pirate threat stinger
- boss alert cue

#### Should After V1 Core

- stronger planet-management feedback sounds
- structure-complete and fleet-complete sounds
- richer faction audio identity

#### Later

- rebirth transition audio
- PvP callout sets
- large event music suite

#### Reuse Notes

- Short reusable audio stingers will go farther than large bespoke tracks in early development.
- Audio should reinforce state changes the player might otherwise miss while managing multiple planets or fleets.
- This group is generally safe to borrow for a long time during prototype and mock-up phases.

### 8. Motion and Animation Assets

#### Purpose

Keep gameplay readable and alive without creating a heavy animation burden.

#### Must For V1

- probe idle and movement motion
- ship hover or travel motion
- firing-point animation timing
- scan pulse
- construction complete feedback
- destruction timing

#### Should After V1 Core

- deploy or colonize sequence
- manager or structure activation cues
- boss wind-up motions

#### Later

- ability-specific animation sets
- advanced docking sequences
- rebirth transition cinematics

#### Reuse Notes

- Favor procedural or effect-driven motion where possible.
- Use animation to clarify state changes, not to chase realism.
- This group is mostly swap-safe if timing hooks are kept independent from the borrowed visual source.

## Suggested Production Packs

### Pack A - First Playable Core

- probe base model and movement effects
- three ship classes
- three planet size variants with material swaps
- five colony structures
- pirate set and one boss
- core combat VFX
- resource and role UI icons
- essential UI panel styling
- essential audio cues

### Pack B - Readability and Variety

- stronger specialization visuals
- better owned-state markers
- improved enemy variants
- richer system dressing
- additional feedback effects

### Pack C - Roadmap Systems

- fog of war visuals
- travel lane presentation
- PvP indicators
- rebirth or gateway assets
- advanced ship family sets

## Borrow Versus Build Guidance

### Borrow First For Mock-Up

- skyboxes and backdrops
- planets, stars, and asteroid fields
- placeholder colony structures
- placeholder ships
- pirate and neutral enemy models
- combat particles and general VFX
- placeholder UI frames and generic icons
- ambient audio and alert sounds

### Build Earlier Than The Rest

- player probe
- ownership marker language
- main faction ship family
- colony structure kit
- boss presentation
- core UI identity set

### Borrow With Extra Caution

- assets containing scripts
- assets with unclear licensing or ownership status inside the Roblox ecosystem
- assets with extreme poly counts or poor performance behavior
- assets with inconsistent scale or collision
- assets whose hierarchy is too messy to rewrap cleanly

## Suggested Intake Checklist

### Quick Pass

- does it solve the gameplay need right now
- can it be imported quickly
- is it readable from normal camera distance
- can it be cleaned up in minutes rather than hours

### Technical Pass

- remove or isolate scripts
- fix scale and pivot
- check collision behavior
- check performance impact
- rename and rehome into project structure

### Qualitative Pass

- does it fit the broad sci-fi direction
- does it clash with other selected assets
- does it look too generic for a signature role
- should it be marked `Keep for now` or `Prototype only`

## Roblox Implementation Notes

- Build for silhouette readability first because players will often view ships and planets from a distance.
- Prefer low-complexity meshes with strong materials, glow, and VFX accents over detail-heavy models.
- Reuse mesh families with color and attachment swaps to reduce both art cost and performance risk.
- Keep VFX modular so combat feedback can be upgraded later without replacing the underlying gameplay systems.

## Open Asset Questions

- How stylized versus serious should the visual language be?
- Should the probe and cloned managers look identical or show role/state differences?
- How much planet-side detail should be visible from the main strategic camera distance?
- Should fleets appear as full groups, condensed tokens, or hybrid visual clusters during normal navigation?
