--// =========================
--// SERVICES
--// =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

--// =========================
--// SETTINGS
--// =========================

local Settings = {
    Aimbot = false,
    ESP = false,

    AimPart = "Head",
    ESPMode = "Box",

    Smoothness = 0.15,
    FOV = 150,

    ESPColor = Color3.fromRGB(255,0,0),
    FOVColor = Color3.fromRGB(255,255,255),

    ESPRainbow = false,
    FOVRainbow = false,

    TeamCheck = false,
    VisibleCheck = false,
    WallCheck = false
}

--// =========================
--// LUNA UI
--// =========================

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Luna/main/source.lua"))()

local Window = Luna:CreateWindow({
    Name = "Program UI",
    Subtitle = "Integrated System",
    KeySystem = false
})

local MainTab = Window:CreateTab("Main")

-- Aimbot
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

-- FOV
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

-- ESP
MainTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.ESP = v
    end
})

MainTab:CreateDropdown({
    Name = "ESP Mode",
    Options = {"Box","Skeleton"},
    CurrentOption = "Box",
    Callback = function(v)
        Settings.ESPMode = v
    end
})

MainTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Settings.ESPColor,
    Callback = function(v)
        Settings.ESPColor = v
    end
})

MainTab:CreateToggle({
    Name = "ESP Rainbow",
    CurrentValue = false,
    Callback = function(v)
        Settings.ESPRainbow = v
    end
})

-- General
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

MainTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Callback = function(v)
        Settings.WallCheck = v
    end
})

--// =========================
--// FOV CIRCLE
--// =========================

local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Visible = true

--// =========================
--// VISIBILITY CHECK
--// =========================

local function IsVisible(part)
    if not Settings.VisibleCheck then return true end
    if not part or not part.Parent then return false end

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)

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
    local mousePos = UIS:GetMouseLocation()

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            local char = player.Character
            if not char then continue end
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

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
--// RENDER LOOP
--// =========================

RunService.RenderStepped:Connect(function()

    -- Rainbow
    local hue = tick() % 5 / 5
    local rainbow = Color3.fromHSV(hue,1,1)

    if Settings.FOVRainbow then
        FOVCircle.Color = rainbow
    else
        FOVCircle.Color = Settings.FOVColor
    end

    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = Settings.FOV

    -- Aimbot
    if Settings.Aimbot then
        local target = GetClosestTarget()
        if target then
            local cf = Camera.CFrame
            local newCF = CFrame.new(cf.Position, target.Position)
            Camera.CFrame = cf:Lerp(newCF, Settings.Smoothness)
        end
    end

end)
