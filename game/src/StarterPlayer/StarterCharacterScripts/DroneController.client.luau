-- Replaces the default character with a flying probe scout ship.
-- Controls: WASD = horizontal, Space = up, LeftShift = down, mouse = look.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Kill default movement
humanoid.PlatformStand = true

-- Hide all default character parts; rootPart becomes the invisible physics anchor
for _, desc in ipairs(character:GetDescendants()) do
	if desc:IsA("BasePart") then
		desc.Transparency = 1
		desc.CanCollide = false
	elseif desc:IsA("Decal") then
		desc.Transparency = 1
	end
end

-- Wait for character physics to settle before building the ship
task.wait()

-- Helper: create a part welded to rootPart at a local offset
local function attach(part, localPos, localCFrame)
	part.CanCollide = false
	part.Anchored = false
	part.CFrame = rootPart.CFrame * (localCFrame or CFrame.new(localPos))
	part.Parent = character
	local w = Instance.new("WeldConstraint")
	w.Part0 = rootPart
	w.Part1 = part
	w.Parent = rootPart
end

local DARK_HULL  = Color3.fromRGB(30,  38,  52)
local MID_HULL   = Color3.fromRGB(45,  55,  72)
local NEON_BLUE  = Color3.fromRGB(0,  200, 255)

-- Main hull — elongated body, nose faces -Z (forward)
local hull = Instance.new("Part")
hull.Size = Vector3.new(2.8, 1, 7)
hull.Material = Enum.Material.Metal
hull.Color = DARK_HULL
attach(hull, Vector3.new(0, 0, 0))

-- Raised cockpit ridge along the top front half
local cockpit = Instance.new("Part")
cockpit.Size = Vector3.new(1.6, 0.6, 3.5)
cockpit.Material = Enum.Material.SmoothPlastic
cockpit.Color = MID_HULL
attach(cockpit, Vector3.new(0, 0.7, -1.2))

-- Left solar wing — swept slightly back
local wingL = Instance.new("Part")
wingL.Size = Vector3.new(5.5, 0.18, 2.4)
wingL.Material = Enum.Material.Metal
wingL.Color = MID_HULL
attach(wingL, Vector3.new(-4.6, -0.1, 0.8))

-- Right solar wing
local wingR = Instance.new("Part")
wingR.Size = Vector3.new(5.5, 0.18, 2.4)
wingR.Material = Enum.Material.Metal
wingR.Color = MID_HULL
attach(wingR, Vector3.new(4.6, -0.1, 0.8))

-- Wing accent stripe left
local accentL = Instance.new("Part")
accentL.Size = Vector3.new(5.5, 0.18, 0.3)
accentL.Material = Enum.Material.Neon
accentL.Color = NEON_BLUE
attach(accentL, Vector3.new(-4.6, -0.1, -0.2))

-- Wing accent stripe right
local accentR = Instance.new("Part")
accentR.Size = Vector3.new(5.5, 0.18, 0.3)
accentR.Material = Enum.Material.Neon
accentR.Color = NEON_BLUE
attach(accentR, Vector3.new(4.6, -0.1, -0.2))

-- Scanner dome at nose
local scanner = Instance.new("Part")
scanner.Shape = Enum.PartType.Ball
scanner.Size = Vector3.new(1.1, 1.1, 1.1)
scanner.Material = Enum.Material.Neon
scanner.Color = NEON_BLUE
attach(scanner, Vector3.new(0, 0.3, -3.9))

local scanLight = Instance.new("PointLight")
scanLight.Brightness = 1.5
scanLight.Range = 18
scanLight.Color = NEON_BLUE
scanLight.Parent = scanner

-- Engine nozzle at rear
local engine = Instance.new("Part")
engine.Shape = Enum.PartType.Ball
engine.Size = Vector3.new(1.2, 1.2, 1.2)
engine.Material = Enum.Material.Neon
engine.Color = NEON_BLUE
attach(engine, Vector3.new(0, 0, 3.7))

local engineLight = Instance.new("PointLight")
engineLight.Brightness = 4
engineLight.Range = 28
engineLight.Color = NEON_BLUE
engineLight.Parent = engine

-- Two small secondary engine pods flanking rear
for _, side in ipairs({-1, 1}) do
	local pod = Instance.new("Part")
	pod.Shape = Enum.PartType.Ball
	pod.Size = Vector3.new(0.7, 0.7, 0.7)
	pod.Material = Enum.Material.Neon
	pod.Color = NEON_BLUE
	attach(pod, Vector3.new(side * 1.4, -0.1, 3.4))
end

-- Physics movers
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
bodyVelocity.Velocity = Vector3.zero
bodyVelocity.Parent = rootPart

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
bodyGyro.D = 120
bodyGyro.P = 1200
bodyGyro.CFrame = rootPart.CFrame
bodyGyro.Parent = rootPart

local SPEED = 80
local VERTICAL_SPEED = 50

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

	local velocity = Vector3.zero
	if moveDir.Magnitude > 0 then
		velocity = moveDir.Unit * SPEED
	end
	bodyVelocity.Velocity = velocity + Vector3.new(0, vertical * VERTICAL_SPEED, 0)

	if moveDir.Magnitude > 0 then
		bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + forward)
	end
end)
