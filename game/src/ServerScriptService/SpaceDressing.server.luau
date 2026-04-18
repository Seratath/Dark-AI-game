-- World dressing beyond the homeworld colony: nebula clouds for colour,
-- a derelict wreck to imply history, a jump gate to imply travel, and a
-- pirate raider patrolling the resource world to imply threat.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

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

local DARK    = Color3.fromRGB(35, 42, 58)
local METAL   = Color3.fromRGB(95, 105, 125)
local NEON    = Color3.fromRGB(0,  200, 255)
local HOSTILE = Color3.fromRGB(255, 70,  70)

----------------------------------------------------------------------
-- Nebula clouds — clusters of large transparent ForceField blobs
----------------------------------------------------------------------

local function nebula(center, baseColor, blobCount, spread, sizeMin, sizeMax)
	local rng = Random.new(center.X * 7 + center.Z * 13)
	for i = 1, blobCount do
		local offset = Vector3.new(
			rng:NextNumber(-spread, spread),
			rng:NextNumber(-spread * 0.4, spread * 0.4),
			rng:NextNumber(-spread, spread)
		)
		local s = rng:NextNumber(sizeMin, sizeMax)
		local blob = Instance.new("Part")
		blob.Name = "Nebula_Blob"
		blob.Shape = Enum.PartType.Ball
		blob.Size = Vector3.new(s, s, s)
		blob.Position = center + offset
		blob.Anchored = true
		blob.CanCollide = false
		blob.CastShadow = false
		blob.Material = Enum.Material.ForceField
		blob.Color = Color3.fromRGB(
			math.clamp(baseColor.R * 255 + rng:NextInteger(-20, 20), 0, 255),
			math.clamp(baseColor.G * 255 + rng:NextInteger(-20, 20), 0, 255),
			math.clamp(baseColor.B * 255 + rng:NextInteger(-20, 20), 0, 255)
		)
		blob.Transparency = 0.85
		blob.Parent = Workspace
	end
end

nebula(Vector3.new(-1100, 100,  900), Color3.fromRGB(180,  80, 200), 12, 240, 140, 260)  -- magenta
nebula(Vector3.new( 900,  -50,-1200), Color3.fromRGB( 60, 140, 220), 14, 280, 160, 300)  -- blue
nebula(Vector3.new(-200, 250, 1400), Color3.fromRGB(220, 120,  60), 10, 220, 130, 240)  -- amber

----------------------------------------------------------------------
-- Derelict wreck — broken ship hull near the asteroid field
----------------------------------------------------------------------

local wreckCenter = Vector3.new(-180, -40, 420)
local wreckCF = CFrame.new(wreckCenter) * CFrame.Angles(math.rad(15), math.rad(40), math.rad(-30))

local function placeWreck(p, localOffset, localRot)
	p.CFrame = wreckCF * CFrame.new(localOffset) * (localRot or CFrame.new())
	p.Parent = Workspace
end

local wHull = part("Wreck_Hull", Vector3.new(8, 4, 22), DARK, Enum.Material.Slate)
placeWreck(wHull, Vector3.new(0, 0, 0))

local wBreak = part("Wreck_BreakNose", Vector3.new(6, 3, 5), DARK, Enum.Material.Slate)
placeWreck(wBreak, Vector3.new(0.6, -0.4, -13), CFrame.Angles(0, math.rad(20), math.rad(8)))

local wWingL = part("Wreck_WingL", Vector3.new(10, 0.5, 4), METAL, Enum.Material.Slate)
placeWreck(wWingL, Vector3.new(-7, -0.2, 1), CFrame.Angles(0, 0, math.rad(-22)))

local wDebris1 = part("Wreck_Debris1", Vector3.new(2, 1.5, 3), METAL, Enum.Material.Slate)
placeWreck(wDebris1, Vector3.new(8, 2, -3), CFrame.Angles(math.rad(40), math.rad(20), 0))
local wDebris2 = part("Wreck_Debris2", Vector3.new(1.6, 1, 2), METAL, Enum.Material.Slate)
placeWreck(wDebris2, Vector3.new(12, -1, 4), CFrame.Angles(math.rad(10), math.rad(60), 0))

-- Faint flickering distress light
local distress = part("Wreck_Distress", Vector3.new(0.6, 0.6, 0.6), Color3.fromRGB(255, 80, 80), Enum.Material.Neon)
distress.Shape = Enum.PartType.Ball
placeWreck(distress, Vector3.new(0, 2.2, -10))
local distressLight = Instance.new("PointLight")
distressLight.Brightness = 2 ; distressLight.Range = 18 ; distressLight.Color = Color3.fromRGB(255, 80, 80)
distressLight.Parent = distress

task.spawn(function()
	while distress.Parent do
		distress.Transparency = 0
		distressLight.Brightness = 2
		task.wait(0.6)
		distress.Transparency = 0.7
		distressLight.Brightness = 0.2
		task.wait(0.4)
	end
end)

----------------------------------------------------------------------
-- Jump gate — large neon ring with rotating inner accent
----------------------------------------------------------------------

local gatePos = Vector3.new(750, 60, 350)
local gateRing = part("JumpGate_Ring", Vector3.new(4, 50, 50), Color3.fromRGB(60, 80, 120), Enum.Material.Metal)
gateRing.Shape = Enum.PartType.Cylinder
gateRing.CFrame = CFrame.new(gatePos) * CFrame.Angles(0, math.rad(35), 0) * CFrame.Angles(0, 0, math.rad(90))
gateRing.Parent = Workspace

-- Hollow it visually with a smaller neon inner accent ring
local gateInner = part("JumpGate_Inner", Vector3.new(1.2, 42, 42), NEON, Enum.Material.Neon)
gateInner.Shape = Enum.PartType.Cylinder
gateInner.CFrame = gateRing.CFrame
gateInner.Parent = Workspace

-- Four pylon nodes around the ring
for i = 0, 3 do
	local angle = i * math.pi / 2
	local node = part("JumpGate_Node", Vector3.new(3, 3, 3), NEON, Enum.Material.Neon)
	node.Shape = Enum.PartType.Ball
	local localOff = Vector3.new(0, math.cos(angle) * 26, math.sin(angle) * 26)
	node.CFrame = gateRing.CFrame * CFrame.new(localOff)
	node.Parent = Workspace
	local nl = Instance.new("PointLight")
	nl.Brightness = 2 ; nl.Range = 30 ; nl.Color = NEON
	nl.Parent = node
end

-- Inner shimmer plane (transparent neon disc filling the ring)
local shimmer = part("JumpGate_Shimmer", Vector3.new(0.3, 38, 38), Color3.fromRGB(120, 220, 255), Enum.Material.ForceField)
shimmer.Shape = Enum.PartType.Cylinder
shimmer.CFrame = gateRing.CFrame
shimmer.Transparency = 0.4
shimmer.Parent = Workspace

local gateLight = Instance.new("PointLight")
gateLight.Brightness = 4 ; gateLight.Range = 60 ; gateLight.Color = NEON
gateLight.Parent = gateRing

----------------------------------------------------------------------
-- Mother mining asteroid near the resource world — claimable ore source.
-- Previously created by MiningOps (now deleted, since drones only spawn
-- when the player deploys them).
----------------------------------------------------------------------

local resourceForAsteroid = Workspace:WaitForChild("Planet_Resource", 5)
if resourceForAsteroid then
	local ac = resourceForAsteroid.Position + Vector3.new(80, 30, 80)
	local rock = Instance.new("Part")
	rock.Name = "Mining_Asteroid"
	rock.Shape = Enum.PartType.Ball
	rock.Size = Vector3.new(18, 14, 20)
	rock.Position = ac
	rock.Anchored = true ; rock.CanCollide = false ; rock.CastShadow = false
	rock.Material = Enum.Material.Slate
	rock.Color = Color3.fromRGB(120, 95, 70)
	rock.Parent = Workspace

	for i = 1, 4 do
		local vein = Instance.new("Part")
		vein.Name = "Ore_Vein"
		vein.Size = Vector3.new(2.5, 0.4, 2.5)
		vein.Material = Enum.Material.Neon
		vein.Color = Color3.fromRGB(255, 220, 120)
		vein.Anchored = true ; vein.CanCollide = false ; vein.CastShadow = false
		local angle = i * math.pi / 2 + 0.3
		vein.CFrame = CFrame.new(ac) * CFrame.Angles(angle, angle * 0.7, 0) * CFrame.new(0, 7, 0)
		vein.Parent = Workspace
	end
end

-- Pirate raider lives in CombatService now (AI + combat FSM).
