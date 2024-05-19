--!strict
--[[

 Raycaster.luau
 To be used in Roblox Studio. Created by @artofcoding212 on Discord and Github.

]]--

--// Variables //--

--// The total amount of ricochets the rays can make.
local rayHitTimes: number = math.huge
--// The delay between each ray.
local rayDelay: number = 0.1
--// The tween time for the visuals to expand to the hit point.
local rayTween: number = 0.1
--// The amount of rays a ray can live through before it gets destroyed.
local rayLifetime: number = 100
--// A variable to be used by the script that shows how many times the rays have richocheted.
local rayHits: number = 0

--// The start Vector3 in which is the origin of the first ray.
local rayStart: Vector3 = workspace.Start.Position
--// The direction Vector3 in is the direction of the first ray.
local rayDirection: Vector3 = workspace.Direction.Position - rayStart
--// An array containing objects in which the ray can touch.
local rayWhitelist: {Instance} = {workspace.Maze}

--// Functions //--

--// Uses Roblox's Workspace:Raycast() function in a dynamic way.
local function castRay(startPosition: Vector3, direction: Vector3): RaycastResult?
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = rayWhitelist
	raycastParams.RespectCanCollide = true
	
	return workspace:Raycast(startPosition, direction, raycastParams)
end

--// Visualizes a ray with the given parameters.
local function visualizeRay(origin: Vector3, direction: Vector3, maxDistance: number): Part
	local raycastPart = Instance.new("Part", workspace)
	raycastPart.Size = Vector3.new(0.1, 0.1, 0)
	raycastPart.Color = Color3.fromRGB(255, 255, 255)
	
	raycastPart.Material = Enum.Material.Neon
	
	raycastPart.Anchored = true
	raycastPart.CanCollide = false
	
	raycastPart.Transparency = 0.5
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = rayWhitelist
	raycastParams.RespectCanCollide = true
	
	local raycastResult = workspace:Raycast(origin, direction * maxDistance, raycastParams)

	if raycastResult then
		game.TweenService:Create(raycastPart, TweenInfo.new(rayTween, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = Vector3.new(0.1, 0.1, raycastResult.Distance), CFrame = CFrame.new(origin, raycastResult.Position) * CFrame.new(0, 0, -raycastResult.Distance / 2)}):Play()
		raycastPart.CFrame = CFrame.new(origin, raycastResult.Position)
	else
		game.TweenService:Create(raycastPart, TweenInfo.new(rayTween, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = Vector3.new(0.1, 0.1, maxDistance), CFrame = CFrame.new(origin, origin + direction * maxDistance) * CFrame.new(0, 0, -maxDistance / 2)}):Play()
		raycastPart.CFrame = CFrame.new(origin, origin + direction * maxDistance)
	end
	
	return raycastPart
end

--// A function in which reflects the given vector and normal, giving the new ray's direction.
local function reflectVector(direction: Vector3, normal: Vector3): Vector3
	return (direction - 2 * (direction:Dot(normal)) * normal).Unit * 100
end

--// A function in which starts the raycast test with the given parameters. Returns whether or not the raycasts casted hit or not.
local function startRaycasting(startPosition: Vector3, direction: Vector3): boolean
	local result = castRay(startPosition, direction)
	
	if typeof(result) == "RaycastResult" then
		local visualization = visualizeRay(startPosition, direction, result.Distance)
		
		task.spawn(function()
			local startRays = rayHits + 1
			
			repeat
				wait()
			until rayHits == (startRays + 1)
			
			visualization.Color = Color3.fromRGB(213, 0, 0)
			visualization.Material = Enum.Material.SmoothPlastic
			visualization.Transparency = 0.5
			
			repeat
				wait()
			until rayHits == (startRays + rayLifetime)
			
			visualization:Destroy()
		end)
	else
		return false
	end
	
	if (rayHits + 1) < rayHitTimes then
		rayHits += 1
		
		wait(rayDelay)
		
		return startRaycasting(result.Position, reflectVector(direction, result.Normal))
	else
		rayHits = 0
		
		return true
	end
end

--// Main //--

print(startRaycasting(rayStart, rayDirection))
