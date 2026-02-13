--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-------------------------------------------------
-- SETTINGS
-------------------------------------------------
local FOV_RADIUS = 120
local SMOOTHNESS = 0.15
local UI_COLOR = Color3.fromRGB(0,255,255)

local aimAssist = false
local espEnabled = false
local teamCheck = false
local triggerIndicator = false
local rgbMode = false

-------------------------------------------------
-- GUI BASE
-------------------------------------------------
local gui = Instance.new("ScreenGui",player.PlayerGui)
gui.ResetOnSpawn = false

local blur = Instance.new("BlurEffect",game.Lighting)
blur.Size = 0

-------------------------------------------------
-- DRAG FUNCTION
-------------------------------------------------
local function makeDraggable(frame)
	local dragging = false
	local dragStart
	local startPos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			
			local delta = input.Position - dragStart
			
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-------------------------------------------------
-- FLOAT BUTTON
-------------------------------------------------
local openButton = Instance.new("TextButton",gui)
openButton.Size = UDim2.new(0,60,0,60)
openButton.Position = UDim2.new(0.5,-30,0.7,0)
openButton.Text = "≡"
openButton.TextScaled = true
openButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
openButton.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",openButton).CornerRadius = UDim.new(1,0)
local openStroke = Instance.new("UIStroke",openButton)

makeDraggable(openButton)

-------------------------------------------------
-- MAIN PANEL
-------------------------------------------------
local main = Instance.new("Frame",gui)
main.Size = UDim2.new(0,350,0,480)
main.Position = UDim2.new(0.5,-175,0.5,-240)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BackgroundTransparency = 0.1
main.Visible = false
Instance.new("UICorner",main).CornerRadius = UDim.new(0,14)
local mainStroke = Instance.new("UIStroke",main)

makeDraggable(main)

-------------------------------------------------
-- TAB BUTTONS
-------------------------------------------------
local tabs = {}
local pages = {}

local tabNames = {"Combat","Visual","Settings"}

for i,name in ipairs(tabNames) do
	local btn = Instance.new("TextButton",main)
	btn.Size = UDim2.new(0.3,0,0,35)
	btn.Position = UDim2.new((i-1)*0.33+0.02,0,0,10)
	btn.Text = name
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
	tabs[name] = btn
	
	local page = Instance.new("Frame",main)
	page.Size = UDim2.new(1,-20,1,-60)
	page.Position = UDim2.new(0,10,0,50)
	page.BackgroundTransparency = 1
	page.Visible = (i==1)
	pages[name] = page
	
	btn.MouseButton1Click:Connect(function()
		for _,p in pairs(pages) do p.Visible = false end
		page.Visible = true
	end)
end

-------------------------------------------------
-- TOGGLE CREATOR
-------------------------------------------------
local function createToggle(parent,text,y,callback)
	local b = Instance.new("TextButton",parent)
	b.Size = UDim2.new(0.9,0,0,40)
	b.Position = UDim2.new(0.05,0,0,y)
	b.Text = text.." : OFF"
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
	
	local state = false
	
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = text.." : "..(state and "ON" or "OFF")
		callback(state)
	end)
end

-------------------------------------------------
-- COMBAT TAB
-------------------------------------------------
createToggle(pages["Combat"],"Aim Assist",0,function(v) aimAssist=v end)
createToggle(pages["Combat"],"Trigger Indicator",50,function(v) triggerIndicator=v end)
createToggle(pages["Combat"],"Team Check",100,function(v) teamCheck=v end)

-------------------------------------------------
-- VISUAL TAB
-------------------------------------------------
createToggle(pages["Visual"],"ESP",0,function(v) espEnabled=v end)

-------------------------------------------------
-- SETTINGS TAB SLIDER (SMOOTHNESS)
-------------------------------------------------
local function createSlider(parent,text,y,min,max,default,callback)
	local frame = Instance.new("Frame",parent)
	frame.Size = UDim2.new(0.9,0,0,60)
	frame.Position = UDim2.new(0.05,0,0,y)
	frame.BackgroundTransparency = 1
	
	local label = Instance.new("TextLabel",frame)
	label.Size = UDim2.new(1,0,0,20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true
	
	local bar = Instance.new("Frame",frame)
	bar.Size = UDim2.new(1,0,0,6)
	bar.Position = UDim2.new(0,0,0.7,0)
	bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
	
	local fill = Instance.new("Frame",bar)
	fill.BackgroundColor3 = UI_COLOR
	
	local knob = Instance.new("Frame",bar)
	knob.Size = UDim2.new(0,14,0,14)
	knob.AnchorPoint = Vector2.new(0.5,0.5)
	knob.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
	
	local dragging=false
	
	local function update(percent)
		fill.Size = UDim2.new(percent,0,1,0)
		knob.Position = UDim2.new(percent,0,0.5,0)
		local value = min + (max-min)*percent
		label.Text = text.." : "..math.floor(value*100)/100
		callback(value)
	end
	
	update((default-min)/(max-min))
	
	knob.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1
		or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true
		end
	end)
	
	UIS.InputEnded:Connect(function() dragging=false end)
	
	UIS.InputChanged:Connect(function(input)
		if dragging then
			local percent = math.clamp(
				(input.Position.X - bar.AbsolutePosition.X) /
				bar.AbsoluteSize.X,
			0,1)
			update(percent)
		end
	end)
end

createSlider(pages["Settings"],"Smoothness",0,0.05,0.5,SMOOTHNESS,function(v)
	SMOOTHNESS=v
end)

createSlider(pages["Settings"],"UI Hue",80,0,360,180,function(v)
	UI_COLOR = Color3.fromHSV(v/360,1,1)
	mainStroke.Color=UI_COLOR
	openStroke.Color=UI_COLOR
end)

createToggle(pages["Settings"],"RGB Mode",160,function(v) rgbMode=v end)

-------------------------------------------------
-- OPEN CLOSE ANIMATION
-------------------------------------------------
openButton.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
	
	if main.Visible then
		main.Size = UDim2.new(0,0,0,0)
		TweenService:Create(main,TweenInfo.new(0.3,Enum.EasingStyle.Back),
			{Size=UDim2.new(0,350,0,480)}):Play()
		TweenService:Create(blur,TweenInfo.new(0.3),{Size=15}):Play()
	else
		TweenService:Create(blur,TweenInfo.new(0.3),{Size=0}):Play()
	end
end)

-------------------------------------------------
-- RGB ANIMATION
-------------------------------------------------
RunService.RenderStepped:Connect(function()
	if rgbMode then
		local t = tick()%5/5
		UI_COLOR = Color3.fromHSV(t,1,1)
		mainStroke.Color=UI_COLOR
		openStroke.Color=UI_COLOR
	end
end)
