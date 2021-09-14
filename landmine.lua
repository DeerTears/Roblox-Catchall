local mine = script.Parent
local debounce = false

function explode()
	debounce = not debounce
	if debounce then
		return
	end
	local explosion = Instance.new("Explosion",mine)
	explosion.Position = mine.Position
	wait(3)
	mine:Destroy()
	mine = nil
end

mine.Touched:Connect(explode)