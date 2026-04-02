--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                                                                              ║
    ║                        Apple Library  ·  V1                                 ║
    ║                    Made by  Kyrubureibu  (2024)                             ║
    ║                                                                              ║
    ║   A macOS-inspired Roblox UI library for executors.                         ║
    ║   Clean, modern, smooth.                                                    ║
    ║                                                                              ║
    ╚══════════════════════════════════════════════════════════════════════════════╝

    MIT License — see bottom of file or README.md for details.
--]]

-- ─────────────────────────────────────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────────────────────────────────────

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Debris            = game:GetService("Debris")
local CoreGui           = game:GetService("CoreGui")

-- ─────────────────────────────────────────────────────────────────────────────
-- LIBRARY TABLE & INTERNAL STATE
-- ─────────────────────────────────────────────────────────────────────────────

local lib = {}

-- Version metadata
lib.Version    = "V1"
lib.Author     = "Kyrubureibu"
lib.Built      = "2024"

-- Internal registries
local _sections      = {}   -- sidebar tab buttons
local _workareas     = {}   -- corresponding scrolling content frames
local _windows       = {}   -- all window references
local _themes        = {}   -- registered theme tables
local _connections   = {}   -- global connection registry for cleanup
local _dropdowns     = {}   -- active open dropdowns

-- Global state
local _visible       = true
local _debounce      = false
local _activeTheme   = nil
local _scrgui        = nil

-- ─────────────────────────────────────────────────────────────────────────────
-- COLOUR THEMES
-- ─────────────────────────────────────────────────────────────────────────────

--[[
    Themes define the colour palette used by every element.
    You can register custom themes with lib:RegisterTheme(name, themeTable)
    and switch with lib:SetTheme(name).
--]]

local THEMES = {
    Light = {
        -- Window chrome
        Window          = Color3.fromRGB(255, 255, 255),
        WindowTrans     = 0.15,
        Sidebar         = Color3.fromRGB(255, 255, 255),
        Workarea        = Color3.fromRGB(255, 255, 255),
        -- Text
        TitleText       = Color3.fromRGB(0,   0,   0  ),
        PrimaryText     = Color3.fromRGB(0,   0,   0  ),
        SecondaryText   = Color3.fromRGB(95,  95,  95 ),
        PlaceholderText = Color3.fromRGB(113, 113, 113),
        -- Accent
        Accent          = Color3.fromRGB(21,  103, 251),
        AccentText      = Color3.fromRGB(255, 255, 255),
        -- Elements
        ButtonBg        = Color3.fromRGB(240, 240, 240),
        InputBg         = Color3.fromRGB(240, 240, 240),
        SwitchOff       = Color3.fromRGB(216, 216, 216),
        SwitchOn        = Color3.fromRGB(21,  103, 251),
        SliderFill      = Color3.fromRGB(21,  103, 251),
        SliderTrack     = Color3.fromRGB(216, 216, 216),
        DropdownBg      = Color3.fromRGB(240, 240, 240),
        DropdownItem    = Color3.fromRGB(255, 255, 255),
        Separator       = Color3.fromRGB(220, 220, 220),
        Progress        = Color3.fromRGB(21,  103, 251),
        ProgressBg      = Color3.fromRGB(216, 216, 216),
        Badge           = Color3.fromRGB(255,  59,  48),
        BadgeText       = Color3.fromRGB(255, 255, 255),
        -- macOS traffic lights
        CloseBtn        = Color3.fromRGB(254,  94,  86),
        MinBtn          = Color3.fromRGB(255, 189,  46),
        MaxBtn          = Color3.fromRGB( 39, 200,  63),
        -- Notification
        NotifBg         = Color3.fromRGB(255, 255, 255),
        NotifDarken     = Color3.fromRGB(0,   0,   0  ),
        -- Toast / TempNotif
        ToastBg         = Color3.fromRGB(255, 255, 255),
        ToastTrans      = 0.15,
    },

    Dark = {
        Window          = Color3.fromRGB( 28,  28,  30),
        WindowTrans     = 0.05,
        Sidebar         = Color3.fromRGB( 28,  28,  30),
        Workarea        = Color3.fromRGB( 44,  44,  46),
        TitleText       = Color3.fromRGB(255, 255, 255),
        PrimaryText     = Color3.fromRGB(255, 255, 255),
        SecondaryText   = Color3.fromRGB(174, 174, 178),
        PlaceholderText = Color3.fromRGB(130, 130, 135),
        Accent          = Color3.fromRGB( 10,  132, 255),
        AccentText      = Color3.fromRGB(255, 255, 255),
        ButtonBg        = Color3.fromRGB( 58,  58,  60),
        InputBg         = Color3.fromRGB( 58,  58,  60),
        SwitchOff       = Color3.fromRGB( 72,  72,  74),
        SwitchOn        = Color3.fromRGB( 10,  132, 255),
        SliderFill      = Color3.fromRGB( 10,  132, 255),
        SliderTrack     = Color3.fromRGB( 72,  72,  74),
        DropdownBg      = Color3.fromRGB( 58,  58,  60),
        DropdownItem    = Color3.fromRGB( 44,  44,  46),
        Separator       = Color3.fromRGB( 58,  58,  60),
        Progress        = Color3.fromRGB( 10,  132, 255),
        ProgressBg      = Color3.fromRGB( 72,  72,  74),
        Badge           = Color3.fromRGB(255,  69,  58),
        BadgeText       = Color3.fromRGB(255, 255, 255),
        CloseBtn        = Color3.fromRGB(254,  94,  86),
        MinBtn          = Color3.fromRGB(255, 189,  46),
        MaxBtn          = Color3.fromRGB( 39, 200,  63),
        NotifBg         = Color3.fromRGB( 44,  44,  46),
        NotifDarken     = Color3.fromRGB(  0,   0,   0),
        ToastBg         = Color3.fromRGB( 44,  44,  46),
        ToastTrans      = 0.05,
    },

    Midnight = {
        Window          = Color3.fromRGB(  7,   7,  20),
        WindowTrans     = 0.02,
        Sidebar         = Color3.fromRGB(  7,   7,  20),
        Workarea        = Color3.fromRGB( 14,  14,  35),
        TitleText       = Color3.fromRGB(200, 210, 255),
        PrimaryText     = Color3.fromRGB(200, 210, 255),
        SecondaryText   = Color3.fromRGB(120, 130, 200),
        PlaceholderText = Color3.fromRGB( 90, 100, 160),
        Accent          = Color3.fromRGB(100, 120, 255),
        AccentText      = Color3.fromRGB(255, 255, 255),
        ButtonBg        = Color3.fromRGB( 25,  25,  60),
        InputBg         = Color3.fromRGB( 25,  25,  60),
        SwitchOff       = Color3.fromRGB( 40,  40,  80),
        SwitchOn        = Color3.fromRGB(100, 120, 255),
        SliderFill      = Color3.fromRGB(100, 120, 255),
        SliderTrack     = Color3.fromRGB( 40,  40,  80),
        DropdownBg      = Color3.fromRGB( 25,  25,  60),
        DropdownItem    = Color3.fromRGB( 14,  14,  35),
        Separator       = Color3.fromRGB( 30,  30,  70),
        Progress        = Color3.fromRGB(100, 120, 255),
        ProgressBg      = Color3.fromRGB( 40,  40,  80),
        Badge           = Color3.fromRGB(255,  69,  58),
        BadgeText       = Color3.fromRGB(255, 255, 255),
        CloseBtn        = Color3.fromRGB(254,  94,  86),
        MinBtn          = Color3.fromRGB(255, 189,  46),
        MaxBtn          = Color3.fromRGB( 39, 200,  63),
        NotifBg         = Color3.fromRGB( 14,  14,  35),
        NotifDarken     = Color3.fromRGB(  0,   0,   0),
        ToastBg         = Color3.fromRGB( 14,  14,  35),
        ToastTrans      = 0.02,
    },

    Rose = {
        Window          = Color3.fromRGB(255, 240, 245),
        WindowTrans     = 0.10,
        Sidebar         = Color3.fromRGB(255, 240, 245),
        Workarea        = Color3.fromRGB(255, 248, 251),
        TitleText       = Color3.fromRGB( 80,  20,  50),
        PrimaryText     = Color3.fromRGB( 80,  20,  50),
        SecondaryText   = Color3.fromRGB(160,  80, 110),
        PlaceholderText = Color3.fromRGB(190, 130, 155),
        Accent          = Color3.fromRGB(230,  60, 110),
        AccentText      = Color3.fromRGB(255, 255, 255),
        ButtonBg        = Color3.fromRGB(240, 210, 225),
        InputBg         = Color3.fromRGB(240, 210, 225),
        SwitchOff       = Color3.fromRGB(220, 180, 200),
        SwitchOn        = Color3.fromRGB(230,  60, 110),
        SliderFill      = Color3.fromRGB(230,  60, 110),
        SliderTrack     = Color3.fromRGB(220, 180, 200),
        DropdownBg      = Color3.fromRGB(240, 210, 225),
        DropdownItem    = Color3.fromRGB(255, 248, 251),
        Separator       = Color3.fromRGB(230, 200, 215),
        Progress        = Color3.fromRGB(230,  60, 110),
        ProgressBg      = Color3.fromRGB(220, 180, 200),
        Badge           = Color3.fromRGB(255,  59,  48),
        BadgeText       = Color3.fromRGB(255, 255, 255),
        CloseBtn        = Color3.fromRGB(254,  94,  86),
        MinBtn          = Color3.fromRGB(255, 189,  46),
        MaxBtn          = Color3.fromRGB( 39, 200,  63),
        NotifBg         = Color3.fromRGB(255, 248, 251),
        NotifDarken     = Color3.fromRGB(  0,   0,   0),
        ToastBg         = Color3.fromRGB(255, 248, 251),
        ToastTrans      = 0.10,
    },
}

_activeTheme = THEMES.Light   -- default

-- ─────────────────────────────────────────────────────────────────────────────
-- UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────────

--[[
    _tween(instance, tweenInfo, goals)
    Wrapper around TweenService:Create():Play().
--]]
local function _tween(ins, ti, goals)
    local t = TweenService:Create(ins, ti, goals)
    t:Play()
    return t
end

--[[
    _tweenPos(instance, position, duration)
    Shortcut for position tweens using Quart InOut.
--]]
local function _tweenPos(ins, pos, duration)
    return _tween(ins, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Position = pos})
end

--[[
    _tweenColor(instance, property, color, duration)
    Smooth color transitions.
--]]
local function _tweenColor(ins, prop, color, duration)
    local goals = {}
    goals[prop] = color
    return _tween(ins, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goals)
end

--[[
    _tweenTransparency(instance, property, value, duration)
--]]
local function _tweenTransparency(ins, prop, value, duration)
    local goals = {}
    goals[prop] = value
    return _tween(ins, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goals)
end

--[[
    _makeCorner(parent, radius)
    Adds a UICorner to a parent.
--]]
local function _makeCorner(parent, radius)
    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, radius or 9)
    uc.Parent = parent
    return uc
end

--[[
    _makeStroke(parent, color, thickness, trans)
    Adds a UIStroke to a parent.
--]]
local function _makeStroke(parent, color, thickness, trans)
    local us = Instance.new("UIStroke")
    us.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    us.Color = color or Color3.fromRGB(200, 200, 200)
    us.Thickness = thickness or 1
    us.Transparency = trans or 0
    us.Parent = parent
    return us
end

--[[
    _makeShadow(parent, zIndex, size, trans)
    Adds a drop-shadow ImageLabel behind a frame.
--]]
local function _makeShadow(parent, zIndex, size, trans)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "__shadow"
    shadow.Parent = parent
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = size or UDim2.new(1.20, 0, 1.20, 0)
    shadow.ZIndex = zIndex or 0
    shadow.Image = "rbxassetid://313486536"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = trans or 0.5
    shadow.TileSize = UDim2.new(0, 1, 0, 1)
    return shadow
end

--[[
    _makeListLayout(parent, direction, halign, valign, padding)
    Creates and parents a UIListLayout.
--]]
local function _makeListLayout(parent, direction, halign, valign, padding)
    local ull = Instance.new("UIListLayout")
    ull.FillDirection = direction or Enum.FillDirection.Vertical
    ull.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    ull.VerticalAlignment = valign or Enum.VerticalAlignment.Top
    ull.SortOrder = Enum.SortOrder.LayoutOrder
    ull.Padding = UDim.new(0, padding or 5)
    ull.Parent = parent
    return ull
end

--[[
    _makePadding(parent, top, bottom, left, right)
    Adds UIPadding to a parent.
--]]
local function _makePadding(parent, top, bottom, left, right)
    local up = Instance.new("UIPadding")
    up.PaddingTop    = UDim.new(0, top    or 0)
    up.PaddingBottom = UDim.new(0, bottom or 0)
    up.PaddingLeft   = UDim.new(0, left   or 0)
    up.PaddingRight  = UDim.new(0, right  or 0)
    up.Parent = parent
    return up
end

--[[
    _clamp(value, min, max)
--]]
local function _clamp(v, mn, mx)
    return math.max(mn, math.min(mx, v))
end

--[[
    _round(n, dec)
    Round to decimal places.
--]]
local function _round(n, dec)
    local m = 10 ^ (dec or 0)
    return math.floor(n * m + 0.5) / m
end

--[[
    _connect(signal, fn)
    Connects a signal and registers it for later cleanup.
--]]
local function _connect(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(_connections, conn)
    return conn
end

--[[
    _disconnectAll()
    Disconnects every registered connection.
--]]
local function _disconnectAll()
    for _, conn in ipairs(_connections) do
        pcall(function() conn:Disconnect() end)
    end
    _connections = {}
end

--[[
    _getGui()
    Returns the correct parent for the ScreenGui based on executor environment.
--]]
local function _getGui()
    if syn then
        return CoreGui
    elseif gethui then
        return gethui()
    else
        return CoreGui
    end
end

--[[
    _protectGui(sg)
    Protects the ScreenGui from detection if syn is available.
--]]
local function _protectGui(sg)
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(sg) end)
    end
end

--[[
    _labelFromBool(b)
--]]
local function _labelFromBool(b)
    return b and "Enabled" or "Disabled"
end

-- ─────────────────────────────────────────────────────────────────────────────
-- THEME API
-- ─────────────────────────────────────────────────────────────────────────────

--[[
    lib:RegisterTheme(name, themeTable)
    Adds a custom theme to the registry.

    Parameters:
        name (string)       - Unique name for your theme.
        themeTable (table)  - Table matching the THEMES structure above.

    Example:
        lib:RegisterTheme("Ocean", { Accent = Color3.fromRGB(0,180,200), ... })
--]]
function lib:RegisterTheme(name, themeTable)
    assert(type(name) == "string", "[AppleLib] Theme name must be a string.")
    assert(type(themeTable) == "table", "[AppleLib] Theme must be a table.")
    THEMES[name] = themeTable
end

--[[
    lib:SetTheme(name)
    Switches the active theme. Changes take effect on new elements.

    Parameters:
        name (string) - Name of a built-in or registered theme.
                        Built-ins: "Light", "Dark", "Midnight", "Rose"

    Example:
        lib:SetTheme("Dark")
--]]
function lib:SetTheme(name)
    assert(THEMES[name], "[AppleLib] Unknown theme: " .. tostring(name))
    _activeTheme = THEMES[name]
end

--[[
    lib:GetTheme()
    Returns the current active theme table.
--]]
function lib:GetTheme()
    return _activeTheme
end

--[[
    lib:GetThemeNames()
    Returns a list of all registered theme names.
--]]
function lib:GetThemeNames()
    local names = {}
    for k in pairs(THEMES) do
        table.insert(names, k)
    end
    table.sort(names)
    return names
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NOTIFICATION SYSTEM  (standalone toast-style, no window required)
-- ─────────────────────────────────────────────────────────────────────────────

local _toastQueue   = {}
local _toastRunning = false
local _toastHolder  = nil   -- initialised lazily

local function _ensureToastHolder()
    if _toastHolder and _toastHolder.Parent then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "AppleLibToasts"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _protectGui(gui)
    gui.Parent = _getGui()
    _toastHolder = gui
    _scrgui = _scrgui or gui
end

--[[
    lib:Toast(title, body, icon, duration)
    Shows a floating macOS-style toast notification.
    Does NOT require a window to be open.

    Parameters:
        title    (string)  - Bold title text.
        body     (string)  - Smaller body text below the title.
        icon     (string)  - Roblox asset id string for an icon image. Optional.
        duration (number)  - Seconds before auto-dismiss. Default 5.

    Example:
        lib:Toast("Script Loaded", "Apple Library V1 is ready!", "rbxassetid://4871684504", 4)
--]]
function lib:Toast(title, body, icon, duration)
    _ensureToastHolder()
    duration = duration or 5

    -- Shift existing toasts down
    for _, ch in ipairs(_toastHolder:GetChildren()) do
        if ch:IsA("Frame") and ch.Name == "AppleToast" then
            _tweenPos(ch, ch.Position + UDim2.new(0, 0, 0, 130), 0.3)
        end
    end

    local t = _activeTheme

    local toast = Instance.new("Frame")
    toast.Name = "AppleToast"
    toast.Parent = _toastHolder
    toast.AnchorPoint = Vector2.new(1, 0)
    toast.BackgroundColor3 = t.ToastBg
    toast.BackgroundTransparency = t.ToastTrans
    toast.Position = UDim2.new(1, -20, 0.08, 0)
    toast.Size = UDim2.new(0, 400, 0, 110)
    toast.ZIndex = 100

    _makeCorner(toast, 16)
    _makeShadow(toast, 99, UDim2.new(1.1, 0, 1.2, 0), 0.5)
    _makeStroke(toast, t.Separator, 1)

    -- Slide in
    toast.Position = UDim2.new(1, 430, 0.08, 0)
    _tweenPos(toast, UDim2.new(1, -20, 0.08, 0), 0.45)

    -- Icon
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Name = "icon"
    iconLabel.Parent = toast
    iconLabel.BackgroundTransparency = 1
    iconLabel.Position = UDim2.new(0, 14, 0.5, 0)
    iconLabel.AnchorPoint = Vector2.new(0, 0.5)
    iconLabel.Size = UDim2.new(0, 64, 0, 64)
    iconLabel.ZIndex = 101
    iconLabel.Image = icon or "rbxassetid://4871684504"
    iconLabel.ImageColor3 = t.SecondaryText
    iconLabel.ScaleType = Enum.ScaleType.Fit

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "title"
    titleLbl.Parent = toast
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 90, 0, 16)
    titleLbl.Size = UDim2.new(1, -100, 0, 28)
    titleLbl.ZIndex = 101
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title or ""
    titleLbl.TextColor3 = t.PrimaryText
    titleLbl.TextSize = 20
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd

    -- Body
    local bodyLbl = Instance.new("TextLabel")
    bodyLbl.Name = "body"
    bodyLbl.Parent = toast
    bodyLbl.BackgroundTransparency = 1
    bodyLbl.Position = UDim2.new(0, 90, 0, 46)
    bodyLbl.Size = UDim2.new(1, -100, 0, 52)
    bodyLbl.ZIndex = 101
    bodyLbl.Font = Enum.Font.Gotham
    bodyLbl.Text = body or ""
    bodyLbl.TextColor3 = t.SecondaryText
    bodyLbl.TextSize = 15
    bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
    bodyLbl.TextWrapped = true
    bodyLbl.TextYAlignment = Enum.TextYAlignment.Top

    -- Progress bar at bottom
    local progressBg = Instance.new("Frame")
    progressBg.Name = "progressbg"
    progressBg.Parent = toast
    progressBg.BackgroundColor3 = t.SliderTrack
    progressBg.BorderSizePixel = 0
    progressBg.Position = UDim2.new(0, 0, 1, -4)
    progressBg.Size = UDim2.new(1, 0, 0, 4)
    progressBg.ZIndex = 102
    _makeCorner(progressBg, 2)

    local progressFill = Instance.new("Frame")
    progressFill.Name = "fill"
    progressFill.Parent = progressBg
    progressFill.BackgroundColor3 = t.Accent
    progressFill.BorderSizePixel = 0
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.ZIndex = 103
    _makeCorner(progressFill, 2)

    _tween(progressFill,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 0, 1, 0)}
    )

    -- Dismiss button (×)
    local dismiss = Instance.new("TextButton")
    dismiss.Name = "dismiss"
    dismiss.Parent = toast
    dismiss.BackgroundTransparency = 1
    dismiss.Position = UDim2.new(1, -30, 0, 8)
    dismiss.Size = UDim2.new(0, 22, 0, 22)
    dismiss.ZIndex = 102
    dismiss.Font = Enum.Font.GothamMedium
    dismiss.Text = "×"
    dismiss.TextColor3 = t.SecondaryText
    dismiss.TextSize = 22

    local function _dismissToast()
        _tweenPos(toast, toast.Position + UDim2.new(0, 430, 0, 0), 0.3)
        Debris:AddItem(toast, 0.4)
    end

    dismiss.MouseButton1Click:Connect(_dismissToast)
    task.delay(duration, function()
        if toast and toast.Parent then
            _dismissToast()
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MAIN WINDOW INIT
-- ─────────────────────────────────────────────────────────────────────────────

--[[
    lib:init(title, doSplash, toggleKey, deletePrevious, themeName)

    Creates the main window and returns a window object.

    Parameters:
        title         (string)   - Text shown in the window title bar.
        doSplash      (boolean)  - Show the splash screen on startup.
        toggleKey     (KeyCode)  - Key to show/hide the window. e.g. Enum.KeyCode.RightShift
        deletePrevious(boolean)  - Destroy an existing AppleLib ScreenGui if found.
        themeName     (string)   - Starting theme name. Defaults to "Light".

    Returns:
        window (table) - The window object with methods to build the UI.

    Example:
        local win = lib:init("My Script", true, Enum.KeyCode.RightShift, true, "Dark")
--]]
function lib:init(title, doSplash, toggleKey, deletePrevious, themeName)

    -- Apply theme if provided
    if themeName and THEMES[themeName] then
        _activeTheme = THEMES[themeName]
    end

    local t = _activeTheme

    -- ── ScreenGui setup ──────────────────────────────────────────────────────
    local guiParent = _getGui()

    if deletePrevious then
        local existing = guiParent:FindFirstChild("AppleLibV1")
        if existing then
            local m = existing:FindFirstChild("main", true)
            if m then
                _tweenPos(m, m.Position + UDim2.new(0, 0, 2, 0), 0.5)
            end
            Debris:AddItem(existing, 0.7)
        end
    end

    local scrgui = Instance.new("ScreenGui")
    scrgui.Name = "AppleLibV1"
    scrgui.ResetOnSpawn = false
    scrgui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _protectGui(scrgui)
    scrgui.Parent = guiParent
    _scrgui = scrgui

    -- ── Splash screen ────────────────────────────────────────────────────────
    if doSplash then
        local splash = Instance.new("Frame")
        splash.Name = "splash"
        splash.Parent = scrgui
        splash.AnchorPoint = Vector2.new(0.5, 0.5)
        splash.BackgroundColor3 = t.Window
        splash.BackgroundTransparency = t.WindowTrans
        splash.Position = UDim2.new(0.5, 0, 2, 0)
        splash.Size = UDim2.new(0, 340, 0, 340)
        splash.ZIndex = 40
        _makeCorner(splash, 18)
        _makeShadow(splash, 39, UDim2.new(1.2, 0, 1.2, 0), 0.4)

        local sicon = Instance.new("ImageLabel")
        sicon.Name = "sicon"
        sicon.Parent = splash
        sicon.AnchorPoint = Vector2.new(0.5, 0.5)
        sicon.BackgroundTransparency = 1
        sicon.Position = UDim2.new(0.5, 0, 0.42, 0)
        sicon.Size = UDim2.new(0, 140, 0, 140)
        sicon.ZIndex = 41
        sicon.Image = "rbxassetid://12621719043"
        sicon.ScaleType = Enum.ScaleType.Fit

        local splashTitle = Instance.new("TextLabel")
        splashTitle.Name = "splashTitle"
        splashTitle.Parent = splash
        splashTitle.BackgroundTransparency = 1
        splashTitle.AnchorPoint = Vector2.new(0.5, 0)
        splashTitle.Position = UDim2.new(0.5, 0, 0.68, 0)
        splashTitle.Size = UDim2.new(0.85, 0, 0, 30)
        splashTitle.ZIndex = 41
        splashTitle.Font = Enum.Font.GothamMedium
        splashTitle.Text = title or "Apple Library"
        splashTitle.TextColor3 = t.TitleText
        splashTitle.TextSize = 22
        splashTitle.TextTruncate = Enum.TextTruncate.AtEnd

        local splashSub = Instance.new("TextLabel")
        splashSub.Name = "splashSub"
        splashSub.Parent = splash
        splashSub.BackgroundTransparency = 1
        splashSub.AnchorPoint = Vector2.new(0.5, 0)
        splashSub.Position = UDim2.new(0.5, 0, 0.80, 0)
        splashSub.Size = UDim2.new(0.85, 0, 0, 22)
        splashSub.ZIndex = 41
        splashSub.Font = Enum.Font.Gotham
        splashSub.Text = "by Kyrubureibu  ·  " .. lib.Version
        splashSub.TextColor3 = t.SecondaryText
        splashSub.TextSize = 15

        _tweenPos(splash, UDim2.new(0.5, 0, 0.5, 0), 0.9)
        task.wait(2.4)
        _tweenPos(splash, UDim2.new(0.5, 0, 2, 0), 0.7)
        Debris:AddItem(splash, 0.9)
        task.wait(0.3)
    end

    -- ── Main frame ───────────────────────────────────────────────────────────
    local main = Instance.new("Frame")
    main.Name = "main"
    main.Parent = scrgui
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = t.Window
    main.BackgroundTransparency = t.WindowTrans
    main.Position = UDim2.new(0.5, 0, 2, 0)
    main.Size = UDim2.new(0, 780, 0, 600)
    main.ClipsDescendants = false
    _makeCorner(main, 18)
    _makeShadow(main, -1, UDim2.new(1.06, 0, 1.06, 0), 0.3)

    -- ── Dragging ─────────────────────────────────────────────────────────────
    local dragging, dragInput, dragStart, startPos

    local function _updateDrag(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            _updateDrag(input)
        end
    end)

    -- ── Top bar ──────────────────────────────────────────────────────────────
    local topbar = Instance.new("Frame")
    topbar.Name = "topbar"
    topbar.Parent = main
    topbar.BackgroundTransparency = 1
    topbar.Size = UDim2.new(1, 0, 0, 54)
    topbar.ZIndex = 5

    -- Traffic-light buttons
    local trafficFrame = Instance.new("Frame")
    trafficFrame.Name = "trafficlights"
    trafficFrame.Parent = topbar
    trafficFrame.BackgroundTransparency = 1
    trafficFrame.Position = UDim2.new(0, 16, 0.5, 0)
    trafficFrame.AnchorPoint = Vector2.new(0, 0.5)
    trafficFrame.Size = UDim2.new(0, 80, 0, 20)
    _makeListLayout(trafficFrame, Enum.FillDirection.Horizontal,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center, 8)

    local function _makeTrafficBtn(name, color)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Parent = trafficFrame
        btn.BackgroundColor3 = color
        btn.Size = UDim2.new(0, 16, 0, 16)
        btn.AutoButtonColor = false
        btn.Font = Enum.Font.SourceSans
        btn.Text = ""
        btn.TextSize = 14
        btn.ZIndex = 6
        _makeCorner(btn, 9)

        -- Hover highlight
        btn.MouseEnter:Connect(function()
            _tweenColor(btn, "BackgroundColor3",
                Color3.new(btn.BackgroundColor3.R + 0.1,
                           btn.BackgroundColor3.G + 0.1,
                           btn.BackgroundColor3.B + 0.1), 0.1)
        end)
        btn.MouseLeave:Connect(function()
            _tweenColor(btn, "BackgroundColor3", color, 0.15)
        end)
        return btn
    end

    local closeBtn    = _makeTrafficBtn("close",    t.CloseBtn)
    local minimizeBtn = _makeTrafficBtn("minimize", t.MinBtn)
    local maximizeBtn = _makeTrafficBtn("maximize", t.MaxBtn)

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "title"
    titleLbl.Parent = topbar
    titleLbl.BackgroundTransparency = 1
    titleLbl.AnchorPoint = Vector2.new(0.5, 0.5)
    titleLbl.Position = UDim2.new(0.5, 0, 0.5, 0)
    titleLbl.Size = UDim2.new(0.5, 0, 0, 28)
    titleLbl.ZIndex = 6
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title or "Apple Library"
    titleLbl.TextColor3 = t.TitleText
    titleLbl.TextSize = 20
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd

    -- Version badge
    local versionBadge = Instance.new("TextLabel")
    versionBadge.Name = "versionBadge"
    versionBadge.Parent = topbar
    versionBadge.BackgroundColor3 = t.Accent
    versionBadge.Position = UDim2.new(1, -90, 0.5, 0)
    versionBadge.AnchorPoint = Vector2.new(0, 0.5)
    versionBadge.Size = UDim2.new(0, 70, 0, 22)
    versionBadge.ZIndex = 6
    versionBadge.Font = Enum.Font.GothamMedium
    versionBadge.Text = lib.Version
    versionBadge.TextColor3 = t.AccentText
    versionBadge.TextSize = 13
    _makeCorner(versionBadge, 6)

    -- Divider under topbar
    local topDivider = Instance.new("Frame")
    topDivider.Name = "topDivider"
    topDivider.Parent = main
    topDivider.BackgroundColor3 = t.Separator
    topDivider.BorderSizePixel = 0
    topDivider.Position = UDim2.new(0, 0, 0, 54)
    topDivider.Size = UDim2.new(1, 0, 0, 1)

    -- ── Sidebar ──────────────────────────────────────────────────────────────
    local sidebar = Instance.new("Frame")
    sidebar.Name = "sidebar"
    sidebar.Parent = main
    sidebar.BackgroundColor3 = t.Sidebar
    sidebar.BackgroundTransparency = 1
    sidebar.Position = UDim2.new(0, 0, 0, 55)
    sidebar.Size = UDim2.new(0, 220, 1, -55)

    -- Vertical divider between sidebar and workarea
    local sideDivider = Instance.new("Frame")
    sideDivider.Name = "sideDivider"
    sideDivider.Parent = main
    sideDivider.BackgroundColor3 = t.Separator
    sideDivider.BorderSizePixel = 0
    sideDivider.Position = UDim2.new(0, 220, 0, 55)
    sideDivider.Size = UDim2.new(0, 1, 1, -55)

    -- Search bar
    local searchContainer = Instance.new("Frame")
    searchContainer.Name = "searchContainer"
    searchContainer.Parent = sidebar
    searchContainer.BackgroundColor3 = t.InputBg
    searchContainer.Position = UDim2.new(0, 12, 0, 10)
    searchContainer.Size = UDim2.new(1, -24, 0, 34)
    _makeCorner(searchContainer, 9)
    _makeStroke(searchContainer, t.Separator, 1)

    local searchIcon = Instance.new("ImageButton")
    searchIcon.Name = "searchIcon"
    searchIcon.Parent = searchContainer
    searchIcon.BackgroundTransparency = 1
    searchIcon.Position = UDim2.new(0, 8, 0.5, 0)
    searchIcon.AnchorPoint = Vector2.new(0, 0.5)
    searchIcon.Size = UDim2.new(0, 20, 0, 20)
    searchIcon.Image = "rbxassetid://2804603863"
    searchIcon.ImageColor3 = t.SecondaryText
    searchIcon.ScaleType = Enum.ScaleType.Fit

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "searchBox"
    searchBox.Parent = searchContainer
    searchBox.BackgroundTransparency = 1
    searchBox.Position = UDim2.new(0, 34, 0, 0)
    searchBox.Size = UDim2.new(1, -42, 1, 0)
    searchBox.ClearTextOnFocus = false
    searchBox.Font = Enum.Font.Gotham
    searchBox.LineHeight = 0.87
    searchBox.PlaceholderText = "Search"
    searchBox.PlaceholderColor3 = t.PlaceholderText
    searchBox.Text = ""
    searchBox.TextColor3 = t.PrimaryText
    searchBox.TextSize = 15
    searchBox.TextXAlignment = Enum.TextXAlignment.Left

    searchIcon.MouseButton1Click:Connect(function()
        searchBox:CaptureFocus()
    end)

    -- Sidebar scrolling list
    local sidebarList = Instance.new("ScrollingFrame")
    sidebarList.Name = "sidebarList"
    sidebarList.Parent = sidebar
    sidebarList.Active = true
    sidebarList.BackgroundTransparency = 1
    sidebarList.BorderSizePixel = 0
    sidebarList.Position = UDim2.new(0, 0, 0, 54)
    sidebarList.Size = UDim2.new(1, 0, 1, -60)
    sidebarList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebarList.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebarList.ScrollBarThickness = 2
    sidebarList.ScrollBarImageColor3 = t.Accent
    _makeListLayout(sidebarList, Enum.FillDirection.Vertical,
        Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 3)
    _makePadding(sidebarList, 6, 6, 0, 0)

    -- Search filter
    RunService:BindToRenderStep("AppleLibSearch_" .. tostring(os.clock()), 1, function()
        if not searchBox:IsFocused() then
            for _, ch in ipairs(sidebarList:GetChildren()) do
                if ch:IsA("TextButton") then ch.Visible = true end
            end
            return
        end
        local query = string.upper(searchBox.Text)
        for _, ch in ipairs(sidebarList:GetChildren()) do
            if ch:IsA("TextButton") then
                ch.Visible = (query == "" or string.find(string.upper(ch.Text), query, 1, true) ~= nil)
            end
        end
    end)

    -- ── Workarea ─────────────────────────────────────────────────────────────
    local workareaOuter = Instance.new("Frame")
    workareaOuter.Name = "workareaOuter"
    workareaOuter.Parent = main
    workareaOuter.BackgroundColor3 = t.Workarea
    workareaOuter.BackgroundTransparency = 1
    workareaOuter.Position = UDim2.new(0, 221, 0, 55)
    workareaOuter.Size = UDim2.new(1, -221, 1, -55)
    workareaOuter.ClipsDescendants = true

    -- ── Close / Minimize / Maximize logic ────────────────────────────────────
    local _guiVisible = true
    local _toggleDebounce = false

    local function _doToggle()
        if _toggleDebounce then return end
        _toggleDebounce = true
        _guiVisible = not _guiVisible
        if _guiVisible then
            _tweenPos(main, UDim2.new(0.5, 0, 0.5, 0), 0.45)
        else
            _tweenPos(main, main.Position + UDim2.new(0, 0, 2, 0), 0.45)
        end
        task.wait(0.5)
        _toggleDebounce = false
    end

    closeBtn.MouseButton1Click:Connect(function()
        _tweenPos(main, main.Position + UDim2.new(0, 0, 2, 0), 0.4)
        task.wait(0.5)
        scrgui:Destroy()
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        _doToggle()
    end)

    if toggleKey then
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == toggleKey then
                _doToggle()
            end
        end)
    end

    -- ── Window object ────────────────────────────────────────────────────────
    local _sectionList   = {}   -- {tabBtn, contentFrame}
    local _sectionObjs   = {}   -- sidebar tab buttons array for selection highlight

    local window = {}
    window._scrgui  = scrgui
    window._main    = main

    -- Slide in
    _tweenPos(main, UDim2.new(0.5, 0, 0.5, 0), 0.9)

    -- ── window:ToggleVisible() ────────────────────────────────────────────────
    --[[
        Programmatically shows or hides the main window.
        Same as pressing the toggleKey.

        Example:
            win:ToggleVisible()
    --]]
    function window:ToggleVisible()
        _doToggle()
    end

    -- ── window:SetTitle(text) ─────────────────────────────────────────────────
    --[[
        Changes the window title bar text.

        Parameters:
            text (string) - New title.

        Example:
            win:SetTitle("Updated Title")
    --]]
    function window:SetTitle(text)
        titleLbl.Text = tostring(text)
    end

    -- ── window:GreenButton(callback) ─────────────────────────────────────────
    --[[
        Assigns a callback to the green (maximize) traffic-light button.

        Parameters:
            callback (function) - Called when the green button is clicked.

        Example:
            win:GreenButton(function()
                print("Green clicked")
            end)
    --]]
    function window:GreenButton(callback)
        if _G.__applelib_green then
            pcall(function() _G.__applelib_green:Disconnect() end)
        end
        _G.__applelib_green = maximizeBtn.MouseButton1Click:Connect(function()
            callback()
        end)
    end

    -- ── window:Destroy() ─────────────────────────────────────────────────────
    --[[
        Destroys the entire GUI immediately.

        Example:
            win:Destroy()
    --]]
    function window:Destroy()
        _tweenPos(main, main.Position + UDim2.new(0, 0, 2, 0), 0.4)
        task.wait(0.5)
        scrgui:Destroy()
    end

    -- ── window:Toast(...) ─────────────────────────────────────────────────────
    --[[
        Shortcut to show a toast from the window object.
    --]]
    function window:Toast(...)
        lib:Toast(...)
    end

    -- ──────────────────────────────────────────────────────────────────────────
    -- MODAL NOTIFICATIONS
    -- ──────────────────────────────────────────────────────────────────────────

    -- Shared overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "overlay"
    overlay.Parent = main
    overlay.AnchorPoint = Vector2.new(0.5, 0.5)
    overlay.BackgroundColor3 = t.NotifDarken
    overlay.BackgroundTransparency = 0.45
    overlay.Position = UDim2.new(0.5, 0, 0.5, 0)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.ZIndex = 10
    overlay.Visible = false
    _makeCorner(overlay, 18)

    local function _showOverlay() overlay.Visible = true end
    local function _hideOverlay() overlay.Visible = false end

    -- ── Single-button modal ───────────────────────────────────────────────────
    local modal1 = Instance.new("Frame")
    modal1.Name = "modal1"
    modal1.Parent = main
    modal1.AnchorPoint = Vector2.new(0.5, 0.5)
    modal1.BackgroundColor3 = t.NotifBg
    modal1.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal1.Size = UDim2.new(0, 310, 0, 370)
    modal1.Visible = false
    modal1.ZIndex = 11
    _makeCorner(modal1, 18)
    _makeShadow(modal1, 10, UDim2.new(1.18, 0, 1.18, 0), 0.45)

    local m1Icon = Instance.new("ImageLabel")
    m1Icon.Parent = modal1
    m1Icon.BackgroundTransparency = 1
    m1Icon.AnchorPoint = Vector2.new(0.5, 0)
    m1Icon.Position = UDim2.new(0.5, 0, 0, 28)
    m1Icon.Size = UDim2.new(0, 90, 0, 90)
    m1Icon.ZIndex = 12
    m1Icon.Image = "rbxassetid://4871684504"
    m1Icon.ImageColor3 = t.Accent
    m1Icon.ScaleType = Enum.ScaleType.Fit

    local m1Title = Instance.new("TextLabel")
    m1Title.Parent = modal1
    m1Title.BackgroundTransparency = 1
    m1Title.AnchorPoint = Vector2.new(0.5, 0)
    m1Title.Position = UDim2.new(0.5, 0, 0, 132)
    m1Title.Size = UDim2.new(0.85, 0, 0, 36)
    m1Title.ZIndex = 12
    m1Title.Font = Enum.Font.GothamMedium
    m1Title.Text = "Notice"
    m1Title.TextColor3 = t.PrimaryText
    m1Title.TextSize = 22
    m1Title.TextTruncate = Enum.TextTruncate.AtEnd

    local m1Body = Instance.new("TextLabel")
    m1Body.Parent = modal1
    m1Body.BackgroundTransparency = 1
    m1Body.AnchorPoint = Vector2.new(0.5, 0)
    m1Body.Position = UDim2.new(0.5, 0, 0, 172)
    m1Body.Size = UDim2.new(0.85, 0, 0, 70)
    m1Body.ZIndex = 12
    m1Body.Font = Enum.Font.Gotham
    m1Body.Text = ""
    m1Body.TextColor3 = t.SecondaryText
    m1Body.TextSize = 15
    m1Body.TextWrapped = true

    local m1Btn = Instance.new("TextButton")
    m1Btn.Parent = modal1
    m1Btn.AnchorPoint = Vector2.new(0.5, 1)
    m1Btn.BackgroundColor3 = t.Accent
    m1Btn.Position = UDim2.new(0.5, 0, 1, -22)
    m1Btn.Size = UDim2.new(0.82, 0, 0, 46)
    m1Btn.ZIndex = 12
    m1Btn.Font = Enum.Font.GothamMedium
    m1Btn.Text = "OK"
    m1Btn.TextColor3 = t.AccentText
    m1Btn.TextSize = 18
    _makeCorner(m1Btn, 10)

    local _m1conn
    --[[
        window:Notify(title, body, buttonText, icon, callback)
        Shows a single-button modal dialog.

        Parameters:
            title      (string)   - Bold modal title.
            body       (string)   - Descriptive body text.
            buttonText (string)   - Label for the confirm button.
            icon       (string)   - Roblox asset id for the icon. Optional.
            callback   (function) - Called when the button is pressed.

        Example:
            win:Notify("Warning", "This will reset your settings.", "Got it",
                "rbxassetid://4871684504", function()
                    print("Acknowledged")
                end)
    --]]
    function window:Notify(t1, t2, b1, icon, callback)
        if modal1.Visible or modal2.Visible then return end
        m1Title.Text = t1 or "Notice"
        m1Body.Text  = t2 or ""
        m1Btn.Text   = b1 or "OK"
        if icon then m1Icon.Image = icon end
        _showOverlay()
        modal1.Visible = true
        if _m1conn then _m1conn:Disconnect() end
        _m1conn = m1Btn.MouseButton1Click:Connect(function()
            modal1.Visible = false
            _hideOverlay()
            if callback then callback() end
        end)
    end

    -- ── Two-button modal ──────────────────────────────────────────────────────
    local modal2 = Instance.new("Frame")
    modal2.Name = "modal2"
    modal2.Parent = main
    modal2.AnchorPoint = Vector2.new(0.5, 0.5)
    modal2.BackgroundColor3 = t.NotifBg
    modal2.Position = UDim2.new(0.5, 0, 0.5, 0)
    modal2.Size = UDim2.new(0, 310, 0, 400)
    modal2.Visible = false
    modal2.ZIndex = 11
    _makeCorner(modal2, 18)
    _makeShadow(modal2, 10, UDim2.new(1.18, 0, 1.18, 0), 0.45)

    local m2Icon = Instance.new("ImageLabel")
    m2Icon.Parent = modal2
    m2Icon.BackgroundTransparency = 1
    m2Icon.AnchorPoint = Vector2.new(0.5, 0)
    m2Icon.Position = UDim2.new(0.5, 0, 0, 28)
    m2Icon.Size = UDim2.new(0, 90, 0, 90)
    m2Icon.ZIndex = 12
    m2Icon.Image = "rbxassetid://12608260095"
    m2Icon.ImageColor3 = t.Accent
    m2Icon.ScaleType = Enum.ScaleType.Fit

    local m2Title = Instance.new("TextLabel")
    m2Title.Parent = modal2
    m2Title.BackgroundTransparency = 1
    m2Title.AnchorPoint = Vector2.new(0.5, 0)
    m2Title.Position = UDim2.new(0.5, 0, 0, 132)
    m2Title.Size = UDim2.new(0.85, 0, 0, 36)
    m2Title.ZIndex = 12
    m2Title.Font = Enum.Font.GothamMedium
    m2Title.Text = "Notice"
    m2Title.TextColor3 = t.PrimaryText
    m2Title.TextSize = 22

    local m2Body = Instance.new("TextLabel")
    m2Body.Parent = modal2
    m2Body.BackgroundTransparency = 1
    m2Body.AnchorPoint = Vector2.new(0.5, 0)
    m2Body.Position = UDim2.new(0.5, 0, 0, 172)
    m2Body.Size = UDim2.new(0.85, 0, 0, 70)
    m2Body.ZIndex = 12
    m2Body.Font = Enum.Font.Gotham
    m2Body.Text = ""
    m2Body.TextColor3 = t.SecondaryText
    m2Body.TextSize = 15
    m2Body.TextWrapped = true

    local m2Btn1 = Instance.new("TextButton")
    m2Btn1.Parent = modal2
    m2Btn1.AnchorPoint = Vector2.new(0.5, 1)
    m2Btn1.BackgroundColor3 = t.Accent
    m2Btn1.Position = UDim2.new(0.5, 0, 1, -72)
    m2Btn1.Size = UDim2.new(0.82, 0, 0, 46)
    m2Btn1.ZIndex = 12
    m2Btn1.Font = Enum.Font.GothamMedium
    m2Btn1.Text = "Yes"
    m2Btn1.TextColor3 = t.AccentText
    m2Btn1.TextSize = 18
    _makeCorner(m2Btn1, 10)

    local m2Btn2 = Instance.new("TextButton")
    m2Btn2.Parent = modal2
    m2Btn2.AnchorPoint = Vector2.new(0.5, 1)
    m2Btn2.BackgroundColor3 = t.ButtonBg
    m2Btn2.Position = UDim2.new(0.5, 0, 1, -18)
    m2Btn2.Size = UDim2.new(0.82, 0, 0, 46)
    m2Btn2.ZIndex = 12
    m2Btn2.Font = Enum.Font.GothamMedium
    m2Btn2.Text = "No"
    m2Btn2.TextColor3 = t.SecondaryText
    m2Btn2.TextSize = 18
    _makeCorner(m2Btn2, 10)

    local _m2conn1, _m2conn2
    --[[
        window:Notify2(title, body, btn1Text, btn2Text, icon, cb1, cb2)
        Shows a two-button modal dialog (e.g. "Yes / No").

        Parameters:
            title    (string)   - Bold title.
            body     (string)   - Body text.
            btn1Text (string)   - Primary button label.
            btn2Text (string)   - Secondary button label.
            icon     (string)   - Roblox asset id. Optional.
            cb1      (function) - Called when btn1 is clicked.
            cb2      (function) - Called when btn2 is clicked.

        Example:
            win:Notify2("Confirm", "Are you sure you want to reset?",
                "Yes, Reset", "Cancel", "rbxassetid://12608260095",
                function() resetAll() end,
                function() print("Cancelled") end)
    --]]
    function window:Notify2(t1, t2, b1, b2, icon, cb1, cb2)
        if modal1.Visible or modal2.Visible then return end
        m2Title.Text = t1 or "Notice"
        m2Body.Text  = t2 or ""
        m2Btn1.Text  = b1 or "Yes"
        m2Btn2.Text  = b2 or "No"
        if icon then m2Icon.Image = icon end
        _showOverlay()
        modal2.Visible = true
        if _m2conn1 then _m2conn1:Disconnect() end
        if _m2conn2 then _m2conn2:Disconnect() end
        _m2conn1 = m2Btn1.MouseButton1Click:Connect(function()
            modal2.Visible = false
            _hideOverlay()
            if cb1 then cb1() end
        end)
        _m2conn2 = m2Btn2.MouseButton1Click:Connect(function()
            modal2.Visible = false
            _hideOverlay()
            if cb2 then cb2() end
        end)
    end

    -- ──────────────────────────────────────────────────────────────────────────
    -- SIDEBAR HELPERS
    -- ──────────────────────────────────────────────────────────────────────────

    --[[
        window:Divider(name)
        Adds a small category label inside the sidebar.

        Parameters:
            name (string) - The category label text.

        Example:
            win:Divider("Combat")
            win:Divider("Visuals")
    --]]
    function window:Divider(name)
        local lbl = Instance.new("TextLabel")
        lbl.Name = "sidebarDivider"
        lbl.Parent = sidebarList
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -16, 0, 24)
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = string.upper(name or "")
        lbl.TextColor3 = t.SecondaryText
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        _makePadding(lbl, 0, 0, 10, 0)
    end

    -- ──────────────────────────────────────────────────────────────────────────
    -- SECTION (TAB)
    -- ──────────────────────────────────────────────────────────────────────────

    --[[
        window:Section(name)
        Creates a new sidebar tab and its associated content panel.

        Parameters:
            name (string) - The label shown on the sidebar button.

        Returns:
            sec (table) - Section object. Call sec:Select() to switch to it,
                          or use sec:Button(), sec:Switch(), etc. to add elements.

        Example:
            local combatTab = win:Section("Combat")
            local visualsTab = win:Section("Visuals")
            combatTab:Select()   -- make Combat active by default
    --]]
    function window:Section(name)
        local t = _activeTheme

        -- Sidebar tab button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "tabBtn_" .. (name or "Section")
        tabBtn.Parent = sidebarList
        tabBtn.BackgroundColor3 = t.Accent
        tabBtn.BackgroundTransparency = 1
        tabBtn.Size = UDim2.new(1, -16, 0, 38)
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 3
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.Text = name or "Section"
        tabBtn.TextColor3 = t.PrimaryText
        tabBtn.TextSize = 16
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        _makeCorner(tabBtn, 9)
        _makePadding(tabBtn, 0, 0, 12, 0)
        table.insert(_sectionObjs, tabBtn)

        -- Content scrolling frame
        local content = Instance.new("ScrollingFrame")
        content.Name = "sectionContent_" .. (name or "Section")
        content.Parent = workareaOuter
        content.Active = true
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.Position = UDim2.new(0, 18, 0, 12)
        content.Size = UDim2.new(1, -36, 1, -24)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.ScrollBarThickness = 2
        content.ScrollBarImageColor3 = t.Accent
        content.Visible = false
        content.ZIndex = 2
        _makeListLayout(content, Enum.FillDirection.Vertical,
            Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 6)
        _makePadding(content, 4, 4, 0, 0)

        table.insert(_sectionList, {tab = tabBtn, content = content})

        local sec = {}

        -- ── sec:Select() ──────────────────────────────────────────────────────
        --[[
            Switches the visible panel to this section and highlights its tab.
        --]]
        function sec:Select()
            for _, entry in ipairs(_sectionList) do
                entry.tab.BackgroundTransparency = 1
                entry.tab.TextColor3 = t.PrimaryText
                entry.content.Visible = false
            end
            tabBtn.BackgroundTransparency = 0
            tabBtn.TextColor3 = t.AccentText
            content.Visible = true
        end

        tabBtn.MouseButton1Click:Connect(function()
            sec:Select()
        end)

        -- Hover effect
        tabBtn.MouseEnter:Connect(function()
            if tabBtn.BackgroundTransparency ~= 0 then
                tabBtn.BackgroundTransparency = 0.88
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if tabBtn.BackgroundTransparency ~= 0 then
                tabBtn.BackgroundTransparency = 1
            end
        end)

        -- ── ELEMENT CONSTRUCTORS ──────────────────────────────────────────────

        -- ── sec:Divider(name) ─────────────────────────────────────────────────
        --[[
            Adds a section divider / heading label inside the content panel.

            Parameters:
                name (string) - Heading text.

            Example:
                tab:Divider("Aim Settings")
        --]]
        function sec:Divider(name)
            local lbl = Instance.new("TextLabel")
            lbl.Name = "divider"
            lbl.Parent = content
            lbl.BackgroundTransparency = 1
            lbl.BorderSizePixel = 0
            lbl.Size = UDim2.new(1, 0, 0, 44)
            lbl.Font = Enum.Font.GothamMedium
            lbl.LineHeight = 1.18
            lbl.Text = name or ""
            lbl.TextColor3 = t.PrimaryText
            lbl.TextSize = 22
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Bottom

            local line = Instance.new("Frame")
            line.Name = "line"
            line.Parent = lbl
            line.BackgroundColor3 = t.Separator
            line.BorderSizePixel = 0
            line.AnchorPoint = Vector2.new(0, 1)
            line.Position = UDim2.new(0, 0, 1, 0)
            line.Size = UDim2.new(1, 0, 0, 1)
        end

        -- ── sec:Label(name) ───────────────────────────────────────────────────
        --[[
            Adds a read-only text label inside the panel.

            Parameters:
                name (string) - Label text.

            Example:
                tab:Label("Version: 1.0.0")
        --]]
        function sec:Label(name)
            local lbl = Instance.new("TextLabel")
            lbl.Name = "label"
            lbl.Parent = content
            lbl.BackgroundTransparency = 1
            lbl.BorderSizePixel = 0
            lbl.Size = UDim2.new(1, 0, 0, 36)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = name or ""
            lbl.TextColor3 = t.SecondaryText
            lbl.TextSize = 16
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local obj = {}
            --[[
                label:Set(text)
                Updates the label text.
            --]]
            function obj:Set(text) lbl.Text = tostring(text) end
            function obj:Get() return lbl.Text end
            return obj
        end

        -- ── sec:Button(name, description, callback) ───────────────────────────
        --[[
            Adds a clickable button element.

            Parameters:
                name        (string)   - Button label text.
                description (string)   - Smaller subtitle text. Optional.
                callback    (function) - Called when clicked.

            Returns:
                obj (table) - { SetText(t), SetDescription(t), SetEnabled(b) }

            Example:
                tab:Button("Teleport to Spawn", "TP to the game spawn point", function()
                    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(0,0,0))
                end)
        --]]
        function sec:Button(name, description, callback)
            -- Support old 2-arg style: Button(name, callback)
            if type(description) == "function" then
                callback = description
                description = nil
            end

            local row = Instance.new("Frame")
            row.Name = "buttonRow"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, description and 54 or 40)
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local btn = Instance.new("TextButton")
            btn.Name = "button"
            btn.Parent = row
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.ZIndex = 3
            btn.Font = Enum.Font.Gotham
            btn.Text = ""
            btn.AutoButtonColor = false

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name = "name"
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, description and 8 or 0)
            nameLbl.Size = UDim2.new(0.7, -14, 0, 26)
            nameLbl.ZIndex = 3
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Button"
            nameLbl.TextColor3 = t.Accent
            nameLbl.TextSize = 17
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

            if description then
                local descLbl = Instance.new("TextLabel")
                descLbl.Name = "desc"
                descLbl.Parent = row
                descLbl.BackgroundTransparency = 1
                descLbl.Position = UDim2.new(0, 14, 0, 30)
                descLbl.Size = UDim2.new(0.7, -14, 0, 18)
                descLbl.ZIndex = 3
                descLbl.Font = Enum.Font.Gotham
                descLbl.Text = description
                descLbl.TextColor3 = t.SecondaryText
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
                descLbl.TextTruncate = Enum.TextTruncate.AtEnd
            end

            -- Right arrow
            local arrow = Instance.new("TextLabel")
            arrow.Name = "arrow"
            arrow.Parent = row
            arrow.BackgroundTransparency = 1
            arrow.AnchorPoint = Vector2.new(1, 0.5)
            arrow.Position = UDim2.new(1, -12, 0.5, 0)
            arrow.Size = UDim2.new(0, 20, 0, 20)
            arrow.ZIndex = 3
            arrow.Font = Enum.Font.GothamMedium
            arrow.Text = "›"
            arrow.TextColor3 = t.Accent
            arrow.TextSize = 26

            -- Hover / click feedback
            btn.MouseEnter:Connect(function()
                _tweenTransparency(row, "BackgroundTransparency", 0.35, 0.12)
            end)
            btn.MouseLeave:Connect(function()
                _tweenTransparency(row, "BackgroundTransparency", 0.55, 0.12)
            end)

            btn.MouseButton1Click:Connect(function()
                -- Pulse animation
                coroutine.wrap(function()
                    _tweenTransparency(row, "BackgroundTransparency", 0.15, 0.08)
                    task.wait(0.12)
                    _tweenTransparency(row, "BackgroundTransparency", 0.55, 0.15)
                end)()
                if callback then
                    coroutine.wrap(callback)()
                end
            end)

            local obj = {}
            function obj:SetText(text) nameLbl.Text = tostring(text) end
            function obj:SetEnabled(enabled)
                btn.Active = enabled
                nameLbl.TextColor3 = enabled and t.Accent or t.SecondaryText
                arrow.TextColor3   = enabled and t.Accent or t.SecondaryText
            end
            return obj
        end

        -- ── sec:Switch(name, description, default, callback) ──────────────────
        --[[
            Adds an iOS-style toggle switch.

            Parameters:
                name        (string)   - Label text.
                description (string)   - Subtitle text. Optional.
                default     (boolean)  - Initial state. true = ON, false = OFF.
                callback    (function) - Called with (state:boolean) on change.

            Returns:
                obj (table) - { Set(b), Get() → bool }

            Example:
                tab:Switch("God Mode", "Become invincible", false, function(state)
                    setGodMode(state)
                end)
        --]]
        function sec:Switch(name, description, default, callback)
            -- Old 3-arg: Switch(name, default, callback)
            if type(description) == "boolean" then
                callback = default
                default = description
                description = nil
            end

            local state = default == true

            local row = Instance.new("Frame")
            row.Name = "switchRow"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, description and 54 or 40)
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name = "name"
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, description and 8 or 0)
            nameLbl.Size = UDim2.new(0.65, -14, 0, 26)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Switch"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 17
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            if description then
                local descLbl = Instance.new("TextLabel")
                descLbl.Parent = row
                descLbl.BackgroundTransparency = 1
                descLbl.Position = UDim2.new(0, 14, 0, 30)
                descLbl.Size = UDim2.new(0.65, -14, 0, 18)
                descLbl.Font = Enum.Font.Gotham
                descLbl.Text = description
                descLbl.TextColor3 = t.SecondaryText
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
            end

            -- Track
            local track = Instance.new("TextButton")
            track.Name = "track"
            track.Parent = row
            track.AnchorPoint = Vector2.new(1, 0.5)
            track.Position = UDim2.new(1, -14, 0.5, 0)
            track.Size = UDim2.new(0, 56, 0, 30)
            track.AutoButtonColor = false
            track.Text = ""
            track.BackgroundColor3 = state and t.SwitchOn or t.SwitchOff
            _makeCorner(track, 15)

            -- Thumb
            local thumb = Instance.new("Frame")
            thumb.Name = "thumb"
            thumb.Parent = track
            thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            thumb.AnchorPoint = Vector2.new(0, 0.5)
            thumb.Position = state and UDim2.new(0, 28, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            thumb.Size = UDim2.new(0, 26, 0, 26)
            _makeCorner(thumb, 13)
            _makeShadow(thumb, 1, UDim2.new(1.3, 0, 1.3, 0), 0.55)

            local function _applyState(s)
                state = s
                _tweenPos(thumb, s and UDim2.new(0, 28, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), 0.18)
                _tweenColor(track, "BackgroundColor3", s and t.SwitchOn or t.SwitchOff, 0.18)
            end

            local function _toggle()
                _applyState(not state)
                if callback then coroutine.wrap(function() callback(state) end)() end
            end

            track.MouseButton1Click:Connect(_toggle)
            thumb.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    _toggle()
                end
            end)

            local obj = {}
            function obj:Set(val)
                _applyState(val == true)
                if callback then coroutine.wrap(function() callback(state) end)() end
            end
            function obj:Get() return state end
            return obj
        end

        -- ── sec:Slider(name, description, min, max, default, step, callback) ──
        --[[
            Adds a horizontal slider element.

            Parameters:
                name        (string)   - Label text.
                description (string)   - Subtitle text. Optional. Pass nil to skip.
                min         (number)   - Minimum value.
                max         (number)   - Maximum value.
                default     (number)   - Starting value.
                step        (number)   - Snap increment. Use 0 or nil for smooth.
                callback    (function) - Called with (value:number) on change.

            Returns:
                obj (table) - { Set(v), Get() → number }

            Example:
                tab:Slider("Walk Speed", "Player movement speed", 0, 100, 16, 1,
                    function(val)
                        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
                    end)
        --]]
        function sec:Slider(name, description, min, max, default, step, callback)
            min     = min     or 0
            max     = max     or 100
            default = default or min
            step    = step    or 0
            local value = _clamp(default, min, max)

            local row = Instance.new("Frame")
            row.Name = "sliderRow"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, description and 66 or 54)
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, 8)
            nameLbl.Size = UDim2.new(0.6, -14, 0, 22)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Slider"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel")
            valLbl.Parent = row
            valLbl.BackgroundTransparency = 1
            valLbl.AnchorPoint = Vector2.new(1, 0)
            valLbl.Position = UDim2.new(1, -14, 0, 8)
            valLbl.Size = UDim2.new(0.35, 0, 0, 22)
            valLbl.Font = Enum.Font.GothamMedium
            valLbl.Text = tostring(_round(value, 2))
            valLbl.TextColor3 = t.Accent
            valLbl.TextSize = 16
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            if description then
                local descLbl = Instance.new("TextLabel")
                descLbl.Parent = row
                descLbl.BackgroundTransparency = 1
                descLbl.Position = UDim2.new(0, 14, 0, 28)
                descLbl.Size = UDim2.new(0.8, -14, 0, 14)
                descLbl.Font = Enum.Font.Gotham
                descLbl.Text = description
                descLbl.TextColor3 = t.SecondaryText
                descLbl.TextSize = 11
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
            end

            local trackY = description and 48 or 36
            local track = Instance.new("Frame")
            track.Name = "track"
            track.Parent = row
            track.BackgroundColor3 = t.SliderTrack
            track.BorderSizePixel = 0
            track.Position = UDim2.new(0, 14, 0, trackY)
            track.Size = UDim2.new(1, -28, 0, 6)
            _makeCorner(track, 3)

            local fill = Instance.new("Frame")
            fill.Name = "fill"
            fill.Parent = track
            fill.BackgroundColor3 = t.SliderFill
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            _makeCorner(fill, 3)

            local knob = Instance.new("Frame")
            knob.Name = "knob"
            knob.Parent = track
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
            knob.Size = UDim2.new(0, 18, 0, 18)
            knob.ZIndex = 2
            _makeCorner(knob, 9)
            _makeStroke(knob, t.SliderFill, 2)
            _makeShadow(knob, 1, UDim2.new(1.5, 0, 1.5, 0), 0.55)

            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Parent = row
            sliderBtn.BackgroundTransparency = 1
            sliderBtn.Position = UDim2.new(0, 0, 0, trackY - 12)
            sliderBtn.Size = UDim2.new(1, 0, 0, 30)
            sliderBtn.Text = ""
            sliderBtn.ZIndex = 4

            local draggingSlider = false

            local function _updateSlider(inputX)
                local trackAbsPos  = track.AbsolutePosition.X
                local trackAbsSize = track.AbsoluteSize.X
                local rel = _clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
                local raw = min + rel * (max - min)
                if step and step > 0 then
                    raw = math.floor((raw - min) / step + 0.5) * step + min
                end
                value = _clamp(raw, min, max)
                local t2 = (value - min) / (max - min)
                fill.Size = UDim2.new(t2, 0, 1, 0)
                knob.Position = UDim2.new(t2, 0, 0.5, 0)
                valLbl.Text = tostring(_round(value, 2))
                if callback then coroutine.wrap(function() callback(value) end)() end
            end

            sliderBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    _updateSlider(inp.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(inp)
                if draggingSlider and (inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch) then
                    _updateSlider(inp.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            local obj = {}
            function obj:Set(v)
                value = _clamp(v, min, max)
                local pct = (value - min) / (max - min)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
                valLbl.Text = tostring(_round(value, 2))
            end
            function obj:Get() return value end
            return obj
        end

        -- ── sec:TextField(name, placeholder, default, callback) ───────────────
        --[[
            Adds a text input field element.

            Parameters:
                name        (string)   - Label text on the left.
                placeholder (string)   - Grey placeholder text inside the box.
                default     (string)   - Pre-filled text. Optional.
                callback    (function) - Called with (text:string) on FocusLost.

            Returns:
                obj (table) - { Set(text), Get() → string }

            Example:
                tab:TextField("Player Name", "Enter username...", "", function(val)
                    print("Searching for:", val)
                end)
        --]]
        function sec:TextField(name, placeholder, default, callback)
            local row = Instance.new("Frame")
            row.Name = "textfieldRow"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, 40)
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, 0)
            nameLbl.Size = UDim2.new(0.38, -14, 1, 0)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Input"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

            local inputBg = Instance.new("Frame")
            inputBg.Parent = row
            inputBg.BackgroundColor3 = t.InputBg
            inputBg.AnchorPoint = Vector2.new(1, 0.5)
            inputBg.Position = UDim2.new(1, -10, 0.5, 0)
            inputBg.Size = UDim2.new(0.58, 0, 0, 28)
            _makeCorner(inputBg, 7)
            _makeStroke(inputBg, t.Separator, 1, 0.3)

            local textbox = Instance.new("TextBox")
            textbox.Name = "textbox"
            textbox.Parent = inputBg
            textbox.BackgroundTransparency = 1
            textbox.Position = UDim2.new(0, 8, 0, 0)
            textbox.Size = UDim2.new(1, -16, 1, 0)
            textbox.ClearTextOnFocus = false
            textbox.Font = Enum.Font.Gotham
            textbox.PlaceholderText = placeholder or "Type..."
            textbox.PlaceholderColor3 = t.PlaceholderText
            textbox.Text = default or ""
            textbox.TextColor3 = t.PrimaryText
            textbox.TextSize = 14
            textbox.TextXAlignment = Enum.TextXAlignment.Left

            textbox.Focused:Connect(function()
                _makeStroke(inputBg, t.Accent, 1.5)
            end)
            textbox.FocusLost:Connect(function()
                _makeStroke(inputBg, t.Separator, 1, 0.3)
                if callback then coroutine.wrap(function() callback(textbox.Text) end)() end
            end)

            local obj = {}
            function obj:Set(text) textbox.Text = tostring(text) end
            function obj:Get() return textbox.Text end
            return obj
        end

        -- ── sec:Dropdown(name, description, options, default, callback) ────────
        --[[
            Adds a dropdown selector.

            Parameters:
                name        (string)   - Label text.
                description (string)   - Subtitle. Optional, pass nil to skip.
                options     (table)    - Array of string options.
                default     (string)   - Pre-selected option. Optional.
                callback    (function) - Called with (selected:string) on change.

            Returns:
                obj (table) - { Set(option), Get() → string, Refresh(opts) }

            Example:
                tab:Dropdown("Team", nil, {"Attackers","Defenders","Spectators"},
                    "Attackers", function(v)
                        joinTeam(v)
                    end)
        --]]
        function sec:Dropdown(name, description, options, default, callback)
            local selected = default or (options and options[1]) or ""
            local open = false

            local container = Instance.new("Frame")
            container.Name = "dropdownContainer"
            container.Parent = content
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1, 0, 0, description and 54 or 40)
            container.ClipsDescendants = false
            container.ZIndex = 8

            local row = Instance.new("Frame")
            row.Name = "dropdownRow"
            row.Parent = container
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 1, 0)
            row.ZIndex = 8
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, description and 8 or 0)
            nameLbl.Size = UDim2.new(0.5, -14, 0, 26)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Dropdown"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            if description then
                local descLbl = Instance.new("TextLabel")
                descLbl.Parent = row
                descLbl.BackgroundTransparency = 1
                descLbl.Position = UDim2.new(0, 14, 0, 30)
                descLbl.Size = UDim2.new(0.5, -14, 0, 18)
                descLbl.Font = Enum.Font.Gotham
                descLbl.Text = description
                descLbl.TextColor3 = t.SecondaryText
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
            end

            -- Selected value pill
            local pill = Instance.new("Frame")
            pill.Parent = row
            pill.BackgroundColor3 = t.Accent
            pill.BackgroundTransparency = 0.85
            pill.AnchorPoint = Vector2.new(1, 0.5)
            pill.Position = UDim2.new(1, -36, 0.5, 0)
            pill.Size = UDim2.new(0.45, 0, 0, 24)
            pill.ZIndex = 9
            _makeCorner(pill, 7)

            local selectedLbl = Instance.new("TextLabel")
            selectedLbl.Parent = pill
            selectedLbl.BackgroundTransparency = 1
            selectedLbl.Size = UDim2.new(1, -8, 1, 0)
            selectedLbl.Position = UDim2.new(0, 4, 0, 0)
            selectedLbl.Font = Enum.Font.Gotham
            selectedLbl.Text = selected
            selectedLbl.TextColor3 = t.Accent
            selectedLbl.TextSize = 13
            selectedLbl.TextTruncate = Enum.TextTruncate.AtEnd
            selectedLbl.ZIndex = 10

            -- Chevron
            local chevron = Instance.new("TextLabel")
            chevron.Parent = row
            chevron.BackgroundTransparency = 1
            chevron.AnchorPoint = Vector2.new(1, 0.5)
            chevron.Position = UDim2.new(1, -10, 0.5, 0)
            chevron.Size = UDim2.new(0, 20, 0, 20)
            chevron.Font = Enum.Font.GothamMedium
            chevron.Text = "⌄"
            chevron.TextColor3 = t.SecondaryText
            chevron.TextSize = 18
            chevron.ZIndex = 9

            -- Panel
            local panel = Instance.new("ScrollingFrame")
            panel.Name = "dropdownPanel"
            panel.Parent = container
            panel.BackgroundColor3 = t.DropdownBg
            panel.BorderSizePixel = 0
            panel.Position = UDim2.new(0, 0, 1, 4)
            panel.Size = UDim2.new(1, 0, 0, 0)
            panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
            panel.CanvasSize = UDim2.new(0, 0, 0, 0)
            panel.ScrollBarThickness = 2
            panel.ScrollBarImageColor3 = t.Accent
            panel.ZIndex = 20
            panel.Visible = false
            panel.ClipsDescendants = true
            _makeCorner(panel, 10)
            _makeStroke(panel, t.Separator, 1, 0.3)
            _makeListLayout(panel, Enum.FillDirection.Vertical,
                Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 2)
            _makePadding(panel, 4, 4, 0, 0)

            local function _buildOptions(opts)
                for _, ch in ipairs(panel:GetChildren()) do
                    if ch:IsA("TextButton") then ch:Destroy() end
                end
                for _, opt in ipairs(opts or {}) do
                    local item = Instance.new("TextButton")
                    item.Name = "option_" .. opt
                    item.Parent = panel
                    item.BackgroundColor3 = t.DropdownItem
                    item.BackgroundTransparency = 1
                    item.Size = UDim2.new(1, -8, 0, 34)
                    item.Font = Enum.Font.Gotham
                    item.Text = opt
                    item.TextColor3 = (opt == selected) and t.Accent or t.PrimaryText
                    item.TextSize = 15
                    item.ZIndex = 21
                    _makeCorner(item, 7)

                    item.MouseEnter:Connect(function()
                        _tweenTransparency(item, "BackgroundTransparency", 0.75, 0.1)
                    end)
                    item.MouseLeave:Connect(function()
                        _tweenTransparency(item, "BackgroundTransparency", 1, 0.1)
                    end)
                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        selectedLbl.Text = opt
                        -- Update colours of all option items
                        for _, ch in ipairs(panel:GetChildren()) do
                            if ch:IsA("TextButton") then
                                ch.TextColor3 = (ch.Text == selected) and t.Accent or t.PrimaryText
                            end
                        end
                        -- Close
                        open = false
                        chevron.Text = "⌄"
                        _tween(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                        task.wait(0.22)
                        panel.Visible = false
                        if callback then coroutine.wrap(function() callback(selected) end)() end
                    end)
                end
            end
            _buildOptions(options)

            local headerBtn = Instance.new("TextButton")
            headerBtn.Parent = row
            headerBtn.BackgroundTransparency = 1
            headerBtn.Size = UDim2.new(1, 0, 1, 0)
            headerBtn.Text = ""
            headerBtn.ZIndex = 10

            headerBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    panel.Visible = true
                    chevron.Text = "⌃"
                    local targetH = math.min(#(options or {}) * 36 + 8, 200)
                    _tween(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Size = UDim2.new(1, 0, 0, targetH)})
                else
                    chevron.Text = "⌄"
                    _tween(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Size = UDim2.new(1, 0, 0, 0)})
                    task.delay(0.22, function() if not open then panel.Visible = false end end)
                end
            end)

            local obj = {}
            function obj:Set(opt)
                selected = opt
                selectedLbl.Text = opt
                for _, ch in ipairs(panel:GetChildren()) do
                    if ch:IsA("TextButton") then
                        ch.TextColor3 = (ch.Text == opt) and t.Accent or t.PrimaryText
                    end
                end
            end
            function obj:Get() return selected end
            function obj:Refresh(opts)
                options = opts
                _buildOptions(opts)
            end
            return obj
        end

        -- ── sec:ColorPicker(name, description, default, callback) ─────────────
        --[[
            Adds a colour picker element (HSV wheel via sliders).

            Parameters:
                name        (string)   - Label text.
                description (string)   - Subtitle. Optional.
                default     (Color3)   - Starting colour. Default: red.
                callback    (function) - Called with (color:Color3) on change.

            Returns:
                obj (table) - { Set(c3), Get() → Color3 }

            Example:
                tab:ColorPicker("ESP Colour", nil, Color3.fromRGB(255,0,0),
                    function(c)
                        setESPColor(c)
                    end)
        --]]
        function sec:ColorPicker(name, description, default, callback)
            default = default or Color3.fromRGB(255, 0, 0)
            local h, s, v = Color3.toHSV(default)
            local currentColor = default

            local row = Instance.new("Frame")
            row.Name = "colorPickerRow"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, description and 54 or 40)
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, description and 8 or 0)
            nameLbl.Size = UDim2.new(0.55, -14, 0, 26)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Color"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            if description then
                local descLbl = Instance.new("TextLabel")
                descLbl.Parent = row
                descLbl.BackgroundTransparency = 1
                descLbl.Position = UDim2.new(0, 14, 0, 30)
                descLbl.Size = UDim2.new(0.55, -14, 0, 18)
                descLbl.Font = Enum.Font.Gotham
                descLbl.Text = description
                descLbl.TextColor3 = t.SecondaryText
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
            end

            -- Colour swatch
            local swatch = Instance.new("TextButton")
            swatch.Name = "swatch"
            swatch.Parent = row
            swatch.BackgroundColor3 = currentColor
            swatch.AnchorPoint = Vector2.new(1, 0.5)
            swatch.Position = UDim2.new(1, -14, 0.5, 0)
            swatch.Size = UDim2.new(0, 56, 0, 28)
            swatch.Text = ""
            swatch.ZIndex = 4
            _makeCorner(swatch, 8)
            _makeStroke(swatch, t.Separator, 1, 0.3)

            -- Expanded picker panel
            local pickerPanel = Instance.new("Frame")
            pickerPanel.Name = "pickerPanel"
            pickerPanel.Parent = content
            pickerPanel.BackgroundColor3 = t.DropdownBg
            pickerPanel.BackgroundTransparency = 0.4
            pickerPanel.BorderSizePixel = 0
            pickerPanel.Size = UDim2.new(1, 0, 0, 0)
            pickerPanel.ClipsDescendants = true
            pickerPanel.ZIndex = 9
            pickerPanel.Visible = false
            _makeCorner(pickerPanel, 10)
            _makeStroke(pickerPanel, t.Separator, 1, 0.3)

            local pickerOpen = false

            local function _buildPicker()
                for _, ch in ipairs(pickerPanel:GetChildren()) do ch:Destroy() end
                pickerPanel.Size = UDim2.new(1, 0, 0, 130)

                local function _makeHSVSlider(label, yPos, initial, maxVal, sliderCallback)
                    local sliderLbl = Instance.new("TextLabel")
                    sliderLbl.Parent = pickerPanel
                    sliderLbl.BackgroundTransparency = 1
                    sliderLbl.Position = UDim2.new(0, 14, 0, yPos)
                    sliderLbl.Size = UDim2.new(0.18, 0, 0, 18)
                    sliderLbl.Font = Enum.Font.Gotham
                    sliderLbl.Text = label
                    sliderLbl.TextColor3 = t.SecondaryText
                    sliderLbl.TextSize = 12
                    sliderLbl.ZIndex = 10

                    local sTrack = Instance.new("Frame")
                    sTrack.Parent = pickerPanel
                    sTrack.BackgroundColor3 = t.SliderTrack
                    sTrack.Position = UDim2.new(0.22, 0, 0, yPos + 6)
                    sTrack.Size = UDim2.new(0.6, 0, 0, 6)
                    sTrack.ZIndex = 10
                    _makeCorner(sTrack, 3)

                    local sFill = Instance.new("Frame")
                    sFill.Parent = sTrack
                    sFill.BackgroundColor3 = t.SliderFill
                    sFill.BorderSizePixel = 0
                    sFill.Size = UDim2.new(initial / maxVal, 0, 1, 0)
                    sFill.ZIndex = 11
                    _makeCorner(sFill, 3)

                    local sKnob = Instance.new("Frame")
                    sKnob.Parent = sTrack
                    sKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    sKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                    sKnob.Position = UDim2.new(initial / maxVal, 0, 0.5, 0)
                    sKnob.Size = UDim2.new(0, 14, 0, 14)
                    sKnob.ZIndex = 12
                    _makeCorner(sKnob, 7)
                    _makeStroke(sKnob, t.Accent, 1.5)

                    local sValLbl = Instance.new("TextLabel")
                    sValLbl.Parent = pickerPanel
                    sValLbl.BackgroundTransparency = 1
                    sValLbl.AnchorPoint = Vector2.new(1, 0)
                    sValLbl.Position = UDim2.new(1, -14, 0, yPos)
                    sValLbl.Size = UDim2.new(0.15, 0, 0, 18)
                    sValLbl.Font = Enum.Font.GothamMedium
                    sValLbl.Text = tostring(_round(initial * (maxVal == 1 and 100 or 1), 0))
                    sValLbl.TextColor3 = t.Accent
                    sValLbl.TextSize = 12
                    sValLbl.TextXAlignment = Enum.TextXAlignment.Right
                    sValLbl.ZIndex = 10

                    local sBtn = Instance.new("TextButton")
                    sBtn.Parent = pickerPanel
                    sBtn.BackgroundTransparency = 1
                    sBtn.Position = UDim2.new(0.22, -6, 0, yPos - 6)
                    sBtn.Size = UDim2.new(0.6, 12, 0, 24)
                    sBtn.Text = ""
                    sBtn.ZIndex = 13

                    local dragS = false
                    sBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1
                        or inp.UserInputType == Enum.UserInputType.Touch then
                            dragS = true
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragS = false end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if dragS and (inp.UserInputType == Enum.UserInputType.MouseMovement
                        or inp.UserInputType == Enum.UserInputType.Touch) then
                            local tAbs = sTrack.AbsolutePosition.X
                            local tSz  = sTrack.AbsoluteSize.X
                            local rel  = _clamp((inp.Position.X - tAbs) / tSz, 0, 1)
                            sFill.Size = UDim2.new(rel, 0, 1, 0)
                            sKnob.Position = UDim2.new(rel, 0, 0.5, 0)
                            sValLbl.Text = tostring(_round(rel * (maxVal == 1 and 100 or 1), 0))
                            sliderCallback(rel * maxVal)
                        end
                    end)
                end

                local function _refreshColor()
                    currentColor = Color3.fromHSV(h, s, v)
                    swatch.BackgroundColor3 = currentColor
                    if callback then coroutine.wrap(function() callback(currentColor) end)() end
                end

                _makeHSVSlider("H", 10,  h, 1, function(val) h = val _refreshColor() end)
                _makeHSVSlider("S", 46,  s, 1, function(val) s = val _refreshColor() end)
                _makeHSVSlider("V", 82,  v, 1, function(val) v = val _refreshColor() end)
            end

            swatch.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    pickerPanel.Visible = true
                    _buildPicker()
                    _tween(pickerPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 130)})
                else
                    _tween(pickerPanel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)})
                    task.delay(0.22, function() pickerPanel.Visible = false end)
                end
            end)

            local obj = {}
            function obj:Set(c3)
                currentColor = c3
                swatch.BackgroundColor3 = c3
                h, s, v = Color3.toHSV(c3)
            end
            function obj:Get() return currentColor end
            return obj
        end

        -- ── sec:Keybind(name, description, default, callback) ─────────────────
        --[[
            Adds a keybind configurator element.

            Parameters:
                name        (string)   - Label text.
                description (string)   - Subtitle. Optional.
                default     (KeyCode)  - Default key. e.g. Enum.KeyCode.F.
                callback    (function) - Called with (keyCode) when key is pressed.

            Returns:
                obj (table) - { Set(keyCode), Get() → KeyCode }

            Example:
                tab:Keybind("Toggle ESP", nil, Enum.KeyCode.Z, function(k)
                    -- activated whenever Z is pressed
                    toggleESP()
                end)
        --]]
        function sec:Keybind(name, description, default, callback)
            local boundKey = default or Enum.KeyCode.Unknown
            local listening = false

            local row = Instance.new("Frame")
            row.Name = "keybindRow"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, description and 54 or 40)
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, description and 8 or 0)
            nameLbl.Size = UDim2.new(0.55, -14, 0, 26)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Keybind"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            if description then
                local descLbl = Instance.new("TextLabel")
                descLbl.Parent = row
                descLbl.BackgroundTransparency = 1
                descLbl.Position = UDim2.new(0, 14, 0, 30)
                descLbl.Size = UDim2.new(0.55, -14, 0, 18)
                descLbl.Font = Enum.Font.Gotham
                descLbl.Text = description
                descLbl.TextColor3 = t.SecondaryText
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
            end

            local keyPill = Instance.new("TextButton")
            keyPill.Name = "keyPill"
            keyPill.Parent = row
            keyPill.BackgroundColor3 = t.InputBg
            keyPill.AnchorPoint = Vector2.new(1, 0.5)
            keyPill.Position = UDim2.new(1, -14, 0.5, 0)
            keyPill.Size = UDim2.new(0, 80, 0, 26)
            keyPill.Font = Enum.Font.GothamMedium
            keyPill.Text = boundKey.Name
            keyPill.TextColor3 = t.Accent
            keyPill.TextSize = 13
            keyPill.ZIndex = 4
            _makeCorner(keyPill, 7)
            _makeStroke(keyPill, t.Accent, 1, 0.4)

            keyPill.MouseButton1Click:Connect(function()
                listening = true
                keyPill.Text = "..."
                keyPill.TextColor3 = t.SecondaryText
            end)

            UserInputService.InputBegan:Connect(function(inp, gpe)
                if listening then
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        boundKey = inp.KeyCode
                        keyPill.Text = boundKey.Name
                        keyPill.TextColor3 = t.Accent
                        listening = false
                    end
                    return
                end
                if not gpe and inp.KeyCode == boundKey then
                    if callback then coroutine.wrap(callback)() end
                end
            end)

            local obj = {}
            function obj:Set(kc)
                boundKey = kc
                keyPill.Text = kc.Name
            end
            function obj:Get() return boundKey end
            return obj
        end

        -- ── sec:ProgressBar(name, description, default, max) ──────────────────
        --[[
            Adds a read-only progress bar element.

            Parameters:
                name        (string) - Label text.
                description (string) - Subtitle. Optional.
                default     (number) - Starting progress value (0 to max).
                max         (number) - Maximum value. Default 100.

            Returns:
                obj (table) - { Set(v), Get() → number, SetMax(m) }

            Example:
                local xpBar = tab:ProgressBar("Experience", "Current XP", 420, 1000)
                xpBar:Set(550)
        --]]
        function sec:ProgressBar(name, description, default, maxVal)
            maxVal = maxVal or 100
            local value = _clamp(default or 0, 0, maxVal)

            local row = Instance.new("Frame")
            row.Name = "progressBarRow"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, description and 60 or 48)
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, 8)
            nameLbl.Size = UDim2.new(0.7, -14, 0, 22)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Progress"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel")
            valLbl.Parent = row
            valLbl.BackgroundTransparency = 1
            valLbl.AnchorPoint = Vector2.new(1, 0)
            valLbl.Position = UDim2.new(1, -14, 0, 8)
            valLbl.Size = UDim2.new(0.28, 0, 0, 22)
            valLbl.Font = Enum.Font.GothamMedium
            valLbl.Text = tostring(_round(value, 1)) .. " / " .. tostring(maxVal)
            valLbl.TextColor3 = t.SecondaryText
            valLbl.TextSize = 13
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            if description then
                local descLbl = Instance.new("TextLabel")
                descLbl.Parent = row
                descLbl.BackgroundTransparency = 1
                descLbl.Position = UDim2.new(0, 14, 0, 28)
                descLbl.Size = UDim2.new(0.8, -14, 0, 14)
                descLbl.Font = Enum.Font.Gotham
                descLbl.Text = description
                descLbl.TextColor3 = t.SecondaryText
                descLbl.TextSize = 11
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
            end

            local trackY = description and 46 or 34
            local track = Instance.new("Frame")
            track.Name = "track"
            track.Parent = row
            track.BackgroundColor3 = t.ProgressBg
            track.BorderSizePixel = 0
            track.Position = UDim2.new(0, 14, 0, trackY)
            track.Size = UDim2.new(1, -28, 0, 8)
            _makeCorner(track, 4)

            local fill = Instance.new("Frame")
            fill.Name = "fill"
            fill.Parent = track
            fill.BackgroundColor3 = t.Progress
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new(_clamp(value / maxVal, 0, 1), 0, 1, 0)
            _makeCorner(fill, 4)

            local obj = {}
            function obj:Set(v)
                value = _clamp(v, 0, maxVal)
                local pct = value / maxVal
                _tween(fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(pct, 0, 1, 0)})
                valLbl.Text = tostring(_round(value, 1)) .. " / " .. tostring(maxVal)
            end
            function obj:Get() return value end
            function obj:SetMax(m)
                maxVal = m
                self:Set(value)
            end
            return obj
        end

        -- ── sec:Spacer(height) ────────────────────────────────────────────────
        --[[
            Adds empty vertical space inside a section panel.

            Parameters:
                height (number) - Height in pixels. Default 16.

            Example:
                tab:Spacer(24)
        --]]
        function sec:Spacer(height)
            local sp = Instance.new("Frame")
            sp.Name = "spacer"
            sp.Parent = content
            sp.BackgroundTransparency = 1
            sp.Size = UDim2.new(1, 0, 0, height or 16)
        end

        -- ── sec:Badge(name, text, color) ──────────────────────────────────────
        --[[
            Adds a label row with a coloured badge / tag on the right side.
            Useful for showing statuses like "Online", "Beta", etc.

            Parameters:
                name  (string)  - Label text.
                text  (string)  - Badge text.
                color (Color3)  - Badge background colour. Optional, defaults to t.Badge.

            Returns:
                obj (table) - { SetBadge(text, color), SetName(text) }

            Example:
                tab:Badge("Anti-Cheat Status", "Bypassed", Color3.fromRGB(52,199,89))
        --]]
        function sec:Badge(name, badgeText, color)
            local row = Instance.new("Frame")
            row.Name = "badgeRow"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, 40)
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, 0)
            nameLbl.Size = UDim2.new(0.6, -14, 1, 0)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or ""
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            local badge = Instance.new("Frame")
            badge.Parent = row
            badge.BackgroundColor3 = color or t.Badge
            badge.AnchorPoint = Vector2.new(1, 0.5)
            badge.Position = UDim2.new(1, -14, 0.5, 0)
            badge.Size = UDim2.new(0, 80, 0, 22)
            _makeCorner(badge, 11)

            local badgeLbl = Instance.new("TextLabel")
            badgeLbl.Parent = badge
            badgeLbl.BackgroundTransparency = 1
            badgeLbl.Size = UDim2.new(1, -8, 1, 0)
            badgeLbl.Position = UDim2.new(0, 4, 0, 0)
            badgeLbl.Font = Enum.Font.GothamMedium
            badgeLbl.Text = badgeText or ""
            badgeLbl.TextColor3 = t.BadgeText
            badgeLbl.TextSize = 13
            badgeLbl.TextTruncate = Enum.TextTruncate.AtEnd

            local obj = {}
            function obj:SetBadge(text, c)
                badgeLbl.Text = tostring(text)
                if c then badge.BackgroundColor3 = c end
            end
            function obj:SetName(text) nameLbl.Text = tostring(text) end
            return obj
        end

        -- ── sec:MultiSwitch(name, options, defaults, callback) ────────────────
        --[[
            Adds a row of segmented toggle buttons (mutually exclusive selection).

            Parameters:
                name     (string)   - Label text.
                options  (table)    - Array of strings for each segment.
                default  (string)   - Initially selected option.
                callback (function) - Called with (selected:string) on change.

            Returns:
                obj (table) - { Set(option), Get() → string }

            Example:
                tab:MultiSwitch("Aim Bone", {"Head","Neck","Chest","Pelvis"},
                    "Head", function(v)
                        setAimBone(v)
                    end)
        --]]
        function sec:MultiSwitch(name, options, default, callback)
            local selected = default or (options and options[1]) or ""

            local outer = Instance.new("Frame")
            outer.Name = "multiSwitchOuter"
            outer.Parent = content
            outer.BackgroundColor3 = t.ButtonBg
            outer.BackgroundTransparency = 0.55
            outer.BorderSizePixel = 0
            outer.Size = UDim2.new(1, 0, 0, 70)
            _makeCorner(outer, 10)
            _makeStroke(outer, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = outer
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, 8)
            nameLbl.Size = UDim2.new(1, -28, 0, 22)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Segment"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 15
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            local segContainer = Instance.new("Frame")
            segContainer.Parent = outer
            segContainer.BackgroundColor3 = t.SliderTrack
            segContainer.BackgroundTransparency = 0.4
            segContainer.Position = UDim2.new(0, 14, 0, 34)
            segContainer.Size = UDim2.new(1, -28, 0, 26)
            _makeCorner(segContainer, 8)

            local segList = Instance.new("UIListLayout")
            segList.Parent = segContainer
            segList.FillDirection = Enum.FillDirection.Horizontal
            segList.SortOrder = Enum.SortOrder.LayoutOrder

            local buttons = {}
            local function _updateSeg()
                for _, btnObj in ipairs(buttons) do
                    local isSelected = (btnObj.lbl.Text == selected)
                    btnObj.bg.BackgroundTransparency = isSelected and 0 or 1
                    btnObj.lbl.TextColor3 = isSelected and t.AccentText or t.SecondaryText
                    btnObj.lbl.Font = isSelected and Enum.Font.GothamMedium or Enum.Font.Gotham
                end
            end

            for i, opt in ipairs(options or {}) do
                local segBg = Instance.new("TextButton")
                segBg.Name = "seg_" .. opt
                segBg.Parent = segContainer
                segBg.BackgroundColor3 = t.Accent
                segBg.BackgroundTransparency = 1
                segBg.Size = UDim2.new(1 / #options, 0, 1, 0)
                segBg.Text = ""
                segBg.AutoButtonColor = false
                _makeCorner(segBg, 7)

                local segLbl = Instance.new("TextLabel")
                segLbl.Parent = segBg
                segLbl.BackgroundTransparency = 1
                segLbl.Size = UDim2.new(1, 0, 1, 0)
                segLbl.Font = Enum.Font.Gotham
                segLbl.Text = opt
                segLbl.TextColor3 = (opt == selected) and t.AccentText or t.SecondaryText
                segLbl.TextSize = 12
                segLbl.TextTruncate = Enum.TextTruncate.AtEnd

                table.insert(buttons, {bg = segBg, lbl = segLbl})

                segBg.MouseButton1Click:Connect(function()
                    selected = opt
                    _updateSeg()
                    if callback then coroutine.wrap(function() callback(selected) end)() end
                end)
            end
            _updateSeg()

            local obj = {}
            function obj:Set(opt)
                selected = opt
                _updateSeg()
            end
            function obj:Get() return selected end
            return obj
        end

        -- ── sec:Image(assetId, height) ────────────────────────────────────────
        --[[
            Embeds an image inside the section panel.

            Parameters:
                assetId (string) - Roblox asset id, e.g. "rbxassetid://1234567890".
                height  (number) - Display height in pixels. Default 120.

            Example:
                tab:Image("rbxassetid://12621719043", 160)
        --]]
        function sec:Image(assetId, height)
            height = height or 120
            local imgFrame = Instance.new("Frame")
            imgFrame.Parent = content
            imgFrame.BackgroundTransparency = 1
            imgFrame.Size = UDim2.new(1, 0, 0, height)

            local img = Instance.new("ImageLabel")
            img.Parent = imgFrame
            img.BackgroundTransparency = 1
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.Position = UDim2.new(0.5, 0, 0.5, 0)
            img.Size = UDim2.new(1, -28, 1, -10)
            img.Image = assetId or ""
            img.ScaleType = Enum.ScaleType.Fit
            _makeCorner(img, 10)

            local obj = {}
            function obj:SetImage(id) img.Image = id end
            return obj
        end

        -- ── sec:TextArea(name, default, callback) ─────────────────────────────
        --[[
            Adds a multi-line text area element.

            Parameters:
                name        (string)   - Label above the text area.
                default     (string)   - Pre-filled text. Optional.
                callback    (function) - Called with (text:string) on FocusLost.

            Returns:
                obj (table) - { Set(text), Get() → string }

            Example:
                tab:TextArea("Script", "print('Hello')", function(code)
                    loadstring(code)()
                end)
        --]]
        function sec:TextArea(name, default, callback)
            local outer = Instance.new("Frame")
            outer.Parent = content
            outer.BackgroundColor3 = t.ButtonBg
            outer.BackgroundTransparency = 0.55
            outer.Size = UDim2.new(1, 0, 0, 130)
            _makeCorner(outer, 10)
            _makeStroke(outer, t.Separator, 1, 0.5)

            local hdr = Instance.new("TextLabel")
            hdr.Parent = outer
            hdr.BackgroundTransparency = 1
            hdr.Position = UDim2.new(0, 12, 0, 6)
            hdr.Size = UDim2.new(1, -24, 0, 20)
            hdr.Font = Enum.Font.GothamMedium
            hdr.Text = name or "Text Area"
            hdr.TextColor3 = t.SecondaryText
            hdr.TextSize = 12
            hdr.TextXAlignment = Enum.TextXAlignment.Left

            local inputBg = Instance.new("Frame")
            inputBg.Parent = outer
            inputBg.BackgroundColor3 = t.InputBg
            inputBg.Position = UDim2.new(0, 10, 0, 28)
            inputBg.Size = UDim2.new(1, -20, 1, -36)
            _makeCorner(inputBg, 8)
            _makeStroke(inputBg, t.Separator, 1, 0.3)

            local tb = Instance.new("TextBox")
            tb.Parent = inputBg
            tb.BackgroundTransparency = 1
            tb.Position = UDim2.new(0, 8, 0, 6)
            tb.Size = UDim2.new(1, -16, 1, -12)
            tb.ClearTextOnFocus = false
            tb.MultiLine = true
            tb.Font = Enum.Font.Code
            tb.PlaceholderText = "Enter text..."
            tb.PlaceholderColor3 = t.PlaceholderText
            tb.Text = default or ""
            tb.TextColor3 = t.PrimaryText
            tb.TextSize = 13
            tb.TextXAlignment = Enum.TextXAlignment.Left
            tb.TextYAlignment = Enum.TextYAlignment.Top

            tb.Focused:Connect(function() _makeStroke(inputBg, t.Accent, 1.5) end)
            tb.FocusLost:Connect(function()
                _makeStroke(inputBg, t.Separator, 1, 0.3)
                if callback then coroutine.wrap(function() callback(tb.Text) end)() end
            end)

            local obj = {}
            function obj:Set(text) tb.Text = tostring(text) end
            function obj:Get() return tb.Text end
            return obj
        end

        -- ── sec:Separator() ───────────────────────────────────────────────────
        --[[
            Adds a thin horizontal line separator.

            Example:
                tab:Separator()
        --]]
        function sec:Separator()
            local line = Instance.new("Frame")
            line.Name = "separator"
            line.Parent = content
            line.BackgroundColor3 = t.Separator
            line.BorderSizePixel = 0
            line.Size = UDim2.new(1, 0, 0, 1)
        end

        -- ── sec:NumericStepper(name, description, min, max, step, default, callback)
        --[[
            Adds a +/- stepper element for choosing integer or stepped values.

            Parameters:
                name        (string)   - Label.
                description (string)   - Subtitle. Optional.
                min         (number)   - Minimum value.
                max         (number)   - Maximum value.
                step        (number)   - Increment per click. Default 1.
                default     (number)   - Starting value.
                callback    (function) - Called with (value:number) on change.

            Returns:
                obj (table) - { Set(v), Get() → number }

            Example:
                tab:NumericStepper("Jump Power", nil, 50, 500, 10, 50,
                    function(v)
                        game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
                    end)
        --]]
        function sec:NumericStepper(name, description, min, max, step, default, callback)
            min     = min     or 0
            max     = max     or 100
            step    = step    or 1
            local value = _clamp(default or min, min, max)

            local row = Instance.new("Frame")
            row.Name = "stepperRow"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, description and 54 or 40)
            _makeCorner(row, 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0, 14, 0, description and 8 or 0)
            nameLbl.Size = UDim2.new(0.48, -14, 0, 26)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name or "Stepper"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            if description then
                local descLbl = Instance.new("TextLabel")
                descLbl.Parent = row
                descLbl.BackgroundTransparency = 1
                descLbl.Position = UDim2.new(0, 14, 0, 30)
                descLbl.Size = UDim2.new(0.48, -14, 0, 18)
                descLbl.Font = Enum.Font.Gotham
                descLbl.Text = description
                descLbl.TextColor3 = t.SecondaryText
                descLbl.TextSize = 12
                descLbl.TextXAlignment = Enum.TextXAlignment.Left
            end

            -- Stepper controls
            local stepperFrame = Instance.new("Frame")
            stepperFrame.Parent = row
            stepperFrame.BackgroundTransparency = 1
            stepperFrame.AnchorPoint = Vector2.new(1, 0.5)
            stepperFrame.Position = UDim2.new(1, -10, 0.5, 0)
            stepperFrame.Size = UDim2.new(0, 120, 0, 28)
            _makeListLayout(stepperFrame, Enum.FillDirection.Horizontal,
                Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, 6)

            local valDisplay = Instance.new("TextLabel")
            valDisplay.Parent = stepperFrame
            valDisplay.BackgroundColor3 = t.InputBg
            valDisplay.Size = UDim2.new(0, 52, 1, 0)
            valDisplay.Font = Enum.Font.GothamMedium
            valDisplay.Text = tostring(value)
            valDisplay.TextColor3 = t.PrimaryText
            valDisplay.TextSize = 15
            _makeCorner(valDisplay, 7)

            local function _makeStepBtn(lbl, delta)
                local btn = Instance.new("TextButton")
                btn.Parent = stepperFrame
                btn.BackgroundColor3 = t.Accent
                btn.Size = UDim2.new(0, 28, 1, 0)
                btn.Font = Enum.Font.GothamMedium
                btn.Text = lbl
                btn.TextColor3 = t.AccentText
                btn.TextSize = 18
                btn.AutoButtonColor = false
                _makeCorner(btn, 7)

                local held = false
                btn.MouseButton1Down:Connect(function()
                    held = true
                    coroutine.wrap(function()
                        while held do
                            value = _clamp(value + delta, min, max)
                            valDisplay.Text = tostring(value)
                            if callback then coroutine.wrap(function() callback(value) end)() end
                            task.wait(0.12)
                        end
                    end)()
                end)
                btn.MouseButton1Up:Connect(function() held = false end)
                btn.MouseLeave:Connect(function() held = false end)
                return btn
            end

            _makeStepBtn("-", -step)
            _makeStepBtn("+", step)

            local obj = {}
            function obj:Set(v)
                value = _clamp(v, min, max)
                valDisplay.Text = tostring(value)
            end
            function obj:Get() return value end
            return obj
        end

        -- ── sec:InfoCard(title, lines) ────────────────────────────────────────
        --[[
            Adds a styled info card displaying key-value rows.

            Parameters:
                title (string) - Card heading.
                lines (table)  - Array of { key=string, value=string } pairs.

            Example:
                tab:InfoCard("System Info", {
                    { key = "Executor", value = identifyexecutor and identifyexecutor() or "Unknown" },
                    { key = "Game",     value = game.Name },
                    { key = "Place ID", value = tostring(game.PlaceId) },
                })
        --]]
        function sec:InfoCard(title, lines)
            local card = Instance.new("Frame")
            card.Name = "infoCard"
            card.Parent = content
            card.BackgroundColor3 = t.ButtonBg
            card.BackgroundTransparency = 0.45
            card.BorderSizePixel = 0
            card.Size = UDim2.new(1, 0, 0, 30 + #(lines or {}) * 28)
            _makeCorner(card, 12)
            _makeStroke(card, t.Separator, 1, 0.4)

            local headerLbl = Instance.new("TextLabel")
            headerLbl.Parent = card
            headerLbl.BackgroundTransparency = 1
            headerLbl.Position = UDim2.new(0, 14, 0, 6)
            headerLbl.Size = UDim2.new(1, -28, 0, 22)
            headerLbl.Font = Enum.Font.GothamMedium
            headerLbl.Text = title or "Info"
            headerLbl.TextColor3 = t.SecondaryText
            headerLbl.TextSize = 12
            headerLbl.TextXAlignment = Enum.TextXAlignment.Left

            for i, pair in ipairs(lines or {}) do
                local lineRow = Instance.new("Frame")
                lineRow.Parent = card
                lineRow.BackgroundTransparency = 1
                lineRow.Position = UDim2.new(0, 0, 0, 28 + (i - 1) * 28)
                lineRow.Size = UDim2.new(1, 0, 0, 28)

                local keyLbl = Instance.new("TextLabel")
                keyLbl.Parent = lineRow
                keyLbl.BackgroundTransparency = 1
                keyLbl.Position = UDim2.new(0, 14, 0, 0)
                keyLbl.Size = UDim2.new(0.45, -14, 1, 0)
                keyLbl.Font = Enum.Font.Gotham
                keyLbl.Text = pair.key or ""
                keyLbl.TextColor3 = t.SecondaryText
                keyLbl.TextSize = 14
                keyLbl.TextXAlignment = Enum.TextXAlignment.Left

                local valLbl = Instance.new("TextLabel")
                valLbl.Parent = lineRow
                valLbl.BackgroundTransparency = 1
                valLbl.AnchorPoint = Vector2.new(1, 0)
                valLbl.Position = UDim2.new(1, -14, 0, 0)
                valLbl.Size = UDim2.new(0.52, 0, 1, 0)
                valLbl.Font = Enum.Font.GothamMedium
                valLbl.Text = tostring(pair.value or "")
                valLbl.TextColor3 = t.PrimaryText
                valLbl.TextSize = 14
                valLbl.TextXAlignment = Enum.TextXAlignment.Right
                valLbl.TextTruncate = Enum.TextTruncate.AtEnd

                if i < #lines then
                    local sep = Instance.new("Frame")
                    sep.Parent = lineRow
                    sep.BackgroundColor3 = t.Separator
                    sep.BorderSizePixel = 0
                    sep.AnchorPoint = Vector2.new(0, 1)
                    sep.Position = UDim2.new(0, 14, 1, 0)
                    sep.Size = UDim2.new(1, -28, 0, 1)
                end
            end
        end

        -- ── sec:RichTextLabel(text) ───────────────────────────────────────────
        --[[
            Adds a label that supports Roblox RichText tags like <b>, <i>, <font>.

            Parameters:
                text (string) - The rich text string.

            Returns:
                obj (table) - { Set(text) }

            Example:
                tab:RichTextLabel('<font color="rgb(21,103,251)"><b>Apple Library V1</b></font> — by Kyrubureibu')
        --]]
        function sec:RichTextLabel(text)
            local lbl = Instance.new("TextLabel")
            lbl.Name = "richTextLabel"
            lbl.Parent = content
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, 36)
            lbl.Font = Enum.Font.Gotham
            lbl.RichText = true
            lbl.Text = text or ""
            lbl.TextColor3 = t.PrimaryText
            lbl.TextSize = 15
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Top

            lbl:GetPropertyChangedSignal("Text"):Connect(function()
                -- Auto size height
                local bounds = game:GetService("TextService"):GetTextSize(
                    lbl.Text, lbl.TextSize, lbl.Font,
                    Vector2.new(lbl.AbsoluteSize.X, math.huge)
                )
                lbl.Size = UDim2.new(1, 0, 0, math.max(36, bounds.Y + 12))
            end)

            local obj = {}
            function obj:Set(text2) lbl.Text = tostring(text2) end
            return obj
        end

        return sec
    end  -- window:Section

    -- First section auto-select support
    -- Caller should call sec:Select() on whichever tab they want default.

    table.insert(_windows, window)
    return window
end  -- lib:init

-- ─────────────────────────────────────────────────────────────────────────────
-- GLOBAL UTILITIES
-- ─────────────────────────────────────────────────────────────────────────────

--[[
    lib:DestroyAll()
    Destroys every AppleLib ScreenGui and disconnects all connections.

    Example:
        lib:DestroyAll()
--]]
function lib:DestroyAll()
    _disconnectAll()
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "AppleLibV1" or gui.Name == "AppleLibToasts" then
            gui:Destroy()
        end
    end
    if gethui then
        for _, gui in ipairs(gethui():GetChildren()) do
            if gui.Name == "AppleLibV1" or gui.Name == "AppleLibToasts" then
                gui:Destroy()
            end
        end
    end
    _windows = {}
    _sectionList = nil
end

--[[
    lib:GetVersion()
    Returns the library version string.

    Example:
        print(lib:GetVersion())   --> "V1"
--]]
function lib:GetVersion()
    return lib.Version
end

--[[
    lib:GetAuthor()
    Returns the author name.

    Example:
        print(lib:GetAuthor())   --> "Kyrubureibu"
--]]
function lib:GetAuthor()
    return lib.Author
end

-- ─────────────────────────────────────────────────────────────────────────────
-- QUICK-START HELPER
-- ─────────────────────────────────────────────────────────────────────────────

--[[
    lib:Quick(config)
    Convenience function that creates a window and one or more sections
    from a single config table. Useful for simple scripts.

    config = {
        title       = "My Script",
        splash      = true,
        theme       = "Dark",
        toggleKey   = Enum.KeyCode.RightShift,
        sections    = {
            {
                name     = "Combat",
                default  = true,   -- select this tab on load
                elements = {
                    { type="Switch",  name="Aimbot", default=false, callback=function(v) end },
                    { type="Slider",  name="FOV", min=1, max=360, default=90, callback=function(v) end },
                    { type="Button",  name="Reset",  callback=function() end },
                    { type="Divider", name="Misc" },
                    { type="Label",   name="Status: Active" },
                }
            },
        }
    }

    Example:
        lib:Quick({
            title = "My Cheat",
            splash = true,
            theme = "Dark",
            toggleKey = Enum.KeyCode.RightShift,
            sections = {
                {
                    name = "Main",
                    default = true,
                    elements = {
                        { type="Switch", name="Fly", default=false, callback=function(v) toggleFly(v) end },
                        { type="Slider", name="Speed", min=16, max=300, default=16, step=1, callback=function(v) setSpeed(v) end },
                    }
                }
            }
        })
--]]
function lib:Quick(cfg)
    assert(type(cfg) == "table", "[AppleLib] lib:Quick expects a config table.")

    local win = self:init(
        cfg.title or "Apple Library",
        cfg.splash ~= false,
        cfg.toggleKey,
        true,
        cfg.theme or "Light"
    )

    for _, secCfg in ipairs(cfg.sections or {}) do
        local sec = win:Section(secCfg.name or "Section")
        if secCfg.default then sec:Select() end

        for _, el in ipairs(secCfg.elements or {}) do
            local elType = string.lower(el.type or "")
            if elType == "button" then
                sec:Button(el.name, el.description, el.callback)
            elseif elType == "switch" or elType == "toggle" then
                sec:Switch(el.name, el.description, el.default, el.callback)
            elseif elType == "slider" then
                sec:Slider(el.name, el.description, el.min, el.max, el.default, el.step, el.callback)
            elseif elType == "textfield" or elType == "input" then
                sec:TextField(el.name, el.placeholder, el.default, el.callback)
            elseif elType == "dropdown" then
                sec:Dropdown(el.name, el.description, el.options, el.default, el.callback)
            elseif elType == "colorpicker" or elType == "color" then
                sec:ColorPicker(el.name, el.description, el.default, el.callback)
            elseif elType == "keybind" then
                sec:Keybind(el.name, el.description, el.default, el.callback)
            elseif elType == "progressbar" or elType == "progress" then
                sec:ProgressBar(el.name, el.description, el.default, el.max)
            elseif elType == "divider" then
                sec:Divider(el.name)
            elseif elType == "label" then
                sec:Label(el.name)
            elseif elType == "spacer" then
                sec:Spacer(el.height)
            elseif elType == "separator" then
                sec:Separator()
            elseif elType == "badge" then
                sec:Badge(el.name, el.badge, el.color)
            elseif elType == "multiswitch" or elType == "segmented" then
                sec:MultiSwitch(el.name, el.options, el.default, el.callback)
            elseif elType == "numericstepper" or elType == "stepper" then
                sec:NumericStepper(el.name, el.description, el.min, el.max, el.step, el.default, el.callback)
            elseif elType == "infocard" then
                sec:InfoCard(el.name, el.lines)
            elseif elType == "textarea" then
                sec:TextArea(el.name, el.default, el.callback)
            elseif elType == "image" then
                sec:Image(el.assetId, el.height)
            end
        end
    end

    return win
end
return lib

--[[
──────────────────────────────────────────────────────────────────────────────
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
──────────────────────────────────────────────────────────────────────────────
--]]
