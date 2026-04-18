-- Simple objective system: a "Current Directive" banner under the resource
-- HUD, and an on-screen arrow that points toward the active objective when
-- it's off-camera, or sits over the target when it's in view. Objectives
-- advance automatically as the probe reaches each contact.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

----------------------------------------------------------------------
-- Objective data — chained directive list
----------------------------------------------------------------------

local directives = {
	{ target = "Planet_Homeworld", text = "Survey the Homeworld",            arrive = 260 },
	{ target = "Planet_Barren",    text = "Scan the Barren World",           arrive = 240 },
	{ target = "Mining_Asteroid",  text = "Inspect mining operations",       arrive = 120 },
	{ target = "JumpGate_Ring",    text = "Investigate the Jump Gate",       arrive = 180 },
	{ target = "Wreck_Hull",       text = "Respond to derelict distress",    arrive = 150 },
	{ target = "PirateRaider",     text = "Identify hostile contact",        arrive = 200 },
}

local currentIndex = 1

----------------------------------------------------------------------
-- UI: banner + arrow
----------------------------------------------------------------------

local screen = Instance.new("ScreenGui")
screen.Name = "Objectives"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

-- Banner under HUD (top-right area)
local banner = Instance.new("Frame")
banner.Size = UDim2.new(0, 280, 0, 50)
banner.Position = UDim2.new(1, -296, 0, 240)
banner.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
banner.BackgroundTransparency = 0.25
banner.BorderSizePixel = 0
banner.Parent = screen

local bCorner = Instance.new("UICorner")
bCorner.CornerRadius = UDim.new(0, 6)
bCorner.Parent = banner

local bStroke = Instance.new("UIStroke")
bStroke.Color = Color3.fromRGB(0, 220, 180)
bStroke.Thickness = 1
bStroke.Transparency = 0.3
bStroke.Parent = banner

local bBar = Instance.new("Frame")
bBar.Size = UDim2.new(0, 3, 1, 0)
bBar.BackgroundColor3 = Color3.fromRGB(0, 220, 180)
bBar.BorderSizePixel = 0
bBar.Parent = banner

local bTitle = Instance.new("TextLabel")
bTitle.Size = UDim2.new(1, -20, 0, 18)
bTitle.Position = UDim2.new(0, 12, 0, 6)
bTitle.BackgroundTransparency = 1
bTitle.Text = "CURRENT DIRECTIVE"
bTitle.TextColor3 = Color3.fromRGB(0, 220, 180)
bTitle.TextXAlignment = Enum.TextXAlignment.Left
bTitle.Font = Enum.Font.GothamBold
bTitle.TextSize = 12
bTitle.Parent = banner

local bBody = Instance.new("TextLabel")
bBody.Size = UDim2.new(1, -20, 0, 20)
bBody.Position = UDim2.new(0, 12, 0, 24)
bBody.BackgroundTransparency = 1
bBody.Text = directives[1].text
bBody.TextColor3 = Color3.fromRGB(220, 235, 250)
bBody.TextXAlignment = Enum.TextXAlignment.Left
bBody.Font = Enum.Font.Gotham
bBody.TextSize = 14
bBody.Parent = banner

-- Arrow / marker
local arrow = Instance.new("Frame")
arrow.Size = UDim2.new(0, 36, 0, 36)
arrow.AnchorPoint = Vector2.new(0.5, 0.5)
arrow.BackgroundTransparency = 1
arrow.Parent = screen

local arrowImg = Instance.new("TextLabel")
arrowImg.Size = UDim2.new(1, 0, 1, 0)
arrowImg.BackgroundTransparency = 1
arrowImg.Text = "▲"
arrowImg.TextColor3 = Color3.fromRGB(0, 220, 180)
arrowImg.Font = Enum.Font.GothamBold
arrowImg.TextSize = 32
arrowImg.Parent = arrow

local distLbl = Instance.new("TextLabel")
distLbl.Size = UDim2.new(0, 80, 0, 16)
distLbl.Position = UDim2.new(0.5, -40, 1, 2)
distLbl.BackgroundTransparency = 1
distLbl.Text = ""
distLbl.TextColor3 = Color3.fromRGB(180, 230, 220)
distLbl.Font = Enum.Font.GothamMedium
distLbl.TextSize = 12
distLbl.Parent = arrow

----------------------------------------------------------------------
-- Resolve current target anchor
----------------------------------------------------------------------

local function resolveTarget(name)
	local obj = Workspace:FindFirstChild(name)
	if not obj then return nil end
	if obj:IsA("Model") and obj.PrimaryPart then return obj.PrimaryPart end
	return obj
end

task.wait(2)

----------------------------------------------------------------------
-- Main loop
----------------------------------------------------------------------

RunService.RenderStepped:Connect(function()
	local dir = directives[currentIndex]
	if not dir then
		banner.Visible = false
		arrow.Visible = false
		return
	end

	local target = resolveTarget(dir.target)
	if not target then
		arrow.Visible = false
		return
	end

	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local dist = (target.Position - root.Position).Magnitude

	-- Auto-advance when close
	if dist < dir.arrive then
		currentIndex += 1
		local next = directives[currentIndex]
		if next then
			bBody.Text = next.text
		else
			bBody.Text = "All directives complete."
			arrow.Visible = false
		end
		return
	end

	distLbl.Text = string.format("%d studs", math.floor(dist))

	-- Project target into screen space
	local vp = camera.ViewportSize
	local screenPos, onScreen = camera:WorldToViewportPoint(target.Position)

	if onScreen and screenPos.Z > 0 then
		arrow.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - 40)
		arrowImg.Rotation = 0
		arrow.Visible = true
	else
		-- Off-screen: clamp arrow to screen edge pointing at target
		local cx, cy = vp.X / 2, vp.Y / 2
		local dx = screenPos.X - cx
		local dy = screenPos.Y - cy
		if screenPos.Z < 0 then
			dx = -dx
			dy = -dy
		end
		local angle = math.atan2(dy, dx)
		local pad = 60
		local maxX = cx - pad
		local maxY = cy - pad
		local scale = math.min(maxX / math.max(math.abs(dx), 0.001), maxY / math.max(math.abs(dy), 0.001))
		local ex = cx + dx * scale
		local ey = cy + dy * scale
		arrow.Position = UDim2.new(0, ex, 0, ey)
		arrowImg.Rotation = math.deg(angle) + 90   -- ▲ points up by default
		arrow.Visible = true
	end
end)
