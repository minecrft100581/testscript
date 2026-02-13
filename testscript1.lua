--====================================================
-- SERVICES
--====================================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--====================================================
-- SETTINGS
--====================================================
local SETTINGS = {
	Aimbot = false,
	ESP = false,
	FOV = 150,
	Smoothness = 0.15
}

--====================================================
-- GUI ROOT
--====================================================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--====================================================
-- BLUR
--====================================================
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

--====================================================
-- DRAG FUNCTION (재사용용)
--====================================================
local function makeDraggable(frame, handle)

	local dragging = false
	local dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
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

	UIS.InputEnded:Connect(function()
		dragging = false
	end)
end

--====================================================
-- OPEN BUTTON (처음엔 이것만 보임)
--====================================================
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,150,0,45)
openBtn.Position = UDim2.new(0.5,-75,0.05,0)
openBtn.Text = "Open Program"
openBtn.BackgroundColor3 = Color3.fromRGB(120,170,255)
openBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",openBtn).CornerRadius = UDim.new(0,12)

makeDraggable(openBtn, openBtn)

--====================================================
-- MAIN PROGRAM WINDOW
--====================================================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,430,0,460)
main.Position = UDim2.new(0.5,-215,0.5,-230)
main.BackgroundColor3 = Color3.fromRGB(22,22,32)
main.Visible = false
main.BorderSizePixel = 0
Instance.new("UICorner",main).CornerRadius = UDim.new(0,14)

--====================================================
-- TITLE BAR
--====================================================
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundColor3 = Color3.fromRGB(30,30,45)
titleBar.BorderSizePixel = 0

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Control Program"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

makeDraggable(main, titleBar)

--====================================================
-- CLOSE BUTTON
--====================================================
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,35,0,28)
closeBtn.Position = UDim2.new(1,-40,0,6)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(170,60,60)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner",closeBtn).CornerRadius = UDim.new(0,6)

--====================================================
-- SCROLL AREA
--====================================================
local scroll = Instance.new("ScrollingFrame", main)
scroll.Position = UDim2.new(0,10,0,50)
scroll.Size = UDim2.new(1,-20,1,-60)
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
-- UI COMPONENTS
--====================================================
local function createToggle(text,key)

	local frame = Instance.new("Frame",scroll)
	frame.Size = UDim2.new(1,0,0,55)
	frame.BackgroundColor3 = Color3.fromRGB(35,35,55)
	Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

	local label = Instance.new("TextLabel",frame)
	label.Size = UDim2.new(0.6,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true

	local btn = Instance.new("TextButton",frame)
	btn.Size = UDim2.new(0.3,0,0.65,0)
	btn.Position = UDim2.new(0.65,0,0.175,0)
	btn.Text = "OFF"
	btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)

	btn.MouseButton1Click:Connect(function()
		SETTINGS[key] = not SETTINGS[key]
		btn.Text = SETTINGS[key] and "ON" or "OFF"
		btn.BackgroundColor3 = SETTINGS[key]
			and Color3.fromRGB(120,170,255)
			or Color3.fromRGB(80,80,80)
	end)
end

local function createSlider(text,key,min,max)

	local frame = Instance.new("Frame",scroll)
	frame.Size = UDim2.new(1,0,0,75)
	frame.BackgroundColor3 = Color3.fromRGB(35,35,55)
	Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

	local label = Instance.new("TextLabel",frame)
	label.Size = UDim2.new(1,0,0.4,0)
	label.BackgroundTransparency = 1
	label.Text = text.." : "..SETTINGS[key]
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true

	local bar = Instance.new("Frame",frame)
	bar.Size = UDim2.new(0.9,0,0,10)
	bar.Position = UDim2.new(0.05,0,0.65,0)
	bar.BackgroundColor3 = Color3.fromRGB(70,70,90)
	Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

	local fill = Instance.new("Frame",bar)
	fill.Size = UDim2.new((SETTINGS[key]-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(120,170,255)
	Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

	local dragging = false

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	UIS.InputEnded:Connect(function()
		dragging = false
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local percent = math.clamp(
				(input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
				0,1
			)
			SETTINGS[key] = math.floor(min + (max-min)*percent)
			fill.Size = UDim2.new(percent,0,1,0)
			label.Text = text.." : "..SETTINGS[key]
		end
	end)
end

-- 생성
createToggle("Aimbot","Aimbot")
createToggle("ESP","ESP")
createSlider("FOV","FOV",50,400)

--====================================================
-- OPEN / CLOSE LOGIC
--====================================================
local opened = false

openBtn.MouseButton1Click:Connect(function()
	opened = not opened
	main.Visible = opened
	blur.Size = opened and 12 or 0
	openBtn.Text = opened and "Close Program" or "Open Program"
end)

closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	blur.Size = 0
	openBtn.Text = "Open Program"
	opened = false
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
-- ESP STORAGE
--====================================================
local esp = {}

local function addESP(plr)
	local text = Drawing.new("Text")
	text.Size = 13
	text.Center = true
	text.Outline = true
	text.Visible = false
	esp[plr] = text
end

for _,p in pairs(Players:GetPlayers()) do
	if p ~= player then addESP(p) end
end

Players.PlayerAdded:Connect(function(p)
	if p ~= player then addESP(p) end
end)

Players.PlayerRemoving:Connect(function(p)
	if esp[p] then
		esp[p]:Remove()
	end
end)

--====================================================
-- MAIN LOOP
--====================================================
RunService.RenderStepped:Connect(function()

	circle.Position = Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
	circle.Radius = SETTINGS.FOV

	local closest
	local shortest = SETTINGS.FOV

	for plr,obj in pairs(esp) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

			local hrp = plr.Character.HumanoidRootPart
			local pos,visible = camera:WorldToViewportPoint(hrp.Position)

			if SETTINGS.ESP and visible and plr.Team ~= player.Team then
				obj.Visible = true
				obj.Position = Vector2.new(pos.X,pos.Y)
				obj.Text = plr.Name
			else
				obj.Visible = false
			end

			if SETTINGS.Aimbot and visible and plr.Team ~= player.Team then
				local dist = (Vector2.new(pos.X,pos.Y) - circle.Position).Magnitude
				if dist < shortest then
					shortest = dist
					closest = hrp
				end
			end
		end
	end

	if SETTINGS.Aimbot and closest then
		local target = CFrame.new(camera.CFrame.Position, closest.Position)
		camera.CFrame = camera.CFrame:Lerp(target, SETTINGS.Smoothness)
	end
end)
