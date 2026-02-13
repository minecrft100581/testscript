--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

--============================--
--        Panda System        --
--============================--

local BaseURL = "https://new.pandadevelopment.net/api/v1"
local Client_ServiceID = "zyroxkr"

local function getHardwareId()
    local success, hwid = pcall(gethwid)
    if success and hwid then
        return hwid
    end

    local clientId = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
    return clientId:gsub("-", "")
end

local function Validate(key)
    local response = request({
        Url = BaseURL .. "/keys/validate",
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            ServiceID = Client_ServiceID,
            HWID = getHardwareId(),
            Key = key
        })
    })

    if not response or not response.Body then
        return false, "Server connection failed"
    end

    local result = HttpService:JSONDecode(response.Body)

    if result.Authenticated_Status == "Success" then
        return true, "Key Valid"
    else
        return false, result.Note or "Invalid Key"
    end
end

--============================--
--         Main Script        --
--============================--

local function RunMainScript()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/minecrft100581/testscript/refs/heads/main/testscript2.lua"))()
end

--============================--
--            Luna            --
--============================--

local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna", true))()

local Window = Luna:CreateWindow({
    Name = "Authentication",
    Subtitle = "Enter your key",
    LogoID = "6031097225",
    LoadingEnabled = true,
    LoadingTitle = "Checking Key...",
    LoadingSubtitle = "Please wait",
    KeySystem = false
})

local KeyTab = Window:CreateTab({
    Name = "Key System",
    Icon = "vpn_key",
    ImageSource = "Material"
})

KeyTab:CreateSection("Authentication Required")

local KeyInput = KeyTab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "PANDA-XXXX-XXXX-XXXX-XXXX",
    CurrentValue = "",
    Numeric = false,
    Enter = false
})

KeyTab:CreateButton({
    Name = "Validate Key",
    Callback = function()

        if KeyInput.Value == "" then
            Luna:Notification({
                Title = "Error",
                Icon = "error",
                ImageSource = "Material",
                Content = "Please enter a key first."
            })
            return
        end

        local success, message = Validate(KeyInput.Value)

        if not success then
            -- ❌ 실패 → 재입력 허용
            Luna:Notification({
                Title = "Access Denied",
                Icon = "error",
                ImageSource = "Material",
                Content = message
            })
            return
        end

        -- ✅ 성공
        Luna:Notification({
            Title = "Access Granted",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = "Authentication Successful"
        })

        task.wait(0.8)

        -- UI 종료
        Luna:Destroy()

        -- 메인 스크립트 실행
        RunMainScript()
    end
})
