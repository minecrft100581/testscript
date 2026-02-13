--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// GUI ROOT
local gui = Instance.new("ScreenGui")
gui.Name = "NebulaProgram"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--// BLUR
local blur = Instance.new("BlurEffect")
blur.Size = 18
blur.Parent = Lighting

--// MAIN WINDOW
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,600,0,380)
main.Position = UDim2.new(0.5,-300,0.5,-190)
main.BackgroundColor3 = Color3.fromRGB(20,20,30)
main.BackgroundTransparency = 0.08
Instance.new("UICorner", main).CornerRadius = UDim.new(0,18)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2

--====================================================
-- 🎨 THEME SYSTEM
--====================================================
local themes = {
	Purple = Color3.fromRGB(150,120,255),
	Red = Color3.fromRGB(255,80,80),
	Cyan = Color3.fromRGB(80,220,255)
}

local currentTheme = "Purple"

local function applyTheme()
	stroke.Color = themes[currentTheme]
end

applyTheme()

--====================================================
-- TITLE BAR
--====================================================
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,42)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Nebula Program UI"
title.TextColor3 = Color3.fromRGB(230,230,255)
title.TextScaled = true

--====================================================
-- DRAG SUPPORT
--====================================================
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

titleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--====================================================
-- BUTTONS (Minimize / Close)
--====================================================
local function makeTopButton(text, posX, color)
	local btn = Instance.new("TextButton", titleBar)
	btn.Size = UDim2.new(0,34,0,30)
	btn.Position = UDim2.new(1,posX,0,6)
	btn.Text = text
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
	return btn
end

local minimizeBtn = makeTopButton("—",-75,Color3.fromRGB(120,120,50))
local closeBtn = makeTopButton("X",-35,Color3.fromRGB(160,40,40))

-- Restore Button
local restoreBtn = Instance.new("TextButton", gui)
restoreBtn.Size = UDim2.new(0,150,0,40)
restoreBtn.Position = UDim2.new(0.5,-75,1,-70)
restoreBtn.Text = "Open Nebula"
restoreBtn.Visible = false
restoreBtn.BackgroundColor3 = Color3.fromRGB(50,50,80)
restoreBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0,12)

--====================================================
-- 📂 TAB SYSTEM
--====================================================
local tabBar = Instance.new("Frame", main)
tabBar.Position = UDim2.new(0,0,0,45)
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.BackgroundTransparency = 1

local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,85)
content.Size = UDim2.new(1,0,1,-85)
content.BackgroundTransparency = 1

local tabs = {}
local pages = {}

local function createTab(name)
	local button = Instance.new("TextButton", tabBar)
	button.Size = UDim2.new(0,150,1,0)
	button.Text = name
	button.BackgroundColor3 = Color3.fromRGB(40,40,60)
	button.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", button).CornerRadius = UDim.new(0,10)

	local page = Instance.new("Frame", content)
	page.Size = UDim2.new(1,0,1,0)
	page.Visible = false
	page.BackgroundTransparency = 1

	tabs[name] = button
	pages[name] = page

	button.MouseButton1Click:Connect(function()
		for _,p in pairs(pages) do
			p.Visible = false
		end
		page.Visible = true
	end)

	return page
end

local generalPage = createTab("General")
local visualPage = createTab("Visual")
local combatPage = createTab("Combat")

generalPage.Visible = true

--====================================================
-- 🎨 THEME SWITCH UI
--====================================================
local themeLabel = Instance.new("TextLabel", generalPage)
themeLabel.Size = UDim2.new(0,200,0,40)
themeLabel.Position = UDim2.new(0,20,0,20)
themeLabel.Text = "Theme:"
themeLabel.BackgroundTransparency = 1
themeLabel.TextColor3 = Color3.new(1,1,1)
themeLabel.TextScaled = true

local xOffset = 20
for name,_ in pairs(themes) do
	local btn = Instance.new("TextButton", generalPage)
	btn.Size = UDim2.new(0,100,0,35)
	btn.Position = UDim2.new(0,xOffset,0,70)
	btn.Text = name
	btn.BackgroundColor3 = themes[name]
	btn.TextColor3 = Color3.new(0,0,0)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

	btn.MouseButton1Click:Connect(function()
		currentTheme = name
		applyTheme()
	end)

	xOffset += 120
end

--====================================================
-- 🟡 MINIMIZE LOGIC
--====================================================
minimizeBtn.MouseButton1Click:Connect(function()
	TweenService:Create(main,TweenInfo.new(0.25),{
		Size = UDim2.new(0,0,0,0),
		BackgroundTransparency = 1
	}):Play()

	task.wait(0.25)
	main.Visible = false
	restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	TweenService:Create(main,TweenInfo.new(0.25),{
		Size = UDim2.new(0,600,0,380),
		BackgroundTransparency = 0.08
	}):Play()
	restoreBtn.Visible = false
end)

--====================================================
-- 🌌 BLACK HOLE CLOSE ANIMATION
--====================================================
local function blackHoleClose()
	local hole = Instance.new("Frame", gui)
	hole.Size = UDim2.new(0,10,0,10)
	hole.Position = UDim2.new(0.5,0,0.5,0)
	hole.AnchorPoint = Vector2.new(0.5,0.5)
	hole.BackgroundColor3 = Color3.new(0,0,0)
	Instance.new("UICorner", hole).CornerRadius = UDim.new(1,0)

	TweenService:Create(hole,TweenInfo.new(0.6,Enum.EasingStyle.Quad),{
		Size = UDim2.new(2,0,2,0)
	}):Play()

	task.wait(0.3)

	TweenService:Create(main,TweenInfo.new(0.4),{
		Size = UDim2.new(0,0,0,0),
		Position = UDim2.new(0.5,0,0.5,0)
	}):Play()

	task.wait(0.6)

	blur:Destroy()
	gui:Destroy()
end

closeBtn.MouseButton1Click:Connect(blackHoleClose)
