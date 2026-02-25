--[[
    VelxHub Premium Universal Script UI v1.4
    UPDATE v1.4:
    - Toggle key: no delay, instant response
    - TP Dropdown: ScrollingFrame, bisa scroll banyak player
    - Freecam: dipindah ke section CAMERA, urutan lebih logis
]]

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- State
local States = {
    NoClip = false,
    Fly = false,
    ESP = false,
    God = false,
    InfJump = false,
    Speed = false,
    Fullbright = false,
    Freecam = false,
    AntiAFK = true,
    Spectating = false,
}
local freecamPos = nil
local spectateTarget = nil
local FlySpeed = 50
local WalkSpeedVal = 16
local JumpPowerVal = 50
local Connections = {}
local flyBody = {}
local currentToggleKey = Enum.KeyCode.LeftControl
local isBindingKey = false

-- ═══════════════════════════════════════
-- UI LIBRARY
-- ═══════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VelxHub Premium Universal Script"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if get_hidden_gui or gethui then
        ScreenGui.Parent = (get_hidden_gui or gethui)()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

-- Colors
local C = {
    bg = Color3.fromRGB(18, 18, 24),
    sidebar = Color3.fromRGB(22, 22, 30),
    card = Color3.fromRGB(28, 28, 38),
    accent = Color3.fromRGB(99, 102, 241),
    accentHover = Color3.fromRGB(129, 132, 255),
    green = Color3.fromRGB(34, 197, 94),
    red = Color3.fromRGB(239, 68, 68),
    orange = Color3.fromRGB(251, 146, 60),
    text = Color3.fromRGB(240, 240, 245),
    textDim = Color3.fromRGB(140, 140, 160),
    border = Color3.fromRGB(45, 45, 60),
    toggleOff = Color3.fromRGB(55, 55, 70),
}

local function tween(obj, props, dur)
    TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function addCorner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function addStroke(obj, col, t)
    local s = Instance.new("UIStroke", obj)
    s.Color = col or C.border
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

-- ═══════════════════════════════════════
-- MAIN FRAME
-- ═══════════════════════════════════════
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 380)
Main.Position = UDim2.new(0.5, -260, 0.5, -190)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = false
addCorner(Main, 12)
addStroke(Main, C.border, 1)

-- Shadow
local Shadow = Instance.new("ImageLabel", Main)
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = 0
Shadow.ImageTransparency = 0.6
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)

-- ═══════════════════════════════════════
-- TITLE BAR
-- ═══════════════════════════════════════
local TitleBar = Instance.new("Frame", Main)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = C.sidebar
TitleBar.BorderSizePixel = 0
addCorner(TitleBar, 12)

-- Draggable
do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Fix bottom corners of title bar
local TitleFix = Instance.new("Frame", TitleBar)
TitleFix.Size = UDim2.new(1, 0, 0, 14)
TitleFix.Position = UDim2.new(0, 0, 1, -14)
TitleFix.BackgroundColor3 = C.sidebar
TitleFix.BorderSizePixel = 0

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 14, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = ">> VelxHub Premium Universal Script v1.5 "
TitleText.TextColor3 = C.text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Close + Minimize
local function titleBtn(text, pos, color)
    local b = Instance.new("TextButton", TitleBar)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = pos
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.8
    b.Text = text
    b.TextColor3 = C.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    addCorner(b, 6)
    b.MouseEnter:Connect(function() tween(b, {BackgroundTransparency = 0.4}, 0.15) end)
    b.MouseLeave:Connect(function() tween(b, {BackgroundTransparency = 0.8}, 0.15) end)
    return b
end

local CloseBtn = titleBtn("X", UDim2.new(1, -38, 0, 4), C.red)
local MinBtn = titleBtn("—", UDim2.new(1, -70, 0, 4), C.orange)

local minimized = false
local pcModeEnabled = false   -- PC Mode: disembunyikan MiniBtn saat minimize

-- Mini button (small square when minimized)
local MiniBtn = Instance.new("TextButton", ScreenGui)
MiniBtn.Name = "MiniBtn"
MiniBtn.Size = UDim2.new(0, 42, 0, 42)
MiniBtn.Position = UDim2.new(0, 10, 0.5, -21)
MiniBtn.BackgroundColor3 = C.accent
MiniBtn.BorderSizePixel = 0
MiniBtn.Text = "P"
MiniBtn.TextColor3 = C.text
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 18
MiniBtn.Visible = false
MiniBtn.ZIndex = 99
addCorner(MiniBtn, 10)
addStroke(MiniBtn, C.border, 1)

-- ═══════════════════════════════════════
-- FIX: MiniBtn click vs drag detection
-- Pakai flag isDragging yg baru set true kalau gerak > threshold
-- InputEnded global tapi cek flag mbDragging biar ga ketuker
-- ═══════════════════════════════════════
do
    local mbDown = false        -- apakah mouse ditekan di atas MiniBtn
    local mbDragging = false    -- apakah sedang di-drag (bukan klik)
    local mbStart = nil
    local mbStartPos = nil
    local DRAG_THRESHOLD = 6    -- pixel minimum buat dianggap drag

    MiniBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            mbDown = true
            mbDragging = false
            mbStart = input.Position
            mbStartPos = MiniBtn.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if mbDown and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mbStart
            if delta.Magnitude > DRAG_THRESHOLD then
                mbDragging = true
            end
            if mbDragging then
                MiniBtn.Position = UDim2.new(
                    mbStartPos.X.Scale, mbStartPos.X.Offset + delta.X,
                    mbStartPos.Y.Scale, mbStartPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if mbDown and not mbDragging then
                -- Klik P = toggle menu (P tetap visible)
                if Main.Visible then
                    Main.Visible = false
                else
                    minimized = false
                    Main.Size = UDim2.new(0, 520, 0, 380)
                    Main.BackgroundTransparency = 0
                    Main.Visible = true
                end
            end
            mbDown = false
            mbDragging = false
        end
    end)
end

-- Mini button hover glow
MiniBtn.MouseEnter:Connect(function() tween(MiniBtn, {BackgroundColor3 = C.accentHover}, 0.15) end)
MiniBtn.MouseLeave:Connect(function() tween(MiniBtn, {BackgroundColor3 = C.accent}, 0.15) end)

-- ── Close Confirmation Dialog ──
local ConfirmOverlay = Instance.new("Frame", ScreenGui)
ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
ConfirmOverlay.Position = UDim2.new(0, 0, 0, 0)
ConfirmOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
ConfirmOverlay.BackgroundTransparency = 0.5
ConfirmOverlay.BorderSizePixel = 0
ConfirmOverlay.Visible = false
ConfirmOverlay.ZIndex = 100

local ConfirmBox = Instance.new("Frame", ConfirmOverlay)
ConfirmBox.Size = UDim2.new(0, 280, 0, 130)
ConfirmBox.Position = UDim2.new(0.5, -140, 0.5, -65)
ConfirmBox.BackgroundColor3 = C.card
ConfirmBox.BorderSizePixel = 0
ConfirmBox.ZIndex = 101
addCorner(ConfirmBox, 12)
addStroke(ConfirmBox, C.accent, 1.5)

local ConfirmTitle = Instance.new("TextLabel", ConfirmBox)
ConfirmTitle.Size = UDim2.new(1, 0, 0, 30)
ConfirmTitle.Position = UDim2.new(0, 0, 0, 16)
ConfirmTitle.BackgroundTransparency = 1
ConfirmTitle.Text = "Yakin mau keluar?"
ConfirmTitle.TextColor3 = C.text
ConfirmTitle.Font = Enum.Font.GothamBold
ConfirmTitle.TextSize = 16
ConfirmTitle.ZIndex = 102

local ConfirmSub = Instance.new("TextLabel", ConfirmBox)
ConfirmSub.Size = UDim2.new(1, 0, 0, 18)
ConfirmSub.Position = UDim2.new(0, 0, 0, 44)
ConfirmSub.BackgroundTransparency = 1
ConfirmSub.Text = "Script akan dihapus sepenuhnya."
ConfirmSub.TextColor3 = C.textDim
ConfirmSub.Font = Enum.Font.GothamMedium
ConfirmSub.TextSize = 11
ConfirmSub.ZIndex = 102

local ConfirmYes = Instance.new("TextButton", ConfirmBox)
ConfirmYes.Size = UDim2.new(0, 110, 0, 34)
ConfirmYes.Position = UDim2.new(0, 20, 1, -48)
ConfirmYes.BackgroundColor3 = C.red
ConfirmYes.BorderSizePixel = 0
ConfirmYes.Text = "Ya, Keluar"
ConfirmYes.TextColor3 = Color3.new(1, 1, 1)
ConfirmYes.Font = Enum.Font.GothamBold
ConfirmYes.TextSize = 13
ConfirmYes.ZIndex = 102
addCorner(ConfirmYes, 8)
ConfirmYes.MouseEnter:Connect(function() tween(ConfirmYes, {BackgroundTransparency = 0.2}, 0.1) end)
ConfirmYes.MouseLeave:Connect(function() tween(ConfirmYes, {BackgroundTransparency = 0}, 0.1) end)

local ConfirmNo = Instance.new("TextButton", ConfirmBox)
ConfirmNo.Size = UDim2.new(0, 110, 0, 34)
ConfirmNo.Position = UDim2.new(1, -130, 1, -48)
ConfirmNo.BackgroundColor3 = C.card
ConfirmNo.BorderSizePixel = 0
ConfirmNo.Text = "Batal"
ConfirmNo.TextColor3 = C.text
ConfirmNo.Font = Enum.Font.GothamBold
ConfirmNo.TextSize = 13
ConfirmNo.ZIndex = 102
addCorner(ConfirmNo, 8)
addStroke(ConfirmNo, C.border, 1)
ConfirmNo.MouseEnter:Connect(function() tween(ConfirmNo, {BackgroundColor3 = C.accent}, 0.1) end)
ConfirmNo.MouseLeave:Connect(function() tween(ConfirmNo, {BackgroundColor3 = C.card}, 0.1) end)

CloseBtn.MouseButton1Click:Connect(function()
    ConfirmOverlay.Visible = true
end)

ConfirmYes.MouseButton1Click:Connect(function()
    ConfirmOverlay.Visible = false
    tween(Main, {Size = UDim2.new(0, 520, 0, 0)}, 0.3)
    task.wait(0.3)
    ScreenGui:Destroy()
    for _, c in Connections do if c.Disconnect then c:Disconnect() end end
end)

ConfirmNo.MouseButton1Click:Connect(function()
    ConfirmOverlay.Visible = false
end)

MinBtn.MouseButton1Click:Connect(function()
    minimized = true
    tween(Main, {Size = UDim2.new(0, 40, 0, 40), BackgroundTransparency = 0.5}, 0.3)
    task.wait(0.3)
    Main.Visible = false
    -- MiniBtn tetap di posisinya, tidak dipindah
    if not pcModeEnabled then
        MiniBtn.Visible = true
    else
        notify("Minimized", "Tekan " .. tostring(currentToggleKey.Name) .. " / Insert untuk buka kembali")
    end
end)

-- ═══════════════════════════════════════
-- SIDEBAR (Tabs)
-- ═══════════════════════════════════════
local Sidebar = Instance.new("Frame", Main)
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 110, 1, -36)
Sidebar.Position = UDim2.new(0, 0, 0, 36)
Sidebar.BackgroundColor3 = C.sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2

local SBLine = Instance.new("Frame", Main)
SBLine.Name = "SidebarLine"
SBLine.Size = UDim2.new(0, 1, 1, -36)
SBLine.Position = UDim2.new(0, 110, 0, 36)
SBLine.BackgroundColor3 = C.border
SBLine.BorderSizePixel = 0
SBLine.ZIndex = 3

local TabLayout = Instance.new("UIListLayout", Sidebar)
TabLayout.Padding = UDim.new(0, 4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local TabPad = Instance.new("UIPadding", Sidebar)
TabPad.PaddingTop = UDim.new(0, 8)
TabPad.PaddingLeft = UDim.new(0, 6)
TabPad.PaddingRight = UDim.new(0, 6)

-- Content area
local ContentArea = Instance.new("Frame", Main)
ContentArea.Name = "Content"
ContentArea.Size = UDim2.new(1, -110, 1, -36)
ContentArea.Position = UDim2.new(0, 110, 0, 36)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0

-- Tab system
local Pages = {}
local TabButtons = {}
local ActiveTab = nil

local function createPage(name)
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)

    Pages[name] = page
    return page
end

local function createTab(icon, name, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = C.accent
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = C.textDim
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    addCorner(btn, 6)

    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 8)

    btn.MouseEnter:Connect(function()
        if ActiveTab ~= name then tween(btn, {BackgroundTransparency = 0.85}, 0.15) end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= name then tween(btn, {BackgroundTransparency = 1}, 0.15) end
    end)

    btn.MouseButton1Click:Connect(function()
        for n, p in Pages do p.Visible = false end
        for n, b in TabButtons do
            tween(b, {BackgroundTransparency = 1, TextColor3 = C.textDim}, 0.2)
        end
        Pages[name].Visible = true
        tween(btn, {BackgroundTransparency = 0.7, TextColor3 = C.text}, 0.2)
        ActiveTab = name
    end)

    TabButtons[name] = btn
    createPage(name)
    return btn
end

-- ═══════════════════════════════════════
-- UI COMPONENTS
-- ═══════════════════════════════════════
local function addToggle(parent, label, default, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 36)
    holder.BackgroundColor3 = C.card
    holder.BorderSizePixel = 0
    addCorner(holder, 8)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local togBg = Instance.new("Frame", holder)
    togBg.Size = UDim2.new(0, 40, 0, 20)
    togBg.Position = UDim2.new(1, -52, 0.5, -10)
    togBg.BackgroundColor3 = default and C.accent or C.toggleOff
    togBg.BorderSizePixel = 0
    addCorner(togBg, 10)

    local circle = Instance.new("Frame", togBg)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    circle.BackgroundColor3 = C.text
    circle.BorderSizePixel = 0
    addCorner(circle, 8)

    local state = default or false
    local btn = Instance.new("TextButton", holder)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 5

    btn.MouseButton1Click:Connect(function()
        state = not state
        tween(togBg, {BackgroundColor3 = state and C.accent or C.toggleOff}, 0.2)
        tween(circle, {Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2)
        if callback then callback(state) end
    end)

    local function setState(newState)
        if state == newState then return end
        state = newState
        tween(togBg, {BackgroundColor3 = state and C.accent or C.toggleOff}, 0.2)
        tween(circle, {Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2)
    end

    return holder, setState
end

local function addButton(parent, label, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C.card
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    addCorner(btn, 8)

    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = C.accent}, 0.15) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = C.card}, 0.15) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

-- Global slider state
local activeSliderUpdate = nil

UIS.InputChanged:Connect(function(input)
    if activeSliderUpdate and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        activeSliderUpdate(input)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        activeSliderUpdate = nil
    end
end)

local function addSlider(parent, label, min, max, default, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 50)
    holder.BackgroundColor3 = C.card
    holder.BorderSizePixel = 0
    addCorner(holder, 8)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -60, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", holder)
    valLabel.Size = UDim2.new(0, 50, 0, 20)
    valLabel.Position = UDim2.new(1, -60, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = C.accent
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 12

    local track = Instance.new("Frame", holder)
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 32)
    track.BackgroundColor3 = C.toggleOff
    track.BorderSizePixel = 0
    addCorner(track, 3)

    local fill = Instance.new("Frame", track)
    local pct = (default - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    addCorner(fill, 3)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(pct, -7, 0.5, -7)
    knob.BackgroundColor3 = C.text
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    addCorner(knob, 7)

    local sliderBtn = Instance.new("TextButton", track)
    sliderBtn.Size = UDim2.new(1, 0, 0, 20)
    sliderBtn.Position = UDim2.new(0, 0, 0, -7)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 4

    local function update(input)
        local abs = track.AbsolutePosition.X
        local w = track.AbsoluteSize.X
        local rel = math.clamp((input.Position.X - abs) / w, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        valLabel.Text = tostring(val)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        if callback then callback(val) end
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeSliderUpdate = update
            update(input)
        end
    end)

    return holder
end

local function addLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local function addInput(parent, placeholder, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 36)
    holder.BackgroundColor3 = C.card
    holder.BorderSizePixel = 0
    addCorner(holder, 8)

    local box = Instance.new("TextBox", holder)
    box.Size = UDim2.new(1, -80, 1, 0)
    box.Position = UDim2.new(0, 12, 0, 0)
    box.BackgroundTransparency = 1
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = C.textDim
    box.Text = ""
    box.TextColor3 = C.text
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 13
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ClearTextOnFocus = false

    local go = Instance.new("TextButton", holder)
    go.Size = UDim2.new(0, 55, 0, 26)
    go.Position = UDim2.new(1, -65, 0.5, -13)
    go.BackgroundColor3 = C.accent
    go.BorderSizePixel = 0
    go.Text = "GO"
    go.TextColor3 = C.text
    go.Font = Enum.Font.GothamBold
    go.TextSize = 12
    addCorner(go, 6)

    go.MouseButton1Click:Connect(function()
        if callback then callback(box.Text) end
    end)
    box.FocusLost:Connect(function(enter)
        if enter and callback then callback(box.Text) end
    end)

    return holder, box
end

-- ═══════════════════════════════════════
-- CREATE TABS
-- ═══════════════════════════════════════
createTab("[P]", "Player", 1)
createTab("[T]", "Teleport", 2)
createTab("[M]", "Movement", 3)
createTab("[V]", "Visual", 4)
createTab("[D]", "Dance", 5)
createTab("[F]", "Farm", 6)
createTab("[X]", "Misc", 7)

-- Default tab
TabButtons["Player"].BackgroundTransparency = 0.7
TabButtons["Player"].TextColor3 = C.text
Pages["Player"].Visible = true
ActiveTab = "Player"

-- ═══════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════
local function getChar()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3,
        })
    end)
end

-- ═══════════════════════════════════════
-- PLAYER TAB
-- ═══════════════════════════════════════
local pPage = Pages["Player"]

addLabel(pPage, "-- CHARACTER")

addSlider(pPage, "WalkSpeed", 0, 500, 16, function(v)
    WalkSpeedVal = v
    local h = getHum()
    if h then h.WalkSpeed = v end
end)

addSlider(pPage, "JumpPower", 0, 500, 50, function(v)
    JumpPowerVal = v
    local h = getHum()
    if h then
        h.UseJumpPower = true
        h.JumpPower = v
    end
end)

addToggle(pPage, "God Mode", false, function(on)
    States.God = on
    local h = getHum()
    if h then
        if on then
            h.MaxHealth = math.huge
            h.Health = math.huge
        else
            h.MaxHealth = 100
            h.Health = 100
        end
    end
end)

addToggle(pPage, "Infinite Jump", false, function(on)
    States.InfJump = on
end)

addLabel(pPage, "-- ACTIONS")

addButton(pPage, "[*] Reset Character", function()
    local h = getHum()
    if h then h.Health = 0 end
end)

addButton(pPage, "[*] Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
end)

addButton(pPage, "[*] Server Hop", function()
    local servers = game:GetService("HttpService"):JSONDecode(
        game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    )
    if servers and servers.data then
        for _, s in servers.data do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, Player)
                break
            end
        end
    end
end)

-- ═══════════════════════════════════════
-- TELEPORT TAB
-- ═══════════════════════════════════════
local tPage = Pages["Teleport"]

-- ── TELEPORT TO PLAYER: Select-style ──
addLabel(tPage, "-- TELEPORT TO PLAYER")

-- State
local tpSelectedPlayer = nil

-- ── "Select Player to Teleport" card ──
local tpSelectCard = Instance.new("Frame", tPage)
tpSelectCard.Size = UDim2.new(1, 0, 0, 44)
tpSelectCard.BackgroundColor3 = C.card
tpSelectCard.BorderSizePixel = 0
addCorner(tpSelectCard, 8)
addStroke(tpSelectCard, C.border, 1)

local tpSelectIcon = Instance.new("TextLabel", tpSelectCard)
tpSelectIcon.Size = UDim2.new(0, 28, 1, 0)
tpSelectIcon.Position = UDim2.new(0, 10, 0, 0)
tpSelectIcon.BackgroundTransparency = 1
tpSelectIcon.Text = "👤"
tpSelectIcon.TextSize = 16
tpSelectIcon.Font = Enum.Font.GothamBold
tpSelectIcon.TextColor3 = C.textDim

local tpSelectTop = Instance.new("TextLabel", tpSelectCard)
tpSelectTop.Size = UDim2.new(1, -50, 0, 16)
tpSelectTop.Position = UDim2.new(0, 38, 0, 6)
tpSelectTop.BackgroundTransparency = 1
tpSelectTop.Text = "Select Player to Teleport"
tpSelectTop.TextColor3 = C.textDim
tpSelectTop.Font = Enum.Font.GothamMedium
tpSelectTop.TextSize = 10
tpSelectTop.TextXAlignment = Enum.TextXAlignment.Left

local tpSelectName = Instance.new("TextLabel", tpSelectCard)
tpSelectName.Size = UDim2.new(1, -50, 0, 18)
tpSelectName.Position = UDim2.new(0, 38, 0, 20)
tpSelectName.BackgroundTransparency = 1
tpSelectName.Text = "— (none selected)"
tpSelectName.TextColor3 = C.text
tpSelectName.Font = Enum.Font.GothamBold
tpSelectName.TextSize = 13
tpSelectName.TextXAlignment = Enum.TextXAlignment.Left
tpSelectName.TextTruncate = Enum.TextTruncate.AtEnd

-- Chevron kanan
local tpSelectChev = Instance.new("TextLabel", tpSelectCard)
tpSelectChev.Size = UDim2.new(0, 24, 1, 0)
tpSelectChev.Position = UDim2.new(1, -30, 0, 0)
tpSelectChev.BackgroundTransparency = 1
tpSelectChev.Text = "▼"
tpSelectChev.TextColor3 = C.textDim
tpSelectChev.Font = Enum.Font.GothamBold
tpSelectChev.TextSize = 11

-- ── Dropdown list: ScrollingFrame supaya bisa di-scroll ──
local tpDropdown = Instance.new("ScrollingFrame", tPage)
tpDropdown.Size = UDim2.new(1, 0, 0, 0)
tpDropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
tpDropdown.BorderSizePixel = 0
tpDropdown.ClipsDescendants = true
tpDropdown.Visible = false
tpDropdown.ScrollBarThickness = 3
tpDropdown.ScrollBarImageColor3 = C.accent
tpDropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
tpDropdown.AutomaticCanvasSize = Enum.AutomaticSize.Y
tpDropdown.ScrollingDirection = Enum.ScrollingDirection.Y
addCorner(tpDropdown, 8)
addStroke(tpDropdown, C.accent, 1)

local tpDropLayout = Instance.new("UIListLayout", tpDropdown)
tpDropLayout.Padding = UDim.new(0, 2)
local tpDropPad = Instance.new("UIPadding", tpDropdown)
tpDropPad.PaddingTop = UDim.new(0, 4)
tpDropPad.PaddingBottom = UDim.new(0, 4)
tpDropPad.PaddingLeft = UDim.new(0, 4)
tpDropPad.PaddingRight = UDim.new(0, 4)

local TP_DROP_MAX_H = 200  -- max tinggi dropdown sebelum scroll aktif

local tpDropOpen = false
local tpSearchQuery = ""  -- search filter

local function closeTpDropdown()
    tpDropOpen = false
    tpSearchQuery = ""
    tween(tpDropdown, {Size = UDim2.new(1, 0, 0, 0)}, 0.18)
    tween(tpSelectChev, {Rotation = 0}, 0.18)
    task.delay(0.2, function() if not tpDropOpen then tpDropdown.Visible = false end end)
end

local function buildTpDropdown(filter)
    for _, c in tpDropdown:GetChildren() do
        if c:IsA("TextButton") or c:IsA("Frame") or c:IsA("TextBox") then c:Destroy() end
    end

    -- Search box
    local searchBox = Instance.new("TextBox", tpDropdown)
    searchBox.Name = "TpSearchBox"
    searchBox.Size = UDim2.new(1, 0, 0, 32)
    searchBox.BackgroundColor3 = C.card
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "🔍 Search player..."
    searchBox.PlaceholderColor3 = C.textDim
    searchBox.Text = filter or ""
    searchBox.TextColor3 = C.text
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.TextSize = 12
    searchBox.ClearTextOnFocus = false
    addCorner(searchBox, 6)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        tpSearchQuery = searchBox.Text
        buildTpDropdown(searchBox.Text)
        tpDropdown.Visible = true
        -- Resize
        local totalItems = 1 -- search box
        for _, c in tpDropdown:GetChildren() do
            if (c:IsA("TextButton") or c:IsA("TextLabel")) then totalItems = totalItems + 1 end
        end
        local totalH = totalItems * 52 + 48
        local dropH = math.min(totalH, TP_DROP_MAX_H)
        tpDropdown.Size = UDim2.new(1, 0, 0, dropH)
    end)

    local others = {}
    local query = (filter or ""):lower()
    for _, p in Players:GetPlayers() do
        if p ~= Player then
            if query == "" or p.Name:lower():find(query, 1, true) or p.DisplayName:lower():find(query, 1, true) then
                table.insert(others, p)
            end
        end
    end

    if #others == 0 then
        local noLbl = Instance.new("TextLabel", tpDropdown)
        noLbl.Size = UDim2.new(1, 0, 0, 30)
        noLbl.BackgroundTransparency = 1
        noLbl.Text = query ~= "" and "Player tidak ditemukan" or "No other players"
        noLbl.TextColor3 = C.textDim
        noLbl.Font = Enum.Font.GothamMedium
        noLbl.TextSize = 11
    else
        for _, p in ipairs(others) do
            local row = Instance.new("TextButton", tpDropdown)
            row.Size = UDim2.new(1, 0, 0, 48)
            row.BackgroundColor3 = C.card
            row.BackgroundTransparency = 0.3
            row.BorderSizePixel = 0
            row.Text = ""
            addCorner(row, 6)

            -- Avatar circle
            local avatar = Instance.new("Frame", row)
            avatar.Size = UDim2.new(0, 30, 0, 30)
            avatar.Position = UDim2.new(0, 8, 0.5, -15)
            avatar.BackgroundColor3 = Color3.fromHSV((p.UserId % 360) / 360, 0.55, 0.75)
            avatar.BorderSizePixel = 0
            addCorner(avatar, 7)
            local avatarLetter = Instance.new("TextLabel", avatar)
            avatarLetter.Size = UDim2.new(1, 0, 1, 0)
            avatarLetter.BackgroundTransparency = 1
            avatarLetter.Text = string.upper(string.sub(p.Name, 1, 1))
            avatarLetter.TextColor3 = Color3.new(1,1,1)
            avatarLetter.Font = Enum.Font.GothamBold
            avatarLetter.TextSize = 14

            -- Nama display
            local rowName = Instance.new("TextLabel", row)
            rowName.Size = UDim2.new(1, -50, 0, 22)
            rowName.Position = UDim2.new(0, 46, 0, 6)
            rowName.BackgroundTransparency = 1
            rowName.Text = p.DisplayName
            rowName.TextColor3 = C.text
            rowName.Font = Enum.Font.GothamBold
            rowName.TextSize = 15
            rowName.TextXAlignment = Enum.TextXAlignment.Left
            rowName.TextTruncate = Enum.TextTruncate.AtEnd

            -- Username
            local rowUser = Instance.new("TextLabel", row)
            rowUser.Size = UDim2.new(1, -50, 0, 16)
            rowUser.Position = UDim2.new(0, 46, 0, 27)
            rowUser.BackgroundTransparency = 1
            rowUser.Text = "@" .. p.Name
            rowUser.TextColor3 = C.textDim
            rowUser.Font = Enum.Font.GothamMedium
            rowUser.TextSize = 12
            rowUser.TextXAlignment = Enum.TextXAlignment.Left

            row.MouseEnter:Connect(function() tween(row, {BackgroundTransparency = 0}, 0.1) end)
            row.MouseLeave:Connect(function() tween(row, {BackgroundTransparency = 0.3}, 0.1) end)

            row.MouseButton1Click:Connect(function()
                tpSelectedPlayer = p
                tpSelectName.Text = p.DisplayName .. "  (@" .. p.Name .. ")"
                tpSelectIcon.Text = "✅"
                tween(tpSelectCard, {BackgroundColor3 = Color3.fromRGB(30, 35, 48)}, 0.2)
                closeTpDropdown()
            end)
        end
    end

    -- Hitung tinggi dropdown: search box (36) + player rows + padding
    local totalH = 36 + (#others == 0 and 1 or #others) * 52 + 12
    local dropH = math.min(totalH, TP_DROP_MAX_H)
    return dropH
end

-- Toggle dropdown saat card diklik
local tpSelectClickBtn = Instance.new("TextButton", tpSelectCard)
tpSelectClickBtn.Size = UDim2.new(1, 0, 1, 0)
tpSelectClickBtn.BackgroundTransparency = 1
tpSelectClickBtn.Text = ""
tpSelectClickBtn.ZIndex = 5

tpSelectClickBtn.MouseButton1Click:Connect(function()
    if tpDropOpen then
        closeTpDropdown()
    else
        tpDropOpen = true
        tpDropdown.Visible = true
        local dropH = buildTpDropdown()
        tween(tpDropdown, {Size = UDim2.new(1, 0, 0, dropH)}, 0.2)
        tween(tpSelectChev, {Rotation = 180}, 0.18)
    end
end)

-- ── "Teleport to Player" action button ──
local tpActionBtn = Instance.new("TextButton", tPage)
tpActionBtn.Size = UDim2.new(1, 0, 0, 38)
tpActionBtn.BackgroundColor3 = C.accent
tpActionBtn.BackgroundTransparency = 0.2
tpActionBtn.BorderSizePixel = 0
tpActionBtn.Text = "▶  Teleport to Player"
tpActionBtn.TextColor3 = C.text
tpActionBtn.Font = Enum.Font.GothamBold
tpActionBtn.TextSize = 13
addCorner(tpActionBtn, 8)

tpActionBtn.MouseEnter:Connect(function() tween(tpActionBtn, {BackgroundTransparency = 0}, 0.15) end)
tpActionBtn.MouseLeave:Connect(function() tween(tpActionBtn, {BackgroundTransparency = 0.2}, 0.15) end)

tpActionBtn.MouseButton1Click:Connect(function()
    if not tpSelectedPlayer then
        notify("Teleport", "Pilih player dulu dari dropdown!")
        tween(tpSelectCard, {BackgroundColor3 = C.red}, 0.1)
        task.delay(0.3, function() tween(tpSelectCard, {BackgroundColor3 = C.card}, 0.3) end)
        return
    end
    local hrp = getHRP()
    local t = tpSelectedPlayer.Character and tpSelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and t then
        hrp.CFrame = t.CFrame * CFrame.new(0, 0, 3)
        tween(tpActionBtn, {BackgroundColor3 = C.green}, 0.1)
        task.delay(0.4, function() tween(tpActionBtn, {BackgroundColor3 = C.accent}, 0.3) end)
        notify("Teleported", "→ " .. tpSelectedPlayer.DisplayName)
    else
        notify("Error", tpSelectedPlayer.DisplayName .. " tidak ditemukan")
        tween(tpActionBtn, {BackgroundColor3 = C.red}, 0.1)
        task.delay(0.4, function() tween(tpActionBtn, {BackgroundColor3 = C.accent}, 0.3) end)
    end
end)

-- Auto Follow Player toggle
addToggle(tPage, "Auto Follow Player (selected)", false, function(on)
    if Connections.autoFollow then Connections.autoFollow:Disconnect() end
    if on then
        if not tpSelectedPlayer then notify("Auto Follow", "Pilih player dulu!") return end
        Connections.autoFollow = RunService.Heartbeat:Connect(function()
            if not tpSelectedPlayer then return end
            local hrp = getHRP()
            local t = tpSelectedPlayer.Character and tpSelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and t then
                local dist = (hrp.Position - t.Position).Magnitude
                if dist > 5 then
                    hrp.CFrame = t.CFrame * CFrame.new(0, 0, 3)
                end
            end
        end)
        notify("Auto Follow", "Following: " .. (tpSelectedPlayer and tpSelectedPlayer.DisplayName or "?"))
    else
        notify("Auto Follow", "Stopped")
    end
end)

addLabel(tPage, "-- TELEPORT TO POSITION")

addInput(tPage, "X, Y, Z (e.g. 100, 50, 200)", function(text)
    local coords = {}
    for n in text:gmatch("[%-]?%d+%.?%d*") do table.insert(coords, tonumber(n)) end
    if #coords >= 3 then
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = CFrame.new(coords[1], coords[2], coords[3])
            notify("Teleported", string.format("→ %.0f, %.0f, %.0f", coords[1], coords[2], coords[3]))
        end
    else
        notify("Error", "Use format: X, Y, Z")
    end
end)

addLabel(tPage, "-- QUICK TELEPORT")

addButton(tPage, "[^] TP to Highest Point", function()
    local hrp = getHRP()
    if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 500, 0) end
end)

addButton(tPage, "[H] TP to Spawn", function()
    local hrp = getHRP()
    local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildOfClass("SpawnLocation")
    if hrp and spawn then
        hrp.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
    elseif hrp then
        hrp.CFrame = CFrame.new(0, 50, 0)
    end
end)

-- ═══════════════════════════════════════
-- MOVEMENT TAB
-- ═══════════════════════════════════════
local mPage = Pages["Movement"]

addLabel(mPage, "-- MOVEMENT HACKS")

addToggle(mPage, "NoClip", false, function(on)
    States.NoClip = on
    if on then
        Connections.noclip = RunService.Stepped:Connect(function()
            local c = getChar()
            if c then
                for _, p in c:GetDescendants() do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        notify("NoClip", "Enabled ✅")
    else
        if Connections.noclip then Connections.noclip:Disconnect() end
        notify("NoClip", "Disabled ❌")
    end
end)

addToggle(mPage, "Fly", false, function(on)
    States.Fly = on
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end

    if on then
        local bg = Instance.new("BodyGyro", hrp)
        bg.Name = "FlyGyro"
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = hrp.CFrame

        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)

        flyBody.bg = bg
        flyBody.bv = bv

        Connections.fly = RunService.RenderStepped:Connect(function()
            if not States.Fly then return end
            local cam = Workspace.CurrentCamera
            bg.CFrame = cam.CFrame
            local dir = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            bv.Velocity = dir * FlySpeed
        end)
        notify("Fly", "Enabled ✅ (WASD + Space/Shift)")
    else
        if Connections.fly then Connections.fly:Disconnect() end
        if flyBody.bg then flyBody.bg:Destroy() end
        if flyBody.bv then flyBody.bv:Destroy() end
        notify("Fly", "Disabled ❌")
    end
end)

addSlider(mPage, "Fly Speed", 10, 500, 50, function(v) FlySpeed = v end)

UIS.JumpRequest:Connect(function()
    if States.InfJump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ═══════════════════════════════════════
-- VISUAL TAB
-- ═══════════════════════════════════════
local vPage = Pages["Visual"]

addLabel(vPage, "-- ESP & VISUALS")

addToggle(vPage, "Player ESP (Highlight)", false, function(on)
    States.ESP = on
    if on then
        local function addESP(p)
            if p == Player then return end
            local c = p.Character
            if not c then return end
            local existing = c:FindFirstChild("ESPHighlight")
            if existing then existing:Destroy() end
            local h = Instance.new("Highlight", c)
            h.Name = "ESPHighlight"
            h.FillColor = C.accent
            h.FillTransparency = 0.7
            h.OutlineColor = C.accent
            h.OutlineTransparency = 0.3
        end
        for _, p in Players:GetPlayers() do
            if p.Character then addESP(p) end
            p.CharacterAdded:Connect(function()
                task.wait(1)
                if States.ESP then addESP(p) end
            end)
        end
        Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                task.wait(1)
                if States.ESP then addESP(p) end
            end)
        end)
        notify("ESP", "Enabled ✅")
    else
        for _, p in Players:GetPlayers() do
            if p.Character then
                local h = p.Character:FindFirstChild("ESPHighlight")
                if h then h:Destroy() end
            end
        end
        notify("ESP", "Disabled ❌")
    end
end)

addToggle(vPage, "Fullbright", false, function(on)
    States.Fullbright = on
    local lighting = game:GetService("Lighting")
    if on then
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
        for _, v in lighting:GetChildren() do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
        end
        notify("Fullbright", "Enabled ✅")
    else
        lighting.GlobalShadows = true
        lighting.Brightness = 1
        for _, v in lighting:GetChildren() do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = true
            end
        end
        notify("Fullbright", "Disabled ❌")
    end
end)

addLabel(vPage, "-- CAMERA")

addSlider(vPage, "FOV", 30, 120, 70, function(v)
    Workspace.CurrentCamera.FieldOfView = v
end)

addButton(vPage, "Reset FOV", function()
    Workspace.CurrentCamera.FieldOfView = 70
end)

-- ═══════════════════════════════════════
-- FREECAM (masuk bagian CAMERA)
-- ═══════════════════════════════════════

-- ── Freecam HUD (floating panel pojok kanan bawah, muncul saat freecam ON) ──
local FreecamHUD = Instance.new("Frame", ScreenGui)
FreecamHUD.Name = "FreecamHUD"
FreecamHUD.Size = UDim2.new(0, 250, 0, 148)  -- +25%: 200→250, 118→148
FreecamHUD.Position = UDim2.new(1, -264, 1, -162)
FreecamHUD.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
FreecamHUD.BackgroundTransparency = 0.1
FreecamHUD.BorderSizePixel = 0
FreecamHUD.Visible = false
FreecamHUD.ZIndex = 60
addCorner(FreecamHUD, 14)
addStroke(FreecamHUD, C.accent, 1.5)

-- Draggable HUD
do
    local fDrag, fStart, fPos = false, nil, nil
    FreecamHUD.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            fDrag = true; fStart = inp.Position; fPos = FreecamHUD.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if fDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - fStart
            FreecamHUD.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then fDrag = false end
    end)
end

-- Header
local fcHudTitle = Instance.new("TextLabel", FreecamHUD)
fcHudTitle.Size = UDim2.new(1, -16, 0, 22)
fcHudTitle.Position = UDim2.new(0, 12, 0, 10)
fcHudTitle.BackgroundTransparency = 1
fcHudTitle.Text = "📷  FREECAM"
fcHudTitle.TextColor3 = C.accent
fcHudTitle.Font = Enum.Font.GothamBold
fcHudTitle.TextSize = 13
fcHudTitle.TextXAlignment = Enum.TextXAlignment.Left
fcHudTitle.ZIndex = 61

-- Speed label
local fcSpeedLabel = Instance.new("TextLabel", FreecamHUD)
fcSpeedLabel.Size = UDim2.new(0.5, 0, 0, 18)
fcSpeedLabel.Position = UDim2.new(0, 12, 0, 36)
fcSpeedLabel.BackgroundTransparency = 1
fcSpeedLabel.Text = "Speed"
fcSpeedLabel.TextColor3 = C.textDim
fcSpeedLabel.Font = Enum.Font.GothamMedium
fcSpeedLabel.TextSize = 12
fcSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
fcSpeedLabel.ZIndex = 61

-- Speed value display
local fcSpeedValue = Instance.new("TextLabel", FreecamHUD)
fcSpeedValue.Size = UDim2.new(0.5, -14, 0, 18)
fcSpeedValue.Position = UDim2.new(0.5, 0, 0, 36)
fcSpeedValue.BackgroundTransparency = 1
fcSpeedValue.Text = "1.00"
fcSpeedValue.TextColor3 = C.text
fcSpeedValue.Font = Enum.Font.GothamBold
fcSpeedValue.TextSize = 14
fcSpeedValue.TextXAlignment = Enum.TextXAlignment.Right
fcSpeedValue.ZIndex = 61

-- Speed bar track
local fcTrack = Instance.new("Frame", FreecamHUD)
fcTrack.Size = UDim2.new(1, -24, 0, 6)
fcTrack.Position = UDim2.new(0, 12, 0, 60)
fcTrack.BackgroundColor3 = C.toggleOff
fcTrack.BorderSizePixel = 0
fcTrack.ZIndex = 61
addCorner(fcTrack, 3)

local fcFill = Instance.new("Frame", fcTrack)
fcFill.Size = UDim2.new(0.05, 0, 1, 0)
fcFill.BackgroundColor3 = C.accent
fcFill.BorderSizePixel = 0
fcFill.ZIndex = 62
addCorner(fcFill, 3)

-- −/+ tombol speed
local function makeSpeedBtn(txt, xOff)
    local b = Instance.new("TextButton", FreecamHUD)
    b.Size = UDim2.new(0, 34, 0, 30)
    b.Position = UDim2.new(0, xOff, 0, 74)
    b.BackgroundColor3 = C.card
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = C.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.ZIndex = 62
    addCorner(b, 7)
    b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = C.accent}, 0.12) end)
    b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = C.card}, 0.12) end)
    return b
end

local fcMinusBtn = makeSpeedBtn("−", 12)
local fcPlusBtn  = makeSpeedBtn("+", 204)

-- Manual speed input box (di tengah antara − dan +)
local fcSpeedInputBg = Instance.new("Frame", FreecamHUD)
fcSpeedInputBg.Size = UDim2.new(1, -110, 0, 30)
fcSpeedInputBg.Position = UDim2.new(0, 52, 0, 74)
fcSpeedInputBg.BackgroundColor3 = C.card
fcSpeedInputBg.BorderSizePixel = 0
fcSpeedInputBg.ZIndex = 61
addCorner(fcSpeedInputBg, 7)
addStroke(fcSpeedInputBg, C.border, 1)

local fcSpeedInput = Instance.new("TextBox", fcSpeedInputBg)
fcSpeedInput.Size = UDim2.new(1, -10, 1, 0)
fcSpeedInput.Position = UDim2.new(0, 5, 0, 0)
fcSpeedInput.BackgroundTransparency = 1
fcSpeedInput.Text = "1.00"
fcSpeedInput.PlaceholderText = "speed"
fcSpeedInput.PlaceholderColor3 = C.textDim
fcSpeedInput.TextColor3 = C.text
fcSpeedInput.Font = Enum.Font.GothamBold
fcSpeedInput.TextSize = 14
fcSpeedInput.ClearTextOnFocus = false
fcSpeedInput.ZIndex = 62

-- Hint text
local fcHint = Instance.new("TextLabel", FreecamHUD)
fcHint.Size = UDim2.new(1, -24, 0, 14)
fcHint.Position = UDim2.new(0, 12, 0, 112)
fcHint.BackgroundTransparency = 1
fcHint.Text = "RMB=look · WASD/Space/Shift · Q/E speed"
fcHint.TextColor3 = C.textDim
fcHint.Font = Enum.Font.GothamMedium
fcHint.TextSize = 9
fcHint.TextXAlignment = Enum.TextXAlignment.Left
fcHint.ZIndex = 61

-- Stop button — "✕" besar, warna merah jelas
local fcStopBtn = Instance.new("TextButton", FreecamHUD)
fcStopBtn.Size = UDim2.new(1, -24, 0, 28)
fcStopBtn.Position = UDim2.new(0, 12, 1, -34)
fcStopBtn.BackgroundColor3 = C.red
fcStopBtn.BackgroundTransparency = 0.2
fcStopBtn.BorderSizePixel = 0
fcStopBtn.Text = "■   Stop Freecam"
fcStopBtn.TextColor3 = Color3.new(1, 1, 1)
fcStopBtn.Font = Enum.Font.GothamBold
fcStopBtn.TextSize = 13
fcStopBtn.ZIndex = 62
addCorner(fcStopBtn, 7)
fcStopBtn.MouseEnter:Connect(function() tween(fcStopBtn, {BackgroundTransparency = 0}, 0.12) end)
fcStopBtn.MouseLeave:Connect(function() tween(fcStopBtn, {BackgroundTransparency = 0.2}, 0.12) end)

-- Shared speed state - tanpa batas bawah ketat, bisa 0.01
local freecamSpeedShared = 0.01
local FC_MAX_SPEED = 200   -- bebas sampai 200
local FC_MIN_SPEED = 0.01  -- bisa sekecil 0.01

local function setFreecamSpeed(v)
    local parsed = tonumber(v)
    if not parsed then return end
    -- Clamp hanya di atas (jangan negatif/nol) dan batas max
    freecamSpeedShared = math.clamp(parsed, FC_MIN_SPEED, FC_MAX_SPEED)
    -- Tampilkan dengan 2 desimal supaya 0.09 keliatan
    fcSpeedValue.Text = string.format("%.2f", freecamSpeedShared)
    fcSpeedInput.Text = string.format("%.2f", freecamSpeedShared)
    -- Fill bar: log scale biar kelihatan di nilai kecil
    local logRatio = math.log(freecamSpeedShared / FC_MIN_SPEED) / math.log(FC_MAX_SPEED / FC_MIN_SPEED)
    fcFill.Size = UDim2.new(math.clamp(logRatio, 0, 1), 0, 1, 0)
end

fcMinusBtn.MouseButton1Click:Connect(function() setFreecamSpeed(freecamSpeedShared - 0.05) end)
fcPlusBtn.MouseButton1Click:Connect(function()  setFreecamSpeed(freecamSpeedShared + 0.05) end)
fcSpeedInput.FocusLost:Connect(function() setFreecamSpeed(fcSpeedInput.Text) end)

-- Stop function (dipanggil dari stop btn atau toggle off)
local freecamToggleState = false
local freecamSetState = nil  -- akan diisi setelah addToggle freecam dibuat

local function stopFreecam()
    if not freecamToggleState then return end
    freecamToggleState = false
    States.Freecam = false

    if Connections.freecam       then Connections.freecam:Disconnect()       end
    if Connections.freecamRmb    then Connections.freecamRmb:Disconnect()    end
    if Connections.freecamRmbEnd then Connections.freecamRmbEnd:Disconnect() end

    UIS.MouseBehavior = Enum.MouseBehavior.Default
    FreecamHUD.Visible = false

    -- Sinkronkan toggle visual di menu
    if freecamSetState then freecamSetState(false) end

    local cam = Workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = getHum()

    local hrpFC = getHRP()
    local humFC = getHum()
    if hrpFC then hrpFC.Anchored = false end
    if humFC then
        humFC.WalkSpeed = WalkSpeedVal
        humFC.JumpPower = JumpPowerVal
    end
    notify("Freecam", "OFF")
end

fcStopBtn.MouseButton1Click:Connect(stopFreecam)

-- Toggle freecam
local _, fcSetState = addToggle(vPage, "Freecam  (tahan RMB = look)", false, function(on)
    local cam = Workspace.CurrentCamera

    if on then
        States.Freecam = true
        freecamToggleState = true
        cam.CameraType = Enum.CameraType.Scriptable

        local hrpFC = getHRP()
        local humFC = getHum()
        if hrpFC then hrpFC.Anchored = true end
        if humFC then humFC.WalkSpeed = 0; humFC.JumpPower = 0 end

        local _, yaw, _ = cam.CFrame:ToEulerAnglesYXZ()
        local freecamYaw   = yaw
        local freecamPitch = 0
        local isLooking    = false
        local eHeld = false
        local qHeld = false

        Connections.freecamRmb = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                isLooking = true
                UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
            end
        end)
        Connections.freecamRmbEnd = UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                isLooking = false
                UIS.MouseBehavior = Enum.MouseBehavior.Default
            end
        end)

        Connections.freecam = RunService.RenderStepped:Connect(function()
            if not States.Freecam then return end

            if isLooking then
                local delta = UIS:GetMouseDelta()
                freecamYaw   = freecamYaw   - delta.X * 0.003
                freecamPitch = math.clamp(freecamPitch - delta.Y * 0.003, math.rad(-89), math.rad(89))
            end

            -- E/Q: hanya naik sekali per pencet, bukan tiap frame
            if UIS:IsKeyDown(Enum.KeyCode.E) then
                if not eHeld then eHeld = true; setFreecamSpeed(freecamSpeedShared + 0.05) end
            else eHeld = false end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then
                if not qHeld then qHeld = true; setFreecamSpeed(freecamSpeedShared - 0.05) end
            else qHeld = false end

            local rotCF = CFrame.fromEulerAnglesYXZ(freecamPitch, freecamYaw, 0)
            local pos   = cam.CFrame.Position
            local move  = Vector3.new(0, 0, 0)

            if UIS:IsKeyDown(Enum.KeyCode.W)         then move += rotCF.LookVector  end
            if UIS:IsKeyDown(Enum.KeyCode.S)         then move -= rotCF.LookVector  end
            if UIS:IsKeyDown(Enum.KeyCode.A)         then move -= rotCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D)         then move += rotCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space)     then move += Vector3.yAxis      end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.yAxis      end

            cam.CFrame = CFrame.new(pos + move * freecamSpeedShared) * rotCF
        end)

        FreecamHUD.Visible = true
        setFreecamSpeed(0.10)
        notify("Freecam", "ON  |  RMB = look  |  Q/E = speed")
    else
        stopFreecam()
    end
end)
freecamSetState = fcSetState

-- ═══════════════════════════════════════
-- SPECTATE - redesign: player list + overlay UI
-- ═══════════════════════════════════════
addLabel(vPage, "-- SPECTATE PLAYER")

-- ── SpectateOverlay: +25% ukuran (270x76 → 338x96) ──
local SpectateOverlay = Instance.new("Frame", ScreenGui)
SpectateOverlay.Name = "SpectateOverlay"
SpectateOverlay.Size = UDim2.new(0, 338, 0, 96)
SpectateOverlay.Position = UDim2.new(1, -352, 1, -110)
SpectateOverlay.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
SpectateOverlay.BackgroundTransparency = 0.08
SpectateOverlay.BorderSizePixel = 0
SpectateOverlay.Visible = false
SpectateOverlay.ZIndex = 50
addCorner(SpectateOverlay, 14)
addStroke(SpectateOverlay, C.accent, 1.5)

-- Draggable
do
    local sDrag = false; local sDragStart; local sDragPos
    SpectateOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sDrag = true; sDragStart = input.Position; sDragPos = SpectateOverlay.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if sDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - sDragStart
            SpectateOverlay.Position = UDim2.new(sDragPos.X.Scale, sDragPos.X.Offset + d.X, sDragPos.Y.Scale, sDragPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sDrag = false end
    end)
end

-- Dot merah blink LIVE
local SpectDot = Instance.new("Frame", SpectateOverlay)
SpectDot.Size = UDim2.new(0, 10, 0, 10)
SpectDot.Position = UDim2.new(0, 14, 0, 16)
SpectDot.BackgroundColor3 = C.red
SpectDot.BorderSizePixel = 0
SpectDot.ZIndex = 51
addCorner(SpectDot, 5)

task.spawn(function()
    while true do
        task.wait(0.7)
        if SpectateOverlay.Visible then
            tween(SpectDot, {BackgroundTransparency = 0.8}, 0.35)
            task.wait(0.35)
            tween(SpectDot, {BackgroundTransparency = 0}, 0.35)
        end
    end
end)

-- "SPECTATING" label
local SpectTopLabel = Instance.new("TextLabel", SpectateOverlay)
SpectTopLabel.Size = UDim2.new(1, -140, 0, 18)
SpectTopLabel.Position = UDim2.new(0, 32, 0, 10)
SpectTopLabel.BackgroundTransparency = 1
SpectTopLabel.Text = "SPECTATING"
SpectTopLabel.TextColor3 = C.textDim
SpectTopLabel.Font = Enum.Font.GothamBold
SpectTopLabel.TextSize = 11
SpectTopLabel.TextXAlignment = Enum.TextXAlignment.Left
SpectTopLabel.ZIndex = 51

-- Nama player
local SpectNameLabel = Instance.new("TextLabel", SpectateOverlay)
SpectNameLabel.Size = UDim2.new(1, -145, 0, 26)
SpectNameLabel.Position = UDim2.new(0, 14, 0, 30)
SpectNameLabel.BackgroundTransparency = 1
SpectNameLabel.Text = "—"
SpectNameLabel.TextColor3 = C.text
SpectNameLabel.Font = Enum.Font.GothamBold
SpectNameLabel.TextSize = 18
SpectNameLabel.TextXAlignment = Enum.TextXAlignment.Left
SpectNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
SpectNameLabel.ZIndex = 51

-- Counter "@name · 1/5"
local SpectCounterLabel = Instance.new("TextLabel", SpectateOverlay)
SpectCounterLabel.Size = UDim2.new(1, -145, 0, 16)
SpectCounterLabel.Position = UDim2.new(0, 14, 1, -22)
SpectCounterLabel.BackgroundTransparency = 1
SpectCounterLabel.Text = ""
SpectCounterLabel.TextColor3 = C.textDim
SpectCounterLabel.Font = Enum.Font.GothamMedium
SpectCounterLabel.TextSize = 11
SpectCounterLabel.TextXAlignment = Enum.TextXAlignment.Left
SpectCounterLabel.ZIndex = 51

-- ── Nav panel kanan: ◀  ✕  ▶ (vertikal tengah) ──
local navFrame = Instance.new("Frame", SpectateOverlay)
navFrame.Size = UDim2.new(0, 124, 0, 44)
navFrame.Position = UDim2.new(1, -134, 0.5, -22)
navFrame.BackgroundTransparency = 1
navFrame.BorderSizePixel = 0
navFrame.ZIndex = 51

local function makeNavBtn(parent, txt, xOff, col, zIdx)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 38, 0, 38)
    b.Position = UDim2.new(0, xOff, 0.5, -19)
    b.BackgroundColor3 = col or C.card
    b.BackgroundTransparency = 0.25
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    b.ZIndex = zIdx or 52
    addCorner(b, 8)
    b.MouseEnter:Connect(function() tween(b, {BackgroundTransparency = 0}, 0.1) end)
    b.MouseLeave:Connect(function() tween(b, {BackgroundTransparency = 0.25}, 0.1) end)
    return b
end

-- Urutan: ◀  ✕  ▶  (stop di tengah, lebih gampang dijangkau)
local SpectPrevBtn = makeNavBtn(navFrame, "◀", 0,  C.card)
local SpectStopBtn = makeNavBtn(navFrame, "■", 43, C.red)
local SpectNextBtn = makeNavBtn(navFrame, "▶", 86, C.card)

-- ── Logika list spectate dan navigasi ──
local spectPlayerListCache = {}   -- list player selain local (urutan stabil)
local spectCurrentIndex = 1        -- index saat ini di cache

local function getSpectablePlayers()
    local list = {}
    for _, p in Players:GetPlayers() do
        if p ~= Player then table.insert(list, p) end
    end
    return list
end

local function applySpectate(p)
    if not p then return end
    if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
        States.Spectating = true
        spectateTarget = p
        Workspace.CurrentCamera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid")
        SpectNameLabel.Text = p.DisplayName
        -- update counter
        local total = #spectPlayerListCache
        local idx = table.find(spectPlayerListCache, p) or spectCurrentIndex
        SpectCounterLabel.Text = "@" .. p.Name .. "  ·  " .. idx .. " / " .. total
        SpectateOverlay.Visible = true

        -- Freeze karakter utama (seperti freecam)
        local hrp = getHRP()
        local hum = getHum()
        if hrp then hrp.Anchored = true end
        if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end

        -- E/Q untuk pindah spectate target (sekali per pencet)
        if not Connections.spectateKeys then
            local seHeld, sqHeld = false, false
            Connections.spectateKeys = RunService.RenderStepped:Connect(function()
                if not States.Spectating then return end
                if UIS:IsKeyDown(Enum.KeyCode.E) then
                    if not seHeld then
                        seHeld = true
                        spectPlayerListCache = getSpectablePlayers()
                        if #spectPlayerListCache > 0 then
                            spectCurrentIndex = spectCurrentIndex + 1
                            if spectCurrentIndex > #spectPlayerListCache then spectCurrentIndex = 1 end
                            applySpectate(spectPlayerListCache[spectCurrentIndex])
                        end
                    end
                else seHeld = false end
                if UIS:IsKeyDown(Enum.KeyCode.Q) then
                    if not sqHeld then
                        sqHeld = true
                        spectPlayerListCache = getSpectablePlayers()
                        if #spectPlayerListCache > 0 then
                            spectCurrentIndex = spectCurrentIndex - 1
                            if spectCurrentIndex < 1 then spectCurrentIndex = #spectPlayerListCache end
                            applySpectate(spectPlayerListCache[spectCurrentIndex])
                        end
                    end
                else sqHeld = false end
            end)
        end
    else
        notify("Spectate", p.DisplayName .. " has no character")
    end
end

local function stopSpectate()
    States.Spectating = false
    spectateTarget = nil
    Workspace.CurrentCamera.CameraSubject = getHum()
    SpectateOverlay.Visible = false

    -- Unfreeze karakter utama
    local hrp = getHRP()
    local hum = getHum()
    if hrp then hrp.Anchored = false end
    if hum then
        hum.WalkSpeed = WalkSpeedVal
        hum.JumpPower = JumpPowerVal
    end

    -- Disconnect E/Q listener
    if Connections.spectateKeys then
        Connections.spectateKeys:Disconnect()
        Connections.spectateKeys = nil
    end

    notify("Spectate", "Stopped")
end

SpectStopBtn.MouseButton1Click:Connect(stopSpectate)

SpectPrevBtn.MouseButton1Click:Connect(function()
    spectPlayerListCache = getSpectablePlayers()
    if #spectPlayerListCache == 0 then return end
    spectCurrentIndex = spectCurrentIndex - 1
    if spectCurrentIndex < 1 then spectCurrentIndex = #spectPlayerListCache end
    applySpectate(spectPlayerListCache[spectCurrentIndex])
end)

SpectNextBtn.MouseButton1Click:Connect(function()
    spectPlayerListCache = getSpectablePlayers()
    if #spectPlayerListCache == 0 then return end
    spectCurrentIndex = spectCurrentIndex + 1
    if spectCurrentIndex > #spectPlayerListCache then spectCurrentIndex = 1 end
    applySpectate(spectPlayerListCache[spectCurrentIndex])
end)

-- Player list untuk spectate (di dalam Visual tab)
local spectListContainer = Instance.new("Frame", vPage)
spectListContainer.Size = UDim2.new(1, 0, 0, 0)
spectListContainer.BackgroundTransparency = 1
spectListContainer.AutomaticSize = Enum.AutomaticSize.Y

local spectListLayout = Instance.new("UIListLayout", spectListContainer)
spectListLayout.Padding = UDim.new(0, 4)

local function refreshSpectList()
    for _, c in spectListContainer:GetChildren() do
        if c:IsA("TextButton") then c:Destroy() end
    end
    spectPlayerListCache = getSpectablePlayers()
    for i, p in ipairs(spectPlayerListCache) do
        local btn = addButton(spectListContainer,
            "👁  " .. p.DisplayName .. " (@" .. p.Name .. ")",
            function()
                spectCurrentIndex = i
                applySpectate(p)
                if States.Spectating then
                    notify("Spectate", "👁 Watching: " .. p.DisplayName)
                end
            end
        )
    end
    if #spectPlayerListCache == 0 then
        local noOne = Instance.new("TextLabel", spectListContainer)
        noOne.Size = UDim2.new(1, 0, 0, 30)
        noOne.BackgroundTransparency = 1
        noOne.Text = "No other players in server"
        noOne.TextColor3 = C.textDim
        noOne.Font = Enum.Font.GothamMedium
        noOne.TextSize = 12
    end
end
refreshSpectList()

addButton(vPage, "[*] Refresh Spectate List", refreshSpectList)

addButton(vPage, "[X] Stop Spectate", stopSpectate)

-- Locate Player
addLabel(vPage, "-- LOCATE PLAYER")

addInput(vPage, "Player name to locate...", function(text)
    if text == "" then return end
    for _, p in Players:GetPlayers() do
        if p.Name:lower():find(text:lower()) or p.DisplayName:lower():find(text:lower()) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pos = p.Character.HumanoidRootPart.Position
                local myPos = getHRP() and getHRP().Position or Vector3.new(0,0,0)
                local dist = math.floor((pos - myPos).Magnitude)
                notify("Locate: " .. p.DisplayName,
                    string.format("Pos: %.0f, %.0f, %.0f\nDist: %d studs", pos.X, pos.Y, pos.Z, dist))
                pcall(function()
                    local beam = Instance.new("Highlight", p.Character)
                    beam.Name = "LocateHL"
                    beam.FillColor = Color3.fromRGB(255, 255, 0)
                    beam.FillTransparency = 0.5
                    beam.OutlineColor = Color3.fromRGB(255, 255, 0)
                    task.delay(5, function() if beam then beam:Destroy() end end)
                end)
            else
                notify("Locate", p.DisplayName .. " has no character")
            end
            return
        end
    end
    notify("Error", "Player not found")
end)

-- ═══════════════════════════════════════
-- DANCE TAB (REORDERED)
-- Order baru: Preset Dances → Loop/Stop controls → Custom Emote → Custom Anim → Replace Anims → Packs
-- ═══════════════════════════════════════
local dPage = Pages["Dance"]
local currentEmoteTrack = nil
local currentAnimTrack = nil
local savedAnimateScript = nil
local loopAnimEnabled = false

local function killAllCharacterAnims()
    local hum = getHum()
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:Stop(0)
            track:Destroy()
        end
    end
end

local function disableAnimateScript()
    local char = getChar()
    if not char then return end
    local animScript = char:FindFirstChild("Animate")
    if animScript then
        savedAnimateScript = animScript:Clone()
        animScript:Destroy()
    end
end

local function restoreAnimateScript()
    if savedAnimateScript then
        local char = getChar()
        if char then
            local existing = char:FindFirstChild("Animate")
            if existing then existing:Destroy() end
            savedAnimateScript.Parent = char
            savedAnimateScript = nil
        end
    end
end

local function stopAllDanceAnims()
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop() currentEmoteTrack:Destroy() end)
        currentEmoteTrack = nil
    end
    if currentAnimTrack then
        pcall(function() currentAnimTrack:Stop() currentAnimTrack:Destroy() end)
        currentAnimTrack = nil
    end
    restoreAnimateScript()
end

local function resolveEmoteId(emoteId)
    local animationId = nil
    pcall(function()
        local model = game:GetService("InsertService"):LoadAsset(emoteId)
        if model then
            for _, desc in ipairs(model:GetDescendants()) do
                if desc:IsA("Animation") then
                    animationId = desc.AnimationId
                    break
                end
            end
            model:Destroy()
        end
    end)
    if not animationId then
        pcall(function()
            if game.GetObjects then
                local objects = game:GetObjects("rbxassetid://" .. tostring(emoteId))
                if objects and objects[1] then
                    if objects[1]:IsA("Animation") then
                        animationId = objects[1].AnimationId
                    else
                        for _, desc in ipairs(objects[1]:GetDescendants()) do
                            if desc:IsA("Animation") then
                                animationId = desc.AnimationId
                                break
                            end
                        end
                    end
                    objects[1]:Destroy()
                end
            end
        end)
    end
    if not animationId then
        animationId = "rbxassetid://" .. tostring(emoteId)
    end
    return animationId
end

local function playEmoteById(emoteId)
    stopAllDanceAnims()
    local hum = getHum()
    if not hum then notify("Dance", "No character found") return end
    killAllCharacterAnims()
    disableAnimateScript()
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = Instance.new("Animator", hum) end

    local animationId = resolveEmoteId(emoteId)
    local anim = Instance.new("Animation")
    anim.AnimationId = animationId
    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = loopAnimEnabled
        track:Play(0)
        currentEmoteTrack = track
        notify("Dance", "Playing emote: " .. tostring(emoteId))
        track.Stopped:Connect(function()
            if currentEmoteTrack == track then
                pcall(function() track:Destroy() end)
                currentEmoteTrack = nil
                restoreAnimateScript()
            end
        end)
        task.delay(1.5, function()
            if currentEmoteTrack == track and track.Length == 0 then
                notify("Dance", "⚠️ Emote gak valid atau belum owned.")
                pcall(function() track:Stop() track:Destroy() end)
                currentEmoteTrack = nil
                restoreAnimateScript()
            end
        end)
    else
        notify("Dance", "Gagal load emote ID: " .. tostring(emoteId))
        restoreAnimateScript()
    end
end

local animSpeedVal = 1

local function playAnimById(animId, speed)
    stopAllDanceAnims()
    local hum = getHum()
    if not hum then notify("Dance", "No character found") return end
    killAllCharacterAnims()
    disableAnimateScript()
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = Instance.new("Animator", hum) end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(animId)
    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = loopAnimEnabled
        track:AdjustSpeed(speed or 1)
        track:Play(0)
        currentAnimTrack = track
        notify("Animation", "Playing: " .. tostring(animId) .. " (speed: " .. tostring(speed or 1) .. ")")
        track.Stopped:Connect(function()
            if currentAnimTrack == track then
                pcall(function() track:Destroy() end)
                currentAnimTrack = nil
                restoreAnimateScript()
            end
        end)
    else
        notify("Animation", "Failed to load animation ID: " .. tostring(animId))
        restoreAnimateScript()
    end
end

-- ── [1] Preset Dances ──
addLabel(dPage, "-- PRESET DANCES")

local presetDances = {
    {name = "Default Dance",   id = 507771019},
    {name = "Floss",           id = 5917459365},
    {name = "Trip Out",        id = 75483681450871},
    {name = "Rat Dance",        id = 94083401455021},
}

for _, dance in ipairs(presetDances) do
    addButton(dPage, dance.name, function()
        playEmoteById(dance.id)
    end)
end

-- ── [2] Loop & Stop controls - DEKAT preset dances ──
addLabel(dPage, "-- PLAYBACK CONTROLS")

addToggle(dPage, "Loop Animation", false, function(on)
    loopAnimEnabled = on
    if not on then
        stopAllDanceAnims()
        notify("Dance", "Loop off — animation stopped")
    else
        if currentAnimTrack then currentAnimTrack.Looped = true end
        if currentEmoteTrack then currentEmoteTrack.Looped = true end
    end
end)

addButton(dPage, "[X] Stop Dance / Animation", function()
    stopAllDanceAnims()
    notify("Dance", "All animations stopped")
end)

addButton(dPage, "[X] Stop ALL + Reset Anims", function()
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop(0) currentEmoteTrack:Destroy() end)
        currentEmoteTrack = nil
    end
    if currentAnimTrack then
        pcall(function() currentAnimTrack:Stop(0) currentAnimTrack:Destroy() end)
        currentAnimTrack = nil
    end
    local char = Player.Character
    if char then
        local animateScript = char:FindFirstChild("Animate")
        if animateScript then
            for animType, originals in pairs(savedOriginalAnims or {}) do
                local folder = animateScript:FindFirstChild(animType)
                if folder then
                    for _, child in ipairs(folder:GetChildren()) do
                        if child:IsA("Animation") and originals[child.Name] then
                            child.AnimationId = originals[child.Name]
                        end
                    end
                end
            end
        end
    end
    restoreAnimateScript()
    notify("Dance", "All character animations cleared")
end)

-- ── [3] Custom Emote by ID ──
addLabel(dPage, "-- CUSTOM EMOTE (by ID)")

addInput(dPage, "Enter Emote ID (e.g. 507771019)", function(text)
    if text == "" then return end
    local id = tonumber(text)
    if id then
        playEmoteById(id)
    else
        notify("Dance", "Invalid ID! Enter numbers only.")
    end
end)

-- ── [4] Custom Animation by ID ──
addLabel(dPage, "-- CUSTOM ANIMATION (by ID)")

addInput(dPage, "Enter Animation ID", function(text)
    if text == "" then return end
    local id = tonumber(text)
    if id then
        playAnimById(id, animSpeedVal)
    else
        notify("Animation", "Invalid ID! Enter numbers only.")
    end
end)

addSlider(dPage, "Animation Speed", 1, 30, 10, function(v)
    animSpeedVal = v / 10
    if currentAnimTrack then pcall(function() currentAnimTrack:AdjustSpeed(animSpeedVal) end) end
    if currentEmoteTrack then pcall(function() currentEmoteTrack:AdjustSpeed(animSpeedVal) end) end
end)

-- ── [5] Replace Character Animations ──
addLabel(dPage, "-- REPLACE CHARACTER ANIMS")

local savedOriginalAnims = {}

local function replaceCharAnim(animType, newId)
    local char = Player.Character
    if not char then notify("Anim", "No character") return end
    local animateScript = char:FindFirstChild("Animate")
    if not animateScript then notify("Anim", "No Animate script found") return end
    local folder = animateScript:FindFirstChild(animType)
    if not folder then notify("Anim", "No folder: " .. animType) return end
    if not savedOriginalAnims[animType] then
        savedOriginalAnims[animType] = {}
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Animation") then
                savedOriginalAnims[animType][child.Name] = child.AnimationId
            end
        end
    end
    local changed = 0
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Animation") then
            child.AnimationId = "rbxassetid://" .. tostring(newId)
            changed = changed + 1
        end
    end
    if changed > 0 then
        notify("Anim", animType .. " -> " .. tostring(newId) .. " (" .. changed .. " updated)")
    else
        notify("Anim", "No animations found in " .. animType)
    end
end

local animTypes = {
    {label = "Idle",   key = "idle"},
    {label = "Walk",   key = "walk"},
    {label = "Run",    key = "run"},
    {label = "Jump",   key = "jump"},
    {label = "Fall",   key = "fall"},
    {label = "Climb",  key = "climb"},
    {label = "Swim",   key = "swim"},
}

for _, at in ipairs(animTypes) do
    addInput(dPage, at.label .. " Animation ID", function(text)
        if text == "" then return end
        local id = tonumber(text)
        if id then
            replaceCharAnim(at.key, id)
        else
            notify("Anim", "Invalid ID! Numbers only.")
        end
    end)
end

-- ── [6] Animation Pack Presets ──
addLabel(dPage, "-- ANIMATION PACKS")

local vampireAnims = {
    {label = "Vampire Idle",  key = "idle",  id1 = 1083445855, id2 = 1083450166},
    {label = "Vampire Walk",  key = "walk",  id = 1083473930},
    {label = "Vampire Run",   key = "run",   id = 1083462077},
    {label = "Vampire Jump",  key = "jump",  id = 1083455352},
    {label = "Vampire Fall",  key = "fall",  id = 1083443587},
    {label = "Vampire Climb", key = "climb", id = 1083439238},
    {label = "Vampire Swim",  key = "swim",  id = 1083443587},
}

local function replaceIdleAnim(id1, id2)
    local char = Player.Character
    if not char then notify("Anim", "No character") return end
    local animateScript = char:FindFirstChild("Animate")
    if not animateScript then notify("Anim", "No Animate script") return end
    local idleFolder = animateScript:FindFirstChild("idle")
    if not idleFolder then notify("Anim", "No idle folder") return end
    if not savedOriginalAnims["idle"] then
        savedOriginalAnims["idle"] = {}
        for _, child in ipairs(idleFolder:GetChildren()) do
            if child:IsA("Animation") then
                savedOriginalAnims["idle"][child.Name] = child.AnimationId
            end
        end
    end
    local anim1 = idleFolder:FindFirstChild("Animation1")
    local anim2 = idleFolder:FindFirstChild("Animation2")
    if anim1 then anim1.AnimationId = "rbxassetid://" .. tostring(id1) end
    if anim2 then anim2.AnimationId = "rbxassetid://" .. tostring(id2) end
    notify("Anim", "Vampire Idle applied!")
end

for _, va in ipairs(vampireAnims) do
    if va.key == "idle" then
        addButton(dPage, va.label, function() replaceIdleAnim(va.id1, va.id2) end)
    else
        addButton(dPage, va.label, function() replaceCharAnim(va.key, va.id) end)
    end
end

addButton(dPage, "[!] Apply ALL Vampire Anims", function()
    replaceIdleAnim(1083445855, 1083450166)
    replaceCharAnim("walk",  1083473930)
    replaceCharAnim("run",   1083462077)
    replaceCharAnim("jump",  1083455352)
    replaceCharAnim("fall",  1083443587)
    replaceCharAnim("climb", 1083439238)
    replaceCharAnim("swim",  1083443587)
    notify("Anim Pack", "Vampire Animation Pack applied! 🧛")
end)

addLabel(dPage, "-- WEREWOLF PACK (Bonus)")

local werewolfAnims = {
    {label = "Werewolf Idle",  key = "idle",  id = 1113752682},
    {label = "Werewolf Walk",  key = "walk",  id = 1113751657},
    {label = "Werewolf Run",   key = "run",   id = 1113750642},
    {label = "Werewolf Jump",  key = "jump",  id = 1113752285},
    {label = "Werewolf Fall",  key = "fall",  id = 1113751889},
    {label = "Werewolf Climb", key = "climb", id = 1113754738},
    {label = "Werewolf Swim",  key = "swim",  id = 1113752975},
}

for _, wa in ipairs(werewolfAnims) do
    addButton(dPage, wa.label, function() replaceCharAnim(wa.key, wa.id) end)
end

addButton(dPage, "[!] Apply ALL Werewolf Anims", function()
    for _, wa in ipairs(werewolfAnims) do
        replaceCharAnim(wa.key, wa.id)
    end
    notify("Anim Pack", "Werewolf Animation Pack applied! 🐺")
end)

addButton(dPage, "[*] Reset All Anims to Default", function()
    local char = Player.Character
    if char then
        local animateScript = char:FindFirstChild("Animate")
        if animateScript then
            for animType, originals in pairs(savedOriginalAnims) do
                local folder = animateScript:FindFirstChild(animType)
                if folder then
                    for _, child in ipairs(folder:GetChildren()) do
                        if child:IsA("Animation") and originals[child.Name] then
                            child.AnimationId = originals[child.Name]
                        end
                    end
                end
            end
        end
    end
    savedOriginalAnims = {}
    notify("Anim", "All animations reset to default!")
end)

-- ═══════════════════════════════════════
-- FARM TAB
-- ═══════════════════════════════════════
local farmPage = Pages["Farm"]

addLabel(farmPage, "AUTO COLLECT COIN")

local autoCollectRunning = false
local collectDelay = 1

local GOLD_ZONES = {
    Vector3.new(442, 125, -203), Vector3.new(214, 125, 3),
    Vector3.new(-52, 101, -56),  Vector3.new(-253, 137, -286),
    Vector3.new(-186, 114, -649),Vector3.new(-31, 153, -851),
    Vector3.new(383, 125, -737), Vector3.new(301, 96, -349),
    Vector3.new(-47, 59, -474),  Vector3.new(-129, 103, -15),
    Vector3.new(-40, 100, 83),   Vector3.new(405, 127, 20),
    Vector3.new(-202, 76, -371), Vector3.new(-204, 121, -185),
    Vector3.new(-310, 138, -93), Vector3.new(591, 146, -418),
    Vector3.new(63, 155, -819),
}

local function findCoins()
    local coins = {}
    local goldSpawns = workspace:FindFirstChild("GoldSpawns")
    if goldSpawns then
        for _, v in ipairs(goldSpawns:GetDescendants()) do
            if (v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
                local isCollected = v:GetAttribute("IsCollected")
                if isCollected == false then table.insert(coins, v) end
            end
        end
    end
    local assetnew = workspace:FindFirstChild("assetnew")
    if assetnew then
        for _, v in ipairs(assetnew:GetDescendants()) do
            if (v:IsA("Part") or v:IsA("MeshPart")) then
                local isCollected = v:GetAttribute("IsCollected")
                if isCollected == false then table.insert(coins, v) end
            end
        end
    end
    if #coins == 0 then
        for _, v in ipairs(workspace:GetDescendants()) do
            if (v:IsA("Part") or v:IsA("MeshPart")) then
                local isCollected = v:GetAttribute("IsCollected")
                if isCollected == false then table.insert(coins, v) end
            end
        end
    end
    return coins
end

local collectStatusLabel = Instance.new("TextLabel")
collectStatusLabel.Size = UDim2.new(1, -16, 0, 22)
collectStatusLabel.BackgroundTransparency = 1
collectStatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
collectStatusLabel.Font = Enum.Font.GothamBold
collectStatusLabel.TextSize = 11
collectStatusLabel.Text = "Status: OFF | Coin ditemukan: 0"
collectStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
collectStatusLabel.Parent = farmPage

addToggle(farmPage, "Auto Collect Coin", false, function(on)
    autoCollectRunning = on
    if on then
        task.spawn(function()
            while autoCollectRunning do
                local char = Players.LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not (hrp and hum and hum.Health > 0) then
                    collectStatusLabel.Text = "Nunggu karakter... ⏳"
                    task.wait(1) continue
                end
                local coins = findCoins()
                collectStatusLabel.Text = "Coin aktif: " .. #coins .. " 🟢 Collecting..."
                if #coins == 0 then
                    collectStatusLabel.Text = "Nunggu coin spawn... ⏳"
                    task.wait(2) continue
                end
                local originalCFrame = hrp.CFrame
                for _, coin in ipairs(coins) do
                    if not autoCollectRunning then break end
                    if not coin or not coin.Parent then continue end
                    hrp = char and char:FindFirstChild("HumanoidRootPart")
                    hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not hrp or not hum then break end
                    local coinPos = coin.Position
                    hrp.CFrame = CFrame.new(coinPos + Vector3.new(0, 5, 0)) task.wait(0.05)
                    hrp.CFrame = CFrame.new(coinPos + Vector3.new(0, 3, 0)) task.wait(0.05)
                    hrp.CFrame = CFrame.new(coinPos + Vector3.new(0, 1, 0)) task.wait(0.05)
                    hrp.CFrame = CFrame.new(coinPos)                        task.wait(0.05)
                    hrp.CFrame = CFrame.new(coinPos + Vector3.new(0, -1, 0))task.wait(0.05)
                    hrp.CFrame = CFrame.new(coinPos)
                    hum.Jump = true
                    task.wait(collectDelay)
                end
                hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = originalCFrame end
                task.wait(0.5)
            end
            collectStatusLabel.Text = "Status: OFF | Coin ditemukan: 0"
        end)
    else
        collectStatusLabel.Text = "Status: OFF | Coin ditemukan: 0"
    end
end)

addSlider(farmPage, "Delay Per Coin (detik)", 1, 4, 1, function(val) collectDelay = val end)

addLabel(farmPage, "TELEPORT KE GOLD ZONE")

for i, zPos in ipairs(GOLD_ZONES) do
    addButton(farmPage, "→ Gold Zone " .. i, function()
        local char = Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(zPos + Vector3.new(0, 4, 0))
            notify("Farm", "Teleport ke Gold Zone " .. i)
        end
    end)
end

-- ═══════════════════════════════════════
-- MISC TAB
-- ═══════════════════════════════════════
local miscPage = Pages["Misc"]

addLabel(miscPage, "ANTI STAFF")

local STAFF_GROUP_ID = 564796604
local antiStaffRunning = false
local customStaffNames = {}
local antiStaffConnection = nil

local staffStatusLabel = Instance.new("TextLabel")
staffStatusLabel.Size = UDim2.new(1, -16, 0, 22)
staffStatusLabel.BackgroundTransparency = 1
staffStatusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
staffStatusLabel.Font = Enum.Font.GothamBold
staffStatusLabel.TextSize = 11
staffStatusLabel.Text = "Anti Staff: OFF"
staffStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
staffStatusLabel.Parent = miscPage

local function isStaff(player)
    if player == Players.LocalPlayer then return false end
    for _, name in ipairs(customStaffNames) do
        if player.Name:lower() == name:lower() then return true end
    end
    local ok, result = pcall(function() return player:IsInGroup(STAFF_GROUP_ID) end)
    if ok and result then return true end
    return false
end

local function doRejoin()
    notify("⚠️ Anti Staff", "Staff terdeteksi! Pindah server...")
    task.wait(1.5)
    local TS = game:GetService("TeleportService")
    TS:Teleport(game.PlaceId, Players.LocalPlayer)
end

addToggle(miscPage, "Anti Staff (Auto Rejoin)", false, function(on)
    antiStaffRunning = on
    if antiStaffConnection then antiStaffConnection:Disconnect() antiStaffConnection = nil end
    staffStatusLabel.Text = on and "Anti Staff: ON 🟢 Monitoring..." or "Anti Staff: OFF"
    if on then
        for _, p in ipairs(Players:GetPlayers()) do
            if isStaff(p) then
                staffStatusLabel.Text = "⚠️ STAFF DETECTED: " .. p.Name
                doRejoin() return
            end
        end
        antiStaffConnection = Players.PlayerAdded:Connect(function(p)
            if not antiStaffRunning then return end
            task.wait(2)
            if isStaff(p) then
                staffStatusLabel.Text = "⚠️ STAFF JOIN: " .. p.Name
                doRejoin()
            end
        end)
    end
end)

addInput(miscPage, "Tambah username staff...", function(text)
    if text == "" then return end
    table.insert(customStaffNames, text)
    notify("Anti Staff", "Ditambahkan: " .. text)
    staffStatusLabel.Text = "Custom staff list: " .. #customStaffNames .. " username"
end)

addLabel(miscPage, "ANTI FEATURES")

addToggle(miscPage, "Anti AFK", true, function(on)
    States.AntiAFK = on
    if on then
        local vu = game:GetService("VirtualUser")
        Connections.antiafk = Players.LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end)
        notify("Anti AFK", "Enabled")
    else
        if Connections.antiafk then Connections.antiafk:Disconnect() end
        notify("Anti AFK", "Disabled")
    end
end)

do
    local vu = game:GetService("VirtualUser")
    Connections.antiafk = Players.LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end

addButton(miscPage, "Anti Lag (Clean Up)", function()
    local removed = 0
    for _, v in Workspace:GetDescendants() do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false removed = removed + 1
        elseif v:IsA("Explosion") then
            v:Destroy() removed = removed + 1
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1 removed = removed + 1
        end
    end
    pcall(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0 terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0 terrain.WaterTransparency = 0
        end
    end)
    local lighting = game:GetService("Lighting")
    for _, v in lighting:GetDescendants() do
        if v:IsA("PostEffect") then v.Enabled = false end
    end
    lighting.GlobalShadows = false
    lighting.FogEnd = 100000
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    notify("Anti Lag", "Cleaned " .. removed .. " effects")
end)

addButton(miscPage, "Remove Textures (Smooth)", function()
    local count = 0
    for _, v in Workspace:GetDescendants() do
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic count = count + 1
        end
    end
    notify("Smooth", count .. " parts set to SmoothPlastic")
end)

addLabel(miscPage, "UTILITIES")

addButton(miscPage, "Click TP (Click anywhere)", function()
    notify("Click TP", "Click anywhere to teleport!")
    local conn
    conn = Mouse.Button1Down:Connect(function()
        local hrp = getHRP()
        if hrp and Mouse.Hit then hrp.CFrame = Mouse.Hit + Vector3.new(0, 5, 0) end
        conn:Disconnect()
    end)
end)

addButton(miscPage, "[E] TP to Mouse (Hold E)", function()
    notify("TP to Mouse", "Hold E to teleport to cursor")
    if Connections.mouseTP then Connections.mouseTP:Disconnect() end
    Connections.mouseTP = RunService.RenderStepped:Connect(function()
        if UIS:IsKeyDown(Enum.KeyCode.E) then
            local hrp = getHRP()
            if hrp and Mouse.Hit then hrp.CFrame = Mouse.Hit + Vector3.new(0, 5, 0) end
        end
    end)
end)

addButton(miscPage, "[C] Copy Game PlaceId", function()
    if setclipboard or toclipboard then
        (setclipboard or toclipboard)(tostring(game.PlaceId))
        notify("Copied", "PlaceId: " .. game.PlaceId)
    end
end)

addButton(miscPage, "[!] Kill All (Client-side)", function()
    for _, p in Players:GetPlayers() do
        if p ~= Player and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h then pcall(function() h.Health = 0 end) end
        end
    end
    notify("Kill All", "Attempted (client-side only)")
end)

addLabel(miscPage, "-- KEYBIND")

-- ── PC MODE SETTING ──
-- Di PC biasanya gak perlu MiniBtn "P" yang muncul saat minimize

local pcModeCard = Instance.new("Frame", miscPage)
pcModeCard.Size = UDim2.new(1, 0, 0, 52)
pcModeCard.BackgroundColor3 = C.card
pcModeCard.BorderSizePixel = 0
addCorner(pcModeCard, 8)
addStroke(pcModeCard, C.border, 1)

local pcModeTop = Instance.new("TextLabel", pcModeCard)
pcModeTop.Size = UDim2.new(1, -60, 0, 20)
pcModeTop.Position = UDim2.new(0, 12, 0, 4)
pcModeTop.BackgroundTransparency = 1
pcModeTop.Text = "PC Mode  (disable tombol P)"
pcModeTop.TextColor3 = C.text
pcModeTop.Font = Enum.Font.GothamBold
pcModeTop.TextSize = 12
pcModeTop.TextXAlignment = Enum.TextXAlignment.Left

local pcModeSub = Instance.new("TextLabel", pcModeCard)
pcModeSub.Size = UDim2.new(1, -60, 0, 16)
pcModeSub.Position = UDim2.new(0, 12, 0, 24)
pcModeSub.BackgroundTransparency = 1
pcModeSub.Text = "Sembunyikan floating P button saat minimize"
pcModeSub.TextColor3 = C.textDim
pcModeSub.Font = Enum.Font.GothamMedium
pcModeSub.TextSize = 10
pcModeSub.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle visual untuk PC Mode
local pcTogBg = Instance.new("Frame", pcModeCard)
pcTogBg.Size = UDim2.new(0, 40, 0, 20)
pcTogBg.Position = UDim2.new(1, -52, 0.5, -10)
pcTogBg.BackgroundColor3 = C.green
pcTogBg.BorderSizePixel = 0
addCorner(pcTogBg, 10)

local pcTogCircle = Instance.new("Frame", pcTogBg)
pcTogCircle.Size = UDim2.new(0, 16, 0, 16)
pcTogCircle.Position = UDim2.new(1, -18, 0, 2)
pcTogCircle.BackgroundColor3 = C.text
pcTogCircle.BorderSizePixel = 0
addCorner(pcTogCircle, 8)

local pcTogBtn = Instance.new("TextButton", pcModeCard)
pcTogBtn.Size = UDim2.new(1, 0, 1, 0)
pcTogBtn.BackgroundTransparency = 1
pcTogBtn.Text = ""
pcTogBtn.ZIndex = 5

pcTogBtn.MouseButton1Click:Connect(function()
    pcModeEnabled = not pcModeEnabled
    tween(pcTogBg, {BackgroundColor3 = pcModeEnabled and C.green or C.toggleOff}, 0.2)
    tween(pcTogCircle, {Position = pcModeEnabled and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2)
    -- Kalau PC Mode aktif: sembunyikan MiniBtn
    -- MiniBtn sudah ada tapi belum visible - logic-nya di MinBtn click dan di toggle key
    if pcModeEnabled then
        MiniBtn.Visible = false  -- hide seketika jika lagi visible
        notify("PC Mode", "ON — Tombol P disembunyikan. Gunakan " .. tostring(currentToggleKey.Name) .. " untuk toggle.")
    else
        notify("PC Mode", "OFF — Tombol P aktif kembali saat minimize.")
    end
end)

local keyBindBtn = addButton(miscPage, "Toggle Key: LeftControl", function() end)
keyBindBtn.TextColor3 = C.textDim

local bindBtn = addButton(miscPage, "[*] Ganti Toggle Key (tekan key apa aja)", function()
    if isBindingKey then
        isBindingKey = false
        keyBindBtn.Text = "Toggle Key: " .. tostring(currentToggleKey.Name)
        notify("Keybind", "Batal ganti key")
    else
        isBindingKey = true
        keyBindBtn.Text = "Tekan key baru..."
        notify("Keybind", "Tekan key yang kamu mau buat toggle UI!")
        task.spawn(function()
            while isBindingKey do task.wait(0.1) end
            keyBindBtn.Text = "Toggle Key: " .. tostring(currentToggleKey.Name)
        end)
    end
end)

addButton(miscPage, "[R] Reset ke Default (RightControl)", function()
    currentToggleKey = Enum.KeyCode.LeftControl
    isBindingKey = false
    keyBindBtn.Text = "Toggle Key: LeftControl"
    notify("Keybind", "Reset ke LeftControl")
end)

addLabel(miscPage, "-- INFO")

addButton(miscPage, "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, function() end)
addButton(miscPage, "PlaceId: " .. game.PlaceId, function() end)
addButton(miscPage, "Player: " .. Player.DisplayName .. " (@" .. Player.Name .. ")", function() end)

-- ═══════════════════════════════════════
-- TOGGLE KEY (Custom Keybind)
-- ═══════════════════════════════════════
-- TOGGLE KEY (Custom Keybind) - no delay
-- ═══════════════════════════════════════
local toggleKeyDown = false

UIS.InputBegan:Connect(function(input, gpe)
    if isBindingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            currentToggleKey = input.KeyCode
            isBindingKey = false
            notify("Keybind", "Toggle key: " .. tostring(input.KeyCode.Name))
        end
        return
    end
    if gpe then return end
    if (input.KeyCode == currentToggleKey or input.KeyCode == Enum.KeyCode.Insert) then
        if not toggleKeyDown then
            toggleKeyDown = true
            if minimized then
                minimized = false
                Main.Size = UDim2.new(0, 520, 0, 380)
                Main.BackgroundTransparency = 0
                Main.Visible = true
            else
                Main.Visible = not Main.Visible
            end
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == currentToggleKey or input.KeyCode == Enum.KeyCode.Insert then
        toggleKeyDown = false
    end
end)

-- ═══════════════════════════════════════
-- INTRO
-- ═══════════════════════════════════════
Main.BackgroundTransparency = 0
Main.Size = UDim2.new(0, 520, 0, 380)
notify("VelxHub v1.5", "Tombol leftCtrl untuk toggle")
