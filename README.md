# Nexus UI Library

A modern, simplistic, and fluid UI library for Roblox exploit scripts. Designed with sleek visuals, smooth animations, and an easy-to-use API.

## 📥 Loading the Library

You can load the library directly from the GitHub repository using `loadstring`:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()
```

---

## 🎨 Configuration & Theming (Optional)

You can completely customize the look of the library before creating a window. You can modify colors, corner roundness, and change the keybind that toggles the UI.

```lua
-- Change the toggle key (Default: RightControl)
Library:SetToggleKey(Enum.KeyCode.RightShift)

-- Fully customize the theme
Library:SetTheme({
    MainBackground = Color3.fromRGB(15, 15, 15),     -- Main window background
    SidebarBackground = Color3.fromRGB(20, 20, 20),  -- Sidebar and notifications
    ElementBackground = Color3.fromRGB(22, 22, 22),  -- Background for elements like Sliders/Toggles
    ButtonBackground = Color3.fromRGB(30, 30, 30),   -- Background for buttons
    Accent = Color3.fromRGB(255, 100, 150),          -- Main accent color (Highlights, active states)
    Text = Color3.fromRGB(255, 255, 255),            -- Active text color
    TextDark = Color3.fromRGB(150, 150, 150),        -- Inactive text color
    CornerRadius = UDim.new(0, 6),                   -- UI roundness
    TitleSize = 22,                                  -- Size of the main title text
    TitleFont = Enum.Font.GothamBold                 -- Font of the main title text
})
```

---

## 🏗️ Creating a Window

To start building your UI, you need to create a main window.

```lua
local Window = Library:CreateWindow("My Script Hub")
```

---

## 📑 Creating Tabs

Tabs help you organize your features into different categories. You can pass an optional Decal ID for the tab icon.

```lua
-- Create a tab with an icon (10734949856 is an example asset ID)
local MainTab = Window:CreateTab("Combat", 10734949856)
local MiscTab = Window:CreateTab("Misc", 10734891102)
```

---

## 🧊 Creating Sections

Sections group UI elements together clearly inside a tab.

```lua
local AimbotSection = MainTab:CreateSection("Aimbot Settings")
local EspSection = MainTab:CreateSection("Visuals")
```

---

## 🎛️ Creating Elements

All elements must be created inside a **Section**.

### 🔘 Buttons
A simple clickable button that executes a function.

```lua
AimbotSection:CreateButton("Kill All", function()
    print("Kill All executed!")
end)
```

### ✅ Toggles
A switch that can be turned on or off. 
- *Arguments:* `Name`, `DefaultState`, `Callback`

```lua
AimbotSection:CreateToggle("Enable Aimbot", false, function(state)
    if state then
        print("Aimbot ON")
    else
        print("Aimbot OFF")
    end
end)
```

### 🎚️ Sliders
A draggable slider to select a number value.
- *Arguments:* `Name`, `MinValue`, `MaxValue`, `DefaultValue`, `Callback`

```lua
AimbotSection:CreateSlider("Aimbot Smoothing", 1, 10, 5, function(value)
    print("Smoothing set to:", value)
end)
```

### 📜 Dropdowns
A selection menu with multiple choices.
- *Arguments:* `Name`, `OptionsTable`, `DefaultSelection`, `Callback`

```lua
EspSection:CreateDropdown("ESP Color", {"Red", "Blue", "Pink"}, "Pink", function(selectedOption)
    print("Selected color:", selectedOption)
end)
```

### ⌨️ Keybinds
Allows the user to bind a custom key to a function.
- *Arguments:* `Name`, `DefaultKey`, `Callback`

```lua
AimbotSection:CreateKeybind("Aimbot Lock Key", Enum.KeyCode.RightMouseButton, function(keyCode)
    print("Aimbot key changed to:", keyCode.Name)
end)
```

---

## 🔔 Notifications

The library comes with a built-in notification system. You can call it anywhere in your code.
- *Arguments:* `Title`, `Message`, `Duration (seconds)`

```lua
Library:Notify("System", "Successfully loaded script!", 5)
```

---

## 📝 Example Script

Here is a full example combining all elements:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()

local Window = Library:CreateWindow("Nexus Hub")
Library:Notify("Success", "Welcome to Nexus Hub!", 4)

local CombatTab = Window:CreateTab("Combat", 10734949856)
local MainSection = CombatTab:CreateSection("Main Settings")

MainSection:CreateToggle("Enable Aimbot", false, function(state)
    print("Aimbot Enabled:", state)
end)

MainSection:CreateDropdown("Target Part", {"Head", "Torso"}, "Head", function(part)
    print("Targeting:", part)
end)

MainSection:CreateSlider("FOV Size", 10, 500, 100, function(size)
    print("FOV updated:", size)
end)

MainSection:CreateButton("Reset Config", function()
    Library:Notify("Config", "All settings have been reset.", 3)
end)
```
