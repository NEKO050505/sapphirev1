-- ========== SAPPHIRE MAX (Third-Person OFF) ==========
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local CoreGui=game:GetService("CoreGui")
local UserInputService=game:GetService("UserInputService")
local lp=Players.LocalPlayer
local mouse=lp:GetMouse()

local s={
    aimbot=true, silent=true, trigger=true, fov=200, smooth=0.3, hitchance=100, prediction=true,
    esp=true, espBox=true, espName=true, espHealth=true, espDistance=true, espTracer=true, espGlow=false,
    crosshair=true, chColor=Color3.fromRGB(0,191,255), chSize=25, chShape="circle",
    spin=false, spinSpeed=30, orbit=false, orbitSpeed=20, orbitRadius=15, void=false, voidRange=50, fly=false, flySpeed=100, noclip=false,
    noRecoil=true, antiAim=false, teamCheck=true, thirdPerson=false, -- DISABLED
    hitsound=true, watermark=true,
    configName="Default",
    priority="Closest"
}

local function getTarget()
    local best,bestD=nil,s.fov
    local c=Vector2.new(mouse.X,mouse.Y)
    for _,v in pairs(Players:GetPlayers()) do
        if v~=lp and (not s.teamCheck or lp.Team~=v.Team) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos=v.Character.HumanoidRootPart.Position
            if s.prediction then pos=pos+v.Character.HumanoidRootPart.Velocity*0.1 end
            local p,o=workspace.CurrentCamera:WorldToScreenPoint(pos)
            if o and math.random(1,100)<=s.hitchance then
                local d=(c-Vector2.new(p.X,p.Y)).Magnitude
                if d<bestD then bestD=d best=v end
            end
        end
    end
    return best
end

local espFolder=Instance.new("Folder",CoreGui)
espFolder.Name="SapphireESP"
local function updateESP()
    for _,v in pairs(espFolder:GetChildren()) do v:Destroy() end
    if not s.esp then return end
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root=plr.Character.HumanoidRootPart
            local hum=plr.Character:FindFirstChild("Humanoid")
            if hum and hum.Health>0 then
                local pos,on=workspace.CurrentCamera:WorldToScreenPoint(root.Position)
                if on then
                    local group=Instance.new("Frame",espFolder)
                    group.Size=UDim2.new(0,0,0,0)
                    if s.espBox then
                        local box=Instance.new("Frame",group)
                        box.Size=UDim2.new(0,60,0,80)
                        box.Position=UDim2.new(0,pos.X-30,0,pos.Y-40)
                        box.BackgroundColor3=Color3.fromRGB(255,0,0)
                        box.BackgroundTransparency=0.5
                        box.BorderSizePixel=1
                        if s.espName then
                            local name=Instance.new("TextLabel",box)
                            name.Text=plr.Name
                            name.TextColor3=Color3.fromRGB(255,255,255)
                            name.Size=UDim2.new(1,0,0,15)
                            name.BackgroundTransparency=1
                            name.Font=Enum.Font.GothamBold
                            name.TextSize=10
                        end
                        if s.espHealth then
                            local health=Instance.new("Frame",box)
                            local percent=hum.Health/hum.MaxHealth
                            health.Size=UDim2.new(percent,0,0,4)
                            health.Position=UDim2.new(0,0,0,70)
                            health.BackgroundColor3=percent>0.6 and Color3.fromRGB(0,255,0) or percent>0.3 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)
                        end
                        if s.espDistance then
                            local dist=math.floor((root.Position-lp.Character.HumanoidRootPart.Position).Magnitude)
                            local distText=Instance.new("TextLabel",box)
                            distText.Text=dist.."s"
                            distText.TextColor3=Color3.fromRGB(255,255,255)
                            distText.Size=UDim2.new(1,0,0,12)
                            distText.Position=UDim2.new(0,0,0,55)
                            distText.BackgroundTransparency=1
                            distText.Font=Enum.Font.Gotham
                            distText.TextSize=9
                        end
                        if s.espTracer then
                            local tracer=Instance.new("Frame",group)
                            local center=Vector2.new(mouse.X,mouse.Y)
                            local angle=math.atan2(pos.Y-center.Y,pos.X-center.X)
                            local length=(center-Vector2.new(pos.X,pos.Y)).Magnitude
                            tracer.Size=UDim2.new(0,length,0,1)
                            tracer.Position=UDim2.new(0,center.X,0,center.Y)
                            tracer.Rotation=math.deg(angle)
                            tracer.BackgroundColor3=Color3.fromRGB(0,191,255)
                            tracer.BackgroundTransparency=0.3
                        end
                        if s.espGlow then
                            local glow=Instance.new("Frame",group)
                            glow.Size=UDim2.new(0,70,0,90)
                            glow.Position=UDim2.new(0,pos.X-35,0,pos.Y-45)
                            glow.BackgroundColor3=Color3.fromRGB(0,191,255)
                            glow.BackgroundTransparency=0.8
                            glow.BorderSizePixel=0
                        end
                    end
                end
            end
        end
    end
end

local crosshair=Instance.new("Frame",CoreGui)
crosshair.AnchorPoint=Vector2.new(0.5,0.5)
crosshair.BackgroundTransparency=1
local function updateCrosshair()
    for _,c in pairs(crosshair:GetChildren()) do c:Destroy() end
    if not s.crosshair then return end
    local sz=s.chSize
    if s.chShape=="circle" then
        local cir=Instance.new("Frame",crosshair)
        cir.Size=UDim2.new(0,sz,0,sz)
        cir.Position=UDim2.new(0.5,-sz/2,0.5,-sz/2)
        cir.BackgroundColor3=s.chColor
        cir.BackgroundTransparency=0.5
        local cr=Instance.new("UICorner",cir)
        cr.CornerRadius=UDim.new(1,0)
    end
end

local bv=nil
local function fly()
    if not s.fly then if bv then bv:Destroy() end return end
    local char=lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if not bv then bv=Instance.new("BodyVelocity",char.HumanoidRootPart) bv.MaxForce=Vector3.new(1e9,1e9,1e9) end
    local cam=workspace.CurrentCamera
    local dir=Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
    bv.Velocity=dir*s.flySpeed
end

local function noclip()
    if not s.noclip then return end
    local char=lp.Character
    if char then for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
end

local function combat()
    if not s.aimbot then return end
    local target=getTarget()
    if target then
        pcall(function()
            local p=workspace.CurrentCamera:WorldToScreenPoint(target.Character.HumanoidRootPart.Position)
            if s.silent then mousemoveabs(p.X,p.Y) end
            if s.trigger then mouse1click() end
        end)
    end
end

RunService.RenderStepped:Connect(function()
    combat()
    updateESP()
    updateCrosshair()
    fly()
    noclip()
    -- Third-Person DISABLED - no camera changes
end)

print("Sapphire MAX Loaded - Third-Person OFF") 
