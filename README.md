# Nexus UI Library (v1.2.0)

A professional-grade, fluid, and feature-rich UI library for Roblox exploit development. Engineered for maximum performance, premium aesthetics, and advanced functional control.

## ✨ Key Overhaul Features
- **Premium Aesthetics:** Integrated `UIStroke` borders and smooth `TweenService` hover/active states.
- **Dynamic Dropdowns:** Searchable lists with real-time updates (`:SetOptions()`).
- **Multi-Selection:** Intelligent multi-select dropdowns for complex settings (e.g., ESP Filters).
- **Universal Tooltips:** Sleek hover-based descriptions for every UI element.
- **Smart Sliders:** Integrated manual `TextBox` input for pixel-perfect value control.
- **Real-time Theming:** Change the entire UI appearance on the fly with `Library:ChangeTheme()`.

---

## 🚀 Loading the Library

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NexusSelling/Scripts/refs/heads/main/Libary/firstStyle.lua"))()
```

---

## 🎨 Professional Configuration

### Dynamic Theme Support
You can now update the theme even after the UI is loaded! All active elements will refresh instantly.

```lua
-- Initial Setup
Library:SetTheme({
    Accent = Color3.fromRGB(0, 170, 255),
    MainBackground = Color3.fromRGB(15, 15, 15)
})

-- Dynamic Update (e.g., from a button)
Library:ChangeTheme({
    Accent = Color3.fromRGB(255, 100, 150)
})
```

---

## 📑 Core Structure

### Creating a Window
```lua
local Window = Library:CreateWindow("Nexus Professional")
```

### Creating Tabs & Sections
```lua
local Tab = Window:CreateTab("Combat", 10734949856)
local Section = Tab:CreateSection("Aimbot")
```

---

## 🎛️ Advanced Elements

### 🔘 Buttons
- `Section:CreateButton(Text, Tooltip, Callback)`
```lua
Section:CreateButton("Kill All", "Instantly eliminates all players in range", function()
    print("Action executed")
end)
```

### ✅ Toggles
- `Section:CreateToggle(Text, Tooltip, Default, Callback)`
```lua
local FlyToggle = Section:CreateToggle("Fly", "Allows you to fly through the air", false, function(s)
    print("Fly:", s)
end)
```

### 🎚️ Sliders (with Direct Input)
- `Section:CreateSlider(Text, Tooltip, Min, Max, Default, Callback)`
- Includes a manual input box for precise values.
```lua
Section:CreateSlider("WalkSpeed", "Change your movement speed", 16, 250, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)
```

### 📜 Searchable Dropdowns
- `Section:CreateDropdown(Text, Tooltip, OptionsTable, Default, Callback)`
- **Methods:** `:SetOptions(newTable)`, `:Add(option)`, `:Clear()`, `:Set(val)`, `:Get()`
```lua
local PlayerList = Section:CreateDropdown("Target Player", "Select a player to focus", {"Player1"}, "Player1", function(v) end)
PlayerList:SetOptions({"NewPlayer1", "NewPlayer2"})
```

### 📋 Multi-Selection Dropdowns
- `Section:CreateMultiDropdown(Text, Tooltip, OptionsTable, DefaultTable, Callback)`
```lua
Section:CreateMultiDropdown("ESP Filters", "Select which entities to highlight", {"Players", "Items", "Vehicles"}, {"Players"}, function(selected)
    for _, v in pairs(selected) do print("Selected:", v) end
end)
```

### ⌨️ Keybinds
- `Section:CreateKeybind(Text, Tooltip, DefaultKey, Callback)`
```lua
Section:CreateKeybind("Toggle Menu", "Key to hide/show the UI", Enum.KeyCode.RightControl, function() end)
```

---

## 🔔 Professional Notifications
Notifications stack dynamically and support custom transparency.
```lua
Library:Notify("Success", "Nexus Library Overhaul Loaded", 5)
```

---

## 📅 Professional Changelog (v1.2.0)
- **Visual Overhaul:** Added `UIStroke` borders and improved hover transitions.
- **Search Logic:** Implemented real-time filtering for all dropdown types.
- **Dynamic Updates:** Added `:SetOptions()`, `:Add()`, and `:Clear()` to Dropdowns.
- **Input System:** Added manual TextBox input to Sliders.
- **UX Improvements:** Universal Tooltip system for detailed feature explanations.
- **Theme Engine:** New `Refresher` system for `:ChangeTheme()` support.

---

## ⚖️ License
Educational purposes only. Original branding: **Nexus UI Library**.
