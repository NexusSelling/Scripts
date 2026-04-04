--[[
    Nexus | Free - PlaceID: 7711635737
    ESP & Visuals Script
]]

-- ============================================
-- SECRET KEY CHECK - NICHT ENTFERNEN!
-- ============================================
if not getgenv().NexusLoaderActive then
    warn("Access Denied: Use the official Nexus Loader!")
    pcall(function()
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()
        Library:Notify("Access Denied", "Use the official Nexus Loader!", 5)
    end)
    return
end
-- ============================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Library laden
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()

-- Theme (Exact wie im Bild - Dunkel Rot/Schwarz)
Library:SetTheme({
    Accent = Color3.fromRGB(170, 35, 35),
    MainBackground = Color3.fromRGB(18, 18, 18),
    SidebarBackground = Color3.fromRGB(22, 22, 22),
    ElementBackground = Color3.fromRGB(28, 28, 28),
    ButtonBackground = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(160, 160, 160),
})

-- Settings
local Settings = {
    -- ESP
    ESP_Enabled = false,
    ESP_Chams = false,
    ESP_HealthBars = false,
    ESP_Range = 2000,
    ESP_ShowNames = false,
    ESP_ShowDistance = false,
    ESP_TeamCheck = false,
    
    -- Aimbot
    Aimbot_Enabled = false,
    Aimbot_TeamCheck = true,
    Aimbot_TargetPart = "Head",
    Aimbot_Smoothness = 5,
    Aimbot_FOV = 100,
    Aimbot_ShowFOV = false,
}

-- ESP Storage
local ESPObjects = {}

-- ============================================
-- ESP FUNCTIONS
-- ============================================

local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    
    local espHolder = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        Chams = nil
    }
    
    -- Box
    espHolder.Box.Thickness = 1
    espHolder.Box.Color = Color3.fromRGB(200, 30, 30)
    espHolder.Box.Filled = false
    espHolder.Box.Visible = false
    
    -- Name
    espHolder.Name.Size = 14
    espHolder.Name.Color = Color3.fromRGB(255, 255, 255)
    espHolder.Name.Center = true
    espHolder.Name.Outline = true
    espHolder.Name.Visible = false
    
    -- Distance
    espHolder.Distance.Size = 12
    espHolder.Distance.Color = Color3.fromRGB(200, 200, 200)
    espHolder.Distance.Center = true
    espHolder.Distance.Outline = true
    espHolder.Distance.Visible = false
    
    -- Health Bar Outline
    espHolder.HealthBarOutline.Thickness = 1
    espHolder.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    espHolder.HealthBarOutline.Filled = true
    espHolder.HealthBarOutline.Visible = false
    
    -- Health Bar
    espHolder.HealthBar.Thickness = 1
    espHolder.HealthBar.Filled = true
    espHolder.HealthBar.Visible = false
    
    ESPObjects[player] = espHolder
end

local function RemoveESP(player)
    local esp = ESPObjects[player]
    if esp then
        for _, drawing in pairs(esp) do
            if typeof(drawing) == "table" and drawing.Remove then
                drawing:Remove()
            elseif drawing and drawing.Remove then
                drawing:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for player, esp in pairs(ESPObjects) do
        if not player or not player.Parent then
            RemoveESP(player)
            continue
        end
        
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
        local head = character and character:FindFirstChild("Head")
        
        if not character or not humanoid or not rootPart or not head or humanoid.Health <= 0 then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarOutline.Visible = false
            continue
        end
        
        -- Distance check
        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
            and (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0
        
        if distance > Settings.ESP_Range then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarOutline.Visible = false
            continue
        end
        
        -- Team check
        if Settings.ESP_TeamCheck and player.Team == LocalPlayer.Team then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarOutline.Visible = false
            continue
        end
        
        -- Screen position
        local rootPos, rootVisible = Camera:WorldToViewportPoint(rootPart.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
        
        if not rootVisible then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarOutline.Visible = false
            continue
        end
        
        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth = boxHeight * 0.6
        
        -- Update Box (Chams/Boxes)
        if Settings.ESP_Enabled and Settings.ESP_Chams then
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Position = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y)
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        -- Update Name
        if Settings.ESP_Enabled and Settings.ESP_ShowNames then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(rootPos.X, headPos.Y - 18)
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        -- Update Distance
        if Settings.ESP_Enabled and Settings.ESP_ShowDistance then
            esp.Distance.Text = math.floor(distance) .. "m"
            esp.Distance.Position = Vector2.new(rootPos.X, legPos.Y + 5)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        -- Update Health Bar
        if Settings.ESP_Enabled and Settings.ESP_HealthBars then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = boxHeight
            local barWidth = 3
            
            -- Outline
            esp.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
            esp.HealthBarOutline.Position = Vector2.new(rootPos.X - boxWidth / 2 - barWidth - 5, headPos.Y - 1)
            esp.HealthBarOutline.Visible = true
            
            -- Health bar
            esp.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
            esp.HealthBar.Position = Vector2.new(rootPos.X - boxWidth / 2 - barWidth - 4, headPos.Y + barHeight * (1 - healthPercent))
            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            esp.HealthBar.Visible = true
        else
            esp.HealthBar.Visible = false
            esp.HealthBarOutline.Visible = false
        end
    end
end

-- ============================================
-- AIMBOT FUNCTIONS
-- ============================================

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(200, 30, 30)
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Radius = 100

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.Aimbot_FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.Aimbot_TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local character = player.Character
        local targetPart = character and character:FindFirstChild(Settings.Aimbot_TargetPart)
        
        if not targetPart then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local mousePos = UserInputService:GetMouseLocation()
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if distance < shortestDistance then
            shortestDistance = distance
            closestPlayer = player
        end
    end
    
    return closestPlayer
end

-- ============================================
-- UI CREATION
-- ============================================

local Window = Library:CreateWindow("Nexus | Free")

-- Aimbot Tab
local AimbotTab = Window:CreateTab("Aimbot")
local AimbotSection = AimbotTab:CreateSection("Aimbot")

AimbotSection:CreateToggle("Enable Aimbot", "Toggle aimbot on/off", false, function(value)
    Settings.Aimbot_Enabled = value
end)

AimbotSection:CreateToggle("Team Check", "Don't target teammates", true, function(value)
    Settings.Aimbot_TeamCheck = value
end)

AimbotSection:CreateToggle("Show FOV", "Display FOV circle", false, function(value)
    Settings.Aimbot_ShowFOV = value
    FOVCircle.Visible = value
end)

AimbotSection:CreateDropdown("Target Part", "Which body part to aim at", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(value)
    Settings.Aimbot_TargetPart = value
end)

AimbotSection:CreateSlider("FOV", "Aimbot field of view", 50, 500, 100, function(value)
    Settings.Aimbot_FOV = value
    FOVCircle.Radius = value
end)

AimbotSection:CreateSlider("Smoothness", "Aim smoothness (lower = faster)", 1, 20, 5, function(value)
    Settings.Aimbot_Smoothness = value
end)

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals")

-- ESP Section
local ESPSection = VisualsTab:CreateSection("ESP")

ESPSection:CreateToggle("Enable ESP", "Toggle ESP on/off", false, function(value)
    Settings.ESP_Enabled = value
end)

ESPSection:CreateToggle("Chams/Boxes", "Show player boxes", false, function(value)
    Settings.ESP_Chams = value
end)

ESPSection:CreateToggle("Health Bars", "Show health bars", false, function(value)
    Settings.ESP_HealthBars = value
end)

ESPSection:CreateSlider("Range", "ESP render distance", 100, 2000, 2000, function(value)
    Settings.ESP_Range = value
end)

-- Filters Section
local FiltersSection = VisualsTab:CreateSection("Filters")

FiltersSection:CreateToggle("Show Names", "Display player names", false, function(value)
    Settings.ESP_ShowNames = value
end)

FiltersSection:CreateToggle("Show Distance", "Display distance to players", false, function(value)
    Settings.ESP_ShowDistance = value
end)

FiltersSection:CreateToggle("Team Check", "Don't show teammates", false, function(value)
    Settings.ESP_TeamCheck = value
end)

-- Misc Tab
local MiscTab = Window:CreateTab("Misc")
local MiscSection = MiscTab:CreateSection("Player")

MiscSection:CreateSlider("WalkSpeed", "Change walk speed", 16, 200, 16, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
    end
end)

MiscSection:CreateSlider("JumpPower", "Change jump power", 50, 300, 50, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = value
    end
end)

MiscSection:CreateSeparator()

MiscSection:CreateButton("Rejoin", "Rejoin the server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- Configs Tab
local ConfigsTab = Window:CreateTab("Configs")
local ConfigsSection = ConfigsTab:CreateSection("Settings")

ConfigsSection:CreateButton("Reset All", "Reset all settings to default", function()
    Library:Notify("Reset", "Please rejoin to reset all settings", 3)
end)

ConfigsSection:CreateLabel("Press RightCtrl to toggle UI")

-- ============================================
-- MAIN LOOPS
-- ============================================

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

-- Player added/removed
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Main loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle position
    if Settings.Aimbot_ShowFOV then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Settings.Aimbot_FOV
    end
    
    -- Update ESP
    if Settings.ESP_Enabled then
        UpdateESP()
    end
    
    -- Aimbot
    if Settings.Aimbot_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.Aimbot_TargetPart)
            if targetPart then
                local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local delta = Vector2.new(targetPos.X - mousePos.X, targetPos.Y - mousePos.Y)
                
                mousemoverel(delta.X / Settings.Aimbot_Smoothness, delta.Y / Settings.Aimbot_Smoothness)
            end
        end
    end
end)

-- Notify
Library:Notify("Nexus | Free", "Script loaded successfully!", 5)
