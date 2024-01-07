-- describes how to weld the handles when a model is equipped by a player
-- some are reused, most are weapon specific

local rifle_standard_weld = {
	{
		limb = "Right Arm",
		C0 = CFrame.new(0, -0.5, -0.25) * CFrame.Angles(math.rad(-90),math.rad(180),0),
		C1 = CFrame.new()
	},
}

return {
	["W17"] = rifle_standard_weld
}
