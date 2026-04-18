-- Press B to deploy a relay beacon at the probe's current position.
-- Costs 5 ore, server-validated. Shows a small flash with the outcome.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("EmpireRemotes", 10)
local deployBeacon = remotes:WaitForChild("DeployBeacon")
local deployMiner  = remotes:WaitForChild("DeployMiner")
local deployScout  = remotes:WaitForChild("DeployScout")
local deployRelay  = remotes:WaitForChild("DeployRelay")
local deployResult = remotes:WaitForChild("DeployResult")

local screen = Instance.new("ScreenGui")
screen.Name = "DeployUI"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

local flash = Instance.new("TextLabel")
flash.Size = UDim2.new(0, 360, 0, 28)
flash.AnchorPoint = Vector2.new(0.5, 1)
flash.Position = UDim2.new(0.5, 0, 0.72, 0)
flash.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
flash.BackgroundTransparency = 0.2
flash.BorderSizePixel = 0
flash.TextColor3 = Color3.fromRGB(0, 220, 255)
flash.Font = Enum.Font.GothamBold
flash.TextSize = 14
flash.Text = ""
flash.Visible = false
flash.Parent = screen

local corner = Instance.new("UICorner") ; corner.CornerRadius = UDim.new(0, 6) ; corner.Parent = flash
local stroke = Instance.new("UIStroke") ; stroke.Color = Color3.fromRGB(0, 220, 255) ; stroke.Thickness = 1 ; stroke.Transparency = 0.3
stroke.Parent = flash

local function showFlash(text, color)
	flash.Text = text
	flash.TextColor3 = color
	stroke.Color = color
	flash.Visible = true
	flash.BackgroundTransparency = 0.2
	TweenService:Create(flash, TweenInfo.new(1.8), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(stroke, TweenInfo.new(1.8), { Transparency = 1 }):Play()
	task.delay(2, function()
		flash.Visible = false
		stroke.Transparency = 0.3
	end)
end

deployResult.OnClientEvent:Connect(function(ok, msg)
	showFlash(msg, ok and Color3.fromRGB(120, 230, 160) or Color3.fromRGB(255, 120, 120))
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if input.KeyCode == Enum.KeyCode.B then
		deployBeacon:FireServer(root.Position)
	elseif input.KeyCode == Enum.KeyCode.M then
		deployMiner:FireServer(root.Position)
	elseif input.KeyCode == Enum.KeyCode.G then
		deployScout:FireServer(root.Position)
	elseif input.KeyCode == Enum.KeyCode.R then
		deployRelay:FireServer(root.Position)
	end
end)

-- Patch the controls hint to include B
task.spawn(function()
	local hudGui = playerGui:WaitForChild("EmpireHUD", 6)
	if not hudGui then return end
	local hint = hudGui:FindFirstChild("ControlsHint")
	if hint and hint:IsA("TextLabel") then
		hint.Size = UDim2.new(0, 720, 0, 22)
		hint.Text = "  WASD  SPACE/SHIFT  Q boost  LMB fire  F scan  C claim  B beacon  M miner  G scout  R relay  "
	end
end)
