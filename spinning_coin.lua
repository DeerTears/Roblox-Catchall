speed = script.Speed.Value
-- or just = 4 if you prefer values to be in-script instead of in NumberValues

while true do
	script.Parent.CFrame = script.Parent.CFrame * CFrame.Angles(0, 0, math.rad(speed))
	wait(0)
end

local current_position = script.Parent.Position
