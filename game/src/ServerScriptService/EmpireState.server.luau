-- Authoritative empire state. Everything starts at zero except Fleet = 1
-- (the probe itself). Resources only accrue while the player owns
-- productive assets — claimed worlds, deployed beacons/miners. Also owns
-- all server-side remote handlers (claim, deploy beacon, deploy miner).
--
-- Shared bus:
--   * Values live under ReplicatedStorage/EmpireState
--   * Client → server actions go through ReplicatedStorage/EmpireRemotes
--   * Claim flags: EmpireState/Claimed/<contactName>.Value (BoolValue)
--   * Deploy counters: EmpireState/Deployed/{Beacons, Miners}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

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

local compute    = num("Compute",    0)
local ore        = num("Ore",        0)
local energy     = num("Energy",     0)
local energyMax  = num("EnergyMax",  0)
local population = num("Population", 0)
local fleet      = num("Fleet",      1)   -- the probe

local claimed = Instance.new("Folder") ; claimed.Name = "Claimed"  ; claimed.Parent = state
local deployed = Instance.new("Folder") ; deployed.Name = "Deployed" ; deployed.Parent = state

local function claimFlag(name)
	local v = claimed:FindFirstChild(name)
	if not v then
		v = Instance.new("BoolValue") ; v.Name = name ; v.Value = false ; v.Parent = claimed
	end
	return v
end

-- Pre-create so clients can subscribe without a race
for _, n in ipairs({"Planet_Homeworld", "Planet_Resource", "Planet_Barren", "Mining_Asteroid"}) do
	claimFlag(n)
end

local function intCounter(name)
	local v = Instance.new("IntValue") ; v.Name = name ; v.Value = 0 ; v.Parent = deployed
	return v
end
local beaconsCount = intCounter("Beacons")
local minersCount  = intCounter("Miners")
local scoutsCount  = intCounter("Scouts")
local relaysCount  = intCounter("Relays")

----------------------------------------------------------------------
-- Remotes
----------------------------------------------------------------------

local remotes = Instance.new("Folder") ; remotes.Name = "EmpireRemotes" ; remotes.Parent = ReplicatedStorage

local function remote(name)
	local r = Instance.new("RemoteEvent") ; r.Name = name ; r.Parent = remotes ; return r
end

local scanCompleted = remote("ScanCompleted")
local claimWorld    = remote("ClaimWorld")
local claimResult   = remote("ClaimResult")
local deployBeacon  = remote("DeployBeacon")
local deployMiner   = remote("DeployMiner")
local deployScout   = remote("DeployScout")
local deployRelay   = remote("DeployRelay")
local deployResult  = remote("DeployResult")

scanCompleted.OnServerEvent:Connect(function() end)   -- no-op; scans give information, not economy

----------------------------------------------------------------------
-- Claim mechanic
----------------------------------------------------------------------

local CLAIMABLE = {
	Planet_Homeworld = { label = "Homeworld",       range = 300 },
	Planet_Resource  = { label = "Resource World",  range = 280 },
	Planet_Barren    = { label = "Barren World",    range = 260 },
	Mining_Asteroid  = { label = "Mining Asteroid", range = 120 },
}

local function applyClaimGrants(name)
	if name == "Planet_Homeworld" then
		-- Bootstrap starter kit so the player has what they need to build.
		energyMax.Value = energyMax.Value + 50
		energy.Value    = math.min(energyMax.Value, energy.Value + 20)
		ore.Value       = ore.Value + 12
		fleet.Value     = fleet.Value + 2   -- patrol scouts become part of fleet
	elseif name == "Planet_Resource" then
		energyMax.Value = energyMax.Value + 15
		ore.Value       = ore.Value + 5
	elseif name == "Mining_Asteroid" then
		ore.Value       = ore.Value + 3
	end
end

claimWorld.OnServerEvent:Connect(function(plr, targetName, position)
	local info = CLAIMABLE[targetName]
	if not info then
		claimResult:FireClient(plr, false, "Target not claimable") ; return
	end

	local anchor = Workspace:FindFirstChild(targetName)
	if anchor and anchor:IsA("Model") and anchor.PrimaryPart then anchor = anchor.PrimaryPart end
	if anchor and typeof(position) == "Vector3" then
		local d = (anchor.Position - position).Magnitude
		if d > info.range then
			claimResult:FireClient(plr, false, "TOO FAR  —  move closer to claim") ; return
		end
	end

	local flag = claimFlag(targetName)
	if flag.Value then
		claimResult:FireClient(plr, false, info.label .. " already claimed") ; return
	end
	flag.Value = true
	applyClaimGrants(targetName)
	claimResult:FireClient(plr, true, info.label .. " claimed")
end)

----------------------------------------------------------------------
-- Deployment (beacon + miner)
----------------------------------------------------------------------

local NEON  = Color3.fromRGB(0, 220, 255)
local METAL = Color3.fromRGB(95, 105, 125)
local DARK  = Color3.fromRGB(40, 48, 64)
local OREHUE = Color3.fromRGB(255, 220, 120)

local BEACON_COST = 5
local MINER_COST  = 10
local SCOUT_COST  = 6
local RELAY_COST  = 8

local function plainPart(size, color, material)
	local p = Instance.new("Part")
	p.Size = size ; p.Color = color ; p.Material = material or Enum.Material.Metal
	p.Anchored = true ; p.CanCollide = false ; p.CastShadow = false
	return p
end

local deployCounter = 0

local function spawnBeacon(position)
	deployCounter += 1
	local model = Instance.new("Model") ; model.Name = "PlayerBeacon_" .. deployCounter

	local pylon = plainPart(Vector3.new(1, 6, 1), METAL) ; pylon.Position = position ; pylon.Parent = model ; model.PrimaryPart = pylon
	local core = plainPart(Vector3.new(2, 2, 2), NEON, Enum.Material.Neon) ; core.Shape = Enum.PartType.Ball
	core.Position = position + Vector3.new(0, 4, 0) ; core.Parent = model
	local halo = plainPart(Vector3.new(4, 4, 4), NEON, Enum.Material.ForceField) ; halo.Shape = Enum.PartType.Ball
	halo.Position = core.Position ; halo.Transparency = 0.7 ; halo.Parent = model
	local light = Instance.new("PointLight") ; light.Brightness = 3 ; light.Range = 28 ; light.Color = NEON ; light.Parent = core

	model.Parent = Workspace
end

deployBeacon.OnServerEvent:Connect(function(plr, position)
	if typeof(position) ~= "Vector3" then return end
	if ore.Value < BEACON_COST then
		deployResult:FireClient(plr, false, "INSUFFICIENT ORE  —  need " .. BEACON_COST) ; return
	end
	ore.Value = ore.Value - BEACON_COST
	spawnBeacon(position)
	beaconsCount.Value = beaconsCount.Value + 1
	deployResult:FireClient(plr, true, "BEACON DEPLOYED  —  -" .. BEACON_COST .. " ore")
end)

local MINER_RANGE = 350

local function findClaimedOreSource(pos)
	-- Must be near a CLAIMED ore source. Resource World or Mining_Asteroid.
	for _, name in ipairs({"Planet_Resource", "Mining_Asteroid"}) do
		if claimFlag(name).Value then
			local obj = Workspace:FindFirstChild(name)
			if obj and (obj.Position - pos).Magnitude < MINER_RANGE then
				return obj
			end
		end
	end
	return nil
end

local function spawnMiner(sourcePart)
	deployCounter += 1
	local model = Instance.new("Model") ; model.Name = "PlayerMiner_" .. deployCounter

	local hull   = plainPart(Vector3.new(1.6, 0.8, 2.8), DARK) ; hull.Parent = model ; model.PrimaryPart = hull
	local cap    = plainPart(Vector3.new(1, 0.5, 1.2), METAL)  ; cap.Parent = model
	local engine = plainPart(Vector3.new(0.6, 0.6, 0.6), OREHUE, Enum.Material.Neon) ; engine.Shape = Enum.PartType.Ball ; engine.Parent = model
	local cargo  = plainPart(Vector3.new(0.8, 0.8, 0.8), OREHUE, Enum.Material.Neon) ; cargo.Shape = Enum.PartType.Ball ; cargo.Transparency = 1 ; cargo.Parent = model

	model.Parent = Workspace

	-- Dock at homeworld if claimed; else use the source itself as dock (circular flight).
	local homeworld = Workspace:FindFirstChild("Planet_Homeworld")
	local dockPos = (homeworld and claimFlag("Planet_Homeworld").Value)
		and (homeworld.Position + Vector3.new(0, homeworld.Size.X / 2 + 12, 0))
		or (sourcePart.Position + Vector3.new(40, 20, 40))

	local CYCLE = 14
	local phase = math.random() * CYCLE
	local awarded = false

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not hull.Parent then conn:Disconnect() return end
		phase = (phase + dt) % CYCLE
		local t = phase / CYCLE

		local pos, heading, carrying = Vector3.zero, Vector3.new(1, 0, 0), false
		local src = sourcePart.Position + Vector3.new(0, 6, 0)
		if t < 0.4 then
			local u = t / 0.4
			pos = dockPos:Lerp(src, u) + Vector3.new(0, math.sin(u * math.pi) * 6, 0)
			heading = (src - dockPos).Unit
		elseif t < 0.5 then
			pos = src + Vector3.new(0, math.sin(t * 40) * 0.3, 0)
			heading = Vector3.new(1, 0, 0)
		elseif t < 0.9 then
			local u = (t - 0.5) / 0.4
			pos = src:Lerp(dockPos, u) + Vector3.new(0, math.sin(u * math.pi) * 6, 0)
			heading = (dockPos - src).Unit
			carrying = true
		else
			pos = dockPos + Vector3.new(0, math.sin(t * 40) * 0.2, 0)
			heading = Vector3.new(-1, 0, 0)
			carrying = t < 0.95
		end
		local cf = CFrame.lookAt(pos, pos + heading)
		hull.CFrame   = cf
		cap.CFrame    = cf * CFrame.new(0, 0.55, 0.2)
		engine.CFrame = cf * CFrame.new(0, 0, 1.7)
		cargo.CFrame  = cf * CFrame.new(0, -0.7, 0)
		cargo.Transparency = carrying and 0 or 1

		if t >= 0.9 and not awarded then
			awarded = true
			ore.Value = ore.Value + 2
		elseif t < 0.5 then
			awarded = false
		end
	end)
end

deployMiner.OnServerEvent:Connect(function(plr, position)
	if typeof(position) ~= "Vector3" then return end
	local src = findClaimedOreSource(position)
	if not src then
		deployResult:FireClient(plr, false, "NO CLAIMED ORE SOURCE IN RANGE") ; return
	end
	if ore.Value < MINER_COST then
		deployResult:FireClient(plr, false, "INSUFFICIENT ORE  —  need " .. MINER_COST) ; return
	end
	ore.Value = ore.Value - MINER_COST
	spawnMiner(src)
	minersCount.Value = minersCount.Value + 1
	fleet.Value = fleet.Value + 1
	deployResult:FireClient(plr, true, "MINER DEPLOYED  —  -" .. MINER_COST .. " ore")
end)

----------------------------------------------------------------------
-- Scout drone — orbits its deploy point, extends scanner detection.
-- Parented to a PlayerScouts folder so ScannerSystem can enumerate.
----------------------------------------------------------------------

local scoutsFolder = Workspace:FindFirstChild("PlayerScouts")
if not scoutsFolder then
	scoutsFolder = Instance.new("Folder") ; scoutsFolder.Name = "PlayerScouts" ; scoutsFolder.Parent = Workspace
end

local function spawnScout(position)
	deployCounter += 1
	local model = Instance.new("Model") ; model.Name = "PlayerScout_" .. deployCounter

	local core = plainPart(Vector3.new(1, 1, 1), NEON, Enum.Material.Neon)
	core.Shape = Enum.PartType.Ball ; core.Position = position ; core.Parent = model
	model.PrimaryPart = core
	local halo = plainPart(Vector3.new(2.2, 2.2, 2.2), NEON, Enum.Material.ForceField)
	halo.Shape = Enum.PartType.Ball ; halo.Position = position ; halo.Transparency = 0.6 ; halo.Parent = model
	local light = Instance.new("PointLight") ; light.Brightness = 2 ; light.Range = 24 ; light.Color = NEON
	light.Parent = core

	model.Parent = scoutsFolder

	local phase = math.random() * math.pi * 2
	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not core.Parent then conn:Disconnect() return end
		phase += dt * 0.4
		local offset = Vector3.new(math.cos(phase) * 14, math.sin(phase * 1.3) * 4, math.sin(phase) * 14)
		core.Position = position + offset
		halo.Position = core.Position
	end)
end

deployScout.OnServerEvent:Connect(function(plr, position)
	if typeof(position) ~= "Vector3" then return end
	if ore.Value < SCOUT_COST then
		deployResult:FireClient(plr, false, "INSUFFICIENT ORE  —  need " .. SCOUT_COST) ; return
	end
	ore.Value = ore.Value - SCOUT_COST
	spawnScout(position)
	scoutsCount.Value = scoutsCount.Value + 1
	fleet.Value = fleet.Value + 1
	deployResult:FireClient(plr, true, "SCOUT DEPLOYED  —  -" .. SCOUT_COST .. " ore")
end)

----------------------------------------------------------------------
-- Compute relay — tall pylon, grants compute and boosts nearby beacons.
----------------------------------------------------------------------

local RELAY_BOOST_RANGE = 180

local relaysFolder = Workspace:FindFirstChild("PlayerRelays")
if not relaysFolder then
	relaysFolder = Instance.new("Folder") ; relaysFolder.Name = "PlayerRelays" ; relaysFolder.Parent = Workspace
end

local function spawnRelay(position)
	deployCounter += 1
	local model = Instance.new("Model") ; model.Name = "PlayerRelay_" .. deployCounter

	local tower = plainPart(Vector3.new(1.2, 10, 1.2), METAL) ; tower.Position = position ; tower.Parent = model ; model.PrimaryPart = tower
	local ringTop = plainPart(Vector3.new(0.6, 4, 4), NEON, Enum.Material.Neon) ; ringTop.Shape = Enum.PartType.Cylinder
	ringTop.CFrame = CFrame.new(position + Vector3.new(0, 6, 0)) * CFrame.Angles(0, 0, math.rad(90))
	ringTop.Parent = model
	local glow = plainPart(Vector3.new(6, 6, 6), NEON, Enum.Material.ForceField) ; glow.Shape = Enum.PartType.Ball
	glow.Position = position + Vector3.new(0, 6, 0) ; glow.Transparency = 0.7 ; glow.Parent = model
	local light = Instance.new("PointLight") ; light.Brightness = 4 ; light.Range = 40 ; light.Color = NEON
	light.Parent = ringTop

	model.Parent = relaysFolder
end

deployRelay.OnServerEvent:Connect(function(plr, position)
	if typeof(position) ~= "Vector3" then return end
	if ore.Value < RELAY_COST then
		deployResult:FireClient(plr, false, "INSUFFICIENT ORE  —  need " .. RELAY_COST) ; return
	end
	ore.Value = ore.Value - RELAY_COST
	spawnRelay(position)
	relaysCount.Value = relaysCount.Value + 1
	deployResult:FireClient(plr, true, "RELAY ONLINE  —  -" .. RELAY_COST .. " ore")
end)

----------------------------------------------------------------------
-- Production tick — only runs for owned assets
----------------------------------------------------------------------

task.spawn(function()
	while true do
		task.wait(1)
		local computeGain = 0
		if claimFlag("Planet_Homeworld").Value then computeGain += 0.05 end
		if claimFlag("Planet_Resource").Value  then computeGain += 0.02 end
		if claimFlag("Planet_Barren").Value    then computeGain += 0.01 end
		if claimFlag("Mining_Asteroid").Value  then computeGain += 0.005 end
		computeGain += beaconsCount.Value * 0.004
		computeGain += minersCount.Value  * 0.002
		computeGain += relaysCount.Value  * 0.015
		-- Extra: each relay boosts beacons within RELAY_BOOST_RANGE.
		if relaysCount.Value > 0 and beaconsCount.Value > 0 then
			local boosted = 0
			for _, relay in ipairs(relaysFolder:GetChildren()) do
				local rp = relay.PrimaryPart and relay.PrimaryPart.Position
				if rp then
					for _, node in ipairs(Workspace:GetChildren()) do
						if node.Name:sub(1, 13) == "PlayerBeacon_" and node:IsA("Model") and node.PrimaryPart then
							if (node.PrimaryPart.Position - rp).Magnitude < RELAY_BOOST_RANGE then
								boosted += 1
							end
						end
					end
				end
			end
			computeGain += boosted * 0.003
		end
		if computeGain > 0 then
			compute.Value = compute.Value + computeGain
		end

		if claimFlag("Planet_Homeworld").Value then
			population.Value = population.Value + math.random(5, 14)
		end

		if energyMax.Value > 0 and energy.Value < energyMax.Value then
			energy.Value = math.min(energyMax.Value, energy.Value + 2)
		end
	end
end)
