--[[
    ╔══════════════════════════════════════════════════════════╗
    ║            SwiftUI  ·  Version 1.0.0                    ║
    ║         Modern · Clean · Dark · Minimal                 ║
    ╚══════════════════════════════════════════════════════════╝
]]

local SwiftUI = {}
SwiftUI.__index = SwiftUI

-- ═══════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════

local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer

-- ═══════════════════════════════════════
--  DEFAULT THEME  (overridable)
-- ═══════════════════════════════════════

local THEME = {
    Background   = Color3.fromRGB(10,  10,  12),
    Surface      = Color3.fromRGB(22,  22,  26),
    SurfaceAlt   = Color3.fromRGB(32,  32,  38),
    SurfacePop   = Color3.fromRGB(44,  44,  52),

    -- Gradients: defined as {colorA, colorB, rotation}
    GradPrimary  = { Color3.fromRGB(120, 90, 255), Color3.fromRGB(80, 50, 200), 145 },
    GradPanel    = { Color3.fromRGB(26, 26, 32),   Color3.fromRGB(18, 18, 24),  180 },
    GradAccent   = { Color3.fromRGB(110, 80, 240), Color3.fromRGB(70, 40, 180), 135 },

    Accent       = Color3.fromRGB(120, 90, 255),
    AccentDim    = Color3.fromRGB(80,  50, 200),

    Border       = Color3.fromRGB(55,  55,  68),
    BorderFocus  = Color3.fromRGB(120, 90, 255),

    TextPrimary  = Color3.fromRGB(240, 240, 248),
    TextSecondary= Color3.fromRGB(120, 118, 140),
    TextOnAccent = Color3.fromRGB(255, 255, 255),

    Success      = Color3.fromRGB(52,  211, 153),
    Danger       = Color3.fromRGB(248,  92,  92),
    Warning      = Color3.fromRGB(251, 191,  36),
    Info         = Color3.fromRGB(120,  90, 255),

    White        = Color3.fromRGB(255, 255, 255),
    Black        = Color3.fromRGB(0,   0,   0),
}

-- ═══════════════════════════════════════
--  DEFAULTS  (overridable)
-- ═══════════════════════════════════════

local DEFAULTS = {
    CornerRadius  = 14,
    PillRadius    = 999,
    Padding       = 14,
    BorderWidth   = 1,
    AnimSpeed     = 0.22,
    FontTitle     = Enum.Font.GothamBold,
    FontBody      = Enum.Font.GothamMedium,
    FontLight     = Enum.Font.Gotham,
    FontSize      = 14,
}

-- ═══════════════════════════════════════
--  CUSTOMIZATION API
-- ═══════════════════════════════════════

--[[
    Override any theme values.
    @param overrides  table  – keys matching THEME fields
    Example: SwiftUI.setTheme({ Accent = Color3.fromRGB(255,80,120) })
]]
function SwiftUI.setTheme(overrides)
    for k, v in pairs(overrides) do
        THEME[k] = v
    end
end

--[[
    Override any default values.
    @param overrides  table  – keys matching DEFAULTS fields
    Example: SwiftUI.setDefaults({ CornerRadius = 8, AnimSpeed = 0.15 })
]]
function SwiftUI.setDefaults(overrides)
    for k, v in pairs(overrides) do
        DEFAULTS[k] = v
    end
end

-- ═══════════════════════════════════════
--  INTERNAL HELPERS
-- ═══════════════════════════════════════

-- Tween wrapper
local function tw(instance, props, dur, style, dir)
    local t = TweenService:Create(
        instance,
        TweenInfo.new(
            dur   or DEFAULTS.AnimSpeed,
            style or Enum.EasingStyle.Quint,
            dir   or Enum.EasingDirection.Out
        ),
        props
    )
    t:Play()
    return t
end

-- Frame + UICorner
local function newFrame(parent, name, size, position, color, radius)
    local f = Instance.new("Frame")
    f.Name             = name
    f.Size             = size
    f.Position         = position or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = color or THEME.Surface
    f.BorderSizePixel  = 0
    f.Parent           = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or DEFAULTS.CornerRadius)
    c.Parent = f
    return f
end

-- UIStroke
local function newStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color     or THEME.Border
    s.Thickness = thickness or DEFAULTS.BorderWidth
    s.Parent    = parent
    return s
end

-- TextLabel
local function newLabel(parent, name, text, size, position, color, fontSize, font)
    local l = Instance.new("TextLabel")
    l.Name                   = name
    l.Text                   = text
    l.Size                   = size
    l.Position               = position or UDim2.new(0, 0, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3             = color    or THEME.TextPrimary
    l.TextSize               = fontSize or DEFAULTS.FontSize
    l.Font                   = font     or DEFAULTS.FontBody
    l.TextWrapped            = true
    l.TextXAlignment         = Enum.TextXAlignment.Left
    l.Parent                 = parent
    return l
end

--[[
    KEY FIX: UIGradient requires BackgroundColor3 = white to render its
    own colors correctly. If the frame is dark, the gradient is multiplied
    by that dark color and becomes nearly invisible.
    Solution: set bg = white, gradient provides ALL color information.
]]
local function newGradient(parent, colorA, colorB, rotation)
    -- Force white bg so gradient colors show at full brightness
    parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    g.Rotation = rotation or 135
    g.Parent   = parent
    return g
end

-- Drag logic — attach to any frame
local function makeDraggable(panel, handle)
    handle = handle or panel
    local dragging, dragStart, startPos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════
--  NOTIFICATION MANAGER  (internal)
-- ═══════════════════════════════════════

local _notifySlots = {}   -- active toast frames, bottom-to-top stack

local NOTIFY_W   = 300
local NOTIFY_H   = 62
local NOTIFY_GAP = 10
local NOTIFY_X   = -1 * (NOTIFY_W + 16)   -- off-screen right

local function _rebuildNotifyPositions()
    for i, toast in ipairs(_notifySlots) do
        local targetY = 16 + (i - 1) * (NOTIFY_H + NOTIFY_GAP)
        tw(toast, { Position = UDim2.new(1, -(NOTIFY_W + 16), 0, targetY) }, 0.25)
    end
end

local function _removeNotify(toast)
    tw(toast, { Position = UDim2.new(1, 16, 0, toast.Position.Y.Offset) }, 0.22)
    task.delay(0.25, function()
        for i, t in ipairs(_notifySlots) do
            if t == toast then
                table.remove(_notifySlots, i)
                break
            end
        end
        toast:Destroy()
        _rebuildNotifyPositions()
    end)
end

-- ═══════════════════════════════════════
--  CONSTRUCTOR
-- ═══════════════════════════════════════

function SwiftUI.new()
    local self = setmetatable({}, SwiftUI)

    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name           = "SwiftUI"
    self.screenGui.ResetOnSpawn   = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

    self.panels = {}
    return self
end

-- ═══════════════════════════════════════
--  PANEL  (with drag + title bar)
-- ═══════════════════════════════════════

--[[
    Creates a draggable dark panel.
    The top title bar acts as the drag handle.
    @param name     string
    @param title    string   – header text shown in title bar
    @param size     UDim2    – default 400×500
    @param position UDim2    – default centered
    @returns panel Frame, body Frame (children go inside body)
]]
function SwiftUI:createPanel(name, title, size, position)
    local panelW = size and size.X.Offset or 400
    local panelH = size and size.Y.Offset or 500

    -- Outer shell
    local shell = Instance.new("Frame")
    shell.Name             = name
    shell.Size             = size or UDim2.new(0, 400, 0, 500)
    shell.Position         = position or UDim2.new(0.5, -200, 0.5, -250)
    shell.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shell.BorderSizePixel  = 0
    shell.Parent           = self.screenGui

    local shellCorner = Instance.new("UICorner")
    shellCorner.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
    shellCorner.Parent = shell

    -- Panel gradient (visible because bg = white)
    newGradient(shell,
        Color3.fromRGB(26, 26, 34),
        Color3.fromRGB(16, 16, 22),
        170
    )

    newStroke(shell, THEME.Border, 1)

    -- Title bar (drag handle)
    local titleBar = Instance.new("TextButton")
    titleBar.Name                  = "TitleBar"
    titleBar.Size                  = UDim2.new(1, 0, 0, 44)
    titleBar.Position              = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundTransparency = 1
    titleBar.Text                  = ""
    titleBar.AutoButtonColor       = false
    titleBar.ZIndex                = 5
    titleBar.Parent                = shell

    -- Title text
    local titleLabel = newLabel(
        titleBar, "TitleText", title or name,
        UDim2.new(1, -50, 1, 0),
        UDim2.new(0, DEFAULTS.Padding, 0, 0),
        THEME.TextPrimary, 15, DEFAULTS.FontTitle
    )
    titleLabel.ZIndex = 6
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                  = "CloseBtn"
    closeBtn.Size                  = UDim2.new(0, 28, 0, 28)
    closeBtn.Position              = UDim2.new(1, -38, 0.5, -14)
    closeBtn.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
    closeBtn.BorderSizePixel       = 0
    closeBtn.Text                  = "×"
    closeBtn.TextColor3            = THEME.TextSecondary
    closeBtn.TextSize              = 18
    closeBtn.Font                  = DEFAULTS.FontTitle
    closeBtn.AutoButtonColor       = false
    closeBtn.ZIndex                = 6
    closeBtn.Parent                = titleBar

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 999)
    closeBtnCorner.Parent = closeBtn

    newGradient(closeBtn, Color3.fromRGB(50, 50, 62), Color3.fromRGB(38, 38, 50), 180)

    closeBtn.MouseEnter:Connect(function()
        tw(closeBtn, { BackgroundTransparency = 0 }, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        tw(closeBtn, { BackgroundTransparency = 0 }, 0.1)
        closeBtn.TextColor3 = THEME.TextSecondary
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tw(shell, { BackgroundTransparency = 1 }, 0.18)
        task.delay(0.2, function() shell:Destroy() end)
    end)

    -- Divider below title bar
    local div = newFrame(shell, "TitleDivider",
        UDim2.new(1, 0, 0, 1),
        UDim2.new(0, 0, 0, 44),
        THEME.Border, 0
    )

    -- Body — where all content goes
    local body = newFrame(shell, "Body",
        UDim2.new(1, 0, 1, -45),
        UDim2.new(0, 0, 0, 45),
        Color3.fromRGB(0, 0, 0), 0
    )
    body.BackgroundTransparency = 1

    -- Make draggable via title bar
    makeDraggable(shell, titleBar)

    table.insert(self.panels, { instance = shell, body = body })
    return shell, body
end

-- ═══════════════════════════════════════
--  TYPOGRAPHY
-- ═══════════════════════════════════════

--[[
    Large bold section title.
    @param parent   GuiObject
    @param text     string
    @param fontSize number (default 16)
]]
function SwiftUI:createTitle(parent, text, fontSize)
    local l = newLabel(
        parent, "Title", text,
        UDim2.new(1, -DEFAULTS.Padding * 2, 0, 30),
        UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.TextPrimary, fontSize or 16, DEFAULTS.FontTitle
    )
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

--[[
    Secondary / muted body label.
    @param parent   GuiObject
    @param text     string
    @param size     UDim2
    @param position UDim2
    @param fontSize number
]]
function SwiftUI:createLabel(parent, text, size, position, fontSize)
    return newLabel(
        parent, "Label", text,
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 26),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.TextSecondary, fontSize or DEFAULTS.FontSize, DEFAULTS.FontLight
    )
end

-- ═══════════════════════════════════════
--  BUTTON
-- ═══════════════════════════════════════

--[[
    Styled button with gradient and press animation.
    @param parent   GuiObject
    @param text     string
    @param size     UDim2
    @param position UDim2
    @param style    "primary" | "ghost" | "danger"
    @param callback function()
]]
function SwiftUI:createButton(parent, text, size, position, style, callback)
    style = style or "primary"

    local btn = Instance.new("TextButton")
    btn.Name             = "Button_" .. text
    btn.Text             = text
    btn.Size             = size     or UDim2.new(0, 120, 0, 40)
    btn.Position         = position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- white for gradient
    btn.TextColor3       = THEME.TextOnAccent
    btn.TextSize         = DEFAULTS.FontSize
    btn.Font             = DEFAULTS.FontTitle
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, DEFAULTS.PillRadius)
    corner.Parent = btn

    local stroke
    if style == "primary" then
        -- Visible purple gradient
        newGradient(btn, Color3.fromRGB(120, 90, 255), Color3.fromRGB(75, 45, 195), 145)
        btn.TextColor3 = THEME.TextOnAccent
    elseif style == "ghost" then
        newGradient(btn, Color3.fromRGB(38, 38, 50), Color3.fromRGB(28, 28, 38), 180)
        btn.TextColor3 = THEME.TextSecondary
        stroke = newStroke(btn, THEME.Border, 1)
    elseif style == "danger" then
        newGradient(btn, Color3.fromRGB(220, 60, 60), Color3.fromRGB(180, 40, 40), 145)
        btn.TextColor3 = THEME.TextOnAccent
    end

    -- Hover
    btn.MouseEnter:Connect(function()
        tw(btn, { BackgroundTransparency = 0.08 }, 0.1)
        if stroke then tw(stroke, { Color = THEME.BorderFocus }, 0.1) end
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, { BackgroundTransparency = 0 }, 0.1)
        if stroke then tw(stroke, { Color = THEME.Border }, 0.1) end
    end)

    -- Press
    btn.MouseButton1Down:Connect(function()
        tw(btn, { BackgroundTransparency = 0.2 }, 0.07)
        tw(btn, { Size = UDim2.new(
            btn.Size.X.Scale, btn.Size.X.Offset - 2,
            btn.Size.Y.Scale, btn.Size.Y.Offset - 2
        )}, 0.07)
    end)
    btn.MouseButton1Up:Connect(function()
        tw(btn, { BackgroundTransparency = 0 }, 0.1)
        tw(btn, { Size = size or UDim2.new(0, 120, 0, 40) }, 0.1)
    end)

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

-- ═══════════════════════════════════════
--  PILL TAB BAR
-- ═══════════════════════════════════════

--[[
    Horizontal pill tab bar. Active tab has a gradient pill highlight.
    @param parent   GuiObject
    @param tabs     { string }
    @param size     UDim2
    @param position UDim2
    @param callback function(index, tabName)
    @returns        bar Frame, setActive function(index)
]]
function SwiftUI:createTabBar(parent, tabs, size, position, callback)
    local bar = newFrame(
        parent, "TabBar",
        size     or UDim2.new(0, (#tabs * 100) + 12, 0, 44),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        Color3.fromRGB(255, 255, 255),
        DEFAULTS.PillRadius
    )
    newGradient(bar, Color3.fromRGB(36, 36, 46), Color3.fromRGB(28, 28, 36), 180)
    newStroke(bar, THEME.Border, 1)

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection       = Enum.FillDirection.Horizontal
    rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    rowLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    rowLayout.Padding             = UDim.new(0, 4)
    rowLayout.Parent              = bar

    local innerPad = Instance.new("UIPadding")
    innerPad.PaddingLeft  = UDim.new(0, 5)
    innerPad.PaddingRight = UDim.new(0, 5)
    innerPad.Parent       = bar

    local buttons = {}

    local function setActive(index)
        for i, btn in ipairs(buttons) do
            local isActive = (i == index)
            if isActive then
                btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                btn.BackgroundTransparency = 0
                -- Apply gradient to active tab
                local existing = btn:FindFirstChildOfClass("UIGradient")
                if not existing then
                    newGradient(btn, Color3.fromRGB(120, 90, 255), Color3.fromRGB(75, 45, 195), 145)
                end
                tw(btn, { TextColor3 = THEME.TextOnAccent }, 0.15)
            else
                btn.BackgroundTransparency = 1
                local g = btn:FindFirstChildOfClass("UIGradient")
                if g then g:Destroy() end
                tw(btn, { TextColor3 = THEME.TextSecondary }, 0.15)
            end
        end
    end

    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name                   = "Tab_" .. tabName
        btn.Text                   = tabName
        btn.Size                   = UDim2.new(0, 96, 0, 34)
        btn.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = i == 1 and 0 or 1
        btn.TextColor3             = i == 1 and THEME.TextOnAccent or THEME.TextSecondary
        btn.TextSize               = DEFAULTS.FontSize
        btn.Font                   = DEFAULTS.FontTitle
        btn.BorderSizePixel        = 0
        btn.AutoButtonColor        = false
        btn.Parent                 = bar

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, DEFAULTS.PillRadius)
        c.Parent = btn

        if i == 1 then
            newGradient(btn, Color3.fromRGB(120, 90, 255), Color3.fromRGB(75, 45, 195), 145)
        end

        btn.MouseButton1Click:Connect(function()
            setActive(i)
            if callback then callback(i, tabName) end
        end)

        table.insert(buttons, btn)
    end

    return bar, setActive
end

-- ═══════════════════════════════════════
--  INPUT BOX
-- ═══════════════════════════════════════

--[[
    Dark text input with focus glow animation.
    @param parent      GuiObject
    @param placeholder string
    @param size        UDim2
    @param position    UDim2
    @returns           frame Frame, input TextBox
]]
function SwiftUI:createInputBox(parent, placeholder, size, position)
    local frame = newFrame(
        parent, "InputBox",
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 42),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        Color3.fromRGB(255, 255, 255)
    )
    newGradient(frame, Color3.fromRGB(36, 36, 48), Color3.fromRGB(28, 28, 38), 180)
    local stroke = newStroke(frame, THEME.Border, 1)

    local input = Instance.new("TextBox")
    input.Name                   = "TextInput"
    input.Size                   = UDim2.new(1, -DEFAULTS.Padding, 1, 0)
    input.Position               = UDim2.new(0, DEFAULTS.Padding / 2, 0, 0)
    input.BackgroundTransparency = 1
    input.TextColor3             = THEME.TextPrimary
    input.PlaceholderColor3      = THEME.TextSecondary
    input.PlaceholderText        = placeholder or "Type here…"
    input.TextSize               = DEFAULTS.FontSize
    input.Font                   = DEFAULTS.FontBody
    input.ClearTextOnFocus       = false
    input.Parent                 = frame

    input.Focused:Connect(function()
        tw(stroke, { Color = THEME.BorderFocus, Thickness = 1.5 }, 0.15)
    end)
    input.FocusLost:Connect(function()
        tw(stroke, { Color = THEME.Border, Thickness = 1 }, 0.15)
    end)

    return frame, input
end

-- ═══════════════════════════════════════
--  TOGGLE
-- ═══════════════════════════════════════

--[[
    Animated toggle switch with gradient track when ON.
    @param parent       GuiObject
    @param label        string
    @param defaultValue boolean
    @param callback     function(isOn: boolean)
    @param size         UDim2
    @param position     UDim2
    @returns            row Frame, track TextButton, thumb Frame
]]
function SwiftUI:createToggle(parent, label, defaultValue, callback, size, position)
    local row = newFrame(
        parent, "Toggle",
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 44),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        Color3.fromRGB(255, 255, 255)
    )
    newGradient(row, Color3.fromRGB(34, 34, 44), Color3.fromRGB(26, 26, 34), 180)

    newLabel(
        row, "Label", label,
        UDim2.new(0.72, 0, 1, 0),
        UDim2.new(0, DEFAULTS.Padding, 0, 0),
        THEME.TextPrimary
    )

    -- Track
    local track = Instance.new("TextButton")
    track.Name             = "Track"
    track.Size             = UDim2.new(0, 48, 0, 26)
    track.Position         = UDim2.new(1, -60, 0.5, -13)
    track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    track.BorderSizePixel  = 0
    track.Text             = ""
    track.AutoButtonColor  = false
    track.Parent           = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 999)
    trackCorner.Parent = track

    local trackGrad
    if defaultValue then
        trackGrad = newGradient(track, Color3.fromRGB(120, 90, 255), Color3.fromRGB(75, 45, 195), 135)
    else
        newGradient(track, Color3.fromRGB(60, 60, 75), Color3.fromRGB(45, 45, 60), 180)
    end

    -- Thumb
    local thumb = Instance.new("Frame")
    thumb.Name             = "Thumb"
    thumb.Size             = UDim2.new(0, 20, 0, 20)
    thumb.Position         = defaultValue and UDim2.new(0, 25, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    thumb.BackgroundColor3 = THEME.White
    thumb.BorderSizePixel  = 0
    thumb.Parent           = track

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 999)
    thumbCorner.Parent = thumb

    local isOn = defaultValue or false

    track.MouseButton1Click:Connect(function()
        isOn = not isOn

        -- Update track gradient
        local g = track:FindFirstChildOfClass("UIGradient")
        if g then g:Destroy() end

        if isOn then
            newGradient(track, Color3.fromRGB(120, 90, 255), Color3.fromRGB(75, 45, 195), 135)
        else
            newGradient(track, Color3.fromRGB(60, 60, 75), Color3.fromRGB(45, 45, 60), 180)
        end

        tw(thumb, {
            Position = isOn
                and UDim2.new(0, 25, 0.5, -10)
                or  UDim2.new(0, 3,  0.5, -10)
        }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        if callback then callback(isOn) end
    end)

    return row, track, thumb
end

-- ═══════════════════════════════════════
--  DROPDOWN
-- ═══════════════════════════════════════

--[[
    Dropdown with animated chevron and hover highlights.
    @param parent       GuiObject
    @param options      { string }
    @param defaultIndex number (default 1)
    @param callback     function(index, value)
    @param size         UDim2
    @param position     UDim2
    @returns            wrapper, list, selectedLabel
]]
function SwiftUI:createDropdown(parent, options, defaultIndex, callback, size, position)
    local wrapper = newFrame(
        parent, "Dropdown",
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 42),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        Color3.fromRGB(255, 255, 255)
    )
    newGradient(wrapper, Color3.fromRGB(36, 36, 48), Color3.fromRGB(28, 28, 38), 180)
    local stroke = newStroke(wrapper, THEME.Border, 1)

    local selectedLabel = newLabel(
        wrapper, "SelectedLabel",
        options[defaultIndex or 1],
        UDim2.new(0.8, 0, 1, 0),
        UDim2.new(0, DEFAULTS.Padding, 0, 0),
        THEME.TextPrimary
    )

    local chevron = Instance.new("TextButton")
    chevron.Name                   = "Chevron"
    chevron.Size                   = UDim2.new(0, 32, 1, 0)
    chevron.Position               = UDim2.new(1, -36, 0, 0)
    chevron.BackgroundTransparency = 1
    chevron.Text                   = "›"
    chevron.TextColor3             = THEME.TextSecondary
    chevron.TextSize               = 22
    chevron.Font                   = DEFAULTS.FontTitle
    chevron.Rotation               = 90
    chevron.Parent                 = wrapper

    local list = Instance.new("Frame")
    list.Name             = "DropdownList"
    list.Size             = UDim2.new(1, 0, 0, #options * 38)
    list.Position         = UDim2.new(0, 0, 1, 6)
    list.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    list.BorderSizePixel  = 0
    list.ZIndex           = 10
    list.ClipsDescendants = true
    list.Visible          = false
    list.Parent           = wrapper

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
    listCorner.Parent = list

    newGradient(list, Color3.fromRGB(34, 34, 46), Color3.fromRGB(24, 24, 34), 180)
    newStroke(list, THEME.Border, 1)

    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Name                   = "Option_" .. i
        optBtn.Size                   = UDim2.new(1, 0, 0, 38)
        optBtn.Position               = UDim2.new(0, 0, 0, (i - 1) * 38)
        optBtn.BackgroundTransparency = 1
        optBtn.BorderSizePixel        = 0
        optBtn.Text                   = option
        optBtn.TextColor3             = THEME.TextPrimary
        optBtn.TextSize               = DEFAULTS.FontSize
        optBtn.Font                   = DEFAULTS.FontBody
        optBtn.AutoButtonColor        = false
        optBtn.ZIndex                 = 11
        optBtn.Parent                 = list

        optBtn.MouseEnter:Connect(function()
            tw(optBtn, { BackgroundTransparency = 0.85 }, 0.1)
            optBtn.BackgroundColor3 = THEME.Accent
        end)
        optBtn.MouseLeave:Connect(function()
            tw(optBtn, { BackgroundTransparency = 1 }, 0.1)
        end)
        optBtn.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            list.Visible = false
            tw(stroke,  { Color = THEME.Border }, 0.15)
            tw(chevron, { Rotation = 90 }, 0.18)
            if callback then callback(i, option) end
        end)
    end

    local isOpen = false
    local function toggle()
        isOpen = not isOpen
        list.Visible = isOpen
        tw(stroke,  { Color = isOpen and THEME.BorderFocus or THEME.Border }, 0.15)
        tw(chevron, { Rotation = isOpen and 270 or 90 }, 0.18)
    end

    chevron.MouseButton1Click:Connect(toggle)
    wrapper.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)

    return wrapper, list, selectedLabel
end

-- ═══════════════════════════════════════
--  DIVIDER
-- ═══════════════════════════════════════

--[[
    1px horizontal separator.
    @param parent   GuiObject
    @param position UDim2
]]
function SwiftUI:createDivider(parent, position)
    return newFrame(
        parent, "Divider",
        UDim2.new(1, -DEFAULTS.Padding * 2, 0, 1),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.Border, 0
    )
end

-- ═══════════════════════════════════════
--  NOTIFICATION  (toast stack)
-- ═══════════════════════════════════════

--[[
    Shows a toast notification that stacks from the top-right.
    Multiple toasts stack downward and shift when one closes.
    @param message  string
    @param kind     "success" | "danger" | "warning" | "info"
    @param duration number (seconds, default 3.5)
]]
function SwiftUI:notify(message, kind, duration)
    local kindColor = ({
        success = THEME.Success,
        danger  = THEME.Danger,
        warning = THEME.Warning,
        info    = THEME.Accent,
    })[kind or "info"] or THEME.Accent

    local kindIcon = ({
        success = "✓",
        danger  = "✕",
        warning = "⚠",
        info    = "ℹ",
    })[kind or "info"] or "ℹ"

    -- Calculate slot position
    local slotIndex = #_notifySlots + 1
    local yPos = 16 + (slotIndex - 1) * (NOTIFY_H + NOTIFY_GAP)

    -- Toast frame (starts off-screen right)
    local toast = Instance.new("Frame")
    toast.Name             = "Toast_" .. tostring(tick())
    toast.Size             = UDim2.new(0, NOTIFY_W, 0, NOTIFY_H)
    toast.Position         = UDim2.new(1, 16, 0, yPos)   -- off-screen
    toast.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toast.BorderSizePixel  = 0
    toast.ZIndex           = 100
    toast.Parent           = self.screenGui

    local toastCorner = Instance.new("UICorner")
    toastCorner.CornerRadius = UDim.new(0, 12)
    toastCorner.Parent = toast

    -- Toast gradient background
    newGradient(toast, Color3.fromRGB(32, 32, 42), Color3.fromRGB(22, 22, 30), 180)
    newStroke(toast, THEME.Border, 1)

    -- Colored left accent strip
    local strip = newFrame(toast, "Strip", UDim2.new(0, 3, 1, -16), UDim2.new(0, 8, 0, 8), kindColor, 999)
    strip.ZIndex = 101

    -- Icon
    local icon = newLabel(
        toast, "Icon", kindIcon,
        UDim2.new(0, 24, 1, 0),
        UDim2.new(0, 20, 0, 0),
        kindColor, 16, DEFAULTS.FontTitle
    )
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.ZIndex = 101

    -- Message
    local msg = newLabel(
        toast, "Msg", message,
        UDim2.new(1, -56, 1, 0),
        UDim2.new(0, 48, 0, 0),
        THEME.TextPrimary, 13, DEFAULTS.FontBody
    )
    msg.ZIndex = 101

    -- Progress bar (shrinks over duration)
    local progBg = newFrame(toast, "ProgBg",
        UDim2.new(1, -16, 0, 2),
        UDim2.new(0, 8, 1, -8),
        Color3.fromRGB(255, 255, 255), 999
    )
    progBg.BackgroundTransparency = 0.85
    progBg.ZIndex = 101

    local prog = newFrame(progBg, "Prog",
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        kindColor, 999
    )
    prog.ZIndex = 102

    -- Close button on toast
    local closeX = Instance.new("TextButton")
    closeX.Name                   = "CloseX"
    closeX.Size                   = UDim2.new(0, 20, 0, 20)
    closeX.Position               = UDim2.new(1, -26, 0, 6)
    closeX.BackgroundTransparency = 1
    closeX.Text                   = "×"
    closeX.TextColor3             = THEME.TextSecondary
    closeX.TextSize               = 16
    closeX.Font                   = DEFAULTS.FontTitle
    closeX.ZIndex                 = 102
    closeX.Parent                 = toast

    table.insert(_notifySlots, toast)

    -- Slide in from right
    tw(toast, { Position = UDim2.new(1, -(NOTIFY_W + 16), 0, yPos) }, 0.3,
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Progress bar shrink
    local dur = duration or 3.5
    tw(prog, { Size = UDim2.new(0, 0, 1, 0) }, dur, Enum.EasingStyle.Linear)

    -- Auto dismiss
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        _removeNotify(toast)
    end

    closeX.MouseButton1Click:Connect(dismiss)
    task.delay(dur, dismiss)

    return toast
end

-- ═══════════════════════════════════════
--  ANIMATION HELPERS
-- ═══════════════════════════════════════

--[[
    Tween any property on an instance.
    @param instance  GuiObject
    @param props     table
    @param duration  number
    @param style     Enum.EasingStyle
    @param direction Enum.EasingDirection
]]
function SwiftUI:animate(instance, props, duration, style, direction)
    return tw(instance, props, duration, style, direction)
end

--[[
    Fade in: BackgroundTransparency 1 → 0.
]]
function SwiftUI:fadeIn(instance, duration)
    instance.BackgroundTransparency = 1
    return tw(instance, { BackgroundTransparency = 0 }, duration)
end

--[[
    Fade out: BackgroundTransparency 0 → 1.
]]
function SwiftUI:fadeOut(instance, duration)
    return tw(instance, { BackgroundTransparency = 1 }, duration)
end

-- ═══════════════════════════════════════
--  DESTROY
-- ═══════════════════════════════════════

--[[
    Destroys the ScreenGui and clears notification slots.
]]
function SwiftUI:destroy()
    _notifySlots = {}
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

-- ═══════════════════════════════════════

return SwiftUI
