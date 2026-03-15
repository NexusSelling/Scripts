# Nexus UI Library — v1.4.0

A professional, feature-rich UI library for Roblox exploit scripting. Built for clean aesthetics, smooth animations, and serious customization.

---

## Table of Contents

1. [Installation](#-installation)
2. [Key System](#-key-system)
3. [Loading Screen](#-loading-screen)
4. [Theming](#-theming)
5. [Window, Tabs & Sections](#-window-tabs--sections)
6. [Elements](#-elements)
   - [Button](#-button)
   - [Toggle](#-toggle)
   - [Slider](#-slider)
   - [Dropdown](#-dropdown-searchable)
   - [Multi Dropdown](#-multi-selection-dropdown)
   - [Keybind](#-keybind)
   - [TextBox](#-textbox)
   - [Label](#-label)
   - [Separator](#-separator)
7. [Notifications](#-notifications)
8. [Full Example Script](#-full-example-script)
9. [Changelog](#-changelog)

---

## 📦 Installation

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()
```

Or load locally inside an executor:
```lua
local Library = loadstring(readfile("AmbaniLibrary.lua"))()
```

---

## 🔑 Key System

Gate your script behind a key. Shows a compact centered card with an input field, confirm button, and optional "Get Key" link. **The function blocks (yields) until the user enters a valid key or runs out of attempts.**

```lua
local valid = Library:CreateKeySystem({
    Title = "Nexus Hub",                       -- Card title
    Subtitle = "Paste your key below",         -- Description text
    Keys = {"nexus-abc123", "vip-forever"},    -- List of accepted keys
    KeyLink = "https://link-to-get-key.com",   -- URL copied when "Get Key" is clicked
    MaxAttempts = 5,                           -- 0 = unlimited attempts
    AccentColor = Color3.fromRGB(0, 170, 255), -- Button & border color

    OnSuccess = function()
        print("Key accepted, script loading...")
    end,
    OnFail = function()
        print("Too many failed attempts")
        -- optionally kick: game.Players.LocalPlayer:Kick("Invalid key")
    end,
})

-- `valid` is true if the key was correct, false if UI was destroyed/failed
if not valid then return end
```

### Config Options

| Parameter | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Key System"` | Card header |
| `Subtitle` | string | `"Enter your key to continue"` | Description below title |
| `Keys` | table | `{}` | Table of valid key strings |
| `KeyLink` | string | `nil` | URL copied to clipboard via "Get Key" button |
| `MaxAttempts` | number | `0` | Max wrong attempts before auto-close (0 = unlimited) |
| `AccentColor` | Color3 | Theme Accent | Color for confirm button and border |
| `OnSuccess` | function | `nil` | Called after valid key + fade-out |
| `OnFail` | function | `nil` | Called after max attempts exceeded |

### What happens visually
- ✅ **Valid key:** Card turns green, fades out, script continues.
- ❌ **Invalid key:** Card shakes, red error message shown.
- 🔗 **Get Key:** Copies `KeyLink` to clipboard, shows confirmation.
- 🚫 **Max attempts:** Shows error, auto-closes after 1.5 seconds.

---

## 🎬 Loading Screen

A compact centered card with a progress bar. Use it right after the key system (or standalone).

```lua
Library:CreateLoadingScreen({
    Title = "Nexus Hub",
    Subtitle = "Initializing...",
    Duration = 3,
    AccentColor = Color3.fromRGB(0, 170, 255),
    LogoIcon = 12345678,  -- optional rbxassetid number
    Steps = {"Connecting...", "Loading modules...", "Ready!"},
})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Nexus"` | Title text |
| `Subtitle` | string | `"Loading..."` | Subtitle text |
| `Duration` | number | `3` | Total time in seconds |
| `AccentColor` | Color3 | Theme Accent | Bar color |
| `BackgroundColor` | Color3 | `(10,10,10)` | Card color |
| `LogoIcon` | number | `nil` | rbxassetid for logo image |
| `Steps` | table | `{}` | Status text per step (duration split evenly) |

If `Steps` is empty, a smooth continuous bar plays for `Duration` seconds.

---

## 🎨 Theming

Customize colors **at setup** or **live at runtime** (all elements update instantly).

```lua
-- Set initial theme
Library:SetTheme({
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
    NotificationTransparency = 0,
})

-- Live-update any property at runtime (elements refresh immediately)
Library:ChangeTheme({
    Accent = Color3.fromRGB(0, 200, 100),
})
```

You only need to pass the keys you want to change — others stay the same.

---

## 📑 Window, Tabs & Sections

Every UI needs this basic structure: **Window → Tab → Section**. Elements live inside Sections.

```lua
-- The window is the main frame (draggable via sidebar)
local Window = Library:CreateWindow("My Hub")

-- Tabs appear in the sidebar
local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")

-- Sections are sub-pages within a tab (shown as top-bar buttons)
local AimbotSection = CombatTab:CreateSection("Aimbot")
local MiscSection = CombatTab:CreateSection("Misc")
```

Toggle UI visibility: press **Right Control** (default), or change it:
```lua
Library:SetToggleKey(Enum.KeyCode.RightShift)
```

---

## 🎛️ Elements

> **All elements support an optional `tooltip` parameter.** If you don't need it, just skip it — old API calls still work. All stateful elements return `:Set(value)` and `:Get()`.

---

### 🔘 Button

Runs a function when clicked. Brief accent flash on click.

```lua
-- With tooltip
Section:CreateButton("Kill All", "Eliminates all enemies", function()
    print("Clicked!")
end)

-- Without tooltip (old API)
Section:CreateButton("Kill All", function()
    print("Clicked!")
end)
```

---

### ✅ Toggle

On/off switch with smooth slide animation. Returns current state via callback.

```lua
local flyToggle = Section:CreateToggle("Fly", "Toggle flight mode", false, function(enabled)
    print("Fly:", enabled)
end)

-- Control it from code
flyToggle:Set(true)
print(flyToggle:Get()) -- true
```

---

### 🎚️ Slider

Drag to set a value, or type directly into the number box on the right.

```lua
local speedSlider = Section:CreateSlider("Speed", "Walk speed", 16, 500, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

-- Control it from code
speedSlider:Set(100)
print(speedSlider:Get()) -- 100
```

---

### 📜 Dropdown (Searchable)

Select one option from a list. Includes a built-in search bar for filtering.

```lua
local dd = Section:CreateDropdown("Target Part", "Which body part to aim at", {"Head", "Torso", "Random"}, "Head", function(selected)
    print("Targeting:", selected)
end)

-- Dynamic updates
dd:SetOptions({"Head", "Torso", "LeftArm", "RightArm"})  -- replace all
dd:Add("LeftLeg")                                          -- add one
dd:Clear()                                                 -- remove all
dd:Set("Torso")                                            -- select programmatically
print(dd:Get())                                            -- "Torso"
```

---

### 📋 Multi-Selection Dropdown

Select multiple options. Shows accent color for active selections.

```lua
Section:CreateMultiDropdown("ESP Targets", "What to highlight", 
    {"Players", "Items", "Vehicles", "NPCs"}, 
    {"Players"},  -- default selections
    function(selected)
        -- selected is a table like {"Players", "Vehicles"}
        for _, v in pairs(selected) do print(v) end
    end
)
```

---

### ⌨️ Keybind

Click to rebind, then press any key. Auto-fires callback when bound key is pressed.

```lua
local kb = Section:CreateKeybind("Toggle Menu", "Change the toggle key", Enum.KeyCode.RightControl, function(key)
    print("Keybind pressed:", key.Name)
end)

-- Control it from code
kb:Set(Enum.KeyCode.F5)
print(kb:Get().Name) -- "F5"
```

---

### 📝 TextBox

Text input field with a label. Fires callback on focus lost (Enter or click away).

```lua
local nameBox = Section:CreateTextBox("Username", "Target player name", "Enter name...", function(text)
    print("Entered:", text)
end)

nameBox:Set("Player1")
print(nameBox:Get()) -- "Player1"
```

---

### 🏷️ Label

Simple text display. Useful for status info or section headers.

```lua
local status = Section:CreateLabel("Status: Idle")
status:Set("Status: Running")
print(status:Get()) -- "Status: Running"
```

---

### ─── Separator

A thin horizontal line to visually divide element groups.

```lua
Section:CreateSeparator()
```

---

## 🔔 Notifications

Pop-up notifications that stack, auto-sort, and cap at 5 max.

```lua
Library:Notify("Success", "Script loaded successfully!", 5)
Library:Notify("Warning", "Low FPS detected", 3)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `title` | string | required | Bold header text |
| `text` | string | required | Description text |
| `duration` | number | `3` | Seconds before auto-dismiss |

---

## 📋 Full Example Script

A complete script showing the recommended order of operations:

```lua
-- 1. Load the library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()

-- 2. Set your theme
Library:SetTheme({
    Accent = Color3.fromRGB(0, 170, 255),
    MainBackground = Color3.fromRGB(12, 12, 12),
})

-- 3. Key system (blocks until valid key)
local valid = Library:CreateKeySystem({
    Title = "My Script",
    Subtitle = "Enter key to unlock",
    Keys = {"free-key-2026", "premium-xyz"},
    KeyLink = "https://your-key-site.com",
    MaxAttempts = 3,
})
if not valid then return end

-- 4. Loading screen
Library:CreateLoadingScreen({
    Title = "My Script",
    Subtitle = "v1.0",
    Duration = 2.5,
    Steps = {"Connecting...", "Loading...", "Done!"},
})

-- 5. Build the UI
local Window = Library:CreateWindow("My Script")
local MainTab = Window:CreateTab("Main")
local Section = MainTab:CreateSection("Features")

Section:CreateToggle("Speed Hack", "Increase walk speed", false, function(on)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = on and 100 or 16
end)

Section:CreateSlider("Jump Power", nil, 50, 500, 50, function(val)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
end)

Section:CreateSeparator()

Section:CreateButton("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

-- 6. Notify
Library:Notify("Ready", "Script loaded!", 3)
```

---

## 📅 Changelog

### v1.4.0
- **New:** `CreateKeySystem()` — full key validation UI with multi-key, max attempts, shake animation, clipboard link
- Improved README with full examples and better docs

### v1.3.0
- **Bugfix:** Fixed critical `nil value` crash from broken merge
- **New:** `CreateLoadingScreen()` with customizable step-based progress
- **New:** `CreateTextBox()`, `CreateLabel()`, `CreateSeparator()`
- Backward-compatible API (tooltip parameter is optional)

### v1.2.0
- Visual overhaul: `UIStroke` borders, hover transitions on all elements
- Searchable Dropdowns, Multi-Selection, Dynamic Theme, Tooltips, Slider TextBox input

### v1.1.0
- `:Set()` / `:Get()` on all elements, stacking notifications, keybind auto-listen

### v1.0.0
- Initial release

---

*Nexus UI Library — Professional exploit UI.*
