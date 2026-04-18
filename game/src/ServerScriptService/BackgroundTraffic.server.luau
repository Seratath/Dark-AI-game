-- A large distant cargo freighter drifting slowly across the sector. Too
-- far away to interact with, but gives the backdrop a sense of an
-- inhabited universe instead of an empty diorama.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local DARK  = Color3.fromRGB(50,  60,  80)
local METAL = Color3.fromRGB(100, 112, 135)
local NEON  = Color3.fromRGB(255, 180,  80)

local freighter = Instance.new("Model")
freighter.Name = "BackgroundFreighter"

local function part(name, size, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = false
	p.Parent = freighter
	return p
end

-- Long central spine
local spine = part("Freighter_Spine", Vector3.new(12, 6, 80), DARK)
freighter.PrimaryPart = spine

-- Cargo containers stacked along the spine
for i = -3, 3 do
	part("Freighter_Cargo_" .. i, Vector3.new(8, 6, 10), METAL)
	part("Freighter_Cargo_" .. i .. "_Top", Vector3.new(8, 3, 10), DARK)
end

-- Bridge block up front
part("Freighter_Bridge", Vector3.new(10, 6, 14), METAL)

-- Engine cluster
part("Freighter_Engine1", Vector3.new(5, 5, 5), NEON, Enum.Material.Neon)
part("Freighter_Engine2", Vector3.new(5, 5, 5), NEON, Enum.Material.Neon)
local el1 = Instance.new("PointLight")
el1.Brightness = 2 ; el1.Range = 30 ; el1.Color = NEON
el1.Parent = freighter:FindFirstChild("Freighter_Engine1")
local el2 = Instance.new("PointLight")
el2.Brightness = 2 ; el2.Range = 30 ; el2.Color = NEON
el2.Parent = freighter:FindFirstChild("Freighter_Engine2")

-- Running lights
for i = -3, 3 do
	local light = part("Freighter_Light_" .. i, Vector3.new(0.6, 0.6, 0.6), NEON, Enum.Material.Neon)
	light.Shape = Enum.PartType.Ball
end

freighter.Parent = Workspace

----------------------------------------------------------------------
-- Path: drifts slowly across the sector on a diagonal high above the
-- playfield, loops back when it reaches the far side.
----------------------------------------------------------------------

local START = Vector3.new(-2400,  400,  1800)
local END   = Vector3.new( 2400,  600, -1800)
local SPEED_UNITS_PER_SEC = 24

local direction = (END - START).Unit
local heading = CFrame.lookAt(Vector3.zero, direction)
local travel = (END - START).Magnitude

local progress = 0

local function layout(cf)
	spine.CFrame = cf
	freighter:FindFirstChild("Freighter_Bridge").CFrame = cf * CFrame.new(0, 4, -30)

	for i = -3, 3 do
		local c = freighter:FindFirstChild("Freighter_Cargo_" .. i)
		local t = freighter:FindFirstChild("Freighter_Cargo_" .. i .. "_Top")
		if c then c.CFrame = cf * CFrame.new(0, 4, i * 10.2) end
		if t then t.CFrame = cf * CFrame.new(0, 8.5, i * 10.2) end
	end

	freighter:FindFirstChild("Freighter_Engine1").CFrame = cf * CFrame.new(-4, 0, 38)
	freighter:FindFirstChild("Freighter_Engine2").CFrame = cf * CFrame.new( 4, 0, 38)

	for i = -3, 3 do
		local l = freighter:FindFirstChild("Freighter_Light_" .. i)
		if l then l.CFrame = cf * CFrame.new(0, -3.2, i * 10.2) end
	end
end

RunService.Heartbeat:Connect(function(dt)
	progress += SPEED_UNITS_PER_SEC * dt
	if progress > travel then progress = 0 end
	local pos = START + direction * progress
	layout(CFrame.lookAt(pos, pos + direction))
end)
