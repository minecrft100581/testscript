--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--====================================================
-- DEVICE CHECK
--====================================================
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

--====================================================
-- SETTINGS (슬라이더 연동값)
--====================================================
local SETTINGS = {
	Enabled = false,
	Trigger = false,
	FOV = 120,
	Smoothness = 5,
	Distance = 300
}

--====================================================
-- GUI ROOT
--====================================================
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--====================================================
-- BLUR
--====================================================
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

--====================================================
-- OPEN BUTTON
--====================================================
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = isMobile and UDim2.new(0,100,0,35) or UDim2.new(0,140,0,45)
openBtn.Position = UDim2.new(0.5,-openBtn.Size.X.Offset/2,0.05,0)
openBtn.Text = "OPEN"
openBtn.BackgroundColor3 = Color3.fromRGB(120,170,255)
openBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",openBtn).CornerRadius = UDim.new(0,12)

-- Drag support
local dragging, dragStart, startPos
openBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = openBtn.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
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
-- MAIN WINDOW
--====================================================
local main = Instance.new("Frame", gui)
main.Size = isMobile and UDim2.new(0.9,0,0.75,0) or UDim2.new(0.8,0,0.75,0)
main.Position = UDim2.new(0.1,0,0.12,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,35)
main.Visible = false
Instance.new("UICorner",main).CornerRadius = UDim.new(0,16)

--====================================================
-- SCROLL
--====================================================
local scroll = Instance.new("ScrollingFrame", main)
scroll.Position = UDim2.new(0,10,0,10)
scroll.Size = UDim2.new(1,-20,1,-20)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,12)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

--====================================================
-- TOGGLE
--====================================================
local function createToggle(text,settingKey)
	local state = SETTINGS[settingKey]

	local frame = Instance.new("Frame",scroll)
	frame.Size = UDim2.new(1,0,0,60)
	frame.BackgroundColor3 = Color3.fromRGB(40,40,60)
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
	button.Text = state and "ON" or "OFF"
	button.BackgroundColor3 = state and Color3.fromRGB(120,170,255)
		or Color3.fromRGB(90,90,90)
	button.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",button).CornerRadius = UDim.new(0,10)

	button.MouseButton1Click:Connect(function()
		state = not state
		SETTINGS[settingKey] = state
		button.Text = state and "ON" or "OFF"
		button.BackgroundColor3 = state and Color3.fromRGB(120,170,255)
			or Color3.fromRGB(90,90,90)
	end)
end

--====================================================
-- SLIDER
--====================================================
local function createSlider(text,min,max,settingKey)
	local value = SETTINGS[settingKey]

	local frame = Instance.new("Frame",scroll)
	frame.Size = UDim2.new(1,0,0,80)
	frame.BackgroundColor3 = Color3.fromRGB(40,40,60)
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
		if draggingSlider then
			local percent = math.clamp(
				(input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
				0,1
			)
			value = math.floor(min + (max-min)*percent)
			SETTINGS[settingKey] = value
			fill.Size = UDim2.new(percent,0,1,0)
			label.Text = text.." : "..value
		end
	end)
end

--====================================================
-- UI 생성
--====================================================
createToggle("Enable System","Enabled")
createToggle("Trigger Bot","Trigger")
createSlider("FOV Size",50,300,"FOV")
createSlider("Smoothness",1,20,"Smoothness")
createSlider("Distance Limit",50,1000,"Distance")

--====================================================
-- OPEN LOGIC
--====================================================
local opened = false
openBtn.MouseButton1Click:Connect(function()
	opened = not opened
	main.Visible = opened
	openBtn.Text = opened and "CLOSE" or "OPEN"
	TweenService:Create(blur,TweenInfo.new(0.3),{
		Size = opened and 15 or 0
	}):Play()
end)

--====================================================
-- FOV CIRCLE
--====================================================
local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(120,170,255)
circle.Thickness = 2
circle.Filled = false
circle.Visible = true

--====================================================
-- AIM SYSTEM (부드러운 보간)
--====================================================
RunService.RenderStepped:Connect(function()
	circle.Position = Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
	circle.Radius = SETTINGS.FOV

	if not SETTINGS.Enabled then return end

	local closest
	local shortest = SETTINGS.FOV

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = plr.Character.HumanoidRootPart
			local pos,visible = camera:WorldToViewportPoint(hrp.Position)
			if visible then
				local dist2D = (Vector2.new(pos.X,pos.Y) - circle.Position).Magnitude
				local dist3D = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
				if dist2D < shortest and dist3D <= SETTINGS.Distance then
					shortest = dist2D
					closest = hrp
				end
			end
		end
	end

	if closest then
		local targetCF = CFrame.new(camera.CFrame.Position, closest.Position)
		camera.CFrame = camera.CFrame:Lerp(targetCF, SETTINGS.Smoothness/100)

		if SETTINGS.Trigger then
			mouse1press()
			task.wait()
			mouse1release()
		end
	end
end)
