-- Von Neumann probe — elongated teardrop hull with swept wings and engine exhaust.
-- Controls: WASD = horizontal, Space = up, LeftShift = down, mouse = look.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

humanoid.PlatformStand = true

for _, desc in ipairs(character:GetDescendants()) do
	if desc:IsA("BasePart") then
		desc.Transparency = 1
		desc.CanCollide = false
	elseif desc:IsA("Decal") then
		desc.Transparency = 1
	end
end

task.wait()

-- Helpers
local function part(size, color, material)
	local p = Instance.new("Part")
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.Metal
	p.CanCollide = false
	p.Anchored = false
	return p
end

local function ball(diameter, color, material)
	local p = part(Vector3.new(diameter, diameter, diameter), color, material)
	p.Shape = Enum.PartType.Ball
	return p
end

local function attach(p, localOffset)
	p.CFrame = rootPart.CFrame * CFrame.new(localOffset)
	p.Parent = character
	local w = Instance.new("WeldConstraint")
	w.Part0 = rootPart
	w.Part1 = p
	w.Parent = rootPart
end

local DARK  = Color3.fromRGB(28,  36,  50)
local MID   = Color3.fromRGB(48,  58,  76)
local LIGHT = Color3.fromRGB(72,  85, 108)
local NEON  = Color3.fromRGB(0,  200, 255)

-- ── Hull sections stacked nose(-Z) to engine(+Z) ──────────────────────────

-- Nose tip
local noseTip = ball(0.8, NEON, Enum.Material.Neon)
attach(noseTip, Vector3.new(0, 0, -13))

-- Forward taper
local fwd1 = part(Vector3.new(1.2, 1,   4), DARK)  ; attach(fwd1,  Vector3.new(0,  0, -11))
local fwd2 = part(Vector3.new(2,   1.4, 4), MID)   ; attach(fwd2,  Vector3.new(0,  0, -7.5))
local fwd3 = part(Vector3.new(3,   1.8, 4), MID)   ; attach(fwd3,  Vector3.new(0,  0, -4))

-- Mid hull (widest)
local mid  = part(Vector3.new(4,   2.4, 6), DARK)  ; attach(mid,   Vector3.new(0,  0,  0))

-- Rear taper
local rr1  = part(Vector3.new(3.5, 2.2, 4), MID)  ; attach(rr1,   Vector3.new(0,  0,  4.5))
local rr2  = part(Vector3.new(2.5, 1.6, 4), DARK)  ; attach(rr2,   Vector3.new(0,  0,  8))
local rr3  = part(Vector3.new(1.5, 1,   3), MID)   ; attach(rr3,   Vector3.new(0,  0, 10.5))

-- Spine ridge along top
local spine = part(Vector3.new(0.6, 0.5, 24), LIGHT) ; attach(spine, Vector3.new(0, 1.4,  -1))

-- ── Swept wings at mid section ────────────────────────────────────────────
-- Angled back: wider at rear than front to give swept look
for _, s in ipairs({-1, 1}) do
	local wing = part(Vector3.new(9, 0.22, 4), MID)
	attach(wing, Vector3.new(s * 6.5, -0.5, 1.5))

	-- Thin neon edge stripe along leading edge
	local stripe = part(Vector3.new(9, 0.22, 0.25), NEON, Enum.Material.Neon)
	attach(stripe, Vector3.new(s * 6.5, -0.5, -0.65))

	-- Wingtip node
	local tip = ball(0.7, NEON, Enum.Material.Neon)
	attach(tip, Vector3.new(s * 11.2, -0.5, 1))
	local tl = Instance.new("PointLight")
	tl.Brightness = 0.8 ; tl.Range = 10 ; tl.Color = NEON ; tl.Parent = tip
end

-- ── Engine exhaust (rear) ──────────────────────────────────────────────────
local engineCore = ball(1.8, NEON, Enum.Material.Neon)
attach(engineCore, Vector3.new(0, 0, 12.5))
local el = Instance.new("PointLight")
el.Brightness = 6 ; el.Range = 40 ; el.Color = NEON ; el.Parent = engineCore

-- Outer exhaust bloom (larger, slightly transparent)
local bloom = ball(3.2, Color3.fromRGB(120, 220, 255), Enum.Material.Neon)
bloom.Transparency = 0.55
attach(bloom, Vector3.new(0, 0, 13.8))

-- Trailing exhaust streak
local a0 = Instance.new("Attachment")
a0.Position = Vector3.new(0, 0.6, 0)
a0.Parent = engineCore

local a1 = Instance.new("Attachment")
a1.Position = Vector3.new(0, -0.6, 0)
a1.Parent = engineCore

local trail = Instance.new("Trail")
trail.Attachment0 = a0
trail.Attachment1 = a1
trail.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 235, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0,  120, 220)),
})
trail.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.3),
	NumberSequenceKeypoint.new(1, 1),
})
trail.Lifetime = 0.8
trail.MinLength = 0.05
trail.WidthScale = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(1, 0.1),
})
trail.LightEmission = 1
trail.FaceCamera = true
trail.Parent = engineCore

-- ── Physics movers ────────────────────────────────────────────────────────
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bodyVelocity.Velocity = Vector3.zero
bodyVelocity.Parent = rootPart

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bodyGyro.D = 140
bodyGyro.P = 1400
bodyGyro.CFrame = rootPart.CFrame
bodyGyro.Parent = rootPart

local SPEED = 80
local VERTICAL_SPEED = 50
local BOOST_MULT = 3.2

-- Publish current velocity for other UI scripts (SpeedReadout) to read.
local velocityValue = Instance.new("Vector3Value")
velocityValue.Name = "ProbeVelocity"
velocityValue.Parent = player

local boostValue = Instance.new("BoolValue")
boostValue.Name = "ProbeBoost"
boostValue.Parent = player

RunService.Heartbeat:Connect(function()
	local camCF = camera.CFrame
	local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
	local right   = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

	local moveDir = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += forward end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= forward end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += right end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= right end

	local vertical = 0
	if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then vertical =  1 end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vertical = -1 end

	local boosting = UserInputService:IsKeyDown(Enum.KeyCode.Q)
	local mult = boosting and BOOST_MULT or 1

	local velocity = Vector3.zero
	if moveDir.Magnitude > 0 then
		velocity = moveDir.Unit * SPEED * mult
	end
	local finalVel = velocity + Vector3.new(0, vertical * VERTICAL_SPEED * mult, 0)
	bodyVelocity.Velocity = finalVel
	velocityValue.Value = finalVel
	boostValue.Value = boosting

	-- Stretch the engine glow when boosting for visible feel
	engineCore.Size = boosting and Vector3.new(2.2, 2.2, 2.2) or Vector3.new(1.8, 1.8, 1.8)
	bloom.Size      = boosting and Vector3.new(4.2, 4.2, 4.2) or Vector3.new(3.2, 3.2, 3.2)

	if moveDir.Magnitude > 0 then
		bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + forward)
	end
end)
