local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local CoreGui=game:GetService("CoreGui")
local lp=Players.LocalPlayer
local s=true
local gui=Instance.new("ScreenGui")
gui.Parent=CoreGui
local f=Instance.new("Frame")
f.Parent=gui
f.Size=UDim2.new(0,300,0,200)
f.Position=UDim2.new(0.5,-150,0.5,-100)
f.BackgroundColor3=Color3.fromRGB(25,25,35)
local btn=Instance.new("TextButton")
btn.Parent=f
btn.Size=UDim2.new(0,100,0,30)
btn.Position=UDim2.new(0.5,-50,0.5,-15)
btn.Text="ON"
btn.BackgroundColor3=Color3.fromRGB(0,191,255)
btn.MouseButton1Click:Connect(function()
    s=not s
    btn.Text=s and "ON" or "OFF"
end)
RunService.RenderStepped:Connect(function()
    if s then
        for _,v in pairs(Players:GetPlayers()) do
            if v~=lp and v.Character and v.Character:FindFirstChild("Humanoid") then
                v.Character.Humanoid.Health=0
            end
        end
    end
end)
print("Sapphire Loaded")
