-- Hides the default character and turns HumanoidRootPart into a glowing drone probe.
-- Controls: WASD = horizontal, Space = up, LeftShift = down, mouse = look.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Disable the default Roblox movement controller
humanoid.PlatformStand = true

-- Hide all character parts except the root
for _, desc in ipairs(character:GetDescendants()) do
	if desc:IsA("BasePart") and desc ~= rootPart then
		desc.Transparency = 1
		desc.CanCollide = false
	elseif desc:IsA("Decal") then
		desc.Transparency = 1
	end
end

-- Style the root as the drone probe
rootPart.Transparency = 0
rootPart.Material = Enum.Material.Neon
rootPart.Color = Color3.fromRGB(0, 200, 255)
rootPart.CanCollide = false

local glow = Instance.new("PointLight")
glow.Brightness = 2
glow.Range = 20
glow.Color = Color3.fromRGB(0, 200, 255)
glow.Parent = rootPart

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
