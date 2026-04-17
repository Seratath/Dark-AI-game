-- Replaces the default character with a flying probe drone.
-- Controls: WASD = horizontal, Space = up, LeftShift = down, mouse = look.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Kill default movement and animations
humanoid.PlatformStand = true

-- Hide all default character parts
for _, desc in ipairs(character:GetDescendants()) do
	if desc:IsA("BasePart") and desc ~= rootPart then
		desc.Transparency = 1
		desc.CanCollide = false
	elseif desc:IsA("Decal") then
		desc.Transparency = 1
	end
end

-- Drone core — sphere
rootPart.Transparency = 0
rootPart.Material = Enum.Material.Neon
rootPart.Color = Color3.fromRGB(0, 200, 255)
rootPart.CanCollide = false

local mesh = Instance.new("SpecialMesh")
mesh.MeshType = Enum.MeshType.Sphere
mesh.Scale = Vector3.new(1.2, 1.2, 1.2)
mesh.Parent = rootPart

local coreGlow = Instance.new("PointLight")
coreGlow.Brightness = 2
coreGlow.Range = 25
coreGlow.Color = Color3.fromRGB(0, 200, 255)
coreGlow.Parent = rootPart

-- Build 4 thruster arms after physics settles
task.wait()

local thrusterOffsets = {
	Vector3.new( 2.5, 0,  2.5),
	Vector3.new(-2.5, 0,  2.5),
	Vector3.new( 2.5, 0, -2.5),
	Vector3.new(-2.5, 0, -2.5),
}

for _, offset in ipairs(thrusterOffsets) do
	local tipPos = rootPart.Position + offset
	local armCenter = rootPart.Position + offset * 0.5

	-- Strut arm
	local arm = Instance.new("Part")
	arm.Size = Vector3.new(0.22, 0.22, offset.Magnitude * 0.82)
	arm.Material = Enum.Material.Metal
	arm.Color = Color3.fromRGB(35, 45, 60)
	arm.CanCollide = false
	arm.Anchored = false
	arm.CFrame = CFrame.lookAt(armCenter, tipPos)
	arm.Parent = character

	local armWeld = Instance.new("WeldConstraint")
	armWeld.Part0 = rootPart
	armWeld.Part1 = arm
	armWeld.Parent = rootPart

	-- Thruster node
	local tip = Instance.new("Part")
	tip.Shape = Enum.PartType.Ball
	tip.Size = Vector3.new(0.65, 0.65, 0.65)
	tip.Material = Enum.Material.Neon
	tip.Color = Color3.fromRGB(0, 200, 255)
	tip.CanCollide = false
	tip.Anchored = false
	tip.CFrame = CFrame.new(tipPos)
	tip.Parent = character

	local tipWeld = Instance.new("WeldConstraint")
	tipWeld.Part0 = rootPart
	tipWeld.Part1 = tip
	tipWeld.Parent = rootPart

	local tipLight = Instance.new("PointLight")
	tipLight.Brightness = 0.8
	tipLight.Range = 8
	tipLight.Color = Color3.fromRGB(0, 200, 255)
	tipLight.Parent = tip
end

-- Physics movers
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
bodyVelocity.Velocity = Vector3.zero
bodyVelocity.Parent = rootPart

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
bodyGyro.D = 100
bodyGyro.P = 1000
bodyGyro.CFrame = rootPart.CFrame
bodyGyro.Parent = rootPart

local SPEED = 80
local VERTICAL_SPEED = 50

RunService.Heartbeat:Connect(function()
	local camCF = camera.CFrame
	local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
	local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

	local moveDir = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += forward end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= forward end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += right end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= right end

	local vertical = 0
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = 1 end
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
