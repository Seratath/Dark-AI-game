-- Periodic ship arrivals through the jump gate: a warp-in flash at the
-- ring, a small allied transport flies out of it and heads toward the
-- homeworld, despawning when it arrives. Makes the gate feel functional
-- rather than decorative.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local FACTION = Color3.fromRGB(0, 200, 230)
local DARK    = Color3.fromRGB(35, 42, 58)
local METAL   = Color3.fromRGB(95, 105, 125)

local gate = Workspace:WaitForChild("JumpGate_Ring", 5)
local homeworld = Workspace:WaitForChild("Planet_Homeworld", 5)
if not gate or not homeworld then return end

local ARRIVAL_INTERVAL = 18   -- seconds between arrivals
local TRAVEL_TIME      = 14   -- seconds to reach homeworld
local WARP_FLASH_TIME  = 0.4

----------------------------------------------------------------------
-- Ship factory
----------------------------------------------------------------------

local function part(size, color, material)
	local p = Instance.new("Part")
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.Anchored = true ; p.CanCollide = false ; p.CastShadow = false
	return p
end

local function makeTransport()
	local model = Instance.new("Model")
	model.Name = "GateTransport"

	local hull = part(Vector3.new(3, 1.4, 7), DARK)
	hull.Parent = model
	model.PrimaryPart = hull

	local cargo1 = part(Vector3.new(2.5, 1.8, 2.2), METAL)
	cargo1.Parent = model
	local cargo2 = part(Vector3.new(2.5, 1.8, 2.2), METAL)
	cargo2.Parent = model

	local engine = part(Vector3.new(1, 1, 1), FACTION, Enum.Material.Neon)
	engine.Shape = Enum.PartType.Ball
	engine.Parent = model
	local el = Instance.new("PointLight")
	el.Brightness = 3 ; el.Range = 20 ; el.Color = FACTION
	el.Parent = engine

	local a0 = Instance.new("Attachment") ; a0.Position = Vector3.new(0,  0.5, 0) ; a0.Parent = engine
	local a1 = Instance.new("Attachment") ; a1.Position = Vector3.new(0, -0.5, 0) ; a1.Parent = engine

	local trail = Instance.new("Trail")
	trail.Attachment0 = a0 ; trail.Attachment1 = a1
	trail.Color = ColorSequence.new(FACTION)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Lifetime = 0.6 ; trail.LightEmission = 1 ; trail.FaceCamera = true
	trail.Parent = engine

	model.Parent = Workspace
	return model, hull, cargo1, cargo2, engine
end

----------------------------------------------------------------------
-- Warp-in flash at the gate
----------------------------------------------------------------------

local function warpFlash()
	local flash = Instance.new("Part")
	flash.Name = "WarpFlash"
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.new(6, 6, 6)
	flash.Position = gate.Position
	flash.Material = Enum.Material.Neon
	flash.Color = FACTION
	flash.Anchored = true ; flash.CanCollide = false ; flash.CastShadow = false
	flash.Parent = Workspace

	local pl = Instance.new("PointLight")
	pl.Brightness = 8 ; pl.Range = 80 ; pl.Color = FACTION
	pl.Parent = flash

	local grow = TweenService:Create(flash, TweenInfo.new(WARP_FLASH_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(34, 34, 34),
		Transparency = 1,
	})
	grow:Play()
	grow.Completed:Connect(function() flash:Destroy() end)
end

----------------------------------------------------------------------
-- One arrival cycle
----------------------------------------------------------------------

local function runArrival()
	warpFlash()
	task.wait(WARP_FLASH_TIME * 0.5)

	local model, hull, cargo1, cargo2, engine = makeTransport()
	local start = gate.Position
	local destination = homeworld.Position + Vector3.new(-homeworld.Size.X, 10, 0)
	local direction = (destination - start).Unit

	local t = 0
	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		t += dt
		local u = math.min(t / TRAVEL_TIME, 1)
		local pos = start + (destination - start) * u
		local cf = CFrame.lookAt(pos, pos + direction)
		hull.CFrame    = cf
		cargo1.CFrame  = cf * CFrame.new(0, 1.2, -1)
		cargo2.CFrame  = cf * CFrame.new(0, 1.2,  1.5)
		engine.CFrame  = cf * CFrame.new(0, 0, 4)

		if u >= 1 then
			conn:Disconnect()
			model:Destroy()
		end
	end)
end

task.spawn(function()
	task.wait(6)   -- first arrival a bit after scene loads
	while true do
		runArrival()
		task.wait(ARRIVAL_INTERVAL)
	end
end)
