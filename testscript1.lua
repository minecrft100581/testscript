--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

--====================================================
-- ROOT GUI
--====================================================
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--====================================================
-- OPEN BUTTON (중앙 상단 + 드래그 가능)
--====================================================
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,140,0,45)
openBtn.Position = UDim2.new(0.5,-70,0.05,0)
openBtn.Text = "OPEN UI"
openBtn.BackgroundColor3 = Color3.fromRGB(120,170,255)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.AutoButtonColor = false
Instance.new("UICorner",openBtn).CornerRadius = UDim.new(0,12)

-- 드래그 (모바일 포함)
local dragging = false
local dragStart
local startPos

openBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = openBtn.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local delta = input.Position - dragStart
		openBtn.Position = UDim2.new(
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
-- BLUR
--====================================================
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

--====================================================
-- MAIN WINDOW
--====================================================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0.85,0,0.8,0)
main.Position = UDim2.new(0.075,0,0.1,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,35)
main.Visible = false
main.BorderSizePixel = 0
Instance.new("UICorner",main).CornerRadius = UDim.new(0,16)

--====================================================
-- CLOSE BUTTON
--====================================================
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0,40,0,35)
closeBtn.Position = UDim2.new(1,-45,0,5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",closeBtn).CornerRadius = UDim.new(0,8)

--====================================================
-- SCROLL AREA
--====================================================
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-20,1,-50)
scroll.Position = UDim2.new(0,10,0,45)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,12)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

--====================================================
-- COMPONENTS
--====================================================
local function createToggle(text)
	local state = false

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,60)
	frame.BackgroundColor3 = Color3.fromRGB(40,40,60)
	frame.BorderSizePixel = 0
	Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)

	local label = Instance.new("TextLabel",frame)
	label.Size = UDim2.new(0.65,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.TextColor3 = Color3.new(1,1,1)

	local button = Instance.new("TextButton",frame)
	button.Size = UDim2.new(0.25,0,0.65,0)
	button.Position = UDim2.new(0.7,0,0.175,0)
	button.Text = "OFF"
	button.BackgroundColor3 = Color3.fromRGB(90,90,90)
	button.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",button).CornerRadius = UDim.new(0,10)

	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = state and "ON" or "OFF"
		button.BackgroundColor3 = state and Color3.fromRGB(120,170,255)
			or Color3.fromRGB(90,90,90)
	end)

	frame.Parent = scroll
end

local function createSlider(text,min,max,default)
	local value = default

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,80)
	frame.BackgroundColor3 = Color3.fromRGB(40,40,60)
	frame.BorderSizePixel = 0
	Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)

	local label = Instance.new("TextLabel",frame)
	label.Size = UDim2.new(1,0,0.4,0)
	label.BackgroundTransparency = 1
	label.Text = text.." : "..value
	label.TextScaled = true
	label.TextColor3 = Color3.new(1,1,1)

	local bar = Instance.new("Frame",frame)
	bar.Size = UDim2.new(0.9,0,0,12)
	bar.Position = UDim2.new(0.05,0,0.65,0)
	bar.BackgroundColor3 = Color3.fromRGB(70,70,90)
	Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

	local fill = Instance.new("Frame",bar)
	fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(120,170,255)
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

	frame.Parent = scroll
end

--====================================================
-- 예시 기능들
--====================================================
createToggle("Enable System")
createToggle("Trigger Mode")
createSlider("FOV Size",50,300,120)
createSlider("Smoothness",1,20,5)
createSlider("Distance Limit",50,1000,300)

--====================================================
-- OPEN / CLOSE LOGIC
--====================================================
local opened = false

openBtn.MouseButton1Click:Connect(function()
	opened = not opened
	main.Visible = opened
	openBtn.Text = opened and "CLOSE UI" or "OPEN UI"
	TweenService:Create(blur,TweenInfo.new(0.3),{
		Size = opened and 15 or 0
	}):Play()
end)

--====================================================
-- BLACK HOLE CLOSE
--====================================================
closeBtn.MouseButton1Click:Connect(function()
	local hole = Instance.new("Frame", gui)
	hole.Size = UDim2.new(0,10,0,10)
	hole.Position = UDim2.new(0.5,0,0.5,0)
	hole.AnchorPoint = Vector2.new(0.5,0.5)
	hole.BackgroundColor3 = Color3.new(0,0,0)
	Instance.new("UICorner",hole).CornerRadius = UDim.new(1,0)

	TweenService:Create(hole,TweenInfo.new(0.6),{
		Size = UDim2.new(2,0,2,0)
	}):Play()

	task.wait(0.6)
	gui:Destroy()
end)
