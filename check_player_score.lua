local is_equipped = false
local player = nil


-- StarterPlayer Humanoid has an IntValue child called "Points"
function onActivated()
	if player ~= nil then
		print("Current points:" .. player.Points.Value)
	end
end

function onEquipped()
	is_equipped = true
	player = script.Parent.Parent:FindFirstChild("Humanoid")
	if player ~= nil then
		print("Current points:" .. player.Points.Value)
	end
end

function onUnequipped()
	player = nil
	is_equipped = false
end

script.Parent.Activated:Connect(onActivated)
script.Parent.Equipped:Connect(onEquipped)
script.Parent.Unequipped:Connect(onUnequipped)
