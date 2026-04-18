-- Server-authoritative deployment: client asks to drop a relay beacon at
-- a given position, server checks ore cost, spends it, spawns the world
-- object, and echoes the outcome back to the client.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local state = ReplicatedStorage:WaitForChild("EmpireState")
local remotes = ReplicatedStorage:WaitForChild("EmpireRemotes")
local deployBeacon = remotes:WaitForChild("DeployBeacon")
local deployResult = remotes:WaitForChild("DeployResult")

local NEON = Color3.fromRGB(0, 220, 255)
local METAL = Color3.fromRGB(95, 105, 125)

local BEACON_COST = 5
local deployCounter = 0

local function part(size, color, material)
	local p = Instance.new("Part")
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.Anchored = true ; p.CanCollide = false ; p.CastShadow = false
	return p
end

local function spawnPlayerBeacon(position)
	deployCounter += 1
	local model = Instance.new("Model")
	model.Name = "PlayerBeacon_" .. deployCounter

	local pylon = part(Vector3.new(1, 6, 1), METAL)
	pylon.Position = position
	pylon.Parent = model
	model.PrimaryPart = pylon

	local core = part(Vector3.new(2, 2, 2), NEON, Enum.Material.Neon)
	core.Shape = Enum.PartType.Ball
	core.Position = position + Vector3.new(0, 4, 0)
	core.Parent = model

	local halo = part(Vector3.new(4, 4, 4), NEON, Enum.Material.ForceField)
	halo.Shape = Enum.PartType.Ball
	halo.Position = core.Position
	halo.Transparency = 0.7
	halo.Parent = model

	local light = Instance.new("PointLight")
	light.Brightness = 3 ; light.Range = 28 ; light.Color = NEON
	light.Parent = core

	model.Parent = Workspace
	return model
end

deployBeacon.OnServerEvent:Connect(function(plr, position)
	if typeof(position) ~= "Vector3" then return end

	if state.Ore.Value < BEACON_COST then
		deployResult:FireClient(plr, false, "INSUFFICIENT ORE  —  need " .. BEACON_COST)
		return
	end

	state.Ore.Value = state.Ore.Value - BEACON_COST
	spawnPlayerBeacon(position)
	deployResult:FireClient(plr, true, "BEACON DEPLOYED  —  -" .. BEACON_COST .. " ore")
end)
