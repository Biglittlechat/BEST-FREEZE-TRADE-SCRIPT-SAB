-- // zapickle loader script
-- // for educational purposes only
-- // compatible with: synapse x, krnl, script-ware, fluxus

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // CONFIG
local CONFIG = {
    Username = LocalPlayer.Name,
    LoadTime = 300, -- 5 minutes in seconds
    AccentColor = Color3.fromRGB(0, 180, 255),
    AccentColor2 = Color3.fromRGB(95, 63, 255),
    BgColor = Color3.fromRGB(10, 11, 16),
    CardColor = Color3.fromRGB(16, 19, 31),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(120, 130, 160),
    ToggleOnColor = Color3.fromRGB(0, 180, 255),
    ToggleOffColor = Color3.fromRGB(40, 44, 60),
}

-- // STATE
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
    "Loading modules...",
    "Patching memory...",
    "Almost ready...",
    "Finalizing...",
}

-- // DESTROY OLD GUI
if PlayerGui:FindFirstChild("ZapickleLoader") then
    PlayerGui.ZapickleLoader:Destroy()
end

-- // SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZapickleLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- // UTILITY FUNCTIONS
local function Tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(
        duration or 0.4,
        style or Enum.EasingStyle.Quart,
        dir or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function MakeFrame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
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

-- // OVERLAY BACKGROUND
local Overlay = MakeFrame(ScreenGui, {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 0,
    BackgroundColor3 = CONFIG.BgColor,
    ZIndex = 1,
})

-- // =============================
-- //        LOADER CARD
-- // =============================
local LoaderCard = MakeFrame(Overlay, {
    Size = UDim2.new(0, 360, 0, 440),
    Position = UDim2.new(0.5, -180, 0.5, -220),
    BackgroundColor3 = CONFIG.CardColor,
    BackgroundTransparency = 0,
    ZIndex = 2,
})
MakeCorner(LoaderCard, 20)
MakeStroke(LoaderCard, CONFIG.AccentColor, 1, 0.75)

-- top glow line
local TopLine = MakeFrame(LoaderCard, {
    Size = UDim2.new(0.5, 0, 0, 1),
    Position = UDim2.new(0.25, 0, 0, 0),
    BackgroundColor3 = CONFIG.AccentColor,
    BackgroundTransparency = 0.2,
    ZIndex = 3,
})
MakeGradient(TopLine, 90, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5, CONFIG.AccentColor),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
})

-- avatar background circle
local AvatarBG = MakeFrame(LoaderCard, {
    Size = UDim2.new(0, 90, 0, 90),
    Position = UDim2.new(0.5, -45, 0, 28),
    BackgroundColor3 = Color3.fromRGB(20, 24, 40),
    ZIndex = 3,
})
MakeCorner(AvatarBG, 45)

-- spinning ring
local AvatarRing = MakeFrame(LoaderCard, {
    Size = UDim2.new(0, 102, 0, 102),
    Position = UDim2.new(0.5, -51, 0, 22),
    BackgroundTransparency = 1,
    ZIndex = 3,
})
MakeCorner(AvatarRing, 51)
local RingStroke = MakeStroke(AvatarRing, CONFIG.AccentColor, 2, 0.1)

-- avatar label (emoji fallback)
local AvatarLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(0, 90, 0, 90),
    Position = UDim2.new(0.5, -45, 0, 28),
    Text = "🎮",
    TextSize = 38,
    ZIndex = 4,
})

-- username
local UsernameLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 34),
    Position = UDim2.new(0, 10, 0, 130),
    Text = CONFIG.Username,
    TextSize = 26,
    TextColor3 = CONFIG.TextColor,
    ZIndex = 3,
    Font = Enum.Font.GothamBold,
})

-- handle
local HandleLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 165),
    Text = "@" .. CONFIG.Username:lower(),
    TextSize = 13,
    TextColor3 = Color3.fromRGB(0, 140, 200),
    ZIndex = 3,
    Font = Enum.Font.Code,
})

-- status label
local StatusLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 26),
    Position = UDim2.new(0, 10, 0, 200),
    Text = "SCRIPT LOADING",
    TextSize = 16,
    TextColor3 = Color3.fromRGB(245, 166, 35),
    ZIndex = 3,
    Font = Enum.Font.GothamBold,
})

-- sub text
local SubLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 228),
    Text = LoadingMessages[1],
    TextSize = 12,
    TextColor3 = CONFIG.SubTextColor,
    ZIndex = 3,
    Font = Enum.Font.Code,
})

-- progress bar background
local BarBG = MakeFrame(LoaderCard, {
    Size = UDim2.new(1, -40, 0, 6),
    Position = UDim2.new(0, 20, 0, 262),
    BackgroundColor3 = Color3.fromRGB(30, 34, 50),
    ZIndex = 3,
})
MakeCorner(BarBG, 3)

-- progress bar fill
local BarFill = MakeFrame(BarBG, {
    Size = UDim2.new(0, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = CONFIG.AccentColor,
    ZIndex = 4,
})
MakeCorner(BarFill, 3)
MakeGradient(BarFill, 90, {
    ColorSequenceKeypoint.new(0, CONFIG.AccentColor),
    ColorSequenceKeypoint.new(1, CONFIG.AccentColor2),
})

-- timer label
local TimerLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(0, 80, 0, 20),
    Position = UDim2.new(0, 20, 0, 280),
    Text = "05:00",
    TextSize = 13,
    TextColor3 = CONFIG.SubTextColor,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
    Font = Enum.Font.Code,
})

-- percent label
local PctLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(0, 60, 0, 20),
    Position = UDim2.new(1, -80, 0, 280),
    Text = "0%",
    TextSize = 13,
    TextColor3 = CONFIG.AccentColor,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 3,
    Font = Enum.Font.Code,
})

-- dots
local DotsFrame = MakeFrame(LoaderCard, {
    Size = UDim2.new(0, 60, 0, 12),
    Position = UDim2.new(0.5, -30, 0, 316),
    ZIndex = 3,
})
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = DotsFrame

local Dots = {}
for i = 1, 3 do
    local d = MakeFrame(DotsFrame, {
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = i == 2 and CONFIG.AccentColor or Color3.fromRGB(40, 44, 60),
        ZIndex = 4,
    })
    MakeCorner(d, 4)
    Dots[i] = d
end

-- footer
local FooterLabel = MakeLabel(LoaderCard, {
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 402),
    Text = "zapickle  ·  for educational purposes only",
    TextSize = 11,
    TextColor3 = Color3.fromRGB(50, 55, 75),
    ZIndex = 3,
    Font = Enum.Font.Code,
})

-- // =============================
-- //        SCRIPT PANEL
-- // =============================
local Panel = MakeFrame(Overlay, {
    Size = UDim2.new(0, 360, 0, 440),
    Position = UDim2.new(0.5, -180, 0.5, -220),
    BackgroundColor3 = CONFIG.CardColor,
    BackgroundTransparency = 0,
    ZIndex = 2,
    Visible = false,
})
MakeCorner(Panel, 20)
MakeStroke(Panel, CONFIG.AccentColor, 1, 0.75)

-- panel top glow
local PanelTopLine = MakeFrame(Panel, {
    Size = UDim2.new(0.5, 0, 0, 1),
    Position = UDim2.new(0.25, 0, 0, 0),
    BackgroundColor3 = CONFIG.AccentColor,
    BackgroundTransparency = 0.2,
    ZIndex = 3,
})
MakeGradient(PanelTopLine, 90, {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5, CONFIG.AccentColor),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
})

-- panel header
local PanelHeader = MakeFrame(Panel, {
    Size = UDim2.new(1, 0, 0, 52),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    ZIndex = 3,
})

local HeaderDot = MakeFrame(PanelHeader, {
    Size = UDim2.new(0, 10, 0, 10),
    Position = UDim2.new(0, 20, 0.5, -5),
    BackgroundColor3 = CONFIG.AccentColor,
    ZIndex = 4,
})
MakeCorner(HeaderDot, 5)

local HeaderTitle = MakeLabel(PanelHeader, {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 38, 0, 0),
    Text = "SCRIPT PANEL",
    TextSize = 13,
    TextColor3 = Color3.fromRGB(200, 215, 235),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
    Font = Enum.Font.Code,
})

-- close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -46, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
CloseBtn.BackgroundTransparency = 0.6
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 4
CloseBtn.Parent = PanelHeader
MakeCorner(CloseBtn, 6)
MakeStroke(CloseBtn, Color3.fromRGB(255, 80, 80), 1, 0.65)

CloseBtn.MouseEnter:Connect(function()
    Tween(CloseBtn, {BackgroundTransparency = 0.2}, 0.2)
end)
CloseBtn.MouseLeave:Connect(function()
    Tween(CloseBtn, {BackgroundTransparency = 0.6}, 0.2)
end)
CloseBtn.MouseButton1Click:Connect(function()
    Tween(Panel, {BackgroundTransparency = 1}, 0.3)
    Tween(Overlay, {BackgroundTransparency = 1}, 0.4)
    task.wait(0.4)
    ScreenGui:Destroy()
end)

-- divider under header
local Divider = MakeFrame(Panel, {
    Size = UDim2.new(1, -40, 0, 1),
    Position = UDim2.new(0, 20, 0, 52),
    BackgroundColor3 = CONFIG.AccentColor,
    BackgroundTransparency = 0.85,
    ZIndex = 3,
})

-- section label maker
local function MakeSectionLabel(parent, text, yPos)
    return MakeLabel(parent, {
        Size = UDim2.new(1, -40, 0, 18),
        Position = UDim2.new(0, 20, 0, yPos),
        Text = text,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(0, 130, 180),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Font = Enum.Font.Code,
    })
end

MakeSectionLabel(Panel, "── TRADE MODS", 62)
MakeSectionLabel(Panel, "── VISUALS", 232)

-- toggle row maker
local function MakeToggleRow(parent, labelText, yPos, defaultOn, onToggle)
    local Row = MakeFrame(parent, {
        Size = UDim2.new(1, -2, 0, 52),
        Position = UDim2.new(0, 1, 0, yPos),
        BackgroundColor3 = Color3.fromRGB(18, 21, 34),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })

    -- hover accent bar
    local AccentBar = MakeFrame(Row, {
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = CONFIG.AccentColor,
        BackgroundTransparency = 1,
        ZIndex = 4,
    })
    MakeGradient(AccentBar, 180, {
        ColorSequenceKeypoint.new(0, CONFIG.AccentColor),
        ColorSequenceKeypoint.new(1, CONFIG.AccentColor2),
    })

    -- row label
    local Label = MakeLabel(Row, {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        Text = labelText,
        TextSize = 17,
        TextColor3 = Color3.fromRGB(180, 190, 210),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Font = Enum.Font.GothamSemibold,
    })

    -- on/off text
    local OnOffLabel = MakeLabel(Row, {
        Size = UDim2.new(0, 36, 1, 0),
        Position = UDim2.new(1, -86, 0, 0),
        Text = defaultOn and "ON" or "OFF",
        TextSize = 11,
        TextColor3 = defaultOn and CONFIG.AccentColor or Color3.fromRGB(60, 65, 85),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 4,
        Font = Enum.Font.Code,
    })

    -- toggle background
    local TglBG = MakeFrame(Row, {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -62, 0.5, -12),
        BackgroundColor3 = defaultOn and Color3.fromRGB(0, 50, 80) or Color3.fromRGB(30, 33, 48),
        ZIndex = 4,
    })
    MakeCorner(TglBG, 12)
    MakeStroke(TglBG, defaultOn and CONFIG.AccentColor or Color3.fromRGB(50, 55, 75), 1, defaultOn and 0.4 or 0.7)

    -- toggle knob
    local TglKnob = MakeFrame(TglBG, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = defaultOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = defaultOn and CONFIG.AccentColor or Color3.fromRGB(60, 65, 90),
        ZIndex = 5,
    })
    MakeCorner(TglKnob, 8)

    local isOn = defaultOn

    -- invisible button
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 6
    Btn.Parent = Row

    Btn.MouseEnter:Connect(function()
        Tween(Row, {BackgroundTransparency = 0.85}, 0.2)
        Tween(AccentBar, {BackgroundTransparency = 0}, 0.2)
        Tween(Label, {TextColor3 = Color3.fromRGB(230, 240, 255)}, 0.2)
    end)
    Btn.MouseLeave:Connect(function()
        Tween(Row, {BackgroundTransparency = 1}, 0.2)
        Tween(AccentBar, {BackgroundTransparency = 1}, 0.2)
        Tween(Label, {TextColor3 = Color3.fromRGB(180, 190, 210)}, 0.2)
    end)

    Btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        if isOn then
            Tween(TglKnob, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = CONFIG.AccentColor}, 0.25)
            Tween(TglBG, {BackgroundColor3 = Color3.fromRGB(0, 50, 80)}, 0.25)
            Tween(OnOffLabel, {TextColor3 = CONFIG.AccentColor}, 0.2)
            OnOffLabel.Text = "ON"
        else
            Tween(TglKnob, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(60, 65, 90)}, 0.25)
            Tween(TglBG, {BackgroundColor3 = Color3.fromRGB(30, 33, 48)}, 0.25)
            Tween(OnOffLabel, {TextColor3 = Color3.fromRGB(60, 65, 85)}, 0.2)
            OnOffLabel.Text = "OFF"
        end
        if onToggle then onToggle(isOn) end
    end)

    return Row
end

-- build toggle rows
local toggleDefs = {
    -- label, yPos, defaultOn, stateKey
    {"Freeze Trade",   82,  false, "FreezeTrade"},
    {"Auto Accept",    136, false, "AutoAccept"},
    {"Force Accept",   190, true,  "ForceAccept"},
    {"ESP Players",    252, false, "ESPPlayers"},
    {"Infinite Yield", 306, false, "InfiniteYield"},
    {"God Mode",       360, false, "GodMode"},
}

for _, def in ipairs(toggleDefs) do
    local label, yPos, default, key = def[1], def[2], def[3], def[4]
    MakeToggleRow(Panel, label, yPos, default, function(val)
        State[key] = val
        print("[zapickle] " .. label .. " -> " .. tostring(val))
    end)
end

-- panel footer
MakeLabel(Panel, {
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 416),
    Text = "zapickle  ·  for educational purposes only",
    TextSize = 11,
    TextColor3 = Color3.fromRGB(35, 40, 58),
    ZIndex = 3,
    Font = Enum.Font.Code,
})

-- // =============================
-- //       LOADER LOGIC
-- // =============================
local function PadNum(n)
    return string.format("%02d", math.floor(n))
end

local elapsed = 0
local totalTime = CONFIG.LoadTime

-- animate spinning ring
local ringAngle = 0
RunService.Heartbeat:Connect(function(dt)
    ringAngle = ringAngle + dt * 120
    if ringAngle >= 360 then ringAngle = ringAngle - 360 end
    AvatarRing.Rotation = ringAngle
    -- pulse the header dot on panel
    if Panel.Visible then
        local pulse = 0.5 + 0.5 * math.sin(os.clock() * 3)
        HeaderDot.BackgroundTransparency = 0.1 + pulse * 0.5
    end
end)

-- main loading loop
task.spawn(function()
    while elapsed < totalTime do
        task.wait(1)
        elapsed = elapsed + 1

        local pct = math.floor((elapsed / totalTime) * 100)
        local remaining = totalTime - elapsed
        local mins = math.floor(remaining / 60)
        local secs = remaining % 60

        -- update bar
        Tween(BarFill, {Size = UDim2.new(pct / 100, 0, 1, 0)}, 0.8, Enum.EasingStyle.Linear)

        -- update labels
        TimerLabel.Text = PadNum(mins) .. ":" .. PadNum(secs)
        PctLabel.Text = pct .. "%"

        -- update sub text
        local msgIdx = math.min(math.ceil((elapsed / totalTime) * #LoadingMessages), #LoadingMessages)
        SubLabel.Text = LoadingMessages[msgIdx]

        -- update dots
        for i, d in ipairs(Dots) do
            if i == math.ceil(pct / 34) then
                Tween(d, {BackgroundColor3 = CONFIG.AccentColor}, 0.3)
            else
                Tween(d, {BackgroundColor3 = Color3.fromRGB(40, 44, 60)}, 0.3)
            end
        end

        -- pulse status label
        if elapsed % 2 == 0 then
            Tween(StatusLabel, {TextTransparency = 0.4}, 0.5)
        else
            Tween(StatusLabel, {TextTransparency = 0}, 0.5)
        end
    end

    -- done loading
    StatusLabel.Text = "READY"
    StatusLabel.TextColor3 = CONFIG.AccentColor
    SubLabel.Text = "Script loaded successfully."
    TimerLabel.Text = "00:00"
    PctLabel.Text = "100%"
    Tween(BarFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.5)

    task.wait(0.8)

    -- fade out loader, show panel
    Tween(LoaderCard, {BackgroundTransparency = 1}, 0.5)
    for _, child in ipairs(LoaderCard:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            pcall(function()
                if child:IsA("TextLabel") then
                    Tween(child, {TextTransparency = 1}, 0.4)
                else
                    Tween(child, {BackgroundTransparency = 1}, 0.4)
                end
            end)
        end
    end

    task.wait(0.6)
    LoaderCard.Visible = false

    -- slide in panel
    Panel.Visible = true
    Panel.Position = UDim2.new(0.5, -180, 0.5, -200)
    Panel.BackgroundTransparency = 1
    Tween(Panel, {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -180, 0.5, -220)
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    print("[zapickle] Script panel opened. All systems go.")
end)

print("[zapickle] Loader started. " .. CONFIG.LoadTime .. "s until ready.")
