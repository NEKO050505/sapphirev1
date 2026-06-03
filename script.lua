local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local CoreGui=game:GetService("CoreGui")
local lp=Players.LocalPlayer
local mouse=lp:GetMouse()

local s={en=true,ik=true,sa=true,tb=true,bs=999999,fov=360,rs=true,ar=true,wa=true,ch=true,sh="circle",sz=25,av=true,sk="yellow",un=true}

local skc={white=Color3.new(1,1,1),yellow=Color3.new(1,1,0.6),brown=Color3.new(0.55,0.27,0.07),black=Color3.new(0.2,0.2,0.2),red=Color3.new(1,0.4,0.4),blue=Color3.new(0.4,0.6,1),green=Color3.new(0.4,1,0.4)}

local function kill(t)
    if t and t.Character then
        local h=t.Character:FindFirstChild("Humanoid")
        if h and h.Health>0 then
            h.Health=0
        end
    end
end

local function getClosest()
    local best,bestDist=nil,s.fov
    local center=Vector2.new(mouse.X,mouse.Y)
    for _,v in pairs(Players:GetPlayers()) do
        if v~=lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos,on=workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            if on then
                local dist=(center-Vector2.new(pos.X,pos.Y)).Magnitude
                if dist<bestDist then
                    bestDist=dist
                    best=v
                end
            end
        end
    end
    return best
end

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
