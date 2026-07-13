local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = {
    AimbotEnabled = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotSmoothing = 5,
    AimbotFOV = 150,
    ShowFOV = false,
    AimbotTarget = "Head", -- "Head" or "Torso"
    
    HitboxEnabled = false,
    HitboxSize = 10,
    
    TriggerBotEnabled = false,
    TriggerBotDelay = 0.05,
    
    GlobalVisCheck = false,
    
    ESPEnabled = false,
    BoxESP = false,
    HealthBarESP = false,
    SkeletonESP = false,
    NameESP = false,
    DistanceESP = false,
    SnaplineESP = false,
    TracerESP = false,
    
    EnemyColor = Color3.fromRGB(255, 50, 50),
    TeamColor = Color3.fromRGB(50, 255, 50),
    VisibleColor = Color3.fromRGB(50, 255, 50),
    NotVisibleColor = Color3.fromRGB(255, 50, 50),
    ColorByVisibility = false,
    
    ChamsEnabled = false,
    
    Fullbright = false,
    CameraFOV = 70,
    GravityModifier = 196.2,
    RemoveFog = false,
    
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    InfiniteJump = false,
    FlyEnabled = false,
    FlySpeed = 60,
    
    AntiAFK = false,
    SpinBot = false,
    SpinSpeed = 20,
    LongReach = false,
    ReachDistance = 20,
    AutoRespawn = false,
    ClickTP = false,
    
    ThirdPerson = false,
    ThirdPersonDist = 15,
    
    KB_ThirdPerson = "T",
    KB_SpinBot = "X",
}

local ConfigFileName = "Jailbird_Config.json"

local function SaveConfig()
    if writefile then
        pcall(function()
            local saveable = {}
            for k, v in pairs(Config) do
                if typeof(v) ~= "EnumItem" and typeof(v) ~= "Color3" then
                    saveable[k] = v
                end
            end
            writefile(ConfigFileName, HttpService:JSONEncode(saveable))
        end)
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(ConfigFileName) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFileName))
        end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if Config[k] ~= nil then
                    Config[k] = v
                end
            end
        end
    end
end

LoadConfig()

task.spawn(function()
    while task.wait(3) do
        SaveConfig()
    end
end)

local ESP_Cache = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5

local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    return true
end

local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local targetPos = targetPart.Position
    
    local ignoreList = {LocalPlayer.Character, targetPart.Parent}
    
    local obscuringParts = Camera:GetPartsObscuringTarget({origin, targetPos}, ignoreList)
    
    for _, part in ipairs(obscuringParts) do
        if part.Transparency >= 0.5 or not part.CanCollide then
            continue
        end
        
        return false
    end
    
    return true
end

local function GetCharacterParts(char)
    if not char then return nil end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if not (head and root and hum) then return nil end
    
    return {
        Head = head,
        Torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
        Root = root,
        Humanoid = hum,
        LeftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
        RightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
        LeftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
        RightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
        LeftLowerArm = char:FindFirstChild("LeftLowerArm") or char:FindFirstChild("Left Arm"),
        RightLowerArm = char:FindFirstChild("RightLowerArm") or char:FindFirstChild("Right Arm"),
        LeftLowerLeg = char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("Left Leg"),
        RightLowerLeg = char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg"),
        LeftHand = char:FindFirstChild("LeftHand"),
        RightHand = char:FindFirstChild("RightHand"),
        LeftFoot = char:FindFirstChild("LeftFoot"),
        RightFoot = char:FindFirstChild("RightFoot"),
    }
end

local function GetESPColor(player, parts)
    if Config.ColorByVisibility and parts and parts.Head then
        if IsVisible(parts.Head) then
            return Config.VisibleColor
        else
            return Config.NotVisibleColor
        end
    end
    
    if IsEnemy(player) then
        return Config.EnemyColor
    end
    return Config.TeamColor
end

local function CreateESP(player)
    local esp = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        HealthBarBG = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        ShieldBar = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Snapline = Drawing.new("Line"),
        Tracer = Drawing.new("Line"),
        
        HeadToNeck = Drawing.new("Line"),
        NeckToTorso = Drawing.new("Line"),
        TorsoToHip = Drawing.new("Line"),
        LShoulderToElbow = Drawing.new("Line"),
        LElbowToHand = Drawing.new("Line"),
        RShoulderToElbow = Drawing.new("Line"),
        RElbowToHand = Drawing.new("Line"),
        LHipToKnee = Drawing.new("Line"),
        LKneeToFoot = Drawing.new("Line"),
        RHipToKnee = Drawing.new("Line"),
        RKneeToFoot = Drawing.new("Line"),
    }
    
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Color = Color3.new(0, 0, 0)
    esp.BoxOutline.Filled = false
    
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    
    esp.HealthBarBG.Thickness = 4
    esp.HealthBarBG.Color = Color3.new(0, 0, 0)
    
    esp.HealthBar.Thickness = 2
    
    esp.ShieldBar.Thickness = 2
    esp.ShieldBar.Color = Color3.fromRGB(50, 150, 255)
    
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Font = 2 -- Plex

    esp.Distance.Size = 13
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Font = 2
    
    esp.Snapline.Thickness = 1
    esp.Snapline.Color = Color3.fromRGB(255, 255, 255)
    esp.Snapline.Transparency = 0.5
    
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 0.6

    local skeletonKeys = {
        "HeadToNeck", "NeckToTorso", "TorsoToHip",
        "LShoulderToElbow", "LElbowToHand", "RShoulderToElbow", "RElbowToHand",
        "LHipToKnee", "LKneeToFoot", "RHipToKnee", "RKneeToFoot"
    }
    for _, key in ipairs(skeletonKeys) do
        esp[key].Thickness = 1.5
        esp[key].Color = Color3.new(1, 1, 1)
    end
    
    ESP_Cache[player] = esp
end

local function RemoveESP(player)
    if ESP_Cache[player] then
        for _, drawing in pairs(ESP_Cache[player]) do
            drawing.Visible = false
            pcall(function() drawing:Remove() end)
        end
        ESP_Cache[player] = nil
    end
end

local function HideAllESP(esp)
    for _, drawing in pairs(esp) do
        drawing.Visible = false
    end
end

local function W2S(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function DrawBone(line, from3D, to3D, color)
    local fromS, fromOn = W2S(from3D)
    local toS, toOn = W2S(to3D)
    if fromOn and toOn then
        line.From = fromS
        line.To = toS
        line.Color = color
        line.Visible = true
    else
        line.Visible = false
    end
end

local function UpdateESP()
    for player, esp in pairs(ESP_Cache) do
        if not player or not player.Parent then
            HideAllESP(esp)
            for _, drawing in pairs(esp) do pcall(function() drawing:Remove() end) end
            ESP_Cache[player] = nil
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if not ESP_Cache[player] then CreateESP(player) end
        local esp = ESP_Cache[player]
        
        local char = player.Character
        local parts = char and GetCharacterParts(char) or nil
        
        local isAlive = parts and parts.Humanoid and parts.Humanoid.Health > 0
        local isEnemy = IsEnemy(player)
        
        local shouldShow = Config.ESPEnabled and isAlive and isEnemy
        
        if shouldShow then
            local headPos, headOn, headZ = Camera:WorldToViewportPoint(parts.Head.Position + Vector3.new(0, 0.5, 0))
            local rootPos = Camera:WorldToViewportPoint(parts.Root.Position)
            local legPos = Camera:WorldToViewportPoint(parts.Root.Position - Vector3.new(0, 3, 0))
            
            if rootPos.Z > 0 then
                local espColor = GetESPColor(player, parts)
                
                local boxHeight = math.abs(headPos.Y - legPos.Y)
                local boxWidth = boxHeight / 2
                local boxPos = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y)
                local boxSize = Vector2.new(boxWidth, boxHeight)
                
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                    and (LocalPlayer.Character.HumanoidRootPart.Position - parts.Root.Position).Magnitude
                    or 0
                local distStuds = math.floor(distance)
                
                if Config.BoxESP then
                    esp.BoxOutline.Size = boxSize
                    esp.BoxOutline.Position = boxPos
                    esp.BoxOutline.Visible = true
                    
                    esp.Box.Size = boxSize
                    esp.Box.Position = boxPos
                    esp.Box.Color = espColor
                    esp.Box.Visible = true
                else
                    esp.BoxOutline.Visible = false
                    esp.Box.Visible = false
                end
                
                if Config.HealthBarESP then
                    local healthPct = math.clamp(parts.Humanoid.Health / parts.Humanoid.MaxHealth, 0, 1)
                    local barHeight = boxHeight * healthPct
                    
                    esp.HealthBarBG.From = Vector2.new(boxPos.X - 6, boxPos.Y)
                    esp.HealthBarBG.To = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight)
                    esp.HealthBarBG.Visible = true
                    
                    esp.HealthBar.From = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight)
                    esp.HealthBar.To = Vector2.new(boxPos.X - 6, boxPos.Y + boxHeight - barHeight)
                    esp.HealthBar.Color = Color3.fromHSV(healthPct * 0.3, 1, 1)
                    esp.HealthBar.Visible = true
                else
                    esp.HealthBarBG.Visible = false
                    esp.HealthBar.Visible = false
                end
                esp.ShieldBar.Visible = false
                
                if Config.NameESP then
                    local healthText = string.format("[%d HP]", math.floor(parts.Humanoid.Health))
                    esp.Name.Text = player.DisplayName .. " " .. healthText
                    esp.Name.Position = Vector2.new(rootPos.X, boxPos.Y - 18)
                    esp.Name.Color = espColor
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end
                
                if Config.DistanceESP then
                    esp.Distance.Text = string.format("[%d studs]", distStuds)
                    esp.Distance.Position = Vector2.new(rootPos.X, boxPos.Y + boxHeight + 3)
                    esp.Distance.Visible = true
                else
                    esp.Distance.Visible = false
                end
                
                if Config.SnaplineESP then
                    local viewportSize = Camera.ViewportSize
                    esp.Snapline.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                    esp.Snapline.To = Vector2.new(rootPos.X, rootPos.Y)
                    esp.Snapline.Color = espColor
                    esp.Snapline.Visible = true
                else
                    esp.Snapline.Visible = false
                end
                
                if Config.TracerESP then
                    local viewportSize = Camera.ViewportSize
                    esp.Tracer.From = Vector2.new(viewportSize.X / 2, 0)
                    esp.Tracer.To = Vector2.new(headPos.X, headPos.Y)
                    esp.Tracer.Color = espColor
                    esp.Tracer.Visible = true
                else
                    esp.Tracer.Visible = false
                end
                
                if Config.SkeletonESP and parts.Torso then
                    local skelColor = espColor
                    local headP = parts.Head.Position
                    local torsoP = parts.Torso.Position
                    local hipP = parts.Root.Position
                    
                    DrawBone(esp.HeadToNeck, headP, torsoP + Vector3.new(0, 0.8, 0), skelColor)
                    DrawBone(esp.NeckToTorso, torsoP + Vector3.new(0, 0.8, 0), torsoP, skelColor)
                    DrawBone(esp.TorsoToHip, torsoP, hipP, skelColor)
                    
                    if parts.LeftArm then
                        DrawBone(esp.LShoulderToElbow, torsoP + Vector3.new(0, 0.5, 0), parts.LeftArm.Position, skelColor)
                    else esp.LShoulderToElbow.Visible = false end
                    
                    if parts.LeftLowerArm and parts.LeftArm then
                        DrawBone(esp.LElbowToHand, parts.LeftArm.Position, parts.LeftLowerArm.Position, skelColor)
                    elseif parts.LeftArm then
                        esp.LElbowToHand.Visible = false
                    else esp.LElbowToHand.Visible = false end
                    
                    if parts.RightArm then
                        DrawBone(esp.RShoulderToElbow, torsoP + Vector3.new(0, 0.5, 0), parts.RightArm.Position, skelColor)
                    else esp.RShoulderToElbow.Visible = false end
                    
                    if parts.RightLowerArm and parts.RightArm then
                        DrawBone(esp.RElbowToHand, parts.RightArm.Position, parts.RightLowerArm.Position, skelColor)
                    elseif parts.RightArm then
                        esp.RElbowToHand.Visible = false
                    else esp.RElbowToHand.Visible = false end
                    
                    if parts.LeftLeg then
                        DrawBone(esp.LHipToKnee, hipP, parts.LeftLeg.Position, skelColor)
                    else esp.LHipToKnee.Visible = false end
                    
                    if parts.LeftLowerLeg and parts.LeftLeg then
                        DrawBone(esp.LKneeToFoot, parts.LeftLeg.Position, parts.LeftLowerLeg.Position, skelColor)
                    else esp.LKneeToFoot.Visible = false end
                    
                    if parts.RightLeg then
                        DrawBone(esp.RHipToKnee, hipP, parts.RightLeg.Position, skelColor)
                    else esp.RHipToKnee.Visible = false end
                    
                    if parts.RightLowerLeg and parts.RightLeg then
                        DrawBone(esp.RKneeToFoot, parts.RightLeg.Position, parts.RightLowerLeg.Position, skelColor)
                    else esp.RKneeToFoot.Visible = false end
                else
                    esp.HeadToNeck.Visible = false
                    esp.NeckToTorso.Visible = false
                    esp.TorsoToHip.Visible = false
                    esp.LShoulderToElbow.Visible = false
                    esp.LElbowToHand.Visible = false
                    esp.RShoulderToElbow.Visible = false
                    esp.RElbowToHand.Visible = false
                    esp.LHipToKnee.Visible = false
                    esp.LKneeToFoot.Visible = false
                    esp.RHipToKnee.Visible = false
                    esp.RKneeToFoot.Visible = false
                end
                
            else
                HideAllESP(esp)
            end
        else
            HideAllESP(esp)
        end
    end
end

local AimbotTarget = nil
local IsAiming = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Config.AimbotKey then
        IsAiming = true
    end
    if Config.InfiniteJump and input.KeyCode == Enum.KeyCode.Space then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name
        
        if key == Config.KB_ThirdPerson then
            Config.ThirdPerson = not Config.ThirdPerson
            UpdateThirdPerson()
        elseif key == Config.KB_SpinBot then
            Config.SpinBot = not Config.SpinBot
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.AimbotKey then
        IsAiming = false
        AimbotTarget = nil
    end
end)

local function GetClosestToMouse()
    local closestDist = Config.AimbotFOV
    local closestPlayer = nil
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not IsEnemy(player) then continue end
        
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("Head") then
            local targetPart = char:FindFirstChild(Config.AimbotTarget) or char.Head
            
            if Config.GlobalVisCheck and not IsVisible(targetPart) then
                continue
            end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function UpdateAimbot()
    if Config.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Config.AimbotFOV
    else
        FOVCircle.Visible = false
    end

    if Config.AimbotEnabled and IsAiming then
        AimbotTarget = GetClosestToMouse()
        if AimbotTarget and AimbotTarget.Character then
            local targetPart = AimbotTarget.Character:FindFirstChild(Config.AimbotTarget) or AimbotTarget.Character:FindFirstChild("Head")
            if targetPart then
                local targetPos = targetPart.Position
                if Config.AimbotSmoothing > 1 then
                    local currentCFrame = Camera.CFrame
                    local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
                    Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / Config.AimbotSmoothing)
                else
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                end
            end
        end
    end
end

local function UpdateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local char = player.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") then
                local head = char.Head
                if char.Humanoid.Health > 0 then
                    local shouldExpand = Config.HitboxEnabled
                    if shouldExpand and Config.GlobalVisCheck then
                        shouldExpand = IsVisible(head)
                    end
                    
                    if shouldExpand then
                        head.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                        head.Transparency = 0.7
                        head.BrickColor = BrickColor.new("Really red")
                        head.Material = Enum.Material.Neon
                        head.CanCollide = false
                    else
                        head.Size = Vector3.new(1.2, 1.2, 1.2)
                        head.Transparency = 0
                    end
                end
            end
        end
    end
end

local lastTrigger = 0
local VirtualInputManager = game:GetService("VirtualInputManager")

local function UpdateTriggerBot()
    if not Config.TriggerBotEnabled then return end
    
    if tick() - lastTrigger < Config.TriggerBotDelay then return end
    
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    
    if target and target.Parent then
        local char = target.Parent
        if char:IsA("Accessory") or char:IsA("Tool") then
            char = char.Parent
        end
        
        local player = Players:GetPlayerFromCharacter(char)
        if player and IsEnemy(player) then
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local shouldShoot = true
                if Config.GlobalVisCheck and target then
                    shouldShoot = IsVisible(target)
                end
                
                if shouldShoot then
                    VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
                    lastTrigger = tick()
                end
            end
        end
    end
end

local originalMinZoom = LocalPlayer.CameraMinZoomDistance
local originalMaxZoom = LocalPlayer.CameraMaxZoomDistance

local function UpdateThirdPerson()
    if Config.ThirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = Config.ThirdPersonDist
        LocalPlayer.CameraMaxZoomDistance = Config.ThirdPersonDist
    else
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = originalMaxZoom
    end
end

local originalAmbient = Lighting.Ambient
local originalBrightness = Lighting.Brightness
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalFogEnd = Lighting.FogEnd

local function UpdateFullbright()
    if Config.Fullbright then
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.FogEnd = 100000
    else
        Lighting.Ambient = originalAmbient
        Lighting.Brightness = originalBrightness
        Lighting.OutdoorAmbient = originalOutdoorAmbient
        Lighting.FogEnd = originalFogEnd
    end
end

local function UpdateNoclip()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

local ChamsCache = {}

local function UpdateChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then
            if ChamsCache[player] then
                ChamsCache[player]:Destroy()
                ChamsCache[player] = nil
            end
            continue
        end
        
        if Config.ChamsEnabled and IsEnemy(player) and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            if not ChamsCache[player] or not ChamsCache[player].Parent then
                local highlight = Instance.new("Highlight")
                highlight.Name = "JB_Chams"
                highlight.FillColor = Color3.fromRGB(255, 0, 80)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = char
                highlight.Parent = CoreGui
                ChamsCache[player] = highlight
            end
            if Config.ColorByVisibility and char:FindFirstChild("Head") then
                if IsVisible(char.Head) then
                    ChamsCache[player].FillColor = Color3.fromRGB(50, 255, 50)
                else
                    ChamsCache[player].FillColor = Color3.fromRGB(255, 50, 50)
                end
            end
        else
            if ChamsCache[player] then
                ChamsCache[player]:Destroy()
                ChamsCache[player] = nil
            end
        end
    end
end

local flyBV = nil
local flyBG = nil

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    if flyBV then pcall(function() flyBV:Destroy() end) end
    if flyBG then pcall(function() flyBG:Destroy() end) end
    
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = root
    
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.D = 200
    flyBG.P = 10000
    flyBG.Parent = root
end

local function StopFly()
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
end

local function UpdateFly()
    if not Config.FlyEnabled then
        if flyBV then StopFly() end
        return
    end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if not flyBV or not flyBV.Parent then
        StartFly()
    end
    
    local root = char.HumanoidRootPart
    local camCF = Camera.CFrame
    local moveDir = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDir = moveDir + camCF.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDir = moveDir - camCF.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDir = moveDir - camCF.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDir = moveDir + camCF.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDir = moveDir + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveDir = moveDir - Vector3.new(0, 1, 0)
    end
    
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
    end
    
    flyBV.Velocity = moveDir * Config.FlySpeed
    flyBG.CFrame = camCF
end

local function SetupAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end
pcall(SetupAntiAFK)

local function UpdateSpinBot()
    if Config.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame 
            * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0)
    end
end

local function UpdateLongReach()
    if Config.LongReach and LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    handle.Size = Vector3.new(Config.ReachDistance, 0.5, Config.ReachDistance)
                    handle.Transparency = 1
                    handle.Massless = true
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoRespawn then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                if char.Humanoid.Health <= 0 then
                    task.wait(0.5)
                    pcall(function()
                        LocalPlayer:LoadCharacter()
                    end)
                end
            end
        end
    end
end)

local Mouse = LocalPlayer:GetMouse()
Mouse.Button1Down:Connect(function()
    if Config.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = Mouse.Hit
            if target then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target + Vector3.new(0, 3, 0)
            end
        end
    end
end)

local function TeleportToClosest()
    local closestDist = math.huge
    local closestChar = nil
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local dist = (myRoot.Position - char.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestChar = char
            end
        end
    end
    
    if closestChar then
        myRoot.CFrame = closestChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
    end
end

local function UpdateRemoveFog()
    if Config.RemoveFog then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        for _, effect in ipairs(Lighting:GetDescendants()) do
            if effect:IsA("Atmosphere") then
                effect.Density = 0
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateHitboxes()
    UpdateAimbot()
    UpdateTriggerBot()
    UpdateNoclip()
    UpdateFly()
    UpdateChams()
    UpdateSpinBot()
    UpdateLongReach()
    
    Camera.FieldOfView = Config.CameraFOV
    
    Workspace.Gravity = Config.GravityModifier
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if Config.WalkSpeed ~= 16 then
            hum.WalkSpeed = Config.WalkSpeed
        end
        if Config.JumpPower ~= 50 then
            hum.JumpPower = Config.JumpPower
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

getgenv().Title = "Jailbird"

local ui_lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/Libary3.lua"))()
local win = ui_lib:NewGui()

local combatTab = win:NewTab("Combat")
local visualsTab = win:NewTab("Visuals")
local playerTab = win:NewTab("Player")
local worldTab = win:NewTab("World")
local settingsTab = win:NewTab("Settings")

settingsTab:NewCheckbox("Global Visibility Check (Wall Check)", function(state)
    Config.GlobalVisCheck = state
end)

settingsTab:NewCheckbox("ESP Color by Visibility", function(state)
    Config.ColorByVisibility = state
end)

settingsTab:NewLabel("--- Keybinds ---")

local keyOptions = {"None","Z","X","C","V","B","N","M","F","G","H","J","K","L","T","Y","U","P","Q","E","R","One","Two","Three","Four","Five"}

settingsTab:NewDropdown("Third Person Toggle [" .. Config.KB_ThirdPerson .. "]", keyOptions, function(sel)
    Config.KB_ThirdPerson = sel
end)

settingsTab:NewDropdown("Spin Bot Toggle [" .. Config.KB_SpinBot .. "]", keyOptions, function(sel)
    Config.KB_SpinBot = sel
end)

combatTab:NewLabel("--- Aimbot ---")

combatTab:NewCheckbox("Enable Aimbot (Hold RMB)", function(state)
    Config.AimbotEnabled = state
end)

combatTab:NewCheckbox("Show FOV Circle", function(state)
    Config.ShowFOV = state
end)

combatTab:NewSlider("Aimbot FOV", 10, 500, true, function(val)
    Config.AimbotFOV = val
end)

combatTab:NewSlider("Smoothing (1 = Snap)", 1, 20, true, function(val)
    Config.AimbotSmoothing = val
end)

combatTab:NewDropdown("Aim Target", {"Head", "Torso", "HumanoidRootPart"}, function(selected)
    Config.AimbotTarget = selected
end)

combatTab:NewLabel("--- Hitbox Expander ---")

combatTab:NewCheckbox("Enable Hitbox Expander (Head)", function(state)
    Config.HitboxEnabled = state
end)

combatTab:NewSlider("Hitbox Size", 2, 50, true, function(val)
    Config.HitboxSize = val
end)

combatTab:NewLabel("--- TriggerBot ---")

combatTab:NewCheckbox("Enable TriggerBot", function(state)
    Config.TriggerBotEnabled = state
end)

combatTab:NewSlider("Trigger Delay (ms)", 0, 500, true, function(val)
    Config.TriggerBotDelay = val / 1000
end)

visualsTab:NewLabel("--- ESP Master ---")

visualsTab:NewCheckbox("Enable ESP", function(state)
    Config.ESPEnabled = state
end)

visualsTab:NewLabel("--- ESP Features ---")

visualsTab:NewCheckbox("Box ESP", function(state)
    Config.BoxESP = state
end)

visualsTab:NewCheckbox("Skeleton ESP", function(state)
    Config.SkeletonESP = state
end)

visualsTab:NewCheckbox("HealthBar ESP", function(state)
    Config.HealthBarESP = state
end)

visualsTab:NewCheckbox("Name & Health ESP", function(state)
    Config.NameESP = state
end)

visualsTab:NewCheckbox("Distance ESP", function(state)
    Config.DistanceESP = state
end)

visualsTab:NewCheckbox("Snaplines (Bottom)", function(state)
    Config.SnaplineESP = state
end)

visualsTab:NewCheckbox("Tracers (Top)", function(state)
    Config.TracerESP = state
end)

visualsTab:NewLabel("--- Chams ---")

visualsTab:NewCheckbox("Chams / Highlight ESP", function(state)
    Config.ChamsEnabled = state
    if not state then
        for p, h in pairs(ChamsCache) do
            h:Destroy()
        end
        ChamsCache = {}
    end
end)

playerTab:NewLabel("--- Movement ---")

playerTab:NewSlider("WalkSpeed", 16, 200, true, function(val)
    Config.WalkSpeed = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

playerTab:NewSlider("JumpPower", 50, 300, true, function(val)
    Config.JumpPower = val
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

playerTab:NewLabel("--- Movement Exploits ---")

playerTab:NewCheckbox("Noclip (Walk Through Walls)", function(state)
    Config.Noclip = state
end)

playerTab:NewCheckbox("Infinite Jump", function(state)
    Config.InfiniteJump = state
end)

playerTab:NewCheckbox("Fly (WASD + Space/Shift)", function(state)
    Config.FlyEnabled = state
    if not state then StopFly() end
end)

playerTab:NewSlider("Fly Speed", 10, 300, true, function(val)
    Config.FlySpeed = val
end)

playerTab:NewLabel("--- Combat Exploits ---")

playerTab:NewCheckbox("Spin Bot (Troll)", function(state)
    Config.SpinBot = state
end)

playerTab:NewSlider("Spin Speed", 5, 60, true, function(val)
    Config.SpinSpeed = val
end)

playerTab:NewCheckbox("Long Reach (Tool Range)", function(state)
    Config.LongReach = state
end)

playerTab:NewSlider("Reach Distance", 5, 100, true, function(val)
    Config.ReachDistance = val
end)

playerTab:NewCheckbox("Auto Respawn", function(state)
    Config.AutoRespawn = state
end)

worldTab:NewLabel("--- Camera ---")

worldTab:NewCheckbox("Third Person [" .. Config.KB_ThirdPerson .. "]", function(state)
    Config.ThirdPerson = state
    UpdateThirdPerson()
end)

worldTab:NewSlider("Third Person Distance", 5, 50, true, function(val)
    Config.ThirdPersonDist = val
    if Config.ThirdPerson then UpdateThirdPerson() end
end)

worldTab:NewLabel("--- Lighting ---")

worldTab:NewCheckbox("Fullbright (Remove Darkness)", function(state)
    Config.Fullbright = state
    UpdateFullbright()
end)

worldTab:NewCheckbox("Remove Fog", function(state)
    Config.RemoveFog = state
    UpdateRemoveFog()
end)

worldTab:NewSlider("Camera FOV", 30, 120, true, function(val)
    Config.CameraFOV = val
end)

worldTab:NewSlider("Gravity (196 = Normal)", 0, 400, true, function(val)
    Config.GravityModifier = val
end)

worldTab:NewLabel("--- Teleport ---")

worldTab:NewCheckbox("Click TP (Ctrl + Click)", function(state)
    Config.ClickTP = state
end)

worldTab:NewCheckbox("Anti-AFK", function(state)
    Config.AntiAFK = state
end)

task.delay(0.6, function()
    local gui = nil
    for _, v in pairs(CoreGui:GetDescendants()) do
        if v:IsA("StringValue") and v.Name == "dizzy_hub" then
            gui = v.Parent
            break
        end
    end
    if not gui then return end
    
    local checkboxMap = {
        ["Global Visibility Check (Wall Check)"] = "GlobalVisCheck",
        ["ESP Color by Visibility"] = "ColorByVisibility",
        ["Enable Aimbot (Hold RMB)"] = "AimbotEnabled",
        ["Show FOV Circle"] = "ShowFOV",
        ["Enable Hitbox Expander (Head)"] = "HitboxEnabled",
        ["Enable TriggerBot"] = "TriggerBotEnabled",
        ["Enable ESP"] = "ESPEnabled",
        ["Box ESP"] = "BoxESP",
        ["Skeleton ESP"] = "SkeletonESP",
        ["HealthBar ESP"] = "HealthBarESP",
        ["Name & Health ESP"] = "NameESP",
        ["Distance ESP"] = "DistanceESP",
        ["Snaplines (Bottom)"] = "SnaplineESP",
        ["Tracers (Top)"] = "TracerESP",
        ["Chams / Highlight ESP"] = "ChamsEnabled",
        ["Noclip (Walk Through Walls)"] = "Noclip",
        ["Infinite Jump"] = "InfiniteJump",
        ["Fly (WASD + Space/Shift)"] = "FlyEnabled",
        ["Spin Bot (Troll)"] = "SpinBot",
        ["Long Reach (Tool Range)"] = "LongReach",
        ["Auto Respawn"] = "AutoRespawn",
        ["Third Person [" .. Config.KB_ThirdPerson .. "]"] = "ThirdPerson",
        ["Fullbright (Remove Darkness)"] = "Fullbright",
        ["Remove Fog"] = "RemoveFog",
        ["Click TP (Ctrl + Click)"] = "ClickTP",
        ["Anti-AFK"] = "AntiAFK",
    }
    
    local sliderMap = {
        ["Aimbot FOV"] = {"AimbotFOV", 10, 500},
        ["Smoothing (1 = Snap)"] = {"AimbotSmoothing", 1, 20},
        ["Hitbox Size"] = {"HitboxSize", 2, 50},
        ["Trigger Delay (ms)"] = {"TriggerBotDelay", 0, 500},
        ["WalkSpeed"] = {"WalkSpeed", 16, 200},
        ["JumpPower"] = {"JumpPower", 50, 300},
        ["Fly Speed"] = {"FlySpeed", 10, 300},
        ["Spin Speed"] = {"SpinSpeed", 5, 60},
        ["Reach Distance"] = {"ReachDistance", 5, 100},
        ["Camera FOV"] = {"CameraFOV", 30, 120},
        ["Gravity (196 = Normal)"] = {"GravityModifier", 0, 400},
        ["Third Person Distance"] = {"ThirdPersonDist", 5, 50},
    }
    
    for _, descendant in pairs(gui:GetDescendants()) do
        if descendant:IsA("Frame") and checkboxMap[descendant.Name] and descendant:FindFirstChild("untoggled") then
            local configKey = checkboxMap[descendant.Name]
            if Config[configKey] == true then
                local untoggled = descendant:FindFirstChild("untoggled")
                if untoggled then
                    local fired = false
                    if firesignal then
                        pcall(function()
                            firesignal(untoggled.MouseButton1Click)
                            fired = true
                        end)
                    end
                    if not fired and fireclickdetector then
                        pcall(function()
                            fireclickdetector(untoggled)
                            fired = true
                        end)
                    end
                    if not fired then
                        local toggled_img = descendant:FindFirstChild("toggled")
                        if toggled_img then
                            untoggled.Visible = false
                            untoggled.ImageTransparency = 1
                            toggled_img.Visible = true
                            toggled_img.ImageTransparency = 0
                        end
                    end
                end
            end
        end
        
        if descendant:IsA("Frame") and sliderMap[descendant.Name] then
            local info = sliderMap[descendant.Name]
            local configKey = info[1]
            local minVal = info[2]
            local maxVal = info[3]
            local val = Config[configKey]
            
            if val and val ~= minVal then
                local pct = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
                
                local textBox = descendant:FindFirstChild("box")
                if textBox then
                    textBox.Text = tostring(val)
                end
                
                local sliderFrame = descendant:FindFirstChild("Slider")
                if sliderFrame then
                    local button = sliderFrame:FindFirstChild("button")
                    if button then
                        button.Position = UDim2.new(math.clamp(pct * 0.94, 0, 0.94), 0, -0.5, 0)
                    end
                end
            end
        end
    end
    
    if Config.Fullbright then UpdateFullbright() end
    if Config.RemoveFog then UpdateRemoveFog() end
    
    Camera.FieldOfView = Config.CameraFOV
    if Config.ThirdPerson then UpdateThirdPerson() end
    
    Workspace.Gravity = Config.GravityModifier
    
    if Config.FlyEnabled then StartFly() end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        hum.WalkSpeed = Config.WalkSpeed
        hum.JumpPower = Config.JumpPower
    end
    
    print("[Jailbird] Config geladen! Alle Features aktiviert.")
    print("[Jailbird] ESP=" .. tostring(Config.ESPEnabled) .. " | Aimbot=" .. tostring(Config.AimbotEnabled) .. " | Fly=" .. tostring(Config.FlyEnabled))
end)
