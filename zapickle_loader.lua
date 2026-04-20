-- // zapickle loader script
-- // for educational purposes only
-- // compatible with: synapse x, krnl, script-ware, fluxus

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // CONFIG
local CONFIG = {
    LoadTime = 300,
    AccentColor = Color3.fromRGB(0, 180, 255),
    AccentColor2 = Color3.fromRGB(95, 63, 255),
    CardColor = Color3.fromRGB(13, 15, 24),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(110, 120, 150),
}

local State = {
    FreezeTrade = false,
    AutoAccept = false,
    ForceAccept = true,
    ESPPlayers = false,
    InfiniteYield = false,
    GodMode = false,
}

local LoadingMessages = {
    "Initializing executor...",
    "Bypassing anti-cheat...",
    "Injecting hooks...",
    "Patching memory tables...",
    "Loading modules...",
    "Verifying signatures...",
    "Connecting to backend...",
    "Almost ready...",
    "Finalizing...",
}

-- // =============================
-- //        ANTI-LEAVE
-- // =============================

-- block the roblox top bar menu button (hamburger / roblox icon)
pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
end)

-- disable the escape key opening the roblox leave menu
local function BlockLeaveMenu()
    -- intercept escape key before roblox can process it
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Escape then
            -- re-close the menu immediately if it opens
            task.defer(function()
                pcall(function()
                    GuiService:SetMenuOpen(false)
                end)
            end)
        end
    end)

    -- continuously force the roblox menu shut
    RunService.Heartbeat:Connect(function()
        pcall(function()
            if GuiService:GetMenuOpen() then
                GuiService:SetMenuOpen(false)
            end
        end)
    end)
end

-- hide the roblox top bar entirely (hides the roblox icon leave button)
local function HideTopBar()
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    end)
    -- also try via game settings
    pcall(function()
        game:GetService("GameSettings").OverrideStarterGui = true
    end)
end

-- block window close via hook (executor-level, works on synapse/krnl)
local function BlockWindowClose()
    -- this hooks the shutdown event and cancels it
    -- note: this is executor-level and requires a script executor to function
    if hookfunction then
        local oldShutdown = game.close
        hookfunction(game.close, function()
            -- do nothing — block the close
        end)
    end

    -- alternative: keep reconnecting if somehow disconnected
    game:BindToClose(function()
        -- stall the close for as long as possible
        local t = tick()
        while tick() - t < 10 do
            task.wait(0.1)
        end
    end)
end

-- run all anti-leave systems
BlockLeaveMenu()
HideTopBar()
BlockWindowClose()

-- re-apply top bar hide every few seconds in case roblox resets it
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
            if GuiService:GetMenuOpen() then
                GuiService:SetMenuOpen(false)
            end
        end)
    end
end)

-- // =============================
-- //        UTILITIES
-- // =============================
if PlayerGui:FindFirstChild("ZapickleLoader") then
    PlayerGui.ZapickleLoader:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZapickleLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local function Tween(obj, props, duration, style, dir)
    local t = TweenService:Create(obj,
        TweenInfo.new(duration or 0.4, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props)
    t:Play()
    return t
end

local function MakeFrame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.BackgroundTransparency = 1
    for k, v in pairs(props or {}) do f[k] = v end
    f.Parent = parent
    return f
end

local function MakeLabel(parent, props)
    local l = Instance.new("TextLabel")
    l.BorderSizePixel = 0
    l.BackgroundTransparency = 1
    l.TextColor3 = CONFIG.TextColor
    l.Font = Enum.Font.GothamBold
    l.TextScaled = false
    l.TextWrapped = true
    for k, v in pairs(props or {}) do l[k] = v end
    l.Parent = parent
    return l
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

local function MakeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.AccentColor
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.7
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function MakeGradient(parent, rotation, keypoints)
    local g = Instance.new("UIGradient")
    g.Rotation = rotation or 90
    g.Color = ColorSequence.new(keypoints)
    g.Parent = parent
    return g
end

local function PadNum(n)
    return string.format("%02d", math.floor(n))
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- // =============================
-- //        LOADER CARD
-- // =============================
local LoaderCard = MakeFrame(ScreenGui, {
    Size = UDim2.new(0, 340, 0, 420),
    Position = UDim2.new(0.5, -170, 0.5, -210),
    BackgroundColor3 = CONFIG.CardColor,
    BackgroundTransparency = 0.05,
    ZIndex = 2,
})
MakeCorner(LoaderCard, 20)
MakeStroke(LoaderCard, CONFIG.AccentColor, 1, 0.72)
MakeDraggable(LoaderCard)

-- top glow line
local TL = MakeFrame(LoaderCard, {
    Size = UDim2.new(0.55, 0, 0, 1),
    Position = UDim2.new(0.225, 0, 0, 0),
    BackgroundColor3 = CONFIG.AccentColor,
    BackgroundTransparency = 0,
    ZIndex = 3,
})
MakeGradient(TL, 90, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5, CONFIG.AccentColor),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
})

-- spinning ring
local AvatarRing = MakeFrame(LoaderCard, {
    Size = UDim2.new(0, 106, 0, 106),
    Position = UDim2.new(0.5, -53, 0, 22),
    BackgroundTransparency = 1,
    ZIndex = 3,
})
MakeCorner(AvatarRing, 53)
MakeStroke(AvatarRing, CONFIG.AccentColor, 2.5, 0.08)

-- inner ring (counter rotate)
local AvatarRing2 = MakeFrame(LoaderCard, {
    Size = UDim2.new(0, 116, 0, 116),
    Position = UDim2.new(0.5, -58, 0, 17),
    BackgroundTransparency = 1,
    ZIndex = 3,
})
MakeCorner(AvatarRing2, 58)
MakeStroke(AvatarRing2, CONFIG.AccentColor2, 1, 0.6)

-- avatar bg
local AvatarBG = MakeFrame(LoaderCard, {
    Size = UDim2.new(0, 90, 0, 90),
    Position = UDim2.new(0.5, -45, 0, 30),
    BackgroundColor3 = Color3.fromRGB(18, 22, 36),
    BackgroundTransparency = 0,
    ZIndex = 3,
})
MakeCorner(AvatarBG, 45)
MakeStroke(AvatarBG, CONFIG.AccentColor, 1, 0.82)

MakeLabel(AvatarBG, {
    Size = UDim2.new(1, 0, 1, 0),
    Text = "🎮",
    TextSize = 38,
    ZIndex = 4,
})

MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 34),
    Position = UDim2.new(0, 10, 0, 144),
    Text = LocalPlayer.Name,
    TextSize = 26,
    Font = Enum.Font.GothamBold,
    ZIndex = 3,
})

MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 178),
    Text = "@" .. LocalPlayer.Name:lower(),
    TextSize = 12,
    TextColor3 = Color3.fromRGB(0, 145, 200),
    Font = Enum.Font.Code,
    ZIndex = 3,
})

local StatusLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 24),
    Position = UDim2.new(0, 10, 0, 208),
    Text = "SCRIPT LOADING",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(245, 166, 35),
    Font = Enum.Font.GothamBold,
    ZIndex = 3,
})

local SubLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -30, 0, 18),
    Position = UDim2.new(0, 15, 0, 234),
    Text = LoadingMessages[1],
    TextSize = 12,
    TextColor3 = CONFIG.SubTextColor,
    Font = Enum.Font.Code,
    ZIndex = 3,
})

local BarBG = MakeFrame(LoaderCard, {
    Size = UDim2.new(1, -40, 0, 6),
    Position = UDim2.new(0, 20, 0, 268),
    BackgroundColor3 = Color3.fromRGB(22, 26, 42),
    BackgroundTransparency = 0,
    ZIndex = 3,
})
MakeCorner(BarBG, 3)

local BarFill = MakeFrame(BarBG, {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = CONFIG.AccentColor,
    BackgroundTransparency = 0,
    ZIndex = 4,
})
MakeCorner(BarFill, 3)
MakeGradient(BarFill, 90, {
    ColorSequenceKeypoint.new(0, CONFIG.AccentColor),
    ColorSequenceKeypoint.new(1, CONFIG.AccentColor2),
})

local TimerLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(0, 80, 0, 18),
    Position = UDim2.new(0, 20, 0, 284),
    Text = "05:00",
    TextSize = 12,
    TextColor3 = CONFIG.SubTextColor,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.Code,
    ZIndex = 3,
})

local PctLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(0, 50, 0, 18),
    Position = UDim2.new(1, -70, 0, 284),
    Text = "0%",
    TextSize = 12,
    TextColor3 = CONFIG.AccentColor,
    TextXAlignment = Enum.TextXAlignment.Right,
    Font = Enum.Font.Code,
    ZIndex = 3,
})

local DotsHolder = MakeFrame(LoaderCard, {
    Size = UDim2.new(0, 56, 0, 10),
    Position = UDim2.new(0.5, -28, 0, 316),
    ZIndex = 3,
})
local dll = Instance.new("UIListLayout")
dll.FillDirection = Enum.FillDirection.Horizontal
dll.HorizontalAlignment = Enum.HorizontalAlignment.Center
dll.VerticalAlignment = Enum.VerticalAlignment.Center
dll.Padding = UDim.new(0, 8)
dll.Parent = DotsHolder

local Dots = {}
for i = 1, 3 do
    local d = MakeFrame(DotsHolder, {
        Size = UDim2.new(0, 7, 0, 7),
        BackgroundColor3 = i == 1 and CONFIG.AccentColor or Color3.fromRGB(35, 38, 55),
        BackgroundTransparency = 0,
        ZIndex = 4,
    })
    MakeCorner(d, 4)
    Dots[i] = d
end

-- anti-leave status indicator on loader
local AntiLeaveTag = MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 14),
    Position = UDim2.new(0, 10, 0, 344),
    Text = "⚡ anti-leave active",
    TextSize = 10,
    TextColor3 = Color3.fromRGB(0, 200, 100),
    Font = Enum.Font.Code,
    ZIndex = 3,
})

MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 16),
    Position = UDim2.new(0, 10, 0, 390),
    Text = "zapickle  ·  for educational purposes only",
    TextSize = 10,
    TextColor3 = Color3.fromRGB(35, 40, 60),
    Font = Enum.Font.Code,
    ZIndex = 3,
})

-- // =============================
-- //        SCRIPT PANEL
-- // =============================
local Panel = MakeFrame(ScreenGui, {
    Size = UDim2.new(0, 310, 0, 430),
    Position = UDim2.new(0.5, -155, 0.5, -215),
    BackgroundColor3 = CONFIG.CardColor,
    BackgroundTransparency = 0.05,
    ZIndex = 2,
    Visible = false,
})
MakeCorner(Panel, 20)
MakeStroke(Panel, CONFIG.AccentColor, 1, 0.72)
MakeDraggable(Panel)

local PTL = MakeFrame(Panel, {
    Size = UDim2.new(0.55, 0, 0, 1),
    Position = UDim2.new(0.225, 0, 0, 0),
    BackgroundColor3 = CONFIG.AccentColor,
    BackgroundTransparency = 0,
    ZIndex = 3,
})
MakeGradient(PTL, 90, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5, CONFIG.AccentColor),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
})

local PanelHeader = MakeFrame(Panel, {
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundTransparency = 1,
    ZIndex = 3,
})

local PulseDot = MakeFrame(PanelHeader, {
    Size = UDim2.new(0, 9, 0, 9),
    Position = UDim2.new(0, 18, 0.5, -4),
    BackgroundColor3 = CONFIG.AccentColor,
    BackgroundTransparency = 0,
    ZIndex = 4,
})
MakeCorner(PulseDot, 5)

MakeLabel(PanelHeader, {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 34, 0, 0),
    Text = "SCRIPT PANEL",
    TextSize = 12,
    TextColor3 = Color3.fromRGB(180, 200, 220),
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.Code,
    ZIndex = 4,
})

-- anti-leave badge in panel header
local ALBadge = MakeFrame(PanelHeader, {
    Size = UDim2.new(0, 68, 0, 18),
    Position = UDim2.new(0, 34, 1, -26),
    BackgroundColor3 = Color3.fromRGB(0, 60, 30),
    BackgroundTransparency = 0,
    ZIndex = 4,
})
MakeCorner(ALBadge, 4)
MakeStroke(ALBadge, Color3.fromRGB(0, 200, 80), 1, 0.55)
MakeLabel(ALBadge, {
    Size = UDim2.new(1, 0, 1, 0),
    Text = "⚡ PROTECTED",
    TextSize = 9,
    TextColor3 = Color3.fromRGB(0, 220, 100),
    Font = Enum.Font.Code,
    ZIndex = 5,
})

-- close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(90, 15, 15)
CloseBtn.BackgroundTransparency = 0.5
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 5
CloseBtn.Parent = PanelHeader
MakeCorner(CloseBtn, 6)
MakeStroke(CloseBtn, Color3.fromRGB(255, 70, 70), 1, 0.6)

CloseBtn.MouseEnter:Connect(function()
    Tween(CloseBtn, {BackgroundTransparency = 0.15}, 0.18)
end)
CloseBtn.MouseLeave:Connect(function()
    Tween(CloseBtn, {BackgroundTransparency = 0.5}, 0.18)
end)
CloseBtn.MouseButton1Click:Connect(function()
    -- restore top bar when closing
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    end)
    Tween(Panel, {BackgroundTransparency = 1}, 0.35)
    task.wait(0.4)
    ScreenGui:Destroy()
end)

MakeFrame(Panel, {
    Size = UDim2.new(1, -36, 0, 1),
    Position = UDim2.new(0, 18, 0, 52),
    BackgroundColor3 = CONFIG.AccentColor,
    BackgroundTransparency = 0.88,
    ZIndex = 3,
})

local function SectionLabel(yPos, txt)
    MakeLabel(Panel, {
        Size = UDim2.new(1, -36, 0, 16),
        Position = UDim2.new(0, 18, 0, yPos),
        Text = txt,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(0, 120, 170),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code,
        ZIndex = 3,
    })
end

SectionLabel(60, "── TRADE MODS")
SectionLabel(212, "── VISUALS")

local function MakeToggleRow(yPos, labelText, defaultOn, onToggle)
    local Row = MakeFrame(Panel, {
        Size = UDim2.new(1, -2, 0, 46),
        Position = UDim2.new(0, 1, 0, yPos),
        BackgroundColor3 = Color3.fromRGB(16, 19, 30),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })

    local AccentBar = MakeFrame(Row, {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = CONFIG.AccentColor,
        BackgroundTransparency = 1,
        ZIndex = 4,
    })
    MakeGradient(AccentBar, 180, {
        ColorSequenceKeypoint.new(0, CONFIG.AccentColor),
        ColorSequenceKeypoint.new(1, CONFIG.AccentColor2),
    })

    local RowLabel = MakeLabel(Row, {
        Size = UDim2.new(0.65, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        Text = labelText,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(170, 182, 205),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        ZIndex = 4,
    })

    local OnOffLabel = MakeLabel(Row, {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(1, -76, 0, 0),
        Text = defaultOn and "ON" or "OFF",
        TextSize = 10,
        TextColor3 = defaultOn and CONFIG.AccentColor or Color3.fromRGB(55, 60, 80),
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Code,
        ZIndex = 4,
    })

    local TglBG = MakeFrame(Row, {
        Size = UDim2.new(0, 42, 0, 23),
        Position = UDim2.new(1, -58, 0.5, -11),
        BackgroundColor3 = defaultOn and Color3.fromRGB(0, 45, 72) or Color3.fromRGB(26, 29, 44),
        BackgroundTransparency = 0,
        ZIndex = 4,
    })
    MakeCorner(TglBG, 12)
    local TglStroke = MakeStroke(TglBG,
        defaultOn and CONFIG.AccentColor or Color3.fromRGB(45, 50, 70),
        1,
        defaultOn and 0.35 or 0.65
    )

    local TglKnob = MakeFrame(TglBG, {
        Size = UDim2.new(0, 15, 0, 15),
        Position = defaultOn
            and UDim2.new(1, -18, 0.5, -7)
            or  UDim2.new(0, 3,   0.5, -7),
        BackgroundColor3 = defaultOn and CONFIG.AccentColor or Color3.fromRGB(55, 60, 85),
        BackgroundTransparency = 0,
        ZIndex = 5,
    })
    MakeCorner(TglKnob, 8)

    MakeFrame(Row, {
        Size = UDim2.new(1, -32, 0, 1),
        Position = UDim2.new(0, 16, 1, -1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.94,
        ZIndex = 3,
    })

    local isOn = defaultOn
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 6
    Btn.Parent = Row

    Btn.MouseEnter:Connect(function()
        Tween(Row, {BackgroundTransparency = 0.82}, 0.18)
        Tween(AccentBar, {BackgroundTransparency = 0}, 0.18)
        Tween(RowLabel, {TextColor3 = Color3.fromRGB(225, 238, 255)}, 0.18)
    end)
    Btn.MouseLeave:Connect(function()
        Tween(Row, {BackgroundTransparency = 1}, 0.18)
        Tween(AccentBar, {BackgroundTransparency = 1}, 0.18)
        Tween(RowLabel, {TextColor3 = Color3.fromRGB(170, 182, 205)}, 0.18)
    end)

    Btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            Tween(TglKnob, {Position = UDim2.new(1, -18, 0.5, -7), BackgroundColor3 = CONFIG.AccentColor}, 0.22)
            Tween(TglBG, {BackgroundColor3 = Color3.fromRGB(0, 45, 72)}, 0.22)
            Tween(TglStroke, {Color = CONFIG.AccentColor, Transparency = 0.35}, 0.22)
            Tween(OnOffLabel, {TextColor3 = CONFIG.AccentColor}, 0.18)
            OnOffLabel.Text = "ON"
        else
            Tween(TglKnob, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(55, 60, 85)}, 0.22)
            Tween(TglBG, {BackgroundColor3 = Color3.fromRGB(26, 29, 44)}, 0.22)
            Tween(TglStroke, {Color = Color3.fromRGB(45, 50, 70), Transparency = 0.65}, 0.22)
            Tween(OnOffLabel, {TextColor3 = Color3.fromRGB(55, 60, 80)}, 0.18)
            OnOffLabel.Text = "OFF"
        end
        if onToggle then onToggle(isOn) end
    end)
end

local toggleDefs = {
    {78,  "Freeze Trade",   false, "FreezeTrade"},
    {126, "Auto Accept",    false, "AutoAccept"},
    {174, "Force Accept",   true,  "ForceAccept"},
    {230, "ESP Players",    false, "ESPPlayers"},
    {278, "Infinite Yield", false, "InfiniteYield"},
    {326, "God Mode",       false, "GodMode"},
}
for _, d in ipairs(toggleDefs) do
    MakeToggleRow(d[1], d[2], d[3], function(val)
        State[d[4]] = val
        print("[zapickle] " .. d[2] .. " -> " .. tostring(val))
    end)
end

MakeLabel(Panel, {
    Size = UDim2.new(1, -20, 0, 16),
    Position = UDim2.new(0, 10, 0, 400),
    Text = "zapickle  ·  for educational purposes only",
    TextSize = 10,
    TextColor3 = Color3.fromRGB(30, 34, 52),
    Font = Enum.Font.Code,
    ZIndex = 3,
})

-- // =============================
-- //       LOADER LOGIC
-- // =============================
local elapsed = 0
local msgIndex = 1
local msgTimer = 0
local MSG_INTERVAL = math.floor(CONFIG.LoadTime / #LoadingMessages)
local ring2Angle = 0

RunService.Heartbeat:Connect(function(dt)
    -- spin both rings in opposite directions
    AvatarRing.Rotation += dt * 130
    ring2Angle -= dt * 60
    AvatarRing2.Rotation = ring2Angle

    if Panel.Visible then
        PulseDot.BackgroundTransparency = 0.1 + 0.7 * math.abs(math.sin(os.clock() * 2.5))
    end
end)

task.spawn(function()
    while elapsed < CONFIG.LoadTime do
        task.wait(1)
        elapsed += 1

        local pct = math.floor((elapsed / CONFIG.LoadTime) * 100)
        local remaining = CONFIG.LoadTime - elapsed
        local mins = math.floor(remaining / 60)
        local secs = remaining % 60

        Tween(BarFill, {Size = UDim2.new(pct / 100, 0, 1, 0)}, 0.85, Enum.EasingStyle.Linear)
        TimerLabel.Text = PadNum(mins) .. ":" .. PadNum(secs)
        PctLabel.Text = pct .. "%"

        -- cycle sub message with fade
        msgTimer += 1
        if msgTimer >= MSG_INTERVAL and msgIndex < #LoadingMessages then
            msgTimer = 0
            msgIndex += 1
            Tween(SubLabel, {TextTransparency = 1}, 0.28)
            task.wait(0.3)
            SubLabel.Text = LoadingMessages[msgIndex]
            Tween(SubLabel, {TextTransparency = 0}, 0.28)
        end

        -- dots
        local stage = math.clamp(math.ceil((elapsed / CONFIG.LoadTime) * 3), 1, 3)
        for i, d in ipairs(Dots) do
            Tween(d, {
                BackgroundColor3 = i == stage and CONFIG.AccentColor or Color3.fromRGB(35, 38, 55)
            }, 0.3)
        end

        -- pulse status
        Tween(StatusLabel, {TextTransparency = elapsed % 2 == 0 and 0.45 or 0}, 0.5)
    end

    -- done
    StatusLabel.Text = "READY"
    StatusLabel.TextColor3 = CONFIG.AccentColor
    StatusLabel.TextTransparency = 0
    SubLabel.Text = "Script loaded successfully."
    TimerLabel.Text = "00:00"
    PctLabel.Text = "100%"
    Tween(BarFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.4)
    task.wait(0.9)

    Tween(LoaderCard, {BackgroundTransparency = 1}, 0.4)
    for _, child in ipairs(LoaderCard:GetDescendants()) do
        pcall(function()
            if child:IsA("TextLabel") then
                Tween(child, {TextTransparency = 1}, 0.3)
            elseif child:IsA("Frame") then
                Tween(child, {BackgroundTransparency = 1}, 0.3)
            end
        end)
    end
    task.wait(0.5)
    LoaderCard.Visible = false

    Panel.Visible = true
    Panel.Position = UDim2.new(0.5, -155, 0.5, -235)
    Panel.BackgroundTransparency = 1
    Tween(Panel, {
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0.5, -155, 0.5, -215)
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    print("[zapickle] Panel ready. Anti-leave active.")
end)

print("[zapickle] Loader started. Anti-leave engaged.")
