local Library = {
    CurrentTab = nil,
    Tabs = {},
    Enabled = true,
    ToggleKey = Enum.KeyCode.RightControl,
    Theme = {
        MainBackground = Color3.fromRGB(15, 15, 15),
        SidebarBackground = Color3.fromRGB(20, 20, 20),
        ElementBackground = Color3.fromRGB(22, 22, 22),
        ButtonBackground = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(255, 100, 150),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 150),
        CornerRadius = UDim.new(0, 6),
        TitleSize = 22,
        TitleFont = Enum.Font.GothamBold,
        NotificationTransparency = 0
    }
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- ══════════════════════════════════════
-- Utility Functions
-- ══════════════════════════════════════

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
    stroke.Transparency = 0.6
    return stroke
end

-- ══════════════════════════════════════
-- Tooltip System
-- ══════════════════════════════════════

local TipGui
local function ShowTooltip(text, pos)
    if not text then return end
    if not TipGui then
        TipGui = Instance.new("ScreenGui", CoreGui)
        TipGui.Name = "NexusTooltips"
    end
    TipGui:ClearAllChildren()
    local frame = Instance.new("Frame", TipGui)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.AutomaticSize = Enum.AutomaticSize.XY
    frame.Position = UDim2.new(0, pos.X + 15, 0, pos.Y + 15)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    AddStroke(frame, Library.Theme.Accent, 0.8)
    local padding = Instance.new("UIPadding", frame)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel", frame)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.Text = text
    lbl.TextColor3 = Library.Theme.Text
    lbl.TextSize = 12
    lbl.AutomaticSize = Enum.AutomaticSize.XY
end

local function HideTooltip()
    if TipGui then TipGui:ClearAllChildren() end
end

-- ══════════════════════════════════════
-- Theme System
-- ══════════════════════════════════════

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

function Library:SetToggleKey(key)
    if typeof(key) == "EnumItem" then
        Library.ToggleKey = key
    end
end

-- ══════════════════════════════════════
-- Notification System
-- ══════════════════════════════════════

local ActiveNotifications = {}
local MAX_NOTIFICATIONS = 5

function Library:Notify(title, text, duration)
    local NotifyGui = CoreGui:FindFirstChild("NexusLibraryNotifications")
    if not NotifyGui then
        NotifyGui = Instance.new("ScreenGui", CoreGui)
        NotifyGui.Name = "NexusLibraryNotifications"
    end

    local NotificationFrame = Instance.new("CanvasGroup")
    NotificationFrame.Parent = NotifyGui
    NotificationFrame.BackgroundColor3 = Library.Theme.SidebarBackground
    NotificationFrame.GroupTransparency = Library.Theme.NotificationTransparency
    NotificationFrame.Size = UDim2.new(0, 250, 0, 60)
    NotificationFrame.Position = UDim2.new(1, 10, 1, -70)
    NotificationFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotificationFrame).CornerRadius = Library.Theme.CornerRadius

    local Accent = Instance.new("Frame", NotificationFrame)
    Accent.BackgroundColor3 = Library.Theme.Accent
    Accent.Size = UDim2.new(0, 3, 1, 0)
    Instance.new("UICorner", Accent)
    AddStroke(NotificationFrame, Color3.fromRGB(60, 60, 60), 0.8)

    local Title = Instance.new("TextLabel", NotificationFrame)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 12, 0, 8)
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Library.Theme.Text
    Title.TextSize = 14
    Title.Text = title
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", NotificationFrame)
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.new(0, 12, 0, 28)
    Desc.Size = UDim2.new(1, -20, 0, 20)
    Desc.Font = Enum.Font.Gotham
    Desc.TextColor3 = Library.Theme.TextDark
    Desc.TextSize = 12
    Desc.Text = text
    Desc.TextXAlignment = Enum.TextXAlignment.Left

    local function UpdatePositions()
        local count = 0
        for i = #ActiveNotifications, 1, -1 do
            local notif = ActiveNotifications[i]
            local targetY = -70 - (count * 65)
            Tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -260, 1, targetY)})
            count = count + 1
        end
    end

    if #ActiveNotifications >= MAX_NOTIFICATIONS then
        local oldest = table.remove(ActiveNotifications, 1)
        Tween(oldest, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 10, oldest.Position.Y.Scale, oldest.Position.Y.Offset)})
        task.delay(0.3, function() oldest:Destroy() end)
    end

    table.insert(ActiveNotifications, NotificationFrame)
    UpdatePositions()

    task.delay(duration or 3, function()
        local index = table.find(ActiveNotifications, NotificationFrame)
        if index then
            table.remove(ActiveNotifications, index)
            Tween(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 10, NotificationFrame.Position.Y.Scale, NotificationFrame.Position.Y.Offset)})
            task.delay(0.5, function() NotificationFrame:Destroy() end)
            UpdatePositions()
        end
    end)
end

-- ══════════════════════════════════════
-- Loading Screen System
-- ══════════════════════════════════════

function Library:CreateLoadingScreen(config)
    config = config or {}
    local title = config.Title or "Nexus"
    local subtitle = config.Subtitle or "Loading..."
    local duration = config.Duration or 3
    local accentColor = config.AccentColor or Library.Theme.Accent
    local bgColor = config.BackgroundColor or Color3.fromRGB(10, 10, 10)
    local logoIcon = config.LogoIcon -- optional ImageAsset ID
    local steps = config.Steps or {} -- e.g. {"Connecting...", "Loading modules...", "Done!"}

    local LoadGui = Instance.new("ScreenGui", CoreGui)
    LoadGui.Name = "NexusLoadingScreen"
    LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LoadGui.DisplayOrder = 999

    local BG = Instance.new("Frame", LoadGui)
    BG.BackgroundColor3 = bgColor
    BG.Size = UDim2.new(1, 0, 1, 0)
    BG.BorderSizePixel = 0

    local Center = Instance.new("Frame", BG)
    Center.BackgroundTransparency = 1
    Center.AnchorPoint = Vector2.new(0.5, 0.5)
    Center.Position = UDim2.new(0.5, 0, 0.5, 0)
    Center.Size = UDim2.new(0, 300, 0, 180)

    if logoIcon then
        local logo = Instance.new("ImageLabel", Center)
        logo.BackgroundTransparency = 1
        logo.AnchorPoint = Vector2.new(0.5, 0)
        logo.Position = UDim2.new(0.5, 0, 0, 0)
        logo.Size = UDim2.new(0, 60, 0, 60)
        logo.Image = "rbxassetid://" .. tostring(logoIcon)
    end

    local TitleLabel = Instance.new("TextLabel", Center)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0)
    TitleLabel.Position = UDim2.new(0.5, 0, 0, logoIcon and 70 or 10)
    TitleLabel.Size = UDim2.new(1, 0, 0, 35)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Library.Theme.Text
    TitleLabel.TextSize = 28

    local SubLabel = Instance.new("TextLabel", Center)
    SubLabel.BackgroundTransparency = 1
    SubLabel.AnchorPoint = Vector2.new(0.5, 0)
    SubLabel.Position = UDim2.new(0.5, 0, 0, logoIcon and 105 or 45)
    SubLabel.Size = UDim2.new(1, 0, 0, 20)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.Text = subtitle
    SubLabel.TextColor3 = Library.Theme.TextDark
    SubLabel.TextSize = 14

    -- Progress Bar
    local BarBG = Instance.new("Frame", Center)
    BarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BarBG.AnchorPoint = Vector2.new(0.5, 0)
    BarBG.Position = UDim2.new(0.5, 0, 0, logoIcon and 135 or 75)
    BarBG.Size = UDim2.new(0.8, 0, 0, 4)
    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame", BarBG)
    BarFill.BackgroundColor3 = accentColor
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    -- Step Label
    local StepLabel = Instance.new("TextLabel", Center)
    StepLabel.BackgroundTransparency = 1
    StepLabel.AnchorPoint = Vector2.new(0.5, 0)
    StepLabel.Position = UDim2.new(0.5, 0, 0, logoIcon and 148 or 88)
    StepLabel.Size = UDim2.new(1, 0, 0, 20)
    StepLabel.Font = Enum.Font.Gotham
    StepLabel.Text = ""
    StepLabel.TextColor3 = Library.Theme.TextDark
    StepLabel.TextSize = 12

    -- Animate
    if #steps > 0 then
        local stepDur = duration / #steps
        for i, stepText in ipairs(steps) do
            StepLabel.Text = stepText
            Tween(BarFill, TweenInfo.new(stepDur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(i / #steps, 0, 1, 0)})
            task.wait(stepDur)
        end
    else
        Tween(BarFill, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
        task.wait(duration)
    end

    -- Fade out
    Tween(BG, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})
    Tween(TitleLabel, TweenInfo.new(0.5), {TextTransparency = 1})
    Tween(SubLabel, TweenInfo.new(0.5), {TextTransparency = 1})
    Tween(StepLabel, TweenInfo.new(0.5), {TextTransparency = 1})
    Tween(BarBG, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    Tween(BarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    task.wait(0.5)
    LoadGui:Destroy()
end

-- ══════════════════════════════════════
-- Window System
-- ══════════════════════════════════════

function Library:CreateWindow(hubName)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = hubName or "NexusUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Library.Theme.MainBackground
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 1

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = Library.Theme.CornerRadius
    local MainStroke = AddStroke(MainFrame, Color3.fromRGB(45, 45, 45), 1)
    MainStroke.Transparency = 0.4

    Tween(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {BackgroundTransparency = 0})

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Enabled = not Library.Enabled
            MainFrame.Visible = Library.Enabled
            if Library.Enabled then
                MainFrame.Size = UDim2.new(0, 0, 0, 0)
                Tween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 600, 0, 400)})
            end
        end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Library.Theme.SidebarBackground
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Instance.new("UICorner", Sidebar).CornerRadius = Library.Theme.CornerRadius

    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Parent = Sidebar
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Position = UDim2.new(0, 15, 0, 15)
    LogoLabel.Size = UDim2.new(1, -30, 0, 30)
    LogoLabel.Font = Library.Theme.TitleFont
    LogoLabel.Text = hubName
    LogoLabel.TextColor3 = Library.Theme.Text
    LogoLabel.TextSize = Library.Theme.TitleSize
    LogoLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 2)

    local PageContainer = Instance.new("Frame")
    PageContainer.Parent = MainFrame
    PageContainer.BackgroundTransparency = 1
    PageContainer.Position = UDim2.new(0, 160, 0, 0)
    PageContainer.Size = UDim2.new(1, -160, 1, 0)

    -- Draggable
    local dragging, dragStart, startPos
    Sidebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local WindowLogic = {}

    function WindowLogic:CreateTab(name, iconID)
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.BackgroundTransparency = 1; TabButton.Size = UDim2.new(1, 0, 0, 38); TabButton.Text = ""

        local TabLabel = Instance.new("TextLabel", TabButton)
        TabLabel.BackgroundTransparency = 1; TabLabel.Position = UDim2.new(0, 35, 0, 0); TabLabel.Size = UDim2.new(1, -35, 1, 0)
        TabLabel.Font = Enum.Font.GothamSemibold; TabLabel.Text = name; TabLabel.TextColor3 = Library.Theme.TextDark; TabLabel.TextSize = 14; TabLabel.TextXAlignment = Enum.TextXAlignment.Left

        local Highlight = Instance.new("Frame", TabButton)
        Highlight.BackgroundColor3 = Library.Theme.Accent; Highlight.Position = UDim2.new(0, 0, 0, 5); Highlight.Size = UDim2.new(0, 3, 1, -10); Highlight.Transparency = 1

        local Page = Instance.new("CanvasGroup", PageContainer)
        Page.BackgroundTransparency = 1; Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false

        local TopBar = Instance.new("ScrollingFrame", Page)
        TopBar.BackgroundTransparency = 1; TopBar.Position = UDim2.new(0, 10, 0, 10); TopBar.Size = UDim2.new(1, -20, 0, 35); TopBar.ScrollBarThickness = 0; TopBar.CanvasSize = UDim2.new(0, 0, 0, 0); TopBar.ScrollingDirection = Enum.ScrollingDirection.X
        local TopBarList = Instance.new("UIListLayout", TopBar); TopBarList.FillDirection = Enum.FillDirection.Horizontal; TopBarList.Padding = UDim.new(0, 15)

        local SubPageContainer = Instance.new("Frame", Page)
        SubPageContainer.BackgroundTransparency = 1; SubPageContainer.Position = UDim2.new(0, 10, 0, 50); SubPageContainer.Size = UDim2.new(1, -20, 1, -60)

        local SubTabs = {}

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Library.Tabs) do t.Page.Visible = false; t.Highlight.Transparency = 1; t.Label.TextColor3 = Library.Theme.TextDark end
            Page.Visible = true; Highlight.Transparency = 0; TabLabel.TextColor3 = Library.Theme.Text
            Page.GroupTransparency = 1
            Tween(Page, TweenInfo.new(0.3), {GroupTransparency = 0})
        end)

        table.insert(Library.Tabs, {Page = Page, Label = TabLabel, Highlight = Highlight})
        if #Library.Tabs == 1 then Page.Visible = true; Highlight.Transparency = 0; TabLabel.TextColor3 = Library.Theme.Text end

        local PageLogic = {}

        function PageLogic:CreateSection(sectionName)
            local SubTabButton = Instance.new("TextButton", TopBar)
            SubTabButton.BackgroundTransparency = 1; SubTabButton.Font = Enum.Font.GothamSemibold; SubTabButton.Text = sectionName; SubTabButton.TextColor3 = Library.Theme.TextDark; SubTabButton.TextSize = 13; SubTabButton.Size = UDim2.new(0, 0, 1, 0); SubTabButton.AutomaticSize = Enum.AutomaticSize.X

            local SubPage = Instance.new("ScrollingFrame", SubPageContainer)
            SubPage.BackgroundTransparency = 1; SubPage.Size = UDim2.new(1, 0, 1, 0); SubPage.Visible = false; SubPage.ScrollBarThickness = 1
            local SubPageList = Instance.new("UIListLayout", SubPage); SubPageList.Padding = UDim.new(0, 8)

            SubTabButton.MouseButton1Click:Connect(function()
                for _, st in pairs(SubTabs) do st.Page.Visible = false; Tween(st.Btn, TweenInfo.new(0.2), {TextColor3 = Library.Theme.TextDark}) end
                SubPage.Visible = true; Tween(SubTabButton, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text})
            end)

            table.insert(SubTabs, {Page = SubPage, Btn = SubTabButton})
            if #SubTabs == 1 then SubPage.Visible = true; SubTabButton.TextColor3 = Library.Theme.Text end

            local SectionLogic = {}

            -- ═══ BUTTON ═══
            function SectionLogic:CreateButton(text, tooltip, callback)
                -- Support old API: CreateButton(text, callback)
                if type(tooltip) == "function" then callback = tooltip; tooltip = nil end

                local btn = Instance.new("TextButton", SubPage)
                btn.BackgroundColor3 = Library.Theme.ButtonBackground; btn.Size = UDim2.new(1, -10, 0, 35); btn.Font = Enum.Font.GothamSemibold; btn.Text = text; btn.TextColor3 = Library.Theme.Text; btn.TextSize = 13
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                local bstroke = AddStroke(btn, Color3.fromRGB(50, 50, 50), 0.8)

                btn.MouseEnter:Connect(function()
                    Tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                    Tween(bstroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent, Transparency = 0.2})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ButtonBackground})
                    Tween(bstroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 50), Transparency = 0.6})
                    HideTooltip()
                end)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Accent})
                    task.wait(0.1)
                    Tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ButtonBackground})
                    if callback then callback() end
                end)

                table.insert(Refresher, function() btn.BackgroundColor3 = Library.Theme.ButtonBackground; btn.TextColor3 = Library.Theme.Text end)
            end

            -- ═══ TOGGLE ═══
            function SectionLogic:CreateToggle(text, tooltip, startState, callback)
                -- Support old API: CreateToggle(text, startState, callback)
                if type(tooltip) == "boolean" then callback = startState; startState = tooltip; tooltip = nil end

                local tgl = Instance.new("Frame", SubPage)
                tgl.BackgroundColor3 = Library.Theme.ElementBackground; tgl.Size = UDim2.new(1, -10, 0, 40)
                Instance.new("UICorner", tgl).CornerRadius = UDim.new(0, 4)
                local tstroke = AddStroke(tgl, Color3.fromRGB(45, 45, 45), 0.8)

                tgl.MouseEnter:Connect(function()
                    Tween(tstroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent, Transparency = 0.4})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)
                tgl.MouseLeave:Connect(function()
                    Tween(tstroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 45, 45), Transparency = 0.6})
                    HideTooltip()
                end)

                local lbl = Instance.new("TextLabel", tgl)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -60, 1, 0)
                lbl.Font = Enum.Font.Gotham; lbl.Text = text; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

                local box = Instance.new("Frame", tgl)
                box.BackgroundColor3 = Color3.fromRGB(40, 40, 40); box.Position = UDim2.new(1, -45, 0.5, -10); box.Size = UDim2.new(0, 35, 0, 20)
                Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

                local check = Instance.new("Frame", box)
                check.BackgroundColor3 = Library.Theme.Text; check.Position = UDim2.new(0, 3, 0.5, -7); check.Size = UDim2.new(0, 14, 0, 14)
                Instance.new("UICorner", check).CornerRadius = UDim.new(1, 0)

                local s = startState or false
                local function applyState(newState)
                    s = newState
                    Tween(box, TweenInfo.new(0.2), {BackgroundColor3 = s and Library.Theme.Accent or Color3.fromRGB(40, 40, 40)})
                    Tween(check, TweenInfo.new(0.2), {Position = s and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
                    if callback then callback(s) end
                end

                if s then
                    box.BackgroundColor3 = Library.Theme.Accent
                    check.Position = UDim2.new(1, -17, 0.5, -7)
                end

                tgl.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then applyState(not s) end
                end)

                table.insert(Refresher, function() tgl.BackgroundColor3 = Library.Theme.ElementBackground; lbl.TextColor3 = Library.Theme.Text end)

                return {
                    Set = function(self, newState) applyState(newState) end,
                    Get = function(self) return s end
                }
            end

            -- ═══ SLIDER ═══
            function SectionLogic:CreateSlider(text, tooltip, min, max, defaultVal, callback)
                -- Support old API: CreateSlider(text, min, max, default, callback)
                if type(tooltip) == "number" then callback = defaultVal; defaultVal = max; max = min; min = tooltip; tooltip = nil end

                local sld = Instance.new("Frame", SubPage)
                sld.BackgroundColor3 = Library.Theme.ElementBackground; sld.Size = UDim2.new(1, -10, 0, 50)
                Instance.new("UICorner", sld).CornerRadius = UDim.new(0, 4)
                local sstroke = AddStroke(sld, Color3.fromRGB(45, 45, 45), 0.8)

                sld.MouseEnter:Connect(function()
                    Tween(sstroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent, Transparency = 0.4})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)
                sld.MouseLeave:Connect(function()
                    Tween(sstroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 45, 45), Transparency = 0.6})
                    HideTooltip()
                end)

                local lbl = Instance.new("TextLabel", sld)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 5); lbl.Size = UDim2.new(1, -70, 0, 20)
                lbl.Font = Enum.Font.Gotham; lbl.Text = text; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

                local bg = Instance.new("Frame", sld)
                bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); bg.Position = UDim2.new(0, 12, 0, 30); bg.Size = UDim2.new(1, -75, 0, 6)
                Instance.new("UICorner", bg)

                local fill = Instance.new("Frame", bg)
                fill.BackgroundColor3 = Library.Theme.Accent; fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
                Instance.new("UICorner", fill)

                local inputBox = Instance.new("TextBox", sld)
                inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35); inputBox.Position = UDim2.new(1, -55, 0, 22); inputBox.Size = UDim2.new(0, 45, 0, 22)
                inputBox.Font = Enum.Font.Gotham; inputBox.Text = tostring(defaultVal); inputBox.TextColor3 = Library.Theme.Text; inputBox.TextSize = 12
                Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)
                AddStroke(inputBox, Color3.fromRGB(50, 50, 50), 0.8)

                local active = false
                local currentVal = defaultVal
                local function applyValue(val)
                    currentVal = math.clamp(math.floor(val), min, max)
                    local m = (currentVal - min) / (max - min)
                    fill.Size = UDim2.new(m, 0, 1, 0)
                    inputBox.Text = tostring(currentVal)
                    if callback then callback(currentVal) end
                end

                inputBox.FocusLost:Connect(function()
                    local n = tonumber(inputBox.Text)
                    if n then applyValue(n) else inputBox.Text = tostring(currentVal) end
                end)

                local function update()
                    local m = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    applyValue(min + (max - min) * m)
                end

                bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = true; update() end end)
                UserInputService.InputChanged:Connect(function(i) if active and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end)

                table.insert(Refresher, function() fill.BackgroundColor3 = Library.Theme.Accent; lbl.TextColor3 = Library.Theme.Text end)

                return {
                    Set = function(self, value) applyValue(value) end,
                    Get = function(self) return currentVal end
                }
            end

            -- ═══ DROPDOWN (Searchable) ═══
            function SectionLogic:CreateDropdown(text, tooltip, options, default, callback)
                -- Support old API: CreateDropdown(text, options, default, callback)
                if type(tooltip) == "table" then callback = default; default = options; options = tooltip; tooltip = nil end

                local dpd = Instance.new("Frame", SubPage)
                dpd.BackgroundColor3 = Library.Theme.ElementBackground; dpd.Size = UDim2.new(1, -10, 0, 35)
                Instance.new("UICorner", dpd).CornerRadius = UDim.new(0, 4)
                local dstroke = AddStroke(dpd, Color3.fromRGB(45, 45, 45), 0.8)
                dpd.ClipsDescendants = true

                dpd.MouseEnter:Connect(function() if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end end)
                dpd.MouseLeave:Connect(function() HideTooltip() end)

                local lbl = Instance.new("TextLabel", dpd)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -60, 0, 35)
                lbl.Font = Enum.Font.Gotham; lbl.Text = text .. " (" .. tostring(default) .. ")"; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

                local arrow = Instance.new("TextLabel", dpd)
                arrow.BackgroundTransparency = 1; arrow.Position = UDim2.new(1, -30, 0, 0); arrow.Size = UDim2.new(0, 30, 0, 35)
                arrow.Font = Enum.Font.GothamBold; arrow.Text = ">"; arrow.TextColor3 = Library.Theme.TextDark; arrow.TextSize = 14

                local listFrame = Instance.new("Frame", dpd)
                listFrame.Name = "OptionList"; listFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                listFrame.Position = UDim2.new(0, 5, 0, 40); listFrame.Size = UDim2.new(1, -10, 0, 120); listFrame.Visible = false; listFrame.BackgroundTransparency = 0.1
                Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 4)
                AddStroke(listFrame, Color3.fromRGB(50, 50, 50), 0.8)

                local searchBox = Instance.new("TextBox", listFrame)
                searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); searchBox.Position = UDim2.new(0, 5, 0, 5); searchBox.Size = UDim2.new(1, -10, 0, 25)
                searchBox.Font = Enum.Font.Gotham; searchBox.PlaceholderText = "Search..."; searchBox.Text = ""; searchBox.TextColor3 = Library.Theme.Text; searchBox.TextSize = 12
                Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

                local scroll = Instance.new("ScrollingFrame", listFrame)
                scroll.BackgroundTransparency = 1; scroll.Position = UDim2.new(0, 0, 0, 35); scroll.Size = UDim2.new(1, 0, 1, -40); scroll.ScrollBarThickness = 2; scroll.ScrollBarImageColor3 = Library.Theme.Accent
                local slist = Instance.new("UIListLayout", scroll); slist.Padding = UDim.new(0, 2)

                local isOpen = false
                local currentOption = default
                local optionButtons = {}

                local function refreshOptions(filter)
                    for _, b in pairs(optionButtons) do
                        b.Visible = (filter == nil or filter == "" or b.Name:lower():find(filter:lower()))
                    end
                    scroll.CanvasSize = UDim2.new(0, 0, 0, slist.AbsoluteContentSize.Y + 5)
                end

                local function addOption(val)
                    local opt = Instance.new("TextButton", scroll)
                    opt.Name = val; opt.BackgroundColor3 = Color3.fromRGB(30, 30, 30); opt.Size = UDim2.new(1, -4, 0, 28)
                    opt.Font = Enum.Font.Gotham; opt.Text = val; opt.TextColor3 = Library.Theme.TextDark; opt.TextSize = 12
                    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 4)

                    opt.MouseButton1Click:Connect(function()
                        currentOption = val
                        lbl.Text = text .. " (" .. val .. ")"
                        isOpen = false
                        dpd:TweenSize(UDim2.new(1, -10, 0, 35), "Out", "Quart", 0.3, true)
                        listFrame.Visible = false
                        Tween(arrow, TweenInfo.new(0.3), {Rotation = 0})
                        if callback then callback(val) end
                    end)
                    table.insert(optionButtons, opt)
                end

                for _, v in pairs(options or {}) do addOption(v) end
                refreshOptions()

                searchBox:GetPropertyChangedSignal("Text"):Connect(function() refreshOptions(searchBox.Text) end)

                dpd.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        isOpen = not isOpen
                        listFrame.Visible = isOpen
                        dpd:TweenSize(isOpen and UDim2.new(1, -10, 0, 165) or UDim2.new(1, -10, 0, 35), "Out", "Quart", 0.3, true)
                        Tween(arrow, TweenInfo.new(0.3), {Rotation = isOpen and 90 or 0})
                        if isOpen then refreshOptions() end
                    end
                end)

                table.insert(Refresher, function() dpd.BackgroundColor3 = Library.Theme.ElementBackground; lbl.TextColor3 = Library.Theme.Text end)

                local DropdownLogic = {}
                function DropdownLogic:SetOptions(newOptions)
                    for _, b in pairs(optionButtons) do b:Destroy() end
                    optionButtons = {}
                    for _, v in pairs(newOptions) do addOption(v) end
                    refreshOptions()
                end
                function DropdownLogic:Add(val) addOption(val); refreshOptions() end
                function DropdownLogic:Clear()
                    for _, b in pairs(optionButtons) do b:Destroy() end
                    optionButtons = {}
                    refreshOptions()
                end
                function DropdownLogic:Set(val)
                    currentOption = val
                    lbl.Text = text .. " (" .. val .. ")"
                    if callback then callback(val) end
                end
                function DropdownLogic:Get() return currentOption end
                return DropdownLogic
            end

            -- ═══ MULTI DROPDOWN ═══
            function SectionLogic:CreateMultiDropdown(text, tooltip, options, defaultTable, callback)
                if type(tooltip) == "table" then callback = defaultTable; defaultTable = options; options = tooltip; tooltip = nil end

                local dpd = Instance.new("Frame", SubPage)
                dpd.BackgroundColor3 = Library.Theme.ElementBackground; dpd.Size = UDim2.new(1, -10, 0, 35)
                Instance.new("UICorner", dpd).CornerRadius = UDim.new(0, 4)
                local dstroke = AddStroke(dpd, Color3.fromRGB(45, 45, 45), 0.8)
                dpd.ClipsDescendants = true

                dpd.MouseEnter:Connect(function() if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end end)
                dpd.MouseLeave:Connect(function() HideTooltip() end)

                local lbl = Instance.new("TextLabel", dpd)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -60, 0, 35)
                lbl.Font = Enum.Font.Gotham; lbl.Text = text .. " (Multi)"; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

                local arrow = Instance.new("TextLabel", dpd)
                arrow.BackgroundTransparency = 1; arrow.Position = UDim2.new(1, -30, 0, 0); arrow.Size = UDim2.new(0, 30, 0, 35)
                arrow.Font = Enum.Font.GothamBold; arrow.Text = ">"; arrow.TextColor3 = Library.Theme.TextDark; arrow.TextSize = 14

                local listFrame = Instance.new("Frame", dpd)
                listFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24); listFrame.Position = UDim2.new(0, 5, 0, 40); listFrame.Size = UDim2.new(1, -10, 0, 120); listFrame.Visible = false; listFrame.BackgroundTransparency = 0.1
                Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 4)
                AddStroke(listFrame, Color3.fromRGB(50, 50, 50), 0.8)

                local searchBox = Instance.new("TextBox", listFrame)
                searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); searchBox.Position = UDim2.new(0, 5, 0, 5); searchBox.Size = UDim2.new(1, -10, 0, 25)
                searchBox.Font = Enum.Font.Gotham; searchBox.PlaceholderText = "Search..."; searchBox.Text = ""; searchBox.TextColor3 = Library.Theme.Text; searchBox.TextSize = 12
                Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

                local scroll = Instance.new("ScrollingFrame", listFrame)
                scroll.BackgroundTransparency = 1; scroll.Position = UDim2.new(0, 0, 0, 35); scroll.Size = UDim2.new(1, 0, 1, -40); scroll.ScrollBarThickness = 2; scroll.ScrollBarImageColor3 = Library.Theme.Accent
                local slist = Instance.new("UIListLayout", scroll); slist.Padding = UDim.new(0, 2)

                local isOpen = false
                local selected = {}
                for _, v in pairs(defaultTable or {}) do selected[v] = true end

                local optionButtons = {}
                local function refreshOptions(filter)
                    for _, b in pairs(optionButtons) do
                        b.Visible = (filter == nil or filter == "" or b.Name:lower():find(filter:lower()))
                    end
                    scroll.CanvasSize = UDim2.new(0, 0, 0, slist.AbsoluteContentSize.Y + 5)
                end

                local function addOption(val)
                    local opt = Instance.new("TextButton", scroll)
                    opt.Name = val; opt.BackgroundColor3 = Color3.fromRGB(30, 30, 30); opt.Size = UDim2.new(1, -4, 0, 28)
                    opt.Font = Enum.Font.Gotham; opt.Text = val; opt.TextColor3 = selected[val] and Library.Theme.Accent or Library.Theme.TextDark; opt.TextSize = 12
                    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 4)

                    opt.MouseButton1Click:Connect(function()
                        selected[val] = not selected[val]
                        opt.TextColor3 = selected[val] and Library.Theme.Accent or Library.Theme.TextDark
                        local out = {}
                        for k, v in pairs(selected) do if v then table.insert(out, k) end end
                        if callback then callback(out) end
                    end)
                    table.insert(optionButtons, opt)
                end

                for _, v in pairs(options or {}) do addOption(v) end
                refreshOptions()

                searchBox:GetPropertyChangedSignal("Text"):Connect(function() refreshOptions(searchBox.Text) end)

                dpd.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        isOpen = not isOpen
                        listFrame.Visible = isOpen
                        dpd:TweenSize(isOpen and UDim2.new(1, -10, 0, 165) or UDim2.new(1, -10, 0, 35), "Out", "Quart", 0.3, true)
                        Tween(arrow, TweenInfo.new(0.3), {Rotation = isOpen and 90 or 0})
                        if isOpen then refreshOptions() end
                    end
                end)

                table.insert(Refresher, function() dpd.BackgroundColor3 = Library.Theme.ElementBackground; lbl.TextColor3 = Library.Theme.Text end)

                return {
                    SetOptions = function(self, newOptions)
                        for _, b in pairs(optionButtons) do b:Destroy() end
                        optionButtons = {}
                        for _, v in pairs(newOptions) do addOption(v) end
                        refreshOptions()
                    end,
                    Get = function(self)
                        local out = {}
                        for k, v in pairs(selected) do if v then table.insert(out, k) end end
                        return out
                    end
                }
            end

            -- ═══ KEYBIND ═══
            function SectionLogic:CreateKeybind(text, tooltip, defaultKey, callback)
                -- Support old API: CreateKeybind(text, defaultKey, callback)
                if typeof(tooltip) == "EnumItem" then callback = defaultKey; defaultKey = tooltip; tooltip = nil end

                local kbd = Instance.new("Frame", SubPage)
                kbd.BackgroundColor3 = Library.Theme.ElementBackground; kbd.Size = UDim2.new(1, -10, 0, 35)
                Instance.new("UICorner", kbd).CornerRadius = UDim.new(0, 4)
                local kstroke = AddStroke(kbd, Color3.fromRGB(45, 45, 45), 0.8)

                kbd.MouseEnter:Connect(function()
                    Tween(kstroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent, Transparency = 0.4})
                    if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end
                end)
                kbd.MouseLeave:Connect(function()
                    Tween(kstroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 45, 45), Transparency = 0.6})
                    HideTooltip()
                end)

                local lbl = Instance.new("TextLabel", kbd)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -60, 1, 0)
                lbl.Font = Enum.Font.Gotham; lbl.Text = text; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

                local keyLbl = Instance.new("TextLabel", kbd)
                keyLbl.BackgroundTransparency = 1; keyLbl.Position = UDim2.new(1, -70, 0, 0); keyLbl.Size = UDim2.new(0, 60, 1, 0)
                keyLbl.Font = Enum.Font.GothamBold; keyLbl.Text = defaultKey.Name; keyLbl.TextColor3 = Library.Theme.Accent; keyLbl.TextSize = 13; keyLbl.TextXAlignment = Enum.TextXAlignment.Right

                local currentKey = defaultKey
                local binding = false

                local function applyKey(newKey)
                    currentKey = newKey
                    keyLbl.Text = currentKey.Name
                end

                kbd.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        binding = true
                        keyLbl.Text = "..."
                    end
                end)

                UserInputService.InputBegan:Connect(function(i, gpe)
                    if binding and i.UserInputType == Enum.UserInputType.Keyboard then
                        binding = false
                        applyKey(i.KeyCode)
                    elseif not binding and not gpe and i.KeyCode == currentKey then
                        if callback then callback(currentKey) end
                    end
                end)

                table.insert(Refresher, function() kbd.BackgroundColor3 = Library.Theme.ElementBackground; keyLbl.TextColor3 = Library.Theme.Accent end)

                return {
                    Set = function(self, newKey) applyKey(newKey) end,
                    Get = function(self) return currentKey end
                }
            end

            -- ═══ TEXT INPUT ═══
            function SectionLogic:CreateTextBox(text, tooltip, placeholder, callback)
                local frame = Instance.new("Frame", SubPage)
                frame.BackgroundColor3 = Library.Theme.ElementBackground; frame.Size = UDim2.new(1, -10, 0, 35)
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
                AddStroke(frame, Color3.fromRGB(45, 45, 45), 0.8)

                local lbl = Instance.new("TextLabel", frame)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(0.5, -12, 1, 0)
                lbl.Font = Enum.Font.Gotham; lbl.Text = text; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left

                local inputBox = Instance.new("TextBox", frame)
                inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); inputBox.Position = UDim2.new(0.5, 5, 0.5, -12); inputBox.Size = UDim2.new(0.5, -15, 0, 24)
                inputBox.Font = Enum.Font.Gotham; inputBox.PlaceholderText = placeholder or ""; inputBox.Text = ""; inputBox.TextColor3 = Library.Theme.Text; inputBox.TextSize = 12
                Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 4)

                frame.MouseEnter:Connect(function() if tooltip then ShowTooltip(tooltip, UserInputService:GetMouseLocation()) end end)
                frame.MouseLeave:Connect(function() HideTooltip() end)

                inputBox.FocusLost:Connect(function()
                    if callback then callback(inputBox.Text) end
                end)

                return {
                    Set = function(self, val) inputBox.Text = val end,
                    Get = function(self) return inputBox.Text end
                }
            end

            -- ═══ LABEL ═══
            function SectionLogic:CreateLabel(text)
                local lbl = Instance.new("TextLabel", SubPage)
                lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1, -10, 0, 25)
                lbl.Font = Enum.Font.Gotham; lbl.Text = text; lbl.TextColor3 = Library.Theme.TextDark; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

                return {
                    Set = function(self, newText) lbl.Text = newText end,
                    Get = function(self) return lbl.Text end
                }
            end

            -- ═══ SEPARATOR ═══
            function SectionLogic:CreateSeparator()
                local sep = Instance.new("Frame", SubPage)
                sep.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                sep.Size = UDim2.new(1, -10, 0, 1)
                sep.BorderSizePixel = 0
            end

            SubPageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SubPage.CanvasSize = UDim2.new(0, 0, 0, SubPageList.AbsoluteContentSize.Y + 10)
            end)

            return SectionLogic
        end

        return PageLogic
    end

    return WindowLogic
end

return Library
