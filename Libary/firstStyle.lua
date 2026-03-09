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
        TitleFont = Enum.Font.GothamBold
    }
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local function Tween(obj, info, goal)
    local tween = TweenService:Create(obj, info, goal)
    tween:Play()
    return tween
end

function Library:SetTheme(cfg)
    if type(cfg) == "table" then
        for k, v in pairs(cfg) do
            if Library.Theme[k] then
                Library.Theme[k] = v
            end
        end
    end
end

function Library:SetToggleKey(key)
    if typeof(key) == "EnumItem" then
        Library.ToggleKey = key
    end
end

local ActiveNotifications = {}
local MAX_NOTIFICATIONS = 5

-- Notification System
function Library:Notify(title, text, duration)
    local NotifyGui = CoreGui:FindFirstChild("NexusLibraryNotifications")
    if not NotifyGui then
        NotifyGui = Instance.new("ScreenGui", CoreGui)
        NotifyGui.Name = "NexusLibraryNotifications"
    end

    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Parent = NotifyGui
    NotificationFrame.BackgroundColor3 = Library.Theme.SidebarBackground
    NotificationFrame.Size = UDim2.new(0, 250, 0, 60)
    NotificationFrame.Position = UDim2.new(1, 10, 1, -70) -- Start outside
    NotificationFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotificationFrame).CornerRadius = Library.Theme.CornerRadius
    
    local Accent = Instance.new("Frame", NotificationFrame)
    Accent.BackgroundColor3 = Library.Theme.Accent
    Accent.Size = UDim2.new(0, 3, 1, 0)
    Instance.new("UICorner", Accent)

    local Title = Instance.new("TextLabel", NotificationFrame)
    Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 12, 0, 8); Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Font = Enum.Font.GothamBold; Title.TextColor3 = Library.Theme.Text; Title.TextSize = 14; Title.Text = title; Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", NotificationFrame)
    Desc.BackgroundTransparency = 1; Desc.Position = UDim2.new(0, 12, 0, 28); Desc.Size = UDim2.new(1, -20, 0, 20)
    Desc.Font = Enum.Font.Gotham; Desc.TextColor3 = Library.Theme.TextDark; Desc.TextSize = 12; Desc.Text = text; Desc.TextXAlignment = Enum.TextXAlignment.Left

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
    
    Tween(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {BackgroundTransparency = 0})

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Enabled = not Library.Enabled
            MainFrame.Visible = Library.Enabled
            if Library.Enabled then
                MainFrame.Size = UDim2.new(0,0,0,0)
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
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

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
        TopBar.BackgroundTransparency = 1; TopBar.Position = UDim2.new(0, 10, 0, 10); TopBar.Size = UDim2.new(1, -20, 0, 35); TopBar.ScrollBarThickness = 0; TopBar.CanvasSize = UDim2.new(0,0,0,0); TopBar.ScrollingDirection = Enum.ScrollingDirection.X
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
            function SectionLogic:CreateButton(text, callback)
                local btn = Instance.new("TextButton", SubPage)
                btn.BackgroundColor3 = Library.Theme.ButtonBackground; btn.Size = UDim2.new(1, -10, 0, 35); btn.Font = Enum.Font.GothamSemibold; btn.Text = text; btn.TextColor3 = Library.Theme.Text; btn.TextSize = 13; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Accent})
                    task.wait(0.1)
                    Tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ButtonBackground})
                    if callback then callback() end
                end)
            end

            function SectionLogic:CreateToggle(text, startState, callback)
                local tgl = Instance.new("Frame", SubPage)
                tgl.BackgroundColor3 = Library.Theme.ElementBackground; tgl.Size = UDim2.new(1, -10, 0, 40); Instance.new("UICorner", tgl).CornerRadius = UDim.new(0, 4)
                
                local lbl = Instance.new("TextLabel", tgl)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Font = Enum.Font.Gotham; lbl.Text = text; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local box = Instance.new("Frame", tgl)
                box.BackgroundColor3 = Color3.fromRGB(40, 40, 40); box.Position = UDim2.new(1, -45, 0.5, -10); box.Size = UDim2.new(0, 35, 0, 20); Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)
                
                local check = Instance.new("Frame", box)
                check.BackgroundColor3 = Library.Theme.Text; check.Position = UDim2.new(0, 3, 0.5, -7); check.Size = UDim2.new(0, 14, 0, 14); Instance.new("UICorner", check).CornerRadius = UDim.new(1, 0)
                
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
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        applyState(not s)
                    end
                end)

                return {
                    Set = function(self, newState) applyState(newState) end,
                    Get = function(self) return s end
                }
            end

            function SectionLogic:CreateSlider(text, min, max, defaultVal, callback)
                local sld = Instance.new("Frame", SubPage)
                sld.BackgroundColor3 = Library.Theme.ElementBackground; sld.Size = UDim2.new(1, -10, 0, 50); Instance.new("UICorner", sld).CornerRadius = UDim.new(0, 4)
                
                local lbl = Instance.new("TextLabel", sld); lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 5); lbl.Size = UDim2.new(1, -20, 0, 20); lbl.Font = Enum.Font.Gotham; lbl.Text = text .. ": " .. defaultVal; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local bg = Instance.new("Frame", sld); bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); bg.Position = UDim2.new(0, 12, 0, 30); bg.Size = UDim2.new(1, -24, 0, 6); Instance.new("UICorner", bg)
                local fill = Instance.new("Frame", bg); fill.BackgroundColor3 = Library.Theme.Accent; fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0); Instance.new("UICorner", fill)
                
                local active = false
                local currentVal = defaultVal
                local function applyValue(val)
                    currentVal = math.clamp(math.floor(val), min, max)
                    local m = (currentVal - min) / (max - min)
                    lbl.Text = text .. ": " .. currentVal; fill.Size = UDim2.new(m, 0, 1, 0)
                    if callback then callback(currentVal) end
                end

                local function update()
                    local m = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * m)
                    applyValue(val)
                end

                bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = true; update() end end)
                UserInputService.InputChanged:Connect(function(i) if active and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end)

                return {
                    Set = function(self, value) applyValue(value) end,
                    Get = function(self) return currentVal end
                }
            end
            
            function SectionLogic:CreateDropdown(text, options, default, callback)
                local dpd = Instance.new("Frame", SubPage)
                dpd.BackgroundColor3 = Library.Theme.ElementBackground; dpd.Size = UDim2.new(1, -10, 0, 35); Instance.new("UICorner", dpd).CornerRadius = UDim.new(0, 4)
                local lbl = Instance.new("TextLabel", dpd)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Font = Enum.Font.Gotham; lbl.Text = text .. " (" .. default .. ")"; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
                
                local index = 1
                local currentOption = default
                for i, v in ipairs(options) do if v == default then index = i break end end
                
                local function applyOption(val)
                    currentOption = val
                    lbl.Text = text .. " (" .. val .. ")"
                    if callback then callback(val) end
                end

                dpd.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        index = index + 1
                        if index > #options then index = 1 end
                        applyOption(options[index])
                    end
                end)

                return {
                    Set = function(self, val)
                        for i, v in ipairs(options) do if v == val then index = i; applyOption(val) break end end
                    end,
                    Get = function(self) return currentOption end
                }
            end
            
            function SectionLogic:CreateKeybind(text, defaultKey, callback)
                local kbd = Instance.new("Frame", SubPage)
                kbd.BackgroundColor3 = Library.Theme.ElementBackground; kbd.Size = UDim2.new(1, -10, 0, 35); Instance.new("UICorner", kbd).CornerRadius = UDim.new(0, 4)
                local lbl = Instance.new("TextLabel", kbd)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Font = Enum.Font.Gotham; lbl.Text = text; lbl.TextColor3 = Library.Theme.Text; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
                local keyLbl = Instance.new("TextLabel", kbd)
                keyLbl.BackgroundTransparency = 1; keyLbl.Position = UDim2.new(1, -70, 0, 0); keyLbl.Size = UDim2.new(0, 60, 1, 0); keyLbl.Font = Enum.Font.GothamBold; keyLbl.Text = defaultKey.Name; keyLbl.TextColor3 = Library.Theme.Accent; keyLbl.TextSize = 13; keyLbl.TextXAlignment = Enum.TextXAlignment.Right
                
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
                        -- Handle triggering logic here automatically
                        if callback then callback(currentKey) end
                    end
                end)

                return {
                    Set = function(self, newKey) applyKey(newKey) end,
                    Get = function(self) return currentKey end
                }
            end

            SubPageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SubPage.CanvasSize = UDim2.new(0, 0, 0, SubPageList.AbsoluteContentSize.Y + 10) end)
            return SectionLogic
        end
        return PageLogic
    end
    return WindowLogic
end

return Library
