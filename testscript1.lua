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
gui.Name = "ProgramUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

--====================================================
-- START WHITE FADE (위 → 아래)
--====================================================
local fade = Instance.new("Frame", gui)
fade.Size = UDim2.new(1,0,1,0)
fade.Position = UDim2.new(0,0,-1,0)
fade.BackgroundColor3 = Color3.new(1,1,1)
fade.BorderSizePixel = 0
fade.ZIndex = 100

TweenService:Create(fade, TweenInfo.new(0.6), {
	Position = UDim2.new(0,0,0,0)
}):Play()

task.wait(0.6)

TweenService:Create(fade, TweenInfo.new(0.4), {
	BackgroundTransparency = 1
}):Play()

task.wait(0.4)
fade:Destroy()

--====================================================
-- BLUR (중복 방지)
--====================================================
local existingBlur = Lighting:FindFirstChild("ProgramBlur")
if existingBlur then
	existingBlur:Destroy()
end

local blur = Instance.new("BlurEffect")
blur.Name = "ProgramBlur"
blur.Size = 15
blur.Parent = Lighting

--====================================================
-- MAIN WINDOW
--====================================================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,600,0,380)
main.Position = UDim2.new(0.5,-300,0.5,-190)
main.BackgroundColor3 = Color3.fromRGB(25,25,35)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

--====================================================
-- TITLE BAR
--====================================================
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundColor3 = Color3.fromRGB(35,35,50)
titleBar.BorderSizePixel = 0

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "Program UI"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

--====================================================
-- DRAG SYSTEM (모바일 안정)
--====================================================
local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
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

--====================================================
-- CLOSE BUTTON
--====================================================
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,34,0,30)
closeBtn.Position = UDim2.new(1,-40,0,5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(160,40,40)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

--====================================================
-- BLACK HOLE CLOSE
--====================================================
local function blackHoleClose()

	local hole = Instance.new("Frame", gui)
	hole.Size = UDim2.new(0,10,0,10)
	hole.Position = UDim2.new(0.5,0,0.5,0)
	hole.AnchorPoint = Vector2.new(0.5,0.5)
	hole.BackgroundColor3 = Color3.new(0,0,0)
	hole.ZIndex = 200
	Instance.new("UICorner", hole).CornerRadius = UDim.new(1,0)

	TweenService:Create(hole, TweenInfo.new(0.6), {
		Size = UDim2.new(2,0,2,0)
	}):Play()

	task.wait(0.3)

	TweenService:Create(main, TweenInfo.new(0.4), {
		Size = UDim2.new(0,0,0,0),
		Position = UDim2.new(0.5,0,0.5,0)
	}):Play()

	task.wait(0.6)

	if blur then blur:Destroy() end
	gui:Destroy()
end

closeBtn.MouseButton1Click:Connect(blackHoleClose)
