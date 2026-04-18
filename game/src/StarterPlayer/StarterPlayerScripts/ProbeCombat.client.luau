-- Probe combat: left-click fires a forward laser from the probe, and a
-- threat banner + raider HP bar subscribe to ReplicatedStorage/
-- EmpireState/Threat. Shield flash fires when the server reports an
-- incoming hit.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("EmpireRemotes")
local fireWeapon  = remotes:WaitForChild("FireProbeWeapon")
local playerHitFx = remotes:WaitForChild("PlayerShieldHit")

local empireState = ReplicatedStorage:WaitForChild("EmpireState")
local threat = empireState:WaitForChild("Threat")
local warningMsg = threat:WaitForChild("Warning")
local raiderHp   = threat:WaitForChild("RaiderHP")
local raiderHpMax= threat:WaitForChild("RaiderHPMax")
local activeHostiles = threat:WaitForChild("ActiveHostiles")

local HOSTILE = Color3.fromRGB(255, 90, 90)

----------------------------------------------------------------------
-- UI
----------------------------------------------------------------------

local screen = Instance.new("ScreenGui")
screen.Name = "ProbeCombat"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = playerGui

-- Reticle
local reticle = Instance.new("Frame")
reticle.Size = UDim2.new(0, 14, 0, 14)
reticle.AnchorPoint = Vector2.new(0.5, 0.5)
reticle.Position = UDim2.new(0.5, 0, 0.5, 0)
reticle.BackgroundTransparency = 1
reticle.Parent = screen
local function tick(x, y, w, h)
	local t = Instance.new("Frame")
	t.AnchorPoint = Vector2.new(0.5, 0.5)
	t.Position = UDim2.new(0.5, x, 0.5, y)
	t.Size = UDim2.new(0, w, 0, h)
	t.BackgroundColor3 = Color3.fromRGB(120, 230, 255)
	t.BackgroundTransparency = 0.3
	t.BorderSizePixel = 0
	t.Parent = reticle
end
tick(-8, 0, 8, 1) ; tick(8, 0, 8, 1) ; tick(0, -8, 1, 8) ; tick(0, 8, 1, 8)

-- Threat banner (under CommsIntro/Tutorial area; right-aligned to avoid
-- colliding with the tutorial banner at top-centre)
local banner = Instance.new("Frame")
banner.Size = UDim2.new(0, 340, 0, 54)
banner.AnchorPoint = Vector2.new(1, 0)
banner.Position = UDim2.new(1, -16, 0, 260)
banner.BackgroundColor3 = Color3.fromRGB(22, 8, 10)
banner.BackgroundTransparency = 0.2
banner.BorderSizePixel = 0
banner.Visible = false
banner.Parent = screen
local bc = Instance.new("UICorner") ; bc.CornerRadius = UDim.new(0, 8) ; bc.Parent = banner
local bs = Instance.new("UIStroke") ; bs.Color = HOSTILE ; bs.Thickness = 1 ; bs.Transparency = 0.2 ; bs.Parent = banner

local warnLbl = Instance.new("TextLabel")
warnLbl.Size = UDim2.new(1, -12, 0, 18)
warnLbl.Position = UDim2.new(0, 6, 0, 4)
warnLbl.BackgroundTransparency = 1
warnLbl.TextXAlignment = Enum.TextXAlignment.Left
warnLbl.Font = Enum.Font.GothamBold
warnLbl.TextSize = 13
warnLbl.TextColor3 = HOSTILE
warnLbl.Text = "HOSTILE CONTACT"
warnLbl.Parent = banner

local hpLbl = Instance.new("TextLabel")
hpLbl.Size = UDim2.new(1, -12, 0, 12)
hpLbl.Position = UDim2.new(0, 6, 0, 22)
hpLbl.BackgroundTransparency = 1
hpLbl.TextXAlignment = Enum.TextXAlignment.Left
hpLbl.Font = Enum.Font.Gotham
hpLbl.TextSize = 11
hpLbl.TextColor3 = Color3.fromRGB(230, 200, 200)
hpLbl.Text = "RAIDER HULL"
hpLbl.Parent = banner

local hpTrack = Instance.new("Frame")
hpTrack.Size = UDim2.new(1, -12, 0, 6)
hpTrack.Position = UDim2.new(0, 6, 0, 40)
hpTrack.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
hpTrack.BorderSizePixel = 0
hpTrack.Parent = banner
local hpTrackCorner = Instance.new("UICorner") ; hpTrackCorner.CornerRadius = UDim.new(0, 3) ; hpTrackCorner.Parent = hpTrack

local hpFill = Instance.new("Frame")
hpFill.Size = UDim2.new(1, 0, 1, 0)
hpFill.BackgroundColor3 = HOSTILE
hpFill.BorderSizePixel = 0
hpFill.Parent = hpTrack
local hpFillCorner = Instance.new("UICorner") ; hpFillCorner.CornerRadius = UDim.new(0, 3) ; hpFillCorner.Parent = hpFill

-- Shield-hit full-screen vignette
local vignette = Instance.new("Frame")
vignette.Size = UDim2.new(1, 0, 1, 0)
vignette.BackgroundColor3 = HOSTILE
vignette.BackgroundTransparency = 1
vignette.BorderSizePixel = 0
vignette.ZIndex = -1
vignette.Parent = screen

----------------------------------------------------------------------
-- State wiring
----------------------------------------------------------------------

local function refreshBanner()
	local hostile = activeHostiles.Value > 0 or warningMsg.Value ~= ""
	banner.Visible = hostile
	if hostile then
		warnLbl.Text = warningMsg.Value ~= "" and warningMsg.Value or "HOSTILE CONTACT"
		local u = raiderHpMax.Value > 0 and (raiderHp.Value / raiderHpMax.Value) or 0
		hpFill.Size = UDim2.new(u, 0, 1, 0)
	end
end

warningMsg.Changed:Connect(refreshBanner)
raiderHp.Changed:Connect(refreshBanner)
raiderHpMax.Changed:Connect(refreshBanner)
activeHostiles.Changed:Connect(refreshBanner)
refreshBanner()

playerHitFx.OnClientEvent:Connect(function()
	vignette.BackgroundTransparency = 0.55
	TweenService:Create(vignette, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
end)

----------------------------------------------------------------------
-- Fire
----------------------------------------------------------------------

local cooldown = 0
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	local now = os.clock()
	if cooldown > now then return end
	cooldown = now + 0.22

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local camera = Workspace.CurrentCamera
	local dir = camera.CFrame.LookVector
	local origin = root.Position + dir * 3

	fireWeapon:FireServer(origin, dir)
end)
