-- Slow world motion: planets spin on their axes, a translucent cloud band
-- rotates above the homeworld, and the central star has a very slow shimmer.
-- Everything is purely cosmetic — meant to kill the "static diorama" feel.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local function waitFor(name)
	return Workspace:WaitForChild(name, 5)
end

local star       = waitFor("Star_Sol")
local homeworld  = waitFor("Planet_Homeworld")
local barren     = waitFor("Planet_Barren")
local resource   = waitFor("Planet_Resource")

----------------------------------------------------------------------
-- Homeworld cloud band — slightly larger translucent ball, self-rotating
----------------------------------------------------------------------

local clouds
if homeworld then
	clouds = Instance.new("Part")
	clouds.Name = "Planet_Homeworld_Clouds"
	clouds.Shape = Enum.PartType.Ball
	clouds.Size = homeworld.Size * 1.04
	clouds.Position = homeworld.Position
	clouds.Anchored = true
	clouds.CanCollide = false
	clouds.CastShadow = false
	clouds.Material = Enum.Material.SmoothPlastic
	clouds.Color = Color3.fromRGB(230, 240, 255)
	clouds.Transparency = 0.65
	clouds.Parent = Workspace
end

----------------------------------------------------------------------
-- Rotation helpers
----------------------------------------------------------------------

local spinners = {}

local function spin(part, axis, speed)
	if not part then return end
	table.insert(spinners, { part = part, axis = axis, speed = speed, base = part.CFrame })
end

spin(homeworld, Vector3.new(0.1, 1, 0).Unit, 0.04)
spin(barren,    Vector3.new(0.2, 1, 0.1).Unit, 0.06)
spin(resource,  Vector3.new(-0.15, 1, 0).Unit, 0.05)
spin(clouds,    Vector3.new(0, 1, 0), 0.08)   -- counter-ish direction makes clouds "drift"
spin(star,      Vector3.new(0, 1, 0), 0.02)

RunService.Heartbeat:Connect(function(dt)
	for _, s in ipairs(spinners) do
		s.base = s.base * CFrame.fromAxisAngle(s.axis, s.speed * dt)
		-- Preserve world position (CFrame.fromAxisAngle is pure rotation but cumulative
		-- multiplication drifts position if base has translation baked in — recompose)
		s.part.CFrame = CFrame.new(s.part.Position) * (s.base - s.base.Position)
	end
end)

----------------------------------------------------------------------
-- Star corona — additional soft ForceField halo, pulses brightness
----------------------------------------------------------------------

if star then
	local corona = Instance.new("Part")
	corona.Name = "Star_Sol_Corona"
	corona.Shape = Enum.PartType.Ball
	corona.Size = star.Size * 1.6
	corona.Position = star.Position
	corona.Anchored = true
	corona.CanCollide = false
	corona.CastShadow = false
	corona.Material = Enum.Material.ForceField
	corona.Color = Color3.fromRGB(255, 200, 120)
	corona.Transparency = 0.7
	corona.Parent = Workspace

	task.spawn(function()
		local t = 0
		while corona.Parent do
			t += 0.05
			corona.Transparency = 0.65 + math.sin(t) * 0.08
			task.wait(0.1)
		end
	end)
end
