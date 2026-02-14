--// =========================
--// SERVICES
--// =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

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
--// LOAD LUNA
--// =========================

local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna"))()

--// =========================
--// SETTINGS
--// =========================

local Settings = {
    -- Legit
    Aimbot = false,
    AimPart = "Head",
    Smoothness = 0.15,
    FOV = 150,
    MaxDistance = 1000,

    FOVColor = Color3.fromRGB(255,255,255),
    FOVRainbow = false,

    -- ESP
    ESP = false,
    ESPColor = Color3.fromRGB(255,0,0),
    ESPRainbow = false,

    TeamCheck = false,
    VisibleCheck = false,

    -- Rage
    Ragebot = false,
    RageTargetMode = "All",
    RageCustomName = "",

    RageFOV = 300,
    RageFOVColor = Color3.fromRGB(255,50,50),
    RageFOVVisible = true,

    AutoHeadshot = true,
    HeadshotDistance = 250,

    -- Silent Aim
    SilentAim = false,
    HitChance = 100, -- %
}

--// =========================
--// UI ELEMENTS
--// =========================

Tabs.Main:CreateSection("Aimbot")

Tabs.Main:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(v)
        Settings.Aimbot = v
    end
})

Tabs.Main:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head","HumanoidRootPart"},
    CurrentOption = "Head",
    MultipleOptions = false,
    Callback = function(v)
        Settings.AimPart = v
    end
})

Tabs.Main:CreateSlider({
    Name = "Smoothness",
    Range = {0.01,1},
    Increment = 0.01,
    CurrentValue = 0.15,
    Callback = function(v)
        Settings.Smoothness = v
    end
})

Tabs.Main:CreateSlider({
    Name = "Max Distance",
    Range = {50,3000},
    Increment = 10,
    CurrentValue = 1000,
    Callback = function(v)
        Settings.MaxDistance = v
    end
})

Tabs.Main:CreateSection("FOV")

Tabs.Main:CreateSlider({
    Name = "FOV Size",
    Range = {50,500},
    Increment = 1,
    CurrentValue = 150,
    Callback = function(v)
        Settings.FOV = v
    end
})

Tabs.Main:CreateColorPicker({
    Name = "FOV Color",
    Color = Settings.FOVColor,
    Callback = function(v)
        Settings.FOVColor = v
    end
})

Tabs.Main:CreateToggle({
    Name = "FOV Rainbow",
    CurrentValue = false,
    Callback = function(v)
        Settings.FOVRainbow = v
    end
})

Tabs.Main:CreateSection("ESP")

Tabs.Main:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.ESP = v
    end
})

Tabs.Main:CreateColorPicker({
    Name = "ESP Color",
    Color = Settings.ESPColor,
    Callback = function(v)
        Settings.ESPColor = v
    end
})

Tabs.Main:CreateSection("Checks")

Tabs.Main:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Callback = function(v)
        Settings.TeamCheck = v
    end
})

Tabs.Main:CreateToggle({
    Name = "Visible Check",
    CurrentValue = false,
    Callback = function(v)
        Settings.VisibleCheck = v
    end
})

Tabs.Main:CreateSection("Silent Aim")

Tabs.Main:CreateToggle({
    Name = "Enable Silent Aim",
    CurrentValue = false,
    Callback = function(v)
        Settings.SilentAim = v
    end
})

Tabs.Main:CreateSlider({
    Name = "Hit Chance %",
    Range = {0,100},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(v)
        Settings.HitChance = v
    end
})

--// =========================
--// FOV GUI (반응형)
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
--// ESP SYSTEM (Highlight 기반)
--// =========================

local ESPContainer = {}

local function UpdateESP()
    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local char = player.Character
            if not char then continue end

            if Settings.ESP then
                if not ESPContainer[player] then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                    ESPContainer[player] = hl
                end

                ESPContainer[player].FillColor = Settings.ESPColor
                ESPContainer[player].OutlineColor = Settings.ESPColor
                ESPContainer[player].Enabled = true
            else
                if ESPContainer[player] then
                    ESPContainer[player]:Destroy()
                    ESPContainer[player] = nil
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    if ESPContainer[plr] then
        ESPContainer[plr]:Destroy()
        ESPContainer[plr] = nil
    end
end)

--// =========================
--// VISIBILITY
--// =========================

local function IsVisible(part)
    if not Settings.VisibleCheck then return true end
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
    local aimPos = GetAimPosition()

    for _,player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local char = player.Character
            if not char then continue end

            local root = char:FindFirstChild("HumanoidRootPart")
            local part = char:FindFirstChild(Settings.AimPart)

            if not root or not part then continue end

            if (root.Position - Camera.CFrame.Position).Magnitude > Settings.MaxDistance then
                continue
            end

            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end

            local dist = (Vector2.new(screenPos.X,screenPos.Y) - aimPos).Magnitude

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

    UpdateESP()

    -- Rainbow
    local hue = tick() % 5 / 5
    local rainbow = Color3.fromHSV(hue,1,1)

    UIStroke.Color = Settings.FOVRainbow and rainbow or Settings.FOVColor

    -- FOV
    local aimPos = GetAimPosition()
    FOVCircle.Position = UDim2.fromOffset(aimPos.X, aimPos.Y)
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

--// ========================
--// HIT CHANCE
--===========================

local function RollHitChance()
    return math.random(0,100) <= Settings.HitChance
end

-- AUTO HEADSHOT

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
    else
        return character:FindFirstChild(Settings.AimPart)
    end
end

-- Silent aim target finder

local function GetSilentTarget()

    local closest = nil
    local shortest = Settings.FOV
    local center = GetAimPosition()

    for _,player in ipairs(Players:GetPlayers()) do

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

        local dist = (Vector2.new(screenPos.X,screenPos.Y) - center).Magnitude

        if dist < shortest then
            shortest = dist
            closest = part
        end
    end

    return closest
end

--silent aim hook

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

--ragebot aimbot 우선순위

if Settings.Ragebot then

    local target = GetRageTarget()

    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end

elseif Settings.Aimbot then

    local target = GetClosestTarget()

    if target then
        local newCF = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(newCF, Settings.Smoothness)
    end

end

--ragebot fov circle

local aimPos = GetAimPosition()

RageCircle.Visible = Settings.Ragebot and Settings.RageFOVVisible
RageCircle.Position = UDim2.fromOffset(aimPos.X, aimPos.Y)
RageCircle.Size = UDim2.fromOffset(Settings.RageFOV*2, Settings.RageFOV*2)
RageStroke.Color = Settings.RageFOVColor
