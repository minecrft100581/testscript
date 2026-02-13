Tabs.Main:CreateToggle({
	Name = "Aimbot",
	CurrentValue = false,
	Callback = function(v)
		Settings.Aimbot = v
	end
})

Tabs.Main:CreateToggle({
	Name = "ESP",
	CurrentValue = false,
	Callback = function(v)
		Settings.ESP = v
	end
})

Tabs.Main:CreateDropdown({
	Name = "Aimbot Target",
	Options = {"Head","HumanoidRootPart"},
	CurrentOption = "Head",
	Callback = function(v)
		Settings.AimPart = v
	end
})

Tabs.Main:CreateDropdown({
	Name = "ESP Mode",
	Options = {"Box","Skeleton"},
	CurrentOption = "Box",
	Callback = function(v)
		Settings.ESPMode = v
	end
})

Tabs.Main:CreateSlider({
	Name = "FOV",
	Range = {50,400},
	Increment = 1,
	CurrentValue = Settings.FOV,
	Callback = function(v)
		Settings.FOV = v
	end
})

Tabs.Main:CreateSlider({
	Name = "Smoothness",
	Range = {0.01,1},
	Increment = 0.01,
	CurrentValue = Settings.Smoothness,
	Callback = function(v)
		Settings.Smoothness = v
	end
})

Tabs.Main:CreateColorPicker({
	Name = "ESP Color",
	Color = Settings.ESPColor,
	Callback = function(v)
		Settings.ESPColor = v
	end
})

Tabs.Main:CreateColorPicker({
	Name = "FOV Color",
	Color = Settings.FOVColor,
	Callback = function(v)
		Settings.FOVColor = v
	end
})

Tabs.Main:CreateToggle({
	Name = "ESP Rainbow",
	CurrentValue = false,
	Callback = function(v)
		Settings.ESPRainbow = v
	end
})

Tabs.Main:CreateToggle({
	Name = "FOV Rainbow",
	CurrentValue = false,
	Callback = function(v)
		Settings.FOVRainbow = v
	end
})

Tabs.Main:CreateToggle({
	Name = "Team Check",
	CurrentValue = true,
	Callback = function(v)
		Settings.TeamCheck = v
	end
})

Tabs.Main:CreateToggle({
	Name = "Visible Check",
	CurrentValue = true,
	Callback = function(v)
		Settings.VisibleCheck = v
	end
})
