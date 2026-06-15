--制作:MerzzL开源 | 美化版 (带最小化按钮 + 墙壁检测开关 + 销毁保护)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end

local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local FOV_RADIUS = 150
local SMOOTHNESS = 0.15
local AIMBOT_ENABLED = true
local AIMBOT_KEY = Enum.KeyCode.E
local WALL_CHECK_ENABLED = true  -- 墙壁检测开关（默认开启）

local target = nil
local lockedTarget = nil
local MOUSE_LOCKED = false
local changingKey = false
local minimized = false
local scriptActive = true  -- 脚本是否激活（用于销毁后失效）

-- 存储所有连接，便于销毁时断开
local connections = {}
local renderConnection = nil

-- ================== FOV瞄准圈 ==================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FOVGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local fovOuter = Instance.new("Frame")
fovOuter.Size = UDim2.new(0, FOV_RADIUS*2 + 6, 0, FOV_RADIUS*2 + 6)
fovOuter.AnchorPoint = Vector2.new(0.5, 0.5)
fovOuter.Position = UDim2.new(0.5, 0, 0.5, 0)
fovOuter.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
fovOuter.BackgroundTransparency = 0.95
fovOuter.BorderSizePixel = 0
fovOuter.Parent = screenGui

local outerCorner = Instance.new("UICorner")
outerCorner.CornerRadius = UDim.new(1, 0)
outerCorner.Parent = fovOuter

local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
fovCircle.BackgroundTransparency = 0.85
fovCircle.BorderSizePixel = 1
fovCircle.BorderColor3 = Color3.fromRGB(255, 100, 100)
fovCircle.Parent = screenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = fovCircle

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 4, 0, 4)
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.new(0.5, 0, 0.5, 0)
dot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
dot.BorderSizePixel = 0
dot.Parent = screenGui

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

fovCircle.Visible = AIMBOT_ENABLED
fovOuter.Visible = AIMBOT_ENABLED
dot.Visible = AIMBOT_ENABLED

-- ================== 缩小版美化菜单 ==================
local menuGui = Instance.new("ScreenGui")
menuGui.Name = "AimbotMenu"
menuGui.ResetOnSpawn = false
menuGui.Parent = playerGui

-- 主面板
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 360)
mainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
mainFrame.BackgroundTransparency = 0.08
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = menuGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local borderStroke = Instance.new("UIStroke")
borderStroke.Color = Color3.fromRGB(80, 120, 220)
borderStroke.Thickness = 1.5
borderStroke.Parent = mainFrame

-- 顶部装饰条
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(1, 0, 0, 2)
accentBar.Position = UDim2.new(0, 0, 0, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
accentBar.BorderSizePixel = 0
accentBar.Parent = mainFrame

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 22, 0, 22)
titleIcon.Position = UDim2.new(0, 10, 0, 5)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = "🎯"
titleIcon.TextSize = 16
titleIcon.TextColor3 = Color3.fromRGB(80, 120, 220)
titleIcon.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 1, 0)
title.Position = UDim2.new(0, 38, 0, 0)
title.BackgroundTransparency = 1
title.Text = "自瞄"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(230, 230, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- 最小化按钮
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 24)
MinBtn.Position = UDim2.new(1, -68, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
MinBtn.BackgroundTransparency = 0.7
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = MinBtn

-- 关闭按钮
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.BackgroundTransparency = 0.7
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseBtn

-- 内容区域
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -32)
contentContainer.Position = UDim2.new(0, 0, 0, 32)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- 分隔线
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.9, 0, 0, 1)
divider.Position = UDim2.new(0.05, 0, 0, 0)
divider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
divider.BorderSizePixel = 0
divider.Parent = contentContainer

-- 开关按钮
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 32)
toggleBtn.Position = UDim2.new(0.5, -50, 0, 13)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
toggleBtn.Text = "● 启用"
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 13
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = contentContainer

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 6, 0, 6)
statusDot.Position = UDim2.new(0, 10, 0.5, -3)
statusDot.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
statusDot.BorderSizePixel = 0
statusDot.Parent = toggleBtn

local statusDotCorner = Instance.new("UICorner")
statusDotCorner.CornerRadius = UDim.new(1, 0)
statusDotCorner.Parent = statusDot

-- ========== 墙壁检测开关 ==========
local wallCheckSection = Instance.new("Frame")
wallCheckSection.Size = UDim2.new(1, -20, 0, 32)
wallCheckSection.Position = UDim2.new(0, 10, 0, 52)
wallCheckSection.BackgroundTransparency = 1
wallCheckSection.Parent = contentContainer

local wallCheckIcon = Instance.new("TextLabel")
wallCheckIcon.Size = UDim2.new(0, 20, 0, 20)
wallCheckIcon.Position = UDim2.new(0, 0, 0, 6)
wallCheckIcon.BackgroundTransparency = 1
wallCheckIcon.Text = "🧱"
wallCheckIcon.TextSize = 13
wallCheckIcon.TextColor3 = Color3.fromRGB(150, 150, 200)
wallCheckIcon.Parent = wallCheckSection

local wallCheckLabel = Instance.new("TextLabel")
wallCheckLabel.Size = UDim2.new(0, 90, 0, 20)
wallCheckLabel.Position = UDim2.new(0, 25, 0, 6)
wallCheckLabel.BackgroundTransparency = 1
wallCheckLabel.Text = "墙壁检测"
wallCheckLabel.Font = Enum.Font.GothamSemibold
wallCheckLabel.TextSize = 12
wallCheckLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
wallCheckLabel.TextXAlignment = Enum.TextXAlignment.Left
wallCheckLabel.Parent = wallCheckSection

local wallCheckToggle = Instance.new("TextButton")
wallCheckToggle.Size = UDim2.new(0, 50, 0, 24)
wallCheckToggle.Position = UDim2.new(1, -60, 0, 4)
wallCheckToggle.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
wallCheckToggle.Text = "● 开"
wallCheckToggle.Font = Enum.Font.GothamSemibold
wallCheckToggle.TextSize = 11
wallCheckToggle.TextColor3 = Color3.new(1, 1, 1)
wallCheckToggle.BorderSizePixel = 0
wallCheckToggle.Parent = wallCheckSection

local wallCheckCorner = Instance.new("UICorner")
wallCheckCorner.CornerRadius = UDim.new(0, 6)
wallCheckCorner.Parent = wallCheckToggle

-- 平滑度区域
local smoothSection = Instance.new("Frame")
smoothSection.Size = UDim2.new(1, -20, 0, 50)
smoothSection.Position = UDim2.new(0, 10, 0, 92)
smoothSection.BackgroundTransparency = 1
smoothSection.Parent = contentContainer

local smoothIcon = Instance.new("TextLabel")
smoothIcon.Size = UDim2.new(0, 20, 0, 20)
smoothIcon.Position = UDim2.new(0, 0, 0, 0)
smoothIcon.BackgroundTransparency = 1
smoothIcon.Text = "⚡"
smoothIcon.TextSize = 14
smoothIcon.TextColor3 = Color3.fromRGB(255, 200, 100)
smoothIcon.Parent = smoothSection

local smoothLabel = Instance.new("TextLabel")
smoothLabel.Size = UDim2.new(0, 50, 0, 20)
smoothLabel.Position = UDim2.new(0, 25, 0, 0)
smoothLabel.BackgroundTransparency = 1
smoothLabel.Text = "平滑度"
smoothLabel.Font = Enum.Font.GothamSemibold
smoothLabel.TextSize = 12
smoothLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
smoothLabel.TextXAlignment = Enum.TextXAlignment.Left
smoothLabel.Parent = smoothSection

local smoothValue = Instance.new("TextLabel")
smoothValue.Size = UDim2.new(0, 40, 0, 20)
smoothValue.Position = UDim2.new(1, -80, 0, 0)
smoothValue.BackgroundTransparency = 1
smoothValue.Text = string.format("%.2f", SMOOTHNESS)
smoothValue.Font = Enum.Font.GothamBold
smoothValue.TextSize = 12
smoothValue.TextColor3 = Color3.fromRGB(80, 180, 255)
smoothValue.TextXAlignment = Enum.TextXAlignment.Right
smoothValue.Parent = smoothSection

local smoothMinus = Instance.new("TextButton")
smoothMinus.Size = UDim2.new(0, 30, 0, 26)
smoothMinus.Position = UDim2.new(0, 0, 0, 24)
smoothMinus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
smoothMinus.Text = "−"
smoothMinus.Font = Enum.Font.GothamBold
smoothMinus.TextSize = 16
smoothMinus.TextColor3 = Color3.fromRGB(255, 200, 100)
smoothMinus.BorderSizePixel = 0
smoothMinus.Parent = smoothSection

local smoothMinusCorner = Instance.new("UICorner")
smoothMinusCorner.CornerRadius = UDim.new(0, 6)
smoothMinusCorner.Parent = smoothMinus

local smoothPlus = Instance.new("TextButton")
smoothPlus.Size = UDim2.new(0, 30, 0, 26)
smoothPlus.Position = UDim2.new(0, 65, 0, 24)
smoothPlus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
smoothPlus.Text = "+"
smoothPlus.Font = Enum.Font.GothamBold
smoothPlus.TextSize = 16
smoothPlus.TextColor3 = Color3.fromRGB(255, 200, 100)
smoothPlus.BorderSizePixel = 0
smoothPlus.Parent = smoothSection

local smoothPlusCorner = Instance.new("UICorner")
smoothPlusCorner.CornerRadius = UDim.new(0, 6)
smoothPlusCorner.Parent = smoothPlus

-- FOV区域
local fovSection = Instance.new("Frame")
fovSection.Size = UDim2.new(1, -20, 0, 50)
fovSection.Position = UDim2.new(0, 10, 0, 148)
fovSection.BackgroundTransparency = 1
fovSection.Parent = contentContainer

local fovIcon = Instance.new("TextLabel")
fovIcon.Size = UDim2.new(0, 20, 0, 20)
fovIcon.Position = UDim2.new(0, 0, 0, 0)
fovIcon.BackgroundTransparency = 1
fovIcon.Text = "🎯"
fovIcon.TextSize = 13
fovIcon.TextColor3 = Color3.fromRGB(255, 100, 100)
fovIcon.Parent = fovSection

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0, 70, 0, 20)
fovLabel.Position = UDim2.new(0, 25, 0, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "瞄准范围"
fovLabel.Font = Enum.Font.GothamSemibold
fovLabel.TextSize = 12
fovLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = fovSection

local fovValue = Instance.new("TextLabel")
fovValue.Size = UDim2.new(0, 40, 0, 20)
fovValue.Position = UDim2.new(1, -80, 0, 0)
fovValue.BackgroundTransparency = 1
fovValue.Text = tostring(FOV_RADIUS)
fovValue.Font = Enum.Font.GothamBold
fovValue.TextSize = 12
fovValue.TextColor3 = Color3.fromRGB(80, 180, 255)
fovValue.TextXAlignment = Enum.TextXAlignment.Right
fovValue.Parent = fovSection

local fovMinus = Instance.new("TextButton")
fovMinus.Size = UDim2.new(0, 30, 0, 26)
fovMinus.Position = UDim2.new(0, 0, 0, 24)
fovMinus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
fovMinus.Text = "−"
fovMinus.Font = Enum.Font.GothamBold
fovMinus.TextSize = 16
fovMinus.TextColor3 = Color3.fromRGB(255, 200, 100)
fovMinus.BorderSizePixel = 0
fovMinus.Parent = fovSection

local fovMinusCorner = Instance.new("UICorner")
fovMinusCorner.CornerRadius = UDim.new(0, 6)
fovMinusCorner.Parent = fovMinus

local fovPlus = Instance.new("TextButton")
fovPlus.Size = UDim2.new(0, 30, 0, 26)
fovPlus.Position = UDim2.new(0, 65, 0, 24)
fovPlus.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
fovPlus.Text = "+"
fovPlus.Font = Enum.Font.GothamBold
fovPlus.TextSize = 16
fovPlus.TextColor3 = Color3.fromRGB(255, 200, 100)
fovPlus.BorderSizePixel = 0
fovPlus.Parent = fovSection

local fovPlusCorner = Instance.new("UICorner")
fovPlusCorner.CornerRadius = UDim.new(0, 6)
fovPlusCorner.Parent = fovPlus

-- 快捷键区域
local keySection = Instance.new("Frame")
keySection.Size = UDim2.new(1, -20, 0, 45)
keySection.Position = UDim2.new(0, 10, 0, 203)
keySection.BackgroundTransparency = 1
keySection.Parent = contentContainer

local keyIcon = Instance.new("TextLabel")
keyIcon.Size = UDim2.new(0, 20, 0, 20)
keyIcon.Position = UDim2.new(0, 0, 0, 0)
keyIcon.BackgroundTransparency = 1
keyIcon.Text = "⌨️"
keyIcon.TextSize = 13
keyIcon.TextColor3 = Color3.fromRGB(180, 180, 255)
keyIcon.Parent = keySection

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0, 50, 0, 20)
keyLabel.Position = UDim2.new(0, 25, 0, 0)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "快捷键"
keyLabel.Font = Enum.Font.GothamSemibold
keyLabel.TextSize = 12
keyLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = keySection

local keyDisplay = Instance.new("TextLabel")
keyDisplay.Size = UDim2.new(0, 50, 0, 26)
keyDisplay.Position = UDim2.new(1, -115, 0, 19)
keyDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
keyDisplay.Text = tostring(AIMBOT_KEY):sub(14)
keyDisplay.Font = Enum.Font.GothamBold
keyDisplay.TextSize = 13
keyDisplay.TextColor3 = Color3.fromRGB(255, 200, 100)
keyDisplay.TextXAlignment = Enum.TextXAlignment.Center
keyDisplay.Parent = keySection

local keyDisplayCorner = Instance.new("UICorner")
keyDisplayCorner.CornerRadius = UDim.new(0, 6)
keyDisplayCorner.Parent = keyDisplay

local changeKeyBtn = Instance.new("TextButton")
changeKeyBtn.Size = UDim2.new(0, 55, 0, 26)
changeKeyBtn.Position = UDim2.new(1, -60, 0, 19)
changeKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 160)
changeKeyBtn.Text = "改键"
changeKeyBtn.Font = Enum.Font.GothamSemibold
changeKeyBtn.TextSize = 11
changeKeyBtn.TextColor3 = Color3.fromRGB(220, 220, 255)
changeKeyBtn.BorderSizePixel = 0
changeKeyBtn.Parent = keySection

local changeKeyCorner = Instance.new("UICorner")
changeKeyCorner.CornerRadius = UDim.new(0, 6)
changeKeyCorner.Parent = changeKeyBtn

-- 底部提示
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 24)
footer.Position = UDim2.new(0, 0, 1, -24)
footer.BackgroundTransparency = 1
footer.Text = "MerzzL | 锁定单一目标"
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextColor3 = Color3.fromRGB(100, 100, 130)
footer.Parent = contentContainer

-- ================== 销毁函数（使所有功能失效） ==================
local function destroyScript()
    if not scriptActive then return end
    scriptActive = false
    
    -- 断开所有连接
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    
    -- 断开渲染连接
    if renderConnection then
        pcall(function() renderConnection:Disconnect() end)
        renderConnection = nil
    end
    
    -- 恢复鼠标
    pcall(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end)
    
    -- 销毁GUI
    pcall(function() screenGui:Destroy() end)
    pcall(function() menuGui:Destroy() end)
    
    print("[自瞄] 脚本已销毁，所有功能已失效")
end

-- ================== 最小化功能 ==================
local function toggleMinimize()
    if not scriptActive then return end
    minimized = not minimized
    if minimized then
        contentContainer.Visible = false
        mainFrame.Size = UDim2.new(0, 240, 0, 32)
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 240, 0, 32)
        }):Play()
        MinBtn.Text = "□"
    else
        contentContainer.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 240, 0, 360)
        }):Play()
        MinBtn.Text = "—"
    end
end

MinBtn.MouseButton1Click:Connect(toggleMinimize)

-- 关闭按钮 - 销毁脚本
CloseBtn.MouseButton1Click:Connect(function()
    destroyScript()
end)

-- ================== 功能逻辑 ==================
local function updateAimbotState()
    if not scriptActive then return end
    if AIMBOT_ENABLED then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
        toggleBtn.Text = "● 启用"
        statusDot.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
        if scriptActive then
            fovCircle.Visible = true
            fovOuter.Visible = true
            dot.Visible = true
        end
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        toggleBtn.Text = "○ 禁用"
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        fovCircle.Visible = false
        fovOuter.Visible = false
        dot.Visible = false
        if not scriptActive then return end
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
        MOUSE_LOCKED = false
        lockedTarget = nil
    end
end

local function updateWallCheckState()
    if WALL_CHECK_ENABLED then
        wallCheckToggle.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
        wallCheckToggle.Text = "● 开"
    else
        wallCheckToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        wallCheckToggle.Text = "○ 关"
    end
end

local function updateFOVSize()
    if not scriptActive then return end
    fovCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
    fovOuter.Size = UDim2.new(0, FOV_RADIUS*2 + 6, 0, FOV_RADIUS*2 + 6)
    fovValue.Text = tostring(FOV_RADIUS)
end

-- 墙壁检测函数
local function isVisible(targetCharacter)
    if not scriptActive then return false end
    if not WALL_CHECK_ENABLED then return true end  -- 关闭墙壁检测时始终返回true
    if not targetCharacter then return false end
    
    local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local origin = camera.CFrame.Position
    local direction = hrp.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character, targetCharacter}
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function getClosestInFOV()
    if not scriptActive then return nil end
    local closest = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and hrp then
                local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < FOV_RADIUS and dist < shortestDistance and isVisible(plr.Character) then
                        closest = plr
                        shortestDistance = dist
                    end
                end
            end
        end
    end
    return closest
end

-- 按钮事件
smoothMinus.MouseButton1Click:Connect(function()
    if not scriptActive then return end
    SMOOTHNESS = math.clamp(SMOOTHNESS - 0.05, 0.01, 1)
    smoothValue.Text = string.format("%.2f", SMOOTHNESS)
end)

smoothPlus.MouseButton1Click:Connect(function()
    if not scriptActive then return end
    SMOOTHNESS = math.clamp(SMOOTHNESS + 0.05, 0.01, 1)
    smoothValue.Text = string.format("%.2f", SMOOTHNESS)
end)

fovMinus.MouseButton1Click:Connect(function()
    if not scriptActive then return end
    FOV_RADIUS = math.clamp(FOV_RADIUS - 10, 50, 400)
    updateFOVSize()
end)

fovPlus.MouseButton1Click:Connect(function()
    if not scriptActive then return end
    FOV_RADIUS = math.clamp(FOV_RADIUS + 10, 50, 400)
    updateFOVSize()
end)

toggleBtn.MouseButton1Click:Connect(function()
    if not scriptActive then return end
    AIMBOT_ENABLED = not AIMBOT_ENABLED
    updateAimbotState()
end)

wallCheckToggle.MouseButton1Click:Connect(function()
    if not scriptActive then return end
    WALL_CHECK_ENABLED = not WALL_CHECK_ENABLED
    updateWallCheckState()
end)

changeKeyBtn.MouseButton1Click:Connect(function()
    if not scriptActive then return end
    changingKey = true
    changeKeyBtn.Text = "按键..."
    changeKeyBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 60)
end)

-- 输入监听
local inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if not scriptActive then return end
    if processed then return end
    if changingKey then
        changingKey = false
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            AIMBOT_KEY = input.KeyCode
            keyDisplay.Text = tostring(AIMBOT_KEY):sub(14)
        end
        changeKeyBtn.Text = "改键"
        changeKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 160)
        return
    end
    if input.KeyCode == AIMBOT_KEY then
        AIMBOT_ENABLED = not AIMBOT_ENABLED
        updateAimbotState()
    end
end)
table.insert(connections, inputConnection)

-- 自瞄核心渲染
renderConnection = RunService.RenderStepped:Connect(function()
    if not scriptActive then return end
    if not AIMBOT_ENABLED then
        if MOUSE_LOCKED then
            pcall(function()
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end)
            MOUSE_LOCKED = false
        end
        lockedTarget = nil
        return
    end

    if lockedTarget and lockedTarget.Character then
        local hum = lockedTarget.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            target = lockedTarget
        else
            lockedTarget = nil
        end
    end

    if not lockedTarget then
        lockedTarget = getClosestInFOV()
        target = lockedTarget
    end

    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local camPos = camera.CFrame.Position
            local lookAt = CFrame.new(camPos, hrp.Position)
            camera.CFrame = camera.CFrame:Lerp(lookAt, SMOOTHNESS)
            if not MOUSE_LOCKED then
                pcall(function()
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                end)
                MOUSE_LOCKED = true
            end
        end
    else
        if MOUSE_LOCKED then
            pcall(function()
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end)
            MOUSE_LOCKED = false
        end
        lockedTarget = nil
    end
end)

-- 角色重生处理
local charAddedConnection = player.CharacterAdded:Connect(function()
    if not scriptActive then return end
    task.wait(0.5)
    pcall(function()
        camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end)
    MOUSE_LOCKED = false
    lockedTarget = nil
end)
table.insert(connections, charAddedConnection)

-- 初始化
updateAimbotState()
updateWallCheckState()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "自瞄系统",
        Text = "已加载 | 墙壁检测: " .. (WALL_CHECK_ENABLED and "开启" or "关闭"),
        Duration = 3
    })
end)

print("[自瞄] 脚本已加载 | 关闭UI即销毁所有功能")
