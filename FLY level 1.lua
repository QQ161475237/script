local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- 核心变量
local flying = false
local maxspeed = 70

-- 获取控制模块
local PlayerModule = require(LP.PlayerScripts:WaitForChild("PlayerModule"))
local ControlModule = PlayerModule:GetControls()

local hrp, hum
local bv, bg
local originalCanCollide = {}
local descendantConnection = nil

-- 清理资源
local function clearAllFlyResources()
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
    end
    if descendantConnection then descendantConnection:Disconnect() descendantConnection = nil end
    if originalCanCollide then
        for part, state in pairs(originalCanCollide) do
            if part and part.Parent then part.CanCollide = state end
        end
        table.clear(originalCanCollide)
    end
    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

local function getCharDetails()
    local char = LP.Character
    if not char then return nil, nil end
    hrp = char:FindFirstChild("HumanoidRootPart")
    hum = char:FindFirstChild("Humanoid")
    return hrp, hum
end

-- ========== 物理飞行（你指定的源码） ==========
local function startPhysicalFly()
    local root, humanoid = getCharDetails()
    if not root or not humanoid then return end
    clearAllFlyResources()
    flying = true

    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)

    task.spawn(function()
        while flying and root.Parent do
            local moveVec = ControlModule:GetMoveVector()
            if moveVec.Magnitude > 0 then
                local camCF = camera.CFrame
                local direction = (camCF.LookVector * -moveVec.Z) + (camCF.RightVector * moveVec.X)
                bv.Velocity = direction.Unit * maxspeed
            else
                bv.Velocity = Vector3.zero
            end
            bg.CFrame = camera.CFrame
            humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
            task.wait()
        end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end)
end

local function stopFly()
    flying = false
    clearAllFlyResources()
end

-- ========== 你指定的UI（完全没改动） ==========
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

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 50, 0, 50)
CloseBtn.Position = UDim2.new(0, 0, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 50, 0, 50)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "Fly"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 100, 0, 50)
ToggleBtn.Position = UDim2.new(0, 0, 0, 50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
ToggleBtn.Text = "开启飞行"
ToggleBtn.TextScaled = true
ToggleBtn.Parent = MainFrame

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

local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Size = UDim2.new(0, 80, 0, 30)
SpeedDisplay.Position = UDim2.new(0, 110, 0, 25)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(20,20,20)
SpeedDisplay.TextColor3 = Color3.new(1,1,1)
SpeedDisplay.Text = "速度: "..maxspeed
SpeedDisplay.TextScaled = true
SpeedDisplay.Parent = MainFrame

-- ========== 按钮绑定（不改UI） ==========
ToggleBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        ToggleBtn.Text = "开启飞行"
    else
        startPhysicalFly()
        ToggleBtn.Text = "关闭飞行"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopFly()
    FlyUI:Destroy()
end)

SpeedUpBtn.MouseButton1Click:Connect(function()
    maxspeed = math.min(maxspeed + 10, 2000)
    SpeedDisplay.Text = "速度: "..maxspeed
end)

SpeedDownBtn.MouseButton1Click:Connect(function()
    maxspeed = math.max(maxspeed - 10, 10)
    SpeedDisplay.Text = "速度: "..maxspeed
end)

-- 重生重置
LP.CharacterAdded:Connect(function(newChar)
    stopFly()
    task.wait(0.2)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)
