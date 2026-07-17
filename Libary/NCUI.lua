local NCUI = {}
NCUI.__index = NCUI

local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer

local THEME = {
    Background   = Color3.fromRGB(8,   8,   10),
    Surface      = Color3.fromRGB(16,  16,  20),
    SurfaceAlt   = Color3.fromRGB(26,  26,  32),
    SurfacePop   = Color3.fromRGB(38,  38,  48),

    GradPrimary  = { Color3.fromRGB(0, 110, 255), Color3.fromRGB(0, 60, 200), 145 },
    GradPanel    = { Color3.fromRGB(22, 22, 28),   Color3.fromRGB(12, 12, 16),  180 },
    GradAccent   = { Color3.fromRGB(0, 120, 255), Color3.fromRGB(0, 70, 180), 135 },

    Accent       = Color3.fromRGB(0,   110, 255),
    AccentDim    = Color3.fromRGB(0,   75,  180),

    Border       = Color3.fromRGB(44,  44,  56),
    BorderFocus  = Color3.fromRGB(0,   110, 255),

    TextPrimary  = Color3.fromRGB(245, 245, 255),
    TextSecondary= Color3.fromRGB(130, 135, 155),
    TextOnAccent = Color3.fromRGB(255, 255, 255),

    Success      = Color3.fromRGB(52,  211, 153),
    Danger       = Color3.fromRGB(248,  92,  92),
    Warning      = Color3.fromRGB(251, 191,  36),
    Info         = Color3.fromRGB(0,   110, 255),

    White        = Color3.fromRGB(255, 255, 255),
    Black        = Color3.fromRGB(0,   0,   0),

    ToastBackground = Color3.fromRGB(16, 16, 22),
    ToastLine       = Color3.fromRGB(0, 110, 255),
}

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

function NCUI.setTheme(overrides)
    for k, v in pairs(overrides) do
        THEME[k] = v
    end
end

function NCUI.setDefaults(overrides)
    for k, v in pairs(overrides) do
        DEFAULTS[k] = v
    end
end

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

local function newStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color     or THEME.Border
    s.Thickness = thickness or DEFAULTS.BorderWidth
    s.Parent    = parent
    return s
end

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

local function newGradient(parent, colorA, colorB, rotation)
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

local function makeDraggable(panel, handle)
    handle = handle or panel
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local _notifySlots = {}

local NOTIFY_W   = 280
local NOTIFY_H   = 56
local NOTIFY_GAP = 10
local NOTIFY_X   = -1 * (NOTIFY_W + 16)

local function _rebuildNotifyPositions()
    for i, toast in ipairs(_notifySlots) do
        local targetY = 16 + (i - 1) * (NOTIFY_H + NOTIFY_GAP)
        tw(toast, { Position = UDim2.new(1, -(NOTIFY_W + 16), 0, targetY) }, 0.25)
    end
end

local function _removeNotify(toast)
    for i, t in ipairs(_notifySlots) do
        if t == toast then
            table.remove(_notifySlots, i)
            break
        end
    end
    _rebuildNotifyPositions()

    tw(toast, { Position = UDim2.new(1, 16, 0, toast.Position.Y.Offset), BackgroundTransparency = 1 }, 0.22)
    for _, child in ipairs(toast:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            tw(child, { TextTransparency = 1 }, 0.22)
        elseif child:IsA("Frame") then
            tw(child, { BackgroundTransparency = 1 }, 0.22)
        elseif child:IsA("UIStroke") then
            tw(child, { Transparency = 1 }, 0.22)
        end
    end
    task.delay(0.25, function()
        toast:Destroy()
    end)
end

function NCUI.new()
    local self = setmetatable({}, NCUI)

    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name           = "NCUI"
    self.screenGui.ResetOnSpawn   = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local success, _ = pcall(function() self.screenGui.Parent = game:GetService("CoreGui") end)
    if not success then
        self.screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self.panels = {}
    return self
end

function NCUI:createPanel(name, title, size, position, keySettings)
    local finalSize = size or UDim2.new(0, 560, 0, 420)
    local finalPos = position or UDim2.new(0.5, -280, 0.5, -210)

    local shell = Instance.new("Frame")
    shell.Name             = name
    shell.Size             = UDim2.new(0, 280, 0, 160)
    shell.Position         = UDim2.new(0.5, -140, 0.5, -80)
    shell.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shell.BorderSizePixel  = 0
    shell.ClipsDescendants = true
    shell.Parent           = self.screenGui

    local shellCorner = Instance.new("UICorner")
    shellCorner.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
    shellCorner.Parent = shell

    local stroke = newStroke(shell, THEME.Accent, 1.5)
    stroke.Transparency = 0

    local bgGradient = newGradient(shell, THEME.GradPanel[1], THEME.GradPanel[2], THEME.GradPanel[3])

    local ncLabel = newLabel(
        shell, "NCLabel", "NC",
        UDim2.new(1, 0, 0, 32),
        UDim2.new(0, 0, 0, 25),
        THEME.Accent, 32, DEFAULTS.FontTitle
    )
    ncLabel.TextXAlignment = Enum.TextXAlignment.Center
    ncLabel.TextTransparency = 0

    local statusLabel = newLabel(
        shell, "StatusLabel", "Connecting...",
        UDim2.new(1, 0, 0, 20),
        UDim2.new(0, 0, 0, 75),
        THEME.TextSecondary, 12, DEFAULTS.FontBody
    )
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextTransparency = 0

    local loadBarBg = newFrame(shell, "LoadBarBg", UDim2.new(0.8, 0, 0, 6), UDim2.new(0.1, 0, 0, 110), Color3.fromRGB(30, 30, 40), 999)
    loadBarBg.BackgroundTransparency = 0.5

    local loadBar = newFrame(loadBarBg, "LoadBar", UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0), THEME.Accent, 999)

    local titleBar = Instance.new("TextButton")
    titleBar.Name                  = "TitleBar"
    titleBar.Size                  = UDim2.new(1, 0, 0, 44)
    titleBar.Position              = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundTransparency = 1
    titleBar.Text                  = ""
    titleBar.ZIndex                = 5
    titleBar.Visible               = false
    titleBar.Parent                = shell

    local titleLabel = newLabel(
        titleBar, "TitleText", title or name,
        UDim2.new(1, -50, 1, 0),
        UDim2.new(0, DEFAULTS.Padding, 0, 0),
        THEME.TextPrimary, 15, DEFAULTS.FontTitle
    )
    titleLabel.ZIndex = 6
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name                  = "CloseBtn"
    closeBtn.Size                  = UDim2.new(0, 28, 0, 28)
    closeBtn.Position              = UDim2.new(1, -38, 0.5, -14)
    closeBtn.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
    closeBtn.BorderSizePixel       = 0
    closeBtn.Text                  = ""
    closeBtn.ZIndex                = 6
    closeBtn.Parent                = titleBar

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 999)
    closeBtnCorner.Parent = closeBtn

    newGradient(closeBtn, Color3.fromRGB(50, 50, 62), Color3.fromRGB(38, 38, 50), 180)

    local closeLabel = newLabel(
        closeBtn, "CloseLabel", "x",
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, -2),
        THEME.TextSecondary, 18, DEFAULTS.FontTitle
    )
    closeLabel.TextXAlignment = Enum.TextXAlignment.Center
    closeLabel.ZIndex = 7

    closeBtn.MouseEnter:Connect(function()
        tw(closeBtn, { BackgroundTransparency = 0.15 }, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        tw(closeBtn, { BackgroundTransparency = 0 }, 0.1)
        closeLabel.TextColor3 = THEME.TextSecondary
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tw(shell, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tw(stroke, { Transparency = 1 }, 0.2)
        task.delay(0.3, function() shell:Destroy() end)
    end)

    local div = newFrame(shell, "TitleDivider",
        UDim2.new(1, 0, 0, 1),
        UDim2.new(0, 0, 0, 44),
        THEME.Border, 0
    )
    div.Visible = false

    local sidebar = newFrame(shell, "Sidebar",
        UDim2.new(0, 140, 1, -45),
        UDim2.new(0, 0, 0, 45),
        THEME.Surface, DEFAULTS.CornerRadius
    )
    sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    newGradient(sidebar, Color3.fromRGB(18, 18, 24), Color3.fromRGB(12, 12, 16), 180)
    sidebar.Visible = false

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
    sidebarCorner.Parent = sidebar

    local sidebarDiv = newFrame(shell, "SidebarDivider",
        UDim2.new(0, 1, 1, -45),
        UDim2.new(0, 140, 0, 45),
        THEME.Border, 0
    )
    sidebarDiv.Visible = false

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.FillDirection = Enum.FillDirection.Vertical
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.Parent = sidebar

    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingBottom = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    sidebarPadding.Parent = sidebar

    local contentContainer = newFrame(shell, "ContentContainer",
        UDim2.new(1, -141, 1, -45),
        UDim2.new(0, 141, 0, 45),
        THEME.Background, DEFAULTS.CornerRadius
    )
    contentContainer.BackgroundTransparency = 1
    contentContainer.Visible = false

    makeDraggable(shell, titleBar)

    local Window = {
        Shell = shell,
        Sidebar = sidebar,
        ContentContainer = contentContainer,
        Tabs = {},
        ActiveTab = nil,
        UI = self
    }

    function Window:CreateTab(tabName)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "TabBtn_" .. tabName
        tabBtn.Size = UDim2.new(1, 0, 0, 34)
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = ""
        tabBtn.BorderSizePixel = 0
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 2
        tabBtn.Parent = self.Sidebar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = tabBtn

        local activeBg = Instance.new("Frame")
        activeBg.Name = "ActiveBg"
        activeBg.Size = UDim2.new(1, 0, 1, 0)
        activeBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        activeBg.BackgroundTransparency = 1
        activeBg.BorderSizePixel = 0
        activeBg.ZIndex = 1
        activeBg.Parent = tabBtn

        local activeCorner = Instance.new("UICorner")
        activeCorner.CornerRadius = UDim.new(0, 8)
        activeCorner.Parent = activeBg

        newGradient(activeBg, THEME.GradPrimary[1], THEME.GradPrimary[2], THEME.GradPrimary[3])

        local textLabel = newLabel(
            tabBtn, "TextLabel", tabName,
            UDim2.new(1, 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            THEME.TextSecondary, DEFAULTS.FontSize, DEFAULTS.FontTitle
        )
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.ZIndex = 3

        local body = Instance.new("ScrollingFrame")
        body.Name = "TabBody_" .. tabName
        body.Size = UDim2.new(1, 0, 1, 0)
        body.Position = UDim2.new(0, 0, 0, 0)
        body.BackgroundTransparency = 1
        body.BorderSizePixel = 0
        body.ScrollBarThickness = 2
        body.ScrollBarImageColor3 = THEME.Border
        body.CanvasSize = UDim2.new(0, 0, 0, 0)
        body.AutomaticCanvasSize = Enum.AutomaticSize.Y
        body.Visible = false
        body.Parent = self.ContentContainer

        local innerPad = Instance.new("UIPadding")
        innerPad.PaddingTop    = UDim.new(0, DEFAULTS.Padding)
        innerPad.PaddingBottom = UDim.new(0, DEFAULTS.Padding)
        innerPad.PaddingLeft   = UDim.new(0, DEFAULTS.Padding)
        innerPad.PaddingRight  = UDim.new(0, DEFAULTS.Padding)
        innerPad.Parent        = body

        local layout = Instance.new("UIListLayout")
        layout.SortOrder        = Enum.SortOrder.LayoutOrder
        layout.FillDirection    = Enum.FillDirection.Vertical
        layout.Padding          = UDim.new(0, 8)
        layout.Parent           = body

        local tab = { Button = tabBtn, ActiveBg = activeBg, Body = body }
        table.insert(self.Tabs, tab)

        tabBtn.MouseButton1Click:Connect(function()
            self:SelectTab(tab)
        end)

        if #self.Tabs == 1 then
            self:SelectTab(tab)
        end

        return body
    end

    function Window:SelectTab(tabToSelect)
        for _, tab in ipairs(self.Tabs) do
            local label = tab.Button:FindFirstChild("TextLabel")
            if tab == tabToSelect then
                tw(tab.ActiveBg, { BackgroundTransparency = 0 }, 0.15)
                if label then tw(label, { TextColor3 = THEME.TextOnAccent }, 0.15) end
                tab.Body.Visible = true
            else
                tw(tab.ActiveBg, { BackgroundTransparency = 1 }, 0.15)
                if label then tw(label, { TextColor3 = THEME.TextSecondary }, 0.15) end
                tab.Body.Visible = false
            end
        end
    end

    local function openMainMenu()
        tw(stroke, { Color = THEME.Border }, 0.3)

        shell.ClipsDescendants = false
        tw(shell, {
            Size = finalSize,
            Position = finalPos
        }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        task.wait(0.5)

        titleBar.Visible = true
        div.Visible = true
        sidebar.Visible = true
        sidebarDiv.Visible = true
        contentContainer.Visible = true

        for _, child in ipairs(shell:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                child.TextTransparency = 1
                tw(child, { TextTransparency = 0 }, 0.3)
            end
        end
    end

    local function showKeySystem(onCorrect)
        tw(shell, {
            Size = UDim2.new(0, 320, 0, 180),
            Position = UDim2.new(0.5, -160, 0.5, -90)
        }, 0.3)
        task.wait(0.3)

        local keyTitle = newLabel(
            shell, "KeyTitle", "KEY SYSTEM",
            UDim2.new(1, -20, 0, 30),
            UDim2.new(0, 10, 0, 15),
            THEME.Accent, 16, DEFAULTS.FontTitle
        )
        keyTitle.TextXAlignment = Enum.TextXAlignment.Center

        local keyInputFrame, keyInput = self:createInputBox(
            shell,
            "Enter key here...",
            UDim2.new(1, -30, 0, 42),
            UDim2.new(0, 15, 0, 55)
        )

        local submitBtn
        local getBtn

        submitBtn = self:createButton(
            shell,
            "Submit Key",
            UDim2.new(0.5, -20, 0, 38),
            UDim2.new(0, 15, 0, 115),
            "primary",
            function()
                local entered = keyInput.Text
                if entered == keySettings.Key then
                    keyTitle:Destroy()
                    keyInputFrame:Destroy()
                    submitBtn:Destroy()
                    getBtn:Destroy()
                    onCorrect()
                else
                    self:notify("Incorrect key, try again!", "danger", 2.5)
                end
            end
        )

        getBtn = self:createButton(
            shell,
            "Get Key",
            UDim2.new(0.5, -20, 0, 38),
            UDim2.new(0.5, 5, 0, 115),
            "ghost",
            function()
                if setclipboard then
                    setclipboard(keySettings.Link)
                elseif syn and syn.write_clipboard then
                    syn.write_clipboard(keySettings.Link)
                end
                self:notify("Key link copied to clipboard!", "success", 2.5)
            end
        )
    end

    task.spawn(function()
        task.wait(0.4)

        local steps = {
            "Connecting to servers...",
            "Validating whitelist...",
            "Loading assets...",
            "Injecting scripts...",
            "Ready!"
        }

        for i, step in ipairs(steps) do
            statusLabel.Text = step
            tw(loadBar, { Size = UDim2.new(i / #steps, 0, 1, 0) }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.wait(0.45)
        end
        task.wait(0.2)

        tw(ncLabel, { TextTransparency = 1 }, 0.25)
        tw(statusLabel, { TextTransparency = 1 }, 0.25)
        tw(loadBarBg, { BackgroundTransparency = 1 }, 0.25)
        tw(loadBar, { BackgroundTransparency = 1 }, 0.25)
        task.wait(0.25)

        ncLabel:Destroy()
        statusLabel:Destroy()
        loadBarBg:Destroy()

        if keySettings then
            showKeySystem(openMainMenu)
        else
            openMainMenu()
        end
    end)

    table.insert(self.panels, { instance = shell, window = Window })
    return Window
end

function NCUI:createTitle(parent, text, fontSize)
    local l = newLabel(
        parent, "Title", text,
        UDim2.new(1, -4, 0, 30),
        UDim2.new(0, 2, 0, 0),
        THEME.TextPrimary, fontSize or 16, DEFAULTS.FontTitle
    )
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

function NCUI:createLabel(parent, text, size, position, fontSize)
    return newLabel(
        parent, "Label", text,
        size     or UDim2.new(1, -4, 0, 26),
        position or UDim2.new(0, 2, 0, 0),
        THEME.TextSecondary, fontSize or DEFAULTS.FontSize, DEFAULTS.FontLight
    )
end

function NCUI:createButton(parent, text, size, position, style, callback)
    style = style or "primary"

    local btn = Instance.new("TextButton")
    btn.Name             = "Button_" .. text
    btn.Text             = ""
    btn.Size             = size     or UDim2.new(1, -4, 0, 40)
    btn.Position         = position or UDim2.new(0, 2, 0, 0)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.ZIndex           = 2
    btn.Parent           = parent

    local btnBg = Instance.new("Frame")
    btnBg.Name = "Bg"
    btnBg.Size = UDim2.new(1, 0, 1, 0)
    btnBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btnBg.BorderSizePixel = 0
    btnBg.ZIndex = 1
    btnBg.Parent = btn

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btnBg

    local label = newLabel(
        btn, "TextLabel", text,
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        THEME.TextOnAccent, DEFAULTS.FontSize, DEFAULTS.FontTitle
    )
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.ZIndex = 3

    local stroke
    if style == "primary" then
        newGradient(btnBg, THEME.GradPrimary[1], THEME.GradPrimary[2], THEME.GradPrimary[3])
        label.TextColor3 = THEME.TextOnAccent
    elseif style == "ghost" then
        newGradient(btnBg, Color3.fromRGB(38, 38, 50), Color3.fromRGB(28, 28, 38), 180)
        label.TextColor3 = THEME.TextSecondary
        stroke = newStroke(btnBg, THEME.Border, 1)
    elseif style == "danger" then
        newGradient(btnBg, Color3.fromRGB(220, 60, 60), Color3.fromRGB(180, 40, 40), 145)
        label.TextColor3 = THEME.TextOnAccent
    end

    btn.MouseEnter:Connect(function()
        tw(btnBg, { BackgroundTransparency = 0.08 }, 0.1)
        if stroke then tw(stroke, { Color = THEME.BorderFocus }, 0.1) end
    end)
    btn.MouseLeave:Connect(function()
        tw(btnBg, { BackgroundTransparency = 0 }, 0.1)
        if stroke then tw(stroke, { Color = THEME.Border }, 0.1) end
    end)

    btn.MouseButton1Down:Connect(function()
        tw(btnBg, { BackgroundTransparency = 0.2 }, 0.07)
    end)
    btn.MouseButton1Up:Connect(function()
        tw(btnBg, { BackgroundTransparency = 0 }, 0.1)
    end)

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

function NCUI:createInputBox(parent, placeholder, size, position)
    local frame = newFrame(
        parent, "InputBox",
        size     or UDim2.new(1, -4, 0, 42),
        position or UDim2.new(0, 2, 0, 0),
        Color3.fromRGB(255, 255, 255), 8
    )
    newGradient(frame, Color3.fromRGB(36, 36, 48), Color3.fromRGB(28, 28, 38), 180)
    local stroke = newStroke(frame, THEME.Border, 1)

    local input = Instance.new("TextBox")
    input.Name                   = "TextInput"
    input.Size                   = UDim2.new(1, -20, 1, 0)
    input.Position               = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.TextColor3             = THEME.TextPrimary
    input.PlaceholderColor3      = THEME.TextSecondary
    input.PlaceholderText        = placeholder or "Type here…"
    input.TextSize               = DEFAULTS.FontSize
    input.Font                   = DEFAULTS.FontBody
    input.ClearTextOnFocus       = false
    input.TextXAlignment         = Enum.TextXAlignment.Left
    input.Parent                 = frame

    input.Focused:Connect(function()
        tw(stroke, { Color = THEME.BorderFocus, Thickness = 1.5 }, 0.15)
    end)
    input.FocusLost:Connect(function()
        tw(stroke, { Color = THEME.Border, Thickness = 1 }, 0.15)
    end)

    return frame, input
end

function NCUI:createToggle(parent, label, defaultValue, callback, size, position)
    local row = newFrame(
        parent, "Toggle",
        size     or UDim2.new(1, -4, 0, 44),
        position or UDim2.new(0, 2, 0, 0),
        Color3.fromRGB(255, 255, 255), 8
    )
    newGradient(row, Color3.fromRGB(34, 34, 44), Color3.fromRGB(26, 26, 34), 180)

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
        trackGrad = newGradient(track, THEME.GradPrimary[1], THEME.GradPrimary[2], THEME.GradPrimary[3])
    else
        newGradient(track, Color3.fromRGB(48, 48, 60), Color3.fromRGB(34, 34, 44), 180)
    end

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
        local g = track:FindFirstChildOfClass("UIGradient")
        if g then g:Destroy() end

        if isOn then
            newGradient(track, THEME.GradPrimary[1], THEME.GradPrimary[2], THEME.GradPrimary[3])
        else
            newGradient(track, Color3.fromRGB(48, 48, 60), Color3.fromRGB(34, 34, 44), 180)
        end

        tw(thumb, {
            Position = isOn and UDim2.new(0, 25, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        if callback then callback(isOn) end
    end)

    return row, track, thumb
end

function NCUI:createDropdown(parent, options, defaultIndex, callback, size, position)
    local wrapper = newFrame(
        parent, "Dropdown",
        size     or UDim2.new(1, -4, 0, 42),
        position or UDim2.new(0, 2, 0, 0),
        Color3.fromRGB(255, 255, 255), 8
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
    chevron.Text                   = ">"
    chevron.TextColor3             = THEME.TextSecondary
    chevron.TextSize               = 22
    chevron.Font                   = DEFAULTS.FontTitle
    chevron.Rotation               = 90
    chevron.Parent                 = wrapper

    local list = Instance.new("Frame")
    list.Name             = "DropdownList"
    list.Size             = UDim2.new(1, 0, 0, 0)
    list.Position         = UDim2.new(0, 0, 1, 6)
    list.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    list.BorderSizePixel  = 0
    list.ZIndex           = 10
    list.ClipsDescendants = true
    list.Visible          = false
    list.Parent           = wrapper

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = list

    newGradient(list, Color3.fromRGB(34, 34, 46), Color3.fromRGB(24, 24, 34), 180)
    newStroke(list, THEME.Border, 1)

    local isOpen = false
    local targetHeight = #options * 38

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
            isOpen = false
            tw(stroke,  { Color = THEME.Border }, 0.15)
            tw(chevron, { Rotation = 90 }, 0.18)
            tw(list, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.2, function()
                if not isOpen then
                    list.Visible = false
                end
            end)
            if callback then callback(i, option) end
        end)
    end

    local function toggle()
        isOpen = not isOpen
        tw(stroke,  { Color = isOpen and THEME.BorderFocus or THEME.Border }, 0.15)
        tw(chevron, { Rotation = isOpen and 270 or 90 }, 0.18)

        if isOpen then
            list.Visible = true
            tw(list, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        else
            tw(list, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.2, function()
                if not isOpen then
                    list.Visible = false
                end
            end)
        end
    end

    chevron.MouseButton1Click:Connect(toggle)
    wrapper.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)

    return wrapper, list, selectedLabel
end

function NCUI:createDivider(parent, position)
    return newFrame(
        parent, "Divider",
        UDim2.new(1, -4, 0, 1),
        position or UDim2.new(0, 2, 0, 0),
        THEME.Border, 0
    )
end

function NCUI:notify(message, kind, duration)
    local kindColor = ({
        success = THEME.Success,
        danger  = THEME.Danger,
        warning = THEME.Warning,
        info    = THEME.Accent,
    })[kind or "info"] or THEME.Accent

    local slotIndex = #_notifySlots + 1
    local yPos = 16 + (slotIndex - 1) * (NOTIFY_H + NOTIFY_GAP)

    local toast = Instance.new("Frame")
    toast.Name             = "Toast_" .. tostring(tick())
    toast.Size             = UDim2.new(0, NOTIFY_W, 0, NOTIFY_H)
    toast.Position         = UDim2.new(1, 16, 0, yPos)
    toast.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toast.BorderSizePixel  = 0
    toast.ZIndex           = 100
    toast.Parent           = self.screenGui

    local toastCorner = Instance.new("UICorner")
    toastCorner.CornerRadius = UDim.new(0, 6)
    toastCorner.Parent = toast

    newGradient(toast, THEME.ToastBackground, Color3.fromRGB(22, 22, 30), 180)
    newStroke(toast, THEME.Border, 1)

    local strip = newFrame(toast, "Strip", UDim2.new(0, 4, 1, 0), UDim2.new(0, 0, 0, 0), kindColor, 0)
    strip.ZIndex = 101
    local stripCorner = Instance.new("UICorner")
    stripCorner.CornerRadius = UDim.new(0, 6)
    stripCorner.Parent = strip

    local msg = newLabel(
        toast, "Msg", message,
        UDim2.new(1, -30, 1, 0),
        UDim2.new(0, 18, 0, 0),
        THEME.TextPrimary, 14, DEFAULTS.FontTitle
    )
    msg.ZIndex = 101

    local progBg = newFrame(toast, "ProgBg",
        UDim2.new(1, 0, 0, 2),
        UDim2.new(0, 0, 1, -2),
        Color3.fromRGB(255, 255, 255), 999
    )
    progBg.BackgroundTransparency = 0.9
    progBg.ZIndex = 101

    local prog = newFrame(progBg, "Prog",
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        kindColor, 999
    )
    prog.ZIndex = 102

    table.insert(_notifySlots, toast)

    tw(toast, { Position = UDim2.new(1, -(NOTIFY_W + 16), 0, yPos) }, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local dur = duration or 3.5
    tw(prog, { Size = UDim2.new(0, 0, 1, 0) }, dur, Enum.EasingStyle.Linear)

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        _removeNotify(toast)
    end

    task.delay(dur, dismiss)

    return toast
end

function NCUI:createKeybind(parent, label, defaultKey, callback, size, position)
    local row = newFrame(
        parent, "Keybind",
        size     or UDim2.new(1, -4, 0, 44),
        position or UDim2.new(0, 2, 0, 0),
        Color3.fromRGB(255, 255, 255), 8
    )
    newGradient(row, Color3.fromRGB(34, 34, 44), Color3.fromRGB(26, 26, 34), 180)

    newLabel(
        row, "Label", label,
        UDim2.new(0.6, 0, 1, 0),
        UDim2.new(0, DEFAULTS.Padding, 0, 0),
        THEME.TextPrimary
    )

    local bindBtn = Instance.new("TextButton")
    bindBtn.Name             = "BindBtn"
    bindBtn.Size             = UDim2.new(0, 80, 0, 26)
    bindBtn.Position         = UDim2.new(1, -92, 0.5, -13)
    bindBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.BorderSizePixel  = 0
    bindBtn.Text             = ""
    bindBtn.AutoButtonColor  = false
    bindBtn.ZIndex           = 2
    bindBtn.Parent           = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = bindBtn

    local btnBg = Instance.new("Frame")
    btnBg.Name = "Bg"
    btnBg.Size = UDim2.new(1, 0, 1, 0)
    btnBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btnBg.BorderSizePixel = 0
    btnBg.ZIndex = 1
    btnBg.Parent = bindBtn

    local activeCorner = Instance.new("UICorner")
    activeCorner.CornerRadius = UDim.new(0, 6)
    activeCorner.Parent = btnBg

    newGradient(btnBg, Color3.fromRGB(48, 48, 60), Color3.fromRGB(34, 34, 44), 180)

    local currentKey = defaultKey
    local keyName = currentKey and currentKey.Name or "None"

    local btnLabel = newLabel(
        bindBtn, "TextLabel", "[ " .. keyName .. " ]",
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        THEME.TextSecondary, DEFAULTS.FontSize - 1, DEFAULTS.FontTitle
    )
    btnLabel.TextXAlignment = Enum.TextXAlignment.Center
    btnLabel.ZIndex = 3

    local connection
    local waiting = false

    bindBtn.MouseButton1Click:Connect(function()
        if waiting then return end
        waiting = true
        btnLabel.Text = "[ ... ]"
        btnLabel.TextColor3 = THEME.Accent

        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local pressed = input.KeyCode
                if pressed == Enum.KeyCode.Escape then
                    currentKey = nil
                    btnLabel.Text = "[ None ]"
                    btnLabel.TextColor3 = THEME.TextSecondary
                else
                    currentKey = pressed
                    btnLabel.Text = "[ " .. pressed.Name .. " ]"
                    btnLabel.TextColor3 = THEME.TextPrimary
                end

                waiting = false
                connection:Disconnect()
                if callback then callback(currentKey) end
            end
        end)
    end)

    return row, bindBtn, currentKey
end

function NCUI:createSlider(parent, label, min, max, defaultVal, callback, size, position)
    local row = newFrame(
        parent, "Slider",
        size     or UDim2.new(1, -4, 0, 50),
        position or UDim2.new(0, 2, 0, 0),
        Color3.fromRGB(255, 255, 255), 8
    )
    newGradient(row, Color3.fromRGB(34, 34, 44), Color3.fromRGB(26, 26, 34), 180)

    local titleLabel = newLabel(
        row, "Label", label,
        UDim2.new(0.6, 0, 0, 22),
        UDim2.new(0, DEFAULTS.Padding, 0, 4),
        THEME.TextPrimary, 13
    )

    local valLabel = newLabel(
        row, "ValLabel", tostring(defaultVal or min),
        UDim2.new(0.3, 0, 0, 22),
        UDim2.new(0.7, -DEFAULTS.Padding, 0, 4),
        THEME.Accent, 13, DEFAULTS.FontTitle
    )
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local track = newFrame(
        row, "Track",
        UDim2.new(1, -DEFAULTS.Padding * 2, 0, 4),
        UDim2.new(0, DEFAULTS.Padding, 0, 32),
        Color3.fromRGB(48, 48, 60), 999
    )

    local fill = newFrame(
        track, "Fill",
        UDim2.new(0, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        Color3.fromRGB(255, 255, 255), 999
    )
    newGradient(fill, THEME.GradPrimary[1], THEME.GradPrimary[2], THEME.GradPrimary[3])

    local thumb = Instance.new("TextButton")
    thumb.Name             = "Thumb"
    thumb.Size             = UDim2.new(0, 12, 0, 12)
    thumb.Position         = UDim2.new(0, -6, 0.5, -6)
    thumb.BackgroundColor3 = THEME.White
    thumb.BorderSizePixel  = 0
    thumb.Text             = ""
    thumb.ZIndex           = 5
    thumb.Parent           = track

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 999)
    thumbCorner.Parent = thumb

    local function updateValue(percentage)
        local value = min + (max - min) * percentage
        value = math.floor(value + 0.5)

        valLabel.Text = tostring(value)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        thumb.Position = UDim2.new(percentage, -6, 0.5, -6)

        if callback then callback(value) end
    end

    local initialPercent = math.clamp(((defaultVal or min) - min) / (max - min), 0, 1)
    updateValue(initialPercent)

    local dragging = false

    local function handleDrag(input)
        local relativeX = input.Position.X - track.AbsolutePosition.X
        local percent = math.clamp(relativeX / track.AbsoluteSize.X, 0, 1)
        updateValue(percent)
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            handleDrag(input)
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            handleDrag(input)
        end
    end)

    return row, track, thumb
end

function NCUI:animate(instance, props, duration, style, direction)
    return tw(instance, props, duration, style, direction)
end

function NCUI:destroy()
    _notifySlots = {}
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

return NCUI
