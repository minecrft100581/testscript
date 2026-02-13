--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

--============================--
--        Panda System        --
--============================--

local BaseURL = "https://new.pandadevelopment.net/api/v1"
local Client_ServiceID = "YOUR_SERVICE_ID"

local function getHardwareId()
    local success, hwid = pcall(gethwid)
    if success and hwid then
        return hwid
    end

    local clientId = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
    return clientId:gsub("-", "")
end

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
end

local function Validate(key)
    local result = makeRequest("/keys/validate", {
        ServiceID = Client_ServiceID,
        HWID = getHardwareId(),
        Key = key
    })

    if not result then
        return false, "Server connection failed", false
    end

    local success = result.Authenticated_Status == "Success"
    return success, result.Note or "Invalid Key", result.Key_Premium or false
end


--============================--
--            Luna            --
--============================--

local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna", true))()

local Window = Luna:CreateWindow({
    Name = "Mobile Universal",
    Subtitle = "Panda Secured",
    LogoID = "6031097225",
    LoadingEnabled = true,
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Please wait",
    KeySystem = false -- ❗ Luna 기본 키 시스템 끔
})

Luna:Notification({
    Title = "Welcome",
    Icon = "sparkle",
    ImageSource = "Material",
    Content = "Authentication required."
})

--============================--
--        Key Tab             --
--============================--

local KeyTab = Window:CreateTab({
    Name = "Key System",
    Icon = "vpn_key",
    ImageSource = "Material"
})

local KeyInput = KeyTab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "PANDA-XXXX-XXXX-XXXX-XXXX",
    CurrentValue = "",
    Numeric = false,
    Enter = false
})

KeyTab:CreateButton({
    Name = "Validate",
    Callback = function()

        local success, message, isPremium = Validate(KeyInput.Value)

        if not success then
            Luna:Notification({
                Title = "Access Denied",
                Icon = "error",
                ImageSource = "Material",
                Content = message
            })
            Players.LocalPlayer:Kick("Invalid Key")
            return
        end

        Luna:Notification({
            Title = "Access Granted",
            Icon = "check_circle",
            ImageSource = "Material",
            Content = isPremium and "Premium Key" or "Standard Key"
        })

        loadMainUI(isPremium)
    end
})

--============================--
--       Main Interface       --
--============================--

function loadMainUI(isPremium)

    local Tabs = {
        Main = Window:CreateTab({
            Name = "Main",
            Icon = "view_in_ar",
            ImageSource = "Material",
            ShowTitle = true
        }),
        Debug = Window:CreateTab({
            Name = "Debug",
            Icon = "settings"
        })
    }

    -- Main Tab
    Tabs.Main:CreateSection("Main Features")

    Tabs.Main:CreateButton({
        Name = "Example Button",
        Callback = function()
            print("Running...")
        end
    })

    Tabs.Main:CreateToggle({
        Name = "Example Toggle",
        CurrentValue = false,
        Callback = function(v)
            print("Toggle:", v)
        end
    })

    -- Debug Tab
    Tabs.Debug:CreateColorPicker({
        Name = "UI Color",
        Color = Color3.fromRGB(86,171,128),
        Callback = function(color)
            print("Color changed:", color)
        end
    })

    -- ⭐ Premium Tab
    if isPremium then
        local PremiumTab = Window:CreateTab({
            Name = "Premium",
            Icon = "star",
            ImageSource = "Material"
        })

        PremiumTab:CreateSection("Premium Features")

        PremiumTab:CreateButton({
            Name = "Premium Feature",
            Callback = function()
                print("Premium Active")
            end
        })
    end
end
