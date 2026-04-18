-- Adds colony structures on the homeworld and a small patrol fleet that
-- orbits it, so the demo reads as an active empire rather than empty space.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Wait for the homeworld to be built by SetupScene
local homeworld = Workspace:WaitForChild("Planet_Homeworld", 5)
if not homeworld then return end

local DARK    = Color3.fromRGB(45,  55,  72)
local METAL   = Color3.fromRGB(95, 105, 125)
local PANEL   = Color3.fromRGB(55,  90, 130)
local NEON    = Color3.fromRGB(0,  200, 255)
local FACTION = Color3.fromRGB(0,  170, 230)

----------------------------------------------------------------------
-- Colony cluster on the side of the homeworld facing player spawn
----------------------------------------------------------------------

local function part(name, size, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = false
	return p
end

-- Colony anchor: outward-facing point on the planet surface
-- Player approaches from -X side, so build the colony there
local planetRadius = homeworld.Size.X / 2
local outwardDir = Vector3.new(-1, 0.15, 0).Unit
local surfacePos = homeworld.Position + outwardDir * (planetRadius + 0.5)

-- Build a CFrame whose Y axis points away from planet centre
local upVec = outwardDir
local refRight = Vector3.new(0, 1, 0):Cross(upVec)
if refRight.Magnitude < 0.01 then refRight = Vector3.new(1, 0, 0):Cross(upVec) end
refRight = refRight.Unit
local fwdVec = upVec:Cross(refRight).Unit
local surfaceCF = CFrame.fromMatrix(surfacePos, refRight, upVec, -fwdVec)

local function placeOnColony(p, localOffset, localRot)
	localRot = localRot or CFrame.new()
	p.CFrame = surfaceCF * CFrame.new(localOffset) * localRot
	p.Parent = Workspace
end

-- Central command dome
local dome = part("Colony_Dome", Vector3.new(10, 10, 10), Color3.fromRGB(170, 200, 230), Enum.Material.SmoothPlastic)
dome.Shape = Enum.PartType.Ball
placeOnColony(dome, Vector3.new(0, 4.5, 0))

local domeLight = Instance.new("PointLight")
domeLight.Brightness = 1.2 ; domeLight.Range = 24 ; domeLight.Color = NEON
domeLight.Parent = dome

-- Glowing dome accent ring (a thin neon disc on top)
local domeRing = part("Colony_DomeRing", Vector3.new(6, 0.4, 6), NEON, Enum.Material.Neon)
domeRing.Shape = Enum.PartType.Cylinder
placeOnColony(domeRing, Vector3.new(0, 9, 0), CFrame.Angles(0, 0, math.rad(90)))

-- Mining tower
local miner = part("Colony_Miner", Vector3.new(3, 12, 3), METAL)
placeOnColony(miner, Vector3.new(8, 6, 4))
local minerCap = part("Colony_MinerCap", Vector3.new(3.4, 0.6, 3.4), NEON, Enum.Material.Neon)
placeOnColony(minerCap, Vector3.new(8, 12.3, 4))

-- Energy collector — angled solar panel
local solar = part("Colony_Solar", Vector3.new(7, 0.25, 5), PANEL, Enum.Material.SmoothPlastic)
placeOnColony(solar, Vector3.new(-7, 5, 4), CFrame.Angles(math.rad(-25), 0, 0))
local solarStem = part("Colony_SolarStem", Vector3.new(0.8, 4, 0.8), METAL)
placeOnColony(solarStem, Vector3.new(-7, 2, 4))

-- Energy generator — short tower with rings
local gen = part("Colony_Generator", Vector3.new(4, 6, 4), DARK)
placeOnColony(gen, Vector3.new(-7, 3, -5))
for i = 1, 3 do
	local ring = part("Colony_GenRing"..i, Vector3.new(5, 0.3, 5), NEON, Enum.Material.Neon)
	ring.Shape = Enum.PartType.Cylinder
	placeOnColony(ring, Vector3.new(-7, 1 + i * 1.6, -5), CFrame.Angles(0, 0, math.rad(90)))
end

-- Shipyard / landing pad
local pad = part("Colony_LandingPad", Vector3.new(10, 0.4, 7), Color3.fromRGB(60, 70, 90), Enum.Material.Metal)
placeOnColony(pad, Vector3.new(8, 0.4, -6))
for _, off in ipairs({Vector3.new(-4.2, 0.6, -2.8), Vector3.new(4.2, 0.6, -2.8), Vector3.new(-4.2, 0.6, 2.8), Vector3.new(4.2, 0.6, 2.8)}) do
	local marker = part("Colony_PadLight", Vector3.new(0.6, 0.4, 0.6), NEON, Enum.Material.Neon)
	placeOnColony(marker, Vector3.new(8, 0, -6) + off)
end

-- Connecting walkways — thin neon strips
local function strip(a, b)
	local mid = (a + b) / 2
	local len = (b - a).Magnitude
	local s = part("Colony_Strip", Vector3.new(0.3, 0.1, len * 0.85), NEON, Enum.Material.Neon)
	-- Strip in colony-local space
	local cf = CFrame.lookAt(surfaceCF * CFrame.new(mid).Position, surfaceCF * CFrame.new(b).Position)
	s.CFrame = cf
	s.Parent = Workspace
end

strip(Vector3.new(0, 0.6, 0),  Vector3.new( 8, 0.6,  4))
strip(Vector3.new(0, 0.6, 0),  Vector3.new(-7, 0.6,  4))
strip(Vector3.new(0, 0.6, 0),  Vector3.new(-7, 0.6, -5))
strip(Vector3.new(0, 0.6, 0),  Vector3.new( 8, 0.6, -6))

----------------------------------------------------------------------
-- Patrol fleet — two small allied scouts orbiting the homeworld
----------------------------------------------------------------------

local function makeScout(name, color)
	local model = Instance.new("Model")
	model.Name = name

	local hull = part(name.."_Hull", Vector3.new(2.4, 1, 5), DARK)
	hull.Parent = model
	model.PrimaryPart = hull

	local cockpit = part(name.."_Cockpit", Vector3.new(1.4, 0.6, 2.2), METAL)
	cockpit.Parent = model

	local wingL = part(name.."_WingL", Vector3.new(4.5, 0.18, 1.6), METAL)
	wingL.Parent = model
	local wingR = part(name.."_WingR", Vector3.new(4.5, 0.18, 1.6), METAL)
	wingR.Parent = model

	local engine = part(name.."_Engine", Vector3.new(0.8, 0.8, 0.8), color, Enum.Material.Neon)
	engine.Shape = Enum.PartType.Ball
	engine.Parent = model

	local engineLight = Instance.new("PointLight")
	engineLight.Brightness = 2 ; engineLight.Range = 14 ; engineLight.Color = color
	engineLight.Parent = engine

	model.Parent = Workspace
	return model, hull, cockpit, wingL, wingR, engine
end

local scouts = {}

local function spawnScout(name, color, phaseOffset)
	local model, hull, cockpit, wingL, wingR, engine = makeScout(name, color)
	table.insert(scouts, {
		model = model,
		hull = hull, cockpit = cockpit, wingL = wingL, wingR = wingR, engine = engine,
		phase = phaseOffset,
	})
end

spawnScout("Patrol_Alpha", FACTION, 0)
spawnScout("Patrol_Bravo", FACTION, math.pi)

-- Orbit animation
local ORBIT_RADIUS = planetRadius + 35
local ORBIT_SPEED = 0.15        -- radians per second
local ORBIT_TILT  = math.rad(12)

RunService.Heartbeat:Connect(function(dt)
	for _, s in ipairs(scouts) do
		s.phase += ORBIT_SPEED * dt
		local angle = s.phase
		local localOffset = Vector3.new(
			math.cos(angle) * ORBIT_RADIUS,
			math.sin(angle) * math.sin(ORBIT_TILT) * ORBIT_RADIUS,
			math.sin(angle) * math.cos(ORBIT_TILT) * ORBIT_RADIUS
		)
		local pos = homeworld.Position + localOffset

		-- Tangent direction = derivative of position w.r.t. angle
		local tangent = Vector3.new(
			-math.sin(angle),
			 math.cos(angle) * math.sin(ORBIT_TILT),
			 math.cos(angle) * math.cos(ORBIT_TILT)
		).Unit

		local cf = CFrame.lookAt(pos, pos + tangent)

		s.hull.CFrame    = cf
		s.cockpit.CFrame = cf * CFrame.new(0, 0.7, 0.5)
		s.wingL.CFrame   = cf * CFrame.new(-3.2, -0.1, 0.5)
		s.wingR.CFrame   = cf * CFrame.new( 3.2, -0.1, 0.5)
		s.engine.CFrame  = cf * CFrame.new(0, 0, 2.8)
	end
end)
