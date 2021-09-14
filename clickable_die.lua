-- Credit to Ozzypig for the tutorial on making Dice in Roblox: https://ozzypig.com/2016/06/01/scripting-dice-in-roblox
-- Throwing/randomness coded by GlitchyBirds: https://www.roblox.com/users/1909437467/profile

local faceValues = {
	Front = 1; Back = 6;
	Left = 2; Right = 5;
	Top = 3; Bottom = 4;
}

local random = Random.new()

local die = script.Parent
local clickDetector = die.ClickDetector
local vFace = die.Face
local vRoll = die.Roll
local vStable = die.IsStable
local vThreshold = die.StableThreshold

local baseMovement = die.Mass * game.Workspace.Gravity / 2 -- ~44 * 196.2 / 2 = ~4316.4

local currentSound = 0

die.Parent = workspace -- necessary for ApplyImpulse

local function getHighestFace(part)
	local highestFace
	local height = -math.huge
	
	for n, normalId in pairs(Enum.NormalId:GetEnumItems()) do
		local current_face_world_y = part.CFrame:pointToWorldSpace(Vector3.FromNormalId(normalId)).y
		if current_face_world_y > height then
			highestFace = normalId
			height = current_face_world_y
		end
	end
	
	return highestFace
end


local function updateDie()
	local highestFace = getHighestFace(die)
	vFace.Value = highestFace.Name
	vRoll.Value = faceValues[vFace.Value]
	
	local current_velocity = die:GetVelocityAtPosition(die.CFrame.Position).Magnitude
	if current_velocity > vThreshold.Value then
		vStable.Value = false
	else
		vStable.Value = true
	end
end

game:GetService("RunService").Stepped:connect(updateDie)

local function playSound()
	if currentSound == 0 then
		currentSound = 1
		die.SoundA:Play()
	else
		currentSound = 0
		die.SoundB:Play()
	end
end


local function throwDie()
	local rotImpulse = Vector3.new(random:NextNumber() * 90, random:NextNumber() * 90, random:NextNumber() * 90)
	local posImpulse = Vector3.new(0, baseMovement,0)
	die:ApplyImpulse(posImpulse)
	die:ApplyAngularImpulse(rotImpulse)
	wait(1.15)
	playSound()
end


local function onClick()
	if vStable.Value == true then
		throwDie()
		vStable.Value = false
	else -- this is usually not the reason the die stops responding, interestingly enough
		print("Wait, the die was clicked before it was stable!")
	end
end

die.ClickDetector.MouseClick:Connect(onClick)
