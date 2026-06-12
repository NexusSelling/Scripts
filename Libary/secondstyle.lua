
local Library = {
    CurrentTab = nil,
    Tabs = {},
    Enabled = true,
    ToggleKey = Enum.KeyCode.RightControl,

    Theme = {
        MainBackground = Color3.fromRGB(13, 11, 23),
        SidebarBackground = Color3.fromRGB(11, 9, 19),
        ElementBackground = Color3.fromRGB(18, 16, 28),
        ButtonBackground = Color3.fromRGB(23, 20, 33),

        Accent = Color3.fromRGB(120, 60, 230),
        AccentDark = Color3.fromRGB(95, 42, 195),
        AccentLight = Color3.fromRGB(148, 88, 255),
        AccentGlow = Color3.fromRGB(155, 100, 255),
        AccentSoft = Color3.fromRGB(30, 24, 50),

        Text = Color3.fromRGB(240, 240, 245),
        TextDark = Color3.fromRGB(140, 135, 158),
        TextMuted = Color3.fromRGB(90, 85, 108),

        Divider = Color3.fromRGB(35, 30, 55),

        CornerRadius = UDim.new(0, 10),
        TitleSize = 24,
        TitleFont = Enum.Font.GothamBold,

        GlowIntensity = 0.6,
        BlurSize = 15,
        ParticleCount = 25,
        AnimationSpeed = 0.35
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
    },

    _connections = {},
    _guis = {}
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")


local function TrackConnection(conn)
    table.insert(Library._connections, conn)
    return conn
end

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

local function SmoothTween(obj, duration, goal)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
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
    glow.ImageTransparency = 0.75
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
    Ripple.BackgroundTransparency = 0.85
    Ripple.BorderSizePixel = 0
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.Position = UDim2.new(0, x, 0, y)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.ZIndex = 10

    Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1, 0)

    Tween(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, parent.AbsoluteSize.X * 2.5, 0, parent.AbsoluteSize.X * 2.5),
        BackgroundTransparency = 1
    })
    task.delay(0.5, function()
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
    ParticleContainer.ClipsDescendants = true

    local particles = {}

    for i = 1, Library.Theme.ParticleCount do
        local particle = Instance.new("Frame")
        particle.Name = "Particle_" .. i
        particle.Parent = ParticleContainer
        particle.BackgroundColor3 = Library.Theme.Accent
        particle.BackgroundTransparency = math.random(75, 92) / 100
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
            velocityX = (math.random(-8, 8) / 100),
            velocityY = (math.random(-8, 8) / 100),
            life = math.random(0, 100) / 10
        })
    end

    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not ParticleContainer or not ParticleContainer.Parent then
            conn:Disconnect()
            return
        end
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

            local pulse = 0.75 + (math.sin(p.life * 1.5) * 0.15)
            p.frame.BackgroundTransparency = pulse
        end
    end)

    TrackConnection(conn)
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
    CreateGradient(GlowLine, {Library.Theme.AccentLight, Library.Theme.Accent, Library.Theme.AccentDark})

    local Glow = AddGlow(GlowLine, Library.Theme.AccentGlow, 25)
    Glow.Size = UDim2.new(3, 0, 1, 20)
    Glow.ImageTransparency = 0.5

    local running = true
    local function pulse()
        while running and GlowLine and GlowLine.Parent do
            Tween(Glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {ImageTransparency = 0.25})
            task.wait(1.2)
            if not running then break end
            Tween(Glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {ImageTransparency = 0.6})
            task.wait(1.2)
        end
    end

    task.spawn(pulse)

    GlowLine.Destroying:Connect(function()
        running = false
    end)

    return GlowLine
end


local function CreateBadge(parent, text, color)
    if not Library.Config.ShowBadges then return end

    local Badge = Instance.new("Frame")
    Badge.Parent = parent
    Badge.BackgroundColor3 = color or Library.Theme.Accent
    Badge.Size = UDim2.new(0, 0, 0, 16)
    Badge.AutomaticSize = Enum.AutomaticSize.X
    Badge.BorderSizePixel = 0

    Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 8)

    local Padding = Instance.new("UIPadding", Badge)
    Padding.PaddingLeft = UDim.new(0, 7)
    Padding.PaddingRight = UDim.new(0, 7)

    local Label = Instance.new("TextLabel", Badge)
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 9

    local running = true
    task.spawn(function()
        while running and Badge and Badge.Parent do
            Tween(Badge, TweenInfo.new(2.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.25})
            task.wait(2.5)
            if not running then break end
            Tween(Badge, TweenInfo.new(2.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 0})
            task.wait(2.5)
        end
    end)

    Badge.Destroying:Connect(function()
        running = false
    end)

    return Badge
end


local function CreateAvatarCircle(parent, initials)
    local Avatar = Instance.new("Frame")
    Avatar.Name = "Avatar"
    Avatar.Parent = parent
    Avatar.BackgroundColor3 = Library.Theme.Accent
    Avatar.Size = UDim2.new(0, 36, 0, 36)
    Avatar.BorderSizePixel = 0

    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
    
    local stroke = AddStroke(Avatar, Library.Theme.AccentLight, 2)
    stroke.Transparency = 0.3

    CreateGradient(Avatar, {Library.Theme.AccentLight, Library.Theme.Accent})

    local Initials = Instance.new("TextLabel", Avatar)
    Initials.BackgroundTransparency = 1
    Initials.Size = UDim2.new(1, 0, 1, 0)
    Initials.Font = Enum.Font.GothamBold
    Initials.Text = initials or Library.Config.AvatarInitials
    Initials.TextColor3 = Color3.fromRGB(255, 255, 255)
    Initials.TextSize = 13

    local Glow = AddGlow(Avatar, Library.Theme.AccentGlow, 18)
    Glow.ImageTransparency = 1

    Avatar.MouseEnter:Connect(function()
        Tween(Glow, TweenInfo.new(0.3), {ImageTransparency = 0.4})
        SpringTween(Avatar, "Size", UDim2.new(0, 38, 0, 38), 0.2)
    end)

    Avatar.MouseLeave:Connect(function()
        Tween(Glow, TweenInfo.new(0.3), {ImageTransparency = 1})
        SpringTween(Avatar, "Size", UDim2.new(0, 36, 0, 36), 0.2)
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

    local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local tipX = pos.X + 15
    local tipY = pos.Y + 15

    if tipX > viewportSize.X - 200 then
        tipX = pos.X - 200
    end
    if tipY > viewportSize.Y - 60 then
        tipY = pos.Y - 50
    end

    local Tooltip = Instance.new("CanvasGroup", TipGui)
    Tooltip.BackgroundColor3 = Library.Theme.ElementBackground
    Tooltip.AutomaticSize = Enum.AutomaticSize.XY
    Tooltip.Position = UDim2.new(0, tipX, 0, tipY)
    Tooltip.BorderSizePixel = 0
    Tooltip.BackgroundTransparency = 0.05

    Instance.new("UICorner", Tooltip).CornerRadius = UDim.new(0, 8)
    local tipStroke = AddStroke(Tooltip, Library.Theme.Accent, 1)
    tipStroke.Transparency = 0.4

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
    Label.TextSize = 12
    Label.AutomaticSize = Enum.AutomaticSize.XY

    Tooltip.GroupTransparency = 1
    SmoothTween(Tooltip, 0.2, {GroupTransparency = 0})
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
        success = Color3.fromRGB(45, 200, 115),
        error = Color3.fromRGB(235, 75, 75),
        warning = Color3.fromRGB(245, 175, 55),
        info = Library.Theme.Accent
    }

    local typeIcons = {
        success = "✓",
        error = "✕",
        warning = "⚠",
        info = "ℹ"
    }

    local accentColor = typeColors[notifType] or Library.Theme.Accent
    local iconText = typeIcons[notifType] or "ℹ"

    local Notif = Instance.new("CanvasGroup")
    Notif.Parent = NotifyGui
    Notif.BackgroundColor3 = Library.Theme.SidebarBackground
    Notif.GroupTransparency = 0
    Notif.Size = UDim2.new(0, 310, 0, 72)
    Notif.Position = UDim2.new(1, 10, 1, -82)
    Notif.BorderSizePixel = 0

    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 10)
    local notifStroke = AddStroke(Notif, Library.Theme.Divider, 1)
    notifStroke.Transparency = 0.3

    -- Accent stripe on the left
    local AccentStripe = Instance.new("Frame", Notif)
    AccentStripe.BackgroundColor3 = accentColor
    AccentStripe.Size = UDim2.new(0, 3, 1, -8)
    AccentStripe.Position = UDim2.new(0, 4, 0, 4)
    AccentStripe.BorderSizePixel = 0
    Instance.new("UICorner", AccentStripe).CornerRadius = UDim.new(1, 0)

    -- Icon circle
    local IconCircle = Instance.new("Frame", Notif)
    IconCircle.BackgroundColor3 = accentColor
    IconCircle.BackgroundTransparency = 0.85
    IconCircle.Position = UDim2.new(0, 14, 0, 14)
    IconCircle.Size = UDim2.new(0, 28, 0, 28)
    IconCircle.BorderSizePixel = 0
    Instance.new("UICorner", IconCircle).CornerRadius = UDim.new(1, 0)

    local IconLabel = Instance.new("TextLabel", IconCircle)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Size = UDim2.new(1, 0, 1, 0)
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Text = iconText
    IconLabel.TextColor3 = accentColor
    IconLabel.TextSize = 14

    local Title = Instance.new("TextLabel", Notif)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 48, 0, 12)
    Title.Size = UDim2.new(1, -80, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Library.Theme.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", Notif)
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.new(0, 48, 0, 34)
    Desc.Size = UDim2.new(1, -65, 0, 28)
    Desc.Font = Enum.Font.Gotham
    Desc.Text = text
    Desc.TextColor3 = Library.Theme.TextDark
    Desc.TextSize = 12
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.TextWrapped = true

    -- Close button
    local CloseBtn = Instance.new("TextButton", Notif)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -28, 0, 6)
    CloseBtn.Size = UDim2.new(0, 22, 0, 22)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Library.Theme.TextMuted
    CloseBtn.TextSize = 16

    CloseBtn.MouseEnter:Connect(function()
        SmoothTween(CloseBtn, 0.15, {TextColor3 = Library.Theme.Text})
    end)
    CloseBtn.MouseLeave:Connect(function()
        SmoothTween(CloseBtn, 0.15, {TextColor3 = Library.Theme.TextMuted})
    end)

    -- Progress bar at bottom
    local ProgressBg = Instance.new("Frame", Notif)
    ProgressBg.BackgroundColor3 = Library.Theme.Divider
    ProgressBg.Position = UDim2.new(0, 8, 1, -5)
    ProgressBg.Size = UDim2.new(1, -16, 0, 2)
    ProgressBg.BorderSizePixel = 0
    Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1, 0)

    local ProgressFill = Instance.new("Frame", ProgressBg)
    ProgressFill.BackgroundColor3 = accentColor
    ProgressFill.Size = UDim2.new(1, 0, 1, 0)
    ProgressFill.BorderSizePixel = 0
    Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

    local function UpdatePositions()
        local count = 0
        for i = #ActiveNotifications, 1, -1 do
            local notif = ActiveNotifications[i]
            if notif and notif.Parent then
                local targetY = -82 - (count * 82)
                SmoothTween(notif, 0.4, {Position = UDim2.new(1, -320, 1, targetY)})
                count = count + 1
            end
        end
    end

    local function DismissNotif()
        local index = table.find(ActiveNotifications, Notif)
        if index then
            table.remove(ActiveNotifications, index)
            SmoothTween(Notif, 0.3, {GroupTransparency = 1})
            SmoothTween(Notif, 0.35, {Position = UDim2.new(1, 10, Notif.Position.Y.Scale, Notif.Position.Y.Offset)})
            task.delay(0.35, function()
                if Notif then Notif:Destroy() end
            end)
            UpdatePositions()
        end
    end

    CloseBtn.MouseButton1Click:Connect(DismissNotif)

    if #ActiveNotifications >= MAX_NOTIFICATIONS then
        local oldest = table.remove(ActiveNotifications, 1)
        if oldest and oldest.Parent then
            SmoothTween(oldest, 0.3, {GroupTransparency = 1})
            task.delay(0.3, function()
                if oldest then oldest:Destroy() end
            end)
        end
    end

    table.insert(ActiveNotifications, Notif)
    Notif.Size = UDim2.new(0, 0, 0, 0)
    Notif.Position = UDim2.new(1, 10, 1, -82)
    Notif.GroupTransparency = 1
    task.wait(0.03)
    UpdatePositions()

    SpringTween(Notif, "Size", UDim2.new(0, 310, 0, 72), 0.4)
    SmoothTween(Notif, 0.3, {GroupTransparency = 0})

    -- Animate progress bar
    local dur = duration or 4
    Tween(ProgressFill, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})

    task.delay(dur, function()
        DismissNotif()
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

function Library:Destroy()
    for _, conn in ipairs(Library._connections) do
        pcall(function() conn:Disconnect() end)
    end
    Library._connections = {}

    for _, gui in ipairs(Library._guis) do
        pcall(function() gui:Destroy() end)
    end
    Library._guis = {}

    pcall(function()
        local n = CoreGui:FindFirstChild("SecondStyleNotifications")
        if n then n:Destroy() end
    end)
    pcall(function()
        if TipGui then TipGui:Destroy() TipGui = nil end
    end)

    Library.Tabs = {}
    ActiveNotifications = {}
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
    table.insert(Library._guis, KeyGui)

    local BG = Instance.new("Frame", KeyGui)
    BG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BG.BackgroundTransparency = 0.3
    BG.Size = UDim2.new(1, 0, 1, 0)
    BG.BorderSizePixel = 0

    local Card = Instance.new("CanvasGroup", KeyGui)
    Card.BackgroundColor3 = Library.Theme.MainBackground
    Card.GroupTransparency = 0.02
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.Position = UDim2.new(0.5, 0, 0.5, 0)
    Card.Size = UDim2.new(0, 390, 0, 250)
    Card.BorderSizePixel = 0

    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)
    local cardStroke = AddStroke(Card, Library.Theme.Accent, 1.5)
    cardStroke.Transparency = 0.3
    AddGlow(Card, Library.Theme.AccentGlow, 60)

    CreateParticleSystem(Card)
    CreateGlowLine(Card)

    local TitleLabel = Instance.new("TextLabel", Card)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 22, 0, 22)
    TitleLabel.Size = UDim2.new(1, -44, 0, 28)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Library.Theme.Text
    TitleLabel.TextSize = 22
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    CreateGradient(TitleLabel, {Library.Theme.AccentLight, Library.Theme.Accent})

    local SubLabel = Instance.new("TextLabel", Card)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Position = UDim2.new(0, 22, 0, 54)
    SubLabel.Size = UDim2.new(1, -44, 0, 18)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.Text = subtitle
    SubLabel.TextColor3 = Library.Theme.TextDark
    SubLabel.TextSize = 12
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left

    local InputContainer = Instance.new("Frame", Card)
    InputContainer.BackgroundColor3 = Library.Theme.ElementBackground
    InputContainer.Position = UDim2.new(0, 22, 0, 88)
    InputContainer.Size = UDim2.new(1, -44, 0, 42)
    InputContainer.BorderSizePixel = 0

    Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 8)
    local inputStroke = AddStroke(InputContainer, Library.Theme.TextMuted, 1)
    inputStroke.Transparency = 0.4

    local InputBox = Instance.new("TextBox", InputContainer)
    InputBox.BackgroundTransparency = 1
    InputBox.Size = UDim2.new(1, -24, 1, 0)
    InputBox.Position = UDim2.new(0, 12, 0, 0)
    InputBox.Font = Enum.Font.GothamSemibold
    InputBox.PlaceholderText = "Enter key..."
    InputBox.PlaceholderColor3 = Library.Theme.TextMuted
    InputBox.Text = ""
    InputBox.TextColor3 = Library.Theme.Text
    InputBox.TextSize = 14
    InputBox.TextXAlignment = Enum.TextXAlignment.Left
    InputBox.ClearTextOnFocus = false

    InputBox.Focused:Connect(function()
        SmoothTween(inputStroke, 0.25, {Color = Library.Theme.Accent, Transparency = 0.15})
        SmoothTween(InputContainer, 0.25, {BackgroundColor3 = Library.Theme.AccentSoft})
    end)

    InputBox.FocusLost:Connect(function()
        SmoothTween(inputStroke, 0.25, {Color = Library.Theme.TextMuted, Transparency = 0.4})
        SmoothTween(InputContainer, 0.25, {BackgroundColor3 = Library.Theme.ElementBackground})
    end)

    local ConfirmBtn = Instance.new("TextButton", Card)
    ConfirmBtn.BackgroundColor3 = Library.Theme.Accent
    ConfirmBtn.Position = UDim2.new(0, 22, 0, 146)
    ConfirmBtn.Size = UDim2.new(0.5, -27, 0, 40)
    ConfirmBtn.Font = Enum.Font.GothamBold
    ConfirmBtn.Text = "Confirm"
    ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmBtn.TextSize = 14
    ConfirmBtn.BorderSizePixel = 0

    Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 8)
    CreateGradient(ConfirmBtn)

    local GetKeyBtn = Instance.new("TextButton", Card)
    GetKeyBtn.BackgroundColor3 = Library.Theme.ElementBackground
    GetKeyBtn.Position = UDim2.new(0.5, 5, 0, 146)
    GetKeyBtn.Size = UDim2.new(0.5, -27, 0, 40)
    GetKeyBtn.Font = Enum.Font.GothamSemibold
    GetKeyBtn.Text = keyLink and "Get Key" or "Copy Link"
    GetKeyBtn.TextColor3 = Library.Theme.Text
    GetKeyBtn.TextSize = 14
    GetKeyBtn.BorderSizePixel = 0

    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)
    local getKeyStroke = AddStroke(GetKeyBtn, Library.Theme.Accent, 1)
    getKeyStroke.Transparency = 0.4

    local StatusLabel = Instance.new("TextLabel", Card)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 22, 0, 198)
    StatusLabel.Size = UDim2.new(1, -44, 0, 24)
    StatusLabel.Font = Enum.Font.GothamSemibold
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Library.Theme.TextDark
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

    ConfirmBtn.MouseEnter:Connect(function()
        SmoothTween(ConfirmBtn, 0.2, {Size = UDim2.new(0.5, -27, 0, 42)})
    end)
    ConfirmBtn.MouseLeave:Connect(function()
        SmoothTween(ConfirmBtn, 0.2, {Size = UDim2.new(0.5, -27, 0, 40)})
    end)

    GetKeyBtn.MouseEnter:Connect(function()
        SmoothTween(GetKeyBtn, 0.2, {BackgroundColor3 = Library.Theme.ButtonBackground})
    end)
    GetKeyBtn.MouseLeave:Connect(function()
        SmoothTween(GetKeyBtn, 0.2, {BackgroundColor3 = Library.Theme.ElementBackground})
    end)

    local attempts = 0
    local validated = false

    local function TryValidate()
        local entered = InputBox.Text
        if entered == "" then
            StatusLabel.Text = "⚠ Please enter a key"
            StatusLabel.TextColor3 = Color3.fromRGB(245, 175, 55)
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
            StatusLabel.TextColor3 = Color3.fromRGB(45, 200, 115)

            SmoothTween(ConfirmBtn, 0.3, {BackgroundColor3 = Color3.fromRGB(45, 200, 115)})

            task.delay(0.8, function()
                SmoothTween(BG, 0.4, {BackgroundTransparency = 1})
                SmoothTween(Card, 0.4, {GroupTransparency = 1})
                task.wait(0.4)
                KeyGui:Destroy()
                if onSuccess then onSuccess() end
            end)
        else
            attempts = attempts + 1
            StatusLabel.Text = "✗ Invalid key! (" .. attempts .. " attempts)"
            StatusLabel.TextColor3 = Color3.fromRGB(235, 75, 75)

            -- Smoother shake
            local original = Card.Position
            SmoothTween(Card, 0.06, {Position = UDim2.new(0.5, 8, 0.5, 0)})
            task.wait(0.06)
            SmoothTween(Card, 0.06, {Position = UDim2.new(0.5, -8, 0.5, 0)})
            task.wait(0.06)
            SmoothTween(Card, 0.06, {Position = UDim2.new(0.5, 4, 0.5, 0)})
            task.wait(0.06)
            SmoothTween(Card, 0.1, {Position = original})

            if maxAttempts > 0 and attempts >= maxAttempts then
                StatusLabel.Text = "⛔ Too many failed attempts"
                task.delay(1.5, function()
                    KeyGui:Destroy()
                    if onFail then onFail() end
                end)
            end
        end
    end

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

    ConfirmBtn.MouseButton1Click:Connect(TryValidate)

    -- Enter key support
    InputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            TryValidate()
        end
    end)

    Card.GroupTransparency = 1
    Card.Size = UDim2.new(0, 0, 0, 0)
    task.wait(0.1)
    SpringTween(Card, "Size", UDim2.new(0, 390, 0, 250), 0.5)
    SmoothTween(Card, 0.4, {GroupTransparency = 0.02})

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

    -- Full-screen backdrop
    local Backdrop = Instance.new("Frame", LoadGui)
    Backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Backdrop.BackgroundTransparency = 0.4
    Backdrop.Size = UDim2.new(1, 0, 1, 0)
    Backdrop.BorderSizePixel = 0

    local Card = Instance.new("CanvasGroup", LoadGui)
    Card.BackgroundColor3 = Library.Theme.SidebarBackground
    Card.GroupTransparency = 0.05
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.Position = UDim2.new(0.5, 0, 0.5, 0)
    Card.Size = UDim2.new(0, 360, 0, logoIcon and 190 or 155)
    Card.BorderSizePixel = 0

    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)
    local cardStroke = AddStroke(Card, Library.Theme.Accent, 1.5)
    cardStroke.Transparency = 0.3
    AddGlow(Card, Library.Theme.AccentGlow, 80)

    local yOffset = 22

    if logoIcon then
        local Logo = Instance.new("ImageLabel", Card)
        Logo.BackgroundTransparency = 1
        Logo.AnchorPoint = Vector2.new(0.5, 0)
        Logo.Position = UDim2.new(0.5, 0, 0, 18)
        Logo.Size = UDim2.new(0, 38, 0, 38)
        Logo.Image = "rbxassetid://" .. tostring(logoIcon)
        Logo.ImageColor3 = Library.Theme.Accent

        local running = true
        task.spawn(function()
            while running and Logo and Logo.Parent do
                Tween(Logo, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = 360})
                task.wait(2)
                if not running then break end
                Logo.Rotation = 0
            end
        end)

        Logo.Destroying:Connect(function() running = false end)

        yOffset = 65
    end

    local TitleLabel = Instance.new("TextLabel", Card)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0)
    TitleLabel.Position = UDim2.new(0.5, 0, 0, yOffset)
    TitleLabel.Size = UDim2.new(1, -40, 0, 26)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextSize = 20
    TitleLabel.TextColor3 = Library.Theme.Text

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
    BarBG.Size = UDim2.new(0.82, 0, 0, 5)
    BarBG.BorderSizePixel = 0

    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame", BarBG)
    BarFill.BackgroundColor3 = Library.Theme.Accent
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BorderSizePixel = 0

    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)
    CreateGradient(BarFill)

    -- Percent label
    local PercentLabel = Instance.new("TextLabel", Card)
    PercentLabel.BackgroundTransparency = 1
    PercentLabel.AnchorPoint = Vector2.new(1, 0)
    PercentLabel.Position = UDim2.new(0.91, 0, 0, yOffset + 44)
    PercentLabel.Size = UDim2.new(0, 40, 0, 14)
    PercentLabel.Font = Enum.Font.GothamBold
    PercentLabel.Text = "0%"
    PercentLabel.TextColor3 = Library.Theme.Accent
    PercentLabel.TextSize = 11
    PercentLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Shimmer = Instance.new("Frame", BarFill)
    Shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Shimmer.BackgroundTransparency = 0.88
    Shimmer.Size = UDim2.new(0, 25, 1, 0)
    Shimmer.Position = UDim2.new(0, -25, 0, 0)
    Shimmer.BorderSizePixel = 0
    Instance.new("UICorner", Shimmer).CornerRadius = UDim.new(1, 0)

    local shimmerRunning = true
    task.spawn(function()
        while shimmerRunning and Shimmer and Shimmer.Parent do
            Tween(Shimmer, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                Position = UDim2.new(1, 0, 0, 0)
            })
            task.wait(1.2)
            if not shimmerRunning then break end
            Shimmer.Position = UDim2.new(0, -25, 0, 0)
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
    StepLabel.TextTransparency = 0

    Card.Size = UDim2.new(0, 0, 0, 0)
    Card.GroupTransparency = 1
    SpringTween(Card, "Size", UDim2.new(0, 360, 0, logoIcon and 190 or 155), 0.6)
    SmoothTween(Card, 0.4, {GroupTransparency = 0.05})

    if #steps > 0 then
        local stepDur = duration / #steps
        for i, stepText in ipairs(steps) do
            -- Fade out old text
            if i > 1 then
                SmoothTween(StepLabel, 0.15, {TextTransparency = 1})
                task.wait(0.15)
            end
            StepLabel.Text = stepText
            SmoothTween(StepLabel, 0.15, {TextTransparency = 0})

            local progress = i / #steps
            PercentLabel.Text = math.floor(progress * 100) .. "%"
            Tween(BarFill, TweenInfo.new(stepDur * 0.8, Enum.EasingStyle.Quint),
                {Size = UDim2.new(progress, 0, 1, 0)})
            task.wait(stepDur)
        end
    else
        Tween(BarFill, TweenInfo.new(duration, Enum.EasingStyle.Quint),
            {Size = UDim2.new(1, 0, 1, 0)})
        -- Animate percent
        task.spawn(function()
            local startTime = tick()
            while tick() - startTime < duration and PercentLabel and PercentLabel.Parent do
                local elapsed = tick() - startTime
                local pct = math.clamp(math.floor((elapsed / duration) * 100), 0, 100)
                PercentLabel.Text = pct .. "%"
                task.wait(0.05)
            end
            if PercentLabel and PercentLabel.Parent then
                PercentLabel.Text = "100%"
            end
        end)
        task.wait(duration)
    end

    shimmerRunning = false
    SmoothTween(Card, 0.4, {GroupTransparency = 1})
    SmoothTween(Backdrop, 0.4, {BackgroundTransparency = 1})
    task.wait(0.4)
    LoadGui:Destroy()
end


function Library:CreateWindow(hubName)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = hubName or "SecondStyleUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    table.insert(Library._guis, ScreenGui)

    local windowSize = Library.Config.WindowSize

    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Library.Theme.MainBackground
    MainFrame.GroupTransparency = 0.02
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -windowSize.X/2, 0.5, -windowSize.Y/2)
    MainFrame.Size = UDim2.new(0, windowSize.X, 0, windowSize.Y)
    MainFrame.ClipsDescendants = true

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    local mainStroke = AddStroke(MainFrame, Library.Theme.Accent, 1.5)
    mainStroke.Transparency = 0.35
    AddGlow(MainFrame, Library.Theme.AccentGlow, 100)

    CreateParticleSystem(MainFrame)

    TrackConnection(UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Enabled = not Library.Enabled
            MainFrame.Visible = Library.Enabled

            if Library.Enabled then
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                MainFrame.GroupTransparency = 1
                SpringTween(MainFrame, "Size", UDim2.new(0, windowSize.X, 0, windowSize.Y), 0.45)
                SmoothTween(MainFrame, 0.35, {GroupTransparency = 0.02})
            end

            Library:LogActivity("UI Toggle", Library.Enabled and "Opened" or "Closed")
        end
    end))

    -- Sidebar
    local sidebarWidth = 210
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Library.Theme.SidebarBackground
    Sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
    Sidebar.BorderSizePixel = 0

    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

    CreateGlowLine(Sidebar)

    -- Sidebar right edge separator
    local SidebarSep = Instance.new("Frame", Sidebar)
    SidebarSep.BackgroundColor3 = Library.Theme.Divider
    SidebarSep.Position = UDim2.new(1, -1, 0, 10)
    SidebarSep.Size = UDim2.new(0, 1, 1, -20)
    SidebarSep.BorderSizePixel = 0
    SidebarSep.BackgroundTransparency = 0.5

    -- Header
    local Header = Instance.new("Frame", Sidebar)
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.new(0, 16, 0, 16)
    Header.Size = UDim2.new(1, -32, 0, 50)

    local Avatar = CreateAvatarCircle(Header, Library.Config.AvatarInitials)
    Avatar.Position = UDim2.new(0, 0, 0, 0)

    local NameLabel = Instance.new("TextLabel", Header)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0, 46, 0, 2)
    NameLabel.Size = UDim2.new(1, -46, 0, 22)
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = hubName or "SecondStyle"
    NameLabel.TextColor3 = Library.Theme.Text
    NameLabel.TextSize = 15
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local StatusLabel = Instance.new("TextLabel", Header)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 46, 0, 24)
    StatusLabel.Size = UDim2.new(1, -46, 0, 16)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "● Online"
    StatusLabel.TextColor3 = Color3.fromRGB(45, 200, 115)
    StatusLabel.TextSize = 11
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Smoother status pulse
    local statusRunning = true
    task.spawn(function()
        while statusRunning and StatusLabel and StatusLabel.Parent do
            SmoothTween(StatusLabel, 1.5, {TextColor3 = Color3.fromRGB(35, 160, 90)})
            task.wait(1.5)
            if not statusRunning then break end
            SmoothTween(StatusLabel, 1.5, {TextColor3 = Color3.fromRGB(45, 200, 115)})
            task.wait(1.5)
        end
    end)

    -- Header separator
    local HeaderSep = Instance.new("Frame", Sidebar)
    HeaderSep.BackgroundColor3 = Library.Theme.Divider
    HeaderSep.Position = UDim2.new(0, 16, 0, 74)
    HeaderSep.Size = UDim2.new(1, -32, 0, 1)
    HeaderSep.BorderSizePixel = 0
    HeaderSep.BackgroundTransparency = 0.3

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 12, 0, 84)
    TabContainer.Size = UDim2.new(1, -24, 1, -100)
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = Library.Theme.Accent
    TabContainer.ScrollBarImageTransparency = 0.5
    TabContainer.BorderSizePixel = 0

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 4)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    local PageContainer = Instance.new("Frame")
    PageContainer.Parent = MainFrame
    PageContainer.BackgroundTransparency = 1
    PageContainer.Position = UDim2.new(0, sidebarWidth, 0, 0)
    PageContainer.Size = UDim2.new(1, -sidebarWidth, 1, 0)
    PageContainer.ClipsDescendants = true

    -- Drag
    local dragging, dragStart, startPos

    Sidebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end))

    TrackConnection(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    -- Intro animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.GroupTransparency = 1
    task.wait(0.1)
    SpringTween(MainFrame, "Size", UDim2.new(0, windowSize.X, 0, windowSize.Y), 0.5)
    SmoothTween(MainFrame, 0.4, {GroupTransparency = 0.02})

    Library:LogActivity("Window Created", hubName or "SecondStyle")

    local WindowLogic = {}


    function WindowLogic:CreateTab(name, iconID)
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Name = name
        TabButton.BackgroundColor3 = Library.Theme.ElementBackground
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 0, 42)
        TabButton.Text = ""
        TabButton.BorderSizePixel = 0

        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)

        local Icon = Instance.new("ImageLabel", TabButton)
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0, 14, 0.5, -10)
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Image = iconID and "rbxassetid://" .. tostring(iconID) or "rbxassetid://3926305904"
        Icon.ImageColor3 = Library.Theme.TextDark

        local TabLabel = Instance.new("TextLabel", TabButton)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position = UDim2.new(0, 44, 0, 0)
        TabLabel.Size = UDim2.new(1, -70, 1, 0)
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.Text = name
        TabLabel.TextColor3 = Library.Theme.TextDark
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left

        local Badge = CreateBadge(TabButton, "NEW", Library.Theme.Accent)
        if Badge then
            Badge.Position = UDim2.new(1, -45, 0.5, -8)
            Badge.Visible = false
        end

        local Indicator = Instance.new("Frame", TabButton)
        Indicator.BackgroundColor3 = Library.Theme.Accent
        Indicator.Position = UDim2.new(0, 0, 0, 8)
        Indicator.Size = UDim2.new(0, 4, 1, -16)
        Indicator.BorderSizePixel = 0
        Indicator.Transparency = 1

        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
        CreateGradient(Indicator, {Library.Theme.AccentLight, Library.Theme.Accent})

        local Page = Instance.new("CanvasGroup", PageContainer)
        Page.Name = name .. "_Page"
        Page.BackgroundTransparency = 1
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.GroupTransparency = 1

        local TopBar = Instance.new("ScrollingFrame", Page)
        TopBar.BackgroundTransparency = 1
        TopBar.Position = UDim2.new(0, 16, 0, 16)
        TopBar.Size = UDim2.new(1, -32, 0, 38)
        TopBar.ScrollBarThickness = 0
        TopBar.CanvasSize = UDim2.new(0, 0, 0, 0)
        TopBar.ScrollingDirection = Enum.ScrollingDirection.X
        TopBar.BorderSizePixel = 0

        local TopBarList = Instance.new("UIListLayout", TopBar)
        TopBarList.FillDirection = Enum.FillDirection.Horizontal
        TopBarList.Padding = UDim.new(0, 8)
        TopBarList.SortOrder = Enum.SortOrder.LayoutOrder

        local ContentContainer = Instance.new("Frame", Page)
        ContentContainer.BackgroundTransparency = 1
        ContentContainer.Position = UDim2.new(0, 16, 0, 62)
        ContentContainer.Size = UDim2.new(1, -32, 1, -78)

        local SubTabs = {}

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Library.Tabs) do
                t.Page.Visible = false
                SmoothTween(t.Page, 0.15, {GroupTransparency = 1})
                SmoothTween(t.Label, 0.2, {TextColor3 = Library.Theme.TextDark})
                SmoothTween(t.Icon, 0.2, {ImageColor3 = Library.Theme.TextDark})
                SmoothTween(t.Button, 0.2, {BackgroundTransparency = 1})
                SmoothTween(t.Indicator, 0.2, {Transparency = 1})
            end

            Page.Visible = true
            Page.Position = UDim2.new(0.02, 0, 0, 0)
            SmoothTween(Page, 0.3, {GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0)})
            SmoothTween(TabLabel, 0.25, {TextColor3 = Library.Theme.Text})
            SmoothTween(Icon, 0.25, {ImageColor3 = Library.Theme.Accent})
            SmoothTween(TabButton, 0.25, {BackgroundTransparency = 0, BackgroundColor3 = Library.Theme.ElementBackground})
            SmoothTween(Indicator, 0.25, {Transparency = 0})

            Library:LogActivity("Tab Changed", name)
        end)

        TabButton.MouseEnter:Connect(function()
            if not Page.Visible then
                SmoothTween(TabButton, 0.2, {BackgroundTransparency = 0.4, BackgroundColor3 = Library.Theme.ElementBackground})
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if not Page.Visible then
                SmoothTween(TabButton, 0.2, {BackgroundTransparency = 1})
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
            btnPadding.PaddingLeft = UDim.new(0, 14)
            btnPadding.PaddingRight = UDim.new(0, 14)

            local Underline = Instance.new("Frame", SubTabButton)
            Underline.BackgroundColor3 = Library.Theme.Accent
            Underline.Position = UDim2.new(0.1, 0, 1, -3)
            Underline.Size = UDim2.new(0.8, 0, 0, 3)
            Underline.BorderSizePixel = 0
            Underline.Transparency = 1

            Instance.new("UICorner", Underline).CornerRadius = UDim.new(1, 0)
            CreateGradient(Underline)

            local SubPage = Instance.new("ScrollingFrame", ContentContainer)
            SubPage.Name = sectionName .. "_SubPage"
            SubPage.BackgroundTransparency = 1
            SubPage.Size = UDim2.new(1, 0, 1, 0)
            SubPage.Visible = false
            SubPage.ScrollBarThickness = 3
            SubPage.ScrollBarImageColor3 = Library.Theme.Accent
            SubPage.ScrollBarImageTransparency = 0.4
            SubPage.BorderSizePixel = 0
            SubPage.CanvasSize = UDim2.new(0, 0, 0, 0)

            local SubPageList = Instance.new("UIListLayout", SubPage)
            SubPageList.Padding = UDim.new(0, 8)
            SubPageList.SortOrder = Enum.SortOrder.LayoutOrder

            SubPageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SubPage.CanvasSize = UDim2.new(0, 0, 0, SubPageList.AbsoluteContentSize.Y + 10)
            end)

            SubTabButton.MouseButton1Click:Connect(function()
                for _, st in pairs(SubTabs) do
                    st.Page.Visible = false
                    st.Page.Position = UDim2.new(0, 0, 0, 0)
                    SmoothTween(st.Btn, 0.2, {
                        TextColor3 = Library.Theme.TextDark,
                        BackgroundTransparency = 1
                    })
                    SmoothTween(st.Underline, 0.2, {Transparency = 1})
                end

                SubPage.Visible = true
                SubPage.Position = UDim2.new(0, 0, 0.02, 0)
                SmoothTween(SubTabButton, 0.2, {TextColor3 = Library.Theme.Text, BackgroundTransparency = 0})
                SmoothTween(Underline, 0.2, {Transparency = 0})
                SmoothTween(SubPage, 0.25, {Position = UDim2.new(0, 0, 0, 0)})

                Library:LogActivity("Section Changed", name .. " > " .. sectionName)
            end)

            SubTabButton.MouseEnter:Connect(function()
                if not SubPage.Visible then
                    SmoothTween(SubTabButton, 0.15, {BackgroundTransparency = 0.5})
                end
            end)

            SubTabButton.MouseLeave:Connect(function()
                if not SubPage.Visible then
                    SmoothTween(SubTabButton, 0.15, {BackgroundTransparency = 1})
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
                Button.Size = UDim2.new(1, -8, 0, 40)
                Button.Font = Enum.Font.GothamSemibold
                Button.Text = ""
                Button.TextColor3 = Library.Theme.Text
                Button.TextSize = 14
                Button.BorderSizePixel = 0
                Button.ClipsDescendants = true

                Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

                -- Left accent bar
                local LeftAccent = Instance.new("Frame", Button)
                LeftAccent.BackgroundColor3 = Library.Theme.Accent
                LeftAccent.Size = UDim2.new(0, 3, 0.6, 0)
                LeftAccent.Position = UDim2.new(0, 0, 0.2, 0)
                LeftAccent.BorderSizePixel = 0
                LeftAccent.BackgroundTransparency = 0.6
                Instance.new("UICorner", LeftAccent).CornerRadius = UDim.new(1, 0)

                local BtnLabel = Instance.new("TextLabel", Button)
                BtnLabel.BackgroundTransparency = 1
                BtnLabel.Position = UDim2.new(0, 14, 0, 0)
                BtnLabel.Size = UDim2.new(1, -28, 1, 0)
                BtnLabel.Font = Enum.Font.GothamSemibold
                BtnLabel.Text = text
                BtnLabel.TextColor3 = Library.Theme.Text
                BtnLabel.TextSize = 13
                BtnLabel.TextXAlignment = Enum.TextXAlignment.Left

                local btnStroke = AddStroke(Button, Library.Theme.Divider, 1)
                btnStroke.Transparency = 0.5

                Button.MouseEnter:Connect(function()
                    SmoothTween(Button, 0.2, {BackgroundColor3 = Library.Theme.ElementBackground})
                    SmoothTween(btnStroke, 0.2, {Transparency = 0.2, Color = Library.Theme.Accent})
                    SmoothTween(LeftAccent, 0.2, {BackgroundTransparency = 0, Size = UDim2.new(0, 3, 0.7, 0)})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                Button.MouseLeave:Connect(function()
                    SmoothTween(Button, 0.25, {BackgroundColor3 = Library.Theme.ButtonBackground})
                    SmoothTween(btnStroke, 0.25, {Transparency = 0.5, Color = Library.Theme.Divider})
                    SmoothTween(LeftAccent, 0.25, {BackgroundTransparency = 0.6, Size = UDim2.new(0, 3, 0.6, 0)})
                    HideTooltip()
                end)

                Button.MouseButton1Down:Connect(function()
                    local mousePos = UserInputService:GetMouseLocation()
                    local relX = mousePos.X - Button.AbsolutePosition.X
                    local relY = mousePos.Y - Button.AbsolutePosition.Y
                    CreateRipple(Button, relX, relY, Library.Theme.AccentLight)
                    SmoothTween(Button, 0.08, {BackgroundColor3 = Library.Theme.AccentSoft})
                end)

                Button.MouseButton1Click:Connect(function()
                    SmoothTween(Button, 0.25, {BackgroundColor3 = Library.Theme.ElementBackground})
                    if callback then
                        task.spawn(callback)
                    end
                    Library:LogActivity("Button Click", text)
                end)

                table.insert(Refresher, function()
                    Button.BackgroundColor3 = Library.Theme.ButtonBackground
                    BtnLabel.TextColor3 = Library.Theme.Text
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
                ToggleFrame.Size = UDim2.new(1, -8, 0, 44)
                ToggleFrame.BorderSizePixel = 0

                Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
                local tglStroke = AddStroke(ToggleFrame, Library.Theme.Divider, 1)
                tglStroke.Transparency = 0.5

                local Label = Instance.new("TextLabel", ToggleFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 14, 0, 0)
                Label.Size = UDim2.new(1, -80, 1, 0)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left

                -- Modern pill switch (48x26)
                local SwitchContainer = Instance.new("Frame", ToggleFrame)
                SwitchContainer.BackgroundColor3 = Color3.fromRGB(38, 35, 50)
                SwitchContainer.Position = UDim2.new(1, -58, 0.5, -13)
                SwitchContainer.Size = UDim2.new(0, 48, 0, 26)
                SwitchContainer.BorderSizePixel = 0

                Instance.new("UICorner", SwitchContainer).CornerRadius = UDim.new(1, 0)
                local switchStroke = AddStroke(SwitchContainer, Color3.fromRGB(50, 48, 65), 1)
                switchStroke.Transparency = 0.3

                local SwitchKnob = Instance.new("Frame", SwitchContainer)
                SwitchKnob.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
                SwitchKnob.Position = UDim2.new(0, 3, 0.5, -10)
                SwitchKnob.Size = UDim2.new(0, 20, 0, 20)
                SwitchKnob.BorderSizePixel = 0

                Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)

                local state = startState

                local function UpdateToggle(animate)
                    if state then
                        if animate then
                            SmoothTween(SwitchContainer, 0.3, {BackgroundColor3 = Library.Theme.Accent})
                            SmoothTween(switchStroke, 0.3, {Color = Library.Theme.AccentDark})
                            SmoothTween(SwitchKnob, 0.25, {Position = UDim2.new(1, -23, 0.5, -10)})
                            SmoothTween(SwitchKnob, 0.25, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                            -- Elastic pop
                            SpringTween(SwitchKnob, "Size", UDim2.new(0, 22, 0, 22), 0.12)
                            task.delay(0.12, function()
                                if SwitchKnob and SwitchKnob.Parent then
                                    SmoothTween(SwitchKnob, 0.15, {Size = UDim2.new(0, 20, 0, 20)})
                                end
                            end)
                        else
                            SwitchContainer.BackgroundColor3 = Library.Theme.Accent
                            switchStroke.Color = Library.Theme.AccentDark
                            SwitchKnob.Position = UDim2.new(1, -23, 0.5, -10)
                            SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        end
                    else
                        if animate then
                            SmoothTween(SwitchContainer, 0.3, {BackgroundColor3 = Color3.fromRGB(38, 35, 50)})
                            SmoothTween(switchStroke, 0.3, {Color = Color3.fromRGB(50, 48, 65)})
                            SmoothTween(SwitchKnob, 0.25, {Position = UDim2.new(0, 3, 0.5, -10)})
                            SmoothTween(SwitchKnob, 0.25, {BackgroundColor3 = Color3.fromRGB(180, 180, 190)})
                            SpringTween(SwitchKnob, "Size", UDim2.new(0, 22, 0, 22), 0.12)
                            task.delay(0.12, function()
                                if SwitchKnob and SwitchKnob.Parent then
                                    SmoothTween(SwitchKnob, 0.15, {Size = UDim2.new(0, 20, 0, 20)})
                                end
                            end)
                        else
                            SwitchContainer.BackgroundColor3 = Color3.fromRGB(38, 35, 50)
                            switchStroke.Color = Color3.fromRGB(50, 48, 65)
                            SwitchKnob.Position = UDim2.new(0, 3, 0.5, -10)
                            SwitchKnob.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
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

                ToggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    UpdateToggle(true)

                    if callback then
                        task.spawn(callback, state)
                    end

                    Library:LogActivity("Toggle", text .. " = " .. tostring(state))
                end)

                ToggleFrame.MouseEnter:Connect(function()
                    SmoothTween(tglStroke, 0.2, {Transparency = 0.2, Color = Library.Theme.Accent})
                    SmoothTween(ToggleFrame, 0.2, {BackgroundColor3 = Library.Theme.ButtonBackground})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                ToggleFrame.MouseLeave:Connect(function()
                    SmoothTween(tglStroke, 0.25, {Transparency = 0.5, Color = Library.Theme.Divider})
                    SmoothTween(ToggleFrame, 0.25, {BackgroundColor3 = Library.Theme.ElementBackground})
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
                SliderFrame.Size = UDim2.new(1, -8, 0, 54)
                SliderFrame.BorderSizePixel = 0

                Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)
                local sliderStroke = AddStroke(SliderFrame, Library.Theme.Divider, 1)
                sliderStroke.Transparency = 0.5

                local Label = Instance.new("TextLabel", SliderFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 14, 0, 7)
                Label.Size = UDim2.new(1, -80, 0, 18)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local ValueLabel = Instance.new("TextLabel", SliderFrame)
                ValueLabel.BackgroundColor3 = Library.Theme.ButtonBackground
                ValueLabel.Position = UDim2.new(1, -58, 0, 6)
                ValueLabel.Size = UDim2.new(0, 44, 0, 20)
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.Text = tostring(default)
                ValueLabel.TextColor3 = Library.Theme.Accent
                ValueLabel.TextSize = 11

                Instance.new("UICorner", ValueLabel).CornerRadius = UDim.new(0, 6)

                local SliderTrack = Instance.new("Frame", SliderFrame)
                SliderTrack.BackgroundColor3 = Color3.fromRGB(35, 33, 48)
                SliderTrack.Position = UDim2.new(0, 14, 1, -17)
                SliderTrack.Size = UDim2.new(1, -28, 0, 5)
                SliderTrack.BorderSizePixel = 0

                Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

                local SliderFill = Instance.new("Frame", SliderTrack)
                SliderFill.BackgroundColor3 = Library.Theme.Accent
                SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                SliderFill.BorderSizePixel = 0

                Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
                CreateGradient(SliderFill)

                local SliderKnob = Instance.new("Frame", SliderTrack)
                SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
                SliderKnob.Size = UDim2.new(0, 14, 0, 14)
                SliderKnob.BorderSizePixel = 0

                Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)
                local knobStroke = AddStroke(SliderKnob, Library.Theme.Accent, 2)
                knobStroke.Transparency = 0.1

                local value = default
                local isDragging = false

                local function UpdateSlider(input)
                    local relativeX = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (relativeX * (max - min)))

                    SmoothTween(SliderFill, 0.06, {Size = UDim2.new(relativeX, 0, 1, 0)})
                    SmoothTween(SliderKnob, 0.06, {Position = UDim2.new(relativeX, 0, 0.5, 0)})

                    ValueLabel.Text = tostring(value)

                    if callback then
                        task.spawn(callback, value)
                    end
                end

                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                        SmoothTween(SliderKnob, 0.15, {Size = UDim2.new(0, 18, 0, 18)})
                        SmoothTween(knobStroke, 0.15, {Transparency = 0})
                        UpdateSlider(input)
                        Library:LogActivity("Slider", text .. " = " .. tostring(value))
                    end
                end)

                SliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                        SmoothTween(SliderKnob, 0.2, {Size = UDim2.new(0, 14, 0, 14)})
                        SmoothTween(knobStroke, 0.2, {Transparency = 0.1})
                    end
                end)

                TrackConnection(UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end))

                TrackConnection(UserInputService.InputEnded:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                        SmoothTween(SliderKnob, 0.2, {Size = UDim2.new(0, 14, 0, 14)})
                        SmoothTween(knobStroke, 0.2, {Transparency = 0.1})
                    end
                end))

                SliderFrame.MouseEnter:Connect(function()
                    SmoothTween(sliderStroke, 0.2, {Transparency = 0.2, Color = Library.Theme.Accent})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                SliderFrame.MouseLeave:Connect(function()
                    SmoothTween(sliderStroke, 0.25, {Transparency = 0.5, Color = Library.Theme.Divider})
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
                DropdownFrame.Size = UDim2.new(1, -8, 0, 44)
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.ClipsDescendants = false
                DropdownFrame.ZIndex = 2

                Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)
                local ddStroke = AddStroke(DropdownFrame, Library.Theme.Divider, 1)
                ddStroke.Transparency = 0.5

                local Label = Instance.new("TextLabel", DropdownFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 14, 0, 0)
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

                Instance.new("UICorner", SelectedButton).CornerRadius = UDim.new(0, 5)

                local Arrow = Instance.new("TextLabel", SelectedButton)
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -20, 0, 0)
                Arrow.Size = UDim2.new(0, 20, 1, 0)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Text = "▼"
                Arrow.TextColor3 = Library.Theme.TextDark
                Arrow.TextSize = 9

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
                local optStroke = AddStroke(OptionsList, Library.Theme.Accent, 1)
                optStroke.Transparency = 0.3

                local OptionsLayout = Instance.new("UIListLayout", OptionsList)
                OptionsLayout.Padding = UDim.new(0, 2)

                local selected = default
                local isOpen = false

                local function CloseDropdown()
                    isOpen = false
                    SmoothTween(OptionsList, 0.25, {Size = UDim2.new(1, -20, 0, 0)})
                    SmoothTween(Arrow, 0.2, {Rotation = 0})
                    task.delay(0.25, function()
                        OptionsList.Visible = false
                        DropdownFrame.Size = UDim2.new(1, -8, 0, 44)
                    end)
                end

                local function OpenDropdown()
                    isOpen = true
                    OptionsList.Visible = true
                    local listHeight = math.min(#options * 26, 140)
                    SmoothTween(OptionsList, 0.25, {Size = UDim2.new(1, -20, 0, listHeight)})
                    SmoothTween(Arrow, 0.2, {Rotation = 180})
                    DropdownFrame.Size = UDim2.new(1, -8, 0, 44 + listHeight + 5)

                    local delay = 0
                    for _, child in ipairs(OptionsList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.Size = UDim2.new(1, -4, 0, 0)
                            task.delay(delay, function()
                                SmoothTween(child, 0.15, {Size = UDim2.new(1, -4, 0, 24)})
                            end)
                            delay = delay + 0.025
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
                    OptionButton.Size = UDim2.new(1, -4, 0, 24)
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
                            SmoothTween(OptionButton, 0.1, {BackgroundTransparency = 0.2})
                        end
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        if option ~= selected then
                            SmoothTween(OptionButton, 0.1, {BackgroundTransparency = 0.5})
                        end
                    end)
                end

                OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    OptionsList.CanvasSize = UDim2.new(0, 0, 0, OptionsLayout.AbsoluteContentSize.Y + 4)
                end)

                DropdownFrame.MouseEnter:Connect(function()
                    SmoothTween(ddStroke, 0.2, {Transparency = 0.2, Color = Library.Theme.Accent})
                    if tooltip and not isOpen then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                DropdownFrame.MouseLeave:Connect(function()
                    SmoothTween(ddStroke, 0.25, {Transparency = 0.5, Color = Library.Theme.Divider})
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
                Label.Size = UDim2.new(1, -8, 0, 26)
                Label.Font = Enum.Font.Gotham
                Label.Text = text
                Label.TextColor3 = Library.Theme.TextDark
                Label.TextSize = 12
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

            function SectionLogic:CreateSpacer(height)
                height = height or 8
                local Spacer = Instance.new("Frame", SubPage)
                Spacer.BackgroundTransparency = 1
                Spacer.Size = UDim2.new(1, 0, 0, height)
                Spacer.BorderSizePixel = 0
                return Spacer
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
                TextboxFrame.Size = UDim2.new(1, -8, 0, 54)
                TextboxFrame.BorderSizePixel = 0

                Instance.new("UICorner", TextboxFrame).CornerRadius = UDim.new(0, 8)
                local tbStroke = AddStroke(TextboxFrame, Library.Theme.Divider, 1)
                tbStroke.Transparency = 0.5

                local Label = Instance.new("TextLabel", TextboxFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 14, 0, 7)
                Label.Size = UDim2.new(1, -28, 0, 18)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 12
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

                Instance.new("UICorner", Textbox).CornerRadius = UDim.new(0, 5)
                local boxStroke = AddStroke(Textbox, Library.Theme.TextMuted, 1)
                boxStroke.Transparency = 0.5

                local padding = Instance.new("UIPadding", Textbox)
                padding.PaddingLeft = UDim.new(0, 8)
                padding.PaddingRight = UDim.new(0, 8)

                Textbox.Focused:Connect(function()
                    SmoothTween(boxStroke, 0.2, {Color = Library.Theme.Accent, Transparency = 0.15})
                    SmoothTween(Textbox, 0.2, {BackgroundColor3 = Library.Theme.AccentSoft})
                end)

                Textbox.FocusLost:Connect(function(enterPressed)
                    SmoothTween(boxStroke, 0.2, {Color = Library.Theme.TextMuted, Transparency = 0.5})
                    SmoothTween(Textbox, 0.2, {BackgroundColor3 = Library.Theme.ButtonBackground})

                    if enterPressed and callback then
                        task.spawn(callback, Textbox.Text)
                        Library:LogActivity("Textbox", text .. " = " .. Textbox.Text)
                    end
                end)

                TextboxFrame.MouseEnter:Connect(function()
                    SmoothTween(tbStroke, 0.2, {Transparency = 0.2, Color = Library.Theme.Accent})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                TextboxFrame.MouseLeave:Connect(function()
                    SmoothTween(tbStroke, 0.25, {Transparency = 0.5, Color = Library.Theme.Divider})
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
                KeybindFrame.Size = UDim2.new(1, -8, 0, 44)
                KeybindFrame.BorderSizePixel = 0

                Instance.new("UICorner", KeybindFrame).CornerRadius = UDim.new(0, 8)
                local kbStroke = AddStroke(KeybindFrame, Library.Theme.Divider, 1)
                kbStroke.Transparency = 0.5

                local Label = Instance.new("TextLabel", KeybindFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 14, 0, 0)
                Label.Size = UDim2.new(1, -100, 1, 0)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local KeyButton = Instance.new("TextButton", KeybindFrame)
                KeyButton.BackgroundColor3 = Library.Theme.ButtonBackground
                KeyButton.Position = UDim2.new(1, -72, 0.5, -12)
                KeyButton.Size = UDim2.new(0, 58, 0, 24)
                KeyButton.Font = Enum.Font.GothamBold
                KeyButton.Text = default.Name
                KeyButton.TextColor3 = Library.Theme.Accent
                KeyButton.TextSize = 11
                KeyButton.BorderSizePixel = 0

                Instance.new("UICorner", KeyButton).CornerRadius = UDim.new(0, 6)
                local keyStroke = AddStroke(KeyButton, Library.Theme.Accent, 1)
                keyStroke.Transparency = 0.4

                local currentKey = default
                local listening = false

                KeyButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeyButton.Text = "..."
                    SmoothTween(KeyButton, 0.2, {BackgroundColor3 = Library.Theme.AccentSoft})
                    SmoothTween(keyStroke, 0.2, {Transparency = 0})
                end)

                TrackConnection(UserInputService.InputBegan:Connect(function(input, gpe)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        currentKey = input.KeyCode
                        KeyButton.Text = currentKey.Name
                        SmoothTween(KeyButton, 0.2, {BackgroundColor3 = Library.Theme.ButtonBackground})
                        SmoothTween(keyStroke, 0.2, {Transparency = 0.4})

                        Library:LogActivity("Keybind", text .. " = " .. currentKey.Name)
                    end

                    if not gpe and input.KeyCode == currentKey and callback then
                        task.spawn(callback)
                    end
                end))

                KeybindFrame.MouseEnter:Connect(function()
                    SmoothTween(kbStroke, 0.2, {Transparency = 0.2, Color = Library.Theme.Accent})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                KeybindFrame.MouseLeave:Connect(function()
                    SmoothTween(kbStroke, 0.25, {Transparency = 0.5, Color = Library.Theme.Divider})
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
                Divider.BackgroundColor3 = Library.Theme.Divider
                Divider.BackgroundTransparency = 0.3
                Divider.Size = UDim2.new(1, -8, 0, 1)
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
                ColorFrame.Size = UDim2.new(1, -8, 0, 44)
                ColorFrame.BorderSizePixel = 0

                Instance.new("UICorner", ColorFrame).CornerRadius = UDim.new(0, 8)
                local cpStroke = AddStroke(ColorFrame, Library.Theme.Divider, 1)
                cpStroke.Transparency = 0.5

                local Label = Instance.new("TextLabel", ColorFrame)
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 14, 0, 0)
                Label.Size = UDim2.new(1, -80, 1, 0)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextColor3 = Library.Theme.Text
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left

                local ColorPreview = Instance.new("Frame", ColorFrame)
                ColorPreview.BackgroundColor3 = defaultColor
                ColorPreview.Position = UDim2.new(1, -52, 0.5, -12)
                ColorPreview.Size = UDim2.new(0, 38, 0, 24)
                ColorPreview.BorderSizePixel = 0

                Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 6)
                local previewStroke = AddStroke(ColorPreview, defaultColor, 2)
                previewStroke.Transparency = 0.3

                local currentColor = defaultColor

                local ColorButton = Instance.new("TextButton", ColorPreview)
                ColorButton.BackgroundTransparency = 1
                ColorButton.Size = UDim2.new(1, 0, 1, 0)
                ColorButton.Text = ""

                ColorButton.MouseButton1Click:Connect(function()
                    local presets = {
                        Color3.fromRGB(120, 60, 230),
                        Color3.fromRGB(255, 95, 145),
                        Color3.fromRGB(55, 175, 250),
                        Color3.fromRGB(45, 200, 115),
                        Color3.fromRGB(245, 175, 55),
                        Color3.fromRGB(235, 75, 75)
                    }

                    local nextIndex = 1
                    for i, preset in ipairs(presets) do
                        if currentColor == preset then
                            nextIndex = (i % #presets) + 1
                            break
                        end
                    end

                    currentColor = presets[nextIndex]
                    SmoothTween(ColorPreview, 0.3, {BackgroundColor3 = currentColor})
                    SmoothTween(previewStroke, 0.3, {Color = currentColor})

                    if callback then
                        task.spawn(callback, currentColor)
                    end

                    Library:LogActivity("Color Picker", text)
                end)

                ColorFrame.MouseEnter:Connect(function()
                    SmoothTween(cpStroke, 0.2, {Transparency = 0.2, Color = Library.Theme.Accent})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)

                ColorFrame.MouseLeave:Connect(function()
                    SmoothTween(cpStroke, 0.25, {Transparency = 0.5, Color = Library.Theme.Divider})
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
                        previewStroke.Color = newColor
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
