local respawning = false

-- NumberValue objects
local respawn_time = script.RespawnTime.Value
local object_transparency = script.ObjectTransparency.Value

script.Parent.Transparency = object_transparency
script.Parent.Particles.Enabled = true

function respawn()
	respawning = true
	script.Parent.Particles.Enabled = false
	script.Parent.Transparency = 1
	wait(respawn_time)
	respawning = false
	script.Parent.Particles.Enabled = true
	script.Parent.Transparency = object_transparency
end

function onTouch(part)
	if respawning then
		return
	end
	local player_with_points = part.Parent:FindFirstChild("Humanoid") and part.Parent.Humanoid.Points.Value
	if player_with_points ~= nil then
		part.Parent.Humanoid.Points.Value += 1
		script.Parent.CollectSound:Play()
		print("Your new score is: " .. part.Parent.Humanoid.Points.Value)
		respawn()
	end
end

script.Parent.Touched:connect(onTouch)
