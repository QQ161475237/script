local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- 飞行变量【固定速度 无自动加速】
local flying = false
local BaseSpeed = 50 -- 固定基础速度
local CurrentSpeed = 50
local maxspeed = 2000
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local BodyVelocity, BodyGyro

-- ========== UI ==========
local FlyUI = Instance.new("ScreenGui")
FlyUI.Name = "MerzzlFlyUI"
FlyUI.ResetOnSpawn = false
FlyUI.IgnoreGuiInset = true
FlyUI.Parent = LP.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 150)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundTransparency = 1
MainFrame.Active = true
MainFrame.Parent = FlyUI

-- 拖动
local dragging = false
local dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    end
end)

MainFrame.InputEnded:Connect(function()
    dragging = false
end)

-- 按钮创建
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 50, 0, 50)
CloseBtn.Position = UDim2.new(0, 0, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 100, 0, 50)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "Merzzl"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Parent = MainFrame

local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0, 50, 0, 50)
UpBtn.Position = UDim2.new(0, 0, 0, 50)
UpBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
UpBtn.Text = "上"
UpBtn.TextScaled = true
UpBtn.Parent = MainFrame

local SpeedUpBtn = Instance.new("TextButton")
SpeedUpBtn.Size = UDim2.new(0, 50, 0, 50)
SpeedUpBtn.Position = UDim2.new(0, 50, 0, 50)
SpeedUpBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
SpeedUpBtn.Text = "+"
SpeedUpBtn.TextScaled = true
SpeedUpBtn.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 100, 0, 50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
ToggleBtn.Text = "飞行"
ToggleBtn.TextScaled = true
ToggleBtn.Parent = MainFrame

local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0, 50, 0, 50)
DownBtn.Position = UDim2.new(0, 0, 0, 100)
DownBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 100)
DownBtn.Text = "下"
DownBtn.TextScaled = true
DownBtn.Parent = MainFrame

local SpeedDownBtn = Instance.new("TextButton")
SpeedDownBtn.Size = UDim2.new(0, 50, 0, 50)
SpeedDownBtn.Position = UDim2.new(0, 50, 0, 100)
SpeedDownBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 255)
SpeedDownBtn.Text = "-"
SpeedDownBtn.TextScaled = true
SpeedDownBtn.Parent = MainFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 50, 0, 50)
SpeedLabel.Position = UDim2.new(0, 100, 0, 100)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
SpeedLabel.Text = tostring(BaseSpeed)
SpeedLabel.TextScaled = true
SpeedLabel.Parent = MainFrame

local upHeld = false
local downHeld = false
UpBtn.MouseButton1Down:Connect(function() upHeld = true end)
UpBtn.MouseButton1Up:Connect(function() upHeld = false end)
DownBtn.MouseButton1Down:Connect(function() downHeld = true end)
DownBtn.MouseButton1Up:Connect(function() downHeld = false end)

-- ========== 纯固定速度飞行【无加速 无提速 无漂移】 ==========
local function FlyLoop()
    while flying and task.wait() do
        if not RootPart or not Humanoid then break end
        Humanoid.PlatformStand = true

        local cam = workspace.CurrentCamera
        
        -- 只保留固定速度，彻底删除自动加速代码
        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
            CurrentSpeed = BaseSpeed
            BodyVelocity.Velocity = ((cam.CFrame.LookVector * (ctrl.f+ctrl.b)) + ((cam.CFrame * CFrame.new(ctrl.l+ctrl.r, 0, 0).Position) - cam.CFrame.Position)) * CurrentSpeed
            lastctrl = table.clone(ctrl)
        else
            -- 松开按键立刻停移，不漂移
            BodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
        end

        -- 上下升降
        local upOffset = Vector3.new(0,0,0)
        if upHeld then upOffset += Vector3.new(0, 0.6, 0) end
        if downHeld then upOffset -= Vector3.new(0, 0.6, 0) end
        BodyVelocity.Velocity += upOffset

        BodyGyro.CFrame = cam.CFrame
    end

    if BodyVelocity then BodyVelocity:Destroy() end
    if BodyGyro then BodyGyro:Destroy() end
    if Humanoid then Humanoid.PlatformStand = false end
    CurrentSpeed = BaseSpeed
    ctrl = {f=0,b=0,l=0,r=0}
    lastctrl = {f=0,b=0,l=0,r=0}
end

local function EnableFly()
    if flying then return end
    flying = true

    BodyGyro = Instance.new("BodyGyro", RootPart)
    BodyGyro.P = 9e4
    BodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    BodyGyro.CFrame = RootPart.CFrame

    BodyVelocity = Instance.new("BodyVelocity", RootPart)
    BodyVelocity.Velocity = Vector3.new(0,0.1,0)
    BodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)

    task.spawn(FlyLoop)
end

local function DisableFly()
    flying = false
end

-- WASD / E开关
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    local key = input.KeyCode.Name:lower()
    if key == "e" then
        if flying then DisableFly() else EnableFly() end
    elseif key == "w" then ctrl.f = 1
    elseif key == "s" then ctrl.b = -1
    elseif key == "a" then ctrl.l = -1
    elseif key == "d" then ctrl.r = 1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode.Name:lower()
    if key == "w" then ctrl.f = 0
    elseif key == "s" then ctrl.b = 0
    elseif key == "a" then ctrl.l = 0
    elseif key == "d" then ctrl.r = 0
    end
end)

-- UI按键
ToggleBtn.MouseButton1Click:Connect(function()
    if flying then DisableFly() else EnableFly() end
end)

CloseBtn.MouseButton1Click:Connect(function()
    DisableFly()
    FlyUI:Destroy()
end)

SpeedUpBtn.MouseButton1Click:Connect(function()
    BaseSpeed = math.min(BaseSpeed + 10, maxspeed)
    SpeedLabel.Text = tostring(BaseSpeed)
end)
SpeedDownBtn.MouseButton1Click:Connect(function()
    BaseSpeed = math.max(BaseSpeed - 10, 10)
    SpeedLabel.Text = tostring(BaseSpeed)
end)

-- 角色重生
LP.CharacterAdded:Connect(function(newChar)
    DisableFly()
    task.wait(0.2)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)
