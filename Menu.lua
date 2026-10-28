local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local guiParent = CoreGui or LP:WaitForChild("PlayerGui")

local Theme = {
    Bg = Color3.fromRGB(15, 15, 20),
    Panel = Color3.fromRGB(25, 25, 32),
    Accent = Color3.fromRGB(138, 43, 226),
    Text = Color3.fromRGB(255, 255, 255),
    Dim = Color3.fromRGB(140, 140, 150)
}

local Config = {
    Panic = false, Ghost = false,
    Aim = false, AimWall = true, AimTeam = true, AimFOV = 150, AimSmooth = 0.35, AimPred = false,
    Silent = false, SilentFOV = 150, SilentDelay = 0.15, SilentHit = 100,
    Trigger = false, TrigFOV = 30, TrigDelay = 0.15,
    ESP = true, ESPBox = true, ESPName = true, ESPHP = true, ESPTracer = false, ESPChams = true,
    FOVCircle = true, Fullbright = false, RemoveUI = false, AntiTela = true,
    Speed = false, SpeedVal = 30, Jump = false, JumpVal = 80, Noclip = false, Fly = false, FlySpeed = 50,
    GodMode = false, InfJump = false, AntiAFK = true
}

local hasDraw = pcall(function() return Drawing.new("Square") end)
local fovCircle = hasDraw and Drawing.new("Circle") or nil
if fovCircle then fovCircle.Thickness = 1.5; fovCircle.NumSides = 30; fovCircle.Visible = false end
local espData = {}

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "Definitive_" .. math.random(10000, 99999)
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.DisplayOrder = 999999
MainGui.Parent = guiParent

local function Tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- ==========================================
-- MENU PRINCIPAL COM ANIMAÇÃO
-- ==========================================
local MenuFrame = Instance.new("Frame")
MenuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MenuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MenuFrame.Size = UDim2.new(0, 280, 0, 380)
MenuFrame.BackgroundColor3 = Theme.Bg
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.ZIndex = 500
MenuFrame.Parent = MainGui
Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", MenuFrame)
stroke.Color = Theme.Panel

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Panel
TopBar.ZIndex = 501
TopBar.Parent = MenuFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "D' RAÇA DEFINITIVE"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 502
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.ZIndex = 502
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- BOTÃO FLUTUANTE
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 60, 0, 40)
MenuBtn.Position = UDim2.new(0, 20, 0.2, 0)
MenuBtn.BackgroundColor3 = Theme.Bg
MenuBtn.Text = "MENU"
MenuBtn.TextColor3 = Theme.Accent
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 12
MenuBtn.ZIndex = 999
MenuBtn.Visible = false
MenuBtn.Parent = MainGui
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 8)
local menuStroke = Instance.new("UIStroke", MenuBtn)
menuStroke.Color = Theme.Accent

-- SISTEMA DE ABAS
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 45)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 501
TabBar.Parent = MenuFrame
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -20, 1, -85)
Pages.Position = UDim2.new(0, 10, 0, 80)
Pages.BackgroundTransparency = 1
Pages.ZIndex = 501
Pages.Parent = MenuFrame

local function CreatePage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.fromScale(1, 1)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 2
    p.ScrollBarImageColor3 = Theme.Accent
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.ZIndex = 502
    p.Parent = Pages
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, 5)
    return p
end

local PageAim = CreatePage()
local PageVis = CreatePage()
local PagePlayer = CreatePage()
local PageMisc = CreatePage()

local function CreateTabButton(name, page)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 62, 1, 0)
    b.BackgroundColor3 = Theme.Panel
    b.Text = name
    b.TextColor3 = Theme.Dim
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.ZIndex = 502
    b.Parent = TabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, child in ipairs(Pages:GetChildren()) do if child:IsA("ScrollingFrame") then child.Visible = false end end
            for _, child in ipairs(TabBar:GetChildren()) do if child:IsA("TextButton") then child.TextColor3 = Theme.Dim; child.BackgroundColor3 = Theme.Panel end end
            page.Visible = true
            b.TextColor3 = Theme.Text
            b.BackgroundColor3 = Theme.Accent
        end
    end)
    return b
end

CreateTabButton("Aimbot", PageAim)
CreateTabButton("Visual", PageVis)
CreateTabButton("Player", PagePlayer)
CreateTabButton("Misc", PageMisc)
PageAim.Visible = true
TabBar:GetChildren()[1].TextColor3 = Theme.Text
TabBar:GetChildren()[1].BackgroundColor3 = Theme.Accent

local AllToggles = {}
local function AddToggle(parent, text, default, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Theme.Panel
    b.Text = "  " .. text .. ": " .. (default and "ON" or "OFF")
    b.TextColor3 = default and Theme.Accent or Theme.Dim
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.ZIndex = 503
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local state = default
    local data = { btn = b, text = text, state = state, cb = cb }
    table.insert(AllToggles, data)
    
    b.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            data.state = state
            b.Text = "  " .. text .. ": " .. (state and "ON" or "OFF")
            b.TextColor3 = state and Theme.Accent or Theme.Dim
            if cb then cb(state) end
        end
    end)
end

local function AddSlider(parent, text, min, max, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 40)
    f.BackgroundColor3 = Theme.Panel
    f.ZIndex = 503
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 15)
    l.Position = UDim2.new(0, 10, 0, 5)
    l.BackgroundTransparency = 1
    l.Text = text .. ": " .. default
    l.TextColor3 = Theme.Text
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 504
    l.Parent = f
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 4)
    bar.Position = UDim2.new(0, 10, 1, -10)
    bar.BackgroundColor3 = Theme.Bg
    bar.ZIndex = 504
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.ZIndex = 504
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local drag = false
    local function update(x)
        local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + a * (max - min) + 0.5)
        fill.Size = UDim2.new(a, 0, 1, 0)
        l.Text = text .. ": " .. val
        if cb then cb(val) end
    end
    bar.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then 
            drag = true; update(i.Position.X)
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end 
    end)
    UIS.InputChanged:Connect(function(i) 
        if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then update(i.Position.X) end 
    end)
end

local function DisableAll()
    Config.Panic = true
    for _, t in ipairs(AllToggles) do 
        t.state = false
        t.btn.Text = "  " .. t.text .. ": OFF"
        t.btn.TextColor3 = Theme.Dim
        if t.cb then pcall(t.cb, false) end 
    end
    if fovCircle then fovCircle.Visible = false end
    for p, data in pairs(espData) do for _, v in pairs(data) do v:Remove() end end
    espData = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then 
            local hl = p.Character:FindFirstChild("DRacaESP")
            if hl then hl:Destroy() end 
        end
    end
    MenuFrame.Visible = false
    MenuBtn.Visible = false
    Config.Panic = false
end

local function SetGhost(state)
    Config.Ghost = state
    if state then
        MenuBtn.TextTransparency = 1
        MenuBtn.BackgroundTransparency = 1
        menuStroke.Transparency = 1
    else
        MenuBtn.TextTransparency = 0
        MenuBtn.BackgroundTransparency = 0
        menuStroke.Transparency = 0
    end
end

-- FUNÇÕES
AddToggle(PageAim, "Aimbot Master", Config.Aim, function(v) Config.Aim = v end)
AddToggle(PageAim, "Wall Check", Config.AimWall, function(v) Config.AimWall = v end)
AddToggle(PageAim, "Team Check", Config.AimTeam, function(v) Config.AimTeam = v end)
AddToggle(PageAim, "Prediction", Config.AimPred, function(v) Config.AimPred = v end)
AddSlider(PageAim, "Aimbot FOV", 20, 500, Config.AimFOV, function(v) Config.AimFOV = v end)
AddSlider(PageAim, "Aimbot Smooth", 10, 100, Config.AimSmooth * 100, function(v) Config.AimSmooth = v / 100 end)
AddToggle(PageAim, "Silent Aim", Config.Silent, function(v) Config.Silent = v end)
AddSlider(PageAim, "Silent FOV", 20, 500, Config.SilentFOV, function(v) Config.SilentFOV = v end)
AddSlider(PageAim, "Silent Delay", 50, 500, Config.SilentDelay * 1000, function(v) Config.SilentDelay = v / 1000 end)
AddToggle(PageAim, "Trigger Bot", Config.Trigger, function(v) Config.Trigger = v end)
AddSlider(PageAim, "Trigger FOV", 5, 100, Config.TrigFOV, function(v) Config.TrigFOV = v end)

AddToggle(PageVis, "ESP Master", Config.ESP, function(v) Config.ESP = v end)
AddToggle(PageVis, "ESP Box", Config.ESPBox, function(v) Config.ESPBox = v end)
AddToggle(PageVis, "ESP Name", Config.ESPName, function(v) Config.ESPName = v end)
AddToggle(PageVis, "ESP HP", Config.ESPHP, function(v) Config.ESPHP = v end)
AddToggle(PageVis, "ESP Chams", Config.ESPChams, function(v) Config.ESPChams = v end)
AddToggle(PageVis, "FOV Circle", Config.FOVCircle, function(v) Config.FOVCircle = v end)
AddToggle(PageVis, "Fullbright", Config.Fullbright, function(v) Config.Fullbright = v end)

AddToggle(PagePlayer, "Speed Hack", Config.Speed, function(v) Config.Speed = v end)
AddSlider(PagePlayer, "Speed Valor", 16, 150, Config.SpeedVal, function(v) Config.SpeedVal = v end)
AddToggle(PagePlayer, "Jump Power", Config.Jump, function(v) Config.Jump = v end)
AddSlider(PagePlayer, "Jump Valor", 50, 300, Config.JumpVal, function(v) Config.JumpVal = v end)
AddToggle(PagePlayer, "Noclip", Config.Noclip, function(v) Config.Noclip = v end)
AddToggle(PagePlayer, "Fly", Config.Fly, function(v) Config.Fly = v end)
AddSlider(PagePlayer, "Fly Speed", 20, 150, Config.FlySpeed, function(v) Config.FlySpeed = v end)
AddToggle(PagePlayer, "God Mode", Config.GodMode, function(v) Config.GodMode = v end)
AddToggle(PagePlayer, "Infinite Jump", Config.InfJump, function(v) Config.InfJump = v end)

AddToggle(PageMisc, "Anti-AFK", Config.AntiAFK, function(v) Config.AntiAFK = v end)
AddToggle(PageMisc, "Modo Fantasma", Config.Ghost, function(v) SetGhost(v) end)
AddToggle(PageMisc, "PANIC / BYPASS", false, function(v) if v then DisableAll() end end)

-- BOTÕES
MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        MenuFrame.Visible = true
        MenuBtn.Visible = false
        MenuFrame.Size = UDim2.new(0, 250, 0, 350)
        Tween(MenuFrame, 0.3, {Size = UDim2.new(0, 280, 0, 380)}, Enum.EasingStyle.Back)
    end
end)

CloseBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        Tween(MenuFrame, 0.2, {Size = UDim2.new(0, 250, 0, 350)})
        task.wait(0.2)
        MenuFrame.Visible = false
        MenuBtn.Visible = true
    end
end)

local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MenuFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MenuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- KEY SYSTEM (OFUSCADO)
-- ==========================================
local LoginFrame = Instance.new("Frame")
LoginFrame.AnchorPoint = Vector2.new(0.5, 0.5)
LoginFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
LoginFrame.Size = UDim2.new(0, 260, 0, 170)
LoginFrame.BackgroundColor3 = Theme.Bg
LoginFrame.BorderSizePixel = 0
LoginFrame.Visible = true
LoginFrame.ZIndex = 1000
LoginFrame.Parent = MainGui
Instance.new("UICorner", LoginFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", LoginFrame).Color = Theme.Accent

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Size = UDim2.new(1, 0, 0, 40)
LoginTitle.BackgroundColor3 = Theme.Accent
LoginTitle.Text = "D' RAÇA PREMIUM"
LoginTitle.TextColor3 = Theme.Text
LoginTitle.Font = Enum.Font.GothamBold
LoginTitle.TextSize = 13
LoginTitle.ZIndex = 1001
LoginTitle.Parent = LoginFrame
Instance.new("UICorner", LoginTitle).CornerRadius = UDim.new(0, 10)

local PassBox = Instance.new("TextBox")
PassBox.Size = UDim2.new(0.85, 0, 0, 38)
PassBox.Position = UDim2.new(0.075, 0, 0.35, 0)
PassBox.BackgroundColor3 = Theme.Panel
PassBox.PlaceholderText = "Insira sua Key ou MASTER..."
PassBox.TextColor3 = Theme.Text
PassBox.Font = Enum.Font.Code
PassBox.TextSize = 14
PassBox.ZIndex = 1001
PassBox.Parent = LoginFrame
Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0, 6)

local LoginBtn = Instance.new("TextButton")
LoginBtn.Size = UDim2.new(0.85, 0, 0, 38)
LoginBtn.Position = UDim2.new(0.075, 0, 0.7, 0)
LoginBtn.BackgroundColor3 = Theme.Accent
LoginBtn.Text = "Validar Acesso"
LoginBtn.TextColor3 = Theme.Text
LoginBtn.Font = Enum.Font.GothamBold
LoginBtn.TextSize = 14
LoginBtn.ZIndex = 1001
LoginBtn.Parent = LoginFrame
Instance.new("UICorner", LoginBtn).CornerRadius = UDim.new(0, 6)

local _0xK = "txt.syek/1fdedd2befbfb89e41545faa6d4d0b5693bc0e0b3/war/cde3d9fc2c63b846d86a407480cde77e/lzxxis/moc.tnetnocrebuhgit.sitsg//:sptth"
local _0xM = string.char(77, 65, 83, 84, 69, 82)

local function _0xL()
    local _0xI = string.gsub(PassBox.Text, "^%s*(.-)%s*$", "%1")
    if _0xI == "" then return end
    LoginBtn.Text = "Verificando..."
    LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
    
    local _0xS, _0xR = pcall(function() return game:HttpGet(string.reverse(_0xK)) end)
    
    if _0xS and _0xR then
        if string.find(string.lower(_0xR), string.lower(_0xI), 1, true) then
            LoginBtn.Text = "ACESSO LIBERADO"
            LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            task.wait(0.5)
            LoginFrame:Destroy()
            MenuBtn.Visible = true
        else
            LoginBtn.Text = "Key Invalida"
            LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            task.wait(1.5)
            LoginBtn.Text = "Validar Acesso"
            LoginBtn.BackgroundColor3 = Theme.Accent
        end
    else
        if _0xI == _0xM then
            LoginBtn.Text = "MODO OFFLINE"
            LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            task.wait(0.5)
            LoginFrame:Destroy()
            MenuBtn.Visible = true
        else
            LoginBtn.Text = "Erro de Rede (Tente MASTER)"
            LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            task.wait(2)
            LoginBtn.Text = "Validar Acesso"
            LoginBtn.BackgroundColor3 = Theme.Accent
        end
    end
end

LoginBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        _0xL()
    end
end)

-- ==========================================
-- LOOPS DE JOGO
-- ==========================================
LP.Idled:Connect(function()
    if Config.AntiAFK then
        pcall(function() game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0)) end)
    end
end)

local lastSilent, lastTrigger = 0, 0
local function IsEnemy(p)
    if p == LP or not p.Character then return false end
    if Config.AimTeam and p.Team and LP.Team and p.TeamColor == LP.TeamColor then return false end
    return true
end

local function GetTarget(fovLimit)
    local best, bDist = nil, fovLimit
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if IsEnemy(p) then
            local hum = p.Character:FindFirstChildWhichIsA("Humanoid")
            local head = p.Character:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                local sp, on = Camera:WorldToViewportPoint(head.Position)
                if on then
                    local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist < bDist then
                        if Config.AimWall then
                            local ray = Ray.new(Camera.CFrame.Position, head.Position - Camera.CFrame.Position)
                            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {Camera, LP.Character})
                            if hit and not hit:IsDescendantOf(p.Character) then continue end
                        end
                        bDist = dist; best = head
                    end
                end
            end
        end
    end
    return bes
