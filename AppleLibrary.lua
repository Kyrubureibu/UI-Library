--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                                                                              ║
    ║                        Apple Library  ·  V1.1                               ║
    ║                    Made by  Kyrubureibu  (2024)                             ║
    ║                                                                              ║
    ║   A macOS-inspired Roblox UI library for executors.                         ║
    ║   Clean, modern, smooth — now with full mobile support.                     ║
    ║                                                                              ║
    ║   Changelog V1.1                                                            ║
    ║     · Full mobile / touch support                                           ║
    ║     · Floating toggle button (Apple icon) for mobile show/hide              ║
    ║     · Mobile hamburger menu — sidebar slides in/out as a drawer             ║
    ║     · Larger tap targets on all elements for thumbs                         ║
    ║     · Window auto-resizes to fill screen on small devices                   ║
    ║     · Touch-drag window repositioning                                       ║
    ║     · Swipe-to-close sidebar gesture on mobile                              ║
    ║     · On-screen keyboard offset so inputs stay visible                      ║
    ║     · Removed version badge from title bar                                  ║
    ║     · Toast notifications reposition to bottom on mobile                    ║
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

lib.Version    = "V1.1"
lib.Author     = "Kyrubureibu"
lib.Built      = "2026"

local _sections    = {}
local _workareas   = {}
local _windows     = {}
local _themes      = {}
local _connections = {}
local _dropdowns   = {}

local _visible     = true
local _debounce    = false
local _activeTheme = nil
local _scrgui      = nil

-- ─────────────────────────────────────────────────────────────────────────────
-- MOBILE DETECTION
-- ─────────────────────────────────────────────────────────────────────────────

--[[
    _isMobile()
    Returns true when the device is a phone or tablet.
    Detection order:
      1. UserInputService.TouchEnabled  (touch screen present)
      2. UserInputService.GamepadEnabled is false (no physical controller)
      3. Viewport width < 800 px  (small screen fallback)
--]]
local function _isMobile()
    if UserInputService.TouchEnabled then
        -- Also catch Windows tablets that have both mouse and touch
        local vp = workspace.CurrentCamera.ViewportSize
        return vp.X < 1024 or not UserInputService.MouseEnabled
    end
    return false
end

-- Cache once — changing device type mid-session is unsupported by Roblox anyway.
local IS_MOBILE = _isMobile()

--[[
    _viewportSize()
    Returns the current camera viewport size as a Vector2.
--]]
local function _viewportSize()
    return workspace.CurrentCamera.ViewportSize
end

-- ─────────────────────────────────────────────────────────────────────────────
-- COLOUR THEMES
-- ─────────────────────────────────────────────────────────────────────────────

local THEMES = {
    Light = {
        Window          = Color3.fromRGB(255, 255, 255),
        WindowTrans     = 0.15,
        Sidebar         = Color3.fromRGB(248, 248, 248),
        Workarea        = Color3.fromRGB(255, 255, 255),
        TitleText       = Color3.fromRGB(0,   0,   0  ),
        PrimaryText     = Color3.fromRGB(0,   0,   0  ),
        SecondaryText   = Color3.fromRGB(95,  95,  95 ),
        PlaceholderText = Color3.fromRGB(113, 113, 113),
        Accent          = Color3.fromRGB(21,  103, 251),
        AccentText      = Color3.fromRGB(255, 255, 255),
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
        CloseBtn        = Color3.fromRGB(254,  94,  86),
        MinBtn          = Color3.fromRGB(255, 189,  46),
        MaxBtn          = Color3.fromRGB( 39, 200,  63),
        NotifBg         = Color3.fromRGB(255, 255, 255),
        NotifDarken     = Color3.fromRGB(0,   0,   0  ),
        ToastBg         = Color3.fromRGB(255, 255, 255),
        ToastTrans      = 0.12,
        -- Mobile drawer overlay
        DrawerOverlay   = Color3.fromRGB(0,   0,   0  ),
        DrawerOverlayTr = 0.45,
        -- Floating toggle button
        FloatBtn        = Color3.fromRGB(21,  103, 251),
        FloatBtnTrans   = 0.05,
    },

    Dark = {
        Window          = Color3.fromRGB( 28,  28,  30),
        WindowTrans     = 0.05,
        Sidebar         = Color3.fromRGB( 22,  22,  24),
        Workarea        = Color3.fromRGB( 44,  44,  46),
        TitleText       = Color3.fromRGB(255, 255, 255),
        PrimaryText     = Color3.fromRGB(255, 255, 255),
        SecondaryText   = Color3.fromRGB(174, 174, 178),
        PlaceholderText = Color3.fromRGB(130, 130, 135),
        Accent          = Color3.fromRGB( 10, 132, 255),
        AccentText      = Color3.fromRGB(255, 255, 255),
        ButtonBg        = Color3.fromRGB( 58,  58,  60),
        InputBg         = Color3.fromRGB( 58,  58,  60),
        SwitchOff       = Color3.fromRGB( 72,  72,  74),
        SwitchOn        = Color3.fromRGB( 10, 132, 255),
        SliderFill      = Color3.fromRGB( 10, 132, 255),
        SliderTrack     = Color3.fromRGB( 72,  72,  74),
        DropdownBg      = Color3.fromRGB( 58,  58,  60),
        DropdownItem    = Color3.fromRGB( 44,  44,  46),
        Separator       = Color3.fromRGB( 58,  58,  60),
        Progress        = Color3.fromRGB( 10, 132, 255),
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
        DrawerOverlay   = Color3.fromRGB(0,   0,   0  ),
        DrawerOverlayTr = 0.55,
        FloatBtn        = Color3.fromRGB( 10, 132, 255),
        FloatBtnTrans   = 0.05,
    },

    Midnight = {
        Window          = Color3.fromRGB(  7,   7,  20),
        WindowTrans     = 0.02,
        Sidebar         = Color3.fromRGB(  5,   5,  16),
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
        DrawerOverlay   = Color3.fromRGB(0,   0,   0  ),
        DrawerOverlayTr = 0.60,
        FloatBtn        = Color3.fromRGB(100, 120, 255),
        FloatBtnTrans   = 0.02,
    },

    Rose = {
        Window          = Color3.fromRGB(255, 240, 245),
        WindowTrans     = 0.10,
        Sidebar         = Color3.fromRGB(250, 232, 240),
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
        DrawerOverlay   = Color3.fromRGB(0,   0,   0  ),
        DrawerOverlayTr = 0.40,
        FloatBtn        = Color3.fromRGB(230,  60, 110),
        FloatBtnTrans   = 0.05,
    },
}

_activeTheme = THEMES.Light

-- ─────────────────────────────────────────────────────────────────────────────
-- UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────────

local function _tween(ins, ti, goals)
    local tw = TweenService:Create(ins, ti, goals)
    tw:Play()
    return tw
end

local function _tweenPos(ins, pos, duration)
    return _tween(ins,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),
        {Position = pos})
end

local function _tweenColor(ins, prop, color, duration)
    local g = {}; g[prop] = color
    return _tween(ins, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), g)
end

local function _tweenTransparency(ins, prop, value, duration)
    local g = {}; g[prop] = value
    return _tween(ins, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), g)
end

local function _makeCorner(parent, radius)
    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, radius or 9)
    uc.Parent = parent
    return uc
end

local function _makeStroke(parent, color, thickness, trans)
    -- Remove any existing UIStroke first
    local old = parent:FindFirstChildOfClass("UIStroke")
    if old then old:Destroy() end
    local us = Instance.new("UIStroke")
    us.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    us.Color = color or Color3.fromRGB(200, 200, 200)
    us.Thickness = thickness or 1
    us.Transparency = trans or 0
    us.Parent = parent
    return us
end

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

local function _makePadding(parent, top, bottom, left, right)
    local up = Instance.new("UIPadding")
    up.PaddingTop    = UDim.new(0, top    or 0)
    up.PaddingBottom = UDim.new(0, bottom or 0)
    up.PaddingLeft   = UDim.new(0, left   or 0)
    up.PaddingRight  = UDim.new(0, right  or 0)
    up.Parent = parent
    return up
end

local function _clamp(v, mn, mx)
    return math.max(mn, math.min(mx, v))
end

local function _round(n, dec)
    local m = 10 ^ (dec or 0)
    return math.floor(n * m + 0.5) / m
end

local function _connect(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(_connections, conn)
    return conn
end

local function _disconnectAll()
    for _, conn in ipairs(_connections) do
        pcall(function() conn:Disconnect() end)
    end
    _connections = {}
end

local function _getGui()
    if syn then return CoreGui
    elseif gethui then return gethui()
    else return CoreGui end
end

local function _protectGui(sg)
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(sg) end)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- THEME API
-- ─────────────────────────────────────────────────────────────────────────────

function lib:RegisterTheme(name, themeTable)
    assert(type(name) == "string",  "[AppleLib] Theme name must be a string.")
    assert(type(themeTable) == "table", "[AppleLib] Theme must be a table.")
    -- Fill in mobile keys if missing
    themeTable.DrawerOverlay   = themeTable.DrawerOverlay   or Color3.fromRGB(0,0,0)
    themeTable.DrawerOverlayTr = themeTable.DrawerOverlayTr or 0.5
    themeTable.FloatBtn        = themeTable.FloatBtn        or themeTable.Accent
    themeTable.FloatBtnTrans   = themeTable.FloatBtnTrans   or 0.05
    THEMES[name] = themeTable
end

function lib:SetTheme(name)
    assert(THEMES[name], "[AppleLib] Unknown theme: " .. tostring(name))
    _activeTheme = THEMES[name]
end

function lib:GetTheme()  return _activeTheme end

function lib:GetThemeNames()
    local names = {}
    for k in pairs(THEMES) do table.insert(names, k) end
    table.sort(names)
    return names
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TOAST NOTIFICATIONS  (standalone, no window needed)
-- ─────────────────────────────────────────────────────────────────────────────

local _toastHolder = nil

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

    Shows a floating toast notification.
    On mobile: appears at the BOTTOM-centre of the screen (thumb-reachable).
    On desktop: appears in the top-right corner.

    Parameters:
        title    (string)  - Bold title text.
        body     (string)  - Smaller body text.
        icon     (string)  - Roblox asset id. Optional.
        duration (number)  - Seconds before auto-dismiss. Default 5.
--]]
function lib:Toast(title, body, icon, duration)
    _ensureToastHolder()
    duration = duration or 5
    local t = _activeTheme

    -- On mobile, toasts stack upward from the bottom.
    -- On desktop, toasts stack downward from the top-right.
    local mobile = IS_MOBILE

    for _, ch in ipairs(_toastHolder:GetChildren()) do
        if ch:IsA("Frame") and ch.Name == "AppleToast" then
            if mobile then
                _tweenPos(ch, ch.Position - UDim2.new(0, 0, 0, 122), 0.3)
            else
                _tweenPos(ch, ch.Position + UDim2.new(0, 0, 0, 122), 0.3)
            end
        end
    end

    -- Toast size: slightly wider/shorter on mobile
    local toastW = mobile and 340 or 400
    local toastH = mobile and 90  or 110

    local toast = Instance.new("Frame")
    toast.Name = "AppleToast"
    toast.Parent = _toastHolder
    toast.BackgroundColor3 = t.ToastBg
    toast.BackgroundTransparency = t.ToastTrans
    toast.ZIndex = 100

    if mobile then
        -- Centre-bottom
        toast.AnchorPoint = Vector2.new(0.5, 1)
        toast.Position = UDim2.new(0.5, 0, 1, toastH + 20)
        toast.Size = UDim2.new(0, toastW, 0, toastH)
        _makeCorner(toast, 18)
        _makeShadow(toast, 99, UDim2.new(1.06, 0, 1.3, 0), 0.45)
        _makeStroke(toast, t.Separator, 1)
        _tweenPos(toast, UDim2.new(0.5, 0, 1, -24), 0.4)
    else
        -- Top-right
        toast.AnchorPoint = Vector2.new(1, 0)
        toast.Position = UDim2.new(1, toastW + 20, 0.08, 0)
        toast.Size = UDim2.new(0, toastW, 0, toastH)
        _makeCorner(toast, 16)
        _makeShadow(toast, 99, UDim2.new(1.1, 0, 1.2, 0), 0.5)
        _makeStroke(toast, t.Separator, 1)
        _tweenPos(toast, UDim2.new(1, -20, 0.08, 0), 0.45)
    end

    -- Icon
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Parent = toast
    iconLabel.BackgroundTransparency = 1
    iconLabel.AnchorPoint = Vector2.new(0, 0.5)
    iconLabel.Position = UDim2.new(0, 12, 0.5, 0)
    iconLabel.Size = UDim2.new(0, mobile and 52 or 62, 0, mobile and 52 or 62)
    iconLabel.ZIndex = 101
    iconLabel.Image = icon or "rbxassetid://4871684504"
    iconLabel.ImageColor3 = t.SecondaryText
    iconLabel.ScaleType = Enum.ScaleType.Fit

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Parent = toast
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, mobile and 74 or 84, 0, mobile and 12 or 14)
    titleLbl.Size = UDim2.new(1, mobile and -84 or -94, 0, 24)
    titleLbl.ZIndex = 101
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title or ""
    titleLbl.TextColor3 = t.PrimaryText
    titleLbl.TextSize = mobile and 17 or 19
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd

    -- Body
    local bodyLbl = Instance.new("TextLabel")
    bodyLbl.Parent = toast
    bodyLbl.BackgroundTransparency = 1
    bodyLbl.Position = UDim2.new(0, mobile and 74 or 84, 0, mobile and 36 or 40)
    bodyLbl.Size = UDim2.new(1, mobile and -84 or -94, 0, mobile and 42 or 54)
    bodyLbl.ZIndex = 101
    bodyLbl.Font = Enum.Font.Gotham
    bodyLbl.Text = body or ""
    bodyLbl.TextColor3 = t.SecondaryText
    bodyLbl.TextSize = mobile and 13 or 14
    bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
    bodyLbl.TextWrapped = true
    bodyLbl.TextYAlignment = Enum.TextYAlignment.Top

    -- Progress countdown strip
    local pBg = Instance.new("Frame")
    pBg.Parent = toast
    pBg.BackgroundColor3 = t.SliderTrack
    pBg.BorderSizePixel = 0
    pBg.Position = UDim2.new(0, 0, 1, -4)
    pBg.Size = UDim2.new(1, 0, 0, 4)
    pBg.ZIndex = 102
    _makeCorner(pBg, 2)

    local pFill = Instance.new("Frame")
    pFill.Parent = pBg
    pFill.BackgroundColor3 = t.Accent
    pFill.BorderSizePixel = 0
    pFill.Size = UDim2.new(1, 0, 1, 0)
    pFill.ZIndex = 103
    _makeCorner(pFill, 2)

    _tween(pFill,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 0, 1, 0)})

    -- Dismiss ×
    local dismiss = Instance.new("TextButton")
    dismiss.Parent = toast
    dismiss.BackgroundTransparency = 1
    dismiss.Position = UDim2.new(1, -28, 0, 6)
    dismiss.Size = UDim2.new(0, 24, 0, 24)
    dismiss.ZIndex = 102
    dismiss.Font = Enum.Font.GothamMedium
    dismiss.Text = "×"
    dismiss.TextColor3 = t.SecondaryText
    dismiss.TextSize = 22

    local function _dismissToast()
        if mobile then
            _tweenPos(toast, toast.Position + UDim2.new(0, 0, 0, toastH + 40), 0.3)
        else
            _tweenPos(toast, toast.Position + UDim2.new(0, toastW + 40, 0, 0), 0.3)
        end
        Debris:AddItem(toast, 0.4)
    end

    dismiss.MouseButton1Click:Connect(_dismissToast)
    -- Touch-friendly swipe dismiss
    toast.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            local startX = inp.Position.X
            local startY = inp.Position.Y
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    local dx = inp.Position.X - startX
                    local dy = inp.Position.Y - startY
                    -- Swipe right or down to dismiss
                    if dx > 60 or dy > 40 then
                        _dismissToast()
                    end
                end
            end)
        end
    end)

    task.delay(duration, function()
        if toast and toast.Parent then _dismissToast() end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- FLOATING MOBILE TOGGLE BUTTON
-- ─────────────────────────────────────────────────────────────────────────────
--[[
    _makeFloatingToggle(scrgui, t, toggleCallback)
    Creates the Apple-icon floating button used on mobile to show/hide the window.
    Draggable so the user can reposition it anywhere on screen.
    Returns the button frame.
--]]
local function _makeFloatingToggle(scrgui, t, toggleCallback)
    local btn = Instance.new("Frame")
    btn.Name = "AppleFloatBtn"
    btn.Parent = scrgui
    btn.AnchorPoint = Vector2.new(0.5, 0)
    -- Starts top-centre, just below the Roblox top bar
    btn.Position = UDim2.new(0.5, 0, 0, 14)
    btn.Size = UDim2.new(0, 56, 0, 56)
    btn.BackgroundColor3 = t.FloatBtn
    btn.BackgroundTransparency = t.FloatBtnTrans
    btn.ZIndex = 200
    _makeCorner(btn, 16)
    _makeShadow(btn, 199, UDim2.new(1.3, 0, 1.3, 0), 0.4)
    _makeStroke(btn, t.Separator, 1, 0.5)

    -- Apple logo image
    local icon = Instance.new("ImageLabel")
    icon.Parent = btn
    icon.BackgroundTransparency = 1
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.Size = UDim2.new(0.68, 0, 0.68, 0)
    icon.ZIndex = 201
    icon.Image = "rbxassetid://12621719043"
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

    -- Invisible touch button on top
    local hitBtn = Instance.new("TextButton")
    hitBtn.Parent = btn
    hitBtn.BackgroundTransparency = 1
    hitBtn.Size = UDim2.new(1, 0, 1, 0)
    hitBtn.Text = ""
    hitBtn.ZIndex = 202

    -- ── Drag logic ────────────────────────────────────────────────────────────
    local dragging = false
    local dragStartPos
    local btnStartPos

    hitBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = inp.Position
            btnStartPos  = btn.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStartPos
            -- Keep within screen bounds
            local vp = _viewportSize()
            local newX = _clamp(
                btnStartPos.X.Scale * vp.X + btnStartPos.X.Offset + delta.X,
                28, vp.X - 28)
            local newY = _clamp(
                btnStartPos.Y.Scale * vp.Y + btnStartPos.Y.Offset + delta.Y,
                14, vp.Y - 70)
            btn.Position = UDim2.new(0, newX, 0, newY)
            btn.AnchorPoint = Vector2.new(0.5, 0)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            local wasDragging = dragging
            dragging = false
            -- If it barely moved, treat as a tap
            if dragStartPos then
                local d = (inp.Position - dragStartPos).Magnitude
                if d < 10 and wasDragging then
                    toggleCallback()
                end
            end
        end
    end)

    -- Pulse animation so the user notices it on first load
    coroutine.wrap(function()
        for _ = 1, 3 do
            _tweenTransparency(btn, "BackgroundTransparency", 0.5, 0.3)
            task.wait(0.35)
            _tweenTransparency(btn, "BackgroundTransparency", t.FloatBtnTrans, 0.3)
            task.wait(0.35)
        end
    end)()

    return btn
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MAIN WINDOW INIT
-- ─────────────────────────────────────────────────────────────────────────────

--[[
    lib:init(title, doSplash, toggleKey, deletePrevious, themeName)

    Creates the main window and returns a window object.

    On DESKTOP:
        · Standard sidebar-left layout, 780×600 px fixed window.
        · Draggable by the title bar area.
        · Keyboard toggleKey supported.

    On MOBILE:
        · Window fills the screen (minus small safe-area margins).
        · Sidebar is hidden by default; a ☰ hamburger button in the topbar
          slides it in as a full-height drawer with a dark overlay.
        · A floating Apple-icon button (draggable) at the top-centre lets the
          user show/hide the window at any time.
        · All tap targets are enlarged (min 48 px tall) for thumbs.
        · The window shifts up automatically when the on-screen keyboard opens.

    Parameters:
        title         (string)  - Window title bar text.
        doSplash      (boolean) - Show the animated splash screen.
        toggleKey     (KeyCode) - PC key to toggle visibility. Ignored on mobile.
        deletePrevious(boolean) - Destroy any existing AppleLib GUI first.
        themeName     (string)  - "Light" | "Dark" | "Midnight" | "Rose" or custom.

    Returns:
        window (table) - Window object.
--]]
function lib:init(title, doSplash, toggleKey, deletePrevious, themeName)

    if themeName and THEMES[themeName] then
        _activeTheme = THEMES[themeName]
    end

    local t = _activeTheme
    local mobile = IS_MOBILE
    local vp = _viewportSize()

    -- ── ScreenGui ──────────────────────────────────────────────────────────────
    local guiParent = _getGui()

    if deletePrevious then
        local existing = guiParent:FindFirstChild("AppleLibV1")
        if existing then
            local m = existing:FindFirstChild("main", true)
            if m then _tweenPos(m, m.Position + UDim2.new(0,0,2,0), 0.5) end
            Debris:AddItem(existing, 0.7)
        end
    end

    local scrgui = Instance.new("ScreenGui")
    scrgui.Name = "AppleLibV1"
    scrgui.ResetOnSpawn = false
    scrgui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    scrgui.IgnoreGuiInset = mobile   -- let us control safe areas ourselves
    _protectGui(scrgui)
    scrgui.Parent = guiParent
    _scrgui = scrgui

    -- ── Splash ─────────────────────────────────────────────────────────────────
    if doSplash then
        local splashSz = mobile and math.min(vp.X - 40, 300) or 340
        local splash = Instance.new("Frame")
        splash.Name = "splash"
        splash.Parent = scrgui
        splash.AnchorPoint = Vector2.new(0.5, 0.5)
        splash.BackgroundColor3 = t.Window
        splash.BackgroundTransparency = t.WindowTrans
        splash.Position = UDim2.new(0.5, 0, 2, 0)
        splash.Size = UDim2.new(0, splashSz, 0, splashSz)
        splash.ZIndex = 40
        _makeCorner(splash, 22)
        _makeShadow(splash, 39, UDim2.new(1.2,0,1.2,0), 0.4)

        local sicon = Instance.new("ImageLabel")
        sicon.Parent = splash
        sicon.AnchorPoint = Vector2.new(0.5, 0.5)
        sicon.BackgroundTransparency = 1
        sicon.Position = UDim2.new(0.5, 0, 0.40, 0)
        sicon.Size = UDim2.new(0, splashSz * 0.42, 0, splashSz * 0.42)
        sicon.ZIndex = 41
        sicon.Image = "rbxassetid://12621719043"
        sicon.ScaleType = Enum.ScaleType.Fit

        local splashTitle = Instance.new("TextLabel")
        splashTitle.Parent = splash
        splashTitle.BackgroundTransparency = 1
        splashTitle.AnchorPoint = Vector2.new(0.5, 0)
        splashTitle.Position = UDim2.new(0.5, 0, 0.67, 0)
        splashTitle.Size = UDim2.new(0.85, 0, 0, 30)
        splashTitle.ZIndex = 41
        splashTitle.Font = Enum.Font.GothamMedium
        splashTitle.Text = title or "Apple Library"
        splashTitle.TextColor3 = t.TitleText
        splashTitle.TextSize = mobile and 19 or 22
        splashTitle.TextTruncate = Enum.TextTruncate.AtEnd

        local splashSub = Instance.new("TextLabel")
        splashSub.Parent = splash
        splashSub.BackgroundTransparency = 1
        splashSub.AnchorPoint = Vector2.new(0.5, 0)
        splashSub.Position = UDim2.new(0.5, 0, 0.80, 0)
        splashSub.Size = UDim2.new(0.85, 0, 0, 22)
        splashSub.ZIndex = 41
        splashSub.Font = Enum.Font.Gotham
        splashSub.Text = "by Kyrubureibu  ·  " .. lib.Version
        splashSub.TextColor3 = t.SecondaryText
        splashSub.TextSize = mobile and 13 or 15

        _tweenPos(splash, UDim2.new(0.5, 0, 0.5, 0), 0.9)
        task.wait(2.4)
        _tweenPos(splash, UDim2.new(0.5, 0, 2, 0), 0.7)
        Debris:AddItem(splash, 0.9)
        task.wait(0.3)
    end

    -- ── Window sizing ──────────────────────────────────────────────────────────
    --  Desktop: fixed 780×600.
    --  Mobile : fills screen with a small margin so corners show.
    local WIN_W, WIN_H
    local MARGIN = 8
    if mobile then
        WIN_W = vp.X - MARGIN * 2
        WIN_H = vp.Y - MARGIN * 2
    else
        WIN_W = 780
        WIN_H = 600
    end

    -- ── Main frame ─────────────────────────────────────────────────────────────
    local main = Instance.new("Frame")
    main.Name = "main"
    main.Parent = scrgui
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = t.Window
    main.BackgroundTransparency = t.WindowTrans
    main.Position = UDim2.new(0.5, 0, 2, 0)
    main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
    main.ClipsDescendants = false
    _makeCorner(main, mobile and 20 or 18)
    _makeShadow(main, -1, UDim2.new(1.05,0,1.05,0), 0.32)

    -- ── Dragging (desktop) ─────────────────────────────────────────────────────
    if not mobile then
        local dragging, dragInput, dragStart, startPos
        local function _updateDrag(input)
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos  = main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        main.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then _updateDrag(input) end
        end)
    end

    -- ── Top bar ─────────────────────────────────────────────────────────────────
    local TOPBAR_H = mobile and 56 or 50

    local topbar = Instance.new("Frame")
    topbar.Name = "topbar"
    topbar.Parent = main
    topbar.BackgroundTransparency = 1
    topbar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
    topbar.ZIndex = 5

    -- ── Traffic-light buttons (desktop) / Close button (mobile) ───────────────
    local function _makeTrafficBtn(name, color)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Parent = topbar
        btn.BackgroundColor3 = color
        btn.AnchorPoint = Vector2.new(0, 0.5)
        btn.Size = UDim2.new(0, 16, 0, 16)
        btn.AutoButtonColor = false
        btn.Font = Enum.Font.SourceSans
        btn.Text = ""
        btn.ZIndex = 6
        _makeCorner(btn, 9)
        btn.MouseEnter:Connect(function()
            _tweenColor(btn, "BackgroundColor3",
                Color3.new(btn.BackgroundColor3.R+0.1,
                           btn.BackgroundColor3.G+0.1,
                           btn.BackgroundColor3.B+0.1), 0.1)
        end)
        btn.MouseLeave:Connect(function()
            _tweenColor(btn, "BackgroundColor3", color, 0.15)
        end)
        return btn
    end

    local closeBtn, minimizeBtn, maximizeBtn
    local hamburgerBtn  -- mobile only

    if mobile then
        -- On mobile: close (×) on the right; hamburger (☰) on the left.
        -- No traffic lights — too small to tap accurately.

        hamburgerBtn = Instance.new("TextButton")
        hamburgerBtn.Name = "hamburger"
        hamburgerBtn.Parent = topbar
        hamburgerBtn.BackgroundTransparency = 1
        hamburgerBtn.AnchorPoint = Vector2.new(0, 0.5)
        hamburgerBtn.Position = UDim2.new(0, 12, 0.5, 0)
        hamburgerBtn.Size = UDim2.new(0, 44, 0, 44)
        hamburgerBtn.Text = "☰"
        hamburgerBtn.Font = Enum.Font.GothamMedium
        hamburgerBtn.TextColor3 = t.PrimaryText
        hamburgerBtn.TextSize = 24
        hamburgerBtn.ZIndex = 6
        hamburgerBtn.AutoButtonColor = false

        -- Touch ripple feedback
        hamburgerBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                _tweenTransparency(hamburgerBtn, "BackgroundTransparency", 0.8, 0.08)
                task.wait(0.12)
                _tweenTransparency(hamburgerBtn, "BackgroundTransparency", 1, 0.15)
            end
        end)

        closeBtn = Instance.new("TextButton")
        closeBtn.Name = "close"
        closeBtn.Parent = topbar
        closeBtn.BackgroundColor3 = t.CloseBtn
        closeBtn.AnchorPoint = Vector2.new(1, 0.5)
        closeBtn.Position = UDim2.new(1, -16, 0.5, 0)
        closeBtn.Size = UDim2.new(0, 28, 0, 28)
        closeBtn.AutoButtonColor = false
        closeBtn.Font = Enum.Font.GothamMedium
        closeBtn.Text = "×"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextSize = 18
        closeBtn.ZIndex = 6
        _makeCorner(closeBtn, 9)

    else
        -- Desktop traffic lights
        local trafficFrame = Instance.new("Frame")
        trafficFrame.Name = "trafficlights"
        trafficFrame.Parent = topbar
        trafficFrame.BackgroundTransparency = 1
        trafficFrame.Position = UDim2.new(0, 16, 0.5, 0)
        trafficFrame.AnchorPoint = Vector2.new(0, 0.5)
        trafficFrame.Size = UDim2.new(0, 80, 0, 20)
        _makeListLayout(trafficFrame, Enum.FillDirection.Horizontal,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center, 8)

        local function _makeTrafficInner(name, color)
            local btn = Instance.new("TextButton")
            btn.Name = name
            btn.Parent = trafficFrame
            btn.BackgroundColor3 = color
            btn.Size = UDim2.new(0, 16, 0, 16)
            btn.AutoButtonColor = false
            btn.Font = Enum.Font.SourceSans
            btn.Text = ""
            btn.ZIndex = 6
            _makeCorner(btn, 9)
            btn.MouseEnter:Connect(function()
                _tweenColor(btn,"BackgroundColor3",
                    Color3.new(btn.BackgroundColor3.R+0.1,
                               btn.BackgroundColor3.G+0.1,
                               btn.BackgroundColor3.B+0.1),0.1)
            end)
            btn.MouseLeave:Connect(function()
                _tweenColor(btn,"BackgroundColor3",color,0.15)
            end)
            return btn
        end
        closeBtn    = _makeTrafficInner("close",    t.CloseBtn)
        minimizeBtn = _makeTrafficInner("minimize", t.MinBtn)
        maximizeBtn = _makeTrafficInner("maximize", t.MaxBtn)
    end

    -- ── Title label ─────────────────────────────────────────────────────────────
    --  NOTE: Version badge removed in V1.1 — keeps the title bar clean.
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "title"
    titleLbl.Parent = topbar
    titleLbl.BackgroundTransparency = 1
    titleLbl.AnchorPoint = Vector2.new(0.5, 0.5)
    titleLbl.Position = UDim2.new(0.5, 0, 0.5, 0)
    titleLbl.Size = UDim2.new(mobile and 0.55 or 0.5, 0, 0, 26)
    titleLbl.ZIndex = 6
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.Text = title or "Apple Library"
    titleLbl.TextColor3 = t.TitleText
    titleLbl.TextSize = mobile and 18 or 20
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd

    -- Divider under topbar
    local topDivider = Instance.new("Frame")
    topDivider.Name = "topDivider"
    topDivider.Parent = main
    topDivider.BackgroundColor3 = t.Separator
    topDivider.BorderSizePixel = 0
    topDivider.Position = UDim2.new(0, 0, 0, TOPBAR_H)
    topDivider.Size = UDim2.new(1, 0, 0, 1)

    -- ── Sidebar width ──────────────────────────────────────────────────────────
    --  Desktop: fixed 220 px column on the left.
    --  Mobile : hidden by default, slides in as a drawer (75 % of screen width).
    local SIDEBAR_W = mobile and math.floor(WIN_W * 0.75) or 220
    local CONTENT_OFFSET = TOPBAR_H + 1  -- below the topbar divider

    -- ── Sidebar container ──────────────────────────────────────────────────────
    local sidebar = Instance.new("Frame")
    sidebar.Name = "sidebar"
    sidebar.Parent = main
    sidebar.BackgroundColor3 = t.Sidebar
    sidebar.BackgroundTransparency = mobile and 0 or 1
    sidebar.Position = UDim2.new(0, mobile and -SIDEBAR_W or 0, 0, CONTENT_OFFSET)
    sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -CONTENT_OFFSET)
    sidebar.ZIndex = mobile and 30 or 1
    sidebar.ClipsDescendants = true
    if mobile then
        _makeCorner(sidebar, 0)
        -- Left edge rounded only on the right side of the drawer
        -- (Roblox doesn't support per-corner radius, so we use full for simplicity)
    end

    -- Drawer overlay (mobile: darkens the workarea when drawer is open)
    local drawerOverlay = nil
    local drawerOpen    = false

    if mobile then
        drawerOverlay = Instance.new("TextButton")
        drawerOverlay.Name = "drawerOverlay"
        drawerOverlay.Parent = main
        drawerOverlay.BackgroundColor3 = t.DrawerOverlay
        drawerOverlay.BackgroundTransparency = 1
        drawerOverlay.BorderSizePixel = 0
        drawerOverlay.Position = UDim2.new(0, 0, 0, CONTENT_OFFSET)
        drawerOverlay.Size = UDim2.new(1, 0, 1, -CONTENT_OFFSET)
        drawerOverlay.ZIndex = 29
        drawerOverlay.Text = ""
        drawerOverlay.Visible = false
        drawerOverlay.AutoButtonColor = false

        local function _closeDrawer()
            if not drawerOpen then return end
            drawerOpen = false
            _tweenPos(sidebar, UDim2.new(0, -SIDEBAR_W, 0, CONTENT_OFFSET), 0.28)
            _tweenTransparency(drawerOverlay, "BackgroundTransparency", 1, 0.28)
            task.delay(0.3, function() drawerOverlay.Visible = false end)
            hamburgerBtn.Text = "☰"
        end

        local function _openDrawer()
            if drawerOpen then return end
            drawerOpen = true
            drawerOverlay.Visible = true
            _tweenPos(sidebar, UDim2.new(0, 0, 0, CONTENT_OFFSET), 0.28)
            _tweenTransparency(drawerOverlay, "BackgroundTransparency", t.DrawerOverlayTr, 0.28)
            hamburgerBtn.Text = "✕"
        end

        hamburgerBtn.MouseButton1Click:Connect(function()
            if drawerOpen then _closeDrawer() else _openDrawer() end
        end)

        drawerOverlay.MouseButton1Click:Connect(function()
            _closeDrawer()
        end)

        -- Swipe from left edge to open
        main.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                local startX = inp.Position.X
                local startY = inp.Position.Y
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then
                        local dx = inp.Position.X - startX
                        local dy = math.abs(inp.Position.Y - startY)
                        -- Swipe right from left 60 px of screen
                        if startX < 60 and dx > 50 and dy < 60 then
                            _openDrawer()
                        end
                        -- Swipe left to close
                        if drawerOpen and dx < -50 and dy < 60 then
                            _closeDrawer()
                        end
                    end
                end)
            end
        end)

        -- Store closers for section:Select to auto-close drawer
        sidebar._closeFn = _closeDrawer
    end

    -- Vertical divider (desktop only)
    if not mobile then
        local sideDivider = Instance.new("Frame")
        sideDivider.Name = "sideDivider"
        sideDivider.Parent = main
        sideDivider.BackgroundColor3 = t.Separator
        sideDivider.BorderSizePixel = 0
        sideDivider.Position = UDim2.new(0, SIDEBAR_W, 0, CONTENT_OFFSET)
        sideDivider.Size = UDim2.new(0, 1, 1, -CONTENT_OFFSET)
    end

    -- ── Search bar ─────────────────────────────────────────────────────────────
    local searchH = mobile and 42 or 34
    local searchContainer = Instance.new("Frame")
    searchContainer.Name = "searchContainer"
    searchContainer.Parent = sidebar
    searchContainer.BackgroundColor3 = t.InputBg
    searchContainer.Position = UDim2.new(0, 12, 0, 10)
    searchContainer.Size = UDim2.new(1, -24, 0, searchH)
    _makeCorner(searchContainer, 10)
    _makeStroke(searchContainer, t.Separator, 1)

    local searchIcon = Instance.new("ImageButton")
    searchIcon.Parent = searchContainer
    searchIcon.BackgroundTransparency = 1
    searchIcon.Position = UDim2.new(0, 10, 0.5, 0)
    searchIcon.AnchorPoint = Vector2.new(0, 0.5)
    searchIcon.Size = UDim2.new(0, mobile and 22 or 20, 0, mobile and 22 or 20)
    searchIcon.Image = "rbxassetid://2804603863"
    searchIcon.ImageColor3 = t.SecondaryText
    searchIcon.ScaleType = Enum.ScaleType.Fit

    local searchBox = Instance.new("TextBox")
    searchBox.Parent = searchContainer
    searchBox.BackgroundTransparency = 1
    searchBox.Position = UDim2.new(0, mobile and 40 or 36, 0, 0)
    searchBox.Size = UDim2.new(1, mobile and -48 or -44, 1, 0)
    searchBox.ClearTextOnFocus = false
    searchBox.Font = Enum.Font.Gotham
    searchBox.PlaceholderText = "Search"
    searchBox.PlaceholderColor3 = t.PlaceholderText
    searchBox.Text = ""
    searchBox.TextColor3 = t.PrimaryText
    searchBox.TextSize = mobile and 16 or 15
    searchBox.TextXAlignment = Enum.TextXAlignment.Left

    searchIcon.MouseButton1Click:Connect(function()
        searchBox:CaptureFocus()
    end)

    -- ── Sidebar scrolling list ─────────────────────────────────────────────────
    local sidebarList = Instance.new("ScrollingFrame")
    sidebarList.Name = "sidebarList"
    sidebarList.Parent = sidebar
    sidebarList.Active = true
    sidebarList.BackgroundTransparency = 1
    sidebarList.BorderSizePixel = 0
    sidebarList.Position = UDim2.new(0, 0, 0, searchH + 18)
    sidebarList.Size = UDim2.new(1, 0, 1, -(searchH + 24))
    sidebarList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebarList.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebarList.ScrollBarThickness = mobile and 0 or 2  -- hidden on touch
    sidebarList.ScrollBarImageColor3 = t.Accent
    _makeListLayout(sidebarList, Enum.FillDirection.Vertical,
        Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, mobile and 4 or 3)
    _makePadding(sidebarList, 6, 6, 0, 0)

    -- Search filter
    RunService:BindToRenderStep("AppleLibSearch_" .. tostring(os.clock()), 1, function()
        if not searchBox:IsFocused() then
            for _, ch in ipairs(sidebarList:GetChildren()) do
                if ch:IsA("TextButton") then ch.Visible = true end
            end
            return
        end
        local q = string.upper(searchBox.Text)
        for _, ch in ipairs(sidebarList:GetChildren()) do
            if ch:IsA("TextButton") then
                ch.Visible = (q == "" or string.find(string.upper(ch.Text), q, 1, true) ~= nil)
            end
        end
    end)

    -- ── Workarea ───────────────────────────────────────────────────────────────
    local workareaX = mobile and 0 or SIDEBAR_W + 1
    local workareaW = mobile and WIN_W or (WIN_W - SIDEBAR_W - 1)

    local workareaOuter = Instance.new("Frame")
    workareaOuter.Name = "workareaOuter"
    workareaOuter.Parent = main
    workareaOuter.BackgroundTransparency = 1
    workareaOuter.Position = UDim2.new(0, workareaX, 0, CONTENT_OFFSET)
    workareaOuter.Size = UDim2.new(0, workareaW, 1, -CONTENT_OFFSET)
    workareaOuter.ClipsDescendants = true

    -- ── On-screen keyboard offset (mobile) ─────────────────────────────────────
    --[[
        When the virtual keyboard appears on mobile, Roblox fires
        UserInputService.TextBoxFocused. We slide the whole window up so the
        focused input stays visible above the keyboard.
    --]]
    if mobile then
        UserInputService.TextBoxFocused:Connect(function(tb)
            -- Estimate keyboard height as ~40 % of viewport
            local kbH = vp.Y * 0.40
            local tbBottom = tb.AbsolutePosition.Y + tb.AbsoluteSize.Y
            local visibleBottom = vp.Y - kbH
            if tbBottom > visibleBottom then
                local shift = tbBottom - visibleBottom + 16
                _tweenPos(main, UDim2.new(0.5, 0, 0, math.floor((vp.Y - WIN_H) / 2 - shift)), 0.25)
            end
        end)
        UserInputService.TextBoxFocusReleased:Connect(function()
            -- Return to centre
            _tweenPos(main, UDim2.new(0.5, 0, 0.5, 0), 0.25)
        end)
    end

    -- ── Toggle visibility logic ────────────────────────────────────────────────
    local _guiVisible     = true
    local _toggleDebounce = false

    local function _doToggle()
        if _toggleDebounce then return end
        _toggleDebounce = true
        _guiVisible = not _guiVisible
        if _guiVisible then
            _tweenPos(main, UDim2.new(0.5, 0, 0.5, 0), 0.42)
        else
            _tweenPos(main, main.Position + UDim2.new(0, 0, 2, 0), 0.42)
        end
        task.wait(0.5)
        _toggleDebounce = false
    end

    closeBtn.MouseButton1Click:Connect(function()
        _tweenPos(main, main.Position + UDim2.new(0, 0, 2, 0), 0.38)
        task.wait(0.5)
        scrgui:Destroy()
    end)

    if not mobile then
        if minimizeBtn then
            minimizeBtn.MouseButton1Click:Connect(_doToggle)
        end
        if toggleKey then
            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.KeyCode == toggleKey then _doToggle() end
            end)
        end
    end

    -- ── Floating toggle button (mobile) ────────────────────────────────────────
    local floatBtn = nil
    if mobile then
        floatBtn = _makeFloatingToggle(scrgui, t, _doToggle)
    end

    -- ── Window object ──────────────────────────────────────────────────────────
    local _sectionList = {}

    local window = {}
    window._scrgui = scrgui
    window._main   = main

    -- Slide in
    _tweenPos(main, UDim2.new(0.5, 0, 0.5, 0), 0.9)

    -- ── window:ToggleVisible() ─────────────────────────────────────────────────
    function window:ToggleVisible() _doToggle() end

    -- ── window:SetTitle(text) ──────────────────────────────────────────────────
    function window:SetTitle(text) titleLbl.Text = tostring(text) end

    -- ── window:GreenButton(callback) ───────────────────────────────────────────
    function window:GreenButton(callback)
        if maximizeBtn then
            if _G.__applelib_green then
                pcall(function() _G.__applelib_green:Disconnect() end)
            end
            _G.__applelib_green = maximizeBtn.MouseButton1Click:Connect(callback)
        end
    end

    -- ── window:Destroy() ──────────────────────────────────────────────────────
    function window:Destroy()
        _tweenPos(main, main.Position + UDim2.new(0, 0, 2, 0), 0.38)
        task.wait(0.5)
        scrgui:Destroy()
    end

    -- ── window:Toast(...) ─────────────────────────────────────────────────────
    function window:Toast(...) lib:Toast(...) end

    -- ──────────────────────────────────────────────────────────────────────────
    -- MODAL NOTIFICATIONS
    -- ──────────────────────────────────────────────────────────────────────────

    local overlay = Instance.new("Frame")
    overlay.Parent = main
    overlay.AnchorPoint = Vector2.new(0.5, 0.5)
    overlay.BackgroundColor3 = t.NotifDarken
    overlay.BackgroundTransparency = 0.45
    overlay.Position = UDim2.new(0.5,0,0.5,0)
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.ZIndex = 10
    overlay.Visible = false
    _makeCorner(overlay, mobile and 20 or 18)

    local function _showOverlay() overlay.Visible = true end
    local function _hideOverlay() overlay.Visible = false end

    -- Modal width adapts to screen
    local MODAL_W = mobile and math.min(WIN_W - 40, 300) or 310

    -- ── Single-button modal ─────────────────────────────────────────────────────
    local modal1 = Instance.new("Frame")
    modal1.Parent = main
    modal1.AnchorPoint = Vector2.new(0.5, 0.5)
    modal1.BackgroundColor3 = t.NotifBg
    modal1.Position = UDim2.new(0.5,0,0.5,0)
    modal1.Size = UDim2.new(0, MODAL_W, 0, mobile and 340 or 370)
    modal1.Visible = false
    modal1.ZIndex = 11
    _makeCorner(modal1, 18)
    _makeShadow(modal1, 10, UDim2.new(1.18,0,1.18,0), 0.45)

    local m1Icon = Instance.new("ImageLabel")
    m1Icon.Parent = modal1
    m1Icon.BackgroundTransparency = 1
    m1Icon.AnchorPoint = Vector2.new(0.5,0)
    m1Icon.Position = UDim2.new(0.5,0,0,24)
    m1Icon.Size = UDim2.new(0, mobile and 78 or 90, 0, mobile and 78 or 90)
    m1Icon.ZIndex = 12
    m1Icon.Image = "rbxassetid://4871684504"
    m1Icon.ImageColor3 = t.Accent
    m1Icon.ScaleType = Enum.ScaleType.Fit

    local m1Title = Instance.new("TextLabel")
    m1Title.Parent = modal1
    m1Title.BackgroundTransparency = 1
    m1Title.AnchorPoint = Vector2.new(0.5,0)
    m1Title.Position = UDim2.new(0.5,0,0, mobile and 116 or 128)
    m1Title.Size = UDim2.new(0.85,0,0,36)
    m1Title.ZIndex = 12
    m1Title.Font = Enum.Font.GothamMedium
    m1Title.Text = "Notice"
    m1Title.TextColor3 = t.PrimaryText
    m1Title.TextSize = mobile and 20 or 22

    local m1Body = Instance.new("TextLabel")
    m1Body.Parent = modal1
    m1Body.BackgroundTransparency = 1
    m1Body.AnchorPoint = Vector2.new(0.5,0)
    m1Body.Position = UDim2.new(0.5,0,0, mobile and 156 or 168)
    m1Body.Size = UDim2.new(0.85,0,0,72)
    m1Body.ZIndex = 12
    m1Body.Font = Enum.Font.Gotham
    m1Body.Text = ""
    m1Body.TextColor3 = t.SecondaryText
    m1Body.TextSize = mobile and 14 or 15
    m1Body.TextWrapped = true

    local m1Btn = Instance.new("TextButton")
    m1Btn.Parent = modal1
    m1Btn.AnchorPoint = Vector2.new(0.5,1)
    m1Btn.BackgroundColor3 = t.Accent
    m1Btn.Position = UDim2.new(0.5,0,1,-20)
    m1Btn.Size = UDim2.new(0.82,0,0, mobile and 50 or 46)
    m1Btn.ZIndex = 12
    m1Btn.Font = Enum.Font.GothamMedium
    m1Btn.Text = "OK"
    m1Btn.TextColor3 = t.AccentText
    m1Btn.TextSize = mobile and 17 or 18
    _makeCorner(m1Btn, 10)

    local _m1conn
    --[[
        window:Notify(title, body, buttonText, icon, callback)
    --]]
    function window:Notify(t1, t2, b1, icon, callback)
        if modal1.Visible or modal2.Visible then return end
        m1Title.Text = t1 or "Notice"
        m1Body.Text  = t2 or ""
        m1Btn.Text   = b1 or "OK"
        if icon then m1Icon.Image = icon end
        _showOverlay(); modal1.Visible = true
        if _m1conn then _m1conn:Disconnect() end
        _m1conn = m1Btn.MouseButton1Click:Connect(function()
            modal1.Visible = false; _hideOverlay()
            if callback then callback() end
        end)
    end

    -- ── Two-button modal ────────────────────────────────────────────────────────
    local modal2 = Instance.new("Frame")
    modal2.Parent = main
    modal2.AnchorPoint = Vector2.new(0.5,0.5)
    modal2.BackgroundColor3 = t.NotifBg
    modal2.Position = UDim2.new(0.5,0,0.5,0)
    modal2.Size = UDim2.new(0, MODAL_W, 0, mobile and 370 or 400)
    modal2.Visible = false
    modal2.ZIndex = 11
    _makeCorner(modal2, 18)
    _makeShadow(modal2, 10, UDim2.new(1.18,0,1.18,0), 0.45)

    local m2Icon = Instance.new("ImageLabel")
    m2Icon.Parent = modal2
    m2Icon.BackgroundTransparency = 1
    m2Icon.AnchorPoint = Vector2.new(0.5,0)
    m2Icon.Position = UDim2.new(0.5,0,0,24)
    m2Icon.Size = UDim2.new(0, mobile and 78 or 90, 0, mobile and 78 or 90)
    m2Icon.ZIndex = 12
    m2Icon.Image = "rbxassetid://12608260095"
    m2Icon.ImageColor3 = t.Accent
    m2Icon.ScaleType = Enum.ScaleType.Fit

    local m2Title = Instance.new("TextLabel")
    m2Title.Parent = modal2
    m2Title.BackgroundTransparency = 1
    m2Title.AnchorPoint = Vector2.new(0.5,0)
    m2Title.Position = UDim2.new(0.5,0,0, mobile and 116 or 128)
    m2Title.Size = UDim2.new(0.85,0,0,36)
    m2Title.ZIndex = 12
    m2Title.Font = Enum.Font.GothamMedium
    m2Title.Text = "Notice"
    m2Title.TextColor3 = t.PrimaryText
    m2Title.TextSize = mobile and 20 or 22

    local m2Body = Instance.new("TextLabel")
    m2Body.Parent = modal2
    m2Body.BackgroundTransparency = 1
    m2Body.AnchorPoint = Vector2.new(0.5,0)
    m2Body.Position = UDim2.new(0.5,0,0, mobile and 156 or 168)
    m2Body.Size = UDim2.new(0.85,0,0,72)
    m2Body.ZIndex = 12
    m2Body.Font = Enum.Font.Gotham
    m2Body.Text = ""
    m2Body.TextColor3 = t.SecondaryText
    m2Body.TextSize = mobile and 14 or 15
    m2Body.TextWrapped = true

    local m2Btn1 = Instance.new("TextButton")
    m2Btn1.Parent = modal2
    m2Btn1.AnchorPoint = Vector2.new(0.5,1)
    m2Btn1.BackgroundColor3 = t.Accent
    m2Btn1.Position = UDim2.new(0.5,0,1, mobile and -74 or -70)
    m2Btn1.Size = UDim2.new(0.82,0,0, mobile and 50 or 46)
    m2Btn1.ZIndex = 12
    m2Btn1.Font = Enum.Font.GothamMedium
    m2Btn1.Text = "Yes"
    m2Btn1.TextColor3 = t.AccentText
    m2Btn1.TextSize = mobile and 17 or 18
    _makeCorner(m2Btn1, 10)

    local m2Btn2 = Instance.new("TextButton")
    m2Btn2.Parent = modal2
    m2Btn2.AnchorPoint = Vector2.new(0.5,1)
    m2Btn2.BackgroundColor3 = t.ButtonBg
    m2Btn2.Position = UDim2.new(0.5,0,1,-16)
    m2Btn2.Size = UDim2.new(0.82,0,0, mobile and 50 or 46)
    m2Btn2.ZIndex = 12
    m2Btn2.Font = Enum.Font.GothamMedium
    m2Btn2.Text = "No"
    m2Btn2.TextColor3 = t.SecondaryText
    m2Btn2.TextSize = mobile and 17 or 18
    _makeCorner(m2Btn2, 10)

    local _m2conn1, _m2conn2
    --[[
        window:Notify2(title, body, btn1, btn2, icon, cb1, cb2)
    --]]
    function window:Notify2(t1, t2, b1, b2, icon, cb1, cb2)
        if modal1.Visible or modal2.Visible then return end
        m2Title.Text = t1 or "Notice"
        m2Body.Text  = t2 or ""
        m2Btn1.Text  = b1 or "Yes"
        m2Btn2.Text  = b2 or "No"
        if icon then m2Icon.Image = icon end
        _showOverlay(); modal2.Visible = true
        if _m2conn1 then _m2conn1:Disconnect() end
        if _m2conn2 then _m2conn2:Disconnect() end
        _m2conn1 = m2Btn1.MouseButton1Click:Connect(function()
            modal2.Visible = false; _hideOverlay()
            if cb1 then cb1() end
        end)
        _m2conn2 = m2Btn2.MouseButton1Click:Connect(function()
            modal2.Visible = false; _hideOverlay()
            if cb2 then cb2() end
        end)
    end

    -- ──────────────────────────────────────────────────────────────────────────
    -- SIDEBAR HELPERS
    -- ──────────────────────────────────────────────────────────────────────────

    --[[
        window:Divider(name)
        Small category heading inside the sidebar tab list.
    --]]
    function window:Divider(name)
        local lbl = Instance.new("TextLabel")
        lbl.Parent = sidebarList
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -16, 0, mobile and 28 or 24)
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = string.upper(name or "")
        lbl.TextColor3 = t.SecondaryText
        lbl.TextSize = mobile and 12 or 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        _makePadding(lbl, 0, 0, 10, 0)
    end

    -- ──────────────────────────────────────────────────────────────────────────
    -- SECTION (TAB)
    -- ──────────────────────────────────────────────────────────────────────────

    --[[
        window:Section(name) → sec

        Creates a sidebar tab and its content panel.
        On mobile, tapping a tab also closes the sidebar drawer automatically.
    --]]
    function window:Section(name)
        local t = _activeTheme

        -- Tab height: larger on mobile for easier tapping
        local TAB_H = mobile and 48 or 38

        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "tabBtn_" .. (name or "Section")
        tabBtn.Parent = sidebarList
        tabBtn.BackgroundColor3 = t.Accent
        tabBtn.BackgroundTransparency = 1
        tabBtn.Size = UDim2.new(1, -16, 0, TAB_H)
        tabBtn.AutoButtonColor = false
        tabBtn.ZIndex = 31
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.Text = name or "Section"
        tabBtn.TextColor3 = t.PrimaryText
        tabBtn.TextSize = mobile and 17 or 16
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        _makeCorner(tabBtn, 10)
        _makePadding(tabBtn, 0, 0, 14, 0)
        table.insert(_sectionList, tabBtn)

        -- Content panel
        local content = Instance.new("ScrollingFrame")
        content.Name = "sectionContent_" .. (name or "Section")
        content.Parent = workareaOuter
        content.Active = true
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.Position = UDim2.new(0, mobile and 14 or 18, 0, 10)
        content.Size = UDim2.new(1, mobile and -28 or -36, 1, -20)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.CanvasSize = UDim2.new(0,0,0,0)
        -- Hidden scrollbar on mobile (users scroll with touch)
        content.ScrollBarThickness = mobile and 0 or 2
        content.ScrollBarImageColor3 = t.Accent
        content.Visible = false
        content.ZIndex = 2
        _makeListLayout(content, Enum.FillDirection.Vertical,
            Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top,
            mobile and 8 or 6)
        _makePadding(content, 4, 24, 0, 0)

        local sec = {}

        function sec:Select()
            for _, entry in ipairs(_sectionList) do
                entry.BackgroundTransparency = 1
                entry.TextColor3 = t.PrimaryText
            end
            tabBtn.BackgroundTransparency = 0
            tabBtn.TextColor3 = t.AccentText
            for _, ch in ipairs(workareaOuter:GetChildren()) do
                if ch:IsA("ScrollingFrame") then ch.Visible = false end
            end
            content.Visible = true
            -- Auto-close drawer on mobile after selecting a tab
            if mobile and sidebar._closeFn then
                sidebar._closeFn()
            end
        end

        tabBtn.MouseButton1Click:Connect(function() sec:Select() end)

        -- Hover tint (desktop)
        if not mobile then
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
        end

        -- Touch ripple (mobile)
        if mobile then
            tabBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then
                    if tabBtn.BackgroundTransparency ~= 0 then
                        _tweenTransparency(tabBtn, "BackgroundTransparency", 0.7, 0.08)
                        task.wait(0.14)
                        _tweenTransparency(tabBtn, "BackgroundTransparency", 1, 0.15)
                    end
                end
            end)
        end

        -- ── Shared element helpers ─────────────────────────────────────────────

        -- Row height constants — larger on mobile
        local ROW_H      = mobile and 56 or 40
        local ROW_H_DESC = mobile and 70 or 54

        local function _makeRow(hasDesc)
            local row = Instance.new("Frame")
            row.Name = "row"
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, hasDesc and ROW_H_DESC or ROW_H)
            _makeCorner(row, mobile and 12 or 10)
            _makeStroke(row, t.Separator, 1, 0.5)
            return row
        end

        local function _makeNameLabel(parent, name2, hasDesc)
            local lbl = Instance.new("TextLabel")
            lbl.Parent = parent
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.new(0, 14, 0, hasDesc and (mobile and 10 or 8) or 0)
            lbl.Size = UDim2.new(0.6, -14, 0, mobile and 30 or 26)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = name2 or ""
            lbl.TextColor3 = t.PrimaryText
            lbl.TextSize = mobile and 18 or 17
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            return lbl
        end

        local function _makeDescLabel(parent, desc, rowH)
            if not desc then return end
            local lbl = Instance.new("TextLabel")
            lbl.Parent = parent
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.new(0, 14, 0, mobile and 38 or 30)
            lbl.Size = UDim2.new(0.65, -14, 0, mobile and 20 or 18)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = desc
            lbl.TextColor3 = t.SecondaryText
            lbl.TextSize = mobile and 13 or 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            return lbl
        end

        -- ── sec:Divider(name) ──────────────────────────────────────────────────
        function sec:Divider(name2)
            local lbl = Instance.new("TextLabel")
            lbl.Parent = content
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, mobile and 50 or 44)
            lbl.Font = Enum.Font.GothamMedium
            lbl.Text = name2 or ""
            lbl.TextColor3 = t.PrimaryText
            lbl.TextSize = mobile and 20 or 22
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Bottom
            local line = Instance.new("Frame")
            line.Parent = lbl
            line.BackgroundColor3 = t.Separator
            line.BorderSizePixel = 0
            line.AnchorPoint = Vector2.new(0,1)
            line.Position = UDim2.new(0,0,1,0)
            line.Size = UDim2.new(1,0,0,1)
        end

        -- ── sec:Label(name) ───────────────────────────────────────────────────
        function sec:Label(name2)
            local lbl = Instance.new("TextLabel")
            lbl.Parent = content
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1,0,0, mobile and 42 or 36)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = name2 or ""
            lbl.TextColor3 = t.SecondaryText
            lbl.TextSize = mobile and 16 or 16
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            local obj = {}
            function obj:Set(tx) lbl.Text = tostring(tx) end
            function obj:Get() return lbl.Text end
            return obj
        end

        -- ── sec:Button(name, description, callback) ────────────────────────────
        function sec:Button(name2, description, callback)
            if type(description) == "function" then
                callback = description; description = nil
            end
            local row = _makeRow(description ~= nil)
            local btn = Instance.new("TextButton")
            btn.Parent = row
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1,0,1,0)
            btn.ZIndex = 3
            btn.Text = ""
            btn.AutoButtonColor = false

            local nameLbl = _makeNameLabel(row, name2, description ~= nil)
            nameLbl.TextColor3 = t.Accent
            _makeDescLabel(row, description)

            local arrow = Instance.new("TextLabel")
            arrow.Parent = row
            arrow.BackgroundTransparency = 1
            arrow.AnchorPoint = Vector2.new(1,0.5)
            arrow.Position = UDim2.new(1,-12,0.5,0)
            arrow.Size = UDim2.new(0,22,0,22)
            arrow.ZIndex = 3
            arrow.Font = Enum.Font.GothamMedium
            arrow.Text = "›"
            arrow.TextColor3 = t.Accent
            arrow.TextSize = mobile and 28 or 26

            if not mobile then
                btn.MouseEnter:Connect(function()
                    _tweenTransparency(row,"BackgroundTransparency",0.35,0.12)
                end)
                btn.MouseLeave:Connect(function()
                    _tweenTransparency(row,"BackgroundTransparency",0.55,0.12)
                end)
            end

            btn.MouseButton1Click:Connect(function()
                coroutine.wrap(function()
                    _tweenTransparency(row,"BackgroundTransparency",0.15,0.08)
                    task.wait(0.14)
                    _tweenTransparency(row,"BackgroundTransparency",0.55,0.18)
                end)()
                if callback then coroutine.wrap(callback)() end
            end)

            local obj = {}
            function obj:SetText(tx) nameLbl.Text = tostring(tx) end
            function obj:SetEnabled(en)
                btn.Active = en
                nameLbl.TextColor3 = en and t.Accent or t.SecondaryText
                arrow.TextColor3   = en and t.Accent or t.SecondaryText
            end
            return obj
        end

        -- ── sec:Switch(name, description, default, callback) ───────────────────
        function sec:Switch(name2, description, default, callback)
            if type(description) == "boolean" then
                callback = default; default = description; description = nil
            end
            local state = default == true
            local row = _makeRow(description ~= nil)
            _makeNameLabel(row, name2, description ~= nil)
            _makeDescLabel(row, description)

            -- Track — bigger on mobile
            local TRK_W = mobile and 62 or 56
            local TRK_H = mobile and 34 or 30
            local THM_S = mobile and 28 or 26

            local track = Instance.new("TextButton")
            track.Parent = row
            track.AnchorPoint = Vector2.new(1,0.5)
            track.Position = UDim2.new(1,-14,0.5,0)
            track.Size = UDim2.new(0,TRK_W,0,TRK_H)
            track.AutoButtonColor = false
            track.Text = ""
            track.BackgroundColor3 = state and t.SwitchOn or t.SwitchOff
            track.ZIndex = 3
            _makeCorner(track, TRK_H)

            local thumb = Instance.new("Frame")
            thumb.Parent = track
            thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
            thumb.AnchorPoint = Vector2.new(0,0.5)
            thumb.Position = state and UDim2.new(0, TRK_W-THM_S-2, 0.5,0) or UDim2.new(0,2,0.5,0)
            thumb.Size = UDim2.new(0,THM_S,0,THM_S)
            thumb.ZIndex = 4
            _makeCorner(thumb, THM_S)
            _makeShadow(thumb, 3, UDim2.new(1.3,0,1.3,0), 0.55)

            local function _applyState(s)
                state = s
                _tweenPos(thumb, s and UDim2.new(0,TRK_W-THM_S-2,0.5,0) or UDim2.new(0,2,0.5,0), 0.18)
                _tweenColor(track,"BackgroundColor3", s and t.SwitchOn or t.SwitchOff, 0.18)
            end
            local function _toggle()
                _applyState(not state)
                if callback then coroutine.wrap(function() callback(state) end)() end
            end
            track.MouseButton1Click:Connect(_toggle)
            thumb.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then _toggle() end
            end)

            local obj = {}
            function obj:Set(v) _applyState(v==true); if callback then coroutine.wrap(function() callback(state) end)() end end
            function obj:Get() return state end
            return obj
        end

        -- ── sec:Slider(name, description, min, max, default, step, callback) ───
        function sec:Slider(name2, description, minV, maxV, default, step, callback)
            minV = minV or 0; maxV = maxV or 100
            default = default or minV; step = step or 0
            local value = _clamp(default, minV, maxV)

            local rowH = (description ~= nil) and (mobile and 82 or 66) or (mobile and 68 or 54)
            local row = Instance.new("Frame")
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1,0,0,rowH)
            _makeCorner(row, mobile and 12 or 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0,14,0, mobile and 10 or 8)
            nameLbl.Size = UDim2.new(0.62,-14,0, mobile and 26 or 22)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name2 or "Slider"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = mobile and 18 or 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel")
            valLbl.Parent = row
            valLbl.BackgroundTransparency = 1
            valLbl.AnchorPoint = Vector2.new(1,0)
            valLbl.Position = UDim2.new(1,-14,0, mobile and 10 or 8)
            valLbl.Size = UDim2.new(0.35,0,0, mobile and 26 or 22)
            valLbl.Font = Enum.Font.GothamMedium
            valLbl.Text = tostring(_round(value,2))
            valLbl.TextColor3 = t.Accent
            valLbl.TextSize = mobile and 18 or 16
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            if description then
                local d = Instance.new("TextLabel")
                d.Parent = row
                d.BackgroundTransparency = 1
                d.Position = UDim2.new(0,14,0, mobile and 36 or 28)
                d.Size = UDim2.new(0.8,-14,0, mobile and 18 or 14)
                d.Font = Enum.Font.Gotham
                d.Text = description
                d.TextColor3 = t.SecondaryText
                d.TextSize = mobile and 13 or 11
                d.TextXAlignment = Enum.TextXAlignment.Left
            end

            local trackY = description and (mobile and 60 or 48) or (mobile and 48 or 36)
            local TRACK_H = mobile and 8 or 6
            local KNOB_S  = mobile and 24 or 18

            local track = Instance.new("Frame")
            track.Parent = row
            track.BackgroundColor3 = t.SliderTrack
            track.BorderSizePixel = 0
            track.Position = UDim2.new(0,14,0,trackY)
            track.Size = UDim2.new(1,-28,0,TRACK_H)
            _makeCorner(track, TRACK_H)

            local fill = Instance.new("Frame")
            fill.Parent = track
            fill.BackgroundColor3 = t.SliderFill
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new((value-minV)/(maxV-minV),0,1,0)
            _makeCorner(fill, TRACK_H)

            local knob = Instance.new("Frame")
            knob.Parent = track
            knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
            knob.AnchorPoint = Vector2.new(0.5,0.5)
            knob.Position = UDim2.new((value-minV)/(maxV-minV),0,0.5,0)
            knob.Size = UDim2.new(0,KNOB_S,0,KNOB_S)
            knob.ZIndex = 2
            _makeCorner(knob, KNOB_S)
            _makeStroke(knob, t.SliderFill, 2)
            _makeShadow(knob, 1, UDim2.new(1.5,0,1.5,0), 0.55)

            -- Larger invisible hit area for touch
            local hitH = mobile and 44 or 30
            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Parent = row
            sliderBtn.BackgroundTransparency = 1
            sliderBtn.Position = UDim2.new(0,0,0,trackY - math.floor((hitH-TRACK_H)/2))
            sliderBtn.Size = UDim2.new(1,0,0,hitH)
            sliderBtn.Text = ""
            sliderBtn.ZIndex = 4

            local draggingSlider = false
            local function _updateSlider(inputX)
                local tAbs = track.AbsolutePosition.X
                local tSz  = track.AbsoluteSize.X
                local rel  = _clamp((inputX - tAbs) / tSz, 0, 1)
                local raw  = minV + rel * (maxV - minV)
                if step and step > 0 then
                    raw = math.floor((raw - minV) / step + 0.5) * step + minV
                end
                value = _clamp(raw, minV, maxV)
                local pct = (value - minV) / (maxV - minV)
                fill.Size = UDim2.new(pct,0,1,0)
                knob.Position = UDim2.new(pct,0,0.5,0)
                valLbl.Text = tostring(_round(value,2))
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
                value = _clamp(v, minV, maxV)
                local pct = (value-minV)/(maxV-minV)
                fill.Size = UDim2.new(pct,0,1,0)
                knob.Position = UDim2.new(pct,0,0.5,0)
                valLbl.Text = tostring(_round(value,2))
            end
            function obj:Get() return value end
            return obj
        end

        -- ── sec:TextField(name, placeholder, default, callback) ────────────────
        function sec:TextField(name2, placeholder, default, callback)
            local row = _makeRow(false)
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0,14,0,0)
            nameLbl.Size = UDim2.new(0.36,-14,1,0)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name2 or "Input"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = mobile and 18 or 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

            local inputBg = Instance.new("Frame")
            inputBg.Parent = row
            inputBg.BackgroundColor3 = t.InputBg
            inputBg.AnchorPoint = Vector2.new(1,0.5)
            inputBg.Position = UDim2.new(1,-10,0.5,0)
            inputBg.Size = UDim2.new(0.6,0,0, mobile and 36 or 28)
            _makeCorner(inputBg, mobile and 9 or 7)
            _makeStroke(inputBg, t.Separator, 1, 0.3)

            local tb = Instance.new("TextBox")
            tb.Parent = inputBg
            tb.BackgroundTransparency = 1
            tb.Position = UDim2.new(0,8,0,0)
            tb.Size = UDim2.new(1,-16,1,0)
            tb.ClearTextOnFocus = false
            tb.Font = Enum.Font.Gotham
            tb.PlaceholderText = placeholder or "Type..."
            tb.PlaceholderColor3 = t.PlaceholderText
            tb.Text = default or ""
            tb.TextColor3 = t.PrimaryText
            tb.TextSize = mobile and 16 or 14
            tb.TextXAlignment = Enum.TextXAlignment.Left

            tb.Focused:Connect(function() _makeStroke(inputBg, t.Accent, 1.5) end)
            tb.FocusLost:Connect(function()
                _makeStroke(inputBg, t.Separator, 1, 0.3)
                if callback then coroutine.wrap(function() callback(tb.Text) end)() end
            end)

            local obj = {}
            function obj:Set(tx) tb.Text = tostring(tx) end
            function obj:Get() return tb.Text end
            return obj
        end

        -- ── sec:Dropdown(name, description, options, default, callback) ─────────
        function sec:Dropdown(name2, description, options, default, callback)
            local selected = default or (options and options[1]) or ""
            local open2 = false

            local container = Instance.new("Frame")
            container.Parent = content
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1,0,0, description and ROW_H_DESC or ROW_H)
            container.ClipsDescendants = false
            container.ZIndex = 8

            local row = Instance.new("Frame")
            row.Parent = container
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.Size = UDim2.new(1,0,1,0)
            row.ZIndex = 8
            _makeCorner(row, mobile and 12 or 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            _makeNameLabel(row, name2, description ~= nil)
            _makeDescLabel(row, description)

            local pill = Instance.new("Frame")
            pill.Parent = row
            pill.BackgroundColor3 = t.Accent
            pill.BackgroundTransparency = 0.82
            pill.AnchorPoint = Vector2.new(1,0.5)
            pill.Position = UDim2.new(1,-32,0.5,0)
            pill.Size = UDim2.new(0.42,0,0, mobile and 28 or 24)
            pill.ZIndex = 9
            _makeCorner(pill, 7)

            local selectedLbl = Instance.new("TextLabel")
            selectedLbl.Parent = pill
            selectedLbl.BackgroundTransparency = 1
            selectedLbl.Size = UDim2.new(1,-8,1,0)
            selectedLbl.Position = UDim2.new(0,4,0,0)
            selectedLbl.Font = Enum.Font.Gotham
            selectedLbl.Text = selected
            selectedLbl.TextColor3 = t.Accent
            selectedLbl.TextSize = mobile and 14 or 13
            selectedLbl.TextTruncate = Enum.TextTruncate.AtEnd
            selectedLbl.ZIndex = 10

            local chevron = Instance.new("TextLabel")
            chevron.Parent = row
            chevron.BackgroundTransparency = 1
            chevron.AnchorPoint = Vector2.new(1,0.5)
            chevron.Position = UDim2.new(1,-10,0.5,0)
            chevron.Size = UDim2.new(0,20,0,20)
            chevron.Font = Enum.Font.GothamMedium
            chevron.Text = "⌄"
            chevron.TextColor3 = t.SecondaryText
            chevron.TextSize = mobile and 20 or 18
            chevron.ZIndex = 9

            local ITEM_H = mobile and 48 or 34
            local panel = Instance.new("ScrollingFrame")
            panel.Parent = container
            panel.BackgroundColor3 = t.DropdownBg
            panel.BorderSizePixel = 0
            panel.Position = UDim2.new(0,0,1,4)
            panel.Size = UDim2.new(1,0,0,0)
            panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
            panel.CanvasSize = UDim2.new(0,0,0,0)
            panel.ScrollBarThickness = mobile and 0 or 2
            panel.ScrollBarImageColor3 = t.Accent
            panel.ZIndex = 20
            panel.Visible = false
            panel.ClipsDescendants = true
            _makeCorner(panel, mobile and 12 or 10)
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
                    item.Parent = panel
                    item.BackgroundColor3 = t.DropdownItem
                    item.BackgroundTransparency = 1
                    item.Size = UDim2.new(1,-8,0,ITEM_H)
                    item.Font = Enum.Font.Gotham
                    item.Text = opt
                    item.TextColor3 = (opt == selected) and t.Accent or t.PrimaryText
                    item.TextSize = mobile and 17 or 15
                    item.ZIndex = 21
                    _makeCorner(item, mobile and 9 or 7)

                    item.MouseEnter:Connect(function()
                        _tweenTransparency(item,"BackgroundTransparency",0.75,0.1)
                    end)
                    item.MouseLeave:Connect(function()
                        _tweenTransparency(item,"BackgroundTransparency",1,0.1)
                    end)
                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        selectedLbl.Text = opt
                        for _, ch2 in ipairs(panel:GetChildren()) do
                            if ch2:IsA("TextButton") then
                                ch2.TextColor3 = (ch2.Text == selected) and t.Accent or t.PrimaryText
                            end
                        end
                        open2 = false
                        chevron.Text = "⌄"
                        _tween(panel, TweenInfo.new(0.2,Enum.EasingStyle.Quad),
                            {Size = UDim2.new(1,0,0,0)})
                        task.wait(0.22); panel.Visible = false
                        if callback then coroutine.wrap(function() callback(selected) end)() end
                    end)
                end
            end
            _buildOptions(options)

            local headerBtn = Instance.new("TextButton")
            headerBtn.Parent = row
            headerBtn.BackgroundTransparency = 1
            headerBtn.Size = UDim2.new(1,0,1,0)
            headerBtn.Text = ""
            headerBtn.ZIndex = 10

            headerBtn.MouseButton1Click:Connect(function()
                open2 = not open2
                if open2 then
                    panel.Visible = true; chevron.Text = "⌃"
                    local maxH = mobile and 220 or 200
                    local targetH = math.min(#(options or {}) * ITEM_H + 8, maxH)
                    _tween(panel, TweenInfo.new(0.2,Enum.EasingStyle.Quad),
                        {Size = UDim2.new(1,0,0,targetH)})
                else
                    chevron.Text = "⌄"
                    _tween(panel, TweenInfo.new(0.2,Enum.EasingStyle.Quad),
                        {Size = UDim2.new(1,0,0,0)})
                    task.delay(0.22, function() if not open2 then panel.Visible = false end end)
                end
            end)

            local obj = {}
            function obj:Set(opt)
                selected = opt; selectedLbl.Text = opt
                for _, ch in ipairs(panel:GetChildren()) do
                    if ch:IsA("TextButton") then
                        ch.TextColor3 = (ch.Text == opt) and t.Accent or t.PrimaryText
                    end
                end
            end
            function obj:Get() return selected end
            function obj:Refresh(opts) options = opts; _buildOptions(opts) end
            return obj
        end

        -- ── sec:ColorPicker(name, description, default, callback) ──────────────
        function sec:ColorPicker(name2, description, default, callback)
            default = default or Color3.fromRGB(255,0,0)
            local h, s, v2 = Color3.toHSV(default)
            local currentColor = default

            local row = _makeRow(description ~= nil)
            _makeNameLabel(row, name2, description ~= nil)
            _makeDescLabel(row, description)

            local swatch = Instance.new("TextButton")
            swatch.Parent = row
            swatch.BackgroundColor3 = currentColor
            swatch.AnchorPoint = Vector2.new(1,0.5)
            swatch.Position = UDim2.new(1,-14,0.5,0)
            swatch.Size = UDim2.new(0, mobile and 64 or 56, 0, mobile and 34 or 28)
            swatch.Text = ""
            swatch.ZIndex = 4
            _makeCorner(swatch, mobile and 10 or 8)
            _makeStroke(swatch, t.Separator, 1, 0.3)

            local pickerPanel = Instance.new("Frame")
            pickerPanel.Parent = content
            pickerPanel.BackgroundColor3 = t.DropdownBg
            pickerPanel.BackgroundTransparency = 0.4
            pickerPanel.Size = UDim2.new(1,0,0,0)
            pickerPanel.ClipsDescendants = true
            pickerPanel.ZIndex = 9
            pickerPanel.Visible = false
            _makeCorner(pickerPanel, mobile and 12 or 10)
            _makeStroke(pickerPanel, t.Separator, 1, 0.3)

            local pickerOpen = false

            local function _refreshColor()
                currentColor = Color3.fromHSV(h, s, v2)
                swatch.BackgroundColor3 = currentColor
                if callback then coroutine.wrap(function() callback(currentColor) end)() end
            end

            local PICKER_H = mobile and 160 or 130
            local SL_Y_STEP = mobile and 48 or 38

            local function _buildPicker()
                for _, ch in ipairs(pickerPanel:GetChildren()) do ch:Destroy() end

                local function _hsvSlider(label2, yPos, initial, slCb)
                    local LABEL_W = mobile and 24 or 18
                    local KNOB2   = mobile and 18 or 14

                    local lbl2 = Instance.new("TextLabel")
                    lbl2.Parent = pickerPanel
                    lbl2.BackgroundTransparency = 1
                    lbl2.Position = UDim2.new(0,14,0,yPos)
                    lbl2.Size = UDim2.new(0,LABEL_W,0, mobile and 22 or 18)
                    lbl2.Font = Enum.Font.Gotham
                    lbl2.Text = label2
                    lbl2.TextColor3 = t.SecondaryText
                    lbl2.TextSize = mobile and 14 or 12
                    lbl2.ZIndex = 10

                    local sTrk = Instance.new("Frame")
                    sTrk.Parent = pickerPanel
                    sTrk.BackgroundColor3 = t.SliderTrack
                    sTrk.Position = UDim2.new(0, 14+LABEL_W+6, 0, yPos + (mobile and 8 or 6))
                    sTrk.Size = UDim2.new(0.62,0,0, mobile and 8 or 6)
                    sTrk.ZIndex = 10
                    _makeCorner(sTrk, 3)

                    local sFill = Instance.new("Frame")
                    sFill.Parent = sTrk
                    sFill.BackgroundColor3 = t.SliderFill
                    sFill.Size = UDim2.new(initial,0,1,0)
                    sFill.ZIndex = 11
                    _makeCorner(sFill, 3)

                    local sKnob = Instance.new("Frame")
                    sKnob.Parent = sTrk
                    sKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
                    sKnob.AnchorPoint = Vector2.new(0.5,0.5)
                    sKnob.Position = UDim2.new(initial,0,0.5,0)
                    sKnob.Size = UDim2.new(0,KNOB2,0,KNOB2)
                    sKnob.ZIndex = 12
                    _makeCorner(sKnob, KNOB2)
                    _makeStroke(sKnob, t.Accent, 1.5)

                    local sValLbl = Instance.new("TextLabel")
                    sValLbl.Parent = pickerPanel
                    sValLbl.BackgroundTransparency = 1
                    sValLbl.AnchorPoint = Vector2.new(1,0)
                    sValLbl.Position = UDim2.new(1,-14,0,yPos)
                    sValLbl.Size = UDim2.new(0.16,0,0, mobile and 22 or 18)
                    sValLbl.Font = Enum.Font.GothamMedium
                    sValLbl.Text = tostring(_round(initial*100,0))
                    sValLbl.TextColor3 = t.Accent
                    sValLbl.TextSize = mobile and 13 or 12
                    sValLbl.TextXAlignment = Enum.TextXAlignment.Right
                    sValLbl.ZIndex = 10

                    local hitH2 = mobile and 44 or 24
                    local sBtn = Instance.new("TextButton")
                    sBtn.Parent = pickerPanel
                    sBtn.BackgroundTransparency = 1
                    sBtn.Position = UDim2.new(0, 14+LABEL_W, 0, yPos - math.floor((hitH2-8)/2))
                    sBtn.Size = UDim2.new(0.62,12,0,hitH2)
                    sBtn.Text = ""; sBtn.ZIndex = 13
                    local dragS2 = false
                    sBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1
                        or inp.UserInputType == Enum.UserInputType.Touch then dragS2 = true end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1
                        or inp.UserInputType == Enum.UserInputType.Touch then dragS2 = false end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if dragS2 and (inp.UserInputType == Enum.UserInputType.MouseMovement
                        or inp.UserInputType == Enum.UserInputType.Touch) then
                            local rel = _clamp((inp.Position.X - sTrk.AbsolutePosition.X) / sTrk.AbsoluteSize.X, 0, 1)
                            sFill.Size = UDim2.new(rel,0,1,0)
                            sKnob.Position = UDim2.new(rel,0,0.5,0)
                            sValLbl.Text = tostring(_round(rel*100,0))
                            slCb(rel)
                        end
                    end)
                end

                _hsvSlider("H", mobile and 12 or 10,  h,   function(val) h  = val _refreshColor() end)
                _hsvSlider("S", mobile and 12+SL_Y_STEP or 10+SL_Y_STEP, s, function(val) s  = val _refreshColor() end)
                _hsvSlider("V", mobile and 12+SL_Y_STEP*2 or 10+SL_Y_STEP*2, v2, function(val) v2 = val _refreshColor() end)
            end

            swatch.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    pickerPanel.Visible = true
                    _buildPicker()
                    _tween(pickerPanel, TweenInfo.new(0.2,Enum.EasingStyle.Quad),
                        {Size = UDim2.new(1,0,0,PICKER_H)})
                else
                    _tween(pickerPanel, TweenInfo.new(0.2,Enum.EasingStyle.Quad),
                        {Size = UDim2.new(1,0,0,0)})
                    task.delay(0.22, function() pickerPanel.Visible = false end)
                end
            end)

            local obj = {}
            function obj:Set(c3)
                currentColor = c3; swatch.BackgroundColor3 = c3
                h, s, v2 = Color3.toHSV(c3)
            end
            function obj:Get() return currentColor end
            return obj
        end

        -- ── sec:Keybind(name, description, default, callback) ──────────────────
        function sec:Keybind(name2, description, default, callback)
            local boundKey = default or Enum.KeyCode.Unknown
            local listening = false
            local row = _makeRow(description ~= nil)
            _makeNameLabel(row, name2, description ~= nil)
            _makeDescLabel(row, description)

            local keyPill = Instance.new("TextButton")
            keyPill.Parent = row
            keyPill.BackgroundColor3 = t.InputBg
            keyPill.AnchorPoint = Vector2.new(1,0.5)
            keyPill.Position = UDim2.new(1,-14,0.5,0)
            keyPill.Size = UDim2.new(0, mobile and 90 or 80, 0, mobile and 32 or 26)
            keyPill.Font = Enum.Font.GothamMedium
            keyPill.Text = boundKey.Name
            keyPill.TextColor3 = t.Accent
            keyPill.TextSize = mobile and 14 or 13
            keyPill.ZIndex = 4
            _makeCorner(keyPill, mobile and 9 or 7)
            _makeStroke(keyPill, t.Accent, 1, 0.4)

            if mobile then
                -- On mobile, tapping shows an on-screen keyboard note
                keyPill.MouseButton1Click:Connect(function()
                    listening = true
                    keyPill.Text = "Press key…"
                    keyPill.TextColor3 = t.SecondaryText
                    keyPill.TextSize = 11
                end)
            else
                keyPill.MouseButton1Click:Connect(function()
                    listening = true
                    keyPill.Text = "..."
                    keyPill.TextColor3 = t.SecondaryText
                end)
            end

            UserInputService.InputBegan:Connect(function(inp, gpe)
                if listening then
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        boundKey = inp.KeyCode
                        keyPill.Text = boundKey.Name
                        keyPill.TextColor3 = t.Accent
                        keyPill.TextSize = mobile and 14 or 13
                        listening = false
                    end
                    return
                end
                if not gpe and inp.KeyCode == boundKey then
                    if callback then coroutine.wrap(callback)() end
                end
            end)

            local obj = {}
            function obj:Set(kc) boundKey = kc; keyPill.Text = kc.Name end
            function obj:Get() return boundKey end
            return obj
        end

        -- ── sec:ProgressBar(name, description, default, max) ──────────────────
        function sec:ProgressBar(name2, description, default, maxVal)
            maxVal = maxVal or 100
            local value = _clamp(default or 0, 0, maxVal)

            local rowH = description and (mobile and 76 or 60) or (mobile and 62 or 48)
            local row = Instance.new("Frame")
            row.Parent = content
            row.BackgroundColor3 = t.ButtonBg
            row.BackgroundTransparency = 0.55
            row.Size = UDim2.new(1,0,0,rowH)
            _makeCorner(row, mobile and 12 or 10)
            _makeStroke(row, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = row
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0,14,0, mobile and 10 or 8)
            nameLbl.Size = UDim2.new(0.65,-14,0, mobile and 26 or 22)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name2 or "Progress"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = mobile and 18 or 16
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel")
            valLbl.Parent = row
            valLbl.BackgroundTransparency = 1
            valLbl.AnchorPoint = Vector2.new(1,0)
            valLbl.Position = UDim2.new(1,-14,0, mobile and 10 or 8)
            valLbl.Size = UDim2.new(0.32,0,0, mobile and 26 or 22)
            valLbl.Font = Enum.Font.GothamMedium
            valLbl.Text = tostring(_round(value,1)).." / "..tostring(maxVal)
            valLbl.TextColor3 = t.SecondaryText
            valLbl.TextSize = mobile and 14 or 13
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            _makeDescLabel(row, description)

            local TRACK_H = mobile and 10 or 8
            local trackY  = description and (mobile and 52 or 42) or (mobile and 44 or 34)
            local track   = Instance.new("Frame")
            track.Parent = row
            track.BackgroundColor3 = t.ProgressBg
            track.Position = UDim2.new(0,14,0,trackY)
            track.Size = UDim2.new(1,-28,0,TRACK_H)
            _makeCorner(track, TRACK_H)

            local fill = Instance.new("Frame")
            fill.Parent = track
            fill.BackgroundColor3 = t.Progress
            fill.Size = UDim2.new(_clamp(value/maxVal,0,1),0,1,0)
            _makeCorner(fill, TRACK_H)

            local obj = {}
            function obj:Set(v)
                value = _clamp(v, 0, maxVal)
                _tween(fill, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                    {Size = UDim2.new(value/maxVal,0,1,0)})
                valLbl.Text = tostring(_round(value,1)).." / "..tostring(maxVal)
            end
            function obj:Get() return value end
            function obj:SetMax(m) maxVal = m; self:Set(value) end
            return obj
        end

        -- ── sec:MultiSwitch(name, options, default, callback) ─────────────────
        function sec:MultiSwitch(name2, options, default, callback)
            local selected = default or (options and options[1]) or ""
            local outerH   = mobile and 88 or 70

            local outer = Instance.new("Frame")
            outer.Parent = content
            outer.BackgroundColor3 = t.ButtonBg
            outer.BackgroundTransparency = 0.55
            outer.Size = UDim2.new(1,0,0,outerH)
            _makeCorner(outer, mobile and 12 or 10)
            _makeStroke(outer, t.Separator, 1, 0.5)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Parent = outer
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position = UDim2.new(0,14,0, mobile and 10 or 8)
            nameLbl.Size = UDim2.new(1,-28,0, mobile and 26 or 22)
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.Text = name2 or "Segment"
            nameLbl.TextColor3 = t.PrimaryText
            nameLbl.TextSize = mobile and 18 or 15
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            local segY = mobile and 44 or 34
            local segH = mobile and 34 or 26
            local segContainer = Instance.new("Frame")
            segContainer.Parent = outer
            segContainer.BackgroundColor3 = t.SliderTrack
            segContainer.BackgroundTransparency = 0.4
            segContainer.Position = UDim2.new(0,14,0,segY)
            segContainer.Size = UDim2.new(1,-28,0,segH)
            _makeCorner(segContainer, segH)

            local segList = Instance.new("UIListLayout")
            segList.Parent = segContainer
            segList.FillDirection = Enum.FillDirection.Horizontal
            segList.SortOrder = Enum.SortOrder.LayoutOrder

            local buttons = {}
            local function _updateSeg()
                for _, btnObj in ipairs(buttons) do
                    local isSel = (btnObj.lbl.Text == selected)
                    btnObj.bg.BackgroundTransparency = isSel and 0 or 1
                    btnObj.lbl.TextColor3 = isSel and t.AccentText or t.SecondaryText
                    btnObj.lbl.Font = isSel and Enum.Font.GothamMedium or Enum.Font.Gotham
                end
            end

            for _, opt in ipairs(options or {}) do
                local segBg = Instance.new("TextButton")
                segBg.Parent = segContainer
                segBg.BackgroundColor3 = t.Accent
                segBg.BackgroundTransparency = 1
                segBg.Size = UDim2.new(1/#options,0,1,0)
                segBg.Text = ""
                segBg.AutoButtonColor = false
                _makeCorner(segBg, segH)
                local segLbl = Instance.new("TextLabel")
                segLbl.Parent = segBg
                segLbl.BackgroundTransparency = 1
                segLbl.Size = UDim2.new(1,0,1,0)
                segLbl.Font = Enum.Font.Gotham
                segLbl.Text = opt
                segLbl.TextColor3 = (opt == selected) and t.AccentText or t.SecondaryText
                segLbl.TextSize = mobile and 14 or 12
                segLbl.TextTruncate = Enum.TextTruncate.AtEnd
                table.insert(buttons, {bg=segBg, lbl=segLbl})
                segBg.MouseButton1Click:Connect(function()
                    selected = opt
                    _updateSeg()
                    if callback then coroutine.wrap(function() callback(selected) end)() end
                end)
            end
            _updateSeg()

            local obj = {}
            function obj:Set(opt) selected = opt; _updateSeg() end
            function obj:Get() return selected end
            return obj
        end

        -- ── sec:NumericStepper(name, description, min, max, step, default, callback)
        function sec:NumericStepper(name2, description, minV, maxV, step, default, callback)
            minV = minV or 0; maxV = maxV or 100; step = step or 1
            local value = _clamp(default or minV, minV, maxV)
            local row = _makeRow(description ~= nil)
            _makeNameLabel(row, name2, description ~= nil)
            _makeDescLabel(row, description)

            local BTN_S = mobile and 36 or 28
            local stepperFrame = Instance.new("Frame")
            stepperFrame.Parent = row
            stepperFrame.BackgroundTransparency = 1
            stepperFrame.AnchorPoint = Vector2.new(1,0.5)
            stepperFrame.Position = UDim2.new(1,-10,0.5,0)
            stepperFrame.Size = UDim2.new(0, BTN_S*2 + 52 + 12, 0, BTN_S)
            _makeListLayout(stepperFrame, Enum.FillDirection.Horizontal,
                Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center, 6)

            local valDisplay = Instance.new("TextLabel")
            valDisplay.Parent = stepperFrame
            valDisplay.BackgroundColor3 = t.InputBg
            valDisplay.Size = UDim2.new(0, mobile and 60 or 52, 1, 0)
            valDisplay.Font = Enum.Font.GothamMedium
            valDisplay.Text = tostring(value)
            valDisplay.TextColor3 = t.PrimaryText
            valDisplay.TextSize = mobile and 17 or 15
            _makeCorner(valDisplay, 7)

            local function _makeStepBtn2(lbl2, delta)
                local btn = Instance.new("TextButton")
                btn.Parent = stepperFrame
                btn.BackgroundColor3 = t.Accent
                btn.Size = UDim2.new(0,BTN_S,1,0)
                btn.Font = Enum.Font.GothamMedium
                btn.Text = lbl2
                btn.TextColor3 = t.AccentText
                btn.TextSize = mobile and 22 or 18
                btn.AutoButtonColor = false
                _makeCorner(btn, 7)
                local held = false
                btn.MouseButton1Down:Connect(function()
                    held = true
                    coroutine.wrap(function()
                        while held do
                            value = _clamp(value+delta, minV, maxV)
                            valDisplay.Text = tostring(value)
                            if callback then coroutine.wrap(function() callback(value) end)() end
                            task.wait(mobile and 0.15 or 0.12)
                        end
                    end)()
                end)
                btn.MouseButton1Up:Connect(function() held = false end)
                btn.MouseLeave:Connect(function() held = false end)
                btn.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch then held = false end
                end)
                return btn
            end
            _makeStepBtn2("-", -step)
            _makeStepBtn2("+",  step)

            local obj = {}
            function obj:Set(v) value = _clamp(v,minV,maxV); valDisplay.Text = tostring(value) end
            function obj:Get() return value end
            return obj
        end

        -- ── sec:Badge(name, badgeText, color) ────────────────────────────────
        function sec:Badge(name2, badgeText, color)
            local row = _makeRow(false)
            _makeNameLabel(row, name2, false)

            local badge = Instance.new("Frame")
            badge.Parent = row
            badge.BackgroundColor3 = color or t.Badge
            badge.AnchorPoint = Vector2.new(1,0.5)
            badge.Position = UDim2.new(1,-14,0.5,0)
            badge.Size = UDim2.new(0, mobile and 96 or 80, 0, mobile and 28 or 22)
            _makeCorner(badge, mobile and 14 or 11)

            local badgeLbl = Instance.new("TextLabel")
            badgeLbl.Parent = badge
            badgeLbl.BackgroundTransparency = 1
            badgeLbl.Size = UDim2.new(1,-8,1,0)
            badgeLbl.Position = UDim2.new(0,4,0,0)
            badgeLbl.Font = Enum.Font.GothamMedium
            badgeLbl.Text = badgeText or ""
            badgeLbl.TextColor3 = t.BadgeText
            badgeLbl.TextSize = mobile and 14 or 13
            badgeLbl.TextTruncate = Enum.TextTruncate.AtEnd

            local obj = {}
            function obj:SetBadge(tx, c) badgeLbl.Text = tostring(tx); if c then badge.BackgroundColor3 = c end end
            function obj:SetName(tx) -- no-op reference kept for API parity
            end
            return obj
        end

        -- ── sec:InfoCard(title, lines) ─────────────────────────────────────────
        function sec:InfoCard(title2, lines)
            local ITEM_H2 = mobile and 36 or 28
            local card = Instance.new("Frame")
            card.Parent = content
            card.BackgroundColor3 = t.ButtonBg
            card.BackgroundTransparency = 0.45
            card.Size = UDim2.new(1,0,0, (mobile and 34 or 30) + #(lines or {}) * ITEM_H2)
            _makeCorner(card, mobile and 14 or 12)
            _makeStroke(card, t.Separator, 1, 0.4)

            local hdr = Instance.new("TextLabel")
            hdr.Parent = card
            hdr.BackgroundTransparency = 1
            hdr.Position = UDim2.new(0,14,0,6)
            hdr.Size = UDim2.new(1,-28,0, mobile and 26 or 22)
            hdr.Font = Enum.Font.GothamMedium
            hdr.Text = title2 or "Info"
            hdr.TextColor3 = t.SecondaryText
            hdr.TextSize = mobile and 13 or 12
            hdr.TextXAlignment = Enum.TextXAlignment.Left

            for i, pair in ipairs(lines or {}) do
                local lineRow = Instance.new("Frame")
                lineRow.Parent = card
                lineRow.BackgroundTransparency = 1
                lineRow.Position = UDim2.new(0,0,0, (mobile and 32 or 28) + (i-1)*ITEM_H2)
                lineRow.Size = UDim2.new(1,0,0,ITEM_H2)

                local kLbl = Instance.new("TextLabel")
                kLbl.Parent = lineRow
                kLbl.BackgroundTransparency = 1
                kLbl.Position = UDim2.new(0,14,0,0)
                kLbl.Size = UDim2.new(0.45,-14,1,0)
                kLbl.Font = Enum.Font.Gotham
                kLbl.Text = pair.key or ""
                kLbl.TextColor3 = t.SecondaryText
                kLbl.TextSize = mobile and 15 or 14
                kLbl.TextXAlignment = Enum.TextXAlignment.Left

                local vLbl = Instance.new("TextLabel")
                vLbl.Parent = lineRow
                vLbl.BackgroundTransparency = 1
                vLbl.AnchorPoint = Vector2.new(1,0)
                vLbl.Position = UDim2.new(1,-14,0,0)
                vLbl.Size = UDim2.new(0.52,0,1,0)
                vLbl.Font = Enum.Font.GothamMedium
                vLbl.Text = tostring(pair.value or "")
                vLbl.TextColor3 = t.PrimaryText
                vLbl.TextSize = mobile and 15 or 14
                vLbl.TextXAlignment = Enum.TextXAlignment.Right
                vLbl.TextTruncate = Enum.TextTruncate.AtEnd

                if i < #lines then
                    local sep = Instance.new("Frame")
                    sep.Parent = lineRow
                    sep.BackgroundColor3 = t.Separator
                    sep.AnchorPoint = Vector2.new(0,1)
                    sep.Position = UDim2.new(0,14,1,0)
                    sep.Size = UDim2.new(1,-28,0,1)
                end
            end
        end

        -- ── sec:TextArea(name, default, callback) ──────────────────────────────
        function sec:TextArea(name2, default, callback)
            local areaH = mobile and 160 or 130
            local outer = Instance.new("Frame")
            outer.Parent = content
            outer.BackgroundColor3 = t.ButtonBg
            outer.BackgroundTransparency = 0.55
            outer.Size = UDim2.new(1,0,0,areaH)
            _makeCorner(outer, mobile and 14 or 10)
            _makeStroke(outer, t.Separator, 1, 0.5)

            local hdr = Instance.new("TextLabel")
            hdr.Parent = outer
            hdr.BackgroundTransparency = 1
            hdr.Position = UDim2.new(0,12,0,6)
            hdr.Size = UDim2.new(1,-24,0, mobile and 24 or 20)
            hdr.Font = Enum.Font.GothamMedium
            hdr.Text = name2 or "Text Area"
            hdr.TextColor3 = t.SecondaryText
            hdr.TextSize = mobile and 13 or 12
            hdr.TextXAlignment = Enum.TextXAlignment.Left

            local inputBg = Instance.new("Frame")
            inputBg.Parent = outer
            inputBg.BackgroundColor3 = t.InputBg
            inputBg.Position = UDim2.new(0,10,0, mobile and 32 or 28)
            inputBg.Size = UDim2.new(1,-20,1, mobile and -40 or -36)
            _makeCorner(inputBg, 8)
            _makeStroke(inputBg, t.Separator, 1, 0.3)

            local tb = Instance.new("TextBox")
            tb.Parent = inputBg
            tb.BackgroundTransparency = 1
            tb.Position = UDim2.new(0,8,0,6)
            tb.Size = UDim2.new(1,-16,1,-12)
            tb.ClearTextOnFocus = false
            tb.MultiLine = true
            tb.Font = Enum.Font.Code
            tb.PlaceholderText = "Enter text..."
            tb.PlaceholderColor3 = t.PlaceholderText
            tb.Text = default or ""
            tb.TextColor3 = t.PrimaryText
            tb.TextSize = mobile and 15 or 13
            tb.TextXAlignment = Enum.TextXAlignment.Left
            tb.TextYAlignment = Enum.TextYAlignment.Top

            tb.Focused:Connect(function() _makeStroke(inputBg, t.Accent, 1.5) end)
            tb.FocusLost:Connect(function()
                _makeStroke(inputBg, t.Separator, 1, 0.3)
                if callback then coroutine.wrap(function() callback(tb.Text) end)() end
            end)

            local obj = {}
            function obj:Set(tx) tb.Text = tostring(tx) end
            function obj:Get() return tb.Text end
            return obj
        end

        -- ── sec:RichTextLabel(text) ────────────────────────────────────────────
        function sec:RichTextLabel(text)
            local lbl = Instance.new("TextLabel")
            lbl.Parent = content
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1,0,0, mobile and 44 or 36)
            lbl.Font = Enum.Font.Gotham
            lbl.RichText = true
            lbl.Text = text or ""
            lbl.TextColor3 = t.PrimaryText
            lbl.TextSize = mobile and 16 or 15
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Top
            local obj = {}
            function obj:Set(tx) lbl.Text = tostring(tx) end
            return obj
        end

        -- ── sec:Image(assetId, height) ─────────────────────────────────────────
        function sec:Image(assetId, height)
            height = height or (mobile and 150 or 120)
            local f = Instance.new("Frame")
            f.Parent = content
            f.BackgroundTransparency = 1
            f.Size = UDim2.new(1,0,0,height)
            local img = Instance.new("ImageLabel")
            img.Parent = f
            img.BackgroundTransparency = 1
            img.AnchorPoint = Vector2.new(0.5,0.5)
            img.Position = UDim2.new(0.5,0,0.5,0)
            img.Size = UDim2.new(1,-24,1,-10)
            img.Image = assetId or ""
            img.ScaleType = Enum.ScaleType.Fit
            _makeCorner(img, 10)
            local obj = {}
            function obj:SetImage(id) img.Image = id end
            return obj
        end

        -- ── sec:Spacer(height) ────────────────────────────────────────────────
        function sec:Spacer(height)
            local sp = Instance.new("Frame")
            sp.Parent = content
            sp.BackgroundTransparency = 1
            sp.Size = UDim2.new(1,0,0, height or (mobile and 20 or 16))
        end

        -- ── sec:Separator() ───────────────────────────────────────────────────
        function sec:Separator()
            local line = Instance.new("Frame")
            line.Parent = content
            line.BackgroundColor3 = t.Separator
            line.BorderSizePixel = 0
            line.Size = UDim2.new(1,0,0, mobile and 2 or 1)
        end

        return sec
    end -- window:Section

    table.insert(_windows, window)
    return window
end -- lib:init

-- ─────────────────────────────────────────────────────────────────────────────
-- GLOBAL UTILITIES
-- ─────────────────────────────────────────────────────────────────────────────

function lib:DestroyAll()
    _disconnectAll()
    for _, gui in ipairs(_getGui():GetChildren()) do
        if gui.Name == "AppleLibV1" or gui.Name == "AppleLibToasts" then
            gui:Destroy()
        end
    end
    _windows = {}
end

function lib:GetVersion()  return lib.Version end
function lib:GetAuthor()   return lib.Author  end
function lib:IsMobile()    return IS_MOBILE   end
-- ─────────────────────────────────────────────────────────────────────────────
return lib
