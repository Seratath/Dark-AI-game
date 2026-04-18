-- Space dust: small glowing motes that follow the probe and stream past the
-- camera when moving. Pure parallax — nothing gameplay-relevant. Makes the
-- sense of motion in empty space much stronger.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local DUST_COUNT  = 80
local FIELD_RADIUS = 120      -- studs around the camera
local MOTE_SIZE   = 0.18

local container = Instance.new("Folder")
container.Name = "SpaceDust"
container.Parent = Workspace

local rng = Random.new()
local motes = {}

local function randomPointInShell()
	-- Uniform-ish point in a sphere around origin
	local theta = rng:NextNumber(0, math.pi * 2)
	local phi   = math.acos(rng:NextNumber(-1, 1))
	local r     = rng:NextNumber(FIELD_RADIUS * 0.3, FIELD_RADIUS)
	return Vector3.new(
		r * math.sin(phi) * math.cos(theta),
		r * math.sin(phi) * math.sin(theta),
		r * math.cos(phi)
	)
end

for i = 1, DUST_COUNT do
	local m = Instance.new("Part")
	m.Name = "Dust"
	m.Size = Vector3.new(MOTE_SIZE, MOTE_SIZE, MOTE_SIZE)
	m.Shape = Enum.PartType.Ball
	m.Material = Enum.Material.Neon
	m.Color = Color3.fromRGB(
		rng:NextInteger(180, 230),
		rng:NextInteger(210, 240),
		rng:NextInteger(230, 255)
	)
	m.Transparency = rng:NextNumber(0.2, 0.6)
	m.Anchored = true
	m.CanCollide = false
	m.CastShadow = false
	m.Position = camera.CFrame.Position + randomPointInShell()
	m.Parent = container
	table.insert(motes, m)
end

RunService.RenderStepped:Connect(function()
	local camPos = camera.CFrame.Position
	for _, m in ipairs(motes) do
		local offset = m.Position - camPos
		-- Wrap motes that drift outside the field back to the far side
		if offset.Magnitude > FIELD_RADIUS then
			m.Position = camPos + randomPointInShell()
		end
	end
end)
