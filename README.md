# 🍎 Apple Library — V1.1

> **A macOS-inspired Roblox executor UI library**
> Made with ❤️ by **Kyrubureibu**

---

## 👤 About the Author — Kyrubureibu

Apple Library was created by **Kyrubureibu**, a Roblox developer passionate about clean,
modern UI design. Inspired by Apple's design language — frosted glass panels, smooth
animations, traffic-light window controls, and a minimal aesthetic — Kyrubureibu built
Apple Library to give Roblox executor scripts a professional, polished look that stands
out from generic UI libraries.

V1.1 is a focused update that brings **full mobile support**, making Apple Library one of
the few Roblox UI libraries that works beautifully on both PC and phone / tablet.

---

## 📋 Changelog

### V1.1 — Mobile Update
- **Full mobile / touch support** — the library auto-detects the device and adapts its layout, sizing, and behaviour automatically
- **Floating toggle button** — a draggable Apple-icon button sits at the top-centre of the screen; tap it to show or hide the window, drag it anywhere you like. It pulses three times on first load so you notice it
- **Sidebar drawer** — on mobile the sidebar is hidden by default and slides in from the left as a full-height drawer with a dim overlay behind it. Tap ☰ to open, tap outside or select a tab to close
- **Swipe gestures** — swipe right from the left 60 px of the screen to open the drawer; swipe left to close; swipe right or down on a toast to dismiss it
- **Larger tap targets** — all elements are taller on mobile (buttons/switches 56 px, sliders 68 px) so thumbs hit them reliably
- **Window fills the screen** on mobile instead of a fixed 780×600 box
- **On-screen keyboard offset** — when a text input is focused the window shifts upward so the field stays visible above the keyboard, then returns to centre when focus is released
- **Toasts reposition to bottom-centre** on mobile (easier to read and dismiss with a thumb), with swipe-to-dismiss
- **Removed the version badge** from the title bar — keeps the topbar clean and vibe-correct
- **Hidden scroll bars on mobile** — native touch scrolling handles it; no distracting bar
- Theme tables gain four new optional keys: `DrawerOverlay`, `DrawerOverlayTr`, `FloatBtn`, `FloatBtnTrans`

### V1.0
- Initial release — 15+ elements, 4 built-in themes, toast / modal system, Quick API

---

## 📦 What is Apple Library?

Apple Library is a **Lua UI library for Roblox executors** that lets you build beautiful,
interactive script GUIs without touching raw Instance code. It handles all the boilerplate —
ScreenGui creation, executor protection (`syn.protect_gui` / `gethui`), drag-to-move,
search filtering, smooth animations, and theming — so you can focus on your script logic.

### What it includes

| Category | Details |
|---|---|
| **Window** | macOS traffic-light buttons on desktop; hamburger + close on mobile |
| **Floating toggle** | Draggable Apple-icon button for mobile show/hide — **new in V1.1** |
| **Sidebar** | Searchable tab list; collapses to a swipe-in drawer on mobile |
| **Themes** | Light · Dark · Midnight · Rose + custom theme registration |
| **Toast** | Slide-in notifications; bottom-centre on mobile, top-right on desktop |
| **Modals** | Single-button and two-button centred dialogs |
| **Splash screen** | Optional animated loading screen on startup |
| **15+ elements** | Button, Switch, Slider, Dropdown, ColorPicker, Keybind, ProgressBar, MultiSwitch, NumericStepper, TextField, TextArea, Label, Divider, Badge, InfoCard, RichTextLabel, Image, Spacer, Separator |
| **Quick API** | `lib:Quick(config)` — build a whole GUI from one table |
| **MIT licensed** | Free to use, modify, and redistribute |

---

## 🚀 Getting Started

```lua
local lib = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

local win = lib:init(
    "My Script",                 -- Window title
    true,                        -- Show splash screen
    Enum.KeyCode.RightShift,     -- PC key to toggle (ignored on mobile)
    true,                        -- Delete previous GUI if found
    "Dark"                       -- Theme: "Light" | "Dark" | "Midnight" | "Rose"
)

local mainTab = win:Section("Main")
mainTab:Select()   -- make this the active tab on load

mainTab:Button("Say Hello", function()
    print("Hello from Apple Library!")
end)
```

On mobile, the `toggleKey` is ignored — the floating Apple-icon button handles visibility.

---

## 📱 Mobile Behaviour — What Changes Automatically

You do **not** need to write separate code for mobile. Detection happens once at startup
using `UserInputService.TouchEnabled` and the viewport width.

| Feature | Desktop | Mobile |
|---|---|---|
| Window size | Fixed 780 × 600 px | Fills screen (8 px margin) |
| Sidebar | Always-visible left column | Hidden; slides in as a drawer |
| Open drawer | N/A | ☰ button, swipe right from left edge |
| Close drawer | N/A | Tap overlay, select a tab, swipe left |
| Window toggle | Yellow traffic-light + keyboard key | Floating Apple-icon button |
| Window drag | Drag anywhere on the frame | N/A (fills screen) |
| Tab buttons | 38 px tall | 48 px tall |
| Sliders | 6 px track · 18 px knob · 30 px hit area | 8 px track · 24 px knob · 44 px hit area |
| Switches | 56 × 30 px | 62 × 34 px |
| Toast position | Top-right corner | Bottom-centre |
| Scroll bars | 2 px visible | Hidden (touch scrolling) |
| Keyboard | Ignored | Window shifts up when keyboard appears |

---

## 🎨 Themes

Built-in themes: `"Light"` · `"Dark"` · `"Midnight"` · `"Rose"`

```lua
-- Set at init:
local win = lib:init("My Script", true, Enum.KeyCode.RightShift, true, "Dark")

-- Or set before calling init:
lib:SetTheme("Midnight")

-- Check the device and pick a theme:
if lib:IsMobile() then
    lib:SetTheme("Dark")   -- dark themes look great on OLED phones
end
```

### Registering a custom theme

```lua
lib:RegisterTheme("Ocean", {
    Window          = Color3.fromRGB(10, 20, 40),
    WindowTrans     = 0.05,
    Sidebar         = Color3.fromRGB(8, 16, 34),
    Workarea        = Color3.fromRGB(15, 30, 55),
    TitleText       = Color3.fromRGB(200, 230, 255),
    PrimaryText     = Color3.fromRGB(200, 230, 255),
    SecondaryText   = Color3.fromRGB(120, 160, 210),
    PlaceholderText = Color3.fromRGB(90, 120, 170),
    Accent          = Color3.fromRGB(0, 180, 220),
    AccentText      = Color3.fromRGB(255, 255, 255),
    ButtonBg        = Color3.fromRGB(20, 40, 70),
    InputBg         = Color3.fromRGB(20, 40, 70),
    SwitchOff       = Color3.fromRGB(40, 60, 90),
    SwitchOn        = Color3.fromRGB(0, 180, 220),
    SliderFill      = Color3.fromRGB(0, 180, 220),
    SliderTrack     = Color3.fromRGB(40, 60, 90),
    DropdownBg      = Color3.fromRGB(20, 40, 70),
    DropdownItem    = Color3.fromRGB(15, 30, 55),
    Separator       = Color3.fromRGB(30, 55, 90),
    Progress        = Color3.fromRGB(0, 180, 220),
    ProgressBg      = Color3.fromRGB(40, 60, 90),
    Badge           = Color3.fromRGB(255, 69, 58),
    BadgeText       = Color3.fromRGB(255, 255, 255),
    CloseBtn        = Color3.fromRGB(254, 94, 86),
    MinBtn          = Color3.fromRGB(255, 189, 46),
    MaxBtn          = Color3.fromRGB(39, 200, 63),
    NotifBg         = Color3.fromRGB(15, 30, 55),
    NotifDarken     = Color3.fromRGB(0, 0, 0),
    ToastBg         = Color3.fromRGB(15, 30, 55),
    ToastTrans      = 0.05,
    -- V1.1 mobile keys (optional — defaults are applied if missing):
    DrawerOverlay   = Color3.fromRGB(0, 0, 0),   -- colour behind the open drawer
    DrawerOverlayTr = 0.50,                       -- how transparent that overlay is
    FloatBtn        = Color3.fromRGB(0, 180, 220),-- floating toggle button colour
    FloatBtnTrans   = 0.05,                       -- floating button background transparency
})

lib:SetTheme("Ocean")
```

---

## 🪟 Window Methods

---

### `lib:init(title, doSplash, toggleKey, deletePrevious, themeName)` → `win`

Creates the main window and returns a window object.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `title` | string | Text shown in the window title bar |
| `doSplash` | boolean | Show the animated splash screen |
| `toggleKey` | KeyCode | Desktop key to toggle visibility. `nil` to disable. Ignored on mobile |
| `deletePrevious` | boolean | Destroy any existing AppleLib GUI before creating |
| `themeName` | string | Starting theme name |

```lua
local win = lib:init("My Script", true, Enum.KeyCode.RightShift, true, "Dark")
```

---

### `win:Section(name)` → `sec`

Creates a new sidebar tab and its associated content panel.
On mobile, selecting a tab automatically closes the sidebar drawer.

```lua
local combatTab  = win:Section("Combat")
local visualsTab = win:Section("Visuals")
local miscTab    = win:Section("Misc")

combatTab:Select()   -- active by default
```

---

### `win:Divider(name)`

Adds a small grey category heading inside the sidebar above a group of tabs.

```lua
win:Divider("Features")
local espTab    = win:Section("ESP")
local aimbotTab = win:Section("Aimbot")

win:Divider("Settings")
local configTab = win:Section("Config")
```

---

### `win:Notify(title, body, buttonText, icon, callback)`

Single-button modal dialog. Blocks the rest of the UI with an overlay.

```lua
win:Notify(
    "Script Loaded",
    "Apple Library V1.1 is ready.",
    "Let's go",
    "rbxassetid://4871684504",
    function() print("Acknowledged") end
)
```

---

### `win:Notify2(title, body, btn1, btn2, icon, cb1, cb2)`

Two-button modal — primary action and a cancel/alternative.

```lua
win:Notify2(
    "Reset Settings",
    "This will clear all preferences. Continue?",
    "Yes, Reset", "Cancel",
    "rbxassetid://12608260095",
    function() resetAll() end,
    function() print("Cancelled") end
)
```

---

### `win:Toast(title, body, icon, duration)`

Floating notification. On mobile it appears at the **bottom-centre** of the screen
and can be swiped right or downward to dismiss early.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `title` | string | Bold title |
| `body` | string | Smaller body text |
| `icon` | string | Roblox asset id. Pass `nil` for default |
| `duration` | number | Seconds before auto-dismiss. Default `5` |

```lua
win:Toast("ESP Enabled", "Players are highlighted.", "rbxassetid://4871684504", 4)
```

You can also call it without a window:
```lua
lib:Toast("Injected", "Script is ready!", nil, 3)
```

---

### `win:SetTitle(text)`

Changes the window title at any time.

```lua
win:SetTitle("My Script — v2.0")
```

---

### `win:GreenButton(callback)`

Assigns a callback to the green traffic-light button. Desktop only — this button is not
shown on mobile.

```lua
win:GreenButton(function()
    toggleFullscreen()
end)
```

---

### `win:ToggleVisible()`

Programmatically shows or hides the window. On desktop this is the same as pressing your
`toggleKey`. On mobile it is the same as tapping the floating button.

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

### `lib:IsMobile()` → `boolean`

Returns `true` if the library detected a mobile / touch device at startup.

```lua
if lib:IsMobile() then
    tab:Label("Running on mobile — swipe right to open the sidebar!")
end
```

---

## 📋 Section Elements

All elements are called on a **section object** from `win:Section(...)`.
Every element automatically sizes itself for the current device — you do not need
to specify mobile or desktop variants yourself.

---

### `sec:Button(name, description, callback)` → `obj`

A tappable button row with an optional subtitle and a right-pointing arrow.
Fires the callback in a coroutine so it cannot freeze the UI.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Button label |
| `description` | string | Smaller subtitle. Pass `nil` to skip |
| `callback` | function | Called when tapped / clicked |

**Returns:** `{ SetText(t), SetEnabled(b) }`

```lua
tab:Button("Teleport to Spawn", "Move to the game spawn", function()
    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(0, 5, 0))
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
local btn = tab:Button("Do Thing", "Does a thing", doThingCallback)
btn:SetEnabled(false)    -- grey out and disable
btn:SetText("Did it!")   -- change the label
```

---

### `sec:Switch(name, description, default, callback)` → `obj`

An iOS-style toggle switch with a sliding thumb. The pill is larger on mobile
(62 × 34 px vs 56 × 30 px) for easier thumb tapping.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Label text |
| `description` | string | Subtitle. Optional |
| `default` | boolean | Starting state. `true` = ON |
| `callback` | function | Called with `(state: boolean)` on change |

**Returns:** `{ Set(bool), Get() → bool }`

```lua
tab:Switch("God Mode", "Immune to all damage", false, function(state)
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
local sw = tab:Switch("Aimbot", nil, false, enableAimbot)
sw:Set(true)
print(sw:Get())   -- true
```

---

### `sec:Slider(name, description, min, max, default, step, callback)` → `obj`

A horizontal drag-to-set slider. On mobile the track is 8 px tall, the knob is
24 px, and the invisible touch hit zone is 44 px tall so thumbs can grab it reliably.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Label |
| `description` | string | Subtitle. Pass `nil` to skip |
| `min` | number | Minimum value |
| `max` | number | Maximum value |
| `default` | number | Starting value |
| `step` | number | Snap increment. `0` or `nil` for smooth |
| `callback` | function | Called with `(value: number)` as you drag |

**Returns:** `{ Set(v), Get() → number }`

```lua
tab:Slider("Walk Speed", "Player movement speed", 0, 500, 16, 1, function(val)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
end)
```

```lua
tab:Slider("FOV", nil, 10, 180, 70, 5, function(val)
    workspace.CurrentCamera.FieldOfView = val
end)
```

```lua
local sl = tab:Slider("Opacity", nil, 0, 1, 0.5, 0, setOpacity)
sl:Set(0.8)
print(sl:Get())   -- 0.8
```

---

### `sec:TextField(name, placeholder, default, callback)` → `obj`

A single-line text input with a label on the left. On mobile the field is taller and
the text is larger. When focused on mobile, the window automatically shifts upward
to stay above the on-screen keyboard.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Label on the left |
| `placeholder` | string | Grey hint text inside the box |
| `default` | string | Pre-filled text. Optional |
| `callback` | function | Called with `(text: string)` on FocusLost |

**Returns:** `{ Set(text), Get() → string }`

```lua
tab:TextField("Player Name", "Enter username...", "", function(val)
    searchPlayer(val)
end)
```

```lua
local tf = tab:TextField("Speed", "e.g. 16", "16", function(v)
    local n = tonumber(v)
    if n then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = n end
end)
tf:Set("32")
print(tf:Get())   -- "32"
```

---

### `sec:Dropdown(name, description, options, default, callback)` → `obj`

A collapsible option picker that animates open and closed.
On mobile each option row is 48 px tall and scroll bars are hidden.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Label |
| `description` | string | Subtitle. Pass `nil` to skip |
| `options` | table | `{"Option1", "Option2", ...}` |
| `default` | string | Pre-selected option |
| `callback` | function | Called with `(selected: string)` on change |

**Returns:** `{ Set(option), Get() → string, Refresh(newOptions) }`

```lua
tab:Dropdown("Team", nil,
    {"Attackers", "Defenders", "Spectators"},
    "Attackers", joinTeam)
```

```lua
tab:Dropdown("Aim Part", "Which body part to aim at",
    {"Head", "Neck", "Chest", "Pelvis"},
    "Head", setAimPart)
```

```lua
local dd = tab:Dropdown("Weapon", nil, {"Sword","Gun","Bow"}, "Sword", setWeapon)
dd:Set("Gun")
dd:Refresh({"Pistol", "Rifle", "Sniper"})
```

---

### `sec:ColorPicker(name, description, default, callback)` → `obj`

An HSV colour picker. Tap the coloured swatch to open or close the picker panel.
On mobile the sliders and knobs are larger for easier dragging.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Label |
| `description` | string | Subtitle. Optional |
| `default` | Color3 | Starting colour. Default: red |
| `callback` | function | Called with `(color: Color3)` as sliders move |

**Returns:** `{ Set(c3), Get() → Color3 }`

```lua
tab:ColorPicker("ESP Colour", "Highlight box colour",
    Color3.fromRGB(255, 0, 0), setESPColor)
```

```lua
local cp = tab:ColorPicker("Chams", nil, Color3.fromRGB(0, 255, 128), setChamColor)
cp:Set(Color3.fromRGB(0, 0, 255))
print(cp:Get())   -- Color3
```

---

### `sec:Keybind(name, description, default, callback)` → `obj`

A keybind configurator. On desktop: click the pill then press a key to rebind.
On mobile: tap the pill to enter listening mode, then press a hardware volume key or
a connected controller button.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Label |
| `description` | string | Subtitle. Optional |
| `default` | Enum.KeyCode | Default key |
| `callback` | function | Called (no args) whenever the bound key is pressed |

**Returns:** `{ Set(keyCode), Get() → KeyCode }`

```lua
tab:Keybind("Toggle ESP", nil, Enum.KeyCode.Z, function()
    toggleESP()
end)
```

```lua
local kb = tab:Keybind("Noclip", nil, Enum.KeyCode.N, toggleNoclip)
kb:Set(Enum.KeyCode.M)
print(kb:Get().Name)   -- "M"
```

---

### `sec:ProgressBar(name, description, default, max)` → `obj`

A read-only animated progress bar. Track is 10 px on mobile.
Update it from your script with `:Set(value)`.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Label |
| `description` | string | Subtitle. Optional |
| `default` | number | Starting value |
| `max` | number | Maximum value. Default `100` |

**Returns:** `{ Set(v), Get() → number, SetMax(m) }`

```lua
local xpBar = tab:ProgressBar("Experience", "XP towards next level", 0, 1000)
xpBar:Set(420)
xpBar:SetMax(2000)
```

---

### `sec:MultiSwitch(name, options, default, callback)` → `obj`

A segmented control — only one option is active at a time.
Segment rows are 34 px tall on mobile.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Label above the segment bar |
| `options` | table | Array of strings |
| `default` | string | Initially active option |
| `callback` | function | Called with `(selected: string)` |

**Returns:** `{ Set(option), Get() → string }`

```lua
tab:MultiSwitch("Aim Bone",
    {"Head", "Neck", "Chest", "Pelvis"},
    "Head", setAimBone)
```

```lua
tab:MultiSwitch("ESP Style",
    {"Box", "Corner Box", "Skeleton", "Off"},
    "Box", setESPStyle)
```

---

### `sec:NumericStepper(name, description, min, max, step, default, callback)` → `obj`

A +/− stepper. Hold the button to continuously increment or decrement.
Buttons are 36 px on mobile for easier tapping.

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `name` | string | Label |
| `description` | string | Subtitle. Optional |
| `min` | number | Minimum value |
| `max` | number | Maximum value |
| `step` | number | Amount per click / hold tick |
| `default` | number | Starting value |
| `callback` | function | Called with `(value: number)` |

**Returns:** `{ Set(v), Get() → number }`

```lua
tab:NumericStepper("Jump Power", nil, 50, 500, 10, 50, function(v)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
end)
```

---

### `sec:Divider(name)`

A section heading inside the content panel with a thin line underneath.
Use it to visually group elements within a tab.

```lua
tab:Divider("Aim Settings")
tab:Switch("Aimbot", nil, false, enableAimbot)
tab:Slider("FOV", nil, 1, 360, 90, 1, setFOV)

tab:Divider("Visuals")
tab:Switch("ESP", nil, false, enableESP)
```

---

### `sec:Label(name)` → `obj`

A static read-only text line. Can be updated at any time.

```lua
tab:Label("Version: 1.0.0")

local statusLbl = tab:Label("Status: Idle")
statusLbl:Set("Status: Running")
```

---

### `sec:Badge(name, badgeText, color)` → `obj`

A label row with a coloured pill badge on the right side.
Great for live status indicators.

```lua
local b = tab:Badge("Anti-Cheat", "Safe", Color3.fromRGB(52, 199, 89))
b:SetBadge("Detected", Color3.fromRGB(255, 59, 48))
```

---

### `sec:InfoCard(title, lines)`

A styled card showing key-value pairs.

```lua
tab:InfoCard("Device Info", {
    { key = "Platform", value = lib:IsMobile() and "Mobile" or "Desktop" },
    { key = "Game",     value = game.Name },
    { key = "Library",  value = lib:GetVersion() },
    { key = "Author",   value = lib:GetAuthor() },
})
```

---

### `sec:TextArea(name, default, callback)` → `obj`

Multi-line text input. 160 px tall on mobile, 130 px on desktop.

```lua
tab:TextArea("Execute Script", "print('Hello')", function(code)
    loadstring(code)()
end)
```

---

### `sec:RichTextLabel(text)` → `obj`

A label that supports Roblox RichText tags: `<b>`, `<i>`, `<font color="">`, etc.

```lua
tab:RichTextLabel(
    '<font color="rgb(21,103,251)"><b>Apple Library V1.1</b></font> — by <i>Kyrubureibu</i>'
)
```

---

### `sec:Image(assetId, height)`

An embedded Roblox image. Default height 150 px on mobile, 120 px on desktop.

```lua
tab:Image("rbxassetid://12621719043", 160)
```

---

### `sec:Spacer(height)` / `sec:Separator()`

Layout helpers. Default spacer is 20 px on mobile. Separator is 2 px on mobile, 1 px on desktop.

```lua
tab:Switch("Aimbot", nil, false, enableAimbot)
tab:Separator()
tab:Switch("ESP",    nil, false, enableESP)
tab:Spacer(16)
tab:Label("More settings below")
```

---

## ⚡ Quick API

Build an entire GUI from a single config table.

```lua
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kyrubureibu/UI-Library/main/AppleLibrary.lua"))()

lib:Quick({
    title     = "My Script",
    splash    = true,
    theme     = "Dark",
    toggleKey = Enum.KeyCode.RightShift,
    sections  = {
        {
            name    = "Combat",
            default = true,
            elements = {
                { type="Switch", name="Aimbot", default=false,
                  callback=function(v) enableAimbot(v) end },
                { type="Slider", name="FOV", min=1, max=360, default=90, step=1,
                  callback=function(v) setFOV(v) end },
                { type="Divider", name="Visuals" },
                { type="Switch", name="ESP", default=false,
                  callback=function(v) enableESP(v) end },
                { type="Button", name="Teleport to Spawn",
                  description="Move to the game spawn",
                  callback=function() teleport() end },
            }
        },
        {
            name = "Settings",
            elements = {
                { type="Dropdown", name="Theme",
                  options={"Light","Dark","Midnight","Rose"},
                  default="Dark",
                  callback=function(v) lib:SetTheme(v) end },
                { type="Badge", name="Platform",
                  badge=lib:IsMobile() and "Mobile" or "Desktop" },
            }
        }
    }
})
```

### Supported `type` strings in `lib:Quick`

| `type` | Element |
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

## 📖 Full API Reference

```
LIBRARY
  lib:init(title, splash, toggleKey, deletePrev, theme) → win
  lib:Quick(config)                                       → win
  lib:Toast(title, body, icon?, duration?)
  lib:RegisterTheme(name, themeTable)
  lib:SetTheme(name)
  lib:GetTheme()      → themeTable
  lib:GetThemeNames() → {string}
  lib:GetVersion()    → "V1.1"
  lib:GetAuthor()     → "Kyrubureibu"
  lib:IsMobile()      → boolean           ← NEW in V1.1
  lib:DestroyAll()

WINDOW  (win = lib:init(...))
  win:Section(name)             → sec
  win:Divider(name)
  win:Notify(title, body, btn, icon, cb)
  win:Notify2(title, body, b1, b2, icon, cb1, cb2)
  win:Toast(title, body, icon?, duration?)
  win:SetTitle(text)
  win:GreenButton(callback)     -- desktop only
  win:ToggleVisible()
  win:Destroy()

SECTION  (sec = win:Section("Name"))
  sec:Select()
  sec:Button(name, desc?, cb)             → { SetText, SetEnabled }
  sec:Switch(name, desc?, default, cb)    → { Set, Get }
  sec:Slider(name,desc?,min,max,def,step,cb) → { Set, Get }
  sec:TextField(name,placeholder,default,cb) → { Set, Get }
  sec:Dropdown(name,desc?,options,default,cb)→ { Set, Get, Refresh }
  sec:ColorPicker(name, desc?, default, cb)  → { Set, Get }
  sec:Keybind(name, desc?, default, cb)      → { Set, Get }
  sec:ProgressBar(name, desc?, default, max) → { Set, Get, SetMax }
  sec:MultiSwitch(name, options, default, cb)→ { Set, Get }
  sec:NumericStepper(name,desc?,min,max,step,def,cb) → { Set, Get }
  sec:Badge(name, badgeText, color?)         → { SetBadge }
  sec:InfoCard(title, lines)
  sec:RichTextLabel(text)                    → { Set }
  sec:Image(assetId, height?)                → { SetImage }
  sec:TextArea(name, default?, cb)           → { Set, Get }
  sec:Divider(name)
  sec:Label(name)                            → { Set, Get }
  sec:Spacer(height?)
  sec:Separator()
```

---

## 🔧 Compatibility

| Environment | Status |
|---|---|
| Synapse X (`syn`) | ✅ Full — uses `syn.protect_gui` |
| KRNL / Fluxus (`gethui`) | ✅ Full |
| Other executors | ✅ CoreGui fallback |
| Mobile — iOS / Android | ✅ Full support — **new in V1.1** |
| Tablet | ✅ Detected as mobile |
| Roblox Studio | ⚠️ Partial — no executor globals |

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

<div align="center">

**Apple Library V1.1** — Made by **Kyrubureibu** · MIT License

*Clean UI. Smooth animations. Desktop & Mobile.*

</div>
