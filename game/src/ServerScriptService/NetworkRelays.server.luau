-- Communication / comms relay network: a handful of floating beacons
-- between the homeworld, resource world, and jump gate. Each beacon is a
-- small pylon with a pulsing neon core. Translucent beam segments connect
-- the nearest pair of beacons, selling "the empire has infrastructure".
--
-- Plus: translucent shield dome over the homeworld colony side to suggest
-- planetary defence. Pulses very slowly.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local NEON = Color3.fromRGB(0, 220, 255)
local METAL = Color3.fromRGB(95, 105, 125)

----------------------------------------------------------------------
-- Beacon builder
----------------------------------------------------------------------

local function makeBeacon(name, pos)
	local model = Instance.new("Model")
	model.Name = name

	local pylon = Instance.new("Part")
	pylon.Name = "Pylon"
	pylon.Size = Vector3.new(1.2, 8, 1.2)
	pylon.Position = pos
	pylon.Material = Enum.Material.Metal
	pylon.Color = METAL
	pylon.Anchored = true ; pylon.CanCollide = false ; pylon.CastShadow = false
	pylon.Parent = model
	model.PrimaryPart = pylon

	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Size = Vector3.new(2.4, 2.4, 2.4)
	core.Position = pos + Vector3.new(0, 5, 0)
	core.Material = Enum.Material.Neon
	core.Color = NEON
	core.Anchored = true ; core.CanCollide = false ; core.CastShadow = false
	core.Parent = model

	local halo = Instance.new("Part")
	halo.Name = "Halo"
	halo.Shape = Enum.PartType.Ball
	halo.Size = Vector3.new(4.6, 4.6, 4.6)
	halo.Position = core.Position
	halo.Material = Enum.Material.ForceField
	halo.Color = NEON
	halo.Transparency = 0.7
	halo.Anchored = true ; halo.CanCollide = false ; halo.CastShadow = false
	halo.Parent = model

	local light = Instance.new("PointLight")
	light.Brightness = 3 ; light.Range = 30 ; light.Color = NEON
	light.Parent = core

	-- Rotating accent ring
	local ring = Instance.new("Part")
	ring.Name = "Ring"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.3, 5, 5)
	ring.CFrame = CFrame.new(core.Position) * CFrame.Angles(0, 0, math.rad(90))
	ring.Material = Enum.Material.Neon
	ring.Color = NEON
	ring.Transparency = 0.3
	ring.Anchored = true ; ring.CanCollide = false ; ring.CastShadow = false
	ring.Parent = model

	model.Parent = Workspace
	return model, core, halo, ring
end

local beacons = {
	{ pos = Vector3.new( 320,  40, -100) },
	{ pos = Vector3.new(  50, -30, -350) },
	{ pos = Vector3.new( 500,  80,  180) },
	{ pos = Vector3.new(-250,  60,  100) },
}

local beaconData = {}
for i, b in ipairs(beacons) do
	local _, core, halo, ring = makeBeacon("CommsBeacon_" .. i, b.pos)
	table.insert(beaconData, { core = core, halo = halo, ring = ring, pos = b.pos })
end

----------------------------------------------------------------------
-- Beam segments between adjacent beacons
----------------------------------------------------------------------

local function makeBeam(a, b)
	local mid = (a + b) / 2
	local len = (b - a).Magnitude
	local beam = Instance.new("Part")
	beam.Name = "CommsBeam"
	beam.Size = Vector3.new(0.2, 0.2, len)
	beam.CFrame = CFrame.lookAt(mid, b)
	beam.Material = Enum.Material.Neon
	beam.Color = NEON
	beam.Transparency = 0.6
	beam.Anchored = true ; beam.CanCollide = false ; beam.CastShadow = false
	beam.Parent = Workspace
	return beam
end

for i = 1, #beacons - 1 do
	makeBeam(beacons[i].pos, beacons[i + 1].pos)
end
makeBeam(beacons[#beacons].pos, beacons[1].pos)   -- close the loop

----------------------------------------------------------------------
-- Beacon pulse animation
----------------------------------------------------------------------

RunService.Heartbeat:Connect(function()
	local t = os.clock()
	for i, d in ipairs(beaconData) do
		local phase = t * 1.5 + i * 0.7
		d.halo.Transparency = 0.65 + math.sin(phase) * 0.1
		d.ring.CFrame = CFrame.new(d.core.Position)
			* CFrame.Angles(0, t * 1.2 + i, 0)
			* CFrame.Angles(0, 0, math.rad(90))
	end
end)

----------------------------------------------------------------------
-- Homeworld colony shield dome
----------------------------------------------------------------------

local homeworld = Workspace:WaitForChild("Planet_Homeworld", 5)
if homeworld then
	local planetRadius = homeworld.Size.X / 2
	local outwardDir = Vector3.new(-1, 0.15, 0).Unit
	local surfacePos = homeworld.Position + outwardDir * (planetRadius + 0.5)

	local dome = Instance.new("Part")
	dome.Name = "Colony_ShieldDome"
	dome.Shape = Enum.PartType.Ball
	dome.Size = Vector3.new(36, 36, 36)
	dome.Position = surfacePos
	dome.Material = Enum.Material.ForceField
	dome.Color = NEON
	dome.Transparency = 0.78
	dome.Anchored = true ; dome.CanCollide = false ; dome.CastShadow = false
	dome.Parent = Workspace

	task.spawn(function()
		local t = 0
		while dome.Parent do
			t += 0.06
			dome.Transparency = 0.78 + math.sin(t) * 0.05
			task.wait(0.1)
		end
	end)
end
