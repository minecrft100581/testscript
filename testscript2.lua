--// =========================
--// SERVICES
--// =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// =========================
--// SAFE CAMERA
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
--// LOAD UI LIB
--// =========================

local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna"))()

local Window = Luna:CreateWindow({
    Name = "Real Cheat Simulator",
    Subtitle = "99.99% Realism",
    LogoID = "rbxassetid://7733960981",
    LoadingEnabled = false,
})

local Tabs = {
    Main = Window:CreateTab({ Name = "Main" }),
    Visual = Window:CreateTab({ Name = "Visual" }),
    Combat = Window:CreateTab({ Name = "Combat" }),
}

--// =========================
--// SETTINGS
--// =========================

local Settings = {

    Aimbot = false,
    Ragebot = false,
    SilentAim = false,

    AimPart = "Head",
    Smoothness = 0.18,
    FOV = 150,
    RageFOV = 300,

    MaxDistance = 1000,

    TeamCheck = false,
    VisibleCheck = false,

    ESP = false,
    ESPColor = Color3.fromRGB(255,0,0),

    FOVColor = Color3.fromRGB(255,255,255),
    FOVRainbow = false,

    HitChance = 100,

    AutoHeadshot = true,
    HeadshotDistance = 250,

    -- Humanized
    Humanize = false,
    HumanizeStrength = 0.55,
    ReactionTime = 0.07,

    -- Recoil
    RecoilControl = false,
    RecoilStrength = 0.65,
    RecoilRandom = 0.25,
}

--// =========================
--// UI
--// =========================

Tabs.Main:CreateToggle({
    Name = "Enable Aimbot",
    Callback = function(v) Settings.Aimbot = v end
})

Tabs.Main:CreateToggle({
    Name = "Enable Ragebot",
    Callback = function(v) Settings.Ragebot = v end
})

Tabs.Main:CreateToggle({
    Name = "Silent Aim",
    Callback = function(v) Settings.SilentAim = v end
})

Tabs.Main:CreateSlider({
    Name = "Smoothness",
    Range = {0.01,1},
    Increment = 0.01,
    CurrentValue = Settings.Smoothness,
    Callback = function(v) Settings.Smoothness = v end
})

Tabs.Main:CreateSlider({
    Name = "FOV",
    Range = {50,500},
    Increment = 1,
    CurrentValue = Settings.FOV,
    Callback = function(v) Settings.FOV = v end
})

Tabs.Visual:CreateToggle({
    Name = "ESP",
    Callback = function(v) Settings.ESP = v end
})

Tabs.Visual:CreateColorPicker({
    Name = "ESP Color",
    Color = Settings.ESPColor,
    Callback = function(v) Settings.ESPColor = v end
})

Tabs.Visual:CreateToggle({
    Name = "FOV Rainbow",
    Callback = function(v) Settings.FOVRainbow = v end
})

Tabs.Combat:CreateToggle({
    Name = "Humanized Aim",
    Callback = function(v) Settings.Humanize = v end
})

Tabs.Combat:CreateToggle({
    Name = "Recoil Control",
    Callback = function(v) Settings.RecoilControl = v end
})

Tabs.Combat:CreateSlider({
    Name = "Hit Chance",
    Range = {0,100},
    Increment = 1,
    CurrentValue = Settings.HitChance,
    Callback = function(v) Settings.HitChance = v end
})

--// =========================
--// FOV GUI
--// =========================

local FOVGui = Instance.new("ScreenGui")
FOVGui.ResetOnSpawn = false
FOVGui.Parent = CoreGui

local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = FOVGui

local UICorner = Instance.new("UICorner", FOVCircle)
UICorner.CornerRadius = UDim.new(1,0)

local UIStroke = Instance.new("UIStroke", FOVCircle)
UIStroke.Thickness = 2

--// =========================
--// AIM POSITION
--// =========================

local function GetAimPosition()
    return UIS:GetMouseLocation()
end

--// =========================
--// ESP
--// =========================

local ESPContainer = {}

local function RemoveESP(player)
    if ESPContainer[player] then
        ESPContainer[player]:Destroy()
        ESPContainer[player] = nil
    end
end

local function CreateESP(player, char)
    RemoveESP(player)

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.5
    hl.Parent = char

    ESPContainer[player] = hl
end

local function UpdateESP()

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local char = player.Character
        if not char then continue end

        if Settings.ESP then

            if not ESPContainer[player] then
                CreateESP(player, char)
            end

            local hl = ESPContainer[player]

            if hl then
                hl.FillColor = Settings.ESPColor
                hl.OutlineColor = Settings.ESPColor
                hl.Enabled = true
            end

        else
            RemoveESP(player)
        end
    end
end

--// =========================
--// TARGET HELPERS
--// =========================

local function GetBestPart(char)
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function GetClosestTarget()

    local closest
    local shortest = Settings.FOV
    local center = GetAimPosition()

    for _, player in ipairs(Players:GetPlayers()) do

        if player == LocalPlayer then continue end

        local char = player.Character
        if not char then continue end

        local part = GetBestPart(char)
        if not part then continue end

        local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude

        if dist < shortest then
            shortest = dist
            closest = part
        end
    end

    return closest
end

--// =========================
--// HUMANIZED AIM
--// =========================

local LastAim = 0

local function ApplyHuman(targetCF, smooth)

    if not Settings.Humanize then
        return Camera.CFrame:Lerp(targetCF, smooth)
    end

    if tick() - LastAim < Settings.ReactionTime then
        return Camera.CFrame
    end

    LastAim = tick()

    local strength = Settings.HumanizeStrength

    local ox = (math.random()-0.5)*0.02*strength
    local oy = (math.random()-0.5)*0.02*strength

    local offset = CFrame.Angles(oy, ox, 0)

    return Camera.CFrame:Lerp(targetCF*offset, smooth)
end

--// =========================
--// RECOIL
--// =========================

local LastCF = Camera.CFrame

local function ApplyRecoil()

    if not Settings.RecoilControl then
        LastCF = Camera.CFrame
        return
    end

    local delta = LastCF:ToObjectSpace(Camera.CFrame)
    local rx, ry = delta:ToOrientation()

    local comp = CFrame.Angles(
        -rx * Settings.RecoilStrength,
        -ry * Settings.RecoilStrength,
        0
    )

    Camera.CFrame *= comp
    LastCF = Camera.CFrame
end

--// =========================
--// SILENT AIM
--// =========================

pcall(function()

    local Mouse = LocalPlayer:GetMouse()

    local Old
    Old = hookmetamethod(game, "__index", function(self, key)

        if self == Mouse and key == "Hit" and Settings.SilentAim then

            local target = GetClosestTarget()

            if target and math.random(0,100) <= Settings.HitChance then
                return target.CFrame
            end
        end

        return Old(self, key)
    end)

end)

--// =========================
--// MAIN LOOP
--// =========================

RunService.RenderStepped:Connect(function()

    UpdateESP()

    local hue = tick()%5/5
    local rainbow = Color3.fromHSV(hue,1,1)

    UIStroke.Color = Settings.FOVRainbow and rainbow or Settings.FOVColor

    local aimPos = GetAimPosition()

    FOVCircle.Position = UDim2.fromOffset(aimPos.X, aimPos.Y)
    FOVCircle.Size = UDim2.fromOffset(Settings.FOV*2, Settings.FOV*2)

    local target

    if Settings.Ragebot then
        target = GetClosestTarget()
    elseif Settings.Aimbot then
        target = GetClosestTarget()
    end

    if target then
        local cf = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = ApplyHuman(cf, Settings.Smoothness)
    end

    ApplyRecoil()

end)
