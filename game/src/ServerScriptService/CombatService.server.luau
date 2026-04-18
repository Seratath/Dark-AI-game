-- Combat loop. Owns the pirate raider (AI + HP) and the probe-weapon
-- remote. Energy acts as shields: incoming raider fire drains energy;
-- at zero, the probe takes no further damage but the SHIELDS DOWN
-- warning keeps up until the player puts distance between them.
--
-- Raider FSM:
--   * Patrol — idle orbit around the Resource World.
--   * Pursue — player inside AGGRO_RANGE. Steer toward pursuit pos.
--   * Engage — inside FIRE_RANGE. Orbit pursuit pos + fire.
-- Raider destroyed → ore reward, respawn after RESPAWN_TIME.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local HOSTILE = Color3.fromRGB(255, 70, 70)
local LASER   = Color3.fromRGB(120, 230, 255)

local AGGRO_RANGE   = 260
local FIRE_RANGE    = 160
local DISENGAGE     = 340
local RAIDER_MAX_HP = 6
local RAIDER_FIRE_COOLDOWN = 1.1
local RAIDER_SHOT_SPEED = 260
local PLAYER_SHIELD_DAMAGE = 4
local RAIDER_ORE_REWARD = 8
local RESPAWN_TIME = 45

local PLAYER_WEAPON_COOLDOWN = 0.22
local PLAYER_WEAPON_RANGE    = 420
local PLAYER_WEAPON_DAMAGE   = 1

----------------------------------------------------------------------
-- Shared state
----------------------------------------------------------------------

local empireState = ReplicatedStorage:WaitForChild("EmpireState")
local energy    = empireState:WaitForChild("Energy")
local energyMax = empireState:WaitForChild("EnergyMax")
local ore       = empireState:WaitForChild("Ore")

local threat = Instance.new("Folder") ; threat.Name = "Threat" ; threat.Parent = empireState
local activeHostiles = Instance.new("IntValue")
activeHostiles.Name = "ActiveHostiles" ; activeHostiles.Parent = threat
local warningMsg = Instance.new("StringValue")
warningMsg.Name = "Warning" ; warningMsg.Parent = threat
local raiderHpVal = Instance.new("NumberValue")
raiderHpVal.Name = "RaiderHP" ; raiderHpVal.Value = RAIDER_MAX_HP ; raiderHpVal.Parent = threat
local raiderHpMaxVal = Instance.new("NumberValue")
raiderHpMaxVal.Name = "RaiderHPMax" ; raiderHpMaxVal.Value = RAIDER_MAX_HP ; raiderHpMaxVal.Parent = threat

local remotes = ReplicatedStorage:WaitForChild("EmpireRemotes")
local function ensureRemote(name)
	local r = remotes:FindFirstChild(name)
	if not r then r = Instance.new("RemoteEvent") ; r.Name = name ; r.Parent = remotes end
	return r
end
local fireWeapon  = ensureRemote("FireProbeWeapon")
local playerHitFx = ensureRemote("PlayerShieldHit")

----------------------------------------------------------------------
-- Visual helpers
----------------------------------------------------------------------

local function plainPart(size, color, material)
	local p = Instance.new("Part")
	p.Size = size ; p.Color = color ; p.Material = material or Enum.Material.Metal
	p.Anchored = true ; p.CanCollide = false ; p.CastShadow = false
	return p
end

----------------------------------------------------------------------
-- Raider build
----------------------------------------------------------------------

local raiderModel, rHull, rNose, rFinL, rFinR, rGun, rEngine

local function buildRaider()
	raiderModel = Instance.new("Model") ; raiderModel.Name = "PirateRaider"
	rHull   = plainPart(Vector3.new(3, 1.2, 6.5), Color3.fromRGB(60, 30, 30))   ; rHull.Parent   = raiderModel ; raiderModel.PrimaryPart = rHull
	rNose   = plainPart(Vector3.new(1.6, 0.9, 3), Color3.fromRGB(80, 35, 35))   ; rNose.Parent   = raiderModel
	rFinL   = plainPart(Vector3.new(0.3, 2.2, 3), Color3.fromRGB(70, 30, 30))   ; rFinL.Parent   = raiderModel
	rFinR   = plainPart(Vector3.new(0.3, 2.2, 3), Color3.fromRGB(70, 30, 30))   ; rFinR.Parent   = raiderModel
	rGun    = plainPart(Vector3.new(0.4, 0.4, 4), Color3.fromRGB(40, 40, 40))   ; rGun.Parent    = raiderModel
	rEngine = plainPart(Vector3.new(1, 1, 1), HOSTILE, Enum.Material.Neon)
	rEngine.Shape = Enum.PartType.Ball ; rEngine.Parent = raiderModel
	local light = Instance.new("PointLight") ; light.Brightness = 2 ; light.Range = 16 ; light.Color = HOSTILE
	light.Parent = rEngine
	raiderModel.Parent = Workspace
end

local function placeRaiderRig(cf)
	rHull.CFrame   = cf
	rNose.CFrame   = cf * CFrame.new(0, 0.1, -3.8)
	rFinL.CFrame   = cf * CFrame.new(-1.3, 0.6, 1.5)
	rFinR.CFrame   = cf * CFrame.new(1.3, 0.6, 1.5)
	rGun.CFrame    = cf * CFrame.new(0, -0.7, -2)
	rEngine.CFrame = cf * CFrame.new(0, 0, 3.6)
end

----------------------------------------------------------------------
-- FX
----------------------------------------------------------------------

local function tracer(fromPos, toPos, color, thickness, lifetime)
	local dir = toPos - fromPos
	local dist = dir.Magnitude
	if dist < 0.01 then return end
	local beam = Instance.new("Part")
	beam.Anchored = true ; beam.CanCollide = false ; beam.CastShadow = false
	beam.Material = Enum.Material.Neon
	beam.Color = color
	beam.Size = Vector3.new(thickness or 0.2, thickness or 0.2, dist)
	beam.CFrame = CFrame.lookAt(fromPos + dir * 0.5, toPos)
	beam.Parent = Workspace
	TweenService:Create(beam, TweenInfo.new(lifetime or 0.25), { Transparency = 1 }):Play()
	Debris:AddItem(beam, (lifetime or 0.25) + 0.1)
end

local function explosion(pos, color, size)
	local b = Instance.new("Part")
	b.Shape = Enum.PartType.Ball
	b.Size = Vector3.new(2, 2, 2)
	b.Position = pos
	b.Anchored = true ; b.CanCollide = false ; b.CastShadow = false
	b.Material = Enum.Material.Neon
	b.Color = color
	b.Parent = Workspace
	local t = TweenService:Create(b, TweenInfo.new(0.8), { Size = Vector3.new(size, size, size), Transparency = 1 })
	t:Play()
	Debris:AddItem(b, 1)
end

----------------------------------------------------------------------
-- Player helpers
----------------------------------------------------------------------

local function playerRootFor(plr)
	local char = plr.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function nearestPlayerRoot(fromPos)
	local best, bestDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		local root = playerRootFor(plr)
		if root then
			local d = (root.Position - fromPos).Magnitude
			if d < bestDist then best, bestDist = root, d end
		end
	end
	return best, bestDist
end

----------------------------------------------------------------------
-- Raider AI
----------------------------------------------------------------------

local resourceWorld = Workspace:WaitForChild("Planet_Resource", 10)
local patrolCenter = (resourceWorld and resourceWorld.Position) or Vector3.new(-900, 0, -1100)
local patrolRadius = (resourceWorld and resourceWorld.Size.X / 2 + 28) or 90

local state = "Patrol"
local patrolPhase = 0
local fireTimer = 0
local alive = true
local lastWarn = 0

local function setWarning(msg)
	warningMsg.Value = msg
	lastWarn = os.clock()
end

local function patrolPos(dt)
	patrolPhase += 0.22 * dt
	local a = patrolPhase
	local offset = Vector3.new(math.cos(a) * patrolRadius, math.sin(a * 0.7) * 6, math.sin(a) * patrolRadius)
	local pos = patrolCenter + offset
	local tangent = Vector3.new(-math.sin(a), 0, math.cos(a)).Unit
	return pos, tangent
end

local function raiderFire(fromPos, targetRoot)
	local toPos = targetRoot.Position
	local dir = (toPos - fromPos).Unit
	local endPos = fromPos + dir * ((toPos - fromPos).Magnitude)

	tracer(fromPos, endPos, HOSTILE, 0.25, 0.35)

	-- Shield hit
	if energy.Value > 0 then
		energy.Value = math.max(0, energy.Value - PLAYER_SHIELD_DAMAGE)
		setWarning("UNDER FIRE  —  shields " .. math.floor(energy.Value) .. "/" .. math.floor(energyMax.Value))
	else
		setWarning("SHIELDS DOWN  —  evade")
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		playerHitFx:FireClient(plr, energy.Value, energyMax.Value)
	end
end

local function raiderDeath(lastPos)
	alive = false
	activeHostiles.Value = 0
	setWarning("HOSTILE DESTROYED  —  +" .. RAIDER_ORE_REWARD .. " ore")
	ore.Value = ore.Value + RAIDER_ORE_REWARD
	explosion(lastPos, HOSTILE, 18)
	if raiderModel then raiderModel:Destroy() ; raiderModel = nil end
	task.delay(RESPAWN_TIME, function()
		buildRaider()
		raiderHpVal.Value = RAIDER_MAX_HP
		state = "Patrol"
		alive = true
		activeHostiles.Value = 0
	end)
end

buildRaider()

RunService.Heartbeat:Connect(function(dt)
	if not alive or not raiderModel or not raiderModel.Parent then return end

	local myPos = rHull.Position
	local target, targetDist = nearestPlayerRoot(myPos)

	-- State transitions
	if state == "Patrol" then
		if target and targetDist < AGGRO_RANGE then
			state = "Pursue"
			setWarning("HOSTILE CONTACT  —  raider approaching")
			activeHostiles.Value = 1
		end
	elseif state == "Pursue" then
		if not target or targetDist > DISENGAGE then
			state = "Patrol"
			activeHostiles.Value = 0
			warningMsg.Value = ""
		elseif targetDist < FIRE_RANGE then
			state = "Engage"
		end
	elseif state == "Engage" then
		if not target or targetDist > FIRE_RANGE * 1.3 then
			state = "Pursue"
		end
	end

	-- Motion
	local pos, heading
	if state == "Patrol" or not target then
		pos, heading = patrolPos(dt)
	elseif state == "Pursue" then
		local toTarget = (target.Position - myPos)
		heading = toTarget.Unit
		pos = myPos + heading * math.min(toTarget.Magnitude - FIRE_RANGE * 0.8, 70) * dt
	else  -- Engage: orbit target at fire range
		patrolPhase += 0.9 * dt
		local offset = Vector3.new(math.cos(patrolPhase) * FIRE_RANGE, math.sin(patrolPhase * 0.7) * 10, math.sin(patrolPhase) * FIRE_RANGE)
		pos = target.Position + offset
		heading = (target.Position - pos).Unit
	end

	local cf = CFrame.lookAt(pos, pos + heading)
	placeRaiderRig(cf)

	-- Fire
	if state == "Engage" and target then
		fireTimer -= dt
		if fireTimer <= 0 then
			fireTimer = RAIDER_FIRE_COOLDOWN
			raiderFire(rGun.Position, target)
		end
	else
		fireTimer = math.max(fireTimer - dt, 0)
	end

	-- Clear stale warning
	if warningMsg.Value ~= "" and os.clock() - lastWarn > 3 and state == "Patrol" then
		warningMsg.Value = ""
	end
end)

----------------------------------------------------------------------
-- Player weapon
----------------------------------------------------------------------

local playerCooldown = {}

fireWeapon.OnServerEvent:Connect(function(plr, origin, direction)
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then return end
	local now = os.clock()
	if (playerCooldown[plr] or 0) > now then return end
	playerCooldown[plr] = now + PLAYER_WEAPON_COOLDOWN

	local dir = direction.Unit
	if dir.Magnitude < 0.5 then return end

	local endPos = origin + dir * PLAYER_WEAPON_RANGE
	local hit = false

	if alive and raiderModel and rHull then
		-- Ray vs raider sphere (approx)
		local toRaider = rHull.Position - origin
		local alongRay = toRaider:Dot(dir)
		if alongRay > 0 and alongRay < PLAYER_WEAPON_RANGE then
			local closest = origin + dir * alongRay
			local miss = (closest - rHull.Position).Magnitude
			if miss < 4.5 then
				endPos = rHull.Position
				hit = true
				raiderHpVal.Value = math.max(0, raiderHpVal.Value - PLAYER_WEAPON_DAMAGE)
				explosion(rHull.Position, LASER, 6)
				if raiderHpVal.Value <= 0 then
					raiderDeath(rHull.Position)
				end
			end
		end
	end

	tracer(origin, endPos, LASER, 0.18, hit and 0.35 or 0.22)
end)

Players.PlayerRemoving:Connect(function(plr) playerCooldown[plr] = nil end)
