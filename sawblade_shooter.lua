-- Thank you @CeaselessQuokka on Twitter: https://pastebin.com/7z0NPG1r for arm-pointing code involving RunService
-- Contained in a LocalScript child of a Tool

-- Services
local Players = game:GetService("Players");
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
wait() -- ensure services get finished

-- Variables
local arm_movement_allowed = false -- enables/disables arm pointing

-- Properties
local force = 8 -- how hard to shoot the saw

-- Declarations
local Player = Players.LocalPlayer -- gives us access to move the entire player when we find a target
local Character = Player.Character or Player.CharacterAdded:Wait() -- let us get certain body parts quickly
local Mouse = Player:GetMouse() -- lets us find where we're pointing the mouse
local Tool = script.Parent -- shorthand for connections at the bottom of this script

--- Character ---
local RightUpperArm = Character:WaitForChild("RightUpperArm");
local RightShoulder = RightUpperArm:WaitForChild("RightShoulder");
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");

RunService.Stepped:Connect(function() -- updates arm per step
	if arm_movement_allowed == false then
		return
	end
	local hit = Mouse.Hit
	-- add the lookVector * 5000 to the hit.p to make the point more "dramatic" (remove it and you'll see why I did this)
	local direction = hit.p + (hit.lookVector * 5000)
	-- get the rotation offset (so the arm points correctly depending on your rotation)
	local rootCFrame = HumanoidRootPart.CFrame;
	local rotationOffset = (rootCFrame - rootCFrame.p):inverse()
	-- since CFrames are relative, put the rotationOffset first, and then multiple by the point CFrame, and then multiply by the CFrame.Angles so the arm points in the right direction
	RightShoulder.Transform = rotationOffset * CFrame.new(Vector3.new(0, 0, 0), direction) * CFrame.Angles(math.pi / 2, 0, 0)
end)

function onClick() -- prepare the rope
	if Player == nil then
		warn("Sawblade tool was used, but no player was seen carrying it.")
		return
	end
end

function onRelease() -- send out the saw
	arm_movement_allowed = false
	local hit = Mouse.Hit
	local bullet = Instance.new("Part", script.Parent)
	bullet.Position = script.Parent.Handle.Position
	bullet.Shape = Enum.PartType.Cylinder
	bullet.Size = Vector3.new(0.5,1.5,1.5)
	bullet:ApplyImpulse(hit.lookVector * force)
	bullet.Touched:Connect(function(part)
		if part:IsA("Terrain") then
			bullet.Anchored = true
			bullet.Size = Vector3.new(0.5, 3, 3)
			bullet.AssemblyAngularVelocity = Vector3.new(0,0,0)
			bullet.AssemblyLinearVelocity = Vector3.new(0,0,0)
			Latched()
			Debris:AddItem(bullet, 10)
			return
		else
			print("hit something else, ignoring")
		end
	end)
end

function Latched()
	print("We latched!")
end

function onUnequipped() -- put away the rope
	arm_movement_allowed = false
end

function onEquipped(mouse) -- mouse is a built-in variable that holds our mouse as an Instance
	arm_movement_allowed = true	
end

Tool.Activated:Connect(onClick)
Tool.Deactivated:Connect(onRelease)
Tool.Unequipped:Connect(onUnequipped)
Tool.Equipped:Connect(onEquipped)
