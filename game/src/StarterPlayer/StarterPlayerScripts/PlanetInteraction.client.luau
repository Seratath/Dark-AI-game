-- Shows planet labels when the probe flies within range.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local RANGE = 130

local planetInfo = {
	Planet_Homeworld = "Homeworld  |  Habitable",
	Planet_Barren    = "Barren World  |  Uninhabitable",
	Planet_Resource  = "Resource World  |  Ore Rich",
}

-- Wait for scene to build
task.wait(2)

local entries = {}

for name, label in pairs(planetInfo) do
	local planet = workspace:FindFirstChild(name)
	if not planet then continue end

	local bg = Instance.new("BillboardGui")
	bg.Adornee = planet
	bg.Size = UDim2.new(0, 220, 0, 50)
	bg.StudsOffset = Vector3.new(0, planet.Size.Y * 0.65 + 5, 0)
	bg.AlwaysOnTop = false
	bg.Enabled = false
	bg.Parent = planet

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = label
	text.TextColor3 = Color3.fromRGB(190, 225, 255)
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.Parent = bg

	table.insert(entries, { planet = planet, gui = bg })
end

RunService.Heartbeat:Connect(function()
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _, e in ipairs(entries) do
		local dist = (e.planet.Position - root.Position).Magnitude
		e.gui.Enabled = dist < RANGE
	end
end)
