--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

--====================================================
-- GUI ROOT
--====================================================
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--====================================================
-- START FADE
--====================================================
local fade = Instance.new("Frame", gui)
fade.Size = UDim2.new(1,0,1,0)
fade.Position = UDim2.new(0,0,-1,0)
fade.BackgroundColor3 = Color3.new(1,1,1)
fade.ZIndex = 100

TweenService:Create(fade,TweenInfo.new(0.5),{Position = UDim2.new(0,0,0,0)}):Play()
task.wait(0.5)
TweenService:Create(fade,TweenInfo.new(0.3),{BackgroundTransparency = 1}):Play()
task.wait(0.3)
fade:Destroy()

--====================================================
-- BLUR
--====================================================
local old = Lighting:FindFirstChild("ProgramBlur")
if old then old:Destroy() end

local blur = Instance.new("BlurEffect")
blur.Name = "ProgramBlur"
blur.Size = 12
blur.Parent = Lighting

--====================================================
-- THEME (통합 이쁜 색)
--====================================================
local THEME = Color3.fromRGB(120,170,255)

--====================================================
-- MAIN WINDOW (반응형)
--====================================================
local main = Instance.new("Frame", gui)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.Position = UDim2.new(0.5,0,0.5,0)
main.Size = UDim2.new(0.6,0,0.7,0) -- 반응형
main.BackgroundColor3 = Color3.fromRGB(25,25,35)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke", main)
stroke.Color = THEME
stroke.Thickness = 2

--====================================================
-- TITLE BAR (DRAG)
--====================================================
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundColor3 = Color3.fromRGB(35,35,50)
titleBar.BorderSizePixel = 0

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Responsive Program UI"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

-- Drag
local dragging, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function()
	dragging = false
end)

--====================================================
-- CLOSE BUTTON (블랙홀)
--====================================================
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,34,0,30)
closeBtn.Position = UDim2.new(1,-40,0,5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(170,60,60)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

local function blackHoleClose()
	local hole = Instance.new("Frame", gui)
	hole.Size = UDim2.new(0,10,0,10)
	hole.Position = UDim2.new(0.5,0,0.5,0)
	hole.AnchorPoint = Vector2.new(0.5,0.5)
	hole.BackgroundColor3 = Color3.new(0,0,0)
	hole.ZIndex = 200
	Instance.new("UICorner", hole).CornerRadius = UDim.new(1,0)

	TweenService:Create(hole,TweenInfo.new(0.6),{
		Size = UDim2.new(2,0,2,0)
	}):Play()

	task.wait(0.6)
	blur:Destroy()
	gui:Destroy()
end

closeBtn.MouseButton1Click:Connect(blackHoleClose)

--====================================================
-- TAB SYSTEM
--====================================================
local tabBar = Instance.new("Frame", main)
tabBar.Position = UDim2.new(0,0,0,40)
tabBar.Size = UDim2.new(1,0,0,45)
tabBar.BackgroundColor3 = Color3.fromRGB(30,30,45)

local layout = Instance.new("UIListLayout", tabBar)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0,5)

local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,85)
content.Size = UDim2.new(1,0,1,-85)
content.BackgroundTransparency = 1

local tabs = {}
local pages = {}
local activeTab

local function createTab(name)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.3,0,1,-10)
	button.Text = name
	button.BackgroundColor3 = Color3.fromRGB(45,45,65)
	button.TextColor3 = Color3.new(1,1,1)
	button.Parent = tabBar
	Instance.new("UICorner", button).CornerRadius = UDim.new(0,8)

	local page = Instance.new("Frame")
	page.Size = UDim2.new(1,0,1,0)
	page.Visible = false
	page.BackgroundTransparency = 1
	page.Parent = content

	tabs[name] = button
	pages[name] = page

	button.MouseButton1Click:Connect(function()
		for n,btn in pairs(tabs) do
			btn.BackgroundColor3 = Color3.fromRGB(45,45,65)
			pages[n].Visible = false
		end
		button.BackgroundColor3 = THEME
		page.Visible = true
		activeTab = name
	end)

	return page
end

local general = createTab("General")
local visual = createTab("Visual")
local combat = createTab("Combat")

tabs["General"].BackgroundColor3 = THEME
pages["General"].Visible = true
activeTab = "General"

--====================================================
-- TOGGLE COMPONENT
--====================================================
local function createToggle(parent,text,default)
	local state = default

	local frame = Instance.new("Frame",parent)
	frame.Size = UDim2.new(0.9,0,0,40)
	frame.BackgroundColor3 = Color3.fromRGB(40,40,60)
	frame.BorderSizePixel = 0
	Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

	local label = Instance.new("TextLabel",frame)
	label.Size = UDim2.new(0.7,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true

	local button = Instance.new("TextButton",frame)
	button.Size = UDim2.new(0.2,0,0.7,0)
	button.Position = UDim2.new(0.75,0,0.15,0)
	button.Text = state and "ON" or "OFF"
	button.BackgroundColor3 = state and THEME or Color3.fromRGB(80,80,80)
	button.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",button).CornerRadius = UDim.new(0,8)

	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = state and "ON" or "OFF"
		button.BackgroundColor3 = state and THEME or Color3.fromRGB(80,80,80)
	end)

	return frame
end

--====================================================
-- SLIDER COMPONENT
--====================================================
local function createSlider(parent,text,min,max,default)
	local value = default

	local frame = Instance.new("Frame",parent)
	frame.Size = UDim2.new(0.9,0,0,60)
	frame.BackgroundColor3 = Color3.fromRGB(40,40,60)
	frame.BorderSizePixel = 0
	Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

	local label = Instance.new("TextLabel",frame)
	label.Size = UDim2.new(1,0,0.4,0)
	label.BackgroundTransparency = 1
	label.Text = text.." : "..value
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true

	local bar = Instance.new("Frame",frame)
	bar.Size = UDim2.new(0.9,0,0,10)
	bar.Position = UDim2.new(0.05,0,0.6,0)
	bar.BackgroundColor3 = Color3.fromRGB(70,70,90)
	bar.BorderSizePixel = 0
	Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

	local fill = Instance.new("Frame",bar)
	fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = THEME
	fill.BorderSizePixel = 0
	Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

	local draggingSlider = false

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
		end
	end)

	UIS.InputEnded:Connect(function()
		draggingSlider = false
	end)

	UIS.InputChanged:Connect(function(input)
		if draggingSlider and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			local percent = math.clamp(
				(input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
				0,1
			)
			value = math.floor(min + (max-min)*percent)
			fill.Size = UDim2.new(percent,0,1,0)
			label.Text = text.." : "..value
		end
	end)

	return frame
end

--====================================================
-- EXAMPLE CONTENT
--====================================================
createToggle(general,"Enable System",false).Position = UDim2.new(0.05,0,0.05,0)
createSlider(general,"Power Level",0,100,50).Position = UDim2.new(0.05,0,0.2,0)
