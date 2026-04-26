-- 飞行脚本核心变量
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local FlyEnabled = false
local FlySpeed = 50 -- 默认速度
local BodyVelocity, BodyGyro

-- 创建UI
local FlyUI = Instance.new("ScreenGui")
FlyUI.Name = "MerzzlFlyUI"
FlyUI.ResetOnSpawn = false
FlyUI.Parent = LP.PlayerGui

-- 主窗口（支持拖动，透明背景，尺寸150x150）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 150)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true
MainFrame.Parent = FlyUI

-- 拖动功能变量
local dragging = false
local dragStart, startPos

-- 拖动逻辑
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- 按钮UI（3行×3列，每个按钮50×50，紧凑正方形布局）
-- 第一行
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 50, 0, 50)
CloseBtn.Position = UDim2.new(0, 0, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Parent = MainFrame

local TopBtn = Instance.new("TextButton")
TopBtn.Size = UDim2.new(0, 50, 0, 50)
TopBtn.Position = UDim2.new(0, 50, 0, 0)
TopBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 200)
TopBtn.Text = "T"
TopBtn.TextScaled = true
TopBtn.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 50, 0, 50)
Title.Position = UDim2.new(0, 100, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
Title.Text = "Merzzl"
Title.TextScaled = true
Title.Parent = MainFrame

-- 第二行
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

-- 第三行
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

-- 开启/关闭按钮移到Merzzl正下方（第二行第三列）
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 100, 0, 50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
ToggleBtn.Text = "开关"
ToggleBtn.TextScaled = true
ToggleBtn.Parent = MainFrame

-- 速度显示放在第三行第三列
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 50, 0, 50)
SpeedLabel.Position = UDim2.new(0, 100, 0, 100)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
SpeedLabel.Text = tostring(FlySpeed)
SpeedLabel.TextScaled = true
SpeedLabel.Parent = MainFrame

-- 关闭UI
CloseBtn.MouseButton1Click:Connect(function()
    FlyUI:Destroy()
    if FlyEnabled then
        FlyEnabled = false
        if BodyVelocity then BodyVelocity:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
        Humanoid.PlatformStand = false
    end
end)

-- 开启/关闭飞行
ToggleBtn.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        -- 初始化飞行
        Humanoid.PlatformStand = true
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        BodyVelocity.Parent = RootPart

        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.CFrame = RootPart.CFrame
        BodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
        BodyGyro.P = 1000
        BodyGyro.Parent = RootPart
    else
        -- 关闭飞行
        if BodyVelocity then BodyVelocity:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
        Humanoid.PlatformStand = false
    end
end)

-- 速度控制
SpeedUpBtn.MouseButton1Click:Connect(function()
    FlySpeed = math.min(FlySpeed + 10, 200)
    SpeedLabel.Text = tostring(FlySpeed)
end)

SpeedDownBtn.MouseButton1Click:Connect(function()
    FlySpeed = math.max(FlySpeed - 10, 10)
    SpeedLabel.Text = tostring(FlySpeed)
end)

-- 上下移动
local movingUp = false
local movingDown = false

UpBtn.MouseButton1Down:Connect(function() movingUp = true end)
UpBtn.MouseButton1Up:Connect(function() movingUp = false end)

DownBtn.MouseButton1Down:Connect(function() movingDown = true end)
DownBtn.MouseButton1Up:Connect(function() movingDown = false end)

-- 主循环：控制飞行方向
RunService.RenderStepped:Connect(function(dt)
    if not FlyEnabled then return end

    -- 获取相机方向
    local camera = workspace.CurrentCamera
    local forward = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local up = camera.CFrame.UpVector

    -- 计算移动方向
    local moveDir = Vector3.new(0, 0, 0)
    if movingUp then moveDir += Vector3.new(0, 1, 0) end
    if movingDown then moveDir += Vector3.new(0, -1, 0) end

    -- WASD控制前后左右
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= forward end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= right end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += right end

    -- 归一化方向并设置速度
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
    end
    BodyVelocity.Velocity = moveDir * FlySpeed * 1.8 -- 这里加速了！
    BodyGyro.CFrame = camera.CFrame
end)

-- 角色重生时自动重置
LP.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")

    if FlyEnabled then
        FlyEnabled = false
        if BodyVelocity then BodyVelocity:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
        Humanoid.PlatformStand = false
    end
end)