--// ============================--
--     Panda Simple Key UI      --
--==============================--

if getgenv().ZYROX_SIMPLE_AUTH then
    return
end
getgenv().ZYROX_SIMPLE_AUTH = true

--============================--
--        Panda System        --
--============================--

local BaseURL = "https://new.pandadevelopment.net/api/v1"
local Client_ServiceID = "zyroxkr"

local HttpService = game:GetService("HttpService")

-- HWID
local function getHardwareId()
    local success, hwid = pcall(gethwid)
    if success and hwid then
        return hwid
    end

    local clientId = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
    return clientId:gsub("-", "")
end

-- Request
local function makeRequest(endpoint, body)
    local response = request({
        Url = BaseURL .. endpoint,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(body)
    })

    if response and response.Body then
        return HttpService:JSONDecode(response.Body)
    end

    return nil
end

-- Validate (⭐ Premium 감지 추가)
local function Validate(key)

    local result = makeRequest("/keys/validate", {
        ServiceID = Client_ServiceID,
        HWID = getHardwareId(),
        Key = key
    })

    if not result then
        return false, "Server connection failed", false
    end

    if result.Authenticated_Status == "Success" then

        local isPremium = false

        -- Panda Premium 필드 감지
        if result.IsPremium == true
        or result.Premium == true
        or result.KeyType == "Premium"
        or result.Plan == "Premium" then
            isPremium = true
        end

        return true, "Key Valid", isPremium

    else
        return false, result.Note or "Invalid Key", false
    end
end

-- Get Key URL
local function GetKeyURL()
    return "https://new.pandadevelopment.net/getkey/" ..
        Client_ServiceID .. "?hwid=" .. getHardwareId()
end


--============================--
--        Main Script         --
--============================--

local function RunMain(isPremium)

    print("hello")

    if isPremium then
        print("Premium Detected")

        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/minecrft100581/testscript/refs/heads/main/testscript3.lua"
        ))()

    else
        print("Free Key")

        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/minecrft100581/testscript/refs/heads/main/testscript2.lua"
        ))()

    end
end


--============================--
--            UI              --
--============================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimplePandaKeyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 190)
Frame.Position = UDim2.new(0.5, -160, 0.5, -95)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Panda Key Authentication"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Parent = Frame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 35)
KeyBox.Position = UDim2.new(0.075, 0, 0.32, 0)
KeyBox.PlaceholderText = "Enter your key..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.new(1,1,1)
KeyBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
KeyBox.BorderSizePixel = 0
KeyBox.Parent = Frame

Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.55, 0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255,80,80)
Status.TextScaled = true
Status.Text = ""
Status.Parent = Frame

local ValidateBtn = Instance.new("TextButton")
ValidateBtn.Size = UDim2.new(0.4, 0, 0, 35)
ValidateBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
ValidateBtn.Text = "Validate"
ValidateBtn.TextColor3 = Color3.new(1,1,1)
ValidateBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
ValidateBtn.BorderSizePixel = 0
ValidateBtn.Parent = Frame

Instance.new("UICorner", ValidateBtn).CornerRadius = UDim.new(0, 8)

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.5, 0, 0.7, 0)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextColor3 = Color3.new(1,1,1)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
GetKeyBtn.BorderSizePixel = 0
GetKeyBtn.Parent = Frame

Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)


--============================--
--        Button Logic        --
--============================--

ValidateBtn.MouseButton1Click:Connect(function()

    if KeyBox.Text == "" then
        Status.Text = "Please enter a key."
        return
    end

    Status.Text = "Validating..."

    local success, message, isPremium = Validate(KeyBox.Text)

    if not success then
        Status.Text = message
        return
    end

    Status.TextColor3 = Color3.fromRGB(100,255,100)
    Status.Text = "Authentication Successful!"

    task.wait(0.8)

    ScreenGui:Destroy()
    RunMain(isPremium)

end)


GetKeyBtn.MouseButton1Click:Connect(function()

    local url = GetKeyURL()

    if setclipboard then
        setclipboard(url)
    end

    Status.TextColor3 = Color3.fromRGB(100,255,100)
    Status.Text = "Key link copied to clipboard!"

    print("Get your key at:", url)
end)
