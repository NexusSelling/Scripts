--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                  SwiftUI  ·  Version 2.0                    ║
    ║           Clean · Gradient · White & Pink Theme             ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local SwiftUI = {}
SwiftUI.__index = SwiftUI

-- ══════════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════════

local TweenService  = game:GetService("TweenService")
local Players       = game:GetService("Players")
local LocalPlayer   = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════
--  THEME  ·  White & Pink
-- ══════════════════════════════════════════════════════════════════

local THEME = {
    -- Gradient stops (White → Soft Pink)
    GradientStart    = Color3.fromRGB(255, 255, 255),   -- Pure white
    GradientEnd      = Color3.fromRGB(255, 182, 213),   -- Soft pink

    -- Accent gradient (Pink → Hot pink)
    AccentStart      = Color3.fromRGB(255, 133, 177),   -- Light pink
    AccentEnd        = Color3.fromRGB(236, 64, 122),    -- Hot pink

    -- UI surfaces
    Background       = Color3.fromRGB(252, 245, 250),   -- Off-white with pink tint
    Surface          = Color3.fromRGB(255, 255, 255),   -- Pure white
    SurfaceAlt       = Color3.fromRGB(255, 242, 249),   -- Very light pink

    -- Borders & strokes
    Border           = Color3.fromRGB(255, 200, 230),   -- Soft pink border
    BorderFocus      = Color3.fromRGB(236, 64, 122),    -- Hot pink focus

    -- Text
    TextPrimary      = Color3.fromRGB(40,  20,  35),    -- Near-black with purple tint
    TextSecondary    = Color3.fromRGB(140, 100, 130),   -- Muted pink-grey
    TextOnAccent     = Color3.fromRGB(255, 255, 255),   -- White on colored bg

    -- States
    Success          = Color3.fromRGB(72,  199, 142),
    Danger           = Color3.fromRGB(241,  70,  104),
    Warning          = Color3.fromRGB(255, 179,  71),

    -- Misc
    White            = Color3.fromRGB(255, 255, 255),
    Black            = Color3.fromRGB(0,   0,   0),
    Transparent      = Color3.fromRGB(0,   0,   0),
}

-- ══════════════════════════════════════════════════════════════════
--  DEFAULTS
-- ══════════════════════════════════════════════════════════════════

local DEFAULTS = {
    CornerRadius    = 12,
    Padding         = 14,
    BorderWidth     = 1.5,
    AnimationSpeed  = 0.25,
    FontSize        = 14,
    FontTitle       = Enum.Font.GothamBold,
    FontBody        = Enum.Font.GothamMedium,
    FontLight       = Enum.Font.Gotham,
}

-- ══════════════════════════════════════════════════════════════════
--  INTERNAL HELPERS
-- ══════════════════════════════════════════════════════════════════

-- Apply a UIGradient to any GuiObject
local function applyGradient(instance, colorA, colorB, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    g.Rotation = rotation or 135
    g.Parent   = instance
    return g
end

-- Create a rounded frame (no gradient by default)
local function newFrame(parent, name, size, position, bgColor)
    local f = Instance.new("Frame")
    f.Name                  = name
    f.Size                  = size
    f.Position              = position
    f.BackgroundColor3      = bgColor or THEME.Surface
    f.BorderSizePixel       = 0
    f.Parent                = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
    c.Parent = f

    return f
end

-- Create a UIStroke border
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
    l.Name                  = name
    l.Text                  = text
    l.Size                  = size
    l.Position              = position
    l.BackgroundTransparency = 1
    l.TextColor3            = color    or THEME.TextPrimary
    l.TextSize              = fontSize or DEFAULTS.FontSize
    l.Font                  = font     or DEFAULTS.FontBody
    l.TextWrapped           = true
    l.TextXAlignment        = Enum.TextXAlignment.Left
    l.Parent                = parent
    return l
end

-- Tween helper
local function tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration   or DEFAULTS.AnimationSpeed,
        style      or Enum.EasingStyle.Quint,
        direction  or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(instance, info, properties)
    t:Play()
    return t
end

-- ══════════════════════════════════════════════════════════════════
--  CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════════

function SwiftUI.new()
    local self = setmetatable({}, SwiftUI)

    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name            = "SwiftUI_ScreenGui"
    self.screenGui.ResetOnSpawn    = false
    self.screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent          = LocalPlayer:WaitForChild("PlayerGui")

    self.panels = {}
    return self
end

-- ══════════════════════════════════════════════════════════════════
--  PANEL
-- ══════════════════════════════════════════════════════════════════

--[[
    Creates a floating panel with a white-to-pink gradient background.
    Parameters:
        name     – Instance name
        size     – UDim2 (default 420×540)
        position – UDim2 (default centered)
]]
function SwiftUI:createPanel(name, size, position)
    local panel = newFrame(
        self.screenGui,
        name,
        size     or UDim2.new(0, 420, 0, 540),
        position or UDim2.new(0.5, -210, 0.5, -270),
        THEME.Surface
    )
    -- Subtle white→pink gradient
    applyGradient(panel, THEME.GradientStart, Color3.fromRGB(255, 235, 246), 160)

    -- Soft pink border stroke
    newStroke(panel, THEME.Border, 1.5)

    -- Drop shadow simulation via inner frame
    local shadow = Instance.new("ImageLabel")
    shadow.Name                 = "Shadow"
    shadow.Size                 = UDim2.new(1, 30, 1, 30)
    shadow.Position             = UDim2.new(0, -15, 0, 10)
    shadow.BackgroundTransparency = 1
    shadow.Image                = "rbxassetid://6014261993"
    shadow.ImageColor3          = Color3.fromRGB(220, 150, 200)
    shadow.ImageTransparency    = 0.65
    shadow.ScaleType            = Enum.ScaleType.Slice
    shadow.SliceCenter          = Rect.new(49, 49, 450, 450)
    shadow.ZIndex               = panel.ZIndex - 1
    shadow.Parent               = panel

    local panelData = { instance = panel, children = {} }
    table.insert(self.panels, panelData)
    return panel
end

-- ══════════════════════════════════════════════════════════════════
--  TYPOGRAPHY
-- ══════════════════════════════════════════════════════════════════

--[[
    Large bold title with a pink gradient text effect (via label + gradient).
]]
function SwiftUI:createTitle(parent, text, fontSize)
    local label = newLabel(
        parent,
        "Title",
        text,
        UDim2.new(1, -DEFAULTS.Padding * 2, 0, 36),
        UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.AccentEnd,          -- hot-pink color (gradient not on text directly in Roblox)
        fontSize or 22,
        DEFAULTS.FontTitle
    )
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

--[[
    Standard body text label.
]]
function SwiftUI:createLabel(parent, text, size, position, fontSize)
    return newLabel(
        parent,
        "Label",
        text,
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 30),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.TextSecondary,
        fontSize or DEFAULTS.FontSize,
        DEFAULTS.FontLight
    )
end

-- ══════════════════════════════════════════════════════════════════
--  BUTTON
-- ══════════════════════════════════════════════════════════════════

--[[
    Gradient button (pink accent gradient by default).
    Parameters:
        parent   – Parent instance
        text     – Button label
        size     – UDim2
        position – UDim2
        primary  – true = pink gradient, false = white ghost style
        callback – function()
]]
function SwiftUI:createButton(parent, text, size, position, primary, callback)
    local isPrimary = (primary ~= false)   -- default true

    local btn = Instance.new("TextButton")
    btn.Name                  = "Button_" .. text
    btn.Text                  = text
    btn.Size                  = size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 42)
    btn.Position              = position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding)
    btn.BackgroundColor3      = isPrimary and THEME.AccentStart or THEME.Surface
    btn.TextColor3            = isPrimary and THEME.TextOnAccent or THEME.AccentEnd
    btn.TextSize              = DEFAULTS.FontSize
    btn.Font                  = DEFAULTS.FontTitle
    btn.BorderSizePixel       = 0
    btn.AutoButtonColor       = false
    btn.Parent                = parent

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
    corner.Parent = btn

    -- Gradient fill for primary buttons
    local gradient
    if isPrimary then
        gradient = applyGradient(btn, THEME.AccentStart, THEME.AccentEnd, 135)
    else
        newStroke(btn, THEME.Border, 1.5)
    end

    -- Hover: scale up slightly + brighten
    btn.MouseEnter:Connect(function()
        tween(btn, { Size = UDim2.new(
            btn.Size.X.Scale, btn.Size.X.Offset,
            btn.Size.Y.Scale, btn.Size.Y.Offset + 2
        )}, 0.12)
        if not isPrimary then
            btn.BackgroundColor3 = THEME.SurfaceAlt
        end
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, { Size = size or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 42) }, 0.12)
        btn.BackgroundColor3 = isPrimary and THEME.AccentStart or THEME.Surface
    end)

    -- Press feedback
    btn.MouseButton1Down:Connect(function()
        tween(btn, { BackgroundTransparency = 0.15 }, 0.08)
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, { BackgroundTransparency = 0 }, 0.08)
    end)

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

-- ══════════════════════════════════════════════════════════════════
--  INPUT BOX
-- ══════════════════════════════════════════════════════════════════

--[[
    Styled text input with focus border animation.
]]
function SwiftUI:createInputBox(parent, placeholder, size, position)
    local frame = newFrame(
        parent,
        "InputBox",
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 42),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.SurfaceAlt
    )

    local stroke = newStroke(frame, THEME.Border, 1.5)

    local input = Instance.new("TextBox")
    input.Name                  = "TextInput"
    input.Size                  = UDim2.new(1, -DEFAULTS.Padding, 1, 0)
    input.Position              = UDim2.new(0, DEFAULTS.Padding / 2, 0, 0)
    input.BackgroundTransparency = 1
    input.TextColor3            = THEME.TextPrimary
    input.PlaceholderColor3     = THEME.TextSecondary
    input.PlaceholderText       = placeholder or "Type here…"
    input.TextSize              = DEFAULTS.FontSize
    input.Font                  = DEFAULTS.FontBody
    input.ClearTextOnFocus      = false
    input.Parent                = frame

    -- Focus: stroke becomes hot-pink
    input.Focused:Connect(function()
        tween(stroke, { Color = THEME.BorderFocus, Thickness = 2 }, 0.15)
        tween(frame, { BackgroundColor3 = THEME.Surface }, 0.15)
    end)
    input.FocusLost:Connect(function()
        tween(stroke, { Color = THEME.Border, Thickness = 1.5 }, 0.15)
        tween(frame, { BackgroundColor3 = THEME.SurfaceAlt }, 0.15)
    end)

    return frame, input
end

-- ══════════════════════════════════════════════════════════════════
--  TOGGLE
-- ══════════════════════════════════════════════════════════════════

--[[
    Animated on/off toggle with pink gradient track.
]]
function SwiftUI:createToggle(parent, label, defaultValue, callback, size, position)
    local row = newFrame(
        parent,
        "Toggle",
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 44),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.Surface
    )

    newLabel(
        row, "Label", label,
        UDim2.new(0.72, 0, 1, 0),
        UDim2.new(0, DEFAULTS.Padding, 0, 0),
        THEME.TextPrimary, DEFAULTS.FontSize, DEFAULTS.FontBody
    )

    -- Track
    local track = Instance.new("TextButton")
    track.Name             = "Track"
    track.Size             = UDim2.new(0, 52, 0, 28)
    track.Position         = UDim2.new(1, -64, 0.5, -14)
    track.BackgroundColor3 = defaultValue and THEME.AccentStart or THEME.Border
    track.BorderSizePixel  = 0
    track.Text             = ""
    track.AutoButtonColor  = false
    track.Parent           = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 14)
    trackCorner.Parent = track

    -- Gradient on track when ON
    local trackGradient
    if defaultValue then
        trackGradient = applyGradient(track, THEME.AccentStart, THEME.AccentEnd, 135)
    end

    -- Thumb (circle)
    local thumb = Instance.new("Frame")
    thumb.Name             = "Thumb"
    thumb.Size             = UDim2.new(0, 22, 0, 22)
    thumb.Position         = defaultValue and UDim2.new(0, 27, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    thumb.BackgroundColor3 = THEME.White
    thumb.BorderSizePixel  = 0
    thumb.Parent           = track

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 11)
    thumbCorner.Parent = thumb

    local isOn = defaultValue or false

    track.MouseButton1Click:Connect(function()
        isOn = not isOn

        if isOn then
            if not trackGradient then
                trackGradient = applyGradient(track, THEME.AccentStart, THEME.AccentEnd, 135)
            end
        else
            if trackGradient then
                trackGradient:Destroy()
                trackGradient = nil
            end
        end

        tween(track, { BackgroundColor3 = isOn and THEME.AccentStart or THEME.Border }, 0.2)
        tween(thumb, { Position = isOn and UDim2.new(0, 27, 0.5, -11) or UDim2.new(0, 3, 0.5, -11) }, 0.2)

        if callback then callback(isOn) end
    end)

    return row, track, thumb
end

-- ══════════════════════════════════════════════════════════════════
--  DROPDOWN
-- ══════════════════════════════════════════════════════════════════

--[[
    Styled dropdown with animated expand/collapse.
    Parameters:
        parent       – Parent instance
        options      – { "Option A", "Option B", … }
        defaultIndex – index of default selection (default 1)
        callback     – function(index, value)
]]
function SwiftUI:createDropdown(parent, options, defaultIndex, callback, size, position)
    local wrapper = newFrame(
        parent,
        "Dropdown",
        size     or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 42),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.SurfaceAlt
    )
    local stroke = newStroke(wrapper, THEME.Border, 1.5)

    -- Selected value label
    local selectedLabel = newLabel(
        wrapper, "SelectedLabel",
        options[defaultIndex or 1],
        UDim2.new(0.8, 0, 1, 0),
        UDim2.new(0, DEFAULTS.Padding, 0, 0),
        THEME.TextPrimary, DEFAULTS.FontSize, DEFAULTS.FontBody
    )

    -- Chevron button
    local chevron = Instance.new("TextButton")
    chevron.Name                = "Chevron"
    chevron.Size                = UDim2.new(0, 36, 1, 0)
    chevron.Position            = UDim2.new(1, -40, 0, 0)
    chevron.BackgroundTransparency = 1
    chevron.Text                = "▾"
    chevron.TextColor3          = THEME.AccentEnd
    chevron.TextSize            = 18
    chevron.Font                = DEFAULTS.FontTitle
    chevron.Parent              = wrapper

    -- Drop list
    local listHeight = #options * 38
    local list = Instance.new("Frame")
    list.Name             = "DropdownList"
    list.Size             = UDim2.new(1, 0, 0, listHeight)
    list.Position         = UDim2.new(0, 0, 1, 6)
    list.BackgroundColor3 = THEME.Surface
    list.BorderSizePixel  = 0
    list.ZIndex           = 10
    list.ClipsDescendants = true
    list.Visible          = false
    list.Parent           = wrapper

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
    listCorner.Parent = list

    newStroke(list, THEME.Border, 1.5)

    -- Populate options
    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Name             = "Option_" .. i
        optBtn.Size             = UDim2.new(1, 0, 0, 38)
        optBtn.Position         = UDim2.new(0, 0, 0, (i - 1) * 38)
        optBtn.BackgroundColor3 = THEME.Surface
        optBtn.BorderSizePixel  = 0
        optBtn.Text             = option
        optBtn.TextColor3       = THEME.TextPrimary
        optBtn.TextSize         = DEFAULTS.FontSize
        optBtn.Font             = DEFAULTS.FontBody
        optBtn.AutoButtonColor  = false
        optBtn.ZIndex           = 11
        optBtn.Parent           = list

        optBtn.MouseEnter:Connect(function()
            tween(optBtn, { BackgroundColor3 = THEME.SurfaceAlt }, 0.1)
        end)
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, { BackgroundColor3 = THEME.Surface }, 0.1)
        end)
        optBtn.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            list.Visible = false
            tween(stroke, { Color = THEME.Border }, 0.15)
            if callback then callback(i, option) end
        end)
    end

    -- Toggle list visibility
    local isOpen = false
    local function toggleList()
        isOpen = not isOpen
        list.Visible = isOpen
        tween(stroke, { Color = isOpen and THEME.BorderFocus or THEME.Border }, 0.15)
        tween(chevron, { Rotation = isOpen and 180 or 0 }, 0.2)
    end

    chevron.MouseButton1Click:Connect(toggleList)
    wrapper.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleList()
        end
    end)

    return wrapper, list, selectedLabel
end

-- ══════════════════════════════════════════════════════════════════
--  DIVIDER
-- ══════════════════════════════════════════════════════════════════

--[[
    A subtle horizontal divider line with a gradient.
]]
function SwiftUI:createDivider(parent, position)
    local line = newFrame(
        parent,
        "Divider",
        UDim2.new(1, -DEFAULTS.Padding * 2, 0, 1),
        position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
        THEME.Border
    )
    applyGradient(line, THEME.Surface, THEME.Border, 90)
    local g2 = applyGradient(line, THEME.Border, THEME.Surface, 90)
    -- Simple center fade: just use the border color at full opacity
    line.BackgroundColor3 = THEME.Border
    if g2 then g2:Destroy() end
    return line
end

-- ══════════════════════════════════════════════════════════════════
--  NOTIFICATION  (toast)
-- ══════════════════════════════════════════════════════════════════

--[[
    Shows a toast notification that slides in from the right and fades out.
    Parameters:
        message  – string
        kind     – "success" | "danger" | "warning" | "info" (default "info")
        duration – seconds visible (default 3)
]]
function SwiftUI:notify(message, kind, duration)
    local accentColor = ({
        success = THEME.Success,
        danger  = THEME.Danger,
        warning = THEME.Warning,
        info    = THEME.AccentEnd,
    })[kind or "info"] or THEME.AccentEnd

    local toast = newFrame(
        self.screenGui,
        "Toast_" .. tostring(tick()),
        UDim2.new(0, 300, 0, 60),
        UDim2.new(1, 20, 0, 20),   -- starts off-screen to the right
        THEME.Surface
    )
    toast.ZIndex = 100

    -- Pink-white gradient base
    applyGradient(toast, THEME.GradientStart, Color3.fromRGB(255, 240, 250), 160)

    -- Colored left accent bar
    local accent = newFrame(toast, "Accent", UDim2.new(0, 4, 1, -16), UDim2.new(0, 8, 0, 8), accentColor)
    accent.ZIndex = 101

    -- Message text
    local msg = newLabel(
        toast, "Message", message,
        UDim2.new(1, -30, 1, 0),
        UDim2.new(0, 20, 0, 0),
        THEME.TextPrimary, 13, DEFAULTS.FontBody
    )
    msg.ZIndex = 101

    newStroke(toast, THEME.Border, 1)

    -- Slide in
    tween(toast, { Position = UDim2.new(1, -316, 0, 20) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration or 3, function()
        tween(toast, { Position = UDim2.new(1, 20, 0, 20) }, 0.3)
        task.wait(0.35)
        toast:Destroy()
    end)

    return toast
end

-- ══════════════════════════════════════════════════════════════════
--  ANIMATION HELPERS
-- ══════════════════════════════════════════════════════════════════

--[[
    Animate any property on an instance.
]]
function SwiftUI:animate(instance, properties, duration, easingStyle, easingDirection)
    return tween(instance, properties, duration, easingStyle, easingDirection)
end

--[[
    Fade an instance in (BackgroundTransparency 1 → 0).
]]
function SwiftUI:fadeIn(instance, duration)
    instance.BackgroundTransparency = 1
    return tween(instance, { BackgroundTransparency = 0 }, duration)
end

--[[
    Fade an instance out (BackgroundTransparency 0 → 1).
]]
function SwiftUI:fadeOut(instance, duration)
    return tween(instance, { BackgroundTransparency = 1 }, duration)
end

-- ══════════════════════════════════════════════════════════════════
--  DESTROY
-- ══════════════════════════════════════════════════════════════════

function SwiftUI:destroy()
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

-- ══════════════════════════════════════════════════════════════════

return SwiftUI
