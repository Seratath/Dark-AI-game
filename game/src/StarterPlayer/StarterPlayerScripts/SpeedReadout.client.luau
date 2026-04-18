-- Bottom-centre airspeed readout: current velocity in studs/s plus a
-- "BOOST" tag when the probe is boosting. Reads values published by
-- the DroneController via Vector3Value/BoolValue on the player.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screen = Instance.new("ScreenGui")
screen.Name = "SpeedReadout"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 44)
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.new(0.5, 0, 1, -16)
frame.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 1
stroke.Transparency = 0.4
stroke.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 14)
label.Position = UDim2.new(0, 0, 0, 4)
label.BackgroundTransparency = 1
label.Text = "AIRSPEED"
label.TextColor3 = Color3.fromRGB(140, 180, 210)
label.Font = Enum.Font.Gotham
label.TextSize = 10
label.Parent = frame

local value = Instance.new("TextLabel")
value.Size = UDim2.new(1, 0, 0, 22)
value.Position = UDim2.new(0, 0, 0, 18)
value.BackgroundTransparency = 1
value.Text = "0  st/s"
value.TextColor3 = Color3.fromRGB(0, 220, 255)
value.Font = Enum.Font.GothamBold
value.TextSize = 18
value.Parent = frame

-- Boost chip — overlay on right side when active
local boost = Instance.new("TextLabel")
boost.Size = UDim2.new(0, 60, 0, 16)
boost.AnchorPoint = Vector2.new(1, 0)
boost.Position = UDim2.new(1, -4, 0, 4)
boost.BackgroundColor3 = Color3.fromRGB(255, 180, 80)
boost.BackgroundTransparency = 0.1
boost.BorderSizePixel = 0
boost.Text = "BOOST"
boost.TextColor3 = Color3.fromRGB(20, 10, 0)
boost.Font = Enum.Font.GothamBold
boost.TextSize = 11
boost.Visible = false
boost.Parent = frame

local boostCorner = Instance.new("UICorner")
boostCorner.CornerRadius = UDim.new(0, 4)
boostCorner.Parent = boost

RunService.Heartbeat:Connect(function()
	local vv = player:FindFirstChild("ProbeVelocity")
	local bv = player:FindFirstChild("ProbeBoost")
	local speed = vv and vv.Value.Magnitude or 0
	value.Text = string.format("%d  st/s", math.floor(speed))
	boost.Visible = bv and bv.Value or false
end)
