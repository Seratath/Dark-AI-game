-- Dark space scene — first prototype pass
-- Creates a minimal star system: one sun, three planets, a probe spawn point.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Remove default baseplate
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate then baseplate:Destroy() end

-- Deep space lighting
Lighting.Ambient = Color3.fromRGB(5, 5, 10)
Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
Lighting.Brightness = 0
Lighting.GlobalShadows = false

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
star.Parent = Workspace

local starLight = Instance.new("PointLight")
starLight.Brightness = 5
starLight.Range = 1000
starLight.Color = Color3.fromRGB(255, 220, 150)
starLight.Parent = star

-- Helper
local function makePlanet(name, size, position, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(size, size, size)
	p.Position = position
	p.Anchored = true
	p.CanCollide = false
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color
	p.Parent = Workspace
	return p
end

-- Planets
makePlanet("Planet_Homeworld",  30, Vector3.new( 300,   0,    0), Color3.fromRGB( 60, 130, 200))
makePlanet("Planet_Barren",     18, Vector3.new(-400,  50,  200), Color3.fromRGB(140, 100,  70))
makePlanet("Planet_Resource",   22, Vector3.new( 100, -80, -500), Color3.fromRGB(180, 140,  60), Enum.Material.Granite)

-- Probe spawn point (near homeworld)
local spawn = Instance.new("SpawnLocation")
spawn.Name = "ProbeSpawn"
spawn.Size = Vector3.new(4, 1, 4)
spawn.Position = Vector3.new(330, 20, 0)
spawn.Anchored = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(0, 200, 255)
spawn.Duration = 0
spawn.Parent = Workspace
