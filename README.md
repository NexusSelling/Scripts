# Nexus UI Library (v1.3.0)

A professional-grade, fluid, and feature-rich UI library for Roblox exploit development. Premium aesthetics, advanced controls, and full customization.

## ✨ Key Features
- **Premium Visuals:** `UIStroke` borders + smooth `TweenService` hover effects on all elements
- **Searchable Dropdowns:** Real-time filtering with `:SetOptions()`, `:Add()`, `:Clear()`
- **Multi-Selection:** Multi-select dropdowns for complex settings (e.g., ESP filters)
- **Universal Tooltips:** Hover descriptions on every element (optional)
- **Smart Sliders:** Manual `TextBox` input for precise values
- **Dynamic Themes:** Live theme updates via `Library:ChangeTheme()`
- **Loading Screen:** Customizable animated loading screen with progress steps
- **Backward Compatible:** Old API calls (without tooltip) still work

---

## 🚀 Loading the Library

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()
```

---

## 🎬 Loading Screen

Show a professional loading animation before your UI appears. Fully customizable.

```lua
Library:CreateLoadingScreen({
    Title = "Nexus Hub",
    Subtitle = "Initializing...",
    Duration = 4,
    AccentColor = Color3.fromRGB(0, 170, 255),
    BackgroundColor = Color3.fromRGB(10, 10, 10),
    LogoIcon = 12345678,  -- optional Roblox Asset ID
    Steps = {"Connecting...", "Loading modules...", "Verifying...", "Ready!"}
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | string | `"Nexus"` | Main title text |
| `Subtitle` | string | `"Loading..."` | Subtitle below title |
| `Duration` | number | `3` | Total loading time (seconds) |
| `AccentColor` | Color3 | Theme Accent | Progress bar color |
| `BackgroundColor` | Color3 | `(10,10,10)` | Background color |
| `LogoIcon` | number | `nil` | Optional image asset ID |
| `Steps` | table | `{}` | Status text per step |

---

## 🎨 Theming

```lua
-- Initial setup
Library:SetTheme({ Accent = Color3.fromRGB(0, 170, 255) })

-- Live update (all elements refresh instantly)
Library:ChangeTheme({ Accent = Color3.fromRGB(255, 100, 150) })
```

---

## 📑 Core Structure

```lua
local Window = Library:CreateWindow("My Hub")
local Tab = Window:CreateTab("Combat", 10734949856)
local Section = Tab:CreateSection("Aimbot")
```

---

## 🎛️ Elements

> **Tooltip parameter is always optional.** Old API calls without tooltip still work.
> All elements with state return `:Set(value)` and `:Get()`.

### 🔘 Button
```lua
Section:CreateButton("Kill All", "Tooltip description", function()
    print("Clicked!")
end)
```

### ✅ Toggle
```lua
local toggle = Section:CreateToggle("Fly", "Fly through walls", false, function(state)
    print("Fly:", state)
end)
```

### 🎚️ Slider (with Direct Input)
```lua
local slider = Section:CreateSlider("Speed", "Movement speed", 16, 250, 16, function(val)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
end)
```

### 📜 Dropdown (Searchable)
```lua
local dd = Section:CreateDropdown("Target", "Pick a target", {"Head", "Torso"}, "Head", function(val)
    print(val)
end)
dd:SetOptions({"NewA", "NewB"})  -- dynamic update
dd:Add("NewC")                    -- add single option
dd:Clear()                        -- remove all options
```

### 📋 Multi-Selection Dropdown
```lua
Section:CreateMultiDropdown("ESP", "What to highlight", {"Players", "Items", "Vehicles"}, {"Players"}, function(selected)
    for _, v in pairs(selected) do print(v) end
end)
```

### ⌨️ Keybind
```lua
Section:CreateKeybind("Toggle", "Toggle key", Enum.KeyCode.RightControl, function()
    print("Key pressed!")
end)
```

### 📝 Text Input
```lua
local tb = Section:CreateTextBox("Name", "Enter a name", "placeholder...", function(text)
    print("Entered:", text)
end)
```

### 🏷️ Label
```lua
local label = Section:CreateLabel("Status: Idle")
label:Set("Status: Active")
```

### ─── Separator
```lua
Section:CreateSeparator()
```

---

## 🔔 Notifications
```lua
Library:Notify("Success", "Script loaded!", 5)
```

---

## 📅 Changelog

**v1.3.0**
- **Bugfix:** Fixed critical `nil value` crash from broken merge
- **New:** `CreateLoadingScreen()` with full customization and step-based progress
- **New:** `CreateTextBox()`, `CreateLabel()`, `CreateSeparator()`
- **New:** Backward-compatible API (tooltip parameter is optional)

**v1.2.0**
- Visual overhaul with `UIStroke` borders and hover transitions
- Searchable Dropdowns, Multi-Selection, Dynamic Theme, Tooltips, Slider input

**v1.1.0**
- `:Set()` / `:Get()` on all elements, stacking notifications, keybind auto-listen

**v1.0.0**
- Initial release

---

## ⚖️ License
Educational purposes only. Original branding: **Nexus UI Library**.
