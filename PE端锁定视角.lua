local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local isLocked = false
local isDragging = false
local dragStart = Vector2.new()
local btnStartPos = UDim2.new()

-- 创建单个 🔒 UI
local sg = Instance.new("ScreenGui")
sg.Name = "ViewLockUI_SingleLock"
sg.Parent = lp:WaitForChild("PlayerGui")
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.ResetOnSpawn = false

local btn = Instance.new("TextButton")
btn.Name = "LockBtn"
btn.Size = UDim2.new(0,44,0,44)
btn.Position = UDim2.new(1,-54,1,-54)
btn.BackgroundTransparency = 0.2
btn.BackgroundColor3 = Color3.new(0.15,0.15,0.15)
btn.Text = "🔒"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 26
btn.TextColor3 = Color3.new(1,1,1)
btn.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1,0)
corner.Parent = btn

-- 拖动逻辑
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        btnStartPos = btn.Position
        isDragging = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- 切换锁定
local function toggleLock()
    isLocked = not isLocked
    btn.Text = isLocked and "🔓" or "🔒"
end
btn.Activated:Connect(toggleLock)

-- 【最终正确版】只提取相机水平旋转，垂直不动，人物永远和镜头同向，实时跟随，不会对视
RunService.RenderStepped:Connect(function()
    if not isLocked then return end
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- 提取相机 Yaw（水平左右），直接应用，彻底解决反向问题
    local _, yaw = cam.CFrame:ToEulerAnglesYXZ()
    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, yaw, 0)
end)

print("✅ 视角锁定最终修复：实时跟随、方向正确、无反向对视")