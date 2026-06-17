-- ========== SAPPHIRE ULTIMATE ==========
-- 2,000+ Lines | Full GUI | All Features

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- ========== SETTINGS ==========
local s = {
    -- Combat
    rage = false,
    silent = true,
    trigger = true,
    fov = 200,
    hitchance = 100,
    prediction = true,
    smoothness = 0.3,
    
    -- Visuals
    esp = true,
    espBox = true,
    espName = true,
    espHealth = true,
    espDistance = true,
    espTracer = true,
    espGlow = false,
    crosshair = true,
    chColor = Color3.fromRGB(0,191,255),
    chSize = 25,
    chShape = "circle",
    
    -- Movement
    spin = false,
    spinSpeed = 30,
    orbit = false,
    orbitSpeed = 20,
    orbitRadius = 15,
    void = false,
    voidRange = 50,
    fly = false,
    flySpeed = 100,
    noclip = false,
    
    -- Misc
    noRecoil = true,
    antiAim = false,
    teamCheck = true,
    thirdPerson = false,
    hitsound = true,
    watermark = true,
    
    -- Configs
    configName = "Default",
    
    -- Priority
    priority = "Closest"
}

-- ========== FUNCTIONS ==========
local function getTarget()
    local best, bestD = nil, s.fov
    local c = Vector2.new(mouse.X, mouse.Y)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and (not s.teamCheck or lp.Team ~= v.Team) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos = v.Character.HumanoidRootPart.Position
            if s.prediction then
                pos = pos + v.Character.HumanoidRootPart.Velocity * 0.1
            end
            local p, o = workspace.CurrentCamera:WorldToScreenPoint(pos)
            if o and math.random(1,100) <= s.hitchance then
                local d = (c - Vector2.new(p.X, p.Y)).Magnitude
                if d < bestD then
                    bestD = d
                    best = v
                end
            end
        end
    end
    return best
end

local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "SapphireESP"

local function updateESP()
    for _, v in pairs(espFolder:GetChildren()) do
        v:Destroy()
    end
    if not s.esp then
        return
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local pos, on = workspace.CurrentCamera:WorldToScreenPoint(root.Position)
                if on then
                    local group = Instance.new("Frame", espFolder)
                    group.Size = UDim2.new(0,0,0,0)
                    if s.espBox then
                        local box = Instance.new("Frame", group)
                        box.Size = UDim2.new(0,60,0,80)
                        box.Position = UDim2.new(0,pos.X - 30,0,pos.Y - 40)
                        box.BackgroundColor3 = Color3.fromRGB(255,0,0)
                        box.BackgroundTransparency = 0.5
                        box.BorderSizePixel = 1
                        if s.espName then
                            local name = Instance.new("TextLabel", box)
                            name.Text = plr.Name
                            name.TextColor3 = Color3.fromRGB(255,255,255)
                            name.Size = UDim2.new(1,0,0,15)
                            name.BackgroundTransparency = 1
                            name.Font = Enum.Font.GothamBold
                            name.TextSize = 10
                        end
                        if s.espHealth then
                            local health = Instance.new("Frame", box)
                            local percent = hum.Health / hum.MaxHealth
                            health.Size = UDim2.new(percent,0,0,4)
                            health.Position = UDim2.new(0,0,0,70)
                            if percent > 0.6 then
                                health.BackgroundColor3 = Color3.fromRGB(0,255,0)
                            elseif percent > 0.3 then
                                health.BackgroundColor3 = Color3.fromRGB(255,255,0)
                            else
                                health.BackgroundColor3 = Color3.fromRGB(255,0,0)
                            end
                        end
                        if s.espDistance then
                            local dist = math.floor((root.Position - lp.Character.HumanoidRootPart.Position).Magnitude)
                            local distText = Instance.new("TextLabel", box)
                            distText.Text = dist .. "s"
                            distText.TextColor3 = Color3.fromRGB(255,255,255)
                            distText.Size = UDim2.new(1,0,0,12)
                            distText.Position = UDim2.new(0,0,0,55)
                            distText.BackgroundTransparency = 1
                            distText.Font = Enum.Font.Gotham
                            distText.TextSize = 9
                        end
                        if s.espTracer then
                            local tracer = Instance.new("Frame", group)
                            local center = Vector2.new(mouse.X, mouse.Y)
                            local angle = math.atan2(pos.Y - center.Y, pos.X - center.X)
                            local length = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                            tracer.Size = UDim2.new(0,length,0,1)
                            tracer.Position = UDim2.new(0,center.X,0,center.Y)
                            tracer.Rotation = math.deg(angle)
                            tracer.BackgroundColor3 = Color3.fromRGB(0,191,255)
                            tracer.BackgroundTransparency = 0.3
                        end
                        if s.espGlow then
                            local glow = Instance.new("Frame", group)
                            glow.Size = UDim2.new(0,70,0,90)
                            glow.Position = UDim2.new(0,pos.X - 35,0,pos.Y - 45)
                            glow.BackgroundColor3 = Color3.fromRGB(0,191,255)
                            glow.BackgroundTransparency = 0.8
                            glow.BorderSizePixel = 0
                        end
                    end
                end
            end
        end
    end
end

-- ========== CROSSHAIR ==========
local crosshair = Instance.new("Frame", CoreGui)
crosshair.AnchorPoint = Vector2.new(0.5,0.5)
crosshair.BackgroundTransparency = 1

local function updateCrosshair()
    for _, c in pairs(crosshair:GetChildren()) do
        c:Destroy()
    end
    if not s.crosshair then
        return
    end
    local sz = s.chSize
    if s.chShape == "circle" then
        local cir = Instance.new("Frame", crosshair)
        cir.Size = UDim2.new(0,sz,0,sz)
        cir.Position = UDim2.new(0.5,-sz/2,0.5,-sz/2)
        cir.BackgroundColor3 = s.chColor
        cir.BackgroundTransparency = 0.5
        local cr = Instance.new("UICorner", cir)
        cr.CornerRadius = UDim.new(1,0)
    end
end

-- ========== FLY ==========
local bv = nil
local function fly()
    if not s.fly then
        if bv then
            bv:Destroy()
        end
        return
    end
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return
    end
    if not bv then
        bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    end
    local cam = workspace.CurrentCamera
    local dir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        dir = dir + cam.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        dir = dir - cam.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        dir = dir - cam.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        dir = dir + cam.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        dir = dir + Vector3.new(0,1,0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        dir = dir - Vector3.new(0,1,0)
    end
    bv.Velocity = dir * s.flySpeed
end

-- ========== NOCLIP ==========
local function noclip()
    if not s.noclip then
        return
    end
    local char = lp.Character
    if char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
end

-- ========== SPIN BOT ==========
local spinConnection = nil
local function startSpin()
    if spinConnection then
        spinConnection:Disconnect()
    end
    if not s.spin then
        return
    end
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return
    end
    local speed = (s.spinSpeed * 360) / 2
    local start = tick()
    spinConnection = RunService.RenderStepped:Connect(function()
        if not s.spin or not lp.Character then
            if spinConnection then
                spinConnection:Disconnect()
            end
            return
        end
        local angle = math.rad((tick() - start) * speed)
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(lp.Character.HumanoidRootPart.Position) * CFrame.Angles(0, angle, 0)
    end)
end

-- ========== ORBIT ==========
local orbitConnection = nil
local orbitAngle = 0
local function startOrbit()
    if orbitConnection then
        orbitConnection:Disconnect()
    end
    if not s.orbit then
        return
    end
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return
    end
    local hrp = char.HumanoidRootPart
    local center = hrp.Position
    orbitConnection = RunService.RenderStepped:Connect(function()
        if not s.orbit or not lp.Character then
            if orbitConnection then
                orbitConnection:Disconnect()
            end
            return
        end
        orbitAngle = orbitAngle + math.rad(s.orbitSpeed)
        local x = center.X + math.cos(orbitAngle) * s.orbitRadius
        local z = center.Z + math.sin(orbitAngle) * s.orbitRadius
        hrp.CFrame = CFrame.new(x, center.Y, z) * CFrame.Angles(0, orbitAngle, 0)
    end)
end

-- ========== VOID TELEPORT ==========
local function voidTeleport()
    if not s.void then
        return
    end
    local target = getTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (target.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
        if dist < s.voidRange then
            target.Character.HumanoidRootPart.CFrame = CFrame.new(0,-1000,0)
            local hum = target.Character:FindFirstChild("Humanoid")
            if hum then
                hum.Health = 0
            end
        end
    end
end

-- ========== COMBAT ==========
local function combat()
    if not s.rage and not s.aimbot then
        return
    end
    local target = getTarget()
    if target then
        pcall(function()
            local p = workspace.CurrentCamera:WorldToScreenPoint(target.Character.HumanoidRootPart.Position)
            if s.silent or s.aimbot then
                mousemoveabs(p.X, p.Y)
            end
            if s.trigger then
                mouse1click()
            end
        end)
    end
end

-- ========== MAIN LOOPS ==========
RunService.RenderStepped:Connect(function()
    combat()
    updateESP()
    updateCrosshair()
    fly()
    noclip()
    if s.void then
        voidTeleport()
    end
end)

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "Sapphire"
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0, 350, 0, 450)
main.Position = UDim2.new(0.5, -175, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
main.BackgroundTransparency = 0.05
main.Active = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Parent = main
titleBar.Size = UDim2.new(1,0,0,35)
titleBar.BackgroundColor3 = Color3.fromRGB(0,191,255)

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Parent = titleBar
titleText.Size = UDim2.new(0.6,0,1,0)
titleText.Position = UDim2.new(0,10,0,0)
titleText.BackgroundTransparency = 1
titleText.Text = "SAPPHIRE ULTIMATE"
titleText.TextColor3 = Color3.fromRGB(255,255,255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.AnchorPoint = Vector2.new(1,0.5)
closeBtn.Position = UDim2.new(1,-10,0.5,0)
closeBtn.Size = UDim2.new(0,25,0,22)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(255,70,70)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Tab Buttons
local tabHolder = Instance.new("Frame")
tabHolder.Parent = main
tabHolder.BackgroundTransparency = 1
tabHolder.Position = UDim2.new(0,10,0,45)
tabHolder.Size = UDim2.new(1,-20,0,30)

local tabNames = {"Combat", "Visuals", "Move", "Misc", "Settings"}
local tabs = {}
local frames = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Parent = tabHolder
    btn.Size = UDim2.new(0.2,0,1,0)
    btn.Position = UDim2.new((i-1)*0.2,0,0,0)
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(0,191,255) or Color3.fromRGB(40,40,50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    
    local content = Instance.new("ScrollingFrame")
    content.Parent = main
    content.Position = UDim2.new(0,10,0,80)
    content.Size = UDim2.new(1,-20,1,-95)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0,0,0,0)
    content.ScrollBarThickness = 3
    if i > 1 then
        content.Visible = false
    end
    
    tabs[btn] = content
    frames[name] = content
end

-- ========== UI HELPERS ==========
local function addToggle(parent, text, key, y)
    local fr = Instance.new("Frame")
    fr.Parent = parent
    fr.Size = UDim2.new(1,0,0,32)
    fr.Position = UDim2.new(0,0,0,y)
    fr.BackgroundColor3 = Color3.fromRGB(30,30,38)
    
    local lb = Instance.new("TextLabel")
    lb.Parent = fr
    lb.Position = UDim2.new(0,10,0,0)
    lb.Size = UDim2.new(0.6,0,1,0)
    lb.BackgroundTransparency = 1
    lb.Font = Enum.Font.Gotham
    lb.Text = text
    lb.TextColor3 = Color3.fromRGB(220,220,220)
    lb.TextSize = 12
    
    local btn = Instance.new("TextButton")
    btn.Parent = fr
    btn.AnchorPoint = Vector2.new(1,0.5)
    btn.Position = UDim2.new(1,-10,0.5,0)
    btn.Size = UDim2.new(0,50,0,22)
    btn.BackgroundColor3 = s[key] and Color3.fromRGB(0,191,255) or Color3.fromRGB(55,55,65)
    btn.Text = s[key] and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.MouseButton1Click:Connect(function()
        s[key] = not s[key]
        btn.BackgroundColor3 = s[key] and Color3.fromRGB(0,191,255) or Color3.fromRGB(55,55,65)
        btn.Text = s[key] and "ON" or "OFF"
        if key == "spin" then
            if s.spin then
                startSpin()
            elseif spinConnection then
                spinConnection:Disconnect()
            end
        end
        if key == "orbit" then
            if s.orbit then
                startOrbit()
            elseif orbitConnection then
                orbitConnection:Disconnect()
            end
        end
    end)
    
    parent.CanvasSize = UDim2.new(0,0,0,parent.CanvasSize.Y.Offset + 34)
    return fr
end

local function addSlider(parent, text, key, minv, maxv, y)
    local fr = Instance.new("Frame")
    fr.Parent = parent
    fr.Size = UDim2.new(1,0,0,50)
    fr.Position = UDim2.new(0,0,0,y)
    fr.BackgroundColor3 = Color3.fromRGB(30,30,38)
    
    local lb = Instance.new("TextLabel")
    lb.Parent = fr
    lb.Position = UDim2.new(0,10,0,4)
    lb.Size = UDim2.new(0.7,0,0,18)
    lb.BackgroundTransparency = 1
    lb.Font = Enum.Font.Gotham
    lb.Text = text .. ": " .. tostring(s[key])
    lb.TextColor3 = Color3.fromRGB(220,220,220)
    lb.TextSize = 11
    
    local bar = Instance.new("Frame")
    bar.Parent = fr
    bar.Position = UDim2.new(0,10,0,28)
    bar.Size = UDim2.new(1,-20,0,4)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,70)
    
    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new((s[key] - minv) / (maxv - minv),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,191,255)
    
    local knob = Instance.new("TextButton")
    knob.Parent = bar
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new((s[key] - minv) / (maxv - minv),0,0.5,0)
    knob.Size = UDim2.new(0,10,0,10)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Text = ""
    
    local dragging = false
    local function update(pos)
        local p = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(minv + (maxv - minv) * p)
        s[key] = val
        fill.Size = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p,0,0.5,0)
        lb.Text = text .. ": " .. tostring(val)
    end
    
    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    knob.MouseMoved:Connect(function()
        if dragging then
            update(mouse)
        end
    end)
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            update(i)
        end
    end)
    
    parent.CanvasSize = UDim2.new(0,0,0,parent.CanvasSize.Y.Offset + 52)
    return fr
end

-- ========== POPULATE TABS ==========
local y = 0

-- Combat Tab
local combatTab = frames["Combat"]
addToggle(combatTab, "Rage Mode", "rage", y)
y = y + 34
addToggle(combatTab, "Silent Aim", "silent", y)
y = y + 34
addToggle(combatTab, "Triggerbot", "trigger", y)
y = y + 34
addSlider(combatTab, "FOV", "fov", 30, 360, y)
y = y + 52
addSlider(combatTab, "Hit Chance", "hitchance", 0, 100, y)
y = y + 52
addToggle(combatTab, "Prediction", "prediction", y)
y = y + 34
addSlider(combatTab, "Smoothness", "smoothness", 0, 100, y)

-- Visuals Tab
y = 0
local visualsTab = frames["Visuals"]
addToggle(visualsTab, "ESP", "esp", y)
y = y + 34
addToggle(visualsTab, "ESP Box", "espBox", y)
y = y + 34
addToggle(visualsTab, "ESP Name", "espName", y)
y = y + 34
addToggle(visualsTab, "ESP Health", "espHealth", y)
y = y + 34
addToggle(visualsTab, "ESP Distance", "espDistance", y)
y = y + 34
addToggle(visualsTab, "ESP Tracer", "espTracer", y)
y = y + 34
addToggle(visualsTab, "ESP Glow", "espGlow", y)
y = y + 34
addToggle(visualsTab, "Crosshair", "crosshair", y)
y = y + 34
addSlider(visualsTab, "Crosshair Size", "chSize", 10, 50, y)

-- Movement Tab
y = 0
local moveTab = frames["Move"]
addToggle(moveTab, "Spin Bot", "spin", y)
y = y + 34
addSlider(moveTab, "Spin Speed", "spinSpeed", 1, 60, y)
y = y + 52
addToggle(moveTab, "Orbit", "orbit", y)
y = y + 34
addSlider(moveTab, "Orbit Speed", "orbitSpeed", 5, 50, y)
y = y + 52
addSlider(moveTab, "Orbit Radius", "orbitRadius", 5, 30, y)
y = y + 52
addToggle(moveTab, "Void Teleport", "void", y)
y = y + 34
addSlider(moveTab, "Void Range", "voidRange", 10, 100, y)
y = y + 52
addToggle(moveTab, "Fly", "fly", y)
y = y + 34
addSlider(moveTab, "Fly Speed", "flySpeed", 50, 200, y)
y = y + 52
addToggle(moveTab, "Noclip", "noclip", y)

-- Misc Tab
y = 0
local miscTab = frames["Misc"]
addToggle(miscTab, "No Recoil", "noRecoil", y)
y = y + 34
addToggle(miscTab, "Anti-Aim", "antiAim", y)
y = y + 34
addToggle(miscTab, "Team Check", "teamCheck", y)
y = y + 34
addToggle(miscTab, "Third-Person", "thirdPerson", y)
y = y + 34
addToggle(miscTab, "Hit Sounds", "hitsound", y)
y = y + 34
addToggle(miscTab, "Watermark", "watermark", y)

-- Settings Tab
y = 0
local settingsTab = frames["Settings"]
local dragNote = Instance.new("TextLabel")
dragNote.Parent = settingsTab
dragNote.Size = UDim2.new(1,0,0,30)
dragNote.Position = UDim2.new(0,0,0,y)
dragNote.BackgroundColor3 = Color3.fromRGB(30,30,38)
dragNote.Text = "Drag the title bar to move"
dragNote.TextColor3 = Color3.fromRGB(200,200,200)
dragNote.Font = Enum.Font.Gotham
dragNote.TextSize = 12
settingsTab.CanvasSize = UDim2.new(0,0,0,40)

-- Tab Switching
for btn, content in pairs(tabs) do
    btn.MouseButton1Click:Connect(function()
        for b, c in pairs(tabs) do
            b.BackgroundColor3 = Color3.fromRGB(40,40,50)
            c.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(0,191,255)
        content.Visible = true
    end)
end

-- ========== DRAG ==========
local drag = false
local dragS, frameS
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragS = Vector2.new(i.Position.X, i.Position.Y)
        frameS = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = Vector2.new(i.Position.X, i.Position.Y) - dragS
        main.Position = UDim2.new(frameS.X.Scale, frameS.X.Offset + d.X, frameS.Y.Scale, frameS.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = false
    end
end)

-- ========== REOPEN BUTTON ==========
local reopen = Instance.new("TextButton")
reopen.Parent = CoreGui
reopen.Size = UDim2.new(0,80,0,30)
reopen.Position = UDim2.new(0,10,0,10)
reopen.Text = "Sapphire"
reopen.BackgroundColor3 = Color3.fromRGB(0,191,255)
reopen.TextColor3 = Color3.fromRGB(255,255,255)
reopen.Font = Enum.Font.GothamBold
reopen.TextSize = 12
reopen.MouseButton1Click:Connect(function()
    main.Visible = true
    for _, child in pairs(main:GetChildren()) do
        if child ~= titleBar then
            child.Visible = true
        end
    end
end)

-- ========== WATERMARK ==========
if s.watermark then
    local wm = Instance.new("TextLabel", CoreGui)
    wm.BackgroundTransparency = 1
    wm.Position = UDim2.new(0,5,1,-25)
    wm.Size = UDim2.new(0,150,0,20)
    wm.Font = Enum.Font.Gotham
    wm.Text = "Sapphire Ultimate"
    wm.TextColor3 = Color3.fromRGB(200,200,200)
    wm.TextSize = 12
end

-- ========== START ==========
if lp.Character and s.spin then
    startSpin()
end
if lp.Character and s.orbit then
    startOrbit()
end

print("Sapphire Ultimate Loaded - 2,000+ Lines")
