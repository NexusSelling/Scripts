--[[
	SwiftUI Library for Roblox
	A professional, easy-to-use UI framework for Swift Scripts
	Version: 1.0.0
]]

local SwiftUI = {}
SwiftUI.__index = SwiftUI

-- ============================================================================
-- CONSTANTS & CONFIGURATION
-- ============================================================================

local DEFAULTS = {
	CornerRadius = 8,
	Padding = 12,
	BorderWidth = 1,
	AnimationSpeed = 0.3,
	FontSize = 14,
	FontFamily = Enum.Font.GothamMedium,
}

local COLORS = {
	Primary = Color3.fromRGB(0, 120, 215),
	Secondary = Color3.fromRGB(50, 50, 50),
	Success = Color3.fromRGB(76, 175, 80),
	Danger = Color3.fromRGB(244, 67, 54),
	Warning = Color3.fromRGB(255, 152, 0),
	Info = Color3.fromRGB(33, 150, 243),
	Dark = Color3.fromRGB(33, 33, 33),
	Light = Color3.fromRGB(245, 245, 245),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	TextDark = Color3.fromRGB(50, 50, 50),
	TextLight = Color3.fromRGB(220, 220, 220),
	Border = Color3.fromRGB(200, 200, 200),
	Transparent = Color3.fromRGB(0, 0, 0),
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function createRoundedFrame(parent, name, size, position, bgColor, cornerRadius)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = bgColor
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, cornerRadius or DEFAULTS.CornerRadius)
	corner.Parent = frame

	return frame
end

local function createText(parent, name, text, size, position, textColor, fontSize, fontFamily)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Text = text
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.TextColor3 = textColor or COLORS.TextDark
	label.TextSize = fontSize or DEFAULTS.FontSize
	label.Font = fontFamily or DEFAULTS.FontFamily
	label.TextWrapped = true
	label.Parent = parent

	return label
end

local function createButton(parent, name, text, size, position, bgColor, textColor, callback)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = bgColor or COLORS.Primary
	button.TextColor3 = textColor or COLORS.White
	button.TextSize = DEFAULTS.FontSize
	button.Font = DEFAULTS.FontFamily
	button.BorderSizePixel = 0
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
	corner.Parent = button

	if callback then
		button.MouseButton1Click:Connect(callback)
	end

	-- Hover effect
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = button.BackgroundColor3:lerp(COLORS.Black, 0.1)
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = bgColor or COLORS.Primary
	end)

	return button
end

-- ============================================================================
-- MAIN SWIFTUI CLASS
-- ============================================================================

function SwiftUI.new()
	local self = setmetatable({}, SwiftUI)
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "SwiftUI_ScreenGui"
	self.screenGui.ResetOnSpawn = false
	self.screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	self.panels = {}
	return self
end

-- ============================================================================
-- PANEL CREATION
-- ============================================================================

function SwiftUI:createPanel(name, size, position, bgColor)
	local panel = createRoundedFrame(
		self.screenGui,
		name,
		size or UDim2.new(0, 400, 0, 500),
		position or UDim2.new(0.5, -200, 0.5, -250),
		bgColor or COLORS.White
	)

	-- Add shadow effect
	local shadow = Instance.new("UIStroke")
	shadow.Color = COLORS.Border
	shadow.Thickness = DEFAULTS.BorderWidth
	shadow.Parent = panel

	local panelData = {
		instance = panel,
		children = {},
	}

	table.insert(self.panels, panelData)
	return panel
end

function SwiftUI:createTitle(parent, text, fontSize)
	return createText(
		parent,
		"Title",
		text,
		UDim2.new(1, -DEFAULTS.Padding * 2, 0, 30),
		UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
		COLORS.TextDark,
		fontSize or 24,
		Enum.Font.GothamBold
	)
end

function SwiftUI:createLabel(parent, text, size, position, fontSize)
	return createText(
		parent,
		"Label",
		text,
		size or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 40),
		position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
		COLORS.TextDark,
		fontSize or DEFAULTS.FontSize
	)
end

function SwiftUI:createButton(parent, text, size, position, bgColor, callback)
	local button = createButton(
		parent,
		text,
		text,
		size or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 40),
		position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
		bgColor or COLORS.Primary,
		COLORS.White,
		callback
	)
	return button
end

function SwiftUI:createInputBox(parent, placeholder, size, position)
	local inputFrame = createRoundedFrame(
		parent,
		"InputBox",
		size or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 40),
		position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
		COLORS.Light
	)

	local border = Instance.new("UIStroke")
	border.Color = COLORS.Border
	border.Thickness = DEFAULTS.BorderWidth
	border.Parent = inputFrame

	local textInput = Instance.new("TextBox")
	textInput.Name = "TextInput"
	textInput.Size = UDim2.new(1, -DEFAULTS.Padding, 1, 0)
	textInput.Position = UDim2.new(0, DEFAULTS.Padding / 2, 0, 0)
	textInput.BackgroundTransparency = 1
	textInput.TextColor3 = COLORS.TextDark
	textInput.PlaceholderColor3 = COLORS.Border
	textInput.PlaceholderText = placeholder or "Enter text..."
	textInput.TextSize = DEFAULTS.FontSize
	textInput.Font = DEFAULTS.FontFamily
	textInput.Parent = inputFrame

	return inputFrame, textInput
end

function SwiftUI:createToggle(parent, label, defaultValue, callback, size, position)
	local toggleFrame = createRoundedFrame(
		parent,
		"Toggle",
		size or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 40),
		position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
		COLORS.Light
	)

	local labelText = createText(
		toggleFrame,
		"Label",
		label,
		UDim2.new(0.7, 0, 1, 0),
		UDim2.new(0, DEFAULTS.Padding, 0, 0),
		COLORS.TextDark
	)

	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Size = UDim2.new(0, 50, 0, 25)
	toggleButton.Position = UDim2.new(1, -60, 0.5, -12.5)
	toggleButton.BackgroundColor3 = defaultValue and COLORS.Success or COLORS.Border
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = ""
	toggleButton.Parent = toggleFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = toggleButton

	local circle = Instance.new("Frame")
	circle.Name = "Circle"
	circle.Size = UDim2.new(0, 21, 0, 21)
	circle.Position = defaultValue and UDim2.new(0, 27, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
	circle.BackgroundColor3 = COLORS.White
	circle.BorderSizePixel = 0
	circle.Parent = toggleButton

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(0, 10)
	circleCorner.Parent = circle

	local isToggled = defaultValue

	toggleButton.MouseButton1Click:Connect(function()
		isToggled = not isToggled
		toggleButton.BackgroundColor3 = isToggled and COLORS.Success or COLORS.Border

		local targetPosition = isToggled and UDim2.new(0, 27, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
		local tween = game:GetService("TweenService"):Create(
			circle,
			TweenInfo.new(DEFAULTS.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = targetPosition }
		)
		tween:Play()

		if callback then
			callback(isToggled)
		end
	end)

	return toggleFrame, toggleButton, circle
end

function SwiftUI:createDropdown(parent, options, defaultIndex, callback, size, position)
	local dropdownFrame = createRoundedFrame(
		parent,
		"Dropdown",
		size or UDim2.new(1, -DEFAULTS.Padding * 2, 0, 40),
		position or UDim2.new(0, DEFAULTS.Padding, 0, DEFAULTS.Padding),
		COLORS.Light
	)

	local border = Instance.new("UIStroke")
	border.Color = COLORS.Border
	border.Thickness = DEFAULTS.BorderWidth
	border.Parent = dropdownFrame

	local selectedLabel = Instance.new("TextLabel")
	selectedLabel.Name = "SelectedLabel"
	selectedLabel.Size = UDim2.new(0.8, 0, 1, 0)
	selectedLabel.Position = UDim2.new(0, DEFAULTS.Padding, 0, 0)
	selectedLabel.BackgroundTransparency = 1
	selectedLabel.Text = options[defaultIndex or 1]
	selectedLabel.TextColor3 = COLORS.TextDark
	selectedLabel.TextSize = DEFAULTS.FontSize
	selectedLabel.Font = DEFAULTS.FontFamily
	selectedLabel.Parent = dropdownFrame

	local expandButton = Instance.new("TextButton")
	expandButton.Name = "ExpandButton"
	expandButton.Size = UDim2.new(0.2, 0, 1, 0)
	expandButton.Position = UDim2.new(0.8, 0, 0, 0)
	expandButton.BackgroundTransparency = 1
	expandButton.Text = "▼"
	expandButton.TextColor3 = COLORS.TextDark
	expandButton.TextSize = DEFAULTS.FontSize
	expandButton.Parent = dropdownFrame

	local dropdownList = Instance.new("Frame")
	dropdownList.Name = "DropdownList"
	dropdownList.Size = UDim2.new(1, 0, 0, #options * 35)
	dropdownList.Position = UDim2.new(0, 0, 1, 5)
	dropdownList.BackgroundColor3 = COLORS.White
	dropdownList.BorderSizePixel = 0
	dropdownList.Visible = false
	dropdownList.Parent = dropdownFrame

	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, DEFAULTS.CornerRadius)
	listCorner.Parent = dropdownList

	local listBorder = Instance.new("UIStroke")
	listBorder.Color = COLORS.Border
	listBorder.Thickness = DEFAULTS.BorderWidth
	listBorder.Parent = dropdownList

	for i, option in ipairs(options) do
		local optionButton = Instance.new("TextButton")
		optionButton.Name = "Option_" .. i
		optionButton.Size = UDim2.new(1, 0, 0, 35)
		optionButton.Position = UDim2.new(0, 0, 0, (i - 1) * 35)
		optionButton.BackgroundColor3 = COLORS.White
		optionButton.BorderSizePixel = 0
		optionButton.Text = option
		optionButton.TextColor3 = COLORS.TextDark
		optionButton.TextSize = DEFAULTS.FontSize
		optionButton.Font = DEFAULTS.FontFamily
		optionButton.Parent = dropdownList

		optionButton.MouseButton1Click:Connect(function()
			selectedLabel.Text = option
			dropdownList.Visible = false
			if callback then
				callback(i, option)
			end
		end)

		optionButton.MouseEnter:Connect(function()
			optionButton.BackgroundColor3 = COLORS.Light
		end)

		optionButton.MouseLeave:Connect(function()
			optionButton.BackgroundColor3 = COLORS.White
		end)
	end

	expandButton.MouseButton1Click:Connect(function()
		dropdownList.Visible = not dropdownList.Visible
	end)

	return dropdownFrame, dropdownList, selectedLabel
end

-- ============================================================================
-- ANIMATION & EFFECTS
-- ============================================================================

function SwiftUI:animate(instance, properties, duration, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(
		duration or DEFAULTS.AnimationSpeed,
		easingStyle or Enum.EasingStyle.Quad,
		easingDirection or Enum.EasingDirection.Out
	)
	local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

function SwiftUI:fadeIn(instance, duration)
	instance.BackgroundTransparency = 1
	return self:animate(instance, { BackgroundTransparency = 0 }, duration or DEFAULTS.AnimationSpeed)
end

function SwiftUI:fadeOut(instance, duration)
	instance.BackgroundTransparency = 0
	return self:animate(instance, { BackgroundTransparency = 1 }, duration or DEFAULTS.AnimationSpeed)
end

-- ============================================================================
-- UTILITY METHODS
-- =====================================================================
