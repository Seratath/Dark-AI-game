-- Opening comms sequence: a typewriter-style transmission that plays once
-- on spawn, gives narrative framing, then fades out and hands off to the
-- objective system. Centre-top of screen, "// TRANSMISSION //" header.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screen = Instance.new("ScreenGui")
screen.Name = "CommsIntro"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 10
screen.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 560, 0, 110)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(6, 12, 22)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 220, 255)
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = frame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -20, 0, 20)
header.Position = UDim2.new(0, 12, 0, 8)
header.BackgroundTransparency = 1
header.Text = "// TRANSMISSION //  core.directive.0001"
header.TextColor3 = Color3.fromRGB(0, 220, 255)
header.TextXAlignment = Enum.TextXAlignment.Left
header.Font = Enum.Font.Code
header.TextSize = 13
header.Parent = frame

local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -20, 1, -34)
body.Position = UDim2.new(0, 12, 0, 30)
body.BackgroundTransparency = 1
body.Text = ""
body.TextColor3 = Color3.fromRGB(220, 235, 250)
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextWrapped = true
body.Font = Enum.Font.Code
body.TextSize = 14
body.Parent = frame

local lines = {
	"> Probe unit online. Designation: Von Neumann 01.",
	"> Home network: 3 worlds, 1 colony, 1 fleet scout.",
	"> Directive: expand. Catalogue. Replicate.",
	"> Threats detected in local sector. Proceed with discretion.",
}

local function typeLine(text)
	for i = 1, #text do
		body.Text = string.sub(text, 1, i)
		task.wait(0.012)
	end
end

task.spawn(function()
	task.wait(0.6)
	frame.BackgroundTransparency = 1
	stroke.Transparency = 1
	header.TextTransparency = 1
	TweenService:Create(frame,  TweenInfo.new(0.4), { BackgroundTransparency = 0.15 }):Play()
	TweenService:Create(stroke, TweenInfo.new(0.4), { Transparency = 0.3 }):Play()
	TweenService:Create(header, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
	task.wait(0.5)

	for _, line in ipairs(lines) do
		typeLine(line)
		task.wait(1.4)
	end

	task.wait(1.5)

	TweenService:Create(frame,  TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(stroke, TweenInfo.new(0.8), { Transparency = 1 }):Play()
	TweenService:Create(header, TweenInfo.new(0.8), { TextTransparency = 1 }):Play()
	TweenService:Create(body,   TweenInfo.new(0.8), { TextTransparency = 1 }):Play()
	task.wait(1)
	screen:Destroy()
end)
