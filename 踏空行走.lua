-- 终极版：绝对可拖动 + 一体UI + 红销毁按钮 + 零报错
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

local Enabled = false
local FloorParts = {}
local AirWalkLoop
local needDoubleClick = false

-- UI
local Gui = Instance.new("ScreenGui")
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = LP.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 95, 0, 68)
Main.Position = UDim2.new(0.12,0,0.55,0)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Parent = Gui

-- ======================================
-- 【最强全局拖拽 必能用 电脑/手机】
-- ======================================
local dragging = false
local diffX, diffY

UserInputService.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        if Main.AbsolutePosition.X < inp.Position.X and Main.AbsolutePosition.X + Main.AbsoluteSize.X > inp.Position.X and
           Main.AbsolutePosition.Y < inp.Position.Y and Main.AbsolutePosition.Y + Main.AbsoluteSize.Y > inp.Position.Y then
            dragging = true
            diffX = inp.Position.X - Main.Position.X.Offset
            diffY = inp.Position.Y - Main.Position.Y.Offset
        end
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        Main.Position = UDim2.new(0, inp.Position.X - diffX, 0, inp.Position.Y - diffY)
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 开关按钮
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1,0,0,38)
Toggle.BackgroundTransparency = 1
Toggle.Text = "踏空行走 [关闭]"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 13
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Parent = Main

-- 销毁按钮 红色
local DestroyBtn = Instance.new("TextButton")
DestroyBtn.Size = UDim2.new(1,0,0,30)
DestroyBtn.Position = UDim2.new(0,0,0,38)
DestroyBtn.BackgroundColor3 = Color3.fromRGB(130, 20, 20)
DestroyBtn.Text = "销毁UI"
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.TextSize = 12
DestroyBtn.TextColor3 = Color3.new(1,1,1)
DestroyBtn.Parent = Main

-- 踏空开关
Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    if Enabled then
        Toggle.Text = "踏空行走 [开启]"
        Main.BackgroundColor3 = Color3.fromRGB(30,70,40)
    else
        Toggle.Text = "踏空行走 [关闭]"
        Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
        for _,v in pairs(FloorParts) do if v.Parent then v:Destroy() end end
        FloorParts = {}
    end
end)

-- 销毁逻辑
local function RemoveUI()
    Enabled = false
    if AirWalkLoop then AirWalkLoop:Disconnect() end
    for _,v in pairs(FloorParts) do if v.Parent then v:Destroy() end end
    Gui:Destroy()
end

local function ResetDestroy()
    needDoubleClick = false
    DestroyBtn.Text = "销毁UI"
    DestroyBtn.BackgroundColor3 = Color3.fromRGB(130,20,20)
end

DestroyBtn.MouseButton1Click:Connect(function()
    if not needDoubleClick then
        needDoubleClick = true
        DestroyBtn.Text = "确认销毁？"
        DestroyBtn.BackgroundColor3 = Color3.fromRGB(190,30,30)
        task.delay(2.5, ResetDestroy)
    else
        RemoveUI()
    end
end)

-- 踏空行走核心
AirWalkLoop = RunService.RenderStepped:Connect(function()
    if not Enabled or not Root.Parent then return end
    if Humanoid.FloorMaterial ~= Enum.Material.Air then return end

    local Fake = Instance.new("Part")
    Fake.Size = Vector3.new(0.4,0.2,0.4)
    Fake.Position = Root.Position - Vector3.new(0,3.1,0)
    Fake.Anchored = true
    Fake.CanCollide = true
    Fake.Transparency = 0.8
    Fake.CastShadow = false
    Fake.Parent = workspace

    table.insert(FloorParts, Fake)
    if #FloorParts > 6 then
        local old = table.remove(FloorParts,1)
        if old.Parent then old:Destroy() end
    end
end)

-- 角色重生
LP.CharacterAdded:Connect(function(newChar)
    task.wait(0.2)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    Root = newChar:WaitForChild("HumanoidRootPart")
end)
