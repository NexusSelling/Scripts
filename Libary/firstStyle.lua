local Library = {
    CurrentTab = nil,
    Tabs = {},
    Enabled = true,
    ToggleKey = Enum.KeyCode.RightControl
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

-- Notification System
function Library:Notify(title, text, duration)
    local NotifyGui = CoreGui:FindFirstChild("AmbaniNotifications")
    if not NotifyGui then
        NotifyGui = Instance.new("ScreenGui", CoreGui)
        NotifyGui.Name = "AmbaniNotifications"
    end

    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Parent = NotifyGui
    NotificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    NotificationFrame.Size = UDim2.new(0, 250, 0, 60)
    NotificationFrame.Position = UDim2.new(1, 10, 1, -70) -- Start outside
    NotificationFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotificationFrame).CornerRadius = UDim.new(0, 6)
    
    local Accent = Instance.new("Frame", NotificationFrame)
    Accent.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    Accent.Size = UDim2.new(0, 3, 1, 0)
    Instance.new("UICorner", Accent)

    local Title = Instance.new("TextLabel", NotificationFrame)
    Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 12, 0, 8); Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Font = Enum.Font.GothamBold; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.TextSize = 14; Title.Text = title; Title.TextXAlignment = Enum.TextXAlignment.Left

    local Desc = Instance.new("TextLabel", NotificationFrame)
    Desc.BackgroundTransparency = 1; Desc.Position = UDim2.new(0, 12, 0, 28); Desc.Size = UDim2.new(1, -20, 0, 20)
    Desc.Font = Enum.Font.Gotham; Desc.TextColor3 = Color3.fromRGB(180, 180, 180); Desc.TextSize = 12; Desc.Text = text; Desc.TextXAlignment = Enum.TextXAlignment.Left

    -- Anim
    Tween(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(1, -260, 1, -70)})
    task.delay(duration or 3, function()
        Tween(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 10, 1, -70)})
        task.wait(0.5)
        NotificationFrame:Destroy()
    end)
end

function Library:CreateWindow(hubName)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AmbaniStyleUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 1 -- Start hidden for anim
    
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 6)
    
    -- Open Animation
    Tween(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {BackgroundTransparency = 0})

    -- Toggle Keybind
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

    -- SIDEBAR
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Parent = Sidebar
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Position = UDim2.new(0, 15, 0, 15)
    LogoLabel.Size = UDim2.new(1, -30, 0, 30)
    LogoLabel.Font = Enum.Font.GothamBold
    LogoLabel.Text = hubName
    LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoLabel.TextSize = 22
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

    -- Ziehen
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
        TabLabel.Font = Enum.Font.GothamSemibold; TabLabel.Text = name; TabLabel.TextColor3 = Color3.fromRGB(150, 150, 150); TabLabel.TextSize = 14; TabLabel.TextXAlignment = Enum.TextXAlignment.Left

        local Highlight = Instance.new("Frame", TabButton)
        Highlight.BackgroundColor3 = Color3.fromRGB(255, 100, 150); Highlight.Position = UDim2.new(0, 0, 0, 5); Highlight.Size = UDim2.new(0, 3, 1, -10); Highlight.Transparency = 1

        local Page = Instance.new("Frame", PageContainer)
        Page.BackgroundTransparency = 1; Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false

        local TopBar = Instance.new("ScrollingFrame", Page)
        TopBar.BackgroundTransparency = 1; TopBar.Position = UDim2.new(0, 10, 0, 10); TopBar.Size = UDim2.new(1, -20, 0, 35); TopBar.ScrollBarThickness = 0; TopBar.CanvasSize = UDim2.new(0,0,0,0); TopBar.ScrollingDirection = Enum.ScrollingDirection.X
        local TopBarList = Instance.new("UIListLayout", TopBar); TopBarList.FillDirection = Enum.FillDirection.Horizontal; TopBarList.Padding = UDim.new(0, 15)

        local SubPageContainer = Instance.new("Frame", Page)
        SubPageContainer.BackgroundTransparency = 1; SubPageContainer.Position = UDim2.new(0, 10, 0, 50); SubPageContainer.Size = UDim2.new(1, -20, 1, -60)

        local SubTabs = {}

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Library.Tabs) do t.Page.Visible = false; t.Highlight.Transparency = 1; t.Label.TextColor3 = Color3.fromRGB(150,150,150) end
            Page.Visible = true; Highlight.Transparency = 0; TabLabel.TextColor3 = Color3.fromRGB(255,255,255)
            -- Anim Tab switch
            Page.GroupTransparency = 1
            Tween(Page, TweenInfo.new(0.3), {GroupTransparency = 0})
        end)

        table.insert(Library.Tabs, {Page = Page, Label = TabLabel, Highlight = Highlight})
        if #Library.Tabs == 1 then Page.Visible = true; Highlight.Transparency = 0; TabLabel.TextColor3 = Color3.fromRGB(255,255,255) end

        local PageLogic = {}
        function PageLogic:CreateSection(sectionName)
            local SubTabButton = Instance.new("TextButton", TopBar)
            SubTabButton.BackgroundTransparency = 1; SubTabButton.Font = Enum.Font.GothamSemibold; SubTabButton.Text = sectionName; SubTabButton.TextColor3 = Color3.fromRGB(150, 150, 150); SubTabButton.TextSize = 13; SubTabButton.Size = UDim2.new(0, 0, 1, 0); SubTabButton.AutomaticSize = Enum.AutomaticSize.X

            local SubPage = Instance.new("ScrollingFrame", SubPageContainer)
            SubPage.BackgroundTransparency = 1; SubPage.Size = UDim2.new(1, 0, 1, 0); SubPage.Visible = false; SubPage.ScrollBarThickness = 1
            local SubPageList = Instance.new("UIListLayout", SubPage); SubPageList.Padding = UDim.new(0, 8)

            SubTabButton.MouseButton1Click:Connect(function()
                for _, st in pairs(SubTabs) do st.Page.Visible = false; Tween(st.Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}) end
                SubPage.Visible = true; Tween(SubTabButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)})
            end)

            table.insert(SubTabs, {Page = SubPage, Btn = SubTabButton})
            if #SubTabs == 1 then SubPage.Visible = true; SubTabButton.TextColor3 = Color3.fromRGB(255,255,255) end

            local SectionLogic = {}
            function SectionLogic:CreateButton(text, callback)
                local btn = Instance.new("TextButton", SubPage)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn.Size = UDim2.new(1, -10, 0, 35); btn.Font = Enum.Font.GothamSemibold; btn.Text = text; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextSize = 13; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 100, 150)})
                    task.wait(0.1)
                    Tween(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                    callback()
                end)
            end

            function SectionLogic:CreateToggle(text, callback)
                local tgl = Instance.new("Frame", SubPage)
                tgl.BackgroundColor3 = Color3.fromRGB(22, 22, 22); tgl.Size = UDim2.new(1, -10, 0, 40); Instance.new("UICorner", tgl).CornerRadius = UDim.new(0, 4)
                local lbl = Instance.new("TextLabel", tgl)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Font = Enum.Font.Gotham; lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 200); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
                local box = Instance.new("Frame", tgl)
                box.BackgroundColor3 = Color3.fromRGB(40, 40, 40); box.Position = UDim2.new(1, -45, 0.5, -10); box.Size = UDim2.new(0, 35, 0, 20); Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)
                local check = Instance.new("Frame", box)
                check.BackgroundColor3 = Color3.fromRGB(255, 255, 255); check.Position = UDim2.new(0, 3, 0.5, -7); check.Size = UDim2.new(0, 14, 0, 14); Instance.new("UICorner", check).CornerRadius = UDim.new(1, 0)
                local s = false
                tgl.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        s = not s
                        Tween(box, TweenInfo.new(0.2), {BackgroundColor3 = s and Color3.fromRGB(255, 100, 150) or Color3.fromRGB(40, 40, 40)})
                        Tween(check, TweenInfo.new(0.2), {Position = s and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
                        callback(s)
                    end
                end)
            end

            function SectionLogic:CreateSlider(text, min, max, default, callback)
                local sld = Instance.new("Frame", SubPage)
                sld.BackgroundColor3 = Color3.fromRGB(22, 22, 22); sld.Size = UDim2.new(1, -10, 0, 50); Instance.new("UICorner", sld).CornerRadius = UDim.new(0, 4)
                local lbl = Instance.new("TextLabel", sld); lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 5); lbl.Size = UDim2.new(1, -20, 0, 20); lbl.Font = Enum.Font.Gotham; lbl.Text = text .. ": " .. default; lbl.TextColor3 = Color3.fromRGB(200, 200, 200); lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
                local bg = Instance.new("Frame", sld); bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); bg.Position = UDim2.new(0, 12, 0, 30); bg.Size = UDim2.new(1, -24, 0, 6); Instance.new("UICorner", bg)
                local fill = Instance.new("Frame", bg); fill.BackgroundColor3 = Color3.fromRGB(255, 100, 150); fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0); Instance.new("UICorner", fill)
                local active = false
                local function update()
                    local m = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * m)
                    lbl.Text = text .. ": " .. val; fill.Size = UDim2.new(m, 0, 1, 0); callback(val)
                end
                bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = true; update() end end)
                UserInputService.InputChanged:Connect(function(i) if active and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end)
            end

            SubPageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SubPage.CanvasSize = UDim2.new(0, 0, 0, SubPageList.AbsoluteContentSize.Y + 10) end)
            return SectionLogic
        end
        return PageLogic
    end
    return WindowLogic
end

return Library
