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

local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer

-- ═══════════════════════════════════════
--  THEME
-- ═══════════════════════════════════════

local THEME = {
    -- Surfaces (dark layers)
    Background  = Color3.fromRGB(10,  10,  12),   -- deepest bg
    Surface     = Color3.fromRGB(22,  22,  26),   -- panel bg
    SurfaceAlt  = Color3.fromRGB(32,  32,  38),   -- input / row bg
    SurfacePop  = Color3.fromRGB(44,  44,  52),   -- hover / active

    -- Accent (subtle purple-blue, like modern UI)
    Accent      = Color3.fromRGB(130, 100, 255),  -- primary accent
    AccentDim   = Color3.fromRGB(90,  65,  190),  -- darker accent

    -- Borders
    Border      = Color3.fromRGB(50,  50,  60),   -- subtle border
    BorderFocus = Color3.fromRGB(130, 100, 255),  -- focused border

    -- Typography
    TextPrimary   = Color3.fromRGB(240, 240, 248), -- near-white
    TextSecondary = Color3.fromRGB(120, 118, 140), -- muted
    TextOnAccent  = Color3.fromRGB(255, 255, 255), -- white on accent

    -- States
    Success = Color3.fromRGB(52,  211, 153),
    Danger  = Color3.fromRGB(248,  92,  92),
    Warning = Color3.fromRGB(251, 191,  36),

    -- Base
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0,   0,   0),
}

-- ═══════════════════════════════════════
--  DEFAULTS
-- ═══════════════════════════════════════

local DEFAULTS = {
    CornerRadius   = 14,
    PillRadius     = 999,
    Padding        = 14,
    BorderWidth    = 1,
    AnimSpeed      = 0.22,
    FontTitle      = Enum.Font.GothamBold,
    FontBody       = Enum.Font.GothamMedium,
    FontLight      = Enum.Font.Gotham,
    FontSize       = 14,
}

-- ═══════════════════════════════════════
--  INTERNAL HELPERS
-- ═══════════════════════════════════════

-- Smooth tween wrapper
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

-- Create a frame with UICorner
local function newFrame(parent, name, size, position, color, radius)
    local f = Instance.new("Frame")
    f.Name             = name
    f.Size             = size
    f.Position         = position
    f.BackgroundColor3 = color  or THEME.Surface
    f.BorderSizePixel  = 0
    f.Parent           = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or DEFAULTS.CornerRadius)
    c.Parent = f

    return f
end

-- Create a UIStroke
local function newStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color     or THEME.Border
    s.Thickness = thickness or DEFAULTS.BorderWidth
    s.Parent    = parent
    return s
end

-- Create a TextLabel
local function newLabel(parent, name, text, size, position, color, fontSize, font)
    local l = Instance.new("TextLabel")
    l.Name                   = name
    l.Text                   = text
    l.Size                   = size
    l.Position               = position
    l.BackgroundTransparency = 1
    l.TextColor3             = color    or THEME.TextPrimary
    l.TextSize               = fontSize or DEFAULTS.FontSize
    l.Font                   = font     or DEFAULTS.FontBody
    l.TextWrapped            = true
    l.TextXAlignment         = Enum.TextXAlignment.Left
    l.Parent                 = parent
    return l
end

-- Apply UIGradient
local function newGradient(parent, colorA, colorB, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    g.Rotation = rotation or 135
    g.Parent   = parent
    return g
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
--  PANEL
-- ═══════════════════════════════════════

--[[
    Creates a floating dark panel.
    @param name     string   – Instance name
    @param size     UDim2    – default 400×500
    @param position UDim2    – default centered
]]
function SwiftUI:createPanel(name, size, position)
    local panel = newFrame(
        self.screenGui,
        name,
        size     or UDim2.new(0, 400, 0, 500),
        position or UDim2.new(0.5, -200, 0.5, -250),
        THEME.Surface
    )

    newStroke(panel, THEME.Border, 1)

    table.insert(self.panels, { instance = panel, children = {} })
    return panel
end

-- ═══════════════════════════════════════
--  TYPOGRAPHY
-- ═══════════════════════════════════════

--[[
    Large bold title.
    @param parent   GuiObject
    @param text     string
    @param fontSize number (default 20)
]]
function SwiftUI:createTitle(parent, text, fontSize)
    local l = newLabel(
        parent, "Title", text,
        UDim2.new(1, -DEFAULTS.Padding * 2, 0, 32),
        UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.TextPrimary, fontSize or 20, DEFAULTS.FontTitle
    )
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

--[[
    Secondary / body text label.
    @param parent   GuiObject
    @param text     string
    @param size     UDim2
    @param position UDim2
    @param fontSize number
]]
function SwiftUI:createLabel(parent, text, size, position, fontSize)
    return newLabel(
        parent, "Label", text,
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 28),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.TextSecondary, fontSize or DEFAULTS.FontSize, DEFAULTS.FontLight
    )
end

-- ═══════════════════════════════════════
--  BUTTON
-- ═══════════════════════════════════════

--[[
    Modern pill / rounded button.
    @param parent   GuiObject
    @param text     string
    @param size     UDim2
    @param position UDim2
    @param style    "primary" | "ghost" | "danger"
    @param callback function
]]
function SwiftUI:createButton(parent, text, size, position, style, callback)
    style = style or "primary"

    local bgColor = ({
        primary = THEME.SurfacePop,
        ghost   = THEME.SurfaceAlt,
        danger  = THEME.Danger,
    })[style] or THEME.SurfacePop

    local textColor = ({
        primary = THEME.TextPrimary,
        ghost   = THEME.TextSecondary,
        danger  = THEME.TextOnAccent,
    })[style] or THEME.TextPrimary

    local btn = Instance.new("TextButton")
    btn.Name             = "Button_" .. text
    btn.Text             = text
    btn.Size             = size     or UDim2.new(0, 120, 0, 38)
    btn.Position         = position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding)
    btn.BackgroundColor3 = bgColor
    btn.TextColor3       = textColor
    btn.TextSize         = DEFAULTS.FontSize
    btn.Font             = DEFAULTS.FontTitle
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.Parent           = parent

    -- Pill corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, DEFAULTS.PillRadius)
    corner.Parent = btn

    -- Ghost gets a border
    local stroke
    if style == "ghost" then
        stroke = newStroke(btn, THEME.Border, 1)
    end

    -- Primary gets a subtle accent gradient
    if style == "primary" then
        newGradient(btn,
            Color3.fromRGB(52, 52, 62),
            Color3.fromRGB(38, 38, 48),
            180
        )
    end

    -- Hover
    btn.MouseEnter:Connect(function()
        tw(btn, { BackgroundColor3 = THEME.SurfacePop }, 0.12)
        if stroke then
            tw(stroke, { Color = THEME.BorderFocus }, 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, { BackgroundColor3 = bgColor }, 0.12)
        if stroke then
            tw(stroke, { Color = THEME.Border }, 0.12)
        end
    end)

    -- Press
    btn.MouseButton1Down:Connect(function()
        tw(btn, { BackgroundTransparency = 0.2 }, 0.08)
    end)
    btn.MouseButton1Up:Connect(function()
        tw(btn, { BackgroundTransparency = 0 }, 0.08)
    end)

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

-- ═══════════════════════════════════════
--  PILL TAB BAR  (inspired by image)
-- ═══════════════════════════════════════

--[[
    Horizontal tab bar where the active tab has a pill highlight.
    @param parent   GuiObject
    @param tabs     { "Home", "Products", … }
    @param size     UDim2
    @param position UDim2
    @param callback function(index, tabName)
    @returns        container Frame, function setActive(index)
]]
function SwiftUI:createTabBar(parent, tabs, size, position, callback)
    local P = DEFAULTS.Padding

    local bar = newFrame(
        parent, "TabBar",
        size     or UDim2.new(0, (#tabs * 100) + P * 2, 0, 44),
        position or UDim2.new(0, P, 0, P),
        THEME.SurfaceAlt,
        DEFAULTS.PillRadius
    )

    newStroke(bar, THEME.Border, 1)

    local layout = Instance.new("UIListLayout")
    layout.FillDirection       = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment   = Enum.VerticalAlignment.Center
    layout.Padding             = UDim.new(0, 4)
    layout.Parent              = bar

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft   = UDim.new(0, 6)
    padding.PaddingRight  = UDim.new(0, 6)
    padding.Parent        = bar

    local buttons = {}
    local active  = 1

    local function setActive(index)
        active = index
        for i, btn in ipairs(buttons) do
            local isActive = (i == index)
            tw(btn, {
                BackgroundColor3     = isActive and THEME.SurfacePop or THEME.SurfaceAlt,
                BackgroundTransparency = isActive and 0 or 1,
            }, 0.18)
            btn.TextColor3 = isActive and THEME.TextPrimary or THEME.TextSecondary
        end
    end

    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name                    = "Tab_" .. tabName
        btn.Text                    = tabName
        btn.Size                    = UDim2.new(0, 96, 0, 34)
        btn.BackgroundColor3        = i == 1 and THEME.SurfacePop or THEME.SurfaceAlt
        btn.BackgroundTransparency  = i == 1 and 0 or 1
        btn.TextColor3              = i == 1 and THEME.TextPrimary or THEME.TextSecondary
        btn.TextSize                = DEFAULTS.FontSize
        btn.Font                    = DEFAULTS.FontTitle
        btn.BorderSizePixel         = 0
        btn.AutoButtonColor         = false
        btn.Parent                  = bar

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, DEFAULTS.PillRadius)
        c.Parent = btn

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
    Dark styled text input with animated focus border.
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
        THEME.SurfaceAlt
    )

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
    Animated on/off toggle.
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
        THEME.SurfaceAlt
    )

    newLabel(
        row, "Label", label,
        UDim2.new(0.72, 0, 1, 0),
        UDim2.new(0, DEFAULTS.Padding, 0, 0),
        THEME.TextPrimary
    )

    local track = Instance.new("TextButton")
    track.Name             = "Track"
    track.Size             = UDim2.new(0, 48, 0, 26)
    track.Position         = UDim2.new(1, -60, 0.5, -13)
    track.BackgroundColor3 = defaultValue and THEME.Accent or THEME.Border
    track.BorderSizePixel  = 0
    track.Text             = ""
    track.AutoButtonColor  = false
    track.Parent           = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 999)
    trackCorner.Parent = track

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
        tw(track, { BackgroundColor3 = isOn and THEME.Accent or THEME.Border }, 0.2)
        tw(thumb, { Position = isOn and UDim2.new(0, 25, 0.5, -10) or UDim2.new(0, 3, 0.5, -10) }, 0.2)
        if callback then callback(isOn) end
    end)

    return row, track, thumb
end

-- ═══════════════════════════════════════
--  DROPDOWN
-- ═══════════════════════════════════════

--[[
    Styled dropdown with animated chevron.
    @param parent       GuiObject
    @param options      { string }
    @param defaultIndex number (default 1)
    @param callback     function(index: number, value: string)
    @param size         UDim2
    @param position     UDim2
    @returns            wrapper Frame, list Frame, selectedLabel TextLabel
]]
function SwiftUI:createDropdown(parent, options, defaultIndex, callback, size, position)
    local wrapper = newFrame(
        parent, "Dropdown",
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 42),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.SurfaceAlt
    )
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
    chevron.TextSize               = 20
    chevron.Font                   = DEFAULTS.FontTitle
    chevron.Rotation               = 90
    chevron.Parent                 = wrapper

    local list = Instance.new("Frame")
    list.Name             = "DropdownList"
    list.Size             = UDim2.new(1, 0, 0, #options * 38)
    list.Position         = UDim2.new(0, 0, 1, 6)
    list.BackgroundColor3 = THEME.SurfaceAlt
    list.BorderSizePixel  = 0
    list.ZIndex           = 10
    list.ClipsDescendants = true
    list.Visible          = false
    list.Parent           = wrapper

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
    listCorner.Parent = list

    newStroke(list, THEME.Border, 1)

    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Name             = "Option_" .. i
        optBtn.Size             = UDim2.new(1, 0, 0, 38)
        optBtn.Position         = UDim2.new(0, 0, 0, (i - 1) * 38)
        optBtn.BackgroundColor3 = THEME.SurfaceAlt
        optBtn.BorderSizePixel  = 0
        optBtn.Text             = option
        optBtn.TextColor3       = THEME.TextPrimary
        optBtn.TextSize         = DEFAULTS.FontSize
        optBtn.Font             = DEFAULTS.FontBody
        optBtn.AutoButtonColor  = false
        optBtn.ZIndex           = 11
        optBtn.Parent           = list

        optBtn.MouseEnter:Connect(function()
            tw(optBtn, { BackgroundColor3 = THEME.SurfacePop }, 0.1)
        end)
        optBtn.MouseLeave:Connect(function()
            tw(optBtn, { BackgroundColor3 = THEME.SurfaceAlt }, 0.1)
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
    local function toggleList()
        isOpen = not isOpen
        list.Visible = isOpen
        tw(stroke,  { Color = isOpen and THEME.BorderFocus or THEME.Border }, 0.15)
        tw(chevron, { Rotation = isOpen and 270 or 90 }, 0.18)
    end

    chevron.MouseButton1Click:Connect(toggleList)

    return wrapper, list, selectedLabel
end

-- ═══════════════════════════════════════
--  DIVIDER
-- ═══════════════════════════════════════

--[[
    Subtle 1px horizontal separator line.
    @param parent   GuiObject
    @param position UDim2
]]
function SwiftUI:createDivider(parent, position)
    local line = newFrame(
        parent, "Divider",
        UDim2.new(1, -DEFAULTS.Padding * 2, 0, 1),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.Border,
        0
    )
    return line
end

-- ═══════════════════════════════════════
--  NOTIFICATION  (toast)
-- ═══════════════════════════════════════

--[[
    Slide-in toast notification.
    @param message  string
    @param kind     "success" | "danger" | "warning" | "info"
    @param duration number  seconds (default 3)
]]
function SwiftUI:notify(message, kind, duration)
    local accentColor = ({
        success = THEME.Success,
        danger  = THEME.Danger,
        warning = THEME.Warning,
        info    = THEME.Accent,
    })[kind or "info"] or THEME.Accent

    local toast = newFrame(
        self.screenGui,
        "Toast_" .. tostring(tick()),
        UDim2.new(0, 290, 0, 56),
        UDim2.new(1, 20, 0, 20),
        THEME.Surface
    )
    toast.ZIndex = 100
    newStroke(toast, THEME.Border, 1)

    -- Colored accent bar
    local bar = newFrame(toast, "Bar", UDim2.new(0, 3, 1, -16), UDim2.new(0, 8, 0, 8), accentColor, 999)
    bar.ZIndex = 101

    local msg = newLabel(
        toast, "Msg", message,
        UDim2.new(1, -28, 1, 0),
        UDim2.new(0, 20, 0, 0),
        THEME.TextPrimary, 13, DEFAULTS.FontBody
    )
    msg.ZIndex = 101

    -- Slide in
    tw(toast, { Position = UDim2.new(1, -306, 0, 20) }, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration or 3, function()
        tw(toast, { Position = UDim2.new(1, 20, 0, 20) }, 0.22)
        task.wait(0.28)
        toast:Destroy()
    end)

    return toast
end

-- ═══════════════════════════════════════
--  ANIMATION HELPERS
-- ═══════════════════════════════════════

--[[
    Animate any property on a GuiObject.
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
    Fade in (BackgroundTransparency 1 → 0).
]]
function SwiftUI:fadeIn(instance, duration)
    instance.BackgroundTransparency = 1
    return tw(instance, { BackgroundTransparency = 0 }, duration)
end

--[[
    Fade out (BackgroundTransparency 0 → 1).
]]
function SwiftUI:fadeOut(instance, duration)
    return tw(instance, { BackgroundTransparency = 1 }, duration)
end

-- ═══════════════════════════════════════
--  DESTROY
-- ═══════════════════════════════════════

--[[
    Cleans up the ScreenGui and all children.
]]
function SwiftUI:destroy()
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

-- ═══════════════════════════════════════

return SwiftUI
