-- 修复：不会自动上浮、不会飞天 纯踏空行走 + 两次点击销毁(防误触修复版)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local Enabled = false
local FloorParts = {}
local AirWalkLoop

-- 防误触变量
local needDoubleClick = false
local resetTimer = nil

-- 可拖动UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AirWalkUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player.PlayerGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 95, 0, 38)
ToggleBtn.Position = UDim2.new(0.12, 0, 0.55, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleBtn.Text = "踏空行走 [关闭]"
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

-- 销毁按钮
local DestroyBtn = Instance.new("TextButton")
DestroyBtn.Size = UDim2.new(0, 95, 0, 28)
DestroyBtn.Position = UDim2.new(0.12, 0, 0.62, 0)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(90,20,20)
DestroyBtn.TextColor3 = Color3.new(1,1,1)
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.TextSize = 12
DestroyBtn.Text = "销毁UI"
DestroyBtn.Draggable = true
DestroyBtn.Parent = ScreenGui

-- 开关切换
ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        ToggleBtn.Text = "踏空行走 [开启]"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,90,40)
    else
        ToggleBtn.Text = "踏空行走 [关闭]"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
        for _,v in pairs(FloorParts) do
            if v and v.Parent then v:Destroy() end
        end
        FloorParts = {}
    end
end)

-- 彻底销毁
local function DestroyAirWalkUI()
    Enabled = false
    if AirWalkLoop then
        AirWalkLoop:Disconnect()
    end
    for _,v in pairs(FloorParts) do
        if v and v.Parent then v:Destroy() end
    end
    FloorParts = {}
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

-- 重置销毁按钮状态
local function ResetDestroyState()
    needDoubleClick = false
    if resetTimer then
        task.cancel(resetTimer)
        resetTimer = nil
    end
    if DestroyBtn.Parent then
        DestroyBtn.Text = "销毁UI"
        DestroyBtn.BackgroundColor3 = Color3.fromRGB(90,20,20)
    end
end

-- 双击防误触逻辑
DestroyBtn.MouseButton1Click:Connect(function()
    if not needDoubleClick then
        -- 第一次点击
        needDoubleClick = true
        DestroyBtn.Text = "确认销毁？"
        DestroyBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
        -- 超时自动重置
        resetTimer = task.delay(2.5, ResetDestroyState)
    else
        -- 第二次点击 = 执行销毁
        DestroyAirWalkUI()
    end
end)

-- 核心踏空行走
AirWalkLoop = RunService.RenderStepped:Connect(function()
    if not Enabled or not Root or not Root.Parent then return end
    if Humanoid.FloorMaterial ~= Enum.Material.Air then return end

    local placePos = Root.Position - Vector3.new(0, 3.1, 0)

    local FakeFloor = Instance.new("Part")
    FakeFloor.Name = "AirWalkBlock"
    FakeFloor.Size = Vector3.new(2.8, 0.4, 2.8)
    FakeFloor.Position = placePos
    FakeFloor.Transparency = 0.9
    FakeFloor.CanCollide = true
    FakeFloor.Anchored = true
    FakeFloor.CastShadow = false
    FakeFloor.CanTouch = true
    FakeFloor.Parent = workspace

    table.insert(FloorParts, FakeFloor)

    while #FloorParts > 6 do
        local old = table.remove(FloorParts, 1)
        if old and old.Parent then old:Destroy() end
    end
end)

-- 角色重生刷新
Player.CharacterAdded:Connect(function(newChar)
    task.wait(0.2)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")
end)