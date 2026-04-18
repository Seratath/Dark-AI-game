-- Top-left resource overlay. Static placeholder values for now — communicates
-- the 4X strategy framing (Compute / Ore / Energy / Population / Fleet) before
-- any real economy exists.

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screen = Instance.new("ScreenGui")
screen.Name = "EmpireHUD"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "ResourcePanel"
panel.Size = UDim2.new(0, 230, 0, 168)
panel.Position = UDim2.new(1, -246, 0, 16)
panel.AnchorPoint = Vector2.new(0, 0)
panel.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
panel.BackgroundTransparency = 0.25
panel.BorderSizePixel = 0
panel.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 1
stroke.Transparency = 0.4
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 22)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.Text = "EMPIRE STATUS"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = panel

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -16, 0, 1)
divider.Position = UDim2.new(0, 8, 0, 30)
divider.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
divider.BackgroundTransparency = 0.6
divider.BorderSizePixel = 0
divider.Parent = panel

local rows = {
	{ label = "Compute",    value = "1.24 TF",  color = Color3.fromRGB(150, 220, 255) },
	{ label = "Ore",        value = "0",         color = Color3.fromRGB(220, 180, 120) },
	{ label = "Energy",     value = "12 / 50",   color = Color3.fromRGB(255, 220, 100) },
	{ label = "Population", value = "0",         color = Color3.fromRGB(180, 255, 180) },
	{ label = "Fleet",      value = "1 Probe",   color = Color3.fromRGB(180, 200, 255) },
}

for i, row in ipairs(rows) do
	local y = 38 + (i - 1) * 24

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, -8, 0, 20)
	lbl.Position = UDim2.new(0, 12, 0, y)
	lbl.BackgroundTransparency = 1
	lbl.Text = row.label
	lbl.TextColor3 = Color3.fromRGB(180, 200, 220)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 13
	lbl.Parent = panel

	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.5, -12, 0, 20)
	val.Position = UDim2.new(0.5, 0, 0, y)
	val.BackgroundTransparency = 1
	val.Text = row.value
	val.TextColor3 = row.color
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Font = Enum.Font.GothamMedium
	val.TextSize = 13
	val.Parent = panel
end

-- Bottom-right hint panel: controls
local hint = Instance.new("TextLabel")
hint.Name = "ControlsHint"
hint.Size = UDim2.new(0, 340, 0, 22)
hint.Position = UDim2.new(0, 16, 1, -34)
hint.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
hint.BackgroundTransparency = 0.35
hint.BorderSizePixel = 0
hint.Text = "  WASD  move    SPACE up    SHIFT down    Q  boost  "
hint.TextColor3 = Color3.fromRGB(170, 200, 230)
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = screen

local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 6)
hintCorner.Parent = hint
