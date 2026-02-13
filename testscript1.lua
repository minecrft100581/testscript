-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
--============================--
-- Panda System --
--============================--
local BaseURL = "https://new.pandadevelopment.net/api/v1"
local Client_ServiceID = "zyroxkr"
local function getHardwareId()
    local clientId = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
    return clientId:gsub("-", "")
end
local function Validate(key)
    local success, response = pcall(function()
        return HttpService:PostAsync(BaseURL .. "/keys/validate", HttpService:JSONEncode({
            ServiceID = Client_ServiceID,
            HWID = getHardwareId(),
            Key = key
        }), Enum.HttpContentType.ApplicationJson)
    end)
    if not success or not response then
        return false, "Server connection failed"
    end
    local result = HttpService:JSONDecode(response)
    if result.Authenticated_Status == "Success" then
        return true, "Key Valid"
    else
        return false, result.Note or "Invalid Key"
    end
end
--============================--
-- Main Script --
--============================--
local function RunMainScript()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/minecrft100581/testscript/refs/heads/main/testscript2.lua"))()
end
--============================--
-- Luna --
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
Luna:Notification({
    Title = "Key system",
    Icon = "notifications_active",
    ImageSource = "Material",
    Content = "Key system = https://new.pandadevelopment.net/getkey/zyroxkr?hwid=hwid"
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
            Luna:Notification({
                Title = "Access Denied",
                Icon = "error",
                ImageSource = "Material",
                Content = message
            })
            return
        end
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
