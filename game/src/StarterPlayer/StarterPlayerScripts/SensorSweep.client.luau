-- Probe active sensor: a subtle translucent ring slowly expands outward
-- from the probe every few seconds. Very quiet effect — adds the sense
-- that the probe is constantly scanning its surroundings.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local SWEEP_INTERVAL = 3.5
local MAX_RADIUS     = 90
local SWEEP_TIME     = 2.5
local COLOR          = Color3.fromRGB(0, 220, 255)

local function spawnSweep()
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local ring = Instance.new("Part")
	ring.Name = "SensorRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.3, 2, 2)
	ring.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.rad(90))
	ring.Anchored = true ; ring.CanCollide = false ; ring.CastShadow = false
	ring.Material = Enum.Material.Neon
	ring.Color = COLOR
	ring.Transparency = 0.6
	ring.Parent = Workspace

	local tween = TweenService:Create(ring, TweenInfo.new(SWEEP_TIME, Enum.EasingStyle.Linear), {
		Size = Vector3.new(0.3, MAX_RADIUS, MAX_RADIUS),
		Transparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function() ring:Destroy() end)
end

task.spawn(function()
	task.wait(4)
	while true do
		spawnSweep()
		task.wait(SWEEP_INTERVAL)
	end
end)
