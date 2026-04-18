-- Authoritative empire state. Creates ReplicatedStorage/EmpireState with the
-- resource counters every other script reads from, runs the passive ticks
-- (energy regen, population growth, compute drift), and exposes remotes
-- for client-driven events (scan completion, deployments).
--
-- Shared bus so scripts stay decoupled:
--   * Server scripts write directly to the NumberValues (MiningOps, etc.)
--   * Client scripts bind to `.Changed` to drive the HUD
--   * Client → server actions go through ReplicatedStorage/EmpireRemotes

local ReplicatedStorage = game:GetService("ReplicatedStorage")

----------------------------------------------------------------------
-- State folder
----------------------------------------------------------------------

local state = Instance.new("Folder")
state.Name = "EmpireState"
state.Parent = ReplicatedStorage

local function num(name, initial)
	local v = Instance.new("NumberValue")
	v.Name = name
	v.Value = initial
	v.Parent = state
	return v
end

local compute     = num("Compute",     1.24)    -- TF
local ore         = num("Ore",         0)
local energy      = num("Energy",      12)
local energyMax   = num("EnergyMax",   50)
local population  = num("Population",  12400)
local fleet       = num("Fleet",       3)       -- probe + 2 patrol scouts

----------------------------------------------------------------------
-- Passive ticks
----------------------------------------------------------------------

-- Colony generator trickles energy
task.spawn(function()
	while true do
		task.wait(2)
		if energy.Value < energyMax.Value then
			energy.Value = math.min(energyMax.Value, energy.Value + 1)
		end
	end
end)

-- Colony population growth
task.spawn(function()
	while true do
		task.wait(3)
		population.Value = population.Value + math.random(4, 14)
	end
end)

-- Tiny compute drift (background processing) so HUD feels alive even when idle
task.spawn(function()
	while true do
		task.wait(5)
		compute.Value = compute.Value + 0.01
	end
end)

----------------------------------------------------------------------
-- Remotes
----------------------------------------------------------------------

local remotes = Instance.new("Folder")
remotes.Name = "EmpireRemotes"
remotes.Parent = ReplicatedStorage

local scanCompleted = Instance.new("RemoteEvent")
scanCompleted.Name = "ScanCompleted"
scanCompleted.Parent = remotes

local deployBeacon = Instance.new("RemoteEvent")
deployBeacon.Name = "DeployBeacon"
deployBeacon.Parent = remotes

local deployResult = Instance.new("RemoteEvent")
deployResult.Name = "DeployResult"
deployResult.Parent = remotes

-- Award compute per scan. Client sends the contact name for future
-- value-tiering (bigger targets = more compute).
local COMPUTE_PER_SCAN = {
	Planet_Homeworld = 0.15,
	Planet_Barren    = 0.08,
	Planet_Resource  = 0.12,
	JumpGate_Ring    = 0.20,
	Wreck_Hull       = 0.25,
	PirateRaider     = 0.10,
	Mining_Asteroid  = 0.05,
	Star_Sol         = 0.30,
}

scanCompleted.OnServerEvent:Connect(function(_, contactName)
	local gain = COMPUTE_PER_SCAN[contactName] or 0.05
	compute.Value = compute.Value + gain
end)
