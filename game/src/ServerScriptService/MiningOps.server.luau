-- Three small mining drones ferrying between a "mother asteroid" and the
-- resource world. Each drone traces a curved path out, pauses at the
-- asteroid, then returns. Sells the "AI economy is running" feel.

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local resource = Workspace:WaitForChild("Planet_Resource", 5)
if not resource then return end

local DARK  = Color3.fromRGB(40, 48, 64)
local METAL = Color3.fromRGB(110, 120, 140)
local NEON  = Color3.fromRGB(255, 220, 120)  -- match resource-world colour

----------------------------------------------------------------------
-- Mother asteroid — large rock near the resource world with mining rigs
----------------------------------------------------------------------

local asteroidCenter = resource.Position + Vector3.new(80, 30, 80)

local rock = Instance.new("Part")
rock.Name = "Mining_Asteroid"
rock.Shape = Enum.PartType.Ball
rock.Size = Vector3.new(18, 14, 20)
rock.Position = asteroidCenter
rock.Anchored = true
rock.CanCollide = false
rock.CastShadow = false
rock.Material = Enum.Material.Slate
rock.Color = Color3.fromRGB(120, 95, 70)
rock.Parent = Workspace

-- Glowing ore veins on the rock
for i = 1, 4 do
	local vein = Instance.new("Part")
	vein.Name = "Ore_Vein"
	vein.Size = Vector3.new(2.5, 0.4, 2.5)
	vein.Material = Enum.Material.Neon
	vein.Color = NEON
	vein.Anchored = true
	vein.CanCollide = false
	vein.CastShadow = false
	local angle = i * math.pi / 2 + 0.3
	vein.CFrame = CFrame.new(asteroidCenter) * CFrame.Angles(angle, angle * 0.7, 0) * CFrame.new(0, 7, 0)
	vein.Parent = Workspace
end

----------------------------------------------------------------------
-- Mining drones — small boxy craft that ferry a cargo glow
----------------------------------------------------------------------

local function makeDrone(name, phaseOffset)
	local model = Instance.new("Model")
	model.Name = name

	local hull = Instance.new("Part")
	hull.Name = "Hull"
	hull.Size = Vector3.new(1.6, 0.8, 2.8)
	hull.Material = Enum.Material.Metal
	hull.Color = DARK
	hull.Anchored = true ; hull.CanCollide = false ; hull.CastShadow = false
	hull.Parent = model
	model.PrimaryPart = hull

	local cap = Instance.new("Part")
	cap.Name = "Cap"
	cap.Size = Vector3.new(1, 0.5, 1.2)
	cap.Material = Enum.Material.Metal
	cap.Color = METAL
	cap.Anchored = true ; cap.CanCollide = false ; cap.CastShadow = false
	cap.Parent = model

	local engine = Instance.new("Part")
	engine.Name = "Engine"
	engine.Shape = Enum.PartType.Ball
	engine.Size = Vector3.new(0.6, 0.6, 0.6)
	engine.Material = Enum.Material.Neon
	engine.Color = NEON
	engine.Anchored = true ; engine.CanCollide = false ; engine.CastShadow = false
	engine.Parent = model

	local cargo = Instance.new("Part")
	cargo.Name = "Cargo"
	cargo.Shape = Enum.PartType.Ball
	cargo.Size = Vector3.new(0.8, 0.8, 0.8)
	cargo.Material = Enum.Material.Neon
	cargo.Color = NEON
	cargo.Transparency = 1   -- visible only on return leg
	cargo.Anchored = true ; cargo.CanCollide = false ; cargo.CastShadow = false
	cargo.Parent = model

	model.Parent = Workspace

	return {
		model = model,
		hull = hull, cap = cap, engine = engine, cargo = cargo,
		phase = phaseOffset,
	}
end

local drones = {
	makeDrone("MiningDrone_A", 0),
	makeDrone("MiningDrone_B", 2.1),
	makeDrone("MiningDrone_C", 4.2),
}

----------------------------------------------------------------------
-- Animation: drones cycle resource-world → asteroid → resource-world.
-- Cycle length in seconds; cargo glow toggles on the return leg.
----------------------------------------------------------------------

local CYCLE = 14

local function lerp(a, b, t) return a + (b - a) * t end
local function lerpV(a, b, t) return a + (b - a) * t end

local resourceDockOffset = Vector3.new(0, (resource.Size.X / 2) + 12, 0)

RunService.Heartbeat:Connect(function(dt)
	for _, d in ipairs(drones) do
		d.phase = (d.phase + dt) % CYCLE
		local t = d.phase / CYCLE   -- 0..1

		local dockPos = resource.Position + resourceDockOffset
		local astPos  = asteroidCenter

		local pos, heading
		local carrying = false

		if t < 0.4 then
			-- Outbound: dock → asteroid
			local u = t / 0.4
			pos = lerpV(dockPos, astPos, u) + Vector3.new(0, math.sin(u * math.pi) * 6, 0)
			heading = (astPos - dockPos).Unit
		elseif t < 0.5 then
			-- Pause at asteroid, mining
			pos = astPos + Vector3.new(0, 6 + math.sin(t * 40) * 0.3, 0)
			heading = Vector3.new(1, 0, 0)
		elseif t < 0.9 then
			-- Return: asteroid → dock (carrying cargo)
			local u = (t - 0.5) / 0.4
			pos = lerpV(astPos, dockPos, u) + Vector3.new(0, math.sin(u * math.pi) * 6, 0)
			heading = (dockPos - astPos).Unit
			carrying = true
		else
			-- Pause at dock, unloading
			pos = dockPos + Vector3.new(0, math.sin(t * 40) * 0.2, 0)
			heading = Vector3.new(-1, 0, 0)
			carrying = t < 0.95   -- cargo blinks off during unload
		end

		local cf = CFrame.lookAt(pos, pos + heading)
		d.hull.CFrame   = cf
		d.cap.CFrame    = cf * CFrame.new(0, 0.55, 0.2)
		d.engine.CFrame = cf * CFrame.new(0, 0, 1.7)
		d.cargo.CFrame  = cf * CFrame.new(0, -0.7, 0)
		d.cargo.Transparency = carrying and 0 or 1
	end
end)
