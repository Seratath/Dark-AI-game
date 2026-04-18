-- Guided onboarding state machine. Loud on purpose — a bright pulsing
-- banner, a 3D world-space waypoint above the tracked target, a large
-- off-screen arrow with distance readout, and a toggleable Directives
-- panel (J or button) where the player can pick which step to track
-- (defaults to whichever step is currently required to progress).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NEON  = Color3.fromRGB(0, 220, 255)
local AMBER = Color3.fromRGB(255, 200, 100)
local GREEN = Color3.fromRGB(120, 230, 160)
local DIM   = Color3.fromRGB(120, 140, 170)

local empireState = ReplicatedStorage:WaitForChild("EmpireState", 10)
local claimedFolder  = empireState and empireState:WaitForChild("Claimed", 5)
local deployedFolder = empireState and empireState:WaitForChild("Deployed", 5)
local threatFolder   = empireState and empireState:WaitForChild("Threat", 10)
local raidersKilledVal = threatFolder and threatFolder:WaitForChild("RaidersKilled", 5)
local localScans = player:WaitForChild("LocalScans", 10)

----------------------------------------------------------------------
-- Step helpers
----------------------------------------------------------------------

local function worldPart(name)
	local o = Workspace:FindFirstChild(name)
	if o and o:IsA("Model") and o.PrimaryPart then return o.PrimaryPart end
	return o
end

local function distanceTo(name)
	local p = worldPart(name)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not p or not root then return math.huge end
	return (p.Position - root.Position).Magnitude
end

local function isClaimed(name)
	local f = claimedFolder and claimedFolder:FindFirstChild(name)
	return f and f.Value or false
end

local function isScanned(name)
	local f = localScans:FindFirstChild(name)
	return f and f.Value or false
end

local function minerCount()
	local f = deployedFolder and deployedFolder:FindFirstChild("Miners")
	return f and f.Value or 0
end

local function raidersKilled()
	return raidersKilledVal and raidersKilledVal.Value or 0
end

----------------------------------------------------------------------
-- Step table
----------------------------------------------------------------------

local steps = {
	{
		title  = "TRAVEL TO HOMEWORLD",
		body   = "Fly to the blue planet. Use WASD, SPACE and SHIFT. Hold Q to boost.",
		target = "Planet_Homeworld",
		short  = "HOMEWORLD",
		done   = function() return distanceTo("Planet_Homeworld") < 320 end,
		flash  = "Approach confirmed.",
	},
	{
		title  = "SCAN HOMEWORLD",
		body   = "Hold [F] while near the Homeworld until the scan completes.",
		target = "Planet_Homeworld",
		short  = "SCAN",
		done   = function() return isScanned("Planet_Homeworld") end,
		flash  = "Homeworld classified.",
	},
	{
		title  = "CLAIM HOMEWORLD",
		body   = "Press [C] to claim the Homeworld. This grants your starter kit.",
		target = "Planet_Homeworld",
		short  = "CLAIM",
		done   = function() return isClaimed("Planet_Homeworld") end,
		flash  = "Homeworld is yours. +Energy +Ore +Fleet.",
	},
	{
		title  = "BRIEFING",
		body   = "Habitable worlds grow Compute & Population. Ore worlds and asteroids feed Miners. Beacons/Relays expand your network. Spend Ore to deploy.",
		target = nil,
		short  = nil,
		auto   = 7.0,
		flash  = "Continue.",
	},
	{
		title  = "TRAVEL TO RESOURCE WORLD",
		body   = "Head to the amber-yellow planet — your future ore source.",
		target = "Planet_Resource",
		short  = "RESOURCE WORLD",
		done   = function() return distanceTo("Planet_Resource") < 320 end,
		flash  = "Approach confirmed.",
	},
	{
		title  = "SCAN RESOURCE WORLD",
		body   = "Hold [F] near the Resource World to classify it.",
		target = "Planet_Resource",
		short  = "SCAN",
		done   = function() return isScanned("Planet_Resource") end,
		flash  = "Ore-rich world classified.",
	},
	{
		title  = "CLAIM RESOURCE WORLD",
		body   = "Press [C] to claim the Resource World.",
		target = "Planet_Resource",
		short  = "CLAIM",
		done   = function() return isClaimed("Planet_Resource") end,
		flash  = "Resource World claimed.",
	},
	{
		title  = "APPROACH MINING ASTEROID",
		body   = "Find the asteroid orbiting the Resource World. Get close.",
		target = "Mining_Asteroid",
		short  = "ASTEROID",
		done   = function() return distanceTo("Mining_Asteroid") < 200 end,
		flash  = "In range of ore source.",
	},
	{
		title  = "DEPLOY MINING DRONE",
		body   = "Press [M] near the asteroid to deploy a Mining Drone. Costs 10 Ore.",
		target = "Mining_Asteroid",
		short  = "DEPLOY",
		done   = function() return minerCount() >= 1 end,
		flash  = "Drone operational. Ore is now flowing.",
	},
	{
		title  = "INVESTIGATE DERELICT WRECK",
		body   = "A faint distress pulse is coming from a broken hull elsewhere in the sector. Find it.",
		target = "Wreck_Hull",
		short  = "WRECK",
		done   = function() return distanceTo("Wreck_Hull") < 300 end,
		flash  = "Signal source located.",
	},
	{
		title  = "DESTROY THE RAIDER",
		body   = "The wreck was bait. LMB fires your laser. Your shields (Energy) regenerate. Finish it.",
		target = "PirateRaider",
		short  = "HOSTILE",
		done   = function() return raidersKilled() >= 1 end,
		flash  = "Raider down. So much for a quiet sector.",
	},
	{
		title  = "ONBOARDING COMPLETE",
		body   = "The sector is yours to expand into. Defend it, scale it, map it.",
		target = nil,
		short  = nil,
		auto   = 5.0,
		final  = true,
	},
}

----------------------------------------------------------------------
-- ScreenGui
----------------------------------------------------------------------

local screen = Instance.new("ScreenGui")
screen.Name = "Tutorial"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 20
screen.Parent = playerGui

----------------------------------------------------------------------
-- Big banner — centre-top, loud and pulsing
----------------------------------------------------------------------

local banner = Instance.new("Frame")
banner.Size = UDim2.new(0, 620, 0, 118)
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 200)
banner.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
banner.BackgroundTransparency = 0.05
banner.BorderSizePixel = 0
banner.Visible = false
banner.Parent = screen

local bCorner = Instance.new("UICorner") ; bCorner.CornerRadius = UDim.new(0, 10) ; bCorner.Parent = banner
local bStroke = Instance.new("UIStroke") ; bStroke.Color = AMBER ; bStroke.Thickness = 2 ; bStroke.Transparency = 0.1 ; bStroke.Parent = banner

-- Accent stripe on the left
local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 6, 1, -16)
accent.Position = UDim2.new(0, 8, 0, 8)
accent.BackgroundColor3 = AMBER
accent.BorderSizePixel = 0
accent.Parent = banner
local accentCorner = Instance.new("UICorner") ; accentCorner.CornerRadius = UDim.new(0, 3) ; accentCorner.Parent = accent

-- Step tag ("DIRECTIVE 2 / 10")
local stepTag = Instance.new("TextLabel")
stepTag.Size = UDim2.new(1, -40, 0, 18)
stepTag.Position = UDim2.new(0, 24, 0, 10)
stepTag.BackgroundTransparency = 1
stepTag.TextXAlignment = Enum.TextXAlignment.Left
stepTag.Text = "DIRECTIVE"
stepTag.TextColor3 = AMBER
stepTag.Font = Enum.Font.GothamBold
stepTag.TextSize = 13
stepTag.Parent = banner

-- Title ("TRAVEL TO HOMEWORLD")
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -40, 0, 30)
titleLbl.Position = UDim2.new(0, 24, 0, 30)
titleLbl.BackgroundTransparency = 1
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Text = ""
titleLbl.TextColor3 = Color3.fromRGB(240, 250, 255)
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 24
titleLbl.Parent = banner

-- Body / instructions
local bodyLbl = Instance.new("TextLabel")
bodyLbl.Size = UDim2.new(1, -40, 0, 50)
bodyLbl.Position = UDim2.new(0, 24, 0, 62)
bodyLbl.BackgroundTransparency = 1
bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
bodyLbl.TextYAlignment = Enum.TextYAlignment.Top
bodyLbl.TextWrapped = true
bodyLbl.Text = ""
bodyLbl.TextColor3 = Color3.fromRGB(205, 220, 235)
bodyLbl.Font = Enum.Font.GothamMedium
bodyLbl.TextSize = 15
bodyLbl.Parent = banner

-- Pulsing glow stroke underlay
local pulseStroke = Instance.new("UIStroke")
pulseStroke.Color = AMBER
pulseStroke.Thickness = 6
pulseStroke.Transparency = 0.85
pulseStroke.Parent = banner

task.spawn(function()
	while banner.Parent do
		if banner.Visible then
			TweenService:Create(pulseStroke, TweenInfo.new(1.0, Enum.EasingStyle.Sine), { Thickness = 10, Transparency = 0.95 }):Play()
			task.wait(1.0)
			TweenService:Create(pulseStroke, TweenInfo.new(1.0, Enum.EasingStyle.Sine), { Thickness = 6,  Transparency = 0.8 }):Play()
			task.wait(1.0)
		else
			task.wait(0.3)
		end
	end
end)

----------------------------------------------------------------------
-- Off-screen arrow with distance
----------------------------------------------------------------------

local arrow = Instance.new("Frame")
arrow.Size = UDim2.new(0, 72, 0, 72)
arrow.AnchorPoint = Vector2.new(0.5, 0.5)
arrow.BackgroundColor3 = AMBER
arrow.BackgroundTransparency = 0.2
arrow.BorderSizePixel = 0
arrow.Visible = false
arrow.Parent = screen
local arrowCorner = Instance.new("UICorner") ; arrowCorner.CornerRadius = UDim.new(1, 0) ; arrowCorner.Parent = arrow
local arrowStroke = Instance.new("UIStroke") ; arrowStroke.Color = AMBER ; arrowStroke.Thickness = 2 ; arrowStroke.Parent = arrow

local arrowGlyph = Instance.new("TextLabel")
arrowGlyph.Size = UDim2.new(1, 0, 1, 0)
arrowGlyph.BackgroundTransparency = 1
arrowGlyph.Text = "➤"
arrowGlyph.TextColor3 = Color3.fromRGB(30, 20, 10)
arrowGlyph.Font = Enum.Font.GothamBlack
arrowGlyph.TextSize = 40
arrowGlyph.Parent = arrow

local arrowLabel = Instance.new("TextLabel")
arrowLabel.Size = UDim2.new(0, 220, 0, 22)
arrowLabel.AnchorPoint = Vector2.new(0.5, 0)
arrowLabel.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
arrowLabel.BackgroundTransparency = 0.1
arrowLabel.BorderSizePixel = 0
arrowLabel.TextColor3 = AMBER
arrowLabel.Font = Enum.Font.GothamBold
arrowLabel.TextSize = 14
arrowLabel.Text = ""
arrowLabel.Visible = false
arrowLabel.Parent = screen
local arrowLabelCorner = Instance.new("UICorner") ; arrowLabelCorner.CornerRadius = UDim.new(0, 4) ; arrowLabelCorner.Parent = arrowLabel

----------------------------------------------------------------------
-- World-space billboard (parented to the tracked target)
----------------------------------------------------------------------

local waypointBillboard = Instance.new("BillboardGui")
waypointBillboard.Name = "TutorialWaypoint"
waypointBillboard.Size = UDim2.new(0, 180, 0, 110)
waypointBillboard.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
waypointBillboard.AlwaysOnTop = true
waypointBillboard.LightInfluence = 0
waypointBillboard.MaxDistance = 12000
waypointBillboard.Enabled = false
waypointBillboard.Parent = screen   -- parent swaps when target changes

local wpChevron = Instance.new("TextLabel")
wpChevron.Size = UDim2.new(1, 0, 0, 70)
wpChevron.BackgroundTransparency = 1
wpChevron.Text = "▼"
wpChevron.TextColor3 = AMBER
wpChevron.Font = Enum.Font.GothamBlack
wpChevron.TextSize = 64
wpChevron.TextStrokeTransparency = 0.4
wpChevron.Parent = waypointBillboard

local wpLabel = Instance.new("TextLabel")
wpLabel.Size = UDim2.new(1, 0, 0, 22)
wpLabel.Position = UDim2.new(0, 0, 0, 70)
wpLabel.BackgroundTransparency = 1
wpLabel.TextColor3 = AMBER
wpLabel.Font = Enum.Font.GothamBold
wpLabel.TextSize = 16
wpLabel.TextStrokeTransparency = 0.4
wpLabel.Text = ""
wpLabel.Parent = waypointBillboard

local wpDist = Instance.new("TextLabel")
wpDist.Size = UDim2.new(1, 0, 0, 16)
wpDist.Position = UDim2.new(0, 0, 0, 92)
wpDist.BackgroundTransparency = 1
wpDist.TextColor3 = Color3.fromRGB(240, 240, 240)
wpDist.Font = Enum.Font.Gotham
wpDist.TextSize = 13
wpDist.TextStrokeTransparency = 0.5
wpDist.Text = ""
wpDist.Parent = waypointBillboard

-- Pulse the chevron so it reads from far away
task.spawn(function()
	while waypointBillboard.Parent do
		if waypointBillboard.Enabled then
			TweenService:Create(wpChevron, TweenInfo.new(0.7, Enum.EasingStyle.Sine), { TextSize = 80 }):Play()
			task.wait(0.7)
			TweenService:Create(wpChevron, TweenInfo.new(0.7, Enum.EasingStyle.Sine), { TextSize = 64 }):Play()
			task.wait(0.7)
		else
			task.wait(0.3)
		end
	end
end)

----------------------------------------------------------------------
-- Directives panel (toggle with J or the button)
----------------------------------------------------------------------

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 150, 0, 36)
toggleBtn.AnchorPoint = Vector2.new(1, 1)
toggleBtn.Position = UDim2.new(1, -16, 1, -200)
toggleBtn.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
toggleBtn.BackgroundTransparency = 0.15
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "📋  DIRECTIVES  [J]"
toggleBtn.TextColor3 = AMBER
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = screen
local tbCorner = Instance.new("UICorner") ; tbCorner.CornerRadius = UDim.new(0, 6) ; tbCorner.Parent = toggleBtn
local tbStroke = Instance.new("UIStroke") ; tbStroke.Color = AMBER ; tbStroke.Thickness = 1 ; tbStroke.Transparency = 0.3 ; tbStroke.Parent = toggleBtn

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 340, 0, 400)
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -16, 1, -244)
panel.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screen
local pnCorner = Instance.new("UICorner") ; pnCorner.CornerRadius = UDim.new(0, 8) ; pnCorner.Parent = panel
local pnStroke = Instance.new("UIStroke") ; pnStroke.Color = AMBER ; pnStroke.Thickness = 1 ; pnStroke.Transparency = 0.3 ; pnStroke.Parent = panel

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, -16, 0, 24)
panelTitle.Position = UDim2.new(0, 8, 0, 8)
panelTitle.BackgroundTransparency = 1
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.Text = "DIRECTIVES  —  track to set waypoint"
panelTitle.TextColor3 = AMBER
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 14
panelTitle.Parent = panel

local panelScroll = Instance.new("ScrollingFrame")
panelScroll.Size = UDim2.new(1, -16, 1, -40)
panelScroll.Position = UDim2.new(0, 8, 0, 32)
panelScroll.BackgroundTransparency = 1
panelScroll.BorderSizePixel = 0
panelScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
panelScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
panelScroll.ScrollBarThickness = 4
panelScroll.ScrollBarImageColor3 = AMBER
panelScroll.Parent = panel

local panelLayout = Instance.new("UIListLayout")
panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
panelLayout.Padding = UDim.new(0, 4)
panelLayout.Parent = panelScroll

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------

local currentStep = 0       -- index actually driving progression
local trackedStep = 0       -- index whose arrow/billboard is displayed
local stepStarted = 0
local stepRows = {}

local function setTracked(i)
	if not steps[i] then return end
	trackedStep = i
	for idx, row in ipairs(stepRows) do
		row.trackDot.Text = (idx == trackedStep) and "◉" or "○"
		row.trackDot.TextColor3 = (idx == trackedStep) and AMBER or DIM
	end
end

local function buildRows()
	for i, step in ipairs(steps) do
		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, -4, 0, 52)
		row.BackgroundColor3 = Color3.fromRGB(18, 26, 42)
		row.BackgroundTransparency = 0.25
		row.BorderSizePixel = 0
		row.AutoButtonColor = false
		row.Text = ""
		row.LayoutOrder = i
		row.Parent = panelScroll

		local rc = Instance.new("UICorner") ; rc.CornerRadius = UDim.new(0, 4) ; rc.Parent = row

		local dot = Instance.new("TextLabel")
		dot.Size = UDim2.new(0, 22, 1, 0)
		dot.Position = UDim2.new(0, 6, 0, 0)
		dot.BackgroundTransparency = 1
		dot.Font = Enum.Font.GothamBold
		dot.TextSize = 16
		dot.Text = "▢"
		dot.TextColor3 = DIM
		dot.Parent = row

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -64, 0, 18)
		title.Position = UDim2.new(0, 30, 0, 6)
		title.BackgroundTransparency = 1
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Text = string.format("%d. %s", i, step.title)
		title.TextColor3 = Color3.fromRGB(225, 235, 250)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 13
		title.Parent = row

		local body = Instance.new("TextLabel")
		body.Size = UDim2.new(1, -64, 0, 26)
		body.Position = UDim2.new(0, 30, 0, 22)
		body.BackgroundTransparency = 1
		body.TextXAlignment = Enum.TextXAlignment.Left
		body.TextYAlignment = Enum.TextYAlignment.Top
		body.TextWrapped = true
		body.Text = step.body
		body.TextColor3 = Color3.fromRGB(170, 190, 210)
		body.Font = Enum.Font.Gotham
		body.TextSize = 11
		body.Parent = row

		local trackDot = Instance.new("TextLabel")
		trackDot.Size = UDim2.new(0, 26, 1, 0)
		trackDot.AnchorPoint = Vector2.new(1, 0)
		trackDot.Position = UDim2.new(1, -6, 0, 0)
		trackDot.BackgroundTransparency = 1
		trackDot.Font = Enum.Font.GothamBold
		trackDot.TextSize = 18
		trackDot.Text = "○"
		trackDot.TextColor3 = DIM
		trackDot.Parent = row

		row.MouseButton1Click:Connect(function()
			setTracked(i)
		end)

		stepRows[i] = { row = row, dot = dot, title = title, body = body, trackDot = trackDot }
	end
end
buildRows()

local function refreshRowStates()
	for i, entry in ipairs(stepRows) do
		if i < currentStep then
			entry.dot.Text = "✓" ; entry.dot.TextColor3 = GREEN
			entry.title.TextColor3 = Color3.fromRGB(150, 180, 200)
		elseif i == currentStep then
			entry.dot.Text = "▶" ; entry.dot.TextColor3 = AMBER
			entry.title.TextColor3 = Color3.fromRGB(255, 230, 200)
			entry.row.BackgroundColor3 = Color3.fromRGB(40, 30, 18)
		else
			entry.dot.Text = "▢" ; entry.dot.TextColor3 = DIM
			entry.title.TextColor3 = Color3.fromRGB(225, 235, 250)
			entry.row.BackgroundColor3 = Color3.fromRGB(18, 26, 42)
		end
	end
end

local function togglePanel()
	panel.Visible = not panel.Visible
end

toggleBtn.MouseButton1Click:Connect(togglePanel)
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.J then togglePanel() end
end)

----------------------------------------------------------------------
-- Banner update + flash
----------------------------------------------------------------------

local function applyBanner(step, idx)
	stepTag.Text = string.format("DIRECTIVE  %d / %d", idx, #steps)
	stepTag.TextColor3 = AMBER
	bStroke.Color = AMBER
	pulseStroke.Color = AMBER
	accent.BackgroundColor3 = AMBER
	titleLbl.Text = step.title
	bodyLbl.Text = step.body
	banner.Visible = true

	-- Brief enlarge flash on new step
	banner.Size = UDim2.new(0, 620, 0, 118)
	local t = TweenService:Create(banner, TweenInfo.new(0.18, Enum.EasingStyle.Back), { Size = UDim2.new(0, 640, 0, 124) })
	t:Play()
	t.Completed:Connect(function()
		TweenService:Create(banner, TweenInfo.new(0.3), { Size = UDim2.new(0, 620, 0, 118) }):Play()
	end)
end

local function flashComplete(msg)
	stepTag.Text = "STEP COMPLETE"
	stepTag.TextColor3 = GREEN
	bStroke.Color = GREEN
	pulseStroke.Color = GREEN
	accent.BackgroundColor3 = GREEN
	titleLbl.Text = "✓  " .. (msg or "")
	bodyLbl.Text = ""
	task.wait(1.2)
end

----------------------------------------------------------------------
-- Waypoint (world + off-screen arrow)
----------------------------------------------------------------------

local camera = Workspace.CurrentCamera

local function attachWaypoint(targetPart, label)
	waypointBillboard.Adornee = targetPart
	waypointBillboard.Parent = targetPart
	waypointBillboard.StudsOffset = Vector3.new(0, (targetPart.Size.Y / 2) + 8, 0)
	waypointBillboard.Enabled = true
	wpLabel.Text = label or ""
end

local function clearWaypoint()
	waypointBillboard.Enabled = false
	waypointBillboard.Adornee = nil
	waypointBillboard.Parent = screen
	arrow.Visible = false
	arrowLabel.Visible = false
end

local function updateArrow(targetWorldPos, label, distance)
	local viewport = camera.ViewportSize
	local screenPos, onScreen = camera:WorldToViewportPoint(targetWorldPos)
	wpDist.Text = string.format("%d st", math.floor(distance))

	if onScreen and screenPos.Z > 0 then
		arrow.Visible = false
		arrowLabel.Visible = false
		return
	end

	local cx, cy = viewport.X / 2, viewport.Y / 2
	local dx, dy = screenPos.X - cx, screenPos.Y - cy
	if screenPos.Z < 0 then dx, dy = -dx, -dy end
	local ax, ay = math.abs(dx), math.abs(dy)
	if ax < 0.01 then ax = 0.01 end
	if ay < 0.01 then ay = 0.01 end
	local margin = 90
	local maxX = cx - margin
	local maxY = cy - margin
	local scale = math.min(maxX / ax, maxY / ay)
	local px, py = cx + dx * scale, cy + dy * scale

	arrow.Position = UDim2.fromOffset(px, py)
	arrow.Rotation = math.deg(math.atan2(dy, dx))
	arrow.Visible = true
	arrowLabel.Position = UDim2.fromOffset(px, py + 52)
	arrowLabel.Text = string.format("%s  —  %d st", label or "", math.floor(distance))
	arrowLabel.Visible = true
end

----------------------------------------------------------------------
-- Runner
----------------------------------------------------------------------

local function startStep(i)
	currentStep = i
	local step = steps[i]
	if not step then
		banner.Visible = false
		clearWaypoint()
		refreshRowStates()
		return
	end
	stepStarted = os.clock()
	applyBanner(step, i)
	setTracked(i)
	refreshRowStates()

	if step.target then
		local p = worldPart(step.target)
		if p then attachWaypoint(p, step.short or step.title) else clearWaypoint() end
	else
		clearWaypoint()
	end
end

local function advance(fromIdx)
	local cur = steps[fromIdx]
	if cur and cur.flash then flashComplete(cur.flash) end
	if cur and cur.final then
		banner.Visible = false
		clearWaypoint()
		refreshRowStates()
		currentStep = #steps + 1
	else
		startStep(fromIdx + 1)
	end
end

task.delay(6, function() startStep(1) end)

RunService.Heartbeat:Connect(function()
	if currentStep == 0 then return end
	local step = steps[currentStep]
	if not step then return end

	-- Drive waypoint off the *tracked* step (defaults to current)
	local tStep = steps[trackedStep] or step
	if tStep and tStep.target then
		local p = worldPart(tStep.target)
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if p and root then
			if waypointBillboard.Adornee ~= p then
				attachWaypoint(p, tStep.short or tStep.title)
			end
			local d = (p.Position - root.Position).Magnitude
			updateArrow(p.Position, tStep.short or tStep.title, d)
		end
	else
		clearWaypoint()
	end

	-- Progression check (on current, not tracked)
	local ready = false
	if step.done then
		ready = step.done()
	elseif step.auto then
		ready = (os.clock() - stepStarted) >= step.auto
	end
	if ready then
		local doneIdx = currentStep
		currentStep = -1
		task.spawn(function() advance(doneIdx) end)
	end
end)
