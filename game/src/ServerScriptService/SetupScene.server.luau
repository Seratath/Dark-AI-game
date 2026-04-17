-- Builds the dark space scene at runtime.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate then baseplate:Destroy() end

-- Deep space lighting
Lighting.Ambient = Color3.fromRGB(2, 2, 8)
Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 3)
Lighting.Brightness = 0
Lighting.GlobalShadows = false

-- Starfield sky
Instance.new("Sky").Parent = Lighting

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

	-- Atmosphere halo
	local atmo = Instance.new("Part")
	atmo.Name = name .. "_Atmo"
	atmo.Shape = Enum.PartType.Ball
	atmo.Size = Vector3.new(size * 1.18, size * 1.18, size * 1.18)
	atmo.Position = position
	atmo.Anchored = true
	atmo.CanCollide = false
	atmo.Material = Enum.Material.ForceField
	atmo.Color = color
	atmo.Transparency = 0.82
	atmo.CastShadow = false
	atmo.Parent = Workspace

	return p
end

makePlanet("Planet_Homeworld", 30, Vector3.new( 300,   0,    0), Color3.fromRGB( 55, 120, 200))
makePlanet("Planet_Barren",    18, Vector3.new(-400,  50,  200), Color3.fromRGB(130,  90,  60), Enum.Material.Slate)
makePlanet("Planet_Resource",  22, Vector3.new( 100, -80, -500), Color3.fromRGB(175, 135,  50), Enum.Material.Granite)

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
spawn.Position = Vector3.new(330, 20, 0)
spawn.Anchored = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(0, 200, 255)
spawn.Duration = 0
spawn.Parent = Workspace
