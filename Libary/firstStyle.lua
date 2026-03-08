local Library = {
    CurrentTab = nil,
    Tabs = {}
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function Tween(obj, info, goal)
    local tween = TweenService:Create(obj, info, goal)
    tween:Play()
    return tween
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
    
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 6)

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
    PageContainer.Position = UDim2.new(0, 160, 0, 0) -- Starts right after Sidebar
    PageContainer.Size = UDim2.new(1, -160, 1, 0)

    -- Dragging
    local dragging, dragInput, dragStart, startPos
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
        local TabButton = Instance.new("TextButton")
        TabButton.Parent = TabContainer
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 0, 38)
        TabButton.Text = ""

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Parent = TabButton
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position = UDim2.new(0, 35, 0, 0)
        TabLabel.Size = UDim2.new(1, -35, 1, 0)
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.Text = name
        TabLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabLabel.TextSize = 14
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left

        local Highlight = Instance.new("Frame")
        Highlight.Parent = TabButton
        Highlight.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
        Highlight.Position = UDim2.new(0, 0, 0, 5)
        Highlight.Size = UDim2.new(0, 3, 1, -10)
        Highlight.Transparency = 1

        local Page = Instance.new("Frame")
        Page.Parent = PageContainer
        Page.BackgroundTransparency = 1
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false

        -- TOP BAR FOR SUB-TABS (Die "Dinger" oben)
        local TopBar = Instance.new("ScrollingFrame")
        TopBar.Name = "TopBar"
        TopBar.Parent = Page
        TopBar.BackgroundTransparency = 1
        TopBar.BorderSizePixel = 0
        TopBar.Position = UDim2.new(0, 10, 0, 10)
        TopBar.Size = UDim2.new(1, -20, 0, 35)
        TopBar.ScrollBarThickness = 0
        TopBar.CanvasSize = UDim2.new(0, 0, 0, 0)
        TopBar.ScrollingDirection = Enum.ScrollingDirection.X
        
        local TopBarList = Instance.new("UIListLayout", TopBar)
        TopBarList.FillDirection = Enum.FillDirection.Horizontal
        TopBarList.Padding = UDim.new(0, 15)

        local SubPageContainer = Instance.new("Frame")
        SubPageContainer.Parent = Page
        SubPageContainer.BackgroundTransparency = 1
        SubPageContainer.Position = UDim2.new(0, 10, 0, 50)
        SubPageContainer.Size = UDim2.new(1, -20, 1, -60)

        local SubTabs = {}

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Library.Tabs) do t.Page.Visible = false; t.Highlight.Transparency = 1; t.Label.TextColor3 = Color3.fromRGB(150,150,150) end
            Page.Visible = true; Highlight.Transparency = 0; TabLabel.TextColor3 = Color3.fromRGB(255,255,255)
        end)

        table.insert(Library.Tabs, {Page = Page, Label = TabLabel, Highlight = Highlight})
        if #Library.Tabs == 1 then Page.Visible = true; Highlight.Transparency = 0; TabLabel.TextColor3 = Color3.fromRGB(255,255,255) end

        local PageLogic = {}

        function PageLogic:CreateSection(sectionName)
            local SubTabButton = Instance.new("TextButton")
            SubTabButton.Parent = TopBar
            SubTabButton.BackgroundTransparency = 1
            SubTabButton.Font = Enum.Font.GothamSemibold
            SubTabButton.Text = sectionName
            SubTabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
            SubTabButton.TextSize = 13
            SubTabButton.Size = UDim2.new(0, 0, 1, 0)
            SubTabButton.AutomaticSize = Enum.AutomaticSize.X

            local SubPage = Instance.new("ScrollingFrame")
            SubPage.Parent = SubPageContainer
            SubPage.BackgroundTransparency = 1
            SubPage.Size = UDim2.new(1, 0, 1, 0)
            SubPage.Visible = false
            SubPage.ScrollBarThickness = 1
            local SubPageList = Instance.new("UIListLayout", SubPage)
            SubPageList.Padding = UDim.new(0, 8)

            SubTabButton.MouseButton1Click:Connect(function()
                for _, st in pairs(SubTabs) do
                    st.Page.Visible = false
                    Tween(st.Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)})
                end
                SubPage.Visible = true
                Tween(SubTabButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)})
            end)

            table.insert(SubTabs, {Page = SubPage, Btn = SubTabButton})
            if #SubTabs == 1 then SubPage.Visible = true; SubTabButton.TextColor3 = Color3.fromRGB(255,255,255) end

            local SectionLogic = {}

            function SectionLogic:CreateButton(text, callback)
                local btn = Instance.new("TextButton", SubPage)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.Size = UDim2.new(1, -10, 0, 35)
                btn.Font = Enum.Font.GothamSemibold
                btn.Text = text
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.TextSize = 13
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                btn.MouseButton1Click:Connect(callback)
            end

            function SectionLogic:CreateToggle(text, callback)
                local tgl = Instance.new("Frame", SubPage)
                tgl.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                tgl.Size = UDim2.new(1, -10, 0, 40)
                Instance.new("UICorner", tgl).CornerRadius = UDim.new(0, 4)
                local lbl = Instance.new("TextLabel", tgl)
                lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0); lbl.Size = UDim2.new(1, -60, 1, 0)
                lbl.Font = Enum.Font.Gotham; lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(200, 200, 200); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
                local box = Instance.new("Frame", tgl)
                box.BackgroundColor3 = Color3.fromRGB(40, 40, 40); box.Position = UDim2.new(1, -45, 0.5, -10); box.Size = UDim2.new(0, 35, 0, 20)
                Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)
                local check = Instance.new("Frame", box)
                check.BackgroundColor3 = Color3.fromRGB(255, 255, 255); check.Position = UDim2.new(0, 3, 0.5, -7); check.Size = UDim2.new(0, 14, 0, 14)
                Instance.new("UICorner", check).CornerRadius = UDim.new(1, 0)
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
