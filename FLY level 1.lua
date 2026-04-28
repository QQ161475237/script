-- 【防反作弊】飞行｜无僵直+有走路动画+不被检测
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- 飞行核心变量
local flying = false
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local maxspeed = 50
local speed = 0
local BodyVelocity, BodyGyro

-- ========== 精简UI 布局分离 ==========
local FlyUI = Instance.new("ScreenGui")
FlyUI.Name = "MerzzlFlyUI"
FlyUI.ResetOnSpawn = false
FlyUI.IgnoreGuiInset = true
FlyUI.Parent = LP.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 100, 0, 100)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundTransparency = 1
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = FlyUI

-- 关闭按钮
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 50, 0, 50)
CloseBtn.Position = UDim2.new(0, 0, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Parent = MainFrame

-- 标题
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 50, 0, 50)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "Fly"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Parent = MainFrame

-- 飞行开关【独立按键】
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 100, 0, 50)
ToggleBtn.Position = UDim2.new(0, 0, 0, 50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
ToggleBtn.Text = "开启飞行"
ToggleBtn.TextScaled = true
ToggleBtn.Parent = MainFrame

-- 速度加减
local SpeedUpBtn = Instance.new("TextButton")
SpeedUpBtn.Size = UDim2.new(0, 50, 0, 50)
SpeedUpBtn.Position = UDim2.new(0, 0, 0, 100)
SpeedUpBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
SpeedUpBtn.Text = "+"
SpeedUpBtn.TextScaled = true
SpeedUpBtn.Parent = MainFrame

local SpeedDownBtn = Instance.new("TextButton")
SpeedDownBtn.Size = UDim2.new(0, 50, 0, 50)
SpeedDownBtn.Position = UDim2.new(0, 50, 0, 100)
SpeedDownBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 255)
SpeedDownBtn.Text = "-"
SpeedDownBtn.TextScaled = true
SpeedDownBtn.Parent = MainFrame

-- 飞行速度【独立文本、完全分开】
local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Size = UDim2.new(0, 80, 0, 30)
SpeedDisplay.Position = UDim2.new(0, 110, 0, 25)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(20,20,20)
SpeedDisplay.TextColor3 = Color3.new(1,1,1)
SpeedDisplay.Text = "速度: "..maxspeed
SpeedDisplay.TextScaled = true
SpeedDisplay.Parent = MainFrame

-- ========== 相机保护防黑屏 ==========
local function GetCamera()
    local cam = workspace.CurrentCamera
    if not cam or cam.Parent ~= workspace then
        cam = Instance.new("Camera", workspace)
        cam.Name = "Camera"
        cam.CFrame = RootPart.CFrame * CFrame.new(0,2,-5)
        cam.Focus = RootPart.CFrame
        workspace.CurrentCamera = cam
    end
    return cam
end

-- ========== 【防反作弊】飞行 ==========
local function FlyLoop()
    while flying and task.wait() do
        if not RootPart or not Humanoid then break end
        
        local cam = GetCamera()
        cam.Focus = RootPart.CFrame

        -- 惯性加速
        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
            speed = speed + .5 + (speed / maxspeed)
            if speed > maxspeed then speed = maxspeed end
        elseif speed ~= 0 then
            speed = speed - 1
            if speed < 0 then speed = 0 end
        end

        local vel = Vector3.new(0,0.1,0)
        if (ctrl.l + ctrl.r ~= 0) or (ctrl.f + ctrl.b ~= 0) then
            vel = ((cam.CFrame.LookVector * (ctrl.f+ctrl.b)) + ((cam.CFrame * CFrame.new(ctrl.l+ctrl.r,0,0).Position) - cam.CFrame.Position)) * speed
            lastctrl = table.clone(ctrl)
        elseif speed ~= 0 then
            vel = ((cam.CFrame.LookVector * (lastctrl.f+lastctrl.b)) + ((cam.CFrame * CFrame.new(lastctrl.l+lastctrl.r,0,0).Position) - cam.CFrame.Position)) * speed
        end

        BodyVelocity.Velocity = vel
        local lookDir = Vector3.new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z).Unit
        BodyGyro.CFrame = CFrame.new(RootPart.Position, RootPart.Position + lookDir)
    end

    if BodyGyro then BodyGyro:Destroy() end
    if BodyVelocity then BodyVelocity:Destroy() end
    speed = 0
    ctrl = {f=0,b=0,l=0,r=0}
    lastctrl = {f=0,b=0,l=0,r=0}
end

local function EnableFly()
    if flying then return end
    flying = true
    ToggleBtn.Text = "关闭飞行"

    BodyGyro = Instance.new("BodyGyro", RootPart)
    BodyGyro.P = 1e4
    BodyGyro.MaxTorque = Vector3.new(1e7,1e7,1e7)

    BodyVelocity = Instance.new("BodyVelocity", RootPart)
    BodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)

    task.spawn(FlyLoop)
end

local function DisableFly()
    flying = false
    ToggleBtn.Text = "开启飞行"
end

-- WASD 控制
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    local k = input.KeyCode.Name:lower()
    if k == "w" then ctrl.f = 1
    elseif k == "s" then ctrl.b = -1
    elseif k == "a" then ctrl.l = -1
    elseif k == "d" then ctrl.r = 1
    end
end)
UserInputService.InputEnded:Connect(function(input)
    local k = input.KeyCode.Name:lower()
    if k == "w" then ctrl.f = 0
    elseif k == "s" then ctrl.b = 0
    elseif k == "a" then ctrl.l = 0
    elseif k == "d" then ctrl.r = 0
    end
end)

-- 飞行开关
ToggleBtn.MouseButton1Click:Connect(function()
    if flying then DisableFly() else EnableFly() end
end)
ToggleBtn.TouchTap:Connect(function()
    if flying then DisableFly() else EnableFly() end
end)

-- 关闭UI
CloseBtn.MouseButton1Click:Connect(function()
    DisableFly()
    FlyUI:Destroy()
end)
CloseBtn.TouchTap:Connect(function()
    DisableFly()
    FlyUI:Destroy()
end)

-- 速度调节
SpeedUpBtn.MouseButton1Click:Connect(function()
    maxspeed = math.min(maxspeed + 10, 2000)
    SpeedDisplay.Text = "速度: "..maxspeed
end)
SpeedDownBtn.MouseButton1Click:Connect(function()
    maxspeed = math.max(maxspeed - 10, 10)
    SpeedDisplay.Text = "速度: "..maxspeed
end)

-- 重生
LP.CharacterAdded:Connect(function(newChar)
    DisableFly()
    task.wait(0.2)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)
