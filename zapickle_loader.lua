-- LocalScript dentro de StarterGui

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════
--  BLUR DE FONDO
-- ══════════════════════════
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

-- Animar el blur para que aparezca suavemente
TweenService:Create(Blur,
    TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    { Size = 56 }):Play()

-- ══════════════════════════
--  CONFIGURACIÓN
-- ══════════════════════════
local LOAD_DURATION  = 180   -- 3 minutos: tiempo en que la barra llega al 100%
local TOTAL_DURATION = 1380  -- 23 minutos total (3 carga + 20 espera invisible)

-- ══════════════════════════
--  SCREENGUI
-- ══════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LoadingScreen"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Fondo oscuro
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.fromScale(1, 1)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 5)
Overlay.BackgroundTransparency = 0.3
Overlay.BorderSizePixel = 0
Overlay.Parent = ScreenGui

-- ══════════════════════════
--  CARD
-- ══════════════════════════
local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 300, 0, 320)
Card.AnchorPoint = Vector2.new(0.5, 0.5)
Card.Position = UDim2.fromScale(0.5, 0.5)
Card.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
Card.BorderSizePixel = 0
Card.Parent = ScreenGui

Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 16)

local Stroke = Instance.new("UIStroke", Card)
Stroke.Color = Color3.fromRGB(0, 200, 255)
Stroke.Thickness = 2

-- ══════════════════════════
--  AVATAR
-- ══════════════════════════
local AvatarHolder = Instance.new("Frame")
AvatarHolder.Size = UDim2.new(0, 70, 0, 70)
AvatarHolder.AnchorPoint = Vector2.new(0.5, 0)
AvatarHolder.Position = UDim2.new(0.5, 0, 0, 20)
AvatarHolder.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
AvatarHolder.BorderSizePixel = 0
AvatarHolder.Parent = Card
Instance.new("UICorner", AvatarHolder).CornerRadius = UDim.new(1, 0)

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(1, -4, 1, -4)
AvatarImg.AnchorPoint = Vector2.new(0.5, 0.5)
AvatarImg.Position = UDim2.fromScale(0.5, 0.5)
AvatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
AvatarImg.BorderSizePixel = 0
AvatarImg.Image = ""
AvatarImg.Parent = AvatarHolder
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

-- Cargar avatar
local ok, url = pcall(Players.GetUserThumbnailAsync, Players,
    LocalPlayer.UserId,
    Enum.ThumbnailType.HeadShot,
    Enum.ThumbnailSize.Size420x420)
if ok then AvatarImg.Image = url end

-- ══════════════════════════
--  TEXTOS
-- ══════════════════════════
local function makeLabel(parent, text, font, size, color, posY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.AnchorPoint = Vector2.new(0.5, 0)
    lbl.Position = UDim2.new(0.5, 0, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.Font = font
    lbl.TextSize = size
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Parent = parent
    return lbl
end

local WHITE  = Color3.fromRGB(255, 255, 255)
local GREY   = Color3.fromRGB(150, 155, 175)
local YELLOW = Color3.fromRGB(255, 200, 0)

local NameLbl   = makeLabel(Card, "zapickle",                    Enum.Font.GothamBold, 19, WHITE,  100)
local SubLbl    = makeLabel(Card, "@zapickle",                   Enum.Font.Gotham,     13, GREY,   124)
local TitleLbl  = makeLabel(Card, "SCRIPT LOADING",              Enum.Font.GothamBold, 14, YELLOW, 158)
local StatusLbl = makeLabel(Card, "Loading remote functions...", Enum.Font.Gotham,     12, GREY,   180)

-- ══════════════════════════
--  BARRA DE PROGRESO
-- ══════════════════════════
local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0.88, 0, 0, 8)
BarBG.AnchorPoint = Vector2.new(0.5, 0)
BarBG.Position = UDim2.new(0.5, 0, 0, 210)
BarBG.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
BarBG.BorderSizePixel = 0
BarBG.Parent = Card
Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(30, 130, 255)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBG
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

-- ══════════════════════════
--  TIMER Y PORCENTAJE
-- ══════════════════════════
local TimerLbl = Instance.new("TextLabel")
TimerLbl.Size = UDim2.new(0.5, -10, 0, 18)
TimerLbl.Position = UDim2.new(0, 18, 0, 225)
TimerLbl.BackgroundTransparency = 1
TimerLbl.Text = "05:00"
TimerLbl.TextColor3 = GREY
TimerLbl.Font = Enum.Font.Code
TimerLbl.TextSize = 13
TimerLbl.TextXAlignment = Enum.TextXAlignment.Left
TimerLbl.Parent = Card

local PctLbl = Instance.new("TextLabel")
PctLbl.Size = UDim2.new(0.5, -10, 0, 18)
PctLbl.AnchorPoint = Vector2.new(1, 0)
PctLbl.Position = UDim2.new(1, -18, 0, 225)
PctLbl.BackgroundTransparency = 1
PctLbl.Text = "0%"
PctLbl.TextColor3 = GREY
PctLbl.Font = Enum.Font.Code
PctLbl.TextSize = 13
PctLbl.TextXAlignment = Enum.TextXAlignment.Right
PctLbl.Parent = Card

-- ══════════════════════════
--  DOTS
-- ══════════════════════════
local DotsFrame = Instance.new("Frame")
DotsFrame.Size = UDim2.new(0, 56, 0, 12)
DotsFrame.AnchorPoint = Vector2.new(0.5, 0)
DotsFrame.Position = UDim2.new(0.5, 0, 0, 258)
DotsFrame.BackgroundTransparency = 1
DotsFrame.Parent = Card

local layout = Instance.new("UIListLayout", DotsFrame)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 8)

local BLUE = Color3.fromRGB(30, 130, 255)
local DIM  = Color3.fromRGB(50, 55, 75)
local dots = {}
for i = 1, 3 do
    local d = Instance.new("Frame", DotsFrame)
    d.Size = UDim2.new(0, 10, 0, 10)
    d.BackgroundColor3 = (i == 1) and BLUE or DIM
    d.BorderSizePixel = 0
    Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
    dots[i] = d
end

-- Footer
makeLabel(Card, "zapickle  •  for educational purposes only",
    Enum.Font.Gotham, 10, Color3.fromRGB(70, 75, 100), 290)

-- ══════════════════════════
--  LOOP PRINCIPAL
-- ══════════════════════════
local statusTexts = {
    "Loading remote functions...",
    "Connecting to servers...",
    "Fetching player data...",
    "Initializing modules...",
    "Setting up environment...",
    "Almost ready...",
}

local startTime   = tick()
local activeDot   = 1
local lastDotTime = 0
local lastSubTime = 0
local subIdx      = 1
local done        = false

-- Pulso del borde
TweenService:Create(Stroke,
    TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Transparency = 0.5 }):Play()

game:GetService("RunService").Heartbeat:Connect(function()
    if done then return end

    local elapsed  = tick() - startTime
    local progress = math.clamp(elapsed / LOAD_DURATION, 0, 1)
    local pct      = math.floor(progress * 100)

    -- Barra y porcentaje
    BarFill.Size = UDim2.new(progress, 0, 1, 0)
    PctLbl.Text  = pct .. "%"

    -- Cronómetro regresivo desde 05:00
    local remaining = math.max(0, LOAD_DURATION - elapsed)
    local m = math.floor(remaining / 60)
    local s = math.floor(remaining % 60)
    TimerLbl.Text = string.format("%02d:%02d", m, s)

    -- Rotar subtítulo cada 2s
    if elapsed - lastSubTime >= 2 then
        lastSubTime = elapsed
        subIdx = (subIdx % #statusTexts) + 1
        StatusLbl.Text = statusTexts[subIdx]
    end

    -- Rotar dot activo cada 1.5s
    if elapsed - lastDotTime >= 1.5 then
        lastDotTime = elapsed
        dots[activeDot].BackgroundColor3 = DIM
        activeDot = (activeDot % 3) + 1
        dots[activeDot].BackgroundColor3 = BLUE
    end

    -- Al terminar los 23 minutos: fade out y destruir
    if elapsed >= TOTAL_DURATION then
        done = true
        task.delay(0.3, function()
            local info = TweenInfo.new(0.8, Enum.EasingStyle.Quad)
            TweenService:Create(Card,    info, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(Overlay, info, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(Stroke,  info, { Transparency = 1 }):Play()
            for _, lbl in ipairs({ NameLbl, SubLbl, TitleLbl, StatusLbl, TimerLbl, PctLbl }) do
                TweenService:Create(lbl, info, { TextTransparency = 1 }):Play()
            end
            TweenService:Create(AvatarImg,  info, { ImageTransparency = 1 }):Play()
            TweenService:Create(BarBG,       info, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(BarFill,     info, { BackgroundTransparency = 1 }):Play()
            for _, d in ipairs(dots) do
                TweenService:Create(d, info, { BackgroundTransparency = 1 }):Play()
            end
                -- Quitar el blur al terminar
            TweenService:Create(Blur,
                TweenInfo.new(0.8, Enum.EasingStyle.Quad),
                { Size = 0 }):Play()
        task.delay(1, function()
            Blur:Destroy()
            ScreenGui:Destroy()
        end)
        end)
    end
end)
