-- Scanner system:
--   * Passive detection — any cataloged object entering DETECT_RANGE is
--     added to the persistent contact list as an "Unidentified contact"
--     with a pulse flourish.
--   * Hold F to scan the nearest unidentified contact within SCAN_RANGE.
--     A progress bar fills; probe must stay (near-)stationary. Movement
--     above INTERRUPT_SPEED cancels the scan.
--   * Scan complete promotes the contact to its classification label.
--     A later "detailed" stage (stage 3) is wired in but gated — lets a
--     future scanner upgrade unlock richer readouts without rewriting.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local scanRemote
task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("EmpireRemotes", 10)
	if remotes then scanRemote = remotes:WaitForChild("ScanCompleted", 5) end
end)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

local NEON   = Color3.fromRGB(0, 220, 255)
local AMBER  = Color3.fromRGB(255, 200, 100)
local GREEN  = Color3.fromRGB(120, 230, 160)

local DETECT_RANGE    = 600   -- added to list as unidentified
local SCAN_RANGE      = 280   -- can be scanned
local SCAN_TIME       = 3.5
local INTERRUPT_SPEED = 6      -- studs/sec

----------------------------------------------------------------------
-- Catalog: reveal text per known object
----------------------------------------------------------------------

local catalog = {
	Planet_Homeworld = {
		label  = "Homeworld  —  Class-M, Habitable",
		detail = "Pop 12,400   Primary export: Compute",
		color  = Color3.fromRGB(100, 200, 255),
	},
	Planet_Barren = {
		label  = "Barren World  —  Uninhabitable",
		detail = "Trace silicate. No atmosphere.",
		color  = Color3.fromRGB(220, 170, 100),
	},
	Planet_Resource = {
		label  = "Resource World  —  Ore-Rich",
		detail = "Fe 48%   Si 22%   Rare-Earth 6%",
		color  = Color3.fromRGB(255, 220, 120),
	},
	JumpGate_Ring = {
		label  = "Jump Gate  —  Active Link",
		detail = "Destination: unresolved",
		color  = NEON,
	},
	Wreck_Hull = {
		label  = "Derelict Wreck",
		detail = "Origin: pre-Collapse freighter",
		color  = Color3.fromRGB(255, 120, 120),
	},
	PirateRaider = {
		label  = "Raider  —  Hostile",
		detail = "Armament: light plasma",
		color  = Color3.fromRGB(255, 80, 80),
	},
	Mining_Asteroid = {
		label  = "Ore-bearing Asteroid",
		detail = "Concentration: 34%",
		color  = Color3.fromRGB(220, 180, 120),
	},
	Star_Sol = {
		label  = "Star Sol  —  Main Sequence",
		detail = "Output: 3.8 YW",
		color  = Color3.fromRGB(255, 230, 100),
	},
}

----------------------------------------------------------------------
-- UI construction
----------------------------------------------------------------------

local screen = Instance.new("ScreenGui")
screen.Name = "ScannerSystem"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

-- Contact list: left side, pushed down below Roblox chat (chat sits top-left
-- roughly y=36..250). 260 clears it with a small buffer.
local list = Instance.new("Frame")
list.Size = UDim2.new(0, 280, 0, 280)
list.Position = UDim2.new(0, 16, 0, 260)
list.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
list.BackgroundTransparency = 0.25
list.BorderSizePixel = 0
list.Parent = screen

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 8) ; listCorner.Parent = list
local listStroke = Instance.new("UIStroke")
listStroke.Color = NEON ; listStroke.Thickness = 1 ; listStroke.Transparency = 0.4
listStroke.Parent = list

local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, -16, 0, 22)
listTitle.Position = UDim2.new(0, 8, 0, 6)
listTitle.BackgroundTransparency = 1
listTitle.Text = "CONTACTS"
listTitle.TextColor3 = NEON
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.Font = Enum.Font.GothamBold
listTitle.TextSize = 13
listTitle.Parent = list

local listDivider = Instance.new("Frame")
listDivider.Size = UDim2.new(1, -16, 0, 1)
listDivider.Position = UDim2.new(0, 8, 0, 30)
listDivider.BackgroundColor3 = NEON
listDivider.BackgroundTransparency = 0.6
listDivider.BorderSizePixel = 0
listDivider.Parent = list

local listScroll = Instance.new("ScrollingFrame")
listScroll.Size = UDim2.new(1, -16, 1, -40)
listScroll.Position = UDim2.new(0, 8, 0, 34)
listScroll.BackgroundTransparency = 1
listScroll.BorderSizePixel = 0
listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
listScroll.ScrollBarThickness = 4
listScroll.ScrollBarImageColor3 = NEON
listScroll.Parent = list

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = listScroll

-- Scan prompt (above crosshair-ish)
local prompt = Instance.new("Frame")
prompt.Size = UDim2.new(0, 280, 0, 34)
prompt.AnchorPoint = Vector2.new(0.5, 1)
prompt.Position = UDim2.new(0.5, 0, 0.55, 0)
prompt.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
prompt.BackgroundTransparency = 0.25
prompt.BorderSizePixel = 0
prompt.Visible = false
prompt.Parent = screen

local pCorner = Instance.new("UICorner") ; pCorner.CornerRadius = UDim.new(0, 6) ; pCorner.Parent = prompt
local pStroke = Instance.new("UIStroke") ; pStroke.Color = AMBER ; pStroke.Thickness = 1 ; pStroke.Transparency = 0.2
pStroke.Parent = prompt

local promptText = Instance.new("TextLabel")
promptText.Size = UDim2.new(1, -12, 1, 0)
promptText.Position = UDim2.new(0, 6, 0, 0)
promptText.BackgroundTransparency = 1
promptText.TextXAlignment = Enum.TextXAlignment.Center
promptText.Text = "[F] SCAN — Unidentified contact"
promptText.TextColor3 = AMBER
promptText.Font = Enum.Font.GothamBold
promptText.TextSize = 14
promptText.Parent = prompt

-- Scan progress bar
local progress = Instance.new("Frame")
progress.Size = UDim2.new(0, 340, 0, 22)
progress.AnchorPoint = Vector2.new(0.5, 1)
progress.Position = UDim2.new(0.5, 0, 0.62, 0)
progress.BackgroundColor3 = Color3.fromRGB(10, 16, 28)
progress.BackgroundTransparency = 0.2
progress.BorderSizePixel = 0
progress.Visible = false
progress.Parent = screen

local pgCorner = Instance.new("UICorner") ; pgCorner.CornerRadius = UDim.new(0, 4) ; pgCorner.Parent = progress
local pgStroke = Instance.new("UIStroke") ; pgStroke.Color = NEON ; pgStroke.Thickness = 1 ; pgStroke.Transparency = 0.3
pgStroke.Parent = progress

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, -4)
progressFill.Position = UDim2.new(0, 2, 0, 2)
progressFill.BackgroundColor3 = NEON
progressFill.BorderSizePixel = 0
progressFill.Parent = progress

local pgFillCorner = Instance.new("UICorner") ; pgFillCorner.CornerRadius = UDim.new(0, 3) ; pgFillCorner.Parent = progressFill

local progressLabel = Instance.new("TextLabel")
progressLabel.Size = UDim2.new(1, 0, 1, 0)
progressLabel.BackgroundTransparency = 1
progressLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
progressLabel.Font = Enum.Font.GothamBold
progressLabel.TextSize = 12
progressLabel.Text = "SCANNING  —  0%"
progressLabel.Parent = progress

-- Interrupt flash
local flashText = Instance.new("TextLabel")
flashText.Size = UDim2.new(0, 300, 0, 24)
flashText.AnchorPoint = Vector2.new(0.5, 1)
flashText.Position = UDim2.new(0.5, 0, 0.65, 0)
flashText.BackgroundTransparency = 1
flashText.TextColor3 = Color3.fromRGB(255, 120, 120)
flashText.Font = Enum.Font.GothamBold
flashText.TextSize = 14
flashText.Text = ""
flashText.Parent = screen

----------------------------------------------------------------------
-- Contact registry
----------------------------------------------------------------------

local contacts = {}   -- [name] = { anchor, stage, row, labelLbl, distLbl, dotIcon }
local contactOrder = 0

local function spawnPulse(position, color)
	local ring = Instance.new("Part")
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.4, 3, 3)
	ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	ring.Material = Enum.Material.Neon
	ring.Color = color
	ring.Transparency = 0.2
	ring.Anchored = true ; ring.CanCollide = false ; ring.CastShadow = false
	ring.Parent = Workspace

	local t = TweenService:Create(ring, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.4, 120, 120),
		Transparency = 1,
	})
	t:Play()
	t.Completed:Connect(function() ring:Destroy() end)
end

local function addRow(contact)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -4, 0, 34)
	row.BackgroundColor3 = Color3.fromRGB(18, 26, 42)
	row.BackgroundTransparency = 0.3
	row.BorderSizePixel = 0
	row.LayoutOrder = contact.order
	row.Parent = listScroll

	local rc = Instance.new("UICorner") ; rc.CornerRadius = UDim.new(0, 4) ; rc.Parent = row

	local dot = Instance.new("TextLabel")
	dot.Size = UDim2.new(0, 20, 1, 0)
	dot.Position = UDim2.new(0, 4, 0, 0)
	dot.BackgroundTransparency = 1
	dot.Text = "▢"
	dot.TextColor3 = AMBER
	dot.Font = Enum.Font.GothamBold
	dot.TextSize = 16
	dot.Parent = row

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -74, 0, 16)
	label.Position = UDim2.new(0, 24, 0, 3)
	label.BackgroundTransparency = 1
	label.Text = "Unidentified contact"
	label.TextColor3 = Color3.fromRGB(220, 235, 250)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = row

	local detail = Instance.new("TextLabel")
	detail.Size = UDim2.new(1, -74, 0, 12)
	detail.Position = UDim2.new(0, 24, 0, 18)
	detail.BackgroundTransparency = 1
	detail.Text = ""
	detail.TextColor3 = Color3.fromRGB(150, 180, 210)
	detail.TextXAlignment = Enum.TextXAlignment.Left
	detail.Font = Enum.Font.Gotham
	detail.TextSize = 11
	detail.TextTruncate = Enum.TextTruncate.AtEnd
	detail.Parent = row

	local dist = Instance.new("TextLabel")
	dist.Size = UDim2.new(0, 50, 1, 0)
	dist.AnchorPoint = Vector2.new(1, 0)
	dist.Position = UDim2.new(1, -6, 0, 0)
	dist.BackgroundTransparency = 1
	dist.Text = "—"
	dist.TextColor3 = Color3.fromRGB(140, 180, 210)
	dist.TextXAlignment = Enum.TextXAlignment.Right
	dist.Font = Enum.Font.Gotham
	dist.TextSize = 11
	dist.Parent = row

	contact.row = row
	contact.dot = dot
	contact.labelLbl = label
	contact.detailLbl = detail
	contact.distLbl = dist
end

local function resolveAnchor(name)
	local obj = Workspace:FindFirstChild(name)
	if not obj then return nil end
	if obj:IsA("Model") and obj.PrimaryPart then return obj.PrimaryPart end
	return obj
end

local function detectNew(root)
	for name, data in pairs(catalog) do
		if not contacts[name] then
			local anchor = resolveAnchor(name)
			if anchor then
				local d = (anchor.Position - root.Position).Magnitude
				if d < DETECT_RANGE then
					contactOrder += 1
					local contact = {
						name = name,
						anchor = anchor,
						catalog = data,
						stage = 1,
						order = contactOrder,
					}
					contacts[name] = contact
					addRow(contact)
					spawnPulse(anchor.Position, data.color)
				end
			end
		end
	end
end

local function promote(contact)
	contact.stage = 2
	contact.dot.Text = "✓"
	contact.dot.TextColor3 = GREEN
	contact.labelLbl.Text = contact.catalog.label
	contact.labelLbl.TextColor3 = contact.catalog.color
	-- Brief row flash
	local orig = contact.row.BackgroundColor3
	contact.row.BackgroundColor3 = Color3.fromRGB(30, 60, 50)
	TweenService:Create(contact.row, TweenInfo.new(0.8), { BackgroundColor3 = orig }):Play()
end

----------------------------------------------------------------------
-- Scan state machine
----------------------------------------------------------------------

local scanning = nil   -- { contact, elapsed }

local function cancelScan(reason)
	scanning = nil
	progress.Visible = false
	progressFill.Size = UDim2.new(0, 0, 1, -4)
	flashText.Text = reason or "SCAN INTERRUPTED"
	flashText.TextColor3 = Color3.fromRGB(255, 120, 120)
	task.delay(1.4, function()
		if flashText.Text == (reason or "SCAN INTERRUPTED") then flashText.Text = "" end
	end)
end

local function completeScan(contact)
	scanning = nil
	progress.Visible = false
	progressFill.Size = UDim2.new(0, 0, 1, -4)
	promote(contact)
	spawnPulse(contact.anchor.Position, contact.catalog.color)
	if scanRemote then scanRemote:FireServer(contact.name) end
	flashText.Text = "SCAN COMPLETE  —  " .. contact.catalog.label
	flashText.TextColor3 = GREEN
	task.delay(1.8, function()
		if string.sub(flashText.Text, 1, 13) == "SCAN COMPLETE" then flashText.Text = "" end
	end)
end

local function findScanTarget(rootPos)
	local best, bestDist = nil, math.huge
	for _, c in pairs(contacts) do
		if c.stage == 1 and c.anchor.Parent then
			local d = (c.anchor.Position - rootPos).Magnitude
			if d < SCAN_RANGE and d < bestDist then
				best, bestDist = c, d
			end
		end
	end
	return best, bestDist
end

----------------------------------------------------------------------
-- Input
----------------------------------------------------------------------

local fHeld = false
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F then fHeld = true end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		fHeld = false
		if scanning then cancelScan("SCAN CANCELLED") end
	end
end)

----------------------------------------------------------------------
-- Main loop
----------------------------------------------------------------------

task.wait(2.5)   -- let world build

RunService.Heartbeat:Connect(function(dt)
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Passive detection
	detectNew(root)

	-- Update distances on list
	for _, c in pairs(contacts) do
		if c.anchor.Parent then
			local d = (c.anchor.Position - root.Position).Magnitude
			c.distLbl.Text = string.format("%d st", math.floor(d))
			-- Fade rows for out-of-detect contacts (but keep known ones)
			c.row.BackgroundTransparency = (d > DETECT_RANGE * 1.4) and 0.7 or 0.3
		end
	end

	-- Scan prompt + initiation
	local target, targetDist = findScanTarget(root.Position)
	local velVal = player:FindFirstChild("ProbeVelocity")
	local speed = velVal and velVal.Value.Magnitude or 0

	if scanning then
		-- Interrupt on motion or target loss
		if speed > INTERRUPT_SPEED then
			cancelScan("SCAN INTERRUPTED — probe in motion")
			return
		end
		if not scanning.contact.anchor.Parent then
			cancelScan("TARGET LOST")
			return
		end
		local td = (scanning.contact.anchor.Position - root.Position).Magnitude
		if td > SCAN_RANGE * 1.1 then
			cancelScan("OUT OF RANGE")
			return
		end

		scanning.elapsed += dt
		local u = math.min(scanning.elapsed / SCAN_TIME, 1)
		progressFill.Size = UDim2.new(u, -4, 1, -4)
		progressLabel.Text = string.format("SCANNING  —  %d%%", math.floor(u * 100))

		if u >= 1 then
			completeScan(scanning.contact)
		end
	else
		if target and speed <= INTERRUPT_SPEED then
			prompt.Visible = true
			promptText.Text = string.format("[F] SCAN  —  Unidentified (%d st)", math.floor(targetDist))
			if fHeld then
				scanning = { contact = target, elapsed = 0 }
				progress.Visible = true
				prompt.Visible = false
			end
		else
			prompt.Visible = false
		end
	end
end)

----------------------------------------------------------------------
-- Controls-hint hook (update bottom-left to include F)
-- Non-destructive: only patches if the hint label exists.
----------------------------------------------------------------------

task.spawn(function()
	local hudGui = playerGui:WaitForChild("EmpireHUD", 4)
	if not hudGui then return end
	local hint = hudGui:FindFirstChild("ControlsHint")
	if hint and hint:IsA("TextLabel") then
		hint.Size = UDim2.new(0, 400, 0, 22)
		hint.Position = UDim2.new(0, 16, 1, -34)
		hint.Text = "  WASD move    SPACE up    SHIFT down    Q boost    F scan  "
	end
end)
