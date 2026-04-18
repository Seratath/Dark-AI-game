-- Top-down minimap in the bottom-right: planets, the jump gate, raider, and
-- the probe itself projected onto a circular radar. World X/Z maps to
-- minimap X/Y (camera-facing north is -Z).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MAP_SIZE   = 200            -- pixels
local MAP_RANGE  = 1600           -- world studs represented edge-to-edge

local screen = Instance.new("ScreenGui")
screen.Name = "Minimap"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

local root = Instance.new("Frame")
root.Size = UDim2.new(0, MAP_SIZE, 0, MAP_SIZE)
root.Position = UDim2.new(1, -MAP_SIZE - 16, 1, -MAP_SIZE - 48)
root.BackgroundColor3 = Color3.fromRGB(8, 14, 24)
root.BackgroundTransparency = 0.2
root.BorderSizePixel = 0
root.Parent = screen

local circle = Instance.new("UICorner")
circle.CornerRadius = UDim.new(1, 0)
circle.Parent = root

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = root

-- Crosshair lines
local function line(thickness, size, pos)
	local l = Instance.new("Frame")
	l.Size = size
	l.Position = pos
	l.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
	l.BackgroundTransparency = 0.75
	l.BorderSizePixel = 0
	l.Parent = root
	return l
end
line(1, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0.5, 0))
line(1, UDim2.new(0, 1, 1, 0), UDim2.new(0.5, 0, 0, 0))

-- Label
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 16)
label.Position = UDim2.new(0, 0, 0, 6)
label.BackgroundTransparency = 1
label.Text = "LOCAL SECTOR"
label.TextColor3 = Color3.fromRGB(0, 220, 255)
label.Font = Enum.Font.GothamBold
label.TextSize = 11
label.Parent = root

----------------------------------------------------------------------
-- Tracked contacts
----------------------------------------------------------------------

local contacts = {
	{ name = "Planet_Homeworld", color = Color3.fromRGB(100, 200, 255), size = 8 },
	{ name = "Planet_Barren",    color = Color3.fromRGB(220, 170, 100), size = 7 },
	{ name = "Planet_Resource",  color = Color3.fromRGB(255, 220, 120), size = 7 },
	{ name = "JumpGate_Ring",    color = Color3.fromRGB(0,   220, 255), size = 6 },
	{ name = "Wreck_Hull",       color = Color3.fromRGB(255, 120, 120), size = 4 },
	{ name = "PirateRaider",     color = Color3.fromRGB(255,  80,  80), size = 5 },
	{ name = "Star_Sol",         color = Color3.fromRGB(255, 230, 100), size = 10 },
}

-- Probe dot (always centred)
local probeDot = Instance.new("Frame")
probeDot.Size = UDim2.new(0, 8, 0, 8)
probeDot.Position = UDim2.new(0.5, -4, 0.5, -4)
probeDot.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
probeDot.BorderSizePixel = 0
probeDot.ZIndex = 5
probeDot.Parent = root
local probeCorner = Instance.new("UICorner")
probeCorner.CornerRadius = UDim.new(1, 0)
probeCorner.Parent = probeDot

task.wait(2)

local entries = {}
for _, c in ipairs(contacts) do
	local obj = Workspace:FindFirstChild(c.name)
	if obj then
		local anchor = obj
		if obj:IsA("Model") and obj.PrimaryPart then anchor = obj.PrimaryPart end

		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, c.size, 0, c.size)
		dot.BackgroundColor3 = c.color
		dot.BorderSizePixel = 0
		dot.ZIndex = 3
		dot.Visible = false
		dot.Parent = root

		local dc = Instance.new("UICorner")
		dc.CornerRadius = UDim.new(1, 0)
		dc.Parent = dot

		table.insert(entries, { anchor = anchor, dot = dot, size = c.size })
	end
end

local half = MAP_SIZE / 2

RunService.Heartbeat:Connect(function()
	local character = player.Character
	if not character then return end
	local root3d = character:FindFirstChild("HumanoidRootPart")
	if not root3d then return end
	local p = root3d.Position

	for _, e in ipairs(entries) do
		if e.anchor.Parent then
			local dx = e.anchor.Position.X - p.X
			local dz = e.anchor.Position.Z - p.Z
			local sx = (dx / MAP_RANGE) * MAP_SIZE
			local sy = (dz / MAP_RANGE) * MAP_SIZE

			-- Clamp to edge if outside range, so distant contacts still show as a hint
			local mag = math.sqrt(sx * sx + sy * sy)
			local maxR = half - e.size / 2 - 2
			if mag > maxR then
				local k = maxR / mag
				sx = sx * k
				sy = sy * k
				e.dot.BackgroundTransparency = 0.5
			else
				e.dot.BackgroundTransparency = 0
			end

			e.dot.Position = UDim2.new(0.5, sx - e.size / 2, 0.5, sy - e.size / 2)
			e.dot.Visible = true
		end
	end
end)
