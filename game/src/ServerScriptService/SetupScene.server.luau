-- Builds the dark space scene at runtime.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate then baseplate:Destroy() end

-- Deep space lighting
-- Roblox PointLight range caps at 60 studs, so the central star can't actually
-- light planets that are hundreds of studs away. Bumping ambient gives uniform
-- visibility instead, sacrificing realistic shadowing for readable distance.
Lighting.Ambient = Color3.fromRGB(70, 75, 95)
Lighting.OutdoorAmbient = Color3.fromRGB(35, 40, 55)
Lighting.Brightness = 0
Lighting.ClockTime = 0                      -- night, kills the sun
Lighting.ExposureCompensation = -0.1
Lighting.EnvironmentDiffuseScale = 0        -- no skybox-based diffuse light
Lighting.EnvironmentSpecularScale = 0       -- no skybox-based reflections
Lighting.GlobalShadows = false

-- Default Sky with no sun/moon and many stars
local sky = Instance.new("Sky")
sky.CelestialBodiesShown = false
sky.StarCount = 6000
sky.Parent = Lighting

-- Remove all atmospheric haze so the background is black space
local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0
atmosphere.Offset = 0
atmosphere.Color = Color3.fromRGB(0, 0, 0)
atmosphere.Decay = Color3.fromRGB(0, 0, 0)
atmosphere.Glare = 0
atmosphere.Haze = 0
atmosphere.Parent = Lighting

-- Bloom — makes neon parts glow
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 1.2
bloom.Size = 28
bloom.Threshold = 0.9
bloom.Parent = Lighting

-- Cool blue grade
local cc = Instance.new("ColorCorrectionEffect")
cc.TintColor = Color3.fromRGB(190, 210, 255)
cc.Brightness = -0.06
cc.Contrast = 0.08
cc.Saturation = 0.15
cc.Parent = Lighting

-- Central star
local star = Instance.new("Part")
star.Name = "Star_Sol"
star.Shape = Enum.PartType.Ball
star.Size = Vector3.new(60, 60, 60)
star.Position = Vector3.new(0, 0, 0)
star.Anchored = true
star.CanCollide = false
star.Material = Enum.Material.Neon
star.Color = Color3.fromRGB(255, 230, 100)
star.CastShadow = false
star.Parent = Workspace

local starLight = Instance.new("PointLight")
starLight.Brightness = 6
starLight.Range = 1400
starLight.Color = Color3.fromRGB(255, 215, 140)
starLight.Parent = star

-- Planet builder
local function makePlanet(name, size, position, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(size, size, size)
	p.Position = position
	p.Anchored = true
	p.CanCollide = true
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color
	p.CastShadow = false
	p.Parent = Workspace

	-- Inner atmosphere — close to surface, more visible
	local innerAtmo = Instance.new("Part")
	innerAtmo.Name = name .. "_AtmoInner"
	innerAtmo.Shape = Enum.PartType.Ball
	innerAtmo.Size = Vector3.new(size * 1.08, size * 1.08, size * 1.08)
	innerAtmo.Position = position
	innerAtmo.Anchored = true
	innerAtmo.CanCollide = false
	innerAtmo.Material = Enum.Material.ForceField
	innerAtmo.Color = color
	innerAtmo.Transparency = 0.6
	innerAtmo.CastShadow = false
	innerAtmo.Parent = Workspace

	-- Outer atmosphere — wider, softer
	local outerAtmo = Instance.new("Part")
	outerAtmo.Name = name .. "_AtmoOuter"
	outerAtmo.Shape = Enum.PartType.Ball
	outerAtmo.Size = Vector3.new(size * 1.35, size * 1.35, size * 1.35)
	outerAtmo.Position = position
	outerAtmo.Anchored = true
	outerAtmo.CanCollide = false
	outerAtmo.Material = Enum.Material.ForceField
	outerAtmo.Color = color
	outerAtmo.Transparency = 0.85
	outerAtmo.CastShadow = false
	outerAtmo.Parent = Workspace

	return p
end

-- Bigger planets so they read at distance
makePlanet("Planet_Homeworld", 90, Vector3.new( 500,   0,    0), Color3.fromRGB( 80, 160, 230))
makePlanet("Planet_Barren",    55, Vector3.new(-600,  80,  300), Color3.fromRGB(170, 130,  90), Enum.Material.Slate)
makePlanet("Planet_Resource",  70, Vector3.new( 200,-120, -700), Color3.fromRGB(220, 175,  80), Enum.Material.Granite)

-- Asteroid field
local rng = Random.new(42)
for i = 1, 60 do
	local a = Instance.new("Part")
	a.Name = "Asteroid_" .. i
	a.Size = Vector3.new(rng:NextNumber(1.5, 7), rng:NextNumber(1, 4.5), rng:NextNumber(1.5, 7))
	a.Material = Enum.Material.Slate
	a.Color = Color3.fromRGB(
		rng:NextInteger(55, 85),
		rng:NextInteger(50, 75),
		rng:NextInteger(45, 70)
	)
	a.Anchored = true
	a.CanCollide = true
	a.CastShadow = false
	local angle = rng:NextNumber(0, math.pi * 2)
	local radius = rng:NextNumber(130, 580)
	local height = rng:NextNumber(-70, 70)
	a.CFrame = CFrame.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
		* CFrame.Angles(
			rng:NextNumber(0, math.pi),
			rng:NextNumber(0, math.pi),
			rng:NextNumber(0, math.pi)
		)
	a.Parent = Workspace
end

-- Probe spawn (near homeworld)
local spawn = Instance.new("SpawnLocation")
spawn.Name = "ProbeSpawn"
spawn.Size = Vector3.new(4, 1, 4)
spawn.Position = Vector3.new(380, 30, 80)
spawn.Anchored = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(0, 200, 255)
spawn.Duration = 0
spawn.Parent = Workspace
