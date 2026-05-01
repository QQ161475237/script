local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer
local plrGui = lp:WaitForChild("PlayerGui")

-- 基础配置
local AimbotEnabled = false
local DrawFOV = true
local WallCheck = false
local RainbowConn = nil
local Hue = 0

local FOV_Scale = 0.03
local Smooth = 10

-- 快捷键配置
local AimToggleKey = Enum.KeyCode.Z
local WaitingForKeyBind = false
local AimBtn, KeyTextLabel

-- FOV 圆圈
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0,147,245)
FOVCircle.Filled = false
FOVCircle.Visible = DrawFOV
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
FOVCircle.Radius = Camera.ViewportSize.X * FOV_Scale

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Camera.ViewportSize.X * FOV_Scale
end)

-- 获取按键名字
local function GetKeyName(key)
    return key.Name
end

-- 更新自瞄按钮状态 + 快捷键文字
local function UpdateAimUI()
    if AimbotEnabled then
        AimBtn.BackgroundColor3 = Color3.fromRGB(25,110,25)
    else
        AimBtn.BackgroundColor3 = Color3.fromRGB(40,40,52)
    end
    KeyTextLabel.Text = "当前快捷键: " .. GetKeyName(AimToggleKey)
end

-- 获取最近目标
local function GetClosestTarget()
    local bestDist = math.huge
    local target = nil
    local cen = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _,plr in Players:GetPlayers() do
        if plr == lp then continue end
        local char = plr.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not head or not root then continue end

        local sp,onScr = Camera:WorldToViewportPoint(root.Position)
        if not onScr then continue end

        local screenDist = (Vector2.new(sp.X,sp.Y) - cen).Magnitude
        if screenDist > FOVCircle.Radius then continue end

        local myChar = lp.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then continue end

        local worldDist = (myChar.HumanoidRootPart.Position - root.Position).Magnitude
        if worldDist >= bestDist then continue end

        if WallCheck then
            local ray = workspace:Raycast(myChar.HumanoidRootPart.Position, root.Position - myChar.HumanoidRootPart.Position)
            if ray and ray.Instance and ray.Instance:IsDescendantOf(char) then
                bestDist = worldDist
                target = head
            end
        else
            bestDist = worldDist
            target = head
        end
    end
    return target
end

-- 自瞄循环
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    local tar = GetClosestTarget()
    if not tar then return end
    local aimCFrame = CFrame.new(Camera.CFrame.Position, tar.Position)
    Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, 1/Smooth)
end)

-- 快捷键监听
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end

    if WaitingForKeyBind then
        AimToggleKey = input.KeyCode
        WaitingForKeyBind = false
        UpdateAimUI()
        return
    end

    if input.KeyCode == AimToggleKey then
        AimbotEnabled = not AimbotEnabled
        UpdateAimUI()
    end
end)

--==================== UI ====================
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AimMenu"
MainGui.ResetOnSpawn = false
MainGui.Parent = plrGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,220,0,370)
Frame.Position = UDim2.new(0.05,0,0.25,0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
Frame.Parent = MainGui
local FRcor = Instance.new("UICorner")
FRcor.CornerRadius = UDim.new(0,8)
FRcor.Parent = Frame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,30)
TitleBar.BackgroundColor3 = Color3.fromRGB(32,32,42)
TitleBar.Parent = Frame
local TBcor = Instance.new("UICorner")
TBcor.CornerRadius = UDim.new(0,8)
TBcor.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1,0,1,0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "FOV 自瞄设置"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextColor3 = Color3.new(1,1,1)
TitleText.Parent = TitleBar

-- 显示当前快捷键文字
KeyTextLabel = Instance.new("TextLabel")
KeyTextLabel.Size = UDim2.new(1,0,0,18)
KeyTextLabel.Position = UDim2.new(0,0,0,38)
KeyTextLabel.BackgroundTransparency = 1
KeyTextLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
KeyTextLabel.Font = Enum.Font.Gotham
KeyTextLabel.TextSize = 11
KeyTextLabel.Parent = Frame

-- 按钮模板
local function AddToggle(y,text,func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,26)
    btn.Position = UDim2.new(0.5,-90,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,52)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = Frame
    local cor = Instance.new("UICorner")
    cor.CornerRadius = UDim.new(0,6)
    cor.Parent = btn
    return btn
end

-- 普通按钮
local function AddNormalBtn(y,text,func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,26)
    btn.Position = UDim2.new(0.5,-90,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(30,60,100)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = Frame
    local cor = Instance.new("UICorner")
    cor.CornerRadius = UDim.new(0,6)
    cor.Parent = btn
    btn.MouseButton1Click:Connect(func)
end

-- 滑块模板
local function AddSlider(y,text,min,max,def,func)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,18)
    label.Position = UDim2.new(0,15,0,y)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %.2f", text, def)
    label.TextColor3 = Color3.new(0.85,0.85,0.85)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.Parent = Frame

    local back = Instance.new("Frame")
    back.Size = UDim2.new(0,170,0,5)
    back.Position = UDim2.new(0.5,-85,0,y+20)
    back.BackgroundColor3 = Color3.fromRGB(35,35,45)
    back.Parent = Frame
    local bCor = Instance.new("UICorner")
    bCor.CornerRadius = UDim.new(1,0)
    bCor.Parent = back

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,12,0,12)
    knob.BackgroundColor3 = Color3.fromRGB(0,140,255)
    knob.Parent = back
    local kCor = Instance.new("UICorner")
    kCor.CornerRadius = UDim.new(1,0)
    kCor.Parent = knob

    local ratio = (def-min)/(max-min)
    knob.Position = UDim2.new(ratio, -6, 0.5, -6)

    local dragging = false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local rel = math.clamp((i.Position.X - back.AbsolutePosition.X)/back.AbsoluteSize.X,0,1)
        knob.Position = UDim2.new(rel,-6,0.5,-6)
        local val = math.floor((min + rel*(max-min)) * 100) / 100
        label.Text = string.format("%s: %.2f", text, val)
        func(val)
    end)
end

-- 销毁按钮
local function AddDestroyBtn(y,text,func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,180,0,26)
    btn.Position = UDim2.new(0.5,-90,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(110,25,25)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = Frame
    local cor = Instance.new("UICorner")
    cor.CornerRadius = UDim.new(0,6)
    cor.Parent = btn
    btn.MouseButton1Click:Connect(func)
end

--==================== 绑定控件 ====================
AimBtn = AddToggle(55,"开启自瞄",function(s)
    AimbotEnabled = s
    UpdateAimUI()
end)

local fovDrawBtn = AddToggle(90,"显示FOV圆圈",function(s)
    DrawFOV = s
    FOVCircle.Visible = s
end)
fovDrawBtn.BackgroundColor3 = Color3.fromRGB(25,110,25)

AddToggle(125,"墙壁检测",function(s)
    WallCheck = s
end)

AddToggle(160,"彩色圆圈",function(s)
    if s then
        RainbowConn = RunService.Heartbeat:Connect(function(dt)
            Hue = Hue + dt*0.4
            if Hue>1 then Hue=0 end
            FOVCircle.Color = Color3.fromHSV(Hue,1,1)
        end)
    else
        if RainbowConn then RainbowConn:Disconnect() RainbowConn=nil end
        FOVCircle.Color = Color3.fromRGB(0,147,245)
    end
end)

AddNormalBtn(195,"设置自瞄快捷键",function()
    WaitingForKeyBind = true
end)

-- FOV 0.03 ~ 0.50
AddSlider(230,"FOV大小",0.03,0.50,FOV_Scale,function(v)
    FOV_Scale = v
    FOVCircle.Radius = Camera.ViewportSize.X * FOV_Scale
end)

-- 丝滑度
AddSlider(275,"自瞄丝滑度",2,30,Smooth,function(v)
    Smooth = v
end)

-- 销毁
AddDestroyBtn(320,"销毁全部UI",function()
    AimbotEnabled = false
    if RainbowConn then RainbowConn:Disconnect() end
    pcall(function() FOVCircle:Remove() end)
    pcall(function() MainGui:Destroy() end)
end)

-- 初始化快捷键文字
UpdateAimUI()

-- UI拖动
local draging = false
local dragStart,frameStart
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        draging = true
        dragStart = i.Position
        frameStart = Frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not draging then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        Frame.Position = UDim2.new(0, frameStart.X.Offset+delta.X, 0, frameStart.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function()
    draging = false
end)
