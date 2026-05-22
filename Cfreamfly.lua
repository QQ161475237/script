-- ========== 独立 CFrame Fly (适配所有设备，带销毁功能) ==========
-- 直接运行这段代码即可，不依赖任何外部脚本

-- 检查是否已存在，避免重复创建
if _G.CFlyRunning then
    -- 如果已经运行，先销毁旧的
    if _G.CFlyDestroy then
        _G.CFlyDestroy()
    end
end

-- 创建 UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CFlyGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 155)  -- 加高一点放销毁按钮
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -77)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
title.Text = "CFrame Fly"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- 关闭按钮 (右上角X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 80, 0, 35)
flyBtn.Position = UDim2.new(0.5, -85, 0, 40)
flyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
flyBtn.Text = "启动飞行"
flyBtn.TextColor3 = Color3.new(1, 1, 1)
flyBtn.Font = Enum.Font.SourceSansBold
flyBtn.TextSize = 16
flyBtn.Parent = mainFrame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 80, 0, 35)
stopBtn.Position = UDim2.new(0.5, 5, 0, 40)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopBtn.Text = "停止飞行"
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.Font = Enum.Font.SourceSansBold
stopBtn.TextSize = 16
stopBtn.Parent = mainFrame

local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(0, 180, 0, 20)
speedSlider.Position = UDim2.new(0.5, -90, 0, 85)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
speedSlider.BorderSizePixel = 0
speedSlider.Parent = mainFrame

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new(0.066, 0, 1, 0)  -- 默认约速度5
speedFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
speedFill.BorderSizePixel = 0
speedFill.Parent = speedSlider

local speedText = Instance.new("TextLabel")
speedText.Size = UDim2.new(1, 0, 1, 0)
speedText.BackgroundTransparency = 1
speedText.Text = "速度: 5"
speedText.TextColor3 = Color3.new(1, 1, 1)
speedText.Font = Enum.Font.SourceSans
speedText.TextSize = 12
speedText.Parent = speedSlider

-- 销毁按钮
local destroyBtn = Instance.new("TextButton")
destroyBtn.Size = UDim2.new(0, 200, 0, 25)
destroyBtn.Position = UDim2.new(0.5, -100, 0, 120)
destroyBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
destroyBtn.Text = "🗑 销毁脚本并关闭UI"
destroyBtn.TextColor3 = Color3.new(1, 1, 1)
destroyBtn.Font = Enum.Font.SourceSans
destroyBtn.TextSize = 13
destroyBtn.BorderSizePixel = 0
destroyBtn.Parent = mainFrame

-- 飞行变量
local CFlying = false
local CFSpeed = 5  -- 默认速度5
local CFlyConnection = nil
local CFlyDiedConn = nil
local isDestroyed = false

-- 获取角色的根部件
local function getRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or 
           char:FindFirstChild("Torso") or 
           char:FindFirstChild("UpperTorso")
end

-- 检测是否为移动端
local isMobile = false
pcall(function()
    local uis = game:GetService("UserInputService")
    isMobile = uis.TouchEnabled and not uis.KeyboardEnabled
end)

-- 停止飞行 (内部使用)
local function stopFlyInternal()
    if CFlyConnection then
        CFlyConnection:Disconnect()
        CFlyConnection = nil
    end
    if CFlyDiedConn then
        CFlyDiedConn:Disconnect()
        CFlyDiedConn = nil
    end
    
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        local head = player.Character:FindFirstChild("Head")
        if head then
            head.Anchored = false
        end
        -- 清理 BodyVelocity 和 BodyGyro
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
    end
end

-- 完整销毁函数
local function destroyScript()
    if isDestroyed then return end
    isDestroyed = true
    
    -- 停止飞行
    stopFlyInternal()
    
    -- 清理所有连接
    CFlying = false
    CFlyConnection = nil
    CFlyDiedConn = nil
    
    -- 销毁 UI
    if screenGui then
        screenGui:Destroy()
    end
    
    -- 清理全局变量
    _G.CFlyRunning = nil
    _G.CFlyDestroy = nil
    
    print("[CFly] 脚本已完全销毁")
end

-- 开始飞行
local function startFly()
    stopFlyInternal()
    
    if isDestroyed then return end
    
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then
        warn("[CFly] 角色不存在")
        return
    end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        warn("[CFly] 没有 Humanoid")
        return
    end
    
    CFlying = true
    flyBtn.Text = "飞行中"
    flyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    
    humanoid.PlatformStand = true
    
    local head = char:FindFirstChild("Head")
    if head then
        head.Anchored = true
    end
    
    if isMobile then
        -- 移动端：BodyVelocity + BodyGyro
        local root = getRoot(char)
        if not root then
            CFlying = false
            return
        end
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = root
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 9e4
        bodyGyro.Parent = root
        
        local uis = game:GetService("UserInputService")
        local rs = game:GetService("RunService")
        
        CFlyConnection = rs.RenderStepped:Connect(function()
            if not CFlying or not player.Character or isDestroyed then
                return
            end
            
            local currentRoot = getRoot(player.Character)
            if not currentRoot then return end
            
            local camera = workspace.CurrentCamera
            local moveVector = Vector3.new()
            
            if uis:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + Vector3.new(0, 0, -1)
            end
            if uis:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector + Vector3.new(0, 0, 1)
            end
            if uis:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector + Vector3.new(-1, 0, 0)
            end
            if uis:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + Vector3.new(1, 0, 0)
            end
            if uis:IsKeyDown(Enum.KeyCode.E) or uis:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if uis:IsKeyDown(Enum.KeyCode.Q) or uis:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveVector = moveVector + Vector3.new(0, -1, 0)
            end
            
            if moveVector.Magnitude > 0 then
                moveVector = moveVector.Unit
            end
            
            local velocity = (camera.CFrame.RightVector * moveVector.X + 
                              camera.CFrame.LookVector * moveVector.Z + 
                              Vector3.new(0, moveVector.Y, 0)) * CFSpeed * 15
            bodyVelocity.Velocity = velocity
            bodyGyro.CFrame = camera.CFrame
        end)
    else
        -- PC端：CFrame 飞行
        local rs = game:GetService("RunService")
        
        CFlyConnection = rs.Heartbeat:Connect(function(deltaTime)
            if not CFlying or not player.Character or isDestroyed then
                return
            end
            
            local currentChar = player.Character
            local currentHead = currentChar:FindFirstChild("Head")
            local currentHumanoid = currentChar:FindFirstChildOfClass("Humanoid")
            
            if not currentHead or not currentHumanoid then
                return
            end
            
            local moveDirection = currentHumanoid.MoveDirection * (CFSpeed * (deltaTime or 0.016) * 15)
            local headCFrame = currentHead.CFrame
            local camera = workspace.CurrentCamera
            local cameraCFrame = camera.CFrame
            local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
            cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
            local cameraPosition = cameraCFrame.Position
            local headPosition = headCFrame.Position
            
            local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
            currentHead.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
        end)
    end
    
    -- 死亡时自动停止
    CFlyDiedConn = humanoid.Died:Connect(function()
        if not isDestroyed then
            stopFlyInternal()
            CFlying = false
            flyBtn.Text = "启动飞行"
            flyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        end
    end)
    
    print("[CFly] 飞行已启动，速度: " .. CFSpeed)
end

-- 停止飞行 (外部调用)
local function stopFly()
    if isDestroyed then return end
    stopFlyInternal()
    CFlying = false
    flyBtn.Text = "启动飞行"
    flyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    print("[CFly] 飞行已停止")
end

-- 更新速度显示 (范围 5-80)
local function updateSpeed(value)
    CFSpeed = math.clamp(value, 5, 80)
    local percent = (CFSpeed - 5) / 75
    speedFill.Size = UDim2.new(percent, 0, 1, 0)
    speedText.Text = "速度: " .. math.floor(CFSpeed)
end

-- 滑动条拖拽功能
local dragging = false
local function updateSlider(input)
    local relativeX = math.clamp((input.Position.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
    local newSpeed = 5 + relativeX * 75
    updateSpeed(newSpeed)
end

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        updateSlider(input)
    end
end)

speedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                     input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- 按钮事件
flyBtn.MouseButton1Click:Connect(function()
    if CFlying then
        stopFly()
    else
        startFly()
    end
end)

stopBtn.MouseButton1Click:Connect(stopFly)

-- 关闭按钮 (只关闭UI，保留飞行功能)
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
    print("[CFly] UI已隐藏，输入 :CFlyShow 可重新显示")
end)

-- 销毁按钮 (完全销毁脚本)
destroyBtn.MouseButton1Click:Connect(function()
    destroyScript()
end)

-- 角色重生时重新飞行（如果之前是飞行状态）
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if CFlying and not isDestroyed then
        task.wait(0.5)
        if CFlying then
            startFly()
        end
    end
end)

-- 拖拽 UI
local dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragStart = input.Position
        startPos = mainFrame.Position
        local conn
        conn = game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or 
               input.UserInputType == Enum.UserInputType.Touch then
                updateDrag(input)
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                conn:Disconnect()
            end
        end)
    end
end)

-- 设置全局变量，方便控制
_G.CFlyRunning = true
_G.CFlyDestroy = destroyScript

-- 添加重新显示UI的命令 (可选)
local function showUI()
    if screenGui then
        screenGui.Enabled = true
    end
end
_G.CFlyShow = showUI

print("[CFly] UI 已加载！")
print("[CFly] 按 W/A/S/D 移动，E/Q 上升/下降")
print("[CFly] 点击右上角 ✕ 隐藏UI")
print("[CFly] 点击底部红色按钮可完全销毁脚本")
print("[CFly] 输入 :CFlyShow 可重新显示UI")