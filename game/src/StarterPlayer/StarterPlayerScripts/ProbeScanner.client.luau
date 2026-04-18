-- Probe scanner: expanding ring pulse when approaching points of interest,
-- plus a toast notification stack in the lower-centre announcing each contact.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local NEON = Color3.fromRGB(0, 220, 255)

----------------------------------------------------------------------
-- Toast stack UI
----------------------------------------------------------------------

local toastGui = Instance.new("ScreenGui")
toastGui.Name = "ProbeToasts"
toastGui.ResetOnSpawn = false
toastGui.IgnoreGuiInset = true
toastGui.Parent = playerGui

local toastRoot = Instance.new("Frame")
toastRoot.Size = UDim2.new(0, 420, 0, 140)
toastRoot.Position = UDim2.new(0.5, -210, 1, -210)
toastRoot.BackgroundTransparency = 1
toastRoot.Parent = toastGui

local toastLayout = Instance.new("UIListLayout")
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.Padding = UDim.new(0, 6)
toastLayout.Parent = toastRoot

local toastCounter = 0

local function showToast(title, body, accent)
	toastCounter += 1
	local order = toastCounter

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.LayoutOrder = order
	frame.Parent = toastRoot

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = accent or NEON
	stroke.Thickness = 1
	stroke.Transparency = 0.3
	stroke.Parent = frame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 3, 1, 0)
	bar.BackgroundColor3 = accent or NEON
	bar.BorderSizePixel = 0
	bar.Parent = frame

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -20, 0, 18)
	titleLbl.Position = UDim2.new(0, 12, 0, 4)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.TextColor3 = accent or NEON
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 13
	titleLbl.Parent = frame

	local bodyLbl = Instance.new("TextLabel")
	bodyLbl.Size = UDim2.new(1, -20, 0, 16)
	bodyLbl.Position = UDim2.new(0, 12, 0, 20)
	bodyLbl.BackgroundTransparency = 1
	bodyLbl.Text = body
	bodyLbl.TextColor3 = Color3.fromRGB(200, 215, 235)
	bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
	bodyLbl.Font = Enum.Font.Gotham
	bodyLbl.TextSize = 12
	bodyLbl.Parent = frame

	task.delay(5, function()
		local fade = TweenService:Create(frame, TweenInfo.new(0.5), {
			BackgroundTransparency = 1,
		})
		fade:Play()
		TweenService:Create(stroke, TweenInfo.new(0.5), { Transparency = 1 }):Play()
		TweenService:Create(titleLbl, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		TweenService:Create(bodyLbl, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		TweenService:Create(bar, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		fade.Completed:Wait()
		frame:Destroy()
	end)
end

----------------------------------------------------------------------
-- Scanner pulse — world-space expanding ring at contact position
----------------------------------------------------------------------

local function spawnPulse(position, color)
	local ring = Instance.new("Part")
	ring.Name = "ScannerPulse"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.4, 4, 4)
	ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	ring.Anchored = true
	ring.CanCollide = false
	ring.CastShadow = false
	ring.Material = Enum.Material.Neon
	ring.Color = color
	ring.Transparency = 0.2
	ring.Parent = Workspace

	local grow = TweenService:Create(ring, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.4, 120, 120),
		Transparency = 1,
	})
	grow:Play()
	grow.Completed:Connect(function() ring:Destroy() end)
end

----------------------------------------------------------------------
-- Contact registry — things the probe "detects" when within range
----------------------------------------------------------------------

local contacts = {
	{ name = "Planet_Homeworld", title = "CONTACT: Habitable World",    body = "Homeworld — atmosphere stable, colony active.",    range = 260, color = Color3.fromRGB(100, 200, 255) },
	{ name = "Planet_Barren",    title = "CONTACT: Barren World",        body = "No atmosphere detected. Mineral survey advised.",  range = 240, color = Color3.fromRGB(220, 170, 100) },
	{ name = "Planet_Resource",  title = "CONTACT: Resource-Rich World", body = "High ore concentration. Hostile signature nearby.", range = 260, color = Color3.fromRGB(255, 220, 120) },
	{ name = "JumpGate_Ring",    title = "CONTACT: Jump Gate",           body = "Ancient transit ring — destination unknown.",      range = 180, color = Color3.fromRGB(0,   220, 255) },
	{ name = "Wreck_Hull",       title = "ANOMALY: Derelict Wreck",      body = "Distress beacon active. Origin unidentified.",     range = 150, color = Color3.fromRGB(255, 120, 120) },
	{ name = "PirateRaider",     title = "THREAT: Unknown Raider",       body = "Hostile silhouette. Recommend evasion.",           range = 180, color = Color3.fromRGB(255,  80,  80) },
}

task.wait(2)

local tracked = {}
for _, c in ipairs(contacts) do
	local obj = Workspace:FindFirstChild(c.name)
	if obj then
		local anchor = obj
		if obj:IsA("Model") and obj.PrimaryPart then anchor = obj.PrimaryPart end
		table.insert(tracked, {
			anchor = anchor,
			title = c.title,
			body = c.body,
			range = c.range,
			color = c.color,
			seen = false,
			cooldownUntil = 0,
		})
	end
end

RunService.Heartbeat:Connect(function()
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local now = os.clock()
	for _, t in ipairs(tracked) do
		if t.anchor.Parent then
			local dist = (t.anchor.Position - root.Position).Magnitude
			if dist < t.range and now > t.cooldownUntil then
				showToast(t.title, t.body, t.color)
				spawnPulse(t.anchor.Position, t.color)
				t.seen = true
				t.cooldownUntil = now + 15   -- re-announce if you leave and return
			elseif dist > t.range * 1.3 then
				t.cooldownUntil = 0
			end
		end
	end
end)

-- Welcome toast
task.delay(1, function()
	showToast("PROBE ONLINE", "Von Neumann unit initialised. Awaiting directive.", NEON)
end)
