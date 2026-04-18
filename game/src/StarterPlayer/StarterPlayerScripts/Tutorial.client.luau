-- Guided onboarding state machine. Replaces the old Objectives banner.
-- Drives the player through: travel → scan → claim Homeworld, then a
-- brief on resources/deployables, then travel → scan → claim Resource
-- World, travel to the Mining Asteroid, deploy a miner. After that the
-- banner clears and the player is in open play.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NEON  = Color3.fromRGB(0, 220, 255)
local AMBER = Color3.fromRGB(255, 200, 100)
local GREEN = Color3.fromRGB(120, 230, 160)

local empireState = ReplicatedStorage:WaitForChild("EmpireState", 10)
local claimedFolder  = empireState and empireState:WaitForChild("Claimed", 5)
local deployedFolder = empireState and empireState:WaitForChild("Deployed", 5)
local localScans = player:WaitForChild("LocalScans", 10)

----------------------------------------------------------------------
-- UI
----------------------------------------------------------------------

local screen = Instance.new("ScreenGui")
screen.Name = "Tutorial"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

-- Banner sits top-centre, below CommsIntro typewriter and Roblox topbar
local banner = Instance.new("Frame")
banner.Size = UDim2.new(0, 460, 0, 56)
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 180)
banner.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
banner.BackgroundTransparency = 0.2
banner.BorderSizePixel = 0
banner.Visible = false
banner.Parent = screen

local bc = Instance.new("UICorner") ; bc.CornerRadius = UDim.new(0, 8) ; bc.Parent = banner
local bs = Instance.new("UIStroke") ; bs.Color = AMBER ; bs.Thickness = 1 ; bs.Transparency = 0.3 ; bs.Parent = banner

local stepTag = Instance.new("TextLabel")
stepTag.Size = UDim2.new(1, -16, 0, 14)
stepTag.Position = UDim2.new(0, 8, 0, 6)
stepTag.BackgroundTransparency = 1
stepTag.TextXAlignment = Enum.TextXAlignment.Left
stepTag.Text = "DIRECTIVE"
stepTag.TextColor3 = AMBER
stepTag.Font = Enum.Font.GothamBold
stepTag.TextSize = 11
stepTag.Parent = banner

local stepText = Instance.new("TextLabel")
stepText.Size = UDim2.new(1, -16, 0, 32)
stepText.Position = UDim2.new(0, 8, 0, 20)
stepText.BackgroundTransparency = 1
stepText.TextXAlignment = Enum.TextXAlignment.Left
stepText.TextYAlignment = Enum.TextYAlignment.Top
stepText.TextWrapped = true
stepText.Text = ""
stepText.TextColor3 = Color3.fromRGB(220, 235, 250)
stepText.Font = Enum.Font.GothamMedium
stepText.TextSize = 13
stepText.Parent = banner

local function flashComplete(line)
	stepTag.Text = "STEP COMPLETE"
	stepTag.TextColor3 = GREEN
	bs.Color = GREEN
	stepText.Text = line
	task.wait(1.2)
	stepTag.TextColor3 = AMBER
	bs.Color = AMBER
end

----------------------------------------------------------------------
-- Off-screen arrow toward a target world position
----------------------------------------------------------------------

local arrow = Instance.new("ImageLabel")
arrow.Size = UDim2.new(0, 56, 0, 56)
arrow.AnchorPoint = Vector2.new(0.5, 0.5)
arrow.BackgroundTransparency = 1
arrow.Image = "rbxasset://textures/ui/Cursors/KeyboardMouse/ArrowFarCursor.png"
arrow.ImageColor3 = AMBER
arrow.ImageTransparency = 0.1
arrow.Visible = false
arrow.Parent = screen

local arrowText = Instance.new("TextLabel")
arrowText.Size = UDim2.new(0, 200, 0, 18)
arrowText.AnchorPoint = Vector2.new(0.5, 0.5)
arrowText.BackgroundTransparency = 1
arrowText.TextColor3 = AMBER
arrowText.Font = Enum.Font.GothamBold
arrowText.TextSize = 12
arrowText.Text = ""
arrowText.Visible = false
arrowText.Parent = screen

local camera = Workspace.CurrentCamera
local function updateArrow(targetWorldPos, label)
	local viewport = camera.ViewportSize
	local screenPos, onScreen = camera:WorldToViewportPoint(targetWorldPos)
	if onScreen and screenPos.Z > 0 then
		arrow.Visible = false
		arrowText.Visible = false
		return
	end
	local cx, cy = viewport.X / 2, viewport.Y / 2
	local dx, dy = screenPos.X - cx, screenPos.Y - cy
	if screenPos.Z < 0 then dx, dy = -dx, -dy end
	local len = math.max(math.sqrt(dx*dx + dy*dy), 0.001)
	local margin = 80
	local maxX = cx - margin
	local maxY = cy - margin
	local scale = math.min(maxX / math.abs(dx == 0 and 0.001 or dx), maxY / math.abs(dy == 0 and 0.001 or dy))
	local px, py = cx + dx * scale, cy + dy * scale
	arrow.Position = UDim2.fromOffset(px, py)
	arrow.Rotation = math.deg(math.atan2(dy, dx)) + 90
	arrow.Visible = true
	arrowText.Position = UDim2.fromOffset(px, py + 44)
	arrowText.Text = label
	arrowText.Visible = true
end

local function hideArrow()
	arrow.Visible = false
	arrowText.Visible = false
end

----------------------------------------------------------------------
-- Step definitions
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

local steps = {
	{
		text = "Travel to the Homeworld. The blue planet to your north.",
		target = "Planet_Homeworld",
		arrow = "HOMEWORLD",
		done = function() return distanceTo("Planet_Homeworld") < 320 end,
		complete = "Approach confirmed.",
	},
	{
		text = "Hold [F] near the Homeworld to scan and identify it.",
		target = "Planet_Homeworld",
		arrow = "SCAN",
		done = function() return isScanned("Planet_Homeworld") end,
		complete = "Homeworld classified.",
	},
	{
		text = "Press [C] to claim the Homeworld. This grants your starter kit.",
		target = "Planet_Homeworld",
		arrow = "CLAIM",
		done = function() return isClaimed("Planet_Homeworld") end,
		complete = "Homeworld is yours. +Energy +Ore +Fleet.",
	},
	{
		text = "BRIEF: Habitable worlds grow Compute and Population. Ore worlds and asteroids feed Miners. Beacons extend your network. Spend Ore to deploy.",
		target = nil,
		arrow = nil,
		auto = 7.0,
		complete = "Continue.",
	},
	{
		text = "Travel to the Resource World — the amber-yellow planet.",
		target = "Planet_Resource",
		arrow = "RESOURCE WORLD",
		done = function() return distanceTo("Planet_Resource") < 320 end,
		complete = "Approach confirmed.",
	},
	{
		text = "Hold [F] near the Resource World to scan it.",
		target = "Planet_Resource",
		arrow = "SCAN",
		done = function() return isScanned("Planet_Resource") end,
		complete = "Ore-rich world classified.",
	},
	{
		text = "Press [C] to claim the Resource World.",
		target = "Planet_Resource",
		arrow = "CLAIM",
		done = function() return isClaimed("Planet_Resource") end,
		complete = "Resource World claimed.",
	},
	{
		text = "Approach the Mining Asteroid orbiting the Resource World.",
		target = "Mining_Asteroid",
		arrow = "MINING ASTEROID",
		done = function() return distanceTo("Mining_Asteroid") < 200 end,
		complete = "In range of ore source.",
	},
	{
		text = "Press [M] near the asteroid to deploy a Mining Drone. Costs 10 Ore.",
		target = "Mining_Asteroid",
		arrow = "DEPLOY",
		done = function() return minerCount() >= 1 end,
		complete = "Drone operational. Ore is now flowing.",
	},
	{
		text = "Onboarding complete. The sector is yours to expand into.",
		target = nil,
		arrow = nil,
		auto = 5.0,
		complete = nil,
		final = true,
	},
}

----------------------------------------------------------------------
-- Runner
----------------------------------------------------------------------

local stepIndex = 0
local stepStarted = 0

local function startStep(i)
	stepIndex = i
	local step = steps[i]
	if not step then
		banner.Visible = false
		hideArrow()
		return
	end
	stepStarted = os.clock()
	stepTag.Text = string.format("DIRECTIVE  %d / %d", i, #steps)
	stepTag.TextColor3 = AMBER
	bs.Color = AMBER
	stepText.Text = step.text
	banner.Visible = true
end

local function advance(fromIdx)
	local cur = steps[fromIdx]
	if cur and cur.complete then
		flashComplete(cur.complete)
	end
	if cur and cur.final then
		banner.Visible = false
		hideArrow()
		stepIndex = #steps + 1
	else
		startStep(fromIdx + 1)
	end
end

-- Defer first step until world + intro have settled
task.delay(6, function() startStep(1) end)

RunService.Heartbeat:Connect(function()
	if stepIndex == 0 then return end
	local step = steps[stepIndex]
	if not step then return end

	if step.target then
		local p = worldPart(step.target)
		if p then updateArrow(p.Position, step.arrow or "") else hideArrow() end
	else
		hideArrow()
	end

	local ready = false
	if step.done then
		ready = step.done()
	elseif step.auto then
		ready = (os.clock() - stepStarted) >= step.auto
	end
	if ready then
		local doneIdx = stepIndex
		stepIndex = -1   -- guard against re-entry while flashComplete sleeps
		task.spawn(function() advance(doneIdx) end)
	end
end)
