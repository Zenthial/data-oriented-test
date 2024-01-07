-- describes the CFrame positions of how to weld a model when holstered to a player
return {
	Back = {
		{
			limb = "Torso",
			C0 = CFrame.new(0.25, 0.5, 0.6),
			C1 = CFrame.Angles(math.rad(30), math.rad(90), math.rad(270)),
		}
	},
	Hip = {
		{
			limb = "Torso",
			C0 = CFrame.new(1.15, -0.65, 0),
			C1 = CFrame.Angles(math.rad(110), 0, 0),
		},
		{
			limb = "Torso",
			C0 = CFrame.new(-1.15, -0.65, 0),
			C1 = CFrame.Angles(math.rad(110), 0, 0), 
		},
	},
	TorsoModule = {
		{
			limb = "Torso",
			C0 = CFrame.new(0, 0, 0),
			C1 = CFrame.Angles(math.rad(180), 0, math.rad(180)),
		},
	},
	RightArmModule = {
		{
			limb = "Right Arm",
			C0 = CFrame.new(0, 0, 0),
			C1 = CFrame.Angles(math.rad(180), 0, math.rad(180)), 
		},
	},
	LeftArmModule = {
		{
			limb = "Left Arm",
			C0 = CFrame.new(0, 0, 0),
			C1 = CFrame.Angles(math.rad(180), 0, math.rad(180)), 
		},
	},
	Melee = {
		{
			limb = "Torso",
			C0 = CFrame.new(-1.15, -0.65, 0),
			C1 = CFrame.Angles(math.rad(110), 0, 0), 
		},
	},
	Datacore = {
		{
			limb = "Torso",
			C0 = CFrame.new(0, 0, 0.6),
			C1 = CFrame.Angles(math.rad(90), math.rad(180), math.rad(90)),
		},
	},
}
