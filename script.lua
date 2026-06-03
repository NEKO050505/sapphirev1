local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local CoreGui=game:GetService("CoreGui")
local TweenService=game:GetService("TweenService")
local lp=Players.LocalPlayer
local mouse=lp:GetMouse()

-- Settings (ALL OFF by default)
local s={
    -- Combat
    rage=false,
    instakill=false,
    silent=false,
    trigger=false,
    backstab=false,
    bulletspeed=999999,
    fov=360,
    hitchance=100,
    prediction=true,
    backstabRange=1000,
    
    -- Defense
    shield=true,
    antirage=true,
    wild=false,
    antiAim=true,
    noRecoil=true,
    
    -- Visuals
    crosshair=true,
    chshape="circle",
    chsize=25,
    chcolor=Color3.fromRGB(0,191,255),
    esp=true,
    
    -- Misc
    hitsound=true,
    watermark=true,
    
    -- Settings
    drag=true,
    save=false
}

-- Instant kill
local function kill(t)
    if t and t.Character then
        local h=t.Character:FindFirstChild("Humanoid")
        if h and h.Health>0 then
            h.Health=0
            h:BreakJoints()
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

-- Backstab Rage (1000 range = kills anyone from anywhere)
local function backstabRage()
    if not s.backstab then return end
    local char=lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myPos=char.HumanoidRootPart.Position
    
    for _,v in pairs(Players:GetPlayers()) do
        if v~=lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local theirPos=v.Character.HumanoidRootPart.Position
            local dist=(myPos-theirPos).Magnitude
            if dist<s.backstabRange then
                -- Instant kill regardless of angle at 1000 range
                local hum=v.Character:FindFirstChild("Humanoid")
                if hum and hum.Health>0 then
                    hum.Health=0
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
    end
end

-- Instant backstab at round start (kills all enemies instantly)
local function instantBackstab()
    for _,v in pairs(Players:GetPlayers()) do
        if v~=lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < s.backstabRange then
                local hum=v.Character:FindFirstChild("Humanoid")
                if hum and hum.Health>0 then
                    hum.Health=0
                end
            end
        end
    end
end

-- Get closest target with prediction
local function getTarget()
    local best,bestD=nil,s.fov
    local center=Vector2.new(mouse.X,mouse.Y)
    for _,v in pairs(Players:GetPlayers()) do
        if v~=lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos=v.Character.HumanoidRootPart.Position
            if s.prediction then
                targetPos=targetPos+v.Character.HumanoidRootPart.Velocity*0.1
            end
            local pos,on=workspace.CurrentCamera:WorldToScreenPoint(targetPos)
            if on then
                local d=(center-Vector2.new(pos.X,pos.Y)).Magnitude
                if d<bestD and math.random(1,100)<=s.hitchance then
                    bestD=d
                    best=v
                end
            end
        end
    end
    return best
end

-- ESP
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
        name.BackgroundTransparency=1
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
                    local dist=(lp.Character.HumanoidRootPart.Position-v.Character.HumanoidRootPart.Position).Magnitude
                    if dist<50 then
                        e.BackgroundColor3=Color3.fromRGB(255,0,0)
                    elseif dist<100 then
                        e.BackgroundColor3=Color3.fromRGB(255,165,0)
                    else
                        e.BackgroundColor3=Color3.fromRGB(255,255,0)
                    end
                else
                    e.Visible=false
                end
            elseif e then
                e.Visible=false
            end
        end
    end)
end

-- Anti-Aim
if s.antiAim then
    RunService.RenderStepped:Connect(function()
        local ch=lp.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then
            ch.HumanoidRootPart.CFrame=CFrame.new(ch.HumanoidRootPart.Position)*CFrame.Angles(0,math.rad(tick()*500),0)
        end
    end)
end

-- No Recoil
if s.noRecoil then
    lp.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").CameraOffset=Vector3.new(0,0,0)
    end)
end

-- UI
local gui=Instance.new("ScreenGui")
gui.Name="Sapphire"
gui.ResetOnSpawn=false
gui.Parent=CoreGui

local main=Instance.new("Frame")
main.Parent=gui
main.AnchorPoint=Vector2.new(0.5,0.5)
main.BackgroundColor3=Color3.fromRGB(20,20,25)
main.BorderSizePixel=0
main.ClipsDescendants=true
main.Position=UDim2.new(0.5,0,0.5,0)
main.Size=UDim2.new(0,0,0,0)
main.BackgroundTransparency=1

local shadow=Instance.new("Frame")
shadow.Parent=main
shadow.BackgroundColor3=Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency=0.5
shadow.BorderSizePixel=0
shadow.Position=UDim2.new(-0.02,0,-0.02,0)
shadow.Size=UDim2.new(1.04,0,1.04,0)

local mainCorner=Instance.new("UICorner")
mainCorner.CornerRadius=UDim.new(0,8)
mainCorner.Parent=main

local shadowCorner=Instance.new("UICorner")
shadowCorner.CornerRadius=UDim.new(0,8)
shadowCorner.Parent=shadow

-- Title bar
local titleBar=Instance.new("Frame")
titleBar.Parent=main
titleBar.BackgroundColor3=Color3.fromRGB(30,30,38)
titleBar.BorderSizePixel=0
titleBar.Size=UDim2.new(1,0,0,35)

local titleCorner=Instance.new("UICorner")
titleCorner.CornerRadius=UDim.new(0,8)
titleCorner.Parent=titleBar

local titleText=Instance.new("TextLabel")
titleText.Parent=titleBar
titleText.BackgroundTransparency=1
titleText.Position=UDim2.new(0,12,0,0)
titleText.Size=UDim2.new(0.6,0,1,0)
titleText.Font=Enum.Font.GothamSemibold
titleText.Text="Sapphire"
titleText.TextColor3=Color3.fromRGB(255,255,255)
titleText.TextSize=16
titleText.TextXAlignment=Enum.TextXAlignment.Left

local accentBar=Instance.new("Frame")
accentBar.Parent=titleBar
accentBar.BackgroundColor3=Color3.fromRGB(0,191,255)
accentBar.BorderSizePixel=0
accentBar.Size=UDim2.new(0.3,0,0,2)
accentBar.Position=UDim2.new(0,0,1,-2)

local closeBtn=Instance.new("TextButton")
closeBtn.Parent=titleBar
closeBtn.AnchorPoint=Vector2.new(1,0.5)
closeBtn.Position=UDim2.new(1,-12,0.5,0)
closeBtn.Size=UDim2.new(0,24,0,24)
closeBtn.BackgroundColor3=Color3.fromRGB(255,70,70)
closeBtn.BackgroundTransparency=0.8
closeBtn.Text="✕"
closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.TextSize=14
closeBtn.Font=Enum.Font.GothamBold

local closeCorner=Instance.new("UICorner")
closeCorner.CornerRadius=UDim.new(0,12)
closeCorner.Parent=closeBtn

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Tab buttons
local tabHolder=Instance.new("Frame")
tabHolder.Parent=main
tabHolder.BackgroundTransparency=1
tabHolder.Position=UDim2.new(0,0,0,35)
tabHolder.Size=UDim2.new(1,0,0,32)

local tabs={}
local frames={}
local tabNames={"Combat","Defense","Visuals","Misc","Settings"}

for i,name in ipairs(tabNames) do
    local btn=Instance.new("TextButton")
    btn.Parent=tabHolder
    btn.Size=UDim2.new(1/#tabNames,0,1,0)
    btn.Position=UDim2.new((i-1)/#tabNames,0,0,0)
    btn.BackgroundColor3=Color3.fromRGB(25,25,30)
    btn.BackgroundTransparency=0.5
    btn.Text=name
    btn.TextColor3=name=="Combat" and Color3.fromRGB(0,191,255) or Color3.fromRGB(180,180,190)
    btn.TextSize=13
    btn.Font=Enum.Font.GothamSemibold
    
    local line=Instance.new("Frame")
    line.Parent=btn
    line.BackgroundColor3=Color3.fromRGB(0,191,255)
    line.BorderSizePixel=0
    line.Size=UDim2.new(0.8,0,0,2)
    line.Position=UDim2.new(0.1,0,1,-2)
    line.Visible=name=="Combat"
    
    local content=Instance.new("ScrollingFrame")
    content.Parent=main
    content.Position=UDim2.new(0,8,0,67)
    content.Size=UDim2.new(1,-16,1,-75)
    content.BackgroundTransparency=1
    content.CanvasSize=UDim2.new(0,0,0,0)
    content.ScrollBarThickness=3
    content.ScrollBarImageColor3=Color3.fromRGB(60,60,70)
    content.Visible=name=="Combat"
    
    btn.MouseButton1Click:Connect(function()
        for _,b in pairs(tabs) do
            b.TextColor3=Color3.fromRGB(180,180,190)
            b.BackgroundTransparency=0.5
            if b:FindFirstChild("Line") then b.Line.Visible=false end
        end
        for _,f in pairs(frames) do f.Visible=false end
        btn.TextColor3=Color3.fromRGB(0,191,255)
        btn.BackgroundTransparency=0
        if btn:FindFirstChild("Line") then btn.Line.Visible=true end
        content.Visible=true
    end)
    
    tabs[btn]=content
    frames[name]=content
    btn.Line=line
end

-- UI Helpers
local function addToggle(parent,text,key,y)
    local frame=Instance.new("Frame")
    frame.Parent=parent
    frame.Size=UDim2.new(1,-16,0,34)
    frame.Position=UDim2.new(0,8,0,y)
    frame.BackgroundColor3=Color3.fromRGB(30,30,38)
    frame.BackgroundTransparency=0.3
    
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,6)
    corner.Parent=frame
    
    local label=Instance.new("TextLabel")
    label.Parent=frame
    label.Position=UDim2.new(0,12,0,0)
    label.Size=UDim2.new(0.6,0,1,0)
    label.BackgroundTransparency=1
    label.Font=Enum.Font.Gotham
    label.Text=text
    label.TextColor3=Color3.fromRGB(220,220,220)
    label.TextSize=13
    label.TextXAlignment=Enum.TextXAlignment.Left
    
    local btn=Instance.new("TextButton")
    btn.Parent=frame
    btn.AnchorPoint=Vector2.new(1,0.5)
    btn.Position=UDim2.new(1,-12,0.5,0)
    btn.Size=UDim2.new(0,50,0,24)
    btn.BackgroundColor3=s[key] and Color3.fromRGB(0,191,255) or Color3.fromRGB(55,55,65)
    btn.Text=s[key] and "ON" or "OFF"
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=11
    
    local btnCorner=Instance.new("UICorner")
    btnCorner.CornerRadius=UDim.new(0,4)
    btnCorner.Parent=btn
    
    btn.MouseButton1Click:Connect(function()
        s[key]=not s[key]
        btn.BackgroundColor3=s[key] and Color3.fromRGB(0,191,255) or Color3.fromRGB(55,55,65)
        btn.Text=s[key] and "ON" or "OFF"
        if key=="esp" and s.esp==false then
            local f=CoreGui:FindFirstChild("SapphireESP")
            if f then f:Destroy() end
        end
        if key=="backstab" and s.backstab then
            instantBackstab()
        end
    end)
    
    parent.CanvasSize=UDim2.new(0,0,0,parent.CanvasSize.Y.Offset+38)
    return frame
end

local function addSlider(parent,text,key,minv,maxv,y)
    local frame=Instance.new("Frame")
    frame.Parent=parent
    frame.Size=UDim2.new(1,-16,0,52)
    frame.Position=UDim2.new(0,8,0,y)
    frame.BackgroundColor3=Color3.fromRGB(30,30,38)
    frame.BackgroundTransparency=0.3
    
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,6)
    corner.Parent=frame
    
    local label=Instance.new("TextLabel")
    label.Parent=frame
    label.Position=UDim2.new(0,12,0,6)
    label.Size=UDim2.new(0.7,0,0,18)
    label.BackgroundTransparency=1
    label.Font=Enum.Font.Gotham
    label.Text=text..": "..tostring(s[key])
    label.TextColor3=Color3.fromRGB(220,220,220)
    label.TextSize=12
    label.TextXAlignment=Enum.TextXAlignment.Left
    
    local bar=Instance.new("Frame")
    bar.Parent=frame
    bar.Position=UDim2.new(0,12,0,30)
    bar.Size=UDim2.new(1,-24,0,4)
    bar.BackgroundColor3=Color3.fromRGB(50,50,60)
    
    local fill=Instance.new("Frame")
    fill.Parent=bar
    fill.Size=UDim2.new((s[key]-minv)/(maxv-minv),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,191,255)
    
    local knob=Instance.new("TextButton")
    knob.Parent=bar
    knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new((s[key]-minv)/(maxv-minv),0,0.5,0)
    knob.Size=UDim2.new(0,12,0,12)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.Text=""
    
    local knobCorner=Instance.new("UICorner")
    knobCorner.CornerRadius=UDim.new(1,0)
    knobCorner.Parent=knob
    
    local dragging=false
    knob.MouseButton1Down:Connect(function() dragging=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    knob.MouseMoved:Connect(function()
        if dragging then
            local pos=math.clamp((mouse.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local val=math.floor(minv+(maxv-minv)*pos)
            s[key]=val
            fill.Size=UDim2.new(pos,0,1,0)
            knob.Position=UDim2.new(pos,0,0.5,0)
            label.Text=text..": "..tostring(val)
        end
    end)
    
    parent.CanvasSize=UDim2.new(0,0,0,parent.CanvasSize.Y.Offset+56)
    return frame
end

local function addDropdown(parent,text,key,opts,y)
    local frame=Instance.new("Frame")
    frame.Parent=parent
    frame.Size=UDim2.new(1,-16,0,40)
    frame.Position=UDim2.new(0,8,0,y)
    frame.BackgroundColor3=Color3.fromRGB(30,30,38)
    frame.BackgroundTransparency=0.3
    frame.ZIndex=2
    
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,6)
    corner.Parent=frame
    
    local label=Instance.new("TextLabel")
    label.Parent=frame
    label.Position=UDim2.new(0,12,0,0)
    label.Size=UDim2.new(0.5,0,1,0)
    label.BackgroundTransparency=1
    label.Font=Enum.Font.Gotham
    label.Text=text
    label.TextColor3=Color3.fromRGB(220,220,220)
    label.TextSize=12
    label.TextXAlignment=Enum.TextXAlignment.Left
    
    local btn=Instance.new("TextButton")
    btn.Parent=frame
    btn.Position=UDim2.new(0.55,0,0.5,-12)
    btn.Size=UDim2.new(0.4,0,0,24)
    btn.BackgroundColor3=Color3.fromRGB(55,55,65)
    btn.Text=tostring(s[key])
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.Gotham
    btn.TextSize=12
    btn.ZIndex=3
    
    local btnCorner=Instance.new("UICorner")
    btnCorner.CornerRadius=UDim.new(0,4)
    btnCorner.Parent=btn
    
    local list=Instance.new("Frame")
    list.Parent=frame
    list.Position=UDim2.new(0.55,0,0.95,0)
    list.Size=UDim2.new(0.4,0,0,0)
    list.BackgroundColor3=Color3.fromRGB(40,40,48)
    list.Visible=false
    list.ClipsDescendants=true
    list.ZIndex=4
    
    local listCorner=Instance.new("UICorner")
    listCorner.CornerRadius=UDim.new(0,4)
    listCorner.Parent=list
    
    local layout=Instance.new("UIListLayout")
    layout.Parent=list
    layout.Padding=UDim.new(0,2)
    
    for _,opt in ipairs(opts) do
        local b=Instance.new("TextButton")
        b.Parent=list
        b.Size=UDim2.new(1,0,0,28)
        b.BackgroundColor3=Color3.fromRGB(50,50,60)
        b.Text=opt
        b.TextColor3=Color3.fromRGB(255,255,255)
        b.Font=Enum.Font.Gotham
        b.TextSize=11
        b.ZIndex=5
        
        local bCorner=Instance.new("UICorner")
        bCorner.CornerRadius=UDim.new(0,3)
        bCorner.Parent=b
        
        b.MouseButton1Click:Connect(function()
            s[key]=opt
            btn.Text=opt
            list.Visible=false
            list.Size=UDim2.new(0.4,0,0,0)
            if text=="Crosshair Shape" then
                updateCrosshair()
            end
        end)
    end
    
    btn.MouseButton1Click:Connect(function()
        if list.Visible then
            list.Visible=false
            list:TweenSize(UDim2.new(0.4,0,0,0),"Out","Quad",0.15)
        else
            list.Visible=true
            local h=#opts*30
            list:TweenSize(UDim2.new(0.4,0,0,h),"Out","Quad",0.15)
        end
    end)
    
    parent.CanvasSize=UDim2.new(0,0,0,parent.CanvasSize.Y.Offset+44)
    return frame
end

-- Populate tabs
local y=0

-- Combat Tab
local combatFrame=frames.Combat
combatFrame.CanvasSize=UDim2.new(0,0,0,10)
addToggle(combatFrame,"Ragebot","rage",y); y=y+38
addToggle(combatFrame,"Instant Kill","instakill",y); y=y+38
addToggle(combatFrame,"Silent Aim","silent",y); y=y+38
addToggle(combatFrame,"Triggerbot","trigger",y); y=y+38
addToggle(combatFrame,"Backstab Rage","backstab",y); y=y+38
addSlider(combatFrame,"Backstab Range","backstabRange",5,1000,y); y=y+56
addSlider(combatFrame,"Bullet Speed","bulletspeed",1000,999999,y); y=y+56
addSlider(combatFrame,"Aim FOV","fov",30,360,y); y=y+56
addSlider(combatFrame,"Hit Chance","hitchance",0,100,y); y=y+56
addToggle(combatFrame,"Prediction","prediction",y); y=y+38

-- Defense Tab
y=0
local defenseFrame=frames.Defense
defenseFrame.CanvasSize=UDim2.new(0,0,0,10)
addToggle(defenseFrame,"Rye Shield","shield",y); y=y+38
addToggle(defenseFrame,"Anti-Ragebot","antirage",y); y=y+38
addToggle(defenseFrame,"Wild Animations","wild",y); y=y+38
addToggle(defenseFrame,"Anti-Aim","antiAim",y); y=y+38
addToggle(defenseFrame,"No Recoil","noRecoil",y); y=y+38

-- Visuals Tab
y=0
local visualsFrame=frames.Visuals
visualsFrame.CanvasSize=UDim2.new(0,0,0,10)
addToggle(visualsFrame,"Crosshair","crosshair",y); y=y+38
addDropdown(visualsFrame,"Crosshair Shape","chshape",{"circle","star"},y); y=y+44
addSlider(visualsFrame,"Crosshair Size","chsize",10,50,y); y=y+56
addToggle(visualsFrame,"ESP","esp",y); y=y+38

-- Misc Tab
y=0
local miscFrame=frames.Misc
miscFrame.CanvasSize=UDim2.new(0,0,0,10)
addToggle(miscFrame,"Hit Sounds","hitsound",y); y=y+38
addToggle(miscFrame,"Watermark","watermark",y); y=y+38

-- Settings Tab
y=0
local settingsFrame=frames.Settings
settingsFrame.CanvasSize=UDim2.new(0,0,0,10)
addToggle(settingsFrame,"Draggable UI","drag",y); y=y+38
addToggle(settingsFrame,"Save Settings","save",y); y=y+38

-- Animate window open
main:TweenSize(UDim2.new(0,420,0,520),"Out","Back",0.3,true)
main.BackgroundTransparency=0
TweenService:Create(main,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
TweenService:Create(shadow,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0.4}):Play()

-- Dragging
if s.drag then
    local dragStart,dragFrameStart,dragging=false
    titleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true
            dragStart=Vector2.new(i.Position.X,i.Position.Y)
            dragFrameStart=main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local delta=Vector2.new(i.Position.X,i.Position.Y)-dragStart
            main.Position=UDim2.new(dragFrameStart.X.Scale,dragFrameStart.X.Offset+delta.X,dragFrameStart.Y.Scale,dragFrameStart.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
end

-- Crosshair
local crosshair=Instance.new("Frame")
crosshair.Parent=CoreGui
crosshair.AnchorPoint=Vector2.new(0.5,0.5)
crosshair.BackgroundTransparency=1
crosshair.ZIndex=999

local function updateCrosshair()
    for _,c in pairs(crosshair:GetChildren()) do c:Destroy() end
    if not s.crosshair then return end
    local sz=s.chsize
    if s.chshape=="circle" then
        local cir=Instance.new("Frame")
        cir.Parent=crosshair
        cir.Size=UDim2.new(0,sz,0,sz)
        cir.Position=UDim2.new(0.5,-sz/2,0.5,-sz/2)
        cir.BackgroundColor3=s.chcolor
        cir.BackgroundTransparency=0.4
        cir.BorderSizePixel=0
        local inn=Instance.new("Frame")
        inn.Parent=cir
        inn.Size=UDim2.new(0.4,0,0.4,0)
        inn.Position=UDim2.new(0.3,0,0.3,0)
        inn.BackgroundColor3=s.chcolor
        inn.BorderSizePixel=0
        local cr=Instance.new("UICorner")
        cr.CornerRadius=UDim.new(1,0)
        cr.Parent=cir
        local ic=Instance.new("UICorner")
        ic.CornerRadius=UDim.new(1,0)
        ic.Parent=inn
    else
        for i=1,5 do
            local ang=(i*72-90)*math.pi/180
            local iang=((i*72)-90+36)*math.pi/180
            local x2=math.cos(iang)*(sz*0.4)
            local y2=math.sin(iang)*(sz*0.4)
            local line=Instance.new("Frame")
            line.Parent=crosshair
            line.Size=UDim2.new(0,2,0,2)
            line.BackgroundColor3=s.chcolor
            line.BackgroundTransparency=0.2
            line.Position=UDim2.new(0.5,x2,0.5,y2)
            local lc=Instance.new("UICorner")
            lc.CornerRadius=UDim.new(1,0)
            lc.Parent=line
        end
    end
end

spawn(function()
    while true do
        updateCrosshair()
        task.wait(0.1)
    end
end)

-- Combat Loops
RunService.RenderStepped:Connect(function()
    if s.rage then
        local target=getTarget()
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
        backstabRage()
    end
end)

-- Rye Shield
if s.shield then
    workspace.DescendantAdded:Connect(function(d)
        if d:IsA("Part") and (d.Name:lower():find("bullet") or d.Name:lower():find("proj")) then
            pcall(function()
                local shooter=d:FindFirstChild("Creator")
                if shooter and shooter.Value then kill(shooter.Value) end
                d:Destroy()
            end)
        end
    end)
end

-- Anti-Ragebot
local shotCounts={}
if s.antirage then
    RunService.RenderStepped:Connect(function()
        for _,v in pairs(Players:GetPlayers()) do
            if v~=lp then
                shotCounts[v]=(shotCounts[v]or 0)+1
                if shotCounts[v]>30 then kill(v) end
            end
        end
        task.wait(1)
        for k in pairs(shotCounts) do shotCounts[k]=0 end
    end)
end

-- Wild Animations
if s.wild then
    RunService.RenderStepped:Connect(function()
        local ch=lp.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then
            local hrp=ch.HumanoidRootPart
            hrp.CFrame=hrp.CFrame+Vector3.new(math.sin(tick()*50)*2,math.abs(math.sin(tick()*30))*1,math.cos(tick()*50)*2)
        end
    end)
end

-- Bullet Speed
local function setBulletSpeed()
    local ch=lp.Character
    if not ch then return end
    for _,t in ipairs(ch:GetChildren()) do
        if t:IsA("Tool") then
            for _,p in ipairs(t:GetDescendants()) do
                if p.Name:lower():find("speed") or p.Name:lower():find("velocity") then
                    pcall(function() p.Value=s.bulletspeed end)
                end
            end
        end
    end
end
lp.CharacterAdded:Connect(function() task.wait(0.5) setBulletSpeed() end)
setBulletSpeed()

-- Watermark
if s.watermark then
    local wm=Instance.new("TextLabel")
    wm.Parent=CoreGui
    wm.BackgroundTransparency=1
    wm.Position=UDim2.new(0,5,1,-25)
    wm.Size=UDim2.new(0,150,0,20)
    wm.Font=Enum.Font.Gotham
    wm.Text="Sapphire | Backstab Range 1000"
    wm.TextColor3=Color3.fromRGB(200,200,200)
    wm.TextSize=12
    wm.TextXAlignment=Enum.TextXAlignment.Left
end

-- Instant backstab on character spawn
lp.CharacterAdded:Connect(function()
    task.wait(0.5)
    if s.backstab then
        instantBackstab()
    end
end)

print("Sapphire Loaded - Backstab Range 1000 (Kills anywhere)")end

local function applyAvatar()
    if not s.av then return end
    pcall(function()
        local ch=lp.Character
        if ch then
            for _,pt in pairs(ch:GetDescendants()) do
                if pt:IsA("BasePart") and not pt.Name:find("Humanoid") then
                    pt.Color=skc[s.sk]
                end
            end
        end
    end)
end

local gui=Instance.new("ScreenGui")
gui.Name="Sapphire"
gui.Parent=CoreGui

local main=Instance.new("Frame")
main.Parent=gui
main.AnchorPoint=Vector2.new(0.5,0.5)
main.Position=UDim2.new(0.5,0,0.5,0)
main.Size=UDim2.new(0,450,0,500)
main.BackgroundColor3=Color3.fromRGB(20,20,25)

local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,10)
corner.Parent=main

local titleBar=Instance.new("Frame")
titleBar.Parent=main
titleBar.Size=UDim2.new(1,0,0,35)
titleBar.BackgroundColor3=Color3.fromRGB(0,191,255)

local titleCorner=Instance.new("UICorner")
titleCorner.CornerRadius=UDim.new(0,10)
titleCorner.Parent=titleBar

local title=Instance.new("TextLabel")
title.Parent=titleBar
title.BackgroundTransparency=1
title.Position=UDim2.new(0,15,0,0)
title.Size=UDim2.new(0.8,0,1,0)
title.Font=Enum.Font.GothamBold
title.Text="Sapphire Ultimate - 5 Tabs"
title.TextColor3=Color3.fromRGB(255,255,255)
title.TextSize=16

local close=Instance.new("TextButton")
close.Parent=titleBar
close.AnchorPoint=Vector2.new(1,0.5)
close.Position=UDim2.new(1,-15,0.5,0)
close.Size=UDim2.new(0,25,0,25)
close.BackgroundColor3=Color3.fromRGB(255,70,70)
close.Text="X"
close.TextColor3=Color3.fromRGB(255,255,255)
close.Font=Enum.Font.GothamBold
close.TextSize=14
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local tabHolder=Instance.new("Frame")
tabHolder.Parent=main
tabHolder.BackgroundTransparency=1
tabHolder.Position=UDim2.new(0,10,0,45)
tabHolder.Size=UDim2.new(1,-20,0,30)

local tabs={}
local contents={}
local tabNames={"Combat","Defense","Visuals","Avatar","Unlocks"}

for i,name in ipairs(tabNames) do
    local btn=Instance.new("TextButton")
    btn.Parent=tabHolder
    btn.Size=UDim2.new(0,80,1,0)
    btn.Position=UDim2.new((i-1)*0.2,2,0,0)
    btn.BackgroundColor3=i==1 and Color3.fromRGB(0,191,255) or Color3.fromRGB(40,40,50)
    btn.Text=name
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=11

    local content=Instance.new("ScrollingFrame")
    content.Parent=main
    content.Position=UDim2.new(0,10,0,85)
    content.Size=UDim2.new(1,-20,1,-100)
    content.BackgroundTransparency=1
    content.CanvasSize=UDim2.new(0,0,0,400)
    content.ScrollBarThickness=3
    if i>1 then content.Visible=false end

    tabs[btn]=content
    contents[name]=content
end

local function toggle(parent,txt,key,y)
    local fr=Instance.new("Frame")
    fr.Parent=parent
    fr.Size=UDim2.new(1,-20,0,35)
    fr.Position=UDim2.new(0,10,0,y)
    fr.BackgroundColor3=Color3.fromRGB(30,30,38)

    local lb=Instance.new("TextLabel")
    lb.Parent=fr
    lb.Position=UDim2.new(0,10,0,0)
    lb.Size=UDim2.new(0.6,0,1,0)
    lb.BackgroundTransparency=1
    lb.Font=Enum.Font.Gotham
    lb.Text=txt
    lb.TextColor3=Color3.fromRGB(220,220,220)
    lb.TextSize=14
    lb.TextXAlignment=Enum.TextXAlignment.Left

    local btn=Instance.new("TextButton")
    btn.Parent=fr
    btn.AnchorPoint=Vector2.new(1,0.5)
    btn.Position=UDim2.new(1,-10,0.5,0)
    btn.Size=UDim2.new(0,60,0,25)
    btn.BackgroundColor3=s[key] and Color3.fromRGB(0,191,255) or Color3.fromRGB(60,60,70)
    btn.Text=s[key] and "ON" or "OFF"
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=12

    btn.MouseButton1Click:Connect(function()
        s[key]=not s[key]
        btn.BackgroundColor3=s[key] and Color3.fromRGB(0,191,255) or Color3.fromRGB(60,60,70)
        btn.Text=s[key] and "ON" or "OFF"
        if key=="av" then applyAvatar() end
        if key=="un" and s.un then
            pcall(function()
                for _,v in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
                    if v:IsA("Tool") then v:Clone().Parent=lp.Backpack end
                end
            end)
        end
    end)
end

local function slider(parent,txt,key,minv,maxv,y)
    local fr=Instance.new("Frame")
    fr.Parent=parent
    fr.Size=UDim2.new(1,-20,0,55)
    fr.Position=UDim2.new(0,10,0,y)
    fr.BackgroundColor3=Color3.fromRGB(30,30,38)

    local lb=Instance.new("TextLabel")
    lb.Parent=fr
    lb.Position=UDim2.new(0,10,0,5)
    lb.Size=UDim2.new(0.7,0,0,20)
    lb.BackgroundTransparency=1
    lb.Font=Enum.Font.Gotham
    lb.Text=txt..": "..tostring(s[key])
    lb.TextColor3=Color3.fromRGB(220,220,220)
    lb.TextSize=13

    local bar=Instance.new("Frame")
    bar.Parent=fr
    bar.Position=UDim2.new(0,10,0,32)
    bar.Size=UDim2.new(1,-20,0,6)
    bar.BackgroundColor3=Color3.fromRGB(60,60,70)

    local fill=Instance.new("Frame")
    fill.Parent=bar
    fill.Size=UDim2.new((s[key]-minv)/(maxv-minv),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,191,255)

    local knob=Instance.new("TextButton")
    knob.Parent=bar
    knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new((s[key]-minv)/(maxv-minv),0,0.5,0)
    knob.Size=UDim2.new(0,14,0,14)
    knob.BackgroundColor3=Color3.fromRGB(0,191,255)
    knob.Text=""

    local dragging=false
    knob.MouseButton1Down:Connect(function()
        dragging=true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
        end
    end)
    knob.MouseMoved:Connect(function()
        if dragging then
            local pos=math.clamp((mouse.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local val=math.floor(minv+(maxv-minv)*pos)
            s[key]=val
            fill.Size=UDim2.new(pos,0,1,0)
            knob.Position=UDim2.new(pos,0,0.5,0)
            lb.Text=txt..": "..tostring(val)
        end
    end)
end

local function dropdown(parent,txt,key,opts,vals,y)
    local fr=Instance.new("Frame")
    fr.Parent=parent
    fr.Size=UDim2.new(1,-20,0,40)
    fr.Position=UDim2.new(0,10,0,y)
    fr.BackgroundColor3=Color3.fromRGB(30,30,38)

    local lb=Instance.new("TextLabel")
    lb.Parent=fr
    lb.Position=UDim2.new(0,10,0,0)
    lb.Size=UDim2.new(0.5,0,1,0)
    lb.BackgroundTransparency=1
    lb.Font=Enum.Font.Gotham
    lb.Text=txt
    lb.TextColor3=Color3.fromRGB(220,220,220)
    lb.TextSize=13

    local btn=Instance.new("TextButton")
    btn.Parent=fr
    btn.Position=UDim2.new(0.55,0,0.1,0)
    btn.Size=UDim2.new(0.4,0,0.8,0)
    btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    btn.Text=tostring(s[key])
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.Gotham
    btn.TextSize=12

    local list=Instance.new("Frame")
    list.Parent=fr
    list.Position=UDim2.new(0.55,0,0.9,0)
    list.Size=UDim2.new(0.4,0,0,0)
    list.BackgroundColor3=Color3.fromRGB(40,40,48)
    list.Visible=false
    list.ClipsDescendants=true

    local layout=Instance.new("UIListLayout")
    layout.Parent=list
    layout.Padding=UDim.new(0,2)

    for i,opt in ipairs(opts) do
        local b=Instance.new("TextButton")
        b.Parent=list
        b.Size=UDim2.new(1,0,0,25)
        b.BackgroundColor3=Color3.fromRGB(50,50,60)
        b.Text=opt
        b.TextColor3=Color3.fromRGB(255,255,255)
        b.Font=Enum.Font.Gotham
        b.TextSize=11
        b.MouseButton1Click:Connect(function()
            s[key]=vals[i]
            btn.Text=opt
            list.Visible=false
            list.Size=UDim2.new(0.4,0,0,0)
            if key=="sk" then applyAvatar() end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        if list.Visible then
            list.Visible=false
            list:TweenSize(UDim2.new(0.4,0,0,0),"Out","Quad",0.2)
        else
            list.Visible=true
            local h=#opts*27
            list:TweenSize(UDim2.new(0.4,0,0,h),"Out","Quad",0.2)
        end
    end)
end

local function button(parent,txt,cb,y)
    local fr=Instance.new("Frame")
    fr.Parent=parent
    fr.Size=UDim2.new(1,-20,0,35)
    fr.Position=UDim2.new(0,10,0,y)
    fr.BackgroundColor3=Color3.fromRGB(30,30,38)

    local btn=Instance.new("TextButton")
    btn.Parent=fr
    btn.Size=UDim2.new(1,-20,1,-6)
    btn.Position=UDim2.new(0,10,0,3)
    btn.BackgroundColor3=Color3.fromRGB(0,191,255)
    btn.Text=txt
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=13
    btn.MouseButton1Click:Connect(cb)
end

-- Combat Tab
toggle(contents.Combat,"Ragebot","en",5)
toggle(contents.Combat,"Instant Kill","ik",45)
toggle(contents.Combat,"Silent Aim","sa",85)
toggle(contents.Combat,"Triggerbot","tb",125)
slider(contents.Combat,"Bullet Speed","bs",1000,999999,165)
slider(contents.Combat,"FOV","fov",30,360,230)

-- Defense Tab
toggle(contents.Defense,"Rye Shield","rs",5)
toggle(contents.Defense,"Anti-Ragebot","ar",45)
toggle(contents.Defense,"Wild Animations","wa",85)

-- Visuals Tab
toggle(contents.Visuals,"Crosshair","ch",5)
dropdown(contents.Visuals,"Crosshair Shape","sh",{"circle","star"},{"circle","star"},45)
slider(contents.Visuals,"Crosshair Size","sz",10,50,95)

-- Avatar Tab
toggle(contents.Avatar,"Avatar Changer","av",5)
dropdown(contents.Avatar,"Skin Color","sk",{"white","yellow","brown","black","red","blue","green"},{"white","yellow","brown","black","red","blue","green"},45)
button(contents.Avatar,"Apply Avatar",applyAvatar,90)

-- Unlocks Tab
toggle(contents.Unlocks,"Unlock All","un",5)
button(contents.Unlocks,"Unlock Now",function()
    pcall(function()
        for _,v in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if v:IsA("Tool") then v:Clone().Parent=lp.Backpack end
        end
    end)
end,45)

-- Tab switching
for btn,content in pairs(tabs) do
    btn.MouseButton1Click:Connect(function()
        for b,c in pairs(tabs) do
            b.BackgroundColor3=Color3.fromRGB(40,40,50)
            c.Visible=false
        end
        btn.BackgroundColor3=Color3.fromRGB(0,191,255)
        content.Visible=true
    end)
end

-- Dragging
local dragging=false
local dragStart,frameStart
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true
        dragStart=Vector2.new(input.Position.X,input.Position.Y)
        frameStart=main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart
        main.Position=UDim2.new(frameStart.X.Scale,frameStart.X.Offset+delta.X,frameStart.Y.Scale,frameStart.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=false
    end
end)

-- Crosshair
local crosshair=Instance.new("Frame")
crosshair.Parent=CoreGui
crosshair.AnchorPoint=Vector2.new(0.5,0.5)
crosshair.BackgroundTransparency=1

local function updateCrosshair()
    for _,child in pairs(crosshair:GetChildren()) do
        child:Destroy()
    end
    if not s.ch then return end
    local sz=s.sz
    if s.sh=="circle" then
        local cir=Instance.new("Frame")
        cir.Parent=crosshair
        cir.Size=UDim2.new(0,sz,0,sz)
        cir.Position=UDim2.new(0.5,-sz/2,0.5,-sz/2)
        cir.BackgroundColor3=Color3.fromRGB(0,191,255)
        cir.BackgroundTransparency=0.5
        local inn=Instance.new("Frame")
        inn.Parent=cir
        inn.Size=UDim2.new(0.5,0,0.5,0)
        inn.Position=UDim2.new(0.25,0,0.25,0)
        inn.BackgroundColor3=Color3.fromRGB(0,191,255)
    else
        for i=1,5 do
            local ang=(i*72-90)*math.pi/180
            local iang=((i*72)-90+36)*math.pi/180
            local x2=math.cos(iang)*(sz*0.4)
            local y2=math.sin(iang)*(sz*0.4)
            local line=Instance.new("Frame")
            line.Parent=crosshair
            line.Size=UDim2.new(0,2,0,2)
            line.BackgroundColor3=Color3.fromRGB(0,191,255)
            line.BackgroundTransparency=0.3
            line.Position=UDim2.new(0.5,x2,0.5,y2)
        end
    end
end

spawn(function()
    while true do
        updateCrosshair()
        task.wait(0.1)
    end
end)

-- Combat loop
RunService.RenderStepped:Connect(function()
    if not s.en then return end
    local target=getClosest()
    if target then
        if s.sa then
            pcall(function()
                local pos=workspace.CurrentCamera:WorldToScreenPoint(target.Character.HumanoidRootPart.Position)
                mousemoveabs(pos.X,pos.Y)
            end)
        end
        if s.tb then
            pcall(mouse1click)
        end
        if s.ik then
            kill(target)
        end
    end
end)

-- Rye Shield
if s.rs then
    workspace.DescendantAdded:Connect(function(d)
        if d:IsA("Part") and (d.Name:lower():find("bullet") or d.Name:lower():find("proj")) then
            pcall(function()
                local sh=d:FindFirstChild("Creator")
                if sh and sh.Value then kill(sh.Value) end
                d:Destroy()
            end)
        end
    end)
end

-- Anti-Ragebot
local shots={}
if s.ar then
    RunService.RenderStepped:Connect(function()
        for _,v in pairs(Players:GetPlayers()) do
            if v~=lp then
                shots[v]=(shots[v]or 0)+1
                if shots[v]>30 then kill(v) end
            end
        end
        task.wait(1)
        for k in pairs(shots) do shots[k]=0 end
    end)
end

-- Wild Animations
if s.wa then
    RunService.RenderStepped:Connect(function()
        local ch=lp.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then
            local hrp=ch.HumanoidRootPart
            hrp.CFrame=hrp.CFrame+Vector3.new(math.sin(tick()*50)*2,math.abs(math.sin(tick()*30))*1,math.cos(tick()*50)*2)
        end
    end)
end

-- Bullet Speed
local function setBS()
    local ch=lp.Character
    if not ch then return end
    for _,t in ipairs(ch:GetChildren()) do
        if t:IsA("Tool") then
            for _,pr in ipairs(t:GetDescendants()) do
                if pr.Name:lower():find("speed") or pr.Name:lower():find("velocity") then
                    pcall(function() pr.Value=s.bs end)
                end
            end
        end
    end
end
lp.CharacterAdded:Connect(function() task.wait(0.5) setBS() end)
setBS()

applyAvatar()

print("Sapphire 5-Tabs Loaded: Combat, Defense, Visuals, Avatar, Unlocks")local gui=Instance.new("ScreenGui")
gui.Name="Sapphire"
gui.Parent=CoreGui

local main=Instance.new("Frame")
main.Parent=gui
main.AnchorPoint=Vector2.new(0.5,0.5)
main.Position=UDim2.new(0.5,0,0.5,0)
main.Size=UDim2.new(0,400,0,450)
main.BackgroundColor3=Color3.fromRGB(20,20,25)

local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,10)
corner.Parent=main

local titleBar=Instance.new("Frame")
titleBar.Parent=main
titleBar.Size=UDim2.new(1,0,0,35)
titleBar.BackgroundColor3=Color3.fromRGB(0,191,255)

local titleCorner=Instance.new("UICorner")
titleCorner.CornerRadius=UDim.new(0,10)
titleCorner.Parent=titleBar

local title=Instance.new("TextLabel")
title.Parent=titleBar
title.BackgroundTransparency=1
title.Position=UDim2.new(0,15,0,0)
title.Size=UDim2.new(0.8,0,1,0)
title.Font=Enum.Font.GothamBold
title.Text="Sapphire Ultimate"
title.TextColor3=Color3.fromRGB(255,255,255)
title.TextSize=16

local close=Instance.new("TextButton")
close.Parent=titleBar
close.AnchorPoint=Vector2.new(1,0.5)
close.Position=UDim2.new(1,-15,0.5,0)
close.Size=UDim2.new(0,25,0,25)
close.BackgroundColor3=Color3.fromRGB(255,70,70)
close.Text="X"
close.TextColor3=Color3.fromRGB(255,255,255)
close.Font=Enum.Font.GothamBold
close.TextSize=14
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local tabHolder=Instance.new("Frame")
tabHolder.Parent=main
tabHolder.BackgroundTransparency=1
tabHolder.Position=UDim2.new(0,10,0,45)
tabHolder.Size=UDim2.new(1,-20,0,30)

local tabs={}
local contents={}
local tabNames={"Combat","Visuals"}

for i,name in ipairs(tabNames) do
    local btn=Instance.new("TextButton")
    btn.Parent=tabHolder
    btn.Size=UDim2.new(0,100,1,0)
    btn.Position=UDim2.new((i-1)*0.5,2,0,0)
    btn.BackgroundColor3=i==1 and Color3.fromRGB(0,191,255) or Color3.fromRGB(40,40,50)
    btn.Text=name
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=14
    
    local content=Instance.new("ScrollingFrame")
    content.Parent=main
    content.Position=UDim2.new(0,10,0,85)
    content.Size=UDim2.new(1,-20,1,-100)
    content.BackgroundTransparency=1
    content.CanvasSize=UDim2.new(0,0,0,300)
    content.ScrollBarThickness=3
    if i>1 then content.Visible=false end
    
    tabs[btn]=content
    contents[name]=content
end

local function toggle(parent,txt,key,y)
    local fr=Instance.new("Frame")
    fr.Parent=parent
    fr.Size=UDim2.new(1,-20,0,35)
    fr.Position=UDim2.new(0,10,0,y)
    fr.BackgroundColor3=Color3.fromRGB(30,30,38)
    
    local lb=Instance.new("TextLabel")
    lb.Parent=fr
    lb.Position=UDim2.new(0,10,0,0)
    lb.Size=UDim2.new(0.6,0,1,0)
    lb.BackgroundTransparency=1
    lb.Font=Enum.Font.Gotham
    lb.Text=txt
    lb.TextColor3=Color3.fromRGB(220,220,220)
    lb.TextSize=14
    lb.TextXAlignment=Enum.TextXAlignment.Left
    
    local btn=Instance.new("TextButton")
    btn.Parent=fr
    btn.AnchorPoint=Vector2.new(1,0.5)
    btn.Position=UDim2.new(1,-10,0.5,0)
    btn.Size=UDim2.new(0,60,0,25)
    btn.BackgroundColor3=s[key] and Color3.fromRGB(0,191,255) or Color3.fromRGB(60,60,70)
    btn.Text=s[key] and "ON" or "OFF"
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=12
    
    btn.MouseButton1Click:Connect(function()
        s[key]=not s[key]
        btn.BackgroundColor3=s[key] and Color3.fromRGB(0,191,255) or Color3.fromRGB(60,60,70)
        btn.Text=s[key] and "ON" or "OFF"
    end)
end

local function slider(parent,txt,key,minv,maxv,y)
    local fr=Instance.new("Frame")
    fr.Parent=parent
    fr.Size=UDim2.new(1,-20,0,55)
    fr.Position=UDim2.new(0,10,0,y)
    fr.BackgroundColor3=Color3.fromRGB(30,30,38)
    
    local lb=Instance.new("TextLabel")
    lb.Parent=fr
    lb.Position=UDim2.new(0,10,0,5)
    lb.Size=UDim2.new(0.7,0,0,20)
    lb.BackgroundTransparency=1
    lb.Font=Enum.Font.Gotham
    lb.Text=txt..": "..tostring(s[key])
    lb.TextColor3=Color3.fromRGB(220,220,220)
    lb.TextSize=13
    
    local bar=Instance.new("Frame")
    bar.Parent=fr
    bar.Position=UDim2.new(0,10,0,32)
    bar.Size=UDim2.new(1,-20,0,6)
    bar.BackgroundColor3=Color3.fromRGB(60,60,70)
    
    local fill=Instance.new("Frame")
    fill.Parent=bar
    fill.Size=UDim2.new((s[key]-minv)/(maxv-minv),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,191,255)
    
    local knob=Instance.new("TextButton")
    knob.Parent=bar
    knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new((s[key]-minv)/(maxv-minv),0,0.5,0)
    knob.Size=UDim2.new(0,14,0,14)
    knob.BackgroundColor3=Color3.fromRGB(0,191,255)
    knob.Text=""
    
    local dragging=false
    knob.MouseButton1Down:Connect(function()
        dragging=true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
        end
    end)
    knob.MouseMoved:Connect(function()
        if dragging then
            local pos=math.clamp((mouse.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local val=math.floor(minv+(maxv-minv)*pos)
            s[key]=val
            fill.Size=UDim2.new(pos,0,1,0)
            knob.Position=UDim2.new(pos,0,0.5,0)
            lb.Text=txt..": "..tostring(val)
        end
    end)
end

local function dropdown(parent,txt,key,opts,y)
    local fr=Instance.new("Frame")
    fr.Parent=parent
    fr.Size=UDim2.new(1,-20,0,40)
    fr.Position=UDim2.new(0,10,0,y)
    fr.BackgroundColor3=Color3.fromRGB(30,30,38)
    
    local lb=Instance.new("TextLabel")
    lb.Parent=fr
    lb.Position=UDim2.new(0,10,0,0)
    lb.Size=UDim2.new(0.5,0,1,0)
    lb.BackgroundTransparency=1
    lb.Font=Enum.Font.Gotham
    lb.Text=txt
    lb.TextColor3=Color3.fromRGB(220,220,220)
    lb.TextSize=13
    
    local btn=Instance.new("TextButton")
    btn.Parent=fr
    btn.Position=UDim2.new(0.55,0,0.1,0)
    btn.Size=UDim2.new(0.4,0,0.8,0)
    btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    btn.Text=tostring(s[key])
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.Gotham
    btn.TextSize=12
    
    local list=Instance.new("Frame")
    list.Parent=fr
    list.Position=UDim2.new(0.55,0,0.9,0)
    list.Size=UDim2.new(0.4,0,0,0)
    list.BackgroundColor3=Color3.fromRGB(40,40,48)
    list.Visible=false
    list.ClipsDescendants=true
    
    local layout=Instance.new("UIListLayout")
    layout.Parent=list
    layout.Padding=UDim.new(0,2)
    
    for _,opt in ipairs(opts) do
        local b=Instance.new("TextButton")
        b.Parent=list
        b.Size=UDim2.new(1,0,0,25)
        b.BackgroundColor3=Color3.fromRGB(50,50,60)
        b.Text=opt
        b.TextColor3=Color3.fromRGB(255,255,255)
        b.Font=Enum.Font.Gotham
        b.TextSize=11
        b.MouseButton1Click:Connect(function()
            s[key]=opt
            btn.Text=opt
            list.Visible=false
            list.Size=UDim2.new(0.4,0,0,0)
        end)
    end
    
    btn.MouseButton1Click:Connect(function()
        if list.Visible then
            list.Visible=false
            list:TweenSize(UDim2.new(0.4,0,0,0),"Out","Quad",0.2)
        else
            list.Visible=true
            local h=#opts*27
            list:TweenSize(UDim2.new(0.4,0,0,h),"Out","Quad",0.2)
        end
    end)
end

-- Combat Tab
toggle(contents.Combat,"Ragebot","en",5)
toggle(contents.Combat,"Instant Kill","ik",45)
toggle(contents.Combat,"Silent Aim","sa",85)
toggle(contents.Combat,"Triggerbot","tb",125)
slider(contents.Combat,"Bullet Speed","bs",1000,999999,165)
slider(contents.Combat,"FOV","fov",30,360,230)

-- Visuals Tab
toggle(contents.Visuals,"Crosshair","ch",5)
dropdown(contents.Visuals,"Crosshair Shape","sh",{"circle","star"},45)
slider(contents.Visuals,"Crosshair Size","sz",10,50,95)

-- Tab switching
for btn,content in pairs(tabs) do
    btn.MouseButton1Click:Connect(function()
        for b,c in pairs(tabs) do
            b.BackgroundColor3=Color3.fromRGB(40,40,50)
            c.Visible=false
        end
        btn.BackgroundColor3=Color3.fromRGB(0,191,255)
        content.Visible=true
    end)
end

-- Dragging
local dragging=false
local dragStart,frameStart
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true
        dragStart=Vector2.new(input.Position.X,input.Position.Y)
        frameStart=main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=Vector2.new(input.Position.X,input.Position.Y)-dragStart
        main.Position=UDim2.new(frameStart.X.Scale,frameStart.X.Offset+delta.X,frameStart.Y.Scale,frameStart.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=false
    end
end)

-- Crosshair
local crosshair=Instance.new("Frame")
crosshair.Parent=CoreGui
crosshair.AnchorPoint=Vector2.new(0.5,0.5)
crosshair.BackgroundTransparency=1

local function updateCrosshair()
    for _,child in pairs(crosshair:GetChildren()) do
        child:Destroy()
    end
    if not s.ch then return end
    local sz=s.sz
    if s.sh=="circle" then
        local cir=Instance.new("Frame")
        cir.Parent=crosshair
        cir.Size=UDim2.new(0,sz,0,sz)
        cir.Position=UDim2.new(0.5,-sz/2,0.5,-sz/2)
        cir.BackgroundColor3=Color3.fromRGB(0,191,255)
        cir.BackgroundTransparency=0.5
        local inn=Instance.new("Frame")
        inn.Parent=cir
        inn.Size=UDim2.new(0.5,0,0.5,0)
        inn.Position=UDim2.new(0.25,0,0.25,0)
        inn.BackgroundColor3=Color3.fromRGB(0,191,255)
    else
        for i=1,5 do
            local ang=(i*72-90)*math.pi/180
            local iang=((i*72)-90+36)*math.pi/180
            local x2=math.cos(iang)*(sz*0.4)
            local y2=math.sin(iang)*(sz*0.4)
            local line=Instance.new("Frame")
            line.Parent=crosshair
            line.Size=UDim2.new(0,2,0,2)
            line.BackgroundColor3=Color3.fromRGB(0,191,255)
            line.BackgroundTransparency=0.3
            line.Position=UDim2.new(0.5,x2,0.5,y2)
        end
    end
end

spawn(function()
    while true do
        updateCrosshair()
        task.wait(0.1)
    end
end)

-- Combat loop
RunService.RenderStepped:Connect(function()
    if not s.en then return end
    local target=getClosest()
    if target then
        if s.sa then
            pcall(function()
                local pos=workspace.CurrentCamera:WorldToScreenPoint(target.Character.HumanoidRootPart.Position)
                mousemoveabs(pos.X,pos.Y)
            end)
        end
        if s.tb then
            pcall(mouse1click)
        end
        if s.ik then
            kill(target)
        end
    end
end)

print("Sapphire 5-Tab Loaded")
