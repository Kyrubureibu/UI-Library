# 🍎 Apple Library — V1

> **A macOS-inspired Roblox executor UI library**
> Made with ❤️ by **Kyrubureibu**

---

## 👤 About the Author — Kyrubureibu

Apple Library was created by **Kyrubureibu**, a Roblox developer passionate about clean,
modern UI design. Inspired by Apple's design language — frosted glass panels, smooth
animations, traffic-light window controls, and a minimal aesthetic — Kyrubureibu built
Apple Library to give Roblox executor scripts a professional, polished look that stands
out from generic UI libraries.

Apple Library V1 is the first public release, packed with more than a dozen interactive
elements, four built-in colour themes, a toast notification system, modal dialogs, and a
quick-start API so you can have a full GUI running in under 20 lines.

---

## 📦 What is Apple Library?

Apple Library is a **Lua UI library for Roblox executors** that lets you build beautiful,
interactive script GUIs without touching raw Instance code. It handles all the boilerplate —
ScreenGui creation, executor protection (`syn.protect_gui` / `gethui`), drag-to-move,
search filtering, smooth animations, and theming — so you can focus on your script logic.

### What it includes

| Category | Details |
|---|---|
| **Window system** | Draggable window with macOS traffic-light buttons (close / minimize / maximize) |
| **Sidebar** | Scrollable tab list with live search filtering |
| **Sections (tabs)** | Infinite scrollable content panels, one per sidebar tab |
| **Themes** | Light, Dark, Midnight, Rose — plus custom theme registration |
| **Toast notifications** | Floating slide-in toasts with a countdown progress bar |
| **Modal dialogs** | Single-button and two-button modal notifications |
| **Splash screen** | Optional animated loading screen on startup |
| **15+ elements** | Button, Switch, Slider, Dropdown, ColorPicker, Keybind, ProgressBar, MultiSwitch, NumericStepper, TextField, TextArea, Label, Divider, Badge, InfoCard, RichTextLabel, Image, Spacer, Separator |
| **Quick API** | `lib:Quick(config)` lets you build an entire GUI from one table |
| **MIT licensed** | Free to use, modify, and redistribute |

---

## 🚀 Getting Started

### Basic setup

```lua
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kyrubureibu/UI-Library/main/AppleLibrary.lua"))()

local win = lib:init(
    "My Script",         -- Window title
    true,                -- Show splash screen
    Enum.KeyCode.RightShift,  -- Key to toggle visibility
    true,                -- Delete previous GUI if found
    "Dark"               -- Theme: "Light" | "Dark" | "Midnight" | "Rose"
)

local mainTab = win:Section("Main")
mainTab:Select()  -- Make this the active tab on load

mainTab:Button("Say Hello", function()
    print("Hello from Apple Library!")
end)
```

---

## 🎨 Themes

Apple Library comes with four built-in themes.

| Theme | Description |
|---|---|
| `"Light"` | Clean white macOS-style (default) |
| `"Dark"` | Dark grey like macOS Dark Mode |
| `"Midnight"` | Deep navy / indigo with purple accents |
| `"Rose"` | Soft pinks with a rose accent colour |

### Switching themes

```lua
-- Set at init:
local win = lib:init("My Script", true, Enum.KeyCode.RightShift, true, "Dark")

-- Or set any time before lib:init:
lib:SetTheme("Midnight")
```

### Registering a custom theme

```lua
lib:RegisterTheme("Ocean", {
    Window       = Color3.fromRGB(10, 20, 40),
    WindowTrans  = 0.05,
    Sidebar      = Color3.fromRGB(10, 20, 40),
    Workarea     = Color3.fromRGB(15, 30, 55),
    TitleText    = Color3.fromRGB(200, 230, 255),
    PrimaryText  = Color3.fromRGB(200, 230, 255),
    SecondaryText= Color3.fromRGB(120, 160, 210),
    PlaceholderText = Color3.fromRGB(90, 120, 170),
    Accent       = Color3.fromRGB(0, 180, 220),
    AccentText   = Color3.fromRGB(255, 255, 255),
    ButtonBg     = Color3.fromRGB(20, 40, 70),
    InputBg      = Color3.fromRGB(20, 40, 70),
    SwitchOff    = Color3.fromRGB(40, 60, 90),
    SwitchOn     = Color3.fromRGB(0, 180, 220),
    SliderFill   = Color3.fromRGB(0, 180, 220),
    SliderTrack  = Color3.fromRGB(40, 60, 90),
    DropdownBg   = Color3.fromRGB(20, 40, 70),
    DropdownItem = Color3.fromRGB(15, 30, 55),
    Separator    = Color3.fromRGB(30, 55, 90),
    Progress     = Color3.fromRGB(0, 180, 220),
    ProgressBg   = Color3.fromRGB(40, 60, 90),
    Badge        = Color3.fromRGB(255, 69, 58),
    BadgeText    = Color3.fromRGB(255, 255, 255),
    CloseBtn     = Color3.fromRGB(254, 94, 86),
    MinBtn       = Color3.fromRGB(255, 189, 46),
    MaxBtn       = Color3.fromRGB(39, 200, 63),
    NotifBg      = Color3.fromRGB(15, 30, 55),
    NotifDarken  = Color3.fromRGB(0, 0, 0),
    ToastBg      = Color3.fromRGB(15, 30, 55),
    ToastTrans   = 0.05,
})

lib:SetTheme("Ocean")
```

---

## 🪟 Window Methods

After calling `lib:init(...)` you get a **window object** with these methods:

---

### `win:Section(name)` → `sec`

Creates a new sidebar tab and its associated content panel.

**Parameters:**
- `name` *(string)* — The label shown on the sidebar button.

**Returns:** A section object (`sec`) used to add elements.

```lua
local combatTab = win:Section("Combat")
local visualsTab = win:Section("Visuals")
local miscTab    = win:Section("Misc")

combatTab:Select()   -- Make Combat active by default
```

---

### `win:Divider(name)`

Adds a small grey category label inside the sidebar (above tab buttons).
Use it to visually group related tabs.

**Parameters:**
- `name` *(string)* — The category label text.

```lua
win:Divider("Settings")
local settingsTab = win:Section("General")

win:Divider("Features")
local aimbotTab = win:Section("Aimbot")
local espTab    = win:Section("ESP")
```

---

### `win:Notify(title, body, buttonText, icon, callback)`

Shows a single-button modal dialog in the centre of the window.
Blocks interaction with elements behind it.

**Parameters:**
- `title` *(string)* — Bold title text.
- `body` *(string)* — Descriptive message.
- `buttonText` *(string)* — Label for the confirm button (e.g. `"OK"`, `"Got it"`).
- `icon` *(string)* — Roblox asset ID for the icon image. Pass `nil` for default.
- `callback` *(function)* — Called when the button is pressed.

```lua
win:Notify(
    "Script Loaded",
    "Apple Library V1 has been successfully injected.",
    "Awesome!",
    "rbxassetid://4871684504",
    function()
        print("User acknowledged.")
    end
)
```

---

### `win:Notify2(title, body, btn1, btn2, icon, cb1, cb2)`

Shows a two-button modal (Yes/No style).

**Parameters:**
- `title` *(string)*
- `body` *(string)*
- `btn1` *(string)* — Primary button label.
- `btn2` *(string)* — Secondary button label.
- `icon` *(string)* — Roblox asset ID. Optional.
- `cb1` *(function)* — Called when btn1 is clicked.
- `cb2` *(function)* — Called when btn2 is clicked.

```lua
win:Notify2(
    "Reset Settings",
    "This will clear all your saved preferences. Continue?",
    "Yes, Reset",
    "Cancel",
    "rbxassetid://12608260095",
    function() resetAll() end,
    function() print("Cancelled") end
)
```

---

### `win:Toast(title, body, icon, duration)`

Shows a floating toast notification in the top-right corner.
Does **not** block the rest of the UI.
Multiple toasts stack automatically.

**Parameters:**
- `title` *(string)* — Bold title.
- `body` *(string)* — Body text.
- `icon` *(string)* — Roblox asset ID. Optional.
- `duration` *(number)* — Seconds before auto-dismiss. Default `5`.

```lua
win:Toast("ESP Enabled", "Players are now highlighted.", "rbxassetid://4871684504", 4)
```

You can also call toasts without a window:
```lua
lib:Toast("Ready", "Script injected successfully!", nil, 3)
```

---

### `win:SetTitle(text)`

Changes the window title bar text at any time.

```lua
win:SetTitle("My Script — v2.0")
```

---

### `win:GreenButton(callback)`

Assigns a callback to the green (rightmost) traffic-light button.
By default the green button does nothing.

```lua
win:GreenButton(function()
    toggleFullscreen()
end)
```

---

### `win:ToggleVisible()`

Programmatically shows or hides the window.
Same as pressing your `toggleKey`.

```lua
win:ToggleVisible()
```

---

### `win:Destroy()`

Destroys the entire GUI with a slide-out animation.

```lua
win:Destroy()
```

---

## 📋 Section Elements

All elements below are called on a **section object** returned by `win:Section(...)`.

---

### `sec:Button(name, description, callback)` → `obj`

A tappable button with an optional subtitle and a right-pointing arrow.
Pressing it fires your callback and plays a subtle pulse animation.

**Parameters:**
- `name` *(string)* — Button label.
- `description` *(string)* — Smaller subtitle text. Optional — pass `nil` to skip.
- `callback` *(function)* — Called when clicked. Runs in a coroutine so it won't freeze the UI.

**Returns:** `{ SetText(t), SetEnabled(b) }`

```lua
tab:Button("Teleport to Spawn", "Move to the game's spawn point", function()
    local char = game.Players.LocalPlayer.Character
    if char then
        char:MoveTo(Vector3.new(0, 5, 0))
    end
end)
```

```lua
-- Without a description:
tab:Button("Print Hello", function()
    print("Hello!")
end)
```

```lua
-- Control it later:
local btn = tab:Button("Do Thing", "This does a thing", callback)
btn:SetEnabled(false)   -- grey it out
btn:SetText("Did it!")  -- change the label
```

---

### `sec:Switch(name, description, default, callback)` → `obj`

An iOS-style toggle switch (pill + sliding thumb).
Tapping anywhere on the row or the pill itself toggles the state.

**Parameters:**
- `name` *(string)* — Label.
- `description` *(string)* — Subtitle. Optional.
- `default` *(boolean)* — `true` = ON, `false` = OFF.
- `callback` *(function)* — Called with `(state: boolean)` when toggled.

**Returns:** `{ Set(bool), Get() → bool }`

```lua
tab:Switch("God Mode", "Become immune to damage", false, function(state)
    setGodMode(state)
end)
```

```lua
-- Old 3-argument style (still supported):
tab:Switch("Fly", false, function(state)
    toggleFly(state)
end)
```

```lua
-- Control programmatically:
local sw = tab:Switch("Aimbot", nil, false, function(v) enableAimbot(v) end)
sw:Set(true)    -- turn on without triggering callback
print(sw:Get()) -- false or true
```

---

### `sec:Slider(name, description, min, max, default, step, callback)` → `obj`

A horizontal drag-to-set slider with a live value readout.
Supports optional snap-to-step increments.

**Parameters:**
- `name` *(string)* — Label.
- `description` *(string)* — Subtitle. Pass `nil` to skip.
- `min` *(number)* — Minimum value.
- `max` *(number)* — Maximum value.
- `default` *(number)* — Starting value.
- `step` *(number)* — Snap increment. `0` or `nil` for smooth (no snapping).
- `callback` *(function)* — Called with `(value: number)` as you drag.

**Returns:** `{ Set(v), Get() → number }`

```lua
tab:Slider("Walk Speed", "Player movement speed", 0, 500, 16, 1, function(val)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
end)
```

```lua
tab:Slider("FOV", nil, 10, 180, 70, 5, function(val)
    camera.FieldOfView = val
end)
```

```lua
local sl = tab:Slider("Opacity", nil, 0, 1, 0.5, 0, function(v) setOpacity(v) end)
sl:Set(0.8)        -- programmatic set
print(sl:Get())    -- 0.8
```

---

### `sec:TextField(name, placeholder, default, callback)` → `obj`

A single-line text input with a label on the left.
The callback fires when the user clicks away (FocusLost).

**Parameters:**
- `name` *(string)* — Label on the left side.
- `placeholder` *(string)* — Grey hint text inside the box.
- `default` *(string)* — Pre-filled text. Optional.
- `callback` *(function)* — Called with `(text: string)` on FocusLost.

**Returns:** `{ Set(text), Get() → string }`

```lua
tab:TextField("Target Player", "Enter username...", "", function(val)
    print("Searching for:", val)
end)
```

```lua
local tf = tab:TextField("Speed Value", "e.g. 16", "16", function(v)
    local n = tonumber(v)
    if n then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = n end
end)

tf:Set("32")      -- set programmatically
print(tf:Get())   -- "32"
```

---

### `sec:Dropdown(name, description, options, default, callback)` → `obj`

A collapsible option picker with animated open/close.
Clicking the row opens a scrollable list of options.

**Parameters:**
- `name` *(string)* — Label.
- `description` *(string)* — Subtitle. Pass `nil` to skip.
- `options` *(table)* — Array of strings: `{"Option1", "Option2", ...}`
- `default` *(string)* — Pre-selected option. Optional.
- `callback` *(function)* — Called with `(selected: string)` on selection.

**Returns:** `{ Set(option), Get() → string, Refresh(newOptions) }`

```lua
tab:Dropdown("Team", nil, {"Attackers", "Defenders", "Spectators"},
    "Attackers", function(v)
        joinTeam(v)
    end)
```

```lua
tab:Dropdown("Aim Part", "Which body part to aim at",
    {"Head", "Neck", "Chest", "Pelvis", "Left Arm", "Right Arm"},
    "Head", function(v)
        setAimPart(v)
    end)
```

```lua
local dd = tab:Dropdown("Weapon", nil, {"Sword", "Gun", "Bow"}, "Sword", setWeapon)

-- Change selected option programmatically:
dd:Set("Gun")

-- Replace the options list entirely:
dd:Refresh({"Pistol", "Rifle", "Sniper"})
```

---

### `sec:ColorPicker(name, description, default, callback)` → `obj`

A colour picker with three HSV sliders (Hue, Saturation, Value).
Clicking the colour swatch opens or closes the picker panel.

**Parameters:**
- `name` *(string)* — Label.
- `description` *(string)* — Subtitle. Optional.
- `default` *(Color3)* — Starting colour. Default: `Color3.fromRGB(255, 0, 0)`.
- `callback` *(function)* — Called with `(color: Color3)` as sliders change.

**Returns:** `{ Set(c3), Get() → Color3 }`

```lua
tab:ColorPicker("ESP Colour", "Colour of the highlight box",
    Color3.fromRGB(255, 0, 0), function(c)
        setESPColor(c)
    end)
```

```lua
local cp = tab:ColorPicker("Chams", nil, Color3.fromRGB(0, 255, 128), setChamColor)
cp:Set(Color3.fromRGB(0, 0, 255))
print(cp:Get())   -- Color3
```

---

### `sec:Keybind(name, description, default, callback)` → `obj`

A keybind configurator. Click the pill then press any key to rebind.
The callback fires every time the bound key is pressed globally.

**Parameters:**
- `name` *(string)* — Label.
- `description` *(string)* — Subtitle. Optional.
- `default` *(Enum.KeyCode)* — Default key. e.g. `Enum.KeyCode.F`.
- `callback` *(function)* — Called (no arguments) whenever the key is pressed.

**Returns:** `{ Set(keyCode), Get() → KeyCode }`

```lua
tab:Keybind("Toggle ESP", "Press to show/hide ESP",
    Enum.KeyCode.Z, function()
        toggleESP()
    end)
```

```lua
tab:Keybind("Teleport", nil, Enum.KeyCode.T, function()
    teleportToMouse()
end)
```

```lua
local kb = tab:Keybind("Noclip", nil, Enum.KeyCode.N, toggleNoclip)
kb:Set(Enum.KeyCode.M)   -- change key
print(kb:Get().Name)     -- "M"
```

---

### `sec:ProgressBar(name, description, default, max)` → `obj`

A read-only animated progress bar. Update it from your script with `:Set(v)`.

**Parameters:**
- `name` *(string)* — Label.
- `description` *(string)* — Subtitle. Optional.
- `default` *(number)* — Starting value.
- `max` *(number)* — Maximum value. Default `100`.

**Returns:** `{ Set(v), Get() → number, SetMax(m) }`

```lua
local xpBar = tab:ProgressBar("Experience", "Current XP towards next level", 0, 1000)

-- Update it later in your script:
xpBar:Set(420)
xpBar:SetMax(2000)
print(xpBar:Get())   -- 420
```

---

### `sec:MultiSwitch(name, options, default, callback)` → `obj`

A segmented control (mutually exclusive button row). Only one option is active at a time.

**Parameters:**
- `name` *(string)* — Label above the segment bar.
- `options` *(table)* — Array of strings.
- `default` *(string)* — Initially active option.
- `callback` *(function)* — Called with `(selected: string)`.

**Returns:** `{ Set(option), Get() → string }`

```lua
tab:MultiSwitch("Aim Bone",
    {"Head", "Neck", "Chest", "Pelvis"},
    "Head", function(v)
        setAimBone(v)
    end)
```

```lua
tab:MultiSwitch("ESP Style",
    {"Box", "Corner Box", "Skeleton", "Off"},
    "Box", function(v)
        setESPStyle(v)
    end)
```

---

### `sec:NumericStepper(name, description, min, max, step, default, callback)` → `obj`

A +/− stepper control. Hold the button to continuously increment/decrement.

**Parameters:**
- `name` *(string)* — Label.
- `description` *(string)* — Subtitle. Optional.
- `min` *(number)* — Minimum value.
- `max` *(number)* — Maximum value.
- `step` *(number)* — Increment per click/hold tick. Default `1`.
- `default` *(number)* — Starting value.
- `callback` *(function)* — Called with `(value: number)`.

**Returns:** `{ Set(v), Get() → number }`

```lua
tab:NumericStepper("Jump Power", nil, 50, 500, 10, 50, function(v)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
end)
```

---

### `sec:Divider(name)`

A section heading inside the content panel, with a thin line underneath.
Use it to visually group elements within a tab.

**Parameters:**
- `name` *(string)* — Heading text.

```lua
tab:Divider("Aim Settings")
tab:Switch("Aimbot", nil, false, enableAimbot)
tab:Slider("FOV", nil, 1, 360, 90, 1, setFOV)

tab:Divider("Visuals")
tab:Switch("ESP", nil, false, enableESP)
tab:ColorPicker("ESP Color", nil, Color3.new(1,0,0), setESPColor)
```

---

### `sec:Label(name)` → `obj`

A static read-only text line. Can be updated dynamically.

**Parameters:**
- `name` *(string)* — Initial label text.

**Returns:** `{ Set(text), Get() → string }`

```lua
tab:Label("Version: 1.0.0")

local statusLbl = tab:Label("Status: Idle")
statusLbl:Set("Status: Running")
```

---

### `sec:Badge(name, badgeText, color)` → `obj`

A label row with a coloured pill badge on the right.
Great for showing live statuses.

**Parameters:**
- `name` *(string)* — Left-side label.
- `badgeText` *(string)* — Text inside the badge pill.
- `color` *(Color3)* — Badge background colour. Optional, defaults to red.

**Returns:** `{ SetBadge(text, color?), SetName(text) }`

```lua
local statusBadge = tab:Badge("Detection Status", "Safe", Color3.fromRGB(52, 199, 89))

-- Update later:
statusBadge:SetBadge("Detected", Color3.fromRGB(255, 59, 48))
statusBadge:SetName("Anti-Cheat Status")
```

---

### `sec:InfoCard(title, lines)`

A styled card showing a grid of key-value pairs.
Useful for displaying script/game/system info at a glance.

**Parameters:**
- `title` *(string)* — Card heading (small, grey, uppercase).
- `lines` *(table)* — Array of `{ key = string, value = string }` pairs.

```lua
tab:InfoCard("System Info", {
    { key = "Executor",  value = identifyexecutor and identifyexecutor() or "Unknown" },
    { key = "Game",      value = game.Name },
    { key = "Place ID",  value = tostring(game.PlaceId) },
    { key = "Library",   value = "Apple Library " .. lib:GetVersion() },
    { key = "Author",    value = lib:GetAuthor() },
})
```

---

### `sec:TextArea(name, default, callback)` → `obj`

A multi-line text box. Useful for script executors, notes, or config input.

**Parameters:**
- `name` *(string)* — Label above the text area.
- `default` *(string)* — Pre-filled text. Optional.
- `callback` *(function)* — Called with `(text: string)` on FocusLost.

**Returns:** `{ Set(text), Get() → string }`

```lua
tab:TextArea("Execute Script", "print('Hello World')", function(code)
    loadstring(code)()
end)
```

---

### `sec:RichTextLabel(text)` → `obj`

A label supporting Roblox's RichText HTML-like tags: `<b>`, `<i>`, `<font color="">`, etc.

**Parameters:**
- `text` *(string)* — Rich text string.

**Returns:** `{ Set(text) }`

```lua
tab:RichTextLabel(
    '<font color="rgb(21,103,251)"><b>Apple Library V1</b></font> — by <i>Kyrubureibu</i>'
)
```

---

### `sec:Image(assetId, height)`

Embeds a Roblox image inside the content panel.

**Parameters:**
- `assetId` *(string)* — e.g. `"rbxassetid://12621719043"`.
- `height` *(number)* — Display height in pixels. Default `120`.

**Returns:** `{ SetImage(assetId) }`

```lua
tab:Image("rbxassetid://12621719043", 160)
```

---

### `sec:Spacer(height)`

Adds invisible vertical space between elements.

**Parameters:**
- `height` *(number)* — Pixels. Default `16`.

```lua
tab:Spacer(24)
```

---

### `sec:Separator()`

Adds a thin 1-pixel horizontal dividing line.

```lua
tab:Switch("Aimbot", nil, false, enableAimbot)
tab:Separator()
tab:Switch("ESP", nil, false, enableESP)
```

---

## ⚡ Quick API

For simple scripts, use `lib:Quick(config)` to build an entire GUI from one table.

```lua
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kyrubureibu/UI-Library/main/AppleLibrary.lua"))()

lib:Quick({
    title    = "My Script",
    splash   = true,
    theme    = "Dark",
    toggleKey = Enum.KeyCode.RightShift,
    sections = {
        {
            name    = "Combat",
            default = true,   -- this tab is active on load
            elements = {
                { type = "Switch", name = "Aimbot", default = false,
                  callback = function(v) enableAimbot(v) end },

                { type = "Slider", name = "FOV", min = 1, max = 360,
                  default = 90, step = 1,
                  callback = function(v) setFOV(v) end },

                { type = "Divider", name = "Visuals" },

                { type = "Switch", name = "ESP", default = false,
                  callback = function(v) enableESP(v) end },

                { type = "Button", name = "Kill All",
                  description = "Eliminate every player",
                  callback = function() killAll() end },
            }
        },

        {
            name = "Settings",
            elements = {
                { type = "Dropdown", name = "Theme",
                  options = {"Light","Dark","Midnight","Rose"},
                  default = "Dark",
                  callback = function(v) lib:SetTheme(v) end },
            }
        }
    }
})
```

### Supported element types in `lib:Quick`

| `type` string | Element |
|---|---|
| `"button"` | Button |
| `"switch"` / `"toggle"` | Switch |
| `"slider"` | Slider |
| `"textfield"` / `"input"` | TextField |
| `"dropdown"` | Dropdown |
| `"colorpicker"` / `"color"` | ColorPicker |
| `"keybind"` | Keybind |
| `"progressbar"` / `"progress"` | ProgressBar |
| `"multiswitch"` / `"segmented"` | MultiSwitch |
| `"numericstepper"` / `"stepper"` | NumericStepper |
| `"badge"` | Badge |
| `"infocard"` | InfoCard |
| `"textarea"` | TextArea |
| `"image"` | Image |
| `"divider"` | Divider |
| `"label"` | Label |
| `"spacer"` | Spacer |
| `"separator"` | Separator |

---

## 📖 Complete API Reference

```
LIBRARY
  lib:init(title, splash, toggleKey, deletePrev, theme) → win
  lib:Quick(config)                                       → win
  lib:Toast(title, body, icon?, duration?)
  lib:RegisterTheme(name, themeTable)
  lib:SetTheme(name)
  lib:GetTheme()    → themeTable
  lib:GetThemeNames() → {string}
  lib:GetVersion()  → string
  lib:GetAuthor()   → string
  lib:DestroyAll()

WINDOW  (win = lib:init(...))
  win:Section(name)            → sec
  win:Divider(name)
  win:Notify(title, body, btn, icon, cb)
  win:Notify2(title, body, b1, b2, icon, cb1, cb2)
  win:Toast(title, body, icon?, duration?)
  win:SetTitle(text)
  win:GreenButton(callback)
  win:ToggleVisible()
  win:Destroy()

SECTION  (sec = win:Section("Name"))
  sec:Select()
  sec:Button(name, desc?, cb)           → { SetText, SetEnabled }
  sec:Switch(name, desc?, default, cb)  → { Set, Get }
  sec:Slider(name, desc?, min, max, def, step, cb) → { Set, Get }
  sec:TextField(name, placeholder, default, cb)    → { Set, Get }
  sec:Dropdown(name, desc?, options, default, cb)  → { Set, Get, Refresh }
  sec:ColorPicker(name, desc?, default, cb) → { Set, Get }
  sec:Keybind(name, desc?, default, cb)     → { Set, Get }
  sec:ProgressBar(name, desc?, default, max)→ { Set, Get, SetMax }
  sec:MultiSwitch(name, options, default, cb) → { Set, Get }
  sec:NumericStepper(name, desc?, min, max, step, def, cb) → { Set, Get }
  sec:Badge(name, badgeText, color?)        → { SetBadge, SetName }
  sec:InfoCard(title, lines)
  sec:RichTextLabel(text)                   → { Set }
  sec:Image(assetId, height?)               → { SetImage }
  sec:TextArea(name, default?, cb)          → { Set, Get }
  sec:Divider(name)
  sec:Label(name)                           → { Set, Get }
  sec:Spacer(height?)
  sec:Separator()
```

---

## 🔧 Compatibility

| Executor | Supported |
|---|---|
| Synapse X (`syn`) | ✅ Full support (uses `syn.protect_gui`) |
| KRNL / Fluxus (`gethui`) | ✅ Full support |
| Other executors | ✅ Falls back to CoreGui |
| Roblox Studio | ⚠️ Partial (no executor globals) |

---

## 📄 License

```
MIT License

Copyright (c) 2026 Kyrubureibu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

**Apple Library V1** — Made by **Kyrubureibu** · MIT License

*Clean UI. Smooth animations. Pure Lua.*
