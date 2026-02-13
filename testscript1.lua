--// =============================--
--        Panda Key System        --
--===============================--

local BaseURL = "https://new.pandadevelopment.net/api/v1"
local Client_ServiceID = "zyroxkr"

-- Get Hardware ID
local function getHardwareId()
    local success, hwid = pcall(gethwid)
    if success and hwid then
        return hwid
    end

    local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
    local clientId = tostring(RbxAnalyticsService:GetClientId())
    return clientId:gsub("-", "")
end

-- HTTP Request wrapper
local function makeRequest(endpoint, body)
    local HttpService = game:GetService("HttpService")

    local response = request({
        Url = BaseURL .. endpoint,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(body)
    })

    if response and response.Body then
        return HttpService:JSONDecode(response.Body)
    end

    return nil
end

-- Get Key URL
function GetKeyURL()
    local hwid = getHardwareId()
    return "https://new.pandadevelopment.net/getkey/" .. Client_ServiceID .. "?hwid=" .. hwid
end

-- Copy Get Key URL
function OpenGetKey()
    local url = GetKeyURL()
    if setclipboard then
        setclipboard(url)
    end
    return url
end

-- Validate Key (프리미엄 검사 제거)
function Validate(key)
    local hwid = getHardwareId()

    local result = makeRequest("/keys/validate", {
        ServiceID = Client_ServiceID,
        HWID = hwid,
        Key = key
    })

    if not result then
        return {
            success = false,
            message = "Failed to connect to server"
        }
    end

    local isAuthenticated = result.Authenticated_Status == "Success"

    return {
        success = isAuthenticated,
        message = result.Note or (isAuthenticated and "Key validated!" or "Invalid key")
    }
end


--============================--
--         Main Script        --
--============================--

local function RunMainScript()
    print("hello")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/minecrft100581/testscript/refs/heads/main/testscript2.lua"))()
end


--============================--
--            Luna UI         --
--============================--

local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna", true))()

local Window = Luna:CreateWindow({
    Name = "Authentication",
    Subtitle = "Panda Key System",
    LogoID = "6031097225",
    LoadingEnabled = true,
    LoadingTitle = "Luna Interface Suite",
    LoadingSubtitle = "Authentication Required",
    KeySystem = false
})

-- 탭 1개만 생성
local Tabs = {
    Main = Window:CreateTab({
        Name = "Key System",
        Icon = "vpn_key",
        ImageSource = "Material",
        ShowTitle = true
    })
}

-- 섹션 1개
Tabs.Main:CreateSection("Authentication Required")

-- 키 입력
local Input = Tabs.Main:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "PANDA-XXXX-XXXX-XXXX-XXXX",
    CurrentValue = "",
    Numeric = false,
    MaxCharacters = nil,
    Enter = false
})

-- Validate 버튼
Tabs.Main:CreateButton({
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

        local result = Validate(KeyInput.Value)

        if not result.success then
            -- 실패 → 재입력 가능
            Luna:Notification({
                Title = "Access Denied",
                Icon = "error",
                ImageSource = "Material",
                Content = result.message
            })
            return
        end

        -- 성공
        Luna:Notification({
            Title = "Access Granted",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = "Authentication Successful"
        })

        task.wait(0.8)

        RunMainScript()
        Luna:Destroy()
    end
})

-- Get Key 버튼
Tabs.Main:CreateButton({
    Name = "Get Key (Copy Link)",
    Callback = function()

        local url = OpenGetKey()

        Luna:Notification({
            Title = "Key URL Copied",
            Icon = "content_copy",
            ImageSource = "Material",
            Content = "Key link copied to clipboard."
        })

        print("Get your key at: " .. url)
    end
})
