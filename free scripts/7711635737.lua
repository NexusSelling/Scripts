--[[
    Nexus | Free - PlaceID: 7711635737
    ESP & Visuals Script - Emergency Hamburg
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
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- ANTI-CHEAT BYPASS (Emergency Hamburg)
-- ============================================
local function SetupBypass()
    pcall(function()
        -- Disable common anti-cheat methods
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        local oldIndex = mt.__index
        
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Block kick attempts
            if method == "Kick" and self == LocalPlayer then
                return nil
            end
            
            -- Block anti-cheat remote calls
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = tostring(self)
                if string.find(string.lower(remoteName), "anticheat") or 
                   string.find(string.lower(remoteName), "detect") or
                   string.find(string.lower(remoteName), "ban") or
                   string.find(string.lower(remoteName), "kick") or
                   string.find(string.lower(remoteName), "security") then
                    return nil
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        mt.__index = newcclosure(function(self, key)
            -- Spoof WalkSpeed/JumpPower checks
            if self == LocalPlayer.Character and (key == "WalkSpeed" or key == "JumpPower") then
                local humanoid = self:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if key == "WalkSpeed" then return 16 end
                    if key == "JumpPower" then return 50 end
                end
            end
            return oldIndex(self, key)
        end)
        
        setreadonly(mt, true)
    end)
    
    -- Hookfunction bypass
    pcall(function()
        if hookfunction then
            local oldCheck = checkcaller
            hookfunction(checkcaller, function()
                return true
            end)
        end
    end)
end

SetupBypass()

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

-- ============================================
-- CONFIG SYSTEM
-- ============================================
local ConfigFolder = "NexusConfigs"
local ConfigExtension = ".json"

local function EnsureConfigFolder()
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

local function GetConfigList()
    EnsureConfigFolder()
    local configs = {}
    for _, file in pairs(listfiles(ConfigFolder)) do
        if string.find(file, ConfigExtension) then
            local name = string.gsub(file, ConfigFolder .. "/", "")
            name = string.gsub(name, ConfigExtension, "")
            table.insert(configs, name)
        end
    end
    return configs
end

local function SaveConfig(name)
    EnsureConfigFolder()
    local configData = HttpService:JSONEncode(Settings)
    writefile(ConfigFolder .. "/" .. name .. ConfigExtension, configData)
    Library:Notify("Config", "Saved config: " .. name, 3)
end

local function LoadConfig(name)
    EnsureConfigFolder()
    local path = ConfigFolder .. "/" .. name .. ConfigExtension
    if isfile(path) then
        local data = readfile(path)
        local loaded = HttpService:JSONDecode(data)
        for key, value in pairs(loaded) do
            Settings[key] = value
        end
        Library:Notify("Config", "Loaded config: " .. name, 3)
        return true
    end
    Library:Notify("Error", "Config not found: " .. name, 3)
    return false
end

local function DeleteConfig(name)
    EnsureConfigFolder()
    local path = ConfigFolder .. "/" .. name .. ConfigExtension
    if isfile(path) then
        delfile(path)
        Library:Notify("Config", "Deleted config: " .. name, 3)
        return true
    end
    return false
end

-- Settings (wird von Config System genutzt)
Settings = {
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
    
    -- Self
    Noclip_Enabled = false,
    Noclip_Key = Enum.KeyCode.N,
    Noclip_Speed = 1,
    
    -- Vehicle
    VehicleFly_Enabled = false,
    VehicleFly_Key = Enum.KeyCode.V,
    VehicleFly_Speed = 50,
}

-- ESP Storage
local ESPObjects = {}

-- ============================================
-- TEAM COLORS (Farben je nach Team/Job)
-- ============================================
local TeamColors = {
    ["Police"] = Color3.fromRGB(0, 120, 255),
    ["Polizei"] = Color3.fromRGB(0, 120, 255),
    ["Sheriff"] = Color3.fromRGB(0, 120, 255),
    ["SWAT"] = Color3.fromRGB(0, 80, 200),
    ["SEK"] = Color3.fromRGB(0, 80, 200),
    ["FBI"] = Color3.fromRGB(0, 60, 180),
    ["Cop"] = Color3.fromRGB(0, 120, 255),
    
    ["Medic"] = Color3.fromRGB(0, 255, 100),
    ["EMS"] = Color3.fromRGB(0, 255, 100),
    ["Rettungsdienst"] = Color3.fromRGB(0, 255, 100),
    ["Doctor"] = Color3.fromRGB(0, 255, 100),
    ["Arzt"] = Color3.fromRGB(0, 255, 100),
    ["Paramedic"] = Color3.fromRGB(0, 255, 100),
    ["Sanitäter"] = Color3.fromRGB(0, 255, 100),
    
    ["Firefighter"] = Color3.fromRGB(255, 100, 0),
    ["Feuerwehr"] = Color3.fromRGB(255, 100, 0),
    ["Fire"] = Color3.fromRGB(255, 100, 0),
    
    ["Criminal"] = Color3.fromRGB(255, 0, 0),
    ["Verbrecher"] = Color3.fromRGB(255, 0, 0),
    ["Prisoner"] = Color3.fromRGB(255, 150, 0),
    ["Gefangener"] = Color3.fromRGB(255, 150, 0),
    ["Inmate"] = Color3.fromRGB(255, 150, 0),
    ["Gang"] = Color3.fromRGB(180, 0, 50),
    
    ["Civilian"] = Color3.fromRGB(200, 200, 200),
    ["Zivilist"] = Color3.fromRGB(200, 200, 200),
    ["Citizen"] = Color3.fromRGB(200, 200, 200),
    ["Bürger"] = Color3.fromRGB(200, 200, 200),
    
    ["Default"] = Color3.fromRGB(255, 255, 255),
}

local function GetTeamColor(player)
    if player.Team then
        local teamName = player.Team.Name
        if TeamColors[teamName] then
            return TeamColors[teamName], teamName
        end
        for keyword, color in pairs(TeamColors) do
            if string.find(string.lower(teamName), string.lower(keyword)) then
                return color, teamName
            end
        end
        if player.Team.TeamColor then
            return player.Team.TeamColor.Color, teamName
        end
        return TeamColors["Default"], teamName
    end
    return TeamColors["Default"], "Unknown"
end

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
    }
    
    espHolder.Box.Thickness = 2
    espHolder.Box.Color = Color3.fromRGB(255, 255, 255)
    espHolder.Box.Filled = false
    espHolder.Box.Visible = false
    
    espHolder.Name.Size = 14
    espHolder.Name.Color = Color3.fromRGB(255, 255, 255)
    espHolder.Name.Center = true
    espHolder.Name.Outline = true
    espHolder.Name.Visible = false
    
    espHolder.Distance.Size = 12
    espHolder.Distance.Color = Color3.fromRGB(200, 200, 200)
    espHolder.Distance.Center = true
    espHolder.Distance.Outline = true
    espHolder.Distance.Visible = false
    
    espHolder.HealthBarOutline.Thickness = 1
    espHolder.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    espHolder.HealthBarOutline.Filled = true
    espHolder.HealthBarOutline.Visible = false
    
    espHolder.HealthBar.Thickness = 1
    espHolder.HealthBar.Filled = true
    espHolder.HealthBar.Visible = false
    
    ESPObjects[player] = espHolder
end

local function RemoveESP(player)
    local esp = ESPObjects[player]
    if esp then
        for _, drawing in pairs(esp) do
            if drawing and drawing.Remove then
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
        
        if Settings.ESP_TeamCheck and player.Team == LocalPlayer.Team then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarOutline.Visible = false
            continue
        end
        
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
        local teamColor, teamName = GetTeamColor(player)
        
        if Settings.ESP_Enabled and Settings.ESP_Chams then
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Position = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y)
            esp.Box.Color = teamColor
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        if Settings.ESP_Enabled and Settings.ESP_ShowNames then
            esp.Name.Text = "[" .. teamName .. "] " .. player.Name
            esp.Name.Position = Vector2.new(rootPos.X, headPos.Y - 18)
            esp.Name.Color = teamColor
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        if Settings.ESP_Enabled and Settings.ESP_ShowDistance then
            esp.Distance.Text = math.floor(distance) .. "m"
            esp.Distance.Position = Vector2.new(rootPos.X, legPos.Y + 5)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        if Settings.ESP_Enabled and Settings.ESP_HealthBars then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = boxHeight
            local barWidth = 3
            
            esp.HealthBarOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
            esp.HealthBarOutline.Position = Vector2.new(rootPos.X - boxWidth / 2 - barWidth - 5, headPos.Y - 1)
            esp.HealthBarOutline.Visible = true
            
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
-- NOCLIP SYSTEM
-- ============================================
local NoclipConnection = nil

local function EnableNoclip()
    if NoclipConnection then return end
    
    NoclipConnection = RunService.Stepped:Connect(function()
        if Settings.Noclip_Enabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- ============================================
-- VEHICLE FLY SYSTEM
-- ============================================
local VehicleFlyConnection = nil
local FlyingVehicle = nil
local BodyGyro = nil
local BodyVelocity = nil

local function GetCurrentVehicle()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        local seat = humanoid.SeatPart
        local vehicle = seat:FindFirstAncestorOfClass("Model")
        if vehicle then
            return vehicle, seat
        end
    end
    return nil
end

local function EnableVehicleFly()
    local vehicle, seat = GetCurrentVehicle()
    if not vehicle then
        Library:Notify("Vehicle Fly", "Du sitzt in keinem Fahrzeug!", 3)
        Settings.VehicleFly_Enabled = false
        return
    end
    
    FlyingVehicle = vehicle
    local primaryPart = vehicle.PrimaryPart or seat
    
    -- Create BodyGyro
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BodyGyro.P = 10000
    BodyGyro.D = 100
    BodyGyro.CFrame = primaryPart.CFrame
    BodyGyro.Parent = primaryPart
    
    -- Create BodyVelocity
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.Parent = primaryPart
    
    VehicleFlyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.VehicleFly_Enabled or not FlyingVehicle or not FlyingVehicle.Parent then
            DisableVehicleFly()
            return
        end
        
        local primaryPart = FlyingVehicle.PrimaryPart or seat
        if not primaryPart or not BodyGyro or not BodyVelocity then return end
        
        BodyGyro.CFrame = Camera.CFrame
        
        local moveDirection = Vector3.new(0, 0, 0)
        local speed = Settings.VehicleFly_Speed
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * speed
        end
        
        BodyVelocity.Velocity = moveDirection
    end)
    
    Library:Notify("Vehicle Fly", "Aktiviert! WASD + Space/Ctrl", 3)
end

local function DisableVehicleFly()
    if VehicleFlyConnection then
        VehicleFlyConnection:Disconnect()
        VehicleFlyConnection = nil
    end
    
    if BodyGyro then
        BodyGyro:Destroy()
        BodyGyro = nil
    end
    
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    
    FlyingVehicle = nil
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

-- ========== SELF TAB ==========
local SelfTab = Window:CreateTab("Self")
local NoclipSection = SelfTab:CreateSection("Noclip")

local NoclipToggle = NoclipSection:CreateToggle("Enable Noclip", "Durch Wände gehen", false, function(value)
    Settings.Noclip_Enabled = value
    if value then
        EnableNoclip()
        Library:Notify("Noclip", "Aktiviert!", 2)
    else
        DisableNoclip()
        Library:Notify("Noclip", "Deaktiviert!", 2)
    end
end)

NoclipSection:CreateKeybind("Noclip Key", "Toggle Noclip", Enum.KeyCode.N, function()
    Settings.Noclip_Enabled = not Settings.Noclip_Enabled
    NoclipToggle:Set(Settings.Noclip_Enabled)
    if Settings.Noclip_Enabled then
        EnableNoclip()
        Library:Notify("Noclip", "Aktiviert!", 2)
    else
        DisableNoclip()
        Library:Notify("Noclip", "Deaktiviert!", 2)
    end
end)

NoclipSection:CreateSlider("Noclip Speed", "Bewegungsgeschwindigkeit", 1, 5, 1, function(value)
    Settings.Noclip_Speed = value
end)

-- ========== VEHICLE TAB ==========
local VehicleTab = Window:CreateTab("Vehicle")
local VehicleFlySection = VehicleTab:CreateSection("Vehicle Fly")

local VehicleFlyToggle = VehicleFlySection:CreateToggle("Enable Vehicle Fly", "Fahrzeug fliegen", false, function(value)
    Settings.VehicleFly_Enabled = value
    if value then
        EnableVehicleFly()
    else
        DisableVehicleFly()
        Library:Notify("Vehicle Fly", "Deaktiviert!", 2)
    end
end)

VehicleFlySection:CreateKeybind("Vehicle Fly Key", "Toggle Vehicle Fly", Enum.KeyCode.V, function()
    Settings.VehicleFly_Enabled = not Settings.VehicleFly_Enabled
    VehicleFlyToggle:Set(Settings.VehicleFly_Enabled)
    if Settings.VehicleFly_Enabled then
        EnableVehicleFly()
    else
        DisableVehicleFly()
        Library:Notify("Vehicle Fly", "Deaktiviert!", 2)
    end
end)

VehicleFlySection:CreateSlider("Fly Speed", "Fluggeschwindigkeit", 10, 200, 50, function(value)
    Settings.VehicleFly_Speed = value
end)

VehicleFlySection:CreateLabel("WASD = Bewegung")
VehicleFlySection:CreateLabel("Space = Hoch | Ctrl = Runter")

-- ========== AIMBOT TAB ==========
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

-- ========== VISUALS TAB ==========
local VisualsTab = Window:CreateTab("Visuals")

local ESPSection = VisualsTab:CreateSection("ESP")

ESPSection:CreateToggle("Enable ESP", "Toggle ESP on/off", false, function(value)
    Settings.ESP_Enabled = value
end)

ESPSection:CreateToggle("Chams/Boxes", "Team-colored boxes", false, function(value)
    Settings.ESP_Chams = value
end)

ESPSection:CreateToggle("Health Bars", "Show health bars", false, function(value)
    Settings.ESP_HealthBars = value
end)

ESPSection:CreateSlider("Range", "ESP render distance", 100, 2000, 2000, function(value)
    Settings.ESP_Range = value
end)

local FiltersSection = VisualsTab:CreateSection("Filters")

FiltersSection:CreateToggle("Show Names", "[Team] Name display", false, function(value)
    Settings.ESP_ShowNames = value
end)

FiltersSection:CreateToggle("Show Distance", "Display distance to players", false, function(value)
    Settings.ESP_ShowDistance = value
end)

FiltersSection:CreateToggle("Team Check", "Don't show teammates", false, function(value)
    Settings.ESP_TeamCheck = value
end)

-- ========== CONFIGS TAB ==========
local ConfigsTab = Window:CreateTab("Configs")

local ConfigManagerSection = ConfigsTab:CreateSection("Config Manager")

local ConfigNameBox = nil
local ConfigListDropdown = nil
local currentConfigList = GetConfigList()

ConfigNameBox = ConfigManagerSection:CreateTextBox("Config Name", "Name für neue Config", "MyConfig", function(text)
    -- Nothing needed here
end)

ConfigManagerSection:CreateButton("Save Config", "Aktuelle Einstellungen speichern", function()
    local name = ConfigNameBox:Get()
    if name and name ~= "" then
        SaveConfig(name)
        -- Update dropdown
        currentConfigList = GetConfigList()
        if ConfigListDropdown then
            ConfigListDropdown:SetOptions(currentConfigList)
        end
    else
        Library:Notify("Error", "Bitte Config-Namen eingeben!", 3)
    end
end)

ConfigManagerSection:CreateSeparator()

ConfigListDropdown = ConfigManagerSection:CreateDropdown("Config List", "Verfügbare Configs", currentConfigList, currentConfigList[1] or "", function(selected)
    -- Nothing needed here
end)

ConfigManagerSection:CreateButton("Load Config", "Ausgewählte Config laden", function()
    local selected = ConfigListDropdown:Get()
    if selected and selected ~= "" then
        LoadConfig(selected)
    else
        Library:Notify("Error", "Bitte Config auswählen!", 3)
    end
end)

ConfigManagerSection:CreateButton("Delete Config", "Ausgewählte Config löschen", function()
    local selected = ConfigListDropdown:Get()
    if selected and selected ~= "" then
        DeleteConfig(selected)
        currentConfigList = GetConfigList()
        if ConfigListDropdown then
            ConfigListDropdown:SetOptions(currentConfigList)
        end
    else
        Library:Notify("Error", "Bitte Config auswählen!", 3)
    end
end)

ConfigManagerSection:CreateButton("Refresh List", "Config-Liste aktualisieren", function()
    currentConfigList = GetConfigList()
    if ConfigListDropdown then
        ConfigListDropdown:SetOptions(currentConfigList)
    end
    Library:Notify("Configs", "Liste aktualisiert!", 2)
end)

-- Team Colors Info
local InfoSection = ConfigsTab:CreateSection("Team Farben")
InfoSection:CreateLabel("Polizei = Blau")
InfoSection:CreateLabel("Rettungsdienst = Grün")
InfoSection:CreateLabel("Feuerwehr = Orange")
InfoSection:CreateLabel("Verbrecher = Rot")
InfoSection:CreateLabel("Zivilist = Weiß")

ConfigsTab:CreateSection("Info"):CreateLabel("Press RightCtrl to toggle UI")

-- ============================================
-- KEYBIND HANDLER
-- ============================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- Noclip Toggle
    if input.KeyCode == Settings.Noclip_Key then
        Settings.Noclip_Enabled = not Settings.Noclip_Enabled
        NoclipToggle:Set(Settings.Noclip_Enabled)
        if Settings.Noclip_Enabled then
            EnableNoclip()
        else
            DisableNoclip()
        end
    end
    
    -- Vehicle Fly Toggle
    if input.KeyCode == Settings.VehicleFly_Key then
        Settings.VehicleFly_Enabled = not Settings.VehicleFly_Enabled
        VehicleFlyToggle:Set(Settings.VehicleFly_Enabled)
        if Settings.VehicleFly_Enabled then
            EnableVehicleFly()
        else
            DisableVehicleFly()
        end
    end
end)

-- ============================================
-- MAIN LOOPS
-- ============================================

for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot_ShowFOV then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Settings.Aimbot_FOV
    end
    
    if Settings.ESP_Enabled then
        UpdateESP()
    end
    
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
Library:Notify("Nexus | Free", "Script loaded!", 3)
task.wait(0.5)
Library:Notify("Bypass", "Anti-Cheat Bypass aktiv!", 3)
