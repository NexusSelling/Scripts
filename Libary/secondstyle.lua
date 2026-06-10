
local Library = {
    CurrentTab = nil,
    Tabs = {},
    Enabled = true,
    ToggleKey = Enum.KeyCode.RightControl,

    Theme = {
        MainBackground = Color3.fromRGB(16, 14, 26),
        SidebarBackground = Color3.fromRGB(14, 12, 22),
        ElementBackground = Color3.fromRGB(20, 18, 30),
        ButtonBackground = Color3.fromRGB(25, 22, 35),

        Accent = Color3.fromRGB(124, 58, 237),
        AccentDark = Color3.fromRGB(100, 45, 200),
        AccentLight = Color3.fromRGB(150, 80, 255),
        AccentGlow = Color3.fromRGB(160, 100, 255),

        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 145, 165),
        TextMuted = Color3.fromRGB(100, 95, 115),

        CornerRadius = UDim.new(0, 10),
        TitleSize = 24,
        TitleFont = Enum.Font.GothamBold,

        GlowIntensity = 0.6,
        BlurSize = 15,
        ParticleCount = 30,
        AnimationSpeed = 0.4
    },

    Config = {
        EnableParticles = true,
        EnableGlowLines = true,
        EnableBlur = true,
        EnableSounds = false,
        ShowBadges = true,
        ShowActivityLog = true,
        AvatarInitials = "NS",
        WindowSize = Vector2.new(700, 450),
        AnimationStyle = "Spring"
    }
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")


local function SpringTween(obj, property, goal, speed)
    speed = speed or Library.Theme.AnimationSpeed
    local info = TweenInfo.new(
        speed,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, info, {[property] = goal})
    tween:Play()
    return tween
end

local function Tween(obj, info, goal)
    local tween = TweenService:Create(obj, info, goal)
    tween:Play()
    return tween
end

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Parent = parent
    stroke.Color = color or Library.Theme.Accent
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0.5
    return stroke
end

local function AddGlow(parent, color, size)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Parent = parent
    glow.BackgroundTransparency = 1
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Size = UDim2.new(1, size or 40, 1, size or 40)
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color or Library.Theme.AccentGlow
    glow.ImageTransparency = 0.7
    glow.ZIndex = 0
    return glow
end

local function CreateGradient(parent, colors)
    local gradient = Instance.new("UIGradient")
    gradient.Parent = parent

    if colors then
        local colorSeq = {}
        for i, col in ipairs(colors) do
            table.insert(colorSeq, ColorSequenceKeypoint.new((i - 1) / (#colors - 1), col))
        end
        gradient.Color = ColorSequence.new(colorSeq)
    else
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library.Theme.Accent),
            ColorSequenceKeypoint.new(1, Library.Theme.AccentLight)
        })
    end

    return gradient
end

local function CreateRipple(parent, x, y, color)
    local Ripple = Instance.new("Frame")
    Ripple.Parent = parent
    Ripple.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    Ripple.BackgroundTransparency = 0.8
    Ripple.BorderSizePixel = 0
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.Position = UDim2.new(0, x, 0, y)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.ZIndex = 10

    Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1, 0)

    Tween(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, parent.AbsoluteSize.X * 2, 0, parent.AbsoluteSize.X * 2),
        BackgroundTransparency = 1
    })
    task.delay(0.4, function()
        if Ripple then Ripple:Destroy() end
    end)

    return Ripple
end

local function HoverAnimate(obj, enterProps, leaveProps, duration)
    duration = duration or 0.2
    obj.MouseEnter:Connect(function()
        for prop, val in pairs(enterProps) do
            SpringTween(obj, prop, val, duration)
        end
    end)
    obj.MouseLeave:Connect(function()
        for prop, val in pairs(leaveProps) do
            SpringTween(obj, prop, val, duration)
        end
    end)
end

local function CreateParticleSystem(parent)
    if not Library.Config.EnableParticles then return end

    local ParticleContainer = Instance.new("Frame")
    ParticleContainer.Name = "ParticleSystem"
    ParticleContainer.Parent = parent
    ParticleContainer.BackgroundTransparency = 1
    ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
    ParticleContainer.ZIndex = 0

    local particles = {}

    for i = 1, Library.Theme.ParticleCount do
        local particle = Instance.new("Frame")
        particle.Name = "Particle_" .. i
        particle.Parent = ParticleContainer
        particle.BackgroundColor3 = Library.Theme.Accent
        particle.BackgroundTransparency = math.random(70, 90) / 100
        particle.BorderSizePixel = 0

        local size = math.random(2, 4)
        particle.Size = UDim2.new(0, size, 0, size)
        particle.Position = UDim2.new(
            math.random(0, 100) / 100,
            0,
            math.random(0, 100) / 100,
            0
        )

        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)

        table.insert(particles, {
            frame = particle,
            velocityX = (math.random(-10, 10) / 100),
            velocityY = (math.random(-10, 10) / 100),
            life = 0
        })
    end

    RunService.RenderStepped:Connect(function(dt)
        if not Library.Config.EnableParticles then return end

        for _, p in ipairs(particles) do
            p.life = p.life + dt

            local currentX = p.frame.Position.X.Scale
            local currentY = p.frame.Position.Y.Scale

            local newX = currentX + (p.velocityX * dt)
            local newY = currentY + (p.velocityY * dt)

            if newX > 1 then newX = 0 elseif newX < 0 then newX = 1 end
            if newY > 1 then newY = 0 elseif newY < 0 then newY = 1 end

            p.frame.Position = UDim2.new(newX, 0, newY, 0)

            local pulse = 0.7 + (math.sin(p.life * 2) * 0.2)
            p.frame.BackgroundTransparency = pulse
        end
    end)

    return ParticleContainer
end


local function CreateGlowLine(parent)
    if not Library.Config.EnableGlowLines then return end

    local GlowLine = Instance.new("Frame")
    GlowLine.Name = "GlowLine"
    GlowLine.Parent = parent
    GlowLine.BackgroundColor3 = Library.Theme.Accent
    GlowLine.BorderSizePixel = 0
    GlowLine.Size = UDim2.new(0, 3, 1, 0)
    GlowLine.Position = UDim2.new(0, 0, 0, 0)

    Instance.new("UICorner", GlowLine).CornerRadius = UDim.new(1, 0)

    local Glow = AddGlow(GlowLine, Library.Theme.AccentGlow, 30)
    Glow.Size = UDim2.new(3, 0, 1, 20)
    Glow.ImageTransparency = 0.5

    local function pulse()
        while GlowLine and GlowLine.Parent do
            Tween(Glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {ImageTransparency = 0.2})
            task.wait(1)
            Tween(Glow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {ImageTransparency = 0.6})
            task.wait(1)
        end
    end

    task.spawn(pulse)

    return GlowLine
end


local function CreateBadge(parent, text, color)
    if not Library.Config.ShowBadges then return end

    local Badge = Instance.new("Frame")
    Badge.Parent = parent
    Badge.BackgroundColor3 = color or Library.Theme.Accent
    Badge.Size = UDim2.new(0, 0, 0, 18)
    Badge.AutomaticSize = Enum.AutomaticSize.X
    Badge.BorderSizePixel = 0

    Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 9)

    local Padding = Instance.new("UIPadding", Badge)
    Padding.PaddingLeft = UDim.new(0, 8)
    Padding.PaddingRight = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", Badge)
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 10

    task.spawn(function()
        while Badge and Badge.Parent do
            Tween(Badge, TweenInfo.new(2, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.2})
            task.wait(2)
            Tween(Badge, TweenInfo.new(2, Enum.EasingStyle.Sine), {BackgroundTransparency = 0})
            task.wait(2)
        end
    end)

    return Badge
end


local function CreateAvatarCircle(parent, initials)
    local Avatar = Instance.new("Frame")
    Avatar.Name = "Avatar"
    Avatar.Parent = parent
    Avatar.BackgroundColor3 = Library.Theme.Accent
    Avatar.Size = UDim2.new(0, 35, 0, 35)
    Avatar.BorderSizePixel = 0

    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
    AddStroke(Avatar, Library.Theme.AccentLight, 2)

    local Initials = Instance.new("TextLabel", Avatar)
    Initials.BackgroundTransparency = 1
    Initials.Size = UDim2.new(1, 0, 1, 0)
    Initials.Font = Enum.Font.GothamBold
    Initials.Text = initials or Library.Config.AvatarInitials
    Initials.TextColor3 = Color3.fromRGB(255, 255, 255)
    Initials.TextSize = 14

    local Glow = AddGlow(Avatar, Library.Theme.AccentGlow, 20)
    Glow.ImageTransparency = 1

    Avatar.MouseEnter:Connect(function()
        Tween(Glow, TweenInfo.new(0.3), {ImageTransparency = 0.4})
    end)

    Avatar.MouseLeave:Connect(function()
        Tween(Glow, TweenInfo.new(0.3), {ImageTransparency = 1})
    end)

    return Avatar
end


local ActivityLog = {}
local MAX_LOG_ENTRIES = 50

function Library:LogActivity(action, details)
    if not Library.Config.ShowActivityLog then return end

    local timestamp = os.date("%H:%M:%S")
    table.insert(ActivityLog, 1, {
        time = timestamp,
        action = action,
        details = details or ""
    })

    if #ActivityLog > MAX_LOG_ENTRIES then
        table.remove(ActivityLog, #ActivityLog)
    end
end


local TipGui
local function ShowTooltip(text, pos)
    if not text then return end

    if not TipGui then
        TipGui = Instance.new("ScreenGui", CoreGui)
        TipGui.Name = "SecondStyleTooltips"
        TipGui.DisplayOrder = 100
    end

    TipGui:ClearAllChildren()

    local Tooltip = Instance.new("Frame", TipGui)
    Tooltip.BackgroundColor3 = Library.Theme.ElementBackground
    Tooltip.AutomaticSize = Enum.AutomaticSize.XY
    Tooltip.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
    Tooltip.BorderSizePixel = 0
    Tooltip.BackgroundTransparency = 0.1

    Instance.new("UICorner", Tooltip).CornerRadius = UDim.new(0, 8)
    AddStroke(Tooltip, Library.Theme.Accent, 1.5)

    if Library.Config.EnableBlur then
        local Blur = Instance.new("ImageLabel", Tooltip)
        Blur.BackgroundTransparency = 1
        Blur.Size = UDim2.new(1, 0, 1, 0)
        Blur.Image = "rbxassetid://5028857084"
        Blur.ImageTransparency = 0.9
        Blur.ZIndex = 0
    end

    local Padding = Instance.new("UIPadding", Tooltip)
    Padding.PaddingBottom = UDim.new(0, 8)
    Padding.PaddingTop = UDim.new(0, 8)
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.PaddingRight = UDim.new(0, 12)

    local Label = Instance.new("TextLabel", Tooltip)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = text
    Label.TextColor3 = Library.Theme.Text
    Label.TextSize = 13
    Label.AutomaticSize = Enum.AutomaticSize.XY

    Tooltip.GroupTransparency = 1
    SpringTween(Tooltip, "GroupTransparency", 0, 0.2)
end

local function HideTooltip()
    if TipGui then
        TipGui:ClearAllChildren()
    end
end


local ActiveNotifications = {}
local MAX_NOTIFICATIONS = 5

function Library:Notify(title, text, duration, notifType)
    local NotifyGui = CoreGui:FindFirstChild("SecondStyleNotifications")
    if not NotifyGui then
        NotifyGui = Instance.new("ScreenGui", CoreGui)
        NotifyGui.Name = "SecondStyleNotifications"
        NotifyGui.DisplayOrder = 99
    end

    local typeColors = {
        success = Color3.fromRGB(50, 200, 120),
        error = Color3.fromRGB(240, 80, 80),
        warning = Color3.fromRGB(255, 180, 60),
        info = Library.Theme.Accent
    }

    local accentColor = typeColors[notifType] or Library.Theme.Accent

    local Notif = Instance.new("CanvasGroup")
    Notif.Parent = NotifyGui
    Notif.BackgroundColor3 = Library.Theme.SidebarBackground
    Notif.GroupTransparency = 0
    Notif.Size = UDim2.new(0, 300, 0, 70)
    Notif.Position = UDim2.new(1, 10, 1, -80)
    Notif.BorderSizePixel = 0

    Instance.new("UICorner", Notif).CornerRadius = Library.Theme.CornerRadius
    AddStroke(Notif, accentColor, 2)

    if Library.Config.EnableBlur then
        local BlurEffect = Instance.new("ImageLabel", Notif)
        BlurEffect.BackgroundTransparency = 1
        BlurEffect.Size = UDim2.new(1, 0, 1, 0)
        BlurEffect.Image = "rbxassetid://5028857084"
        BlurEffect.ImageTransparency = 0.95
        BlurEffect.ZIndex = 0
    end

    local Title = Instance.new("TextLabel", Notif)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.Size = UDim2.new(1, -30, 0, 22)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Library.Theme.Text
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", Notif)
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.new(0, 15, 0, 32)
    Desc.Size = UDim2.new(1, -30, 0, 28)
    Desc.Font = Enum.Font.Gotham
    Desc.Text = text
    Desc.TextColor3 = Library.Theme.TextDark
    Desc.TextSize = 12
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.TextWrapped = true

    local Icon = Instance.new("ImageLabel", Notif)
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(1, -35, 0, 10)
    Icon.Size = UDim2.new(0, 20, 0, 20)
    Icon.ImageColor3 = accentColor

    if notifType == "success" then
        Icon.Image = "rbxassetid://3926305904"
    elseif notifType == "error" then
        Icon.Image = "rbxassetid://3926307971"
    elseif notifType == "warning" then
        Icon.Image = "rbxassetid://3926305904"
    else
        Icon.Image = "rbxassetid://3926305904"
    end

    local function UpdatePositions()
        local count = 0
        for i = #ActiveNotifications, 1, -1 do
            local notif = ActiveNotifications[i]
            if notif and notif.Parent then
                local targetY = -80 - (count * 80)
                SpringTween(notif, "Position", UDim2.new(1, -310, 1, targetY), 0.4)
                count = count + 1
            end
        end
    end

    if #ActiveNotifications >= MAX_NOTIFICATIONS then
        local oldest = table.remove(ActiveNotifications, 1)
        if oldest and oldest.Parent then
            Tween(oldest, TweenInfo.new(0.4, Enum.EasingStyle.Quart),
                {Position = UDim2.new(1, 10, oldest.Position.Y.Scale, oldest.Position.Y.Offset)})
            task.delay(0.4, function()
                if oldest then oldest:Destroy() end
            end)
        end
    end

    table.insert(ActiveNotifications, Notif)
    Notif.Size = UDim2.new(0, 0, 0, 0)
    Notif.Position = UDim2.new(1, 10, 1, -80)
    task.wait(0.05)
    UpdatePositions()

    SpringTween(Notif, "Size", UDim2.new(0, 300, 0, 70), 0.4)

    task.delay(duration or 4, function()
        local index = table.find(ActiveNotifications, Notif)
        if index then
            table.remove(ActiveNotifications, index)
            SpringTween(Notif, "Size", UDim2.new(0, 0, 0, 0), 0.3)
            Tween(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quart),
                {Position = UDim2.new(1, 10, Notif.Position.Y.Scale, Notif.Position.Y.Offset)})
            task.delay(0.4, function()
                if Notif then Notif:Destroy() end
            end)
            UpdatePositions()
        end
    end)

    Library:LogActivity("Notification", title .. ": " .. text)
end


local Refresher = {}

function Library:SetTheme(cfg)
    if type(cfg) == "table" then
        for k, v in pairs(cfg) do
            if Library.Theme[k] ~= nil then
                Library.Theme[k] = v
            end
        end
    end
end

function Library:ChangeTheme(cfg)
    Library:SetTheme(cfg)
    for _, ref in pairs(Refresher) do
        pcall(ref)
    end
end

function Library:SetConfig(cfg)
    if type(cfg) == "table" then
        for k, v in pairs(cfg) do
            if Library.Config[k] ~= nil then
                Library.Config[k] = v
            end
        end
    end
end

function Library:SetToggleKey(key)
    if typeof(key) == "EnumItem" then
        Library.ToggleKey = key
    end
end


function Library:CreateKeySystem(config)
    config = config or {}
    local title = config.Title or "Authentication"
    local subtitle = config.Subtitle or "Enter your access key"
    local keys = config.Keys or {}
    local keyLink = config.KeyLink or nil
    local maxAttempts = config.MaxAttempts or 0
    local onSuccess = config.OnSuccess or nil
    local onFail = config.OnFail or nil

    local KeyGui = Instance.new("ScreenGui", CoreGui)
    KeyGui.Name = "SecondStyleKeySystem"
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeyGui.DisplayOrder = 998

    local BG = Instance.new("Frame", KeyGui)
    BG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BG.BackgroundTransparency = 0.3
    BG.Size = UDim2.new(1, 0, 1, 0)
    BG.BorderSizePixel = 0

    local Card = Instance.new("CanvasGroup", KeyGui)
    Card.BackgroundColor3 = Library.Theme.MainBackground
    Card.GroupTransparency = 0.05
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.Position = UDim2.new(0.5, 0, 0.5, 0)
    Card.Size = UDim2.new(0, 380, 0, 240)
    Card.BorderSizePixel = 0

    Instance.new("UICorner", Card).CornerRadius = Library.Theme.CornerRadius
    AddStroke(Card, Library.Theme.Accent, 2)
    AddGlow(Card, Library.Theme.AccentGlow, 60)

    CreateParticleSystem(Card)

    CreateGlowLine(Card)

    local TitleLabel = Instance.new("TextLabel", Card)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 20, 0, 20)
    TitleLabel.Size = UDim2.new(1, -40, 0, 28)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Library.Theme.Text
    TitleLabel.TextSize = 22
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    CreateGradient(TitleLabel, {Library.Theme.AccentLight, Library.Theme.Accent})

    local SubLabel = Instance.new("TextLabel", Card)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Position = UDim2.new(0, 20, 0, 52)
    SubLabel.Size = UDim2.new(1, -40, 0, 18)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.Text = subtitle
    SubLabel.TextColor3 = Library.Theme.TextDark
    SubLabel.TextSize = 12
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left

    local InputContainer = Instance.new("Frame", Card)
    InputContainer.BackgroundColor3 = Library.Theme.ElementBackground
    InputContainer.Position = UDim2.new(0, 20, 0, 85)
    InputContainer.Size = UDim2.new(1, -40, 0, 40)
    InputContainer.BorderSizePixel = 0

    Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 8)
    local inputStroke = AddStroke(InputContainer, Library.Theme.TextMuted, 1)

    local InputBox = Instance.new("TextBox", InputContainer)
    InputBox.BackgroundTransparency = 1
    InputBox.Size = UDim2.new(1, -20, 1, 0)
    InputBox.Position = UDim2.new(0, 10, 0, 0)
    InputBox.Font = Enum.Font.GothamSemibold
    InputBox.PlaceholderText = "Enter key..."
    InputBox.PlaceholderColor3 = Library.Theme.TextMuted
    InputBox.Text = ""
    InputBox.TextColor3 = Library.Theme.Text
    InputBox.TextSize = 14
    InputBox.TextXAlignment = Enum.TextXAlignment.Left
    InputBox.ClearTextOnFocus = false

    InputBox.Focused:Connect(function()
        SpringTween(inputStroke, "Color", Library.Theme.Accent, 0.3)
        SpringTween(inputStroke, "Transparency", 0.2, 0.3)
    end)

    InputBox.FocusLost:Connect(function()
        Tween(inputStroke, TweenInfo.new(0.3), {Color = Library.Theme.TextMuted, Transparency = 0.5})
    end)

    local ConfirmBtn = Instance.new("TextButton", Card)
    ConfirmBtn.BackgroundColor3 = Library.Theme.Accent
    ConfirmBtn.Position = UDim2.new(0, 20, 0, 140)
    ConfirmBtn.Size = UDim2.new(0.5, -25, 0, 38)
    ConfirmBtn.Font = Enum.Font.GothamBold
    ConfirmBtn.Text = "Confirm"
    ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmBtn.TextSize = 14
    ConfirmBtn.BorderSizePixel = 0

    Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 8)
    AddGlow(ConfirmBtn, Library.Theme.AccentGlow, 30)
    CreateGradient(ConfirmBtn)

    local GetKeyBtn = Instance.new("TextButton", Card)
    GetKeyBtn.BackgroundColor3 = Library.Theme.ElementBackground
    GetKeyBtn.Position = UDim2.new(0.5, 5, 0, 140)
    GetKeyBtn.Size = UDim2.new(0.5, -25, 0, 38)
    GetKeyBtn.Font = Enum.Font.GothamSemibold
    GetKeyBtn.Text = keyLink and "Get Key" or "Copy Link"
    GetKeyBtn.TextColor3 = Library.Theme.Text
    GetKeyBtn.TextSize = 14
    GetKeyBtn.BorderSizePixel = 0

    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)
    AddStroke(GetKeyBtn, Library.Theme.Accent, 1)

    local StatusLabel = Instance.new("TextLabel", Card)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 20, 0, 190)
    StatusLabel.Size = UDim2.new(1, -40, 0, 24)
    StatusLabel.Font = Enum.Font.GothamSemibold
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Library.Theme.TextDark
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

    ConfirmBtn.MouseEnter:Connect(function()
        SpringTween(ConfirmBtn, "Size", UDim2.new(0.5, -25, 0, 40), 0.2)
    end)
    ConfirmBtn.MouseLeave:Connect(function()
        SpringTween(ConfirmBtn, "Size", UDim2.new(0.5, -25, 0, 38), 0.2)
    end)

    GetKeyBtn.MouseEnter:Connect(function()
        SpringTween(GetKeyBtn, "BackgroundColor3", Library.Theme.ButtonBackground, 0.2)
    end)
    GetKeyBtn.MouseLeave:Connect(function()
        SpringTween(GetKeyBtn, "BackgroundColor3", Library.Theme.ElementBackground, 0.2)
    end)

    local attempts = 0
    local validated = false

    GetKeyBtn.MouseButton1Click:Connect(function()
        if keyLink then
            if setclipboard then
                setclipboard(keyLink)
            end
            StatusLabel.Text = "✓ Link copied to clipboard!"
            StatusLabel.TextColor3 = Library.Theme.AccentLight
            task.delay(2, function()
                if not validated then StatusLabel.Text = "" end
            end)
        end
    end)

    ConfirmBtn.MouseButton1Click:Connect(function()
        local entered = InputBox.Text
        if entered == "" then
            StatusLabel.Text = "⚠ Please enter a key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 180, 60)
            return
        end

        local valid = false
        for _, k in pairs(keys) do
            if entered == k then
                valid = true
                break
            end
        end

        if valid then
            validated = true
            StatusLabel.Text = "✓ Access granted!"
            StatusLabel.TextColor3 = Color3.fromRGB(50, 200, 120)

            SpringTween(ConfirmBtn, "BackgroundColor3", Color3.fromRGB(50, 200, 120), 0.3)

            task.delay(0.8, function()
                Tween(BG, TweenInfo.new(0.4), {BackgroundTransparency = 1})
                Tween(Card, TweenInfo.new(0.4), {GroupTransparency = 1})
                task.wait(0.4)
                KeyGui:Destroy()
                if onSuccess then onSuccess() end
            end)
        else
            attempts = attempts + 1
            StatusLabel.Text = "✗ Invalid key! (" .. attempts .. " attempts)"
            StatusLabel.TextColor3 = Color3.fromRGB(240, 80, 80)

            local original = Card.Position
            SpringTween(Card, "Position", UDim2.new(0.5, 10, 0.5, 0), 0.05)
            task.wait(0.05)
            SpringTween(Card, "Position", UDim2.new(0.5, -10, 0.5, 0), 0.05)
            task.wait(0.05)
            SpringTween(Card, "Position", original, 0.1)

            if maxAttempts > 0 and attempts >= maxAttempts then
                StatusLabel.Text = "⛔ Too many failed attempts"
                task.delay(1.5, function()
                    KeyGui:Destroy()
                    if onFail then onFail() end
                end)
            end
        end
    end)

    Card.GroupTransparency = 1
    Card.Size = UDim2.new(0, 0, 0, 0)
    task.wait(0.1)
    SpringTween(Card, "Size", UDim2.new(0, 380, 0, 240), 0.5)
    SpringTween(Card, "GroupTransparency", 0.05, 0.5)

    while KeyGui.Parent and not validated do
        task.wait(0.1)
    end
    return validated
end


function Library:CreateLoadingScreen(config)
    config = config or {}
    local title = config.Title or "SecondStyle"
    local subtitle = config.Subtitle or "Loading interface..."
    local duration = config.Duration or 3
    local logoIcon = config.LogoIcon
    local steps = config.Steps or {}

    local LoadGui = Instance.new("ScreenGui", CoreGui)
    LoadGui.Name = "SecondStyleLoading"
    LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LoadGui.DisplayOrder = 999

    local Card = Instance.new("CanvasGroup", LoadGui)
    Card.BackgroundColor3 = Library.Theme.SidebarBackground
    Card.GroupTransparency = 0.1
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.Position = UDim2.new(0.5, 0, 0.5, 0)
    Card.Size = UDim2.new(0, 350, 0, logoIcon and 180 or 150)
    Card.BorderSizePixel = 0

    Instance.new("UICorner", Card).CornerRadius = Library.Theme.CornerRadius
    AddStroke(Card, Library.Theme.Accent, 2)
    AddGlow(Card, Library.Theme.AccentGlow, 80)

    local yOffset = 20

    if logoIcon then
        local Logo = Instance.new("ImageLabel", Card)
        Logo.BackgroundTransparency = 1
        Logo.AnchorPoint = Vector2.new(0.5, 0)
        Logo.Position = UDim2.new(0.5, 0, 0, 15)
        Logo.Size = UDim2.new(0, 40, 0, 40)
        Logo.Image = "rbxassetid://" .. tostring(logoIcon)
        Logo.ImageColor3 = Library.Theme.Accent

        task.spawn(function()
            while Logo and Logo.Parent do
                Tween(Logo, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = 360})
                task.wait(2)
                Logo.Rotation = 0
            end
        end)

        yOffset = 65
    end

    local TitleLabel = Instance.new("TextLabel", Card)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0)
    TitleLabel.Position = UDim2.new(0.5, 0, 0, yOffset)
    TitleLabel.Size = UDim2.new(1, -40, 0, 26)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Library.Theme.Text
    TitleLabel.TextSize = 20

    CreateGradient(TitleLabel)

    local SubLabel = Instance.new("TextLabel", Card)
    SubLabel.BackgroundTransparency = 1
    SubLabel.AnchorPoint = Vector2.new(0.5, 0)
    SubLabel.Position = UDim2.new(0.5, 0, 0, yOffset + 30)
    SubLabel.Size = UDim2.new(1, -40, 0, 16)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.Text = subtitle
    SubLabel.TextColor3 = Library.Theme.TextDark
    SubLabel.TextSize = 12

    local BarBG = Instance.new("Frame", Card)
    BarBG.BackgroundColor3 = Library.Theme.ElementBackground
    BarBG.AnchorPoint = Vector2.new(0.5, 0)
    BarBG.Position = UDim2.new(0.5, 0, 0, yOffset + 58)
    BarBG.Size = UDim2.new(0.85, 0, 0, 6)
    BarBG.BorderSizePixel = 0

    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame", BarBG)
    BarFill.BackgroundColor3 = Library.Theme.Accent
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BorderSizePixel = 0

    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
    CreateGradient(BarFill)
    AddGlow(BarFill, Library.Theme.AccentGlow, 20)

    local Shimmer = Instance.new("Frame", BarFill)
    Shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Shimmer.BackgroundTransparency = 0.85
    Shimmer.Size = UDim2.new(0, 30, 1, 0)
    Shimmer.Position = UDim2.new(0, -30, 0, 0)
    Shimmer.BorderSizePixel = 0
    Instance.new("UICorner", Shimmer).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        while Shimmer and Shimmer.Parent do
            Tween(Shimmer, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                Position = UDim2.new(1, 0, 0, 0)
            })
            task.wait(1.5)
            if not Shimmer then break end
            Shimmer.Position = UDim2.new(0, -30, 0, 0)
        end
    end)

    local StepLabel = Instance.new("TextLabel", Card)
    StepLabel.BackgroundTransparency = 1
    StepLabel.AnchorPoint = Vector2.new(0.5, 0)
    StepLabel.Position = UDim2.new(0.5, 0, 0, yOffset + 72)
    StepLabel.Size = UDim2.new(1, -40, 0, 18)
    StepLabel.Font = Enum.Font.GothamSemibold
    StepLabel.Text = ""
    StepLabel.TextColor3 = Library.Theme.TextDark
    StepLabel.TextSize = 11

    Card.Size = UDim2.new(0, 0, 0, 0)
    SpringTween(Card, "Size", UDim2.new(0, 350, 0, logoIcon and 180 or 150), 0.6)

    if #steps > 0 then
        local stepDur = duration / #steps
        for i, stepText in ipairs(steps) do
            StepLabel.Text = stepText
            Tween(BarFill, TweenInfo.new(stepDur, Enum.EasingStyle.Quad),
                {Size = UDim2.new(i / #steps, 0, 1, 0)})
            task.wait(stepDur)
        end
    else
        Tween(BarFill, TweenInfo.new(duration, Enum.EasingStyle.Quad),
            {Size = UDim2.new(1, 0, 1, 0)})
        task.wait(duration)
    end

    Tween(Card, TweenInfo.new(0.5), {GroupTransparency = 1})
    task.wait(0.5)
    LoadGui:Destroy()
end


function Library:CreateWindow(hubName)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = hubName or "SecondStyleUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local windowSize = Library.Config.WindowSize

    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Library.Theme.MainBackground
    MainFrame.GroupTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -windowSize.X/2, 0.5, -windowSize.Y/2)
    MainFrame.Size = UDim2.new(0, windowSize.X, 0, windowSize.Y)
    MainFrame.ClipsDescendants = true

    Instance.new("UICorner", MainFrame).CornerRadius = Library.Theme.CornerRadius
    AddStroke(MainFrame, Library.Theme.Accent, 2)
    AddGlow(MainFrame, Library.Theme.AccentGlow, 100)

    CreateParticleSystem(MainFrame)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Enabled = not Library.Enabled
            MainFrame.Visible = Library.Enabled

            if Library.Enabled then
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                SpringTween(MainFrame, "Size", UDim2.new(0, windowSize.X, 0, windowSize.Y), 0.5)
            end

            Library:LogActivity("UI Toggle", Library.Enabled and "Opened" or "Closed")
        end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Library.Theme.SidebarBackground
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BorderSizePixel = 0

    Instance.new("UICorner", Sidebar).CornerRadius = Library.Theme.CornerRadius

    CreateGlowLine(Sidebar)

    local Header = Instance.new("Frame", Sidebar)
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.new(0, 15, 0, 15)
    Header.Size = UDim2.new(1, -30, 0, 50)

    local Avatar = CreateAvatarCircle(Header, Library.Config.AvatarInitials)
    Avatar.Position = UDim2.new(0, 0, 0, 0)

    local NameLabel = Instance.new("TextLabel", Header)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0, 45, 0, 0)
    NameLabel.Size = UDim2.new(1, -45, 0, 25)
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = hubName or "SecondStyle"
    NameLabel.TextColor3 = Library.Theme.Text
    NameLabel.TextSize = 16
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local StatusLabel = Instance.new("TextLabel", Header)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 45, 0, 25)
    StatusLabel.Size = UDim2.new(1, -45, 0, 16)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "● Online"
    StatusLabel.TextColor3 = Color3.fromRGB(50, 200, 120)
    StatusLabel.TextSize = 11
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        while StatusLabel and StatusLabel.Parent do
            StatusLabel.TextColor3 = Color3.fromRGB(50, 200, 120)
            task.wait(1)
            StatusLabel.TextColor3 = Color3.fromRGB(30, 150, 80)
            task.wait(1)
        end
    end)

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 80)
    TabContainer.Size = UDim2.new(1, -20, 1, -95)
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = Library.Theme.Accent
    TabContainer.BorderSizePixel = 0

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 5)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local PageContainer = Instance.new("Frame")
    PageContainer.Parent = MainFrame
    PageContainer.BackgroundTransparency = 1
    PageContainer.Position = UDim2.new(0, 200, 0, 0)
    PageContainer.Size = UDim2.new(1, -200, 1, 0)
    PageContainer.ClipsDescendants = true

    local dragging, dragStart, startPos

    Sidebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.GroupTransparency = 1
    task.wait(0.1)
    SpringTween(MainFrame, "Size", UDim2.new(0, windowSize.X, 0, windowSize.Y), 0.5)
    SpringTween(MainFrame, "GroupTransparency", 0.05, 0.4)

    Library:LogActivity("Window Created", hubName or "SecondStyle")

    local WindowLogic = {}


    function WindowLogic:CreateTab(name, iconID)
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Name = name
        TabButton.BackgroundColor3 = Library.Theme.ElementBackground
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 0, 45)
        TabButton.Text = ""
        TabButton.BorderSizePixel = 0

        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)

        local Icon = Instance.new("ImageLabel", TabButton)
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0, 12, 0.5, -10)
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Image = iconID and "rbxassetid://" .. tostring(iconID) or "rbxassetid://3926305904"
        Icon.ImageColor3 = Library.Theme.TextDark

        local TabLabel = Instance.new("TextLabel", TabButton)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position = UDim2.new(0, 42, 0, 0)
        TabLabel.Size = UDim2.new(1, -70, 1, 0)
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.Text = name
        TabLabel.TextColor3 = Library.Theme.TextDark
        TabLabel.TextSize = 14
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left

        local Badge = CreateBadge(TabButton, "NEW", Library.Theme.Accent)
        if Badge then
            Badge.Position = UDim2.new(1, -45, 0.5, -9)
            Badge.Visible = false
        end

        local Indicator = Instance.new("Frame", TabButton)
        Indicator.BackgroundColor3 = Library.Theme.Accent
        Indicator.Position = UDim2.new(0, 0, 0, 10)
        Indicator.Size = UDim2.new(0, 3, 1, -20)
        Indicator.BorderSizePixel = 0
        Indicator.Transparency = 1

        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

        local Page = Instance.new("CanvasGroup", PageContainer)
        Page.Name = name .. "_Page"
        Page.BackgroundTransparency = 1
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.GroupTransparency = 1

        local TopBar = Instance.new("ScrollingFrame", Page)
        TopBar.BackgroundTransparency = 1
        TopBar.Position = UDim2.new(0, 15, 0, 15)
        TopBar.Size = UDim2.new(1, -30, 0, 40)
        TopBar.ScrollBarThickness = 0
        TopBar.CanvasSize = UDim2.new(0, 0, 0, 0)
        TopBar.ScrollingDirection = Enum.ScrollingDirection.X
        TopBar.BorderSizePixel = 0

        local TopBarList = Instance.new("UIListLayout", TopBar)
        TopBarList.FillDirection = Enum.FillDirection.Horizontal
        TopBarList.Padding = UDim.new(0, 10)
        TopBarList.SortOrder = Enum.SortOrder.LayoutOrder

        local ContentContainer = Instance.new("Frame", Page)
        ContentContainer.BackgroundTransparency = 1
        ContentContainer.Position = UDim2.new(0, 15, 0, 65)
        ContentContainer.Size = UDim2.new(1, -30, 1, -80)

        local SubTabs = {}

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Library.Tabs) do
                t.Page.Visible = false
                Tween(t.Page, TweenInfo.new(0.15), {GroupTransparency = 1})
                Tween(t.Label, TweenInfo.new(0.15), {TextColor3 = Library.Theme.TextDark})
                Tween(t.Icon, TweenInfo.new(0.15), {ImageColor3 = Library.Theme.TextDark})
                Tween(t.Button, TweenInfo.new(0.15), {BackgroundTransparency = 1})
                Tween(t.Indicator, TweenInfo.new(0.15), {Transparency = 1})
            end

            Page.Visible = true
            Page.Position = UDim2.new(0, 20, 0, 0)
            SpringTween(Page, "GroupTransparency", 0, 0.25)
            SpringTween(Page, "Position", UDim2.new(0, 0, 0, 0), 0.3)
            SpringTween(TabLabel, "TextColor3", Library.Theme.Text, 0.3)
            SpringTween(Icon, "ImageColor3", Library.Theme.Accent, 0.3)
            SpringTween(TabButton, "BackgroundTransparency", 0, 0.3)
            SpringTween(TabButton, "BackgroundColor3", Library.Theme.ElementBackground, 0.3)
            SpringTween(Indicator, "Transparency", 0, 0.3)

            Library:LogActivity("Tab Changed", name)
        end)

        TabButton.MouseEnter:Connect(function()
            if not Page.Visible then
                SpringTween(TabButton, "BackgroundTransparency", 0.3, 0.2)
                SpringTween(TabButton, "BackgroundColor3", Library.Theme.ElementBackground, 0.2)
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if not Page.Visible then
                SpringTween(TabButton, "BackgroundTransparency", 1, 0.2)
            end
        end)

        table.insert(Library.Tabs, {
            Page = Page,
            Label = TabLabel,
            Icon = Icon,
            Button = TabButton,
            Indicator = Indicator,
            Badge = Badge
        })

        if #Library.Tabs == 1 then
            Page.Visible = true
            Page.GroupTransparency = 0
            TabLabel.TextColor3 = Library.Theme.Text
            Icon.ImageColor3 = Library.Theme.Accent
            TabButton.BackgroundTransparency = 0
            Indicator.Transparency = 0
        end

        local PageLogic = {}


        function PageLogic:CreateSection(sectionName)
            local SubTabButton = Instance.new("TextButton", TopBar)
            SubTabButton.Name = sectionName
            SubTabButton.BackgroundColor3 = Library.Theme.ElementBackground
            SubTabButton.BackgroundTransparency = 1
            SubTabButton.Font = Enum.Font.GothamSemibold
            SubTabButton.Text = sectionName
            SubTabButton.TextColor3 = Library.Theme.TextDark
            SubTabButton.TextSize = 13
            SubTabButton.Size = UDim2.new(0, 0, 1, 0)
            SubTabButton.AutomaticSize = Enum.AutomaticSize.X
            SubTabButton.BorderSizePixel = 0

            Instance.new("UICorner", SubTabButton).CornerRadius = UDim.new(0, 8)

            local btnPadding = Instance.new("UIPadding", SubTabButton)
            btnPadding.PaddingLeft = UDim.new(0, 15)
            btnPadding.PaddingRight = UDim.new(0, 15)

            local Underline = Instance.new("Frame", SubTabButton)
            Underline.BackgroundColor3 = Library.Theme.Accent
            Underline.Position = UDim2.new(0, 0, 1, -3)
            Underline.Size = UDim2.new(1, 0, 0, 3)
            Underline.BorderSizePixel = 0
            Underline.Transparency = 1

            Instance.new("UICorner", Underline).CornerRadius = UDim.new(1, 0)

            local SubPage = Instance.new("ScrollingFrame", ContentContainer)
            SubPage.Name = sectionName .. "_SubPage"
            SubPage.BackgroundTransparency = 1
            SubPage.Size = UDim2.new(1, 0, 1, 0)
            SubPage.Visible = false
            SubPage.ScrollBarThickness = 3
            SubPage.ScrollBarImageColor3 = Library.Theme.Accent
            SubPage.BorderSizePixel = 0
            SubPage.CanvasSize = UDim2.new(0, 0, 0, 0)

            local SubPageList = Instance.new("UIListLayout", SubPage)
            SubPageList.Padding = UDim.new(0, 10)
            SubPageList.SortOrder = Enum.SortOrder.LayoutOrder

            SubPageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SubPage.CanvasSize = UDim2.new(0, 0, 0, SubPageList.AbsoluteContentSize.Y + 10)
            end)

            SubTabButton.MouseButton1Click:Connect(function()
                for _, st in pairs(SubTabs) do
                    st.Page.Visible = false
                    st.Page.Position = UDim2.new(0, 0, 0, 0)
                    Tween(st.Btn, TweenInfo.new(0.15), {
                        TextColor3 = Library.Theme.TextDark,
                        BackgroundTransparency = 1
                    })
                    Tween(st.Underline, TweenInfo.new(0.15), {Transparency = 1})
                end

                SubPage.Visible = true
                SubPage.Position = UDim2.new(0, 0, 0.05, 10)
                SpringTween(SubTabButton, "TextColor3", Library.Theme.Text, 0.2)
                SpringTween(SubTabButton, "BackgroundTransparency", 0, 0.2)
                SpringTween(Underline, "Transparency", 0, 0.2)
                SpringTween(SubPage, "Position", UDim2.new(0, 0, 0, 0), 0.25)

                Library:LogActivity("Section Changed", name .. " > " .. sectionName)
            end)

            SubTabButton.MouseEnter:Connect(function()
                if not SubPage.Visible then
                    SpringTween(SubTabButton, "BackgroundTransparency", 0.5, 0.2)
                end
            end)

            SubTabButton.MouseLeave:Connect(function()
                if not SubPage.Visible then
                    SpringTween(SubTabButton, "BackgroundTransparency", 1, 0.2)
                end
            end)

            table.insert(SubTabs, {
                Page = SubPage,
                Btn = SubTabButton,
                Underline = Underline
            })

            if #SubTabs == 1 then
                SubPage.Visible = true
                SubTabButton.TextColor3 = Library.Theme.Text
                SubTabButton.BackgroundTransparency = 0
                Underline.Transparency = 0
            end

            local SectionLogic = {}

            function SectionLogic:CreateButton(text, tooltip, callback)
                if type(tooltip) == "function" then
                    callback = tooltip
                    tooltip = nil
                end

                local Button = Instance.new("TextButton", SubPage)
                Button.Name = text
                Button.BackgroundColor3 = Library.Theme.ButtonBackground
                Button.Size = UDim2.new(1, -10, 0, 40)
                Button.Font = Enum.Font.GothamSemibold
                Button.Text = text
                Button.TextColor3 = Library.Theme.Text
                Button.TextSize = 14
                Button.BorderSizePixel = 0
                Button.ClipsDescendants = true

                Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
                local btnStroke = AddStroke(Button, Library.Theme.Accent, 1)
                btnStroke.Transparency = 0.7

                local btnGlow = AddGlow(Button, Library.Theme.AccentGlow, 40)
                btnGlow.ImageTransparency = 1

                Button.MouseEnter:Connect(function()
                    SpringTween(Button, "BackgroundColor3", Library.Theme.ElementBackground, 0.15)
                    SpringTween(btnStroke, "Transparency", 0.2, 0.15)
                    SpringTween(btnGlow, "ImageTransparency", 0.7, 0.15)
                    SpringTween(Button, "Size", UDim2.new(1, -6, 0, 42), 0.15)
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                Button.MouseLeave:Connect(function()
                    SpringTween(Button, "BackgroundColor3", Library.Theme.ButtonBackground, 0.2)
                    SpringTween(btnStroke, "Transparency", 0.7, 0.2)
                    SpringTween(btnGlow, "ImageTransparency", 1, 0.2)
                    SpringTween(Button, "Size", UDim2.new(1, -10, 0, 40), 0.2)
                    HideTooltip()
                end)

                Button.MouseButton1Down:Connect(function()
                    local mousePos = UserInputService:GetMouseLocation()
                    local relX = mousePos.X - Button.AbsolutePosition.X
                    local relY = mousePos.Y - Button.AbsolutePosition.Y
                    CreateRipple(Button, relX, relY, Library.Theme.AccentLight)

                    SpringTween(Button, "BackgroundColor3", Library.Theme.Accent, 0.08)
                end)

                Button.MouseButton1Click:Connect(function()
                    SpringTween(Button, "BackgroundColor3", Library.Theme.ElementBackground, 0.2)

                    if callback then
                        task.spawn(callback)
                    end

                    Library:LogActivity("Button Click", text)
                end)

                table.insert(Refresher, function()
                    Button.BackgroundColor3 = Library.Theme.ButtonBackground
                    Button.TextColor3 = Library.Theme.Text
                end)

                return Button
            end

            function SectionLogic:CreateToggle(text, tooltip, startState, callback)
                if type(tooltip) == "boolean" then
                    callback = startState
                    startState = tooltip
                    tooltip = nil
                end

                startState = startState or false

                local ToggleFrame = Instance.new("Frame", SubPage)
                ToggleFrame.Name = text
                ToggleFrame.BackgroundColor3 = Library.Theme.ElementBackground
                ToggleFrame.Size = UDim2.new(1, -10, 0, 45)
                ToggleFrame.BorderSizePixel = 0

                Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
                local tglStroke = AddStroke(ToggleFrame, Library.Theme.Accent, 1)
                tglStroke.Transparency = 0.7

                local Label = Instance.new("TextLabel", ToggleFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.Size = UDim2.new(1, -80, 1, 0)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local SwitchContainer = Instance.new("Frame", ToggleFrame)
                SwitchContainer.BackgroundColor3 = Color3.fromRGB(40, 38, 50)
                SwitchContainer.Position = UDim2.new(1, -55, 0.5, -12)
                SwitchContainer.Size = UDim2.new(0, 45, 0, 24)
                SwitchContainer.BorderSizePixel = 0

                Instance.new("UICorner", SwitchContainer).CornerRadius = UDim.new(1, 0)

                local SwitchKnob = Instance.new("Frame", SwitchContainer)
                SwitchKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                SwitchKnob.Position = UDim2.new(0, 3, 0.5, -9)
                SwitchKnob.Size = UDim2.new(0, 18, 0, 18)
                SwitchKnob.BorderSizePixel = 0

                Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)
                AddGlow(SwitchKnob, Color3.fromRGB(255, 255, 255), 10)

                local state = startState

                local function UpdateToggle(animate)
                    if state then
                        if animate then
                            SpringTween(SwitchContainer, "BackgroundColor3", Library.Theme.Accent, 0.25)
                            SpringTween(SwitchKnob, "Position", UDim2.new(1, -21, 0.5, -9), 0.3)
                            SpringTween(SwitchKnob, "BackgroundColor3", Color3.fromRGB(255, 255, 255), 0.25)
                            SpringTween(SwitchKnob, "Size", UDim2.new(0, 20, 0, 20), 0.1)
                            task.wait(0.1)
                            SpringTween(SwitchKnob, "Size", UDim2.new(0, 18, 0, 18), 0.2)
                        else
                            SwitchContainer.BackgroundColor3 = Library.Theme.Accent
                            SwitchKnob.Position = UDim2.new(1, -21, 0.5, -9)
                            SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        end
                    else
                        if animate then
                            SpringTween(SwitchContainer, "BackgroundColor3", Color3.fromRGB(40, 38, 50), 0.25)
                            SpringTween(SwitchKnob, "Position", UDim2.new(0, 3, 0.5, -9), 0.3)
                            SpringTween(SwitchKnob, "BackgroundColor3", Color3.fromRGB(200, 200, 200), 0.25)
                            SpringTween(SwitchKnob, "Size", UDim2.new(0, 20, 0, 20), 0.1)
                            task.wait(0.1)
                            SpringTween(SwitchKnob, "Size", UDim2.new(0, 18, 0, 18), 0.2)
                        else
                            SwitchContainer.BackgroundColor3 = Color3.fromRGB(40, 38, 50)
                            SwitchKnob.Position = UDim2.new(0, 3, 0.5, -9)
                            SwitchKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                        end
                    end
                end

                UpdateToggle(false)

                local ToggleButton = Instance.new("TextButton", ToggleFrame)
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Text = ""
                ToggleButton.ZIndex = 2
                ToggleButton.ClipsDescendants = true

                ToggleButton.MouseButton1Down:Connect(function()
                    local mousePos = UserInputService:GetMouseLocation()
                    local relX = mousePos.X - SwitchContainer.AbsolutePosition.X
                    local relY = mousePos.Y - SwitchContainer.AbsolutePosition.Y
                    CreateRipple(SwitchContainer, relX, relY, Library.Theme.AccentLight)
                end)

                ToggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    UpdateToggle(true)

                    if callback then
                        task.spawn(callback, state)
                    end

                    Library:LogActivity("Toggle", text .. " = " .. tostring(state))
                end)

                ToggleFrame.MouseEnter:Connect(function()
                    SpringTween(tglStroke, "Transparency", 0.2, 0.15)
                    SpringTween(ToggleFrame, "BackgroundColor3", Library.Theme.ButtonBackground, 0.15)
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                ToggleFrame.MouseLeave:Connect(function()
                    SpringTween(tglStroke, "Transparency", 0.7, 0.2)
                    SpringTween(ToggleFrame, "BackgroundColor3", Library.Theme.ElementBackground, 0.2)
                    HideTooltip()
                end)

                table.insert(Refresher, function()
                    ToggleFrame.BackgroundColor3 = Library.Theme.ElementBackground
                    Label.TextColor3 = Library.Theme.Text
                    UpdateToggle(false)
                end)

                return {
                    SetState = function(newState)
                        state = newState
                        UpdateToggle(true)
                    end,
                    GetState = function()
                        return state
                    end
                }
            end

            function SectionLogic:CreateSlider(text, tooltip, min, max, default, callback)
                if type(tooltip) == "number" then
                    callback = default
                    default = max
                    max = min
                    min = tooltip
                    tooltip = nil
                end

                min = min or 0
                max = max or 100
                default = default or min

                local SliderFrame = Instance.new("Frame", SubPage)
                SliderFrame.Name = text
                SliderFrame.BackgroundColor3 = Library.Theme.ElementBackground
                SliderFrame.Size = UDim2.new(1, -10, 0, 55)
                SliderFrame.BorderSizePixel = 0

                Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
                AddStroke(SliderFrame, Library.Theme.Accent, 1).Transparency = 0.7

                local Label = Instance.new("TextLabel", SliderFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 15, 0, 8)
                Label.Size = UDim2.new(1, -80, 0, 18)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local ValueLabel = Instance.new("TextLabel", SliderFrame)
                ValueLabel.BackgroundColor3 = Library.Theme.ButtonBackground
                ValueLabel.Position = UDim2.new(1, -60, 0, 6)
                ValueLabel.Size = UDim2.new(0, 45, 0, 22)
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.Text = tostring(default)
                ValueLabel.TextColor3 = Library.Theme.Accent
                ValueLabel.TextSize = 12

                Instance.new("UICorner", ValueLabel).CornerRadius = UDim.new(0, 6)

                local SliderTrack = Instance.new("Frame", SliderFrame)
                SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 38, 50)
                SliderTrack.Position = UDim2.new(0, 15, 1, -18)
                SliderTrack.Size = UDim2.new(1, -30, 0, 6)
                SliderTrack.BorderSizePixel = 0

                Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

                local SliderFill = Instance.new("Frame", SliderTrack)
                SliderFill.BackgroundColor3 = Library.Theme.Accent
                SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                SliderFill.BorderSizePixel = 0

                Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
                CreateGradient(SliderFill)
                AddGlow(SliderFill, Library.Theme.AccentGlow, 15)

                local SliderKnob = Instance.new("Frame", SliderTrack)
                SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
                SliderKnob.Size = UDim2.new(0, 16, 0, 16)
                SliderKnob.BorderSizePixel = 0

                Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)
                AddStroke(SliderKnob, Library.Theme.Accent, 2)
                AddGlow(SliderKnob, Library.Theme.AccentGlow, 20)

                local value = default
                local dragging = false

                local function UpdateSlider(input)
                    local relativeX = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (relativeX * (max - min)))

                    SpringTween(SliderFill, "Size", UDim2.new(relativeX, 0, 1, 0), 0.08)
                    SpringTween(SliderKnob, "Position", UDim2.new(relativeX, 0, 0.5, 0), 0.08)

                    ValueLabel.Text = tostring(value)
                    SpringTween(ValueLabel, "BackgroundColor3", Library.Theme.Accent, 0.1)
                    task.delay(0.3, function()
                        if ValueLabel then
                            SpringTween(ValueLabel, "BackgroundColor3", Library.Theme.ButtonBackground, 0.3)
                        end
                    end)

                    if callback then
                        task.spawn(callback, value)
                    end
                end

                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        SpringTween(SliderKnob, "Size", UDim2.new(0, 22, 0, 22), 0.15)
                        SpringTween(SliderTrack, "Size", UDim2.new(1, -30, 0, 8), 0.15)
                        UpdateSlider(input)
                        Library:LogActivity("Slider", text .. " = " .. tostring(value))
                    end
                end)

                SliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        SpringTween(SliderKnob, "Size", UDim2.new(0, 16, 0, 16), 0.2)
                        SpringTween(SliderTrack, "Size", UDim2.new(1, -30, 0, 6), 0.2)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)

                SliderFrame.MouseEnter:Connect(function()
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                SliderFrame.MouseLeave:Connect(function()
                    HideTooltip()
                end)

                table.insert(Refresher, function()
                    SliderFrame.BackgroundColor3 = Library.Theme.ElementBackground
                    Label.TextColor3 = Library.Theme.Text
                    SliderFill.BackgroundColor3 = Library.Theme.Accent
                end)

                return {
                    SetValue = function(newValue)
                        value = math.clamp(newValue, min, max)
                        local relativeX = (value - min) / (max - min)
                        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                        SliderKnob.Position = UDim2.new(relativeX, 0, 0.5, 0)
                        ValueLabel.Text = tostring(value)
                    end,
                    GetValue = function()
                        return value
                    end
                }
            end

            function SectionLogic:CreateDropdown(text, tooltip, options, default, callback)
                if type(tooltip) == "table" then
                    callback = default
                    default = options
                    options = tooltip
                    tooltip = nil
                end

                options = options or {}
                default = default or (options[1] or "None")

                local DropdownFrame = Instance.new("Frame", SubPage)
                DropdownFrame.Name = text
                DropdownFrame.BackgroundColor3 = Library.Theme.ElementBackground
                DropdownFrame.Size = UDim2.new(1, -10, 0, 45)
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.ZIndex = 2

                Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)
                AddStroke(DropdownFrame, Library.Theme.Accent, 1).Transparency = 0.7

                local Label = Instance.new("TextLabel", DropdownFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.Size = UDim2.new(1, -40, 0, 20)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local SelectedButton = Instance.new("TextButton", DropdownFrame)
                SelectedButton.BackgroundColor3 = Library.Theme.ButtonBackground
                SelectedButton.Position = UDim2.new(0, 10, 0, 22)
                SelectedButton.Size = UDim2.new(1, -20, 0, 18)
                SelectedButton.Font = Enum.Font.Gotham
                SelectedButton.Text = "  " .. default
                SelectedButton.TextColor3 = Library.Theme.Text
                SelectedButton.TextSize = 11
                SelectedButton.TextXAlignment = Enum.TextXAlignment.Left
                SelectedButton.BorderSizePixel = 0

                Instance.new("UICorner", SelectedButton).CornerRadius = UDim.new(0, 6)

                local Arrow = Instance.new("TextLabel", SelectedButton)
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -20, 0, 0)
                Arrow.Size = UDim2.new(0, 20, 1, 0)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Text = "▼"
                Arrow.TextColor3 = Library.Theme.TextDark
                Arrow.TextSize = 10

                local OptionsList = Instance.new("ScrollingFrame", DropdownFrame)
                OptionsList.BackgroundColor3 = Library.Theme.SidebarBackground
                OptionsList.Position = UDim2.new(0, 10, 0, 42)
                OptionsList.Size = UDim2.new(1, -20, 0, 0)
                OptionsList.Visible = false
                OptionsList.BorderSizePixel = 0
                OptionsList.ScrollBarThickness = 2
                OptionsList.ScrollBarImageColor3 = Library.Theme.Accent
                OptionsList.ZIndex = 10

                Instance.new("UICorner", OptionsList).CornerRadius = UDim.new(0, 6)
                AddStroke(OptionsList, Library.Theme.Accent, 2)

                local OptionsLayout = Instance.new("UIListLayout", OptionsList)
                OptionsLayout.Padding = UDim.new(0, 2)

                local selected = default
                local isOpen = false

                local function CloseDropdown()
                    isOpen = false
                    SpringTween(OptionsList, "Size", UDim2.new(1, -20, 0, 0), 0.3)
                    SpringTween(Arrow, "Rotation", 0, 0.2)
                    task.wait(0.3)
                    OptionsList.Visible = false
                    DropdownFrame.Size = UDim2.new(1, -10, 0, 45)
                end

                local function OpenDropdown()
                    isOpen = true
                    OptionsList.Visible = true
                    local listHeight = math.min(#options * 28, 120)
                    SpringTween(OptionsList, "Size", UDim2.new(1, -20, 0, listHeight), 0.3)
                    SpringTween(Arrow, "Rotation", 180, 0.25)
                    DropdownFrame.Size = UDim2.new(1, -10, 0, 45 + listHeight + 5)

                    local delay = 0
                    for _, child in ipairs(OptionsList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.Size = UDim2.new(1, -4, 0, 0)
                            task.delay(delay, function()
                                SpringTween(child, "Size", UDim2.new(1, -4, 0, 26), 0.15)
                            end)
                            delay = delay + 0.03
                        end
                    end
                end

                SelectedButton.MouseButton1Click:Connect(function()
                    if isOpen then
                        CloseDropdown()
                    else
                        OpenDropdown()
                    end
                end)

                for _, option in ipairs(options) do
                    local OptionButton = Instance.new("TextButton", OptionsList)
                    OptionButton.BackgroundColor3 = Library.Theme.ElementBackground
                    OptionButton.BackgroundTransparency = option == selected and 0 or 0.5
                    OptionButton.Size = UDim2.new(1, -4, 0, 26)
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Text = "  " .. option
                    OptionButton.TextColor3 = option == selected and Library.Theme.Accent or Library.Theme.Text
                    OptionButton.TextSize = 11
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    OptionButton.BorderSizePixel = 0

                    Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 4)

                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        SelectedButton.Text = "  " .. option

                        for _, btn in ipairs(OptionsList:GetChildren()) do
                            if btn:IsA("TextButton") then
                                btn.BackgroundTransparency = 0.5
                                btn.TextColor3 = Library.Theme.Text
                            end
                        end

                        OptionButton.BackgroundTransparency = 0
                        OptionButton.TextColor3 = Library.Theme.Accent

                        CloseDropdown()

                        if callback then
                            task.spawn(callback, option)
                        end

                        Library:LogActivity("Dropdown", text .. " = " .. option)
                    end)

                    OptionButton.MouseEnter:Connect(function()
                        if option ~= selected then
                            SpringTween(OptionButton, "BackgroundTransparency", 0.2, 0.1)
                        end
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        if option ~= selected then
                            SpringTween(OptionButton, "BackgroundTransparency", 0.5, 0.1)
                        end
                    end)
                end

                OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    OptionsList.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 4)
                end)

                DropdownFrame.MouseEnter:Connect(function()
                    if tooltip and not isOpen then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                DropdownFrame.MouseLeave:Connect(function()
                    HideTooltip()
                end)

                table.insert(Refresher, function()
                    DropdownFrame.BackgroundColor3 = Library.Theme.ElementBackground
                    Label.TextColor3 = Library.Theme.Text
                end)

                return {
                    SetValue = function(newValue)
                        for _, option in ipairs(options) do
                            if option == newValue then
                                selected = newValue
                                SelectedButton.Text = "  " .. newValue
                                break
                            end
                        end
                    end,
                    GetValue = function()
                        return selected
                    end
                }
            end

            function SectionLogic:CreateLabel(text)
                local Label = Instance.new("TextLabel", SubPage)
                Label.Name = text
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(1, -10, 0, 28)
                Label.Font = Enum.Font.Gotham
                Label.Text = text
                Label.TextColor3 = Library.Theme.TextDark
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true

                table.insert(Refresher, function()
                    Label.TextColor3 = Library.Theme.TextDark
                end)

                return {
                    SetText = function(newText)
                        Label.Text = newText
                    end
                }
            end

            function SectionLogic:CreateTextbox(text, tooltip, placeholder, callback)
                if type(tooltip) == "string" and not callback then
                    callback = placeholder
                    placeholder = tooltip
                    tooltip = nil
                end

                placeholder = placeholder or "Enter text..."

                local TextboxFrame = Instance.new("Frame", SubPage)
                TextboxFrame.Name = text
                TextboxFrame.BackgroundColor3 = Library.Theme.ElementBackground
                TextboxFrame.Size = UDim2.new(1, -10, 0, 55)
                TextboxFrame.BorderSizePixel = 0

                Instance.new("UICorner", TextboxFrame).CornerRadius = UDim.new(0, 8)
                AddStroke(TextboxFrame, Library.Theme.Accent, 1).Transparency = 0.7

                local Label = Instance.new("TextLabel", TextboxFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 15, 0, 8)
                Label.Size = UDim2.new(1, -30, 0, 18)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local Textbox = Instance.new("TextBox", TextboxFrame)
                Textbox.BackgroundColor3 = Library.Theme.ButtonBackground
                Textbox.Position = UDim2.new(0, 10, 0, 28)
                Textbox.Size = UDim2.new(1, -20, 0, 22)
                Textbox.Font = Enum.Font.Gotham
                Textbox.PlaceholderText = placeholder
                Textbox.PlaceholderColor3 = Library.Theme.TextMuted
                Textbox.Text = ""
                Textbox.TextColor3 = Library.Theme.Text
                Textbox.TextSize = 12
                Textbox.TextXAlignment = Enum.TextXAlignment.Left
                Textbox.ClearTextOnFocus = false
                Textbox.BorderSizePixel = 0

                Instance.new("UICorner", Textbox).CornerRadius = UDim.new(0, 6)
                local boxStroke = AddStroke(Textbox, Library.Theme.TextMuted, 1)

                local padding = Instance.new("UIPadding", Textbox)
                padding.PaddingLeft = UDim.new(0, 8)
                padding.PaddingRight = UDim.new(0, 8)

                Textbox.Focused:Connect(function()
                    SpringTween(boxStroke, "Color", Library.Theme.Accent, 0.2)
                    SpringTween(boxStroke, "Transparency", 0.2, 0.2)
                end)

                Textbox.FocusLost:Connect(function(enterPressed)
                    SpringTween(boxStroke, "Color", Library.Theme.TextMuted, 0.2)
                    SpringTween(boxStroke, "Transparency", 0.5, 0.2)

                    if enterPressed and callback then
                        task.spawn(callback, Textbox.Text)
                        Library:LogActivity("Textbox", text .. " = " .. Textbox.Text)
                    end
                end)

                TextboxFrame.MouseEnter:Connect(function()
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                TextboxFrame.MouseLeave:Connect(function()
                    HideTooltip()
                end)

                table.insert(Refresher, function()
                    TextboxFrame.BackgroundColor3 = Library.Theme.ElementBackground
                    Label.TextColor3 = Library.Theme.Text
                    Textbox.BackgroundColor3 = Library.Theme.ButtonBackground
                    Textbox.TextColor3 = Library.Theme.Text
                end)

                return {
                    SetText = function(newText)
                        Textbox.Text = newText
                    end,
                    GetText = function()
                        return Textbox.Text
                    end
                }
            end

            function SectionLogic:CreateKeybind(text, tooltip, default, callback)
                if type(tooltip) == "EnumItem" then
                    callback = default
                    default = tooltip
                    tooltip = nil
                end

                default = default or Enum.KeyCode.E

                local KeybindFrame = Instance.new("Frame", SubPage)
                KeybindFrame.Name = text
                KeybindFrame.BackgroundColor3 = Library.Theme.ElementBackground
                KeybindFrame.Size = UDim2.new(1, -10, 0, 45)
                KeybindFrame.BorderSizePixel = 0

                Instance.new("UICorner", KeybindFrame).CornerRadius = UDim.new(0, 8)
                AddStroke(KeybindFrame, Library.Theme.Accent, 1).Transparency = 0.7

                local Label = Instance.new("TextLabel", KeybindFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.Size = UDim2.new(1, -100, 1, 0)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local KeyButton = Instance.new("TextButton", KeybindFrame)
                KeyButton.BackgroundColor3 = Library.Theme.ButtonBackground
                KeyButton.Position = UDim2.new(1, -75, 0.5, -13)
                KeyButton.Size = UDim2.new(0, 60, 0, 26)
                KeyButton.Font = Enum.Font.GothamBold
                KeyButton.Text = default.Name
                KeyButton.TextColor3 = Library.Theme.Accent
                KeyButton.TextSize = 11
                KeyButton.BorderSizePixel = 0

                Instance.new("UICorner", KeyButton).CornerRadius = UDim.new(0, 6)
                AddStroke(KeyButton, Library.Theme.Accent, 1.5)

                local currentKey = default
                local listening = false

                KeyButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeyButton.Text = "..."
                    SpringTween(KeyButton, "BackgroundColor3", Library.Theme.Accent, 0.2)
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        currentKey = input.KeyCode
                        KeyButton.Text = currentKey.Name
                        SpringTween(KeyButton, "BackgroundColor3", Library.Theme.ButtonBackground, 0.2)

                        Library:LogActivity("Keybind", text .. " = " .. currentKey.Name)
                    end

                    if not gpe and input.KeyCode == currentKey and callback then
                        task.spawn(callback)
                    end
                end)

                KeybindFrame.MouseEnter:Connect(function()
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                KeybindFrame.MouseLeave:Connect(function()
                    HideTooltip()
                end)

                table.insert(Refresher, function()
                    KeybindFrame.BackgroundColor3 = Library.Theme.ElementBackground
                    Label.TextColor3 = Library.Theme.Text
                    KeyButton.BackgroundColor3 = Library.Theme.ButtonBackground
                end)

                return {
                    SetKey = function(newKey)
                        currentKey = newKey
                        KeyButton.Text = newKey.Name
                    end,
                    GetKey = function()
                        return currentKey
                    end
                }
            end

            function SectionLogic:CreateDivider()
                local Divider = Instance.new("Frame", SubPage)
                Divider.BackgroundColor3 = Library.Theme.Accent
                Divider.BackgroundTransparency = 0.8
                Divider.Size = UDim2.new(1, -10, 0, 2)
                Divider.BorderSizePixel = 0

                Instance.new("UICorner", Divider).CornerRadius = UDim.new(1, 0)

                return Divider
            end

            function SectionLogic:CreateColorPicker(text, tooltip, defaultColor, callback)
                if type(tooltip) == "Color3" then
                    callback = defaultColor
                    defaultColor = tooltip
                    tooltip = nil
                end

                defaultColor = defaultColor or Library.Theme.Accent

                local ColorFrame = Instance.new("Frame", SubPage)
                ColorFrame.Name = text
                ColorFrame.BackgroundColor3 = Library.Theme.ElementBackground
                ColorFrame.Size = UDim2.new(1, -10, 0, 45)
                ColorFrame.BorderSizePixel = 0

                Instance.new("UICorner", ColorFrame).CornerRadius = UDim.new(0, 8)
                AddStroke(ColorFrame, Library.Theme.Accent, 1).Transparency = 0.7

                local Label = Instance.new("TextLabel", ColorFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 15, 0, 0)
                Label.Size = UDim2.new(1, -80, 1, 0)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local ColorPreview = Instance.new("Frame", ColorFrame)
                ColorPreview.BackgroundColor3 = defaultColor
                ColorPreview.Position = UDim2.new(1, -55, 0.5, -13)
                ColorPreview.Size = UDim2.new(0, 40, 0, 26)
                ColorPreview.BorderSizePixel = 0

                Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 6)
                AddStroke(ColorPreview, Library.Theme.Accent, 2)
                AddGlow(ColorPreview, defaultColor, 20)

                local currentColor = defaultColor

                local ColorButton = Instance.new("TextButton", ColorPreview)
                ColorButton.BackgroundTransparency = 1
                ColorButton.Size = UDim2.new(1, 0, 1, 0)
                ColorButton.Text = ""

                ColorButton.MouseButton1Click:Connect(function()
                    local presets = {
                        Color3.fromRGB(124, 58, 237),
                        Color3.fromRGB(255, 100, 150),
                        Color3.fromRGB(60, 180, 255),
                        Color3.fromRGB(50, 200, 120),
                        Color3.fromRGB(255, 180, 60),
                        Color3.fromRGB(240, 80, 80)
                    }

                    local nextIndex = 1
                    for i, preset in ipairs(presets) do
                        if currentColor == preset then
                            nextIndex = (i % #presets) + 1
                            break
                        end
                    end

                    currentColor = presets[nextIndex]
                    SpringTween(ColorPreview, "BackgroundColor3", currentColor, 0.3)

                    if callback then
                        task.spawn(callback, currentColor)
                    end

                    Library:LogActivity("Color Picker", text)
                end)

                ColorFrame.MouseEnter:Connect(function()
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                ColorFrame.MouseLeave:Connect(function()
                    HideTooltip()
                end)

                table.insert(Refresher, function()
                    ColorFrame.BackgroundColor3 = Library.Theme.ElementBackground
                    Label.TextColor3 = Library.Theme.Text
                end)

                return {
                    SetColor = function(newColor)
                        currentColor = newColor
                        ColorPreview.BackgroundColor3 = newColor
                    end,
                    GetColor = function()
                        return currentColor
                    end
                }
            end

            return SectionLogic
        end

        return PageLogic
    end

    return WindowLogic
end


return Library
