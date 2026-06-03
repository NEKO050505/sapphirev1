local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local CoreGui=game:GetService("CoreGui")
local lp=Players.LocalPlayer

local s={rage=false,instakill=false,silent=false,trigger=false,backstab=false,unlock=false,esp=false,hitsound=true,watermark=true,range=1000,bs=999999,fov=360}

local function kill(t)
    if t and t.Character then
        local h=t.Character:FindFirstChild("Humanoid")
        if h and h.Health>0 then
            h.Health=0
            if s.hitsound then
                local a=Instance.new("Sound")
                a.SoundId="rbxassetid://9120386546"
                a.Parent=workspace
                a:Play()
                game:GetService("Debris"):AddItem(a,1)
            end
        end
    end
end

local function getClosest()
    local best,bestD=nil,s.fov
    local mouse=lp:GetMouse()
    local center=Vector2.new(mouse.X,mouse.Y)
    for _,v in pairs(Players:GetPlayers()) do
        if v~=lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos,on=workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            if on then
                local d=(center-Vector2.new(pos.X,pos.Y)).Magnitude
                if d<bestD then
                    bestD=d
                    best=v
                end
            end
        end
    end
    return best
end

local function backstabKill()
    if not s.backstab then return end
    local char=lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myPos=char.HumanoidRootPart.Position
    for _,v in pairs(Players:GetPlayers()) do
        if v~=lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local dist=(myPos-v.Character.HumanoidRootPart.Position).Magnitude
            if dist<s.range then
                local h=v.Character:FindFirstChild("Humanoid")
                if h and h.Health>0 then h.Health=0 end
            end
        end
    end
end

local function unlockAll()
    if not s.unlock then return end
    pcall(function()
        for _,v in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if v:IsA("Tool") then v:Clone().Parent=lp.Backpack end
        end
    end)
end

if s.esp then
    local espFolder=Instance.new("Folder",CoreGui)
    espFolder.Name="SapphireESP"
    local function addESP(plr)
        if plr==lp then return end
        local box=Instance.new("Frame",espFolder)
        box.Name=plr.Name
        box.Size=UDim2.new(0,50,0,50)
        box.BackgroundColor3=Color3.fromRGB(255,0,0)
        box.BackgroundTransparency=0.5
        local name=Instance.new("TextLabel",box)
        name.Text=plr.Name
        name.TextColor3=Color3.fromRGB(255,255,255)
        name.Size=UDim2.new(1,0,0,20)
    end
    for _,v in pairs(Players:GetPlayers()) do addESP(v) end
    Players.PlayerAdded:Connect(addESP)
    RunService.RenderStepped:Connect(function()
        for _,v in pairs(Players:GetPlayers()) do
            local e=espFolder:FindFirstChild(v.Name)
            if e and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local p,o=workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                if o then
                    e.Visible=true
                    e.Position=UDim2.new(0,p.X-25,0,p.Y-50)
                else
                    e.Visible=false
                end
            elseif e then
                e.Visible=false
            end
        end
    end)
end

local gui=Instance.new("ScreenGui")
gui.Parent=CoreGui
local f=Instance.new("Frame")
f.Parent=gui
f.Size=UDim2.new(0,240,0,350)
f.Position=UDim2.new(0.5,-120,0.5,-175)
f.BackgroundColor3=Color3.fromRGB(20,20,25)

local function makeBtn(text,y,key)
    local btn=Instance.new("TextButton")
    btn.Parent=f
    btn.Size=UDim2.new(0,220,0,30)
    btn.Position=UDim2.new(0.5,-110,0,y)
    btn.Text=text..": OFF"
    btn.BackgroundColor3=Color3.fromRGB(0,191,255)
    btn.MouseButton1Click:Connect(function()
        s[key]=not s[key]
        btn.Text=text..": "..(s[key] and "ON" or "OFF")
        if key=="unlock" and s.unlock then unlockAll() end
        if key=="esp" and s.esp then
            -- ESP will be created by the if statement at top (run once)
            local espFolder=CoreGui:FindFirstChild("SapphireESP")
            if not espFolder and s.esp then
                local ef=Instance.new("Folder",CoreGui)
                ef.Name="SapphireESP"
                for _,plr in pairs(Players:GetPlayers()) do
                    if plr~=lp then
                        local box=Instance.new("Frame",ef)
                        box.Name=plr.Name
                        box.Size=UDim2.new(0,50,0,50)
                        box.BackgroundColor3=Color3.fromRGB(255,0,0)
                        box.BackgroundTransparency=0.5
                        local nm=Instance.new("TextLabel",box)
                        nm.Text=plr.Name
                        nm.TextColor3=Color3.fromRGB(255,255,255)
                        nm.Size=UDim2.new(1,0,0,20)
                    end
                end
            end
        end
    end)
    return btn
end

makeBtn("Ragebot",10,"rage")
makeBtn("Instant Kill",45,"instakill")
makeBtn("Silent Aim",80,"silent")
makeBtn("Triggerbot",115,"trigger")
makeBtn("Backstab",150,"backstab")
makeBtn("Unlock All",185,"unlock")
makeBtn("ESP",220,"esp")

local hitBtn=makeBtn("Hit Sounds",255,"hitsound")
hitBtn.Text="Hit Sounds: ON"
s.hitsound=true
hitBtn.MouseButton1Click:Connect(function()
    s.hitsound=not s.hitsound
    hitBtn.Text="Hit Sounds: "..(s.hitsound and "ON" or "OFF")
end)

local closeBtn=Instance.new("TextButton")
closeBtn.Parent=f
closeBtn.Size=UDim2.new(0,220,0,30)
closeBtn.Position=UDim2.new(0.5,-110,0,290)
closeBtn.Text="Close UI"
closeBtn.BackgroundColor3=Color3.fromRGB(255,70,70)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

if s.watermark then
    local wm=Instance.new("TextLabel")
    wm.Parent=CoreGui
    wm.BackgroundTransparency=1
    wm.Position=UDim2.new(0,5,1,-25)
    wm.Size=UDim2.new(0,150,0,20)
    wm.Font=Enum.Font.Gotham
    wm.Text="Sapphire"
    wm.TextColor3=Color3.fromRGB(200,200,200)
    wm.TextSize=12
end

local function setBulletSpeed()
    local ch=lp.Character
    if not ch then return end
    for _,t in ipairs(ch:GetChildren()) do
        if t:IsA("Tool") then
            for _,p in ipairs(t:GetDescendants()) do
                if p.Name:lower():find("speed") or p.Name:lower():find("velocity") then
                    pcall(function() p.Value=s.bs end)
                end
            end
        end
    end
end
lp.CharacterAdded:Connect(function() task.wait(0.5) setBulletSpeed() end)
setBulletSpeed()

RunService.RenderStepped:Connect(function()
    if s.rage then
        local target=getClosest()
        if target then
            if s.silent then
                pcall(function()
                    local pos=workspace.CurrentCamera:WorldToScreenPoint(target.Character.HumanoidRootPart.Position)
                    mousemoveabs(pos.X,pos.Y)
                end)
            end
            if s.trigger then
                pcall(mouse1click)
            end
            if s.instakill then
                kill(target)
            end
        end
    end
    if s.backstab then
        backstabKill()
    end
end)

print("Sapphire Ultimate Loaded - All Features")
