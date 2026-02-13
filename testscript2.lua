--// =========================
--// SERVICES
--// =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// =========================
--// SAFE CAMERA LOAD
--// =========================

local function GetCamera()
    local cam = workspace.CurrentCamera
    while not cam do
        workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
        cam = workspace.CurrentCamera
    end
    return cam
end

local Camera = GetCamera()

--// =========================
--// SAFE HTTP LOADER (Executor 유사 환경 대응)
--// =========================

local function httpGet(url)
    if game.HttpGet then
        return game:HttpGet(url)
    elseif syn and syn.request then
        return syn.request({Url=url, Method="GET"}).Body
    elseif http_request then
        return http_request({Url=url, Method="GET"}).Body
    elseif request then
        return request({Url=url, Method="GET"}).Body
    else
        error("No HTTP method available")
    end
end

--// =========================
--// SAFE LUNA LOAD
--// =========================

local Luna
local ok, err = pcall(function()
    Luna = loadstring(httpGet("https://raw.nebulasoftworks.xyz/luna"))()
end)

if not ok or not Luna then
    warn("Luna Load Failed:", err)
    return
end

--// =========================
--// SETTINGS
--// =========================

local Settings = {
    Aimbot = false,
    AimPart = "Head",
    Smoothness = 0.15,
    FOV = 150,

    FOVColor = Color3.fromRGB(255,255,255),
    FOVRainbow = false,

    TeamCheck = false,
    VisibleCheck = false,
    WallCheck = false
}

--// =========================
--// UI
--// =========================

local Window = Luna:CreateWindow({
    Name = "Program UI",
    Subtitle = "Integrated System",
    KeySystem = false
})

local MainTab = Window:CreateTab("Main")

MainTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(v)
        Settings.Aimbot = v
    end
})

MainTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head","HumanoidRootPart"},
    CurrentOption = "Head",
    Callback = function(v)
        Settings.AimPart = v
    end
})

MainTab:CreateSlider({
    Name = "Smoothness",
    Range = {0.01,1},
    Increment = 0.01,
    CurrentValue = 0.15,
    Callback = function(v)
        Settings.Smoothness = v
    end
})

MainTab:CreateSlider({
    Name = "FOV Size",
    Range = {50,500},
    Increment = 1,
    CurrentValue = 150,
    Callback = function(v)
        Settings.FOV = v
    end
})

MainTab:CreateColorPicker({
    Name = "FOV Color",
    Color = Settings.FOVColor,
    Callback = function(v)
        Settings.FOVColor = v
    end
})

MainTab:CreateToggle({
    Name = "FOV Rainbow",
    CurrentValue = false,
    Callback = function(v)
        Settings.FOVRainbow = v
    end
})

MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Callback = function(v)
        Settings.TeamCheck = v
    end
})

MainTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = false,
    Callback = function(v)
        Settings.VisibleCheck = v
    end
})

--// =========================
--// FOV GUI (Drawing 제거)
--// =========================

local FOVGui = Instance.new("ScreenGui")
FOVGui.ResetOnSpawn = false
FOVGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = FOVGui

local UICorner = Instance.new("UICorner", FOVCircle)
UICorner.CornerRadius = UDim.new(1,0)

local UIStroke = Instance.new("UIStroke", FOVCircle)
UIStroke.Thickness = 2
UIStroke.Color = Settings.FOVColor

--// =========================
--// SAFE MOUSE POSITION
--// =========================

local function GetMousePos()
    if UIS.TouchEnabled then
        local v = Camera.ViewportSize
        return Vector2.new(v.X/2, v.Y/2)
    else
        return UIS:GetMouseLocation()
    end
end

--// =========================
--// VISIBILITY CHECK
--// =========================

local function IsVisible(part)
    if not Settings.VisibleCheck then return true end
    if not part or not part.Parent then return false end
    if not LocalPlayer.Character then return false end

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, params)

    if result and not result.Instance:IsDescendantOf(part.Parent) then
        return false
    end

    return true
end

--// =========================
--// TARGET FINDER
--// =========================

local function GetClosestTarget()
    local closest = nil
    local shortest = Settings.FOV
    local mousePos = GetMousePos()

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local char = player.Character
            if not char then continue end

            local part = char:FindFirstChild(Settings.AimPart)
            if not part then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end

            local dist = (Vector2.new(screenPos.X,screenPos.Y) - mousePos).Magnitude

            if dist < shortest and IsVisible(part) then
                shortest = dist
                closest = part
            end
        end
    end

    return closest
end

--// =========================
--// MAIN LOOP
--// =========================

RunService.RenderStepped:Connect(function()

    -- Rainbow
    local hue = tick() % 5 / 5
    local rainbow = Color3.fromHSV(hue,1,1)

    if Settings.FOVRainbow then
        UIStroke.Color = rainbow
    else
        UIStroke.Color = Settings.FOVColor
    end

    -- FOV 위치/크기
    local mousePos = GetMousePos()
    FOVCircle.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
    FOVCircle.Size = UDim2.fromOffset(Settings.FOV*2, Settings.FOV*2)

    -- Aimbot
    if Settings.Aimbot then
        local target = GetClosestTarget()
        if target then
            local newCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(newCF, Settings.Smoothness)
        end
    end

end)
