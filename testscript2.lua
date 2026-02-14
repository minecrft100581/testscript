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
    Name = "Mobile Universal Script",
    Subtitle = "Mobile Universal Script",
    LogoID = "rbxassetid://7733960981",
    LoadingEnabled = false,
})
local Tabs = {
    Main = Window:CreateTab({ Name = "Main" }),
    Visual = Window:CreateTab({ Name = "Visual" }),
    Combat = Window:CreateTab({ Name = "Combat" }),
    Movement = Window:CreateTab({ Name = "Movement" }),
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
    ESPRainbow = false,
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
    -- Circle
    CircleRadius = 5,
    -- Movement
    Speed = false,
    SpeedValue = 50,
    Fly = false,
    FlySpeed = 50,
    -- Anti-Aim
    Backtrack = false,
    Desync = false,
    -- Target Mode
    TargetMode = "All",
    -- Rainbow
    TargetRainbow = false,
    HealthRainbow = false,
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
Tabs.Main:CreateToggle({
    Name = "Team Check",
    Callback = function(v) Settings.TeamCheck = v end
})
Tabs.Main:CreateToggle({
    Name = "Visible Check",
    Callback = function(v) Settings.VisibleCheck = v end
})
Tabs.Main:CreateDropdown({
    Name = "Target Mode",
    Options = {"All", "Enemies", "Teammates"},
    CurrentOption = "All",
    Callback = function(v) Settings.TargetMode = v end
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
Tabs.Main:CreateSlider({
    Name = "Max Distance",
    Range = {100,5000},
    Increment = 100,
    CurrentValue = Settings.MaxDistance,
    Callback = function(v) Settings.MaxDistance = v end
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
Tabs.Visual:CreateToggle({
    Name = "ESP Rainbow",
    Callback = function(v) Settings.ESPRainbow = v end
})
Tabs.Visual:CreateToggle({
    Name = "Target Rainbow",
    Callback = function(v) Settings.TargetRainbow = v end
})
Tabs.Visual:CreateToggle({
    Name = "Health Rainbow",
    Callback = function(v) Settings.HealthRainbow = v end
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
Tabs.Combat:CreateSlider({
    Name = "Circle Radius",
    Range = {1,20},
    Increment = 1,
    CurrentValue = Settings.CircleRadius,
    Callback = function(v) Settings.CircleRadius = v end
})
Tabs.Combat:CreateToggle({
    Name = "Backtrack",
    Callback = function(v) Settings.Backtrack = v end
})
Tabs.Combat:CreateToggle({
    Name = "Desync",
    Callback = function(v) Settings.Desync = v end
})
Tabs.Movement:CreateToggle({
    Name = "Speed",
    Callback = function(v) Settings.Speed = v end
})
Tabs.Movement:CreateSlider({
    Name = "Speed Value",
    Range = {16,100},
    Increment = 1,
    CurrentValue = Settings.SpeedValue,
    Callback = function(v) Settings.SpeedValue = v end
})
Tabs.Movement:CreateToggle({
    Name = "Fly",
    Callback = function(v) Settings.Fly = v end
})
Tabs.Movement:CreateSlider({
    Name = "Fly Speed",
    Range = {10,200},
    Increment = 1,
    CurrentValue = Settings.FlySpeed,
    Callback = function(v) Settings.FlySpeed = v end
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
--// TARGET HUB GUI
--// =========================
local TargetGui = Instance.new("ScreenGui")
TargetGui.ResetOnSpawn = false
TargetGui.Parent = CoreGui
local TargetFrame = Instance.new("Frame")
TargetFrame.Size = UDim2.new(0, 200, 0, 180)
TargetFrame.Position = UDim2.new(1, -210, 0, 10)
TargetFrame.BackgroundColor3 = Color3.new(0,0,0)
TargetFrame.BackgroundTransparency = 0.5
TargetFrame.Parent = TargetGui
TargetFrame.Visible = false
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = TargetFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local DisplayNameLabel = Instance.new("TextLabel")
DisplayNameLabel.Size = UDim2.new(1, 0, 0, 30)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.TextColor3 = Color3.new(1,1,1)
DisplayNameLabel.Text = "Display: "
DisplayNameLabel.Parent = TargetFrame
local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Size = UDim2.new(1, 0, 0, 30)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.TextColor3 = Color3.new(1,1,1)
UsernameLabel.Text = "Username: "
UsernameLabel.Parent = TargetFrame
local HealthLabel = Instance.new("TextLabel")
HealthLabel.Size = UDim2.new(1, 0, 0, 30)
HealthLabel.BackgroundTransparency = 1
HealthLabel.TextColor3 = Color3.new(1,1,1)
HealthLabel.Text = "Health: "
HealthLabel.Parent = TargetFrame
local HealthBar = Instance.new("Frame")
HealthBar.Size = UDim2.new(1, 0, 0, 20)
HealthBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
HealthBar.Parent = TargetFrame
local HealthFill = Instance.new("Frame")
HealthFill.AnchorPoint = Vector2.new(0, 0)
HealthFill.Size = UDim2.new(0, 0, 1, 0)
HealthFill.BackgroundColor3 = Color3.new(0, 1, 0)
HealthFill.Parent = HealthBar
local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Size = UDim2.new(1, 0, 0, 30)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.TextColor3 = Color3.new(1,1,1)
DistanceLabel.Text = "Distance: "
DistanceLabel.Parent = TargetFrame
local WeaponLabel = Instance.new("TextLabel")
WeaponLabel.Size = UDim2.new(1, 0, 0, 30)
WeaponLabel.BackgroundTransparency = 1
WeaponLabel.TextColor3 = Color3.new(1,1,1)
WeaponLabel.Text = "Weapon: "
WeaponLabel.Parent = TargetFrame
--// =========================
--// AIM POSITION
--// =========================
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
local function GetAimPosition()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return center
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
local function UpdateESP(rainbow)
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
                local color = Settings.ESPRainbow and rainbow or Settings.ESPColor
                hl.FillColor = color
                hl.OutlineColor = color
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
local function IsVisible(part, char)
    if not Settings.VisibleCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local result = workspace:Raycast(origin, direction, params)
    return result and result.Instance:IsDescendantOf(char)
end
local function GetClosestTarget()
    local closest
    local shortest = Settings.Ragebot and Settings.RageFOV or Settings.FOV
    local center = GetAimPosition()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local sameTeam = player.Team == LocalPlayer.Team
        if Settings.TargetMode == "Enemies" and sameTeam then continue end
        if Settings.TargetMode == "Teammates" and not sameTeam then continue end
        if Settings.TeamCheck and sameTeam then continue end
        local char = player.Character
        if not char then continue end
        local part = GetBestPart(char)
        if not part then continue end
        local distance = (root.Position - part.Position).Magnitude
        if distance > Settings.MaxDistance then continue end
        local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
        if dist >= shortest then continue end
        if not IsVisible(part, char) then continue end
        shortest = dist
        closest = part
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
--// MOVEMENT
--// =========================
local FlyBV
local function UpdateMovement()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Settings.Speed then
            hum.WalkSpeed = Settings.SpeedValue
        else
            hum.WalkSpeed = 16
        end
    end
    if Settings.Fly then
        if not FlyBV then
            FlyBV = Instance.new("BodyVelocity")
            FlyBV.Velocity = Vector3.new(0,0,0)
            FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyBV.Parent = char:FindFirstChild("HumanoidRootPart")
        end
        local dir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        FlyBV.Velocity = dir * Settings.FlySpeed
    elseif FlyBV then
        FlyBV:Destroy()
        FlyBV = nil
    end
end
--// =========================
--// ANTI-AIM
--// =========================
local BacktrackParts = {}
local function UpdateAntiAim()
    local char = LocalPlayer.Character
    if not char then return end
    if Settings.Backtrack then
        -- Simple backtrack simulation: create fake parts
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local fake = BacktrackParts[root] or Instance.new("Part")
            fake.Size = root.Size
            fake.CFrame = root.CFrame
            fake.Transparency = 0.5
            fake.Parent = workspace
            BacktrackParts[root] = fake
            task.delay(0.1, function() fake:Destroy() end)
        end
    end
    if Settings.Desync then
        -- Simple desync: offset root
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame * CFrame.new(math.sin(tick()*10)*2, 0, 0)
        end
    end
end
--// =========================
--// MAIN LOOP
--// =========================
RunService.RenderStepped:Connect(function()
    local hue = tick()%5/5
    local rainbow = Color3.fromHSV(hue,1,1)
    UpdateESP(rainbow)
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
        local aimPoint = target.Position
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local distance = (root.Position - target.Position).Magnitude
            DistanceLabel.Text = "Distance: " .. math.floor(distance)
            if Settings.Ragebot then
                local angle = tick() * 5
                local offset = Vector3.new(math.sin(angle) * Settings.CircleRadius, 0, math.cos(angle) * Settings.CircleRadius)
                local position = target.Position + offset
                root.CFrame = CFrame.new(position, target.Position)
            end
        end
        local cf = CFrame.new(Camera.CFrame.Position, aimPoint)
        Camera.CFrame = ApplyHuman(cf, Settings.Smoothness)
        -- Update Target Hub
        local char = target.Parent
        local player = Players:GetPlayerFromCharacter(char)
        if player then
            DisplayNameLabel.Text = "Display: " .. player.DisplayName
            UsernameLabel.Text = "Username: " .. player.Name
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                HealthLabel.Text = "Health: " .. math.floor(hum.Health) .. "/" .. hum.MaxHealth
                local healthPct = hum.Health / hum.MaxHealth
                HealthFill.Size = UDim2.new(healthPct, 0, 1, 0)
                HealthFill.BackgroundColor3 = Settings.HealthRainbow and rainbow or Color3.new(0,1,0)
            end
            local equipped = char:FindFirstChildOfClass("Tool")
            if equipped then
                WeaponLabel.Text = "Weapon: " .. equipped.Name
            else
                WeaponLabel.Text = "Weapon: None"
            end
            TargetFrame.BackgroundColor3 = Settings.TargetRainbow and rainbow or Color3.new(0,0,0)
            TargetFrame.Visible = true
        end
    else
        TargetFrame.Visible = false
    end
    ApplyRecoil()
    UpdateMovement()
    UpdateAntiAim()
end)
