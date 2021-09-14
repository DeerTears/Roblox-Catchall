-- Grappling Hook in the style of Indiana Jones
-- Thank you @CeaselessQuokka on Twitter: https://pastebin.com/7z0NPG1r for arm-pointing code involving RunService
-- Contained in a LocalScript child of a Tool

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris") -- to clear the rope grapple safely
wait() -- ensure services get finished

-- Declarations
local Player = Players.LocalPlayer -- gives us access to move the entire player when we find a target
local Character = Player.Character --or Player.CharacterAdded:Wait() -- let us get certain body parts quickly

if not Character or not Character.Parent then
	Character = Player.CharacterAdded:wait()
end

local Mouse = Player:GetMouse() -- lets us find where we're pointing the mouse
local Tool = script.Parent -- shorthand for connections at the bottom of this script

--- Character ---
local RightUpperArm = Character:WaitForChild("RightUpperArm")
local RightShoulder = RightUpperArm:WaitForChild("RightShoulder")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Variables
local arm_movement_allowed = false -- enables/disables arm pointing
local CurrentBullet = nil -- we can only have one rope out at a time
local latched = false -- prevents repeat collisions, enables the while loop in adjustRope()
local remaining_distance = HumanoidRootPart.Position

-- Properties
local minimum_distance = 8 -- how close before the rope stops pulling us
local grapple_lifetime = 10 -- how long the rope lasts after starting
local target_offset = Vector3.new(0,4,0) -- how to best-adjust where the rope grappled to
local force = 9 -- how hard to shoot the rope

function onClick() -- prepare the rope in our hands
	arm_movement_allowed = true
	-- todo: play animation of handle being twirled
end

function onRelease() -- send out the rope
	local hit = Mouse.Hit
	-- more fun this way
	--latched = false
	arm_movement_allowed = false
	
	if CurrentBullet then
		Debris:AddItem(CurrentBullet, 0.033)
	end
	
	local bullet = Instance.new("Part", script.Parent.Parent.Parent)
	bullet.CanCollide = false
	bullet.Position = script.Parent.Handle.Position
	bullet.Shape = Enum.PartType.Ball
	bullet.Size = Vector3.new(0.5,0.5,0.5)
	bullet.BrickColor = BrickColor.new(Color3.new(0.294118, 0.215686, 0.117647))
	bullet.TopSurface = Enum.SurfaceType.Smooth
	bullet.BottomSurface = Enum.SurfaceType.Smooth
	bullet:ApplyImpulse(hit.lookVector * force)
	wait() -- this tick debounces collisions against the player, makes intended rope latches on terrain more likely to happen
	bullet.CanCollide = true
	
	CurrentBullet = bullet -- lets us modify this bullet in other functions
	
	bullet.Touched:Connect(function(part)
		if latched then
			return -- prevents ropeLatched() from being called again if we already latched
		end
		if part:IsA("Terrain") then -- bug: latches underwater
			ropeLatched()
			return
		end
		if part:IsA("BasePart") then -- todo: latch to specific parts but not others?
			return	
		end
	end)
end


function onKeyDown(key)
	key = key:lower()
	if key == "r" or key == "e" then
		latched = false
		Humanoid.Sit = false
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

function onUnequipped() -- put away the rope
	latched = false
	arm_movement_allowed = false
end

function onEquipped(mouse) -- take out the rope (mouse is an Instance of the real mouse)
	arm_movement_allowed = true	
end


function ropeLatched() -- connect to a spot on terrain and prepare to swing
	latched = true -- lets adjustRope perform a loop
	arm_movement_allowed = true
	print("We latched!")
	
	CurrentBullet.Anchored = true -- idea: put an attachment on the target, don't anchor the CurrentBullet yet?
	-- or even just try to get the global coords of where the hit took place, and go there rather than anchor the part post-emptively
	-- we need the collided location anyways to make sure we can bungee our character to that location using the bullet as the anchor point
	CurrentBullet.CanCollide = false
	CurrentBullet.Size = Vector3.new(1.5,1.5,1.5)
	CurrentBullet.BrickColor = BrickColor.Black()
	CurrentBullet.AssemblyAngularVelocity = Vector3.new(0,0,0)
	CurrentBullet.AssemblyLinearVelocity = Vector3.new(0,0,0)
	local total_position = CurrentBullet.Position + target_offset
	CurrentBullet.CFrame = CFrame.new(total_position)
	HumanoidRootPart:ApplyImpulse(target_offset * force)
	Debris:AddItem(CurrentBullet, grapple_lifetime)
	remaining_distance = HumanoidRootPart.Position - CurrentBullet.Position
	if Humanoid then
		Humanoid.Sit = true
	end
	
end

function updateArmAngle()
	if arm_movement_allowed == false then
		return
	end

	local hit = Mouse.Hit
	-- add the lookVector * 5000 to the hit.p to make the point more "dramatic" (remove it and you'll see why I did this)
	local direction = hit.p + (hit.lookVector * 5000)
	-- get the rotation offset (so the arm points correctly depending on your rotation)
	local rootCFrame = HumanoidRootPart.CFrame
	local rotationOffset = (rootCFrame - rootCFrame.p):inverse()
	-- since CFrames are relative, put the rotationOffset first, and then multiple by the point CFrame, and then multiply by the CFrame.Angles so the arm points in the right direction
	RightShoulder.Transform = rotationOffset * CFrame.new(Vector3.new(0, 0, 0), direction) * CFrame.Angles(math.pi / 2, 0, 0)
end

function adjustRope(serverLifespan, delta)
	if latched == false then
		return
	end
	local interpolatedDistance = HumanoidRootPart.Position - remaining_distance * (delta * 2)
	Character:SetPrimaryPartCFrame(CFrame.new(interpolatedDistance))
	remaining_distance = HumanoidRootPart.Position - CurrentBullet.Position -- updates the script-wide variable remaining_distance
	print(remaining_distance.Magnitude)
	if remaining_distance.Magnitude <= minimum_distance then
		latched = false
		Humanoid.Sit = false
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

RunService.Stepped:Connect(updateArmAngle)
RunService.Stepped:Connect(adjustRope)

Tool.Activated:Connect(onClick)
Tool.Deactivated:Connect(onRelease)
Tool.Unequipped:Connect(onUnequipped)
Tool.Equipped:Connect(onEquipped)
Mouse.KeyDown:connect(onKeyDown)
Humanoid.Jumping:connect(function() onKeyDown("r") end)
