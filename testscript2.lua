--// =========================
--// SERVICES
--// =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// =========================
--// LOAD LUNA
--// =========================

local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna"))()

local Window = Luna:CreateWindow({
    Name = "Real Cheat Simulator",
    Subtitle = "99% Realism",
    LogoID = "rbxassetid://0",
    LoadingEnabled = true,
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Please wait"
})

local Tabs = {
    Main = Window:CreateTab({
        Name = "Main",
        Icon = "home"
    })
}


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
--// SETTINGS
--// =========================

local Settings = {

    -- Legit
    Aimbot = false,
    AimPart = "Head",
    Smoothness = 0.18,
    FOV = 150,
    MaxDistance = 1000,

    FOVColor = Color3.fromRGB(255,255,255),
    FOVRainbow = false,

    -- ESP
    ESP = false,
    ESPColor = Color3.fromRGB(255,0,0),

    TeamCheck = false,
    VisibleCheck = false,

    -- Rage
    Ragebot = false,
    RageFOV = 300,

    AutoHeadshot = true,
    HeadshotDistance = 250,

    -- Silent Aim
    SilentAim = false,
    HitChance = 100,

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
--// AIM POSITION
--// =========================

local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local function GetAimPosition()
    if IsMobile then
        local v = Camera.ViewportSize
        return Vector2.new(v.X/2, v.Y/2)
    else
        return UIS:GetMouseLocation()
    end
end

--// =========================
--// FOV GUI
--// =========================

local FOVGui = Instance.new("ScreenGui")
FOVGui.ResetOnSpawn = false
FOVGui.Parent = game:GetService("CoreGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = FOVGui

local UICorner = Instance.new("UICorner", FOVCircle)
UICorner.CornerRadius = UDim.new(1,0)

local UIStroke = Instance.new("UIStroke", FOVCircle)
UIStroke.Thickness = 2

--// =========================
--// ESP SYSTEM (리스폰 대응)
--// =========================

local ESPContainer = {}

local function RemoveESP(player)
    if ESPContainer[player] then
        ESPContainer[player]:Destroy()
        ESPContainer[player] = nil
    end
end

local function CreateESP(player, character)

    RemoveESP(player)

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = character

    ESPContainer[player] = hl
end

local function UpdateESP()

    for _, player in ipairs(Players:GetPlayers()) do

        if player == LocalPlayer then continue end

        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            RemoveESP(player)
            continue
        end

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

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        if Settings.ESP then
            CreateESP(plr, char)
        end
    end)
end)

Players.PlayerRemoving:Connect(RemoveESP)

--// =========================
--// VISIBILITY
--// =========================

local function IsVisible(part)

    if not Settings.VisibleCheck then
        return true
    end

    if not LocalPlayer.Character then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)

    if result and not result.Instance:IsDescendantOf(part.Parent) then
        return false
    end

    return true
end

--// =========================
--// BEST PART
--// =========================

local function GetBestPart(character)

    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not head or not root then return nil end

    local dist = (head.Position - Camera.CFrame.Position).Magnitude

    if Settings.AutoHeadshot then
        if dist <= Settings.HeadshotDistance then
            return head
        else
            return root
        end
    end

    return character:FindFirstChild(Settings.AimPart)
end

--// =========================
--// CLOSEST TARGET
--// =========================

local function GetClosestTarget()

    local closest = nil
    local shortest = Settings.FOV
    local aimPos = GetAimPosition()

    for _, player in ipairs(Players:GetPlayers()) do

        if player == LocalPlayer then continue end

        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            continue
        end

        local char = player.Character
        if not char then continue end

        local root = char:FindFirstChild("HumanoidRootPart")
        local part = char:FindFirstChild(Settings.AimPart)

        if not root or not part then continue end

        local dist3D = (root.Position - Camera.CFrame.Position).Magnitude
        if dist3D > Settings.MaxDistance then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        if not IsVisible(part) then continue end

        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - aimPos).Magnitude

        if dist2D < shortest then
            shortest = dist2D
            closest = part
        end
    end

    return closest
end

--// =========================
--// RAGE TARGET
--// =========================

local function GetRageTarget()

    local closest = nil
    local shortest = Settings.RageFOV
    local center = GetAimPosition()

    for _, player in ipairs(Players:GetPlayers()) do

        if player == LocalPlayer then continue end

        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            continue
        end

        local char = player.Character
        if not char then continue end

        local part = GetBestPart(char)
        if not part then continue end

        if not IsVisible(part) then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

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

local LastAimTime = 0

local function ApplyHumanizedAim(targetCF, smoothness)

    if not Settings.Humanize then
        return Camera.CFrame:Lerp(targetCF, smoothness)
    end

    local now = tick()

    -- Reaction delay
    if now - LastAimTime < Settings.ReactionTime then
        return Camera.CFrame
    end

    LastAimTime = now

    local strength = Settings.HumanizeStrength

    -- micro offset
    local offsetX = (math.random() - 0.5) * 0.02 * strength
    local offsetY = (math.random() - 0.5) * 0.02 * strength

    local offset = CFrame.Angles(offsetY, offsetX, 0)

    local goal = targetCF * offset

    -- dynamic smooth
    local dynamicSmooth = smoothness * (0.5 + math.random() * 0.5)

    return Camera.CFrame:Lerp(goal, dynamicSmooth)
end

--// =========================
--// RECOIL CONTROL
--// =========================

local LastCameraCF = Camera.CFrame

local function ApplyRecoilControl()

    if not Settings.RecoilControl then
        LastCameraCF = Camera.CFrame
        return
    end

    local current = Camera.CFrame
    local delta = LastCameraCF:ToObjectSpace(current)

    local rx, ry, rz = delta:ToOrientation()

    local strength = Settings.RecoilStrength
    local randomFactor = 1 + ((math.random() - 0.5) * Settings.RecoilRandom)

    local compensation = CFrame.Angles(
        -rx * strength * randomFactor,
        -ry * strength * randomFactor,
        0
    )

    Camera.CFrame = Camera.CFrame * compensation

    LastCameraCF = Camera.CFrame
end

--// =========================
--// HIT CHANCE
--// =========================

local function RollHitChance()
    return math.random(0,100) <= Settings.HitChance
end

--// =========================
--// SILENT TARGET
--// =========================

local function GetSilentTarget()

    local closest = nil
    local shortest = Settings.FOV
    local center = GetAimPosition()

    for _, player in ipairs(Players:GetPlayers()) do

        if player == LocalPlayer then continue end

        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            continue
        end

        local char = player.Character
        if not char then continue end

        local part = GetBestPart(char)
        if not part then continue end

        if not IsVisible(part) then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

        if dist < shortest then
            shortest = dist
            closest = part
        end
    end

    return closest
end

--// =========================
--// SILENT AIM HOOK
--// =========================

local Mouse = LocalPlayer:GetMouse()

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, key)

    if self == Mouse and key == "Hit" and Settings.SilentAim then

        local target = GetSilentTarget()

        if target and RollHitChance() then
            return target.CFrame
        end
    end

    return OldIndex(self, key)
end)

--// =========================
--// MAIN LOOP
--// =========================

RunService.RenderStepped:Connect(function()

    UpdateESP()

    -- Rainbow
    local hue = tick() % 5 / 5
    local rainbow = Color3.fromHSV(hue,1,1)

    UIStroke.Color = Settings.FOVRainbow and rainbow or Settings.FOVColor

    local aimPos = GetAimPosition()

    FOVCircle.Position = UDim2.fromOffset(aimPos.X, aimPos.Y)
    FOVCircle.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)

    -- Ragebot 우선
    if Settings.Ragebot then

        local target = GetRageTarget()

        if target then
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = ApplyHumanizedAim(targetCF, 1)
        end

    elseif Settings.Aimbot then

        local target = GetClosestTarget()

        if target then
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = ApplyHumanizedAim(targetCF, Settings.Smoothness)
        end
    end

    -- Recoil 마지막 적용
    ApplyRecoilControl()

end)
