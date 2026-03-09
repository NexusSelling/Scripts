# Nexus UI Library

A modern, simplistic, and fluid UI library for Roblox exploit scripts. Designed with sleek visuals, smooth animations, and an easy-to-use API.

## ✨ Features
- **Highly Customizable:** Change colors, borders, titles, and keybinds on the fly.
- **Fluid Animations:** Smooth tweening for tabs, elements, and notifications.
- **Save-State Ready:** Methods like `:Set()` and `:Get()` to programmatically manage UI state.
- **Smart Notification System:** Stacking notifications that automatically sort and cap at a maximum number to prevent screen clutter.

## 🚀 Requirements & Supported Executors
The Nexus Library relies on standard Roblox CoreGui injections. It is tested and verified to work on:
- **Nexus Executor**
- **Synapse X** / **Script-Ware** (Legacy standard)
- Most generic Level 7+ executors that support `loadstring`, `game:HttpGet()`, and `CoreGui` parent manipulation.

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
    TitleFont = Enum.Font.GothamBold,                -- Font of the main title text
    NotificationTransparency = 0                     -- Transparency of the notification frames (0 = solid, 1 = invisible)
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
*(Performance Tip: It's recommended to keep it under 30-40 elements per section to ensure extremely smooth UI rendering and scrolling.)*

```lua
local AimbotSection = MainTab:CreateSection("Aimbot Settings")
local EspSection = MainTab:CreateSection("Visuals")
```

---

## 🎛️ Creating Elements

All elements must be created inside a **Section**. 
**Important Note on Callbacks:** All `callback` arguments in every element are **optional**. You can pass `nil` or leave them out entirely.
**Returned Objects:** Almost every `Create` method returns an object containing `:Set(value)` and `:Get()` functions so you can programmatically read/change the element's state later!

### 🔘 Buttons
A simple clickable button that executes a function. (Does not return an object, as buttons are stateless and cannot store a value.)

```lua
AimbotSection:CreateButton("Kill All", function()
    print("Kill All executed!")
end)
```

### ✅ Toggles
A switch that can be turned on or off. Returns a Toggle Object.
- *Arguments:* `Name`, `DefaultState`, `Callback`

```lua
local AimbotToggle = AimbotSection:CreateToggle("Enable Aimbot", false, function(state)
    print("Aimbot ON:", state)
end)

-- You can safely read or update the toggle programmatically later!
-- AimbotToggle:Set(true) -- Changes toggle visually to ON and fires callback
-- local isAimbotEnabled = AimbotToggle:Get() -- Returns true/false
```

### 🎚️ Sliders
A draggable slider to select a number value. Returns a Slider Object.
- *Arguments:* `Name`, `MinValue`, `MaxValue`, `DefaultValue`, `Callback`

```lua
local SmoothSlider = AimbotSection:CreateSlider("Aimbot Smoothing", 1, 10, 5, function(value)
    print("Smoothing set to:", value)
end)

-- SmoothSlider:Set(8) 
-- local currentSmoothness = SmoothSlider:Get()
```

### 📜 Dropdowns
A selection menu with multiple choices. Returns a Dropdown Object.
- *Arguments:* `Name`, `OptionsTable`, `DefaultSelection`, `Callback`

```lua
local ColorDropdown = EspSection:CreateDropdown("ESP Color", {"Red", "Blue", "Pink"}, "Pink", function(selectedOption)
    print("Selected color:", selectedOption)
end)

-- ColorDropdown:Set("Blue")
-- local colorInfo = ColorDropdown:Get()
```

### ⌨️ Keybinds
Allows the user to bind a custom key. The callback fires automatically **every time the user presses the currently bound key**. Returns a Keybind Object.
- *Arguments:* `Name`, `DefaultKey`, `Callback`

```lua
local AimbotKeybind = AimbotSection:CreateKeybind("Aimbot Lock Key", Enum.KeyCode.E, function()
    print("The Aimbot key was just pressed!")
end)

-- You can trigger it programmatically or change the bound key later:
-- AimbotKeybind:Set(Enum.KeyCode.Q)
-- local boundKey = AimbotKeybind:Get() -- returns Enum.KeyCode.Q
```

---

## 🔔 Notifications

The library comes with a built-in interactive notification system. You can call it anywhere in your code.
Notifications will **automatically stack upwards** and are **capped at a maximum of 5** active notifications at a time to prevent screen clutter.

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

---

## 🛠️ Troubleshooting

**"The UI doesn't open / nothing happens when I run the script."**
- Check your external executor's developer console (F9) for script errors.
- Ensure your executor supports `game:HttpGet` and doesn't block loading raw strings from GitHub.

**"The notifications aren't showing up!"**
- Make sure you inject into a game, not the main Roblox menu. `CoreGui` access is required.

**"My callback isn't firing on load!"**
- Elements do not auto-fire their callbacks on creation. If you want a default state to apply immediately in your script's logic, call `Element:Set(defaultValue)` manually after creating it.

---

## 📅 Changelog

**v1.1.0**
- Added `:Set()` and `:Get()` object returns on all elements.
- Upgraded the Notification System to stack dynamically and cap at 5 active alerts.
- Added fully customizable title text size and font configurations (`TitleSize`, `TitleFont`).
- Keybinds now automatically listen for keyboard input and fire the callback without manual loops.

**v1.0.0**
- Initial Release of Nexus Library structure.
- Basic tabs, dropdowns, toggles, buttons, sliders.

---

## ⚖️ License

This project is intended for educational purposes and personal scripting utility. 
You are free to use it, branch it, and adapt it into your own scripts. Mentioning the original **Nexus** library in your script hubs is appreciated but not required.
