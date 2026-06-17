local placeID = game.PlaceId
if placeID ~= 10449761463 then
    print("当前游戏不是 The Strongest Battlegrounds")
    return
end
--

--
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local character = localPlayer.Character
local humanoid = character and character:WaitForChild("Humanoid")
local humanoidRootPart = character and character:WaitForChild("HumanoidRootPart")
local playerUserId = localPlayer.UserId
local playerName = localPlayer.Name

--

-- 游戏属性修改
local function exploits()

    if workspace:GetAttribute("VIPServer") ~= tostring(playerUserId) then
        workspace:SetAttribute("VIPServer", tostring(playerUserId))
    end
    if workspace:GetAttribute("VIPServerOwner") ~= playerName then
        workspace:SetAttribute("VIPServerOwner", playerName)
    end
    --

    if localPlayer:GetAttribute("ExtraSlots") == nil then
        localPlayer:SetAttribute("ExtraSlots", false)
    end
    --
    if localPlayer:GetAttribute("EmoteSearchBar") == nil then
        localPlayer:SetAttribute("EmoteSearchBar", false)
    end
    --
    if workspace:GetAttribute("NoDashCooldown") == nil then
        workspace:SetAttribute("NoDashCooldown", false)
    end
    --
    if workspace:GetAttribute("NoFatigue") == nil then
        workspace:SetAttribute("NoFatigue", false)
    end

end
exploits()

-- 
local tspeed = 0.1
local tpwalking = false

--

--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MerzzL script",
   Icon = "user",
   LoadingTitle = "Rayfield",
   LoadingSubtitle = "作者MerzzL(SKID)",
   ShowText = "界面",
   Theme = "Default",

   ToggleUIKeybind = "F",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TSB-Script"
   },

   Discord = {
      Enabled = false, 
      Invite = "noinvitelink", 
      RememberJoins = true 
   },

   KeySystem = false, 
   KeySettings = {
      Title = "无标题",
      Subtitle = "密钥系统",
      Note = "未提供获取密钥的方式",
      FileName = "Key",
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"Hello"} 
   }
})
--

-- 标签页
local mainTab = Window:CreateTab("主要", "user")
local teleportTab = Window:CreateTab("传送", "map")
--

localPlayer.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

mainTab:CreateDivider()

mainTab:CreateToggle({
   Name = "速度增强",
   CurrentValue = false,
   Flag = "SpeedBoostToggle",
   Callback = function(Value)
       tpwalking = Value
   end,
})

mainTab:CreateSlider({
   Name = "速度倍数",
   Range = {0, 5},
   Increment = 0.1,
   Suffix = "倍",
   CurrentValue = 0.1,
   Flag = "SpeedBoostSlider",
   Callback = function(Value)
       tspeed = Value
   end,
})

runService.Heartbeat:Connect(function()
    if tpwalking and character and humanoid then
        if humanoid.MoveDirection.Magnitude > 0 then
            if tspeed then
                 humanoidRootPart.CFrame = humanoidRootPart.CFrame + (humanoid.MoveDirection * tspeed)
            end
        end
    end
end)

mainTab:CreateToggle({
   Name = "跳跃增强",
   CurrentValue = false,
   Flag = "JumpBoostToggle",
   Callback = function(Value)
       humanoid.UseJumpPower = not Value
   end,
})

mainTab:CreateSlider({
   Name = "跳跃高度",
   Range = {7.2, 500},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 7.2,
   Flag = "JumpBoostSlider",
   Callback = function(Value)
       humanoid.JumpHeight = Value
   end,
})

mainTab:CreateDivider()

mainTab:CreateSlider({
   Name = "重力",
   Range = {0, 192.6},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 192.6,
   Flag = "GravitySlider",
   Callback = function(Value)
       workspace.Gravity = Value
   end,
})

mainTab:CreateSlider({
   Name = "视野角度",
   Range = {0, 120},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 70,
   Flag = "FOVSlider",
   Callback = function(Value)
       workspace.CurrentCamera.FieldOfView = Value
   end,
})

mainTab:CreateDivider()

mainTab:CreateSection("功能修改")

mainTab:CreateToggle({
   Name = "无冲刺冷却",
   CurrentValue = false,
   Flag = "noDashCooldownToggle",
   Callback = function(Value)
       workspace:SetAttribute("NoDashCooldown", Value)
   end,
})

mainTab:CreateToggle({
   Name = "无体力消耗",
   CurrentValue = false,
   Flag = "noFatigueToggle",
   Callback = function(Value)
       workspace:SetAttribute("NoFatigue", Value)
   end,
})

mainTab:CreateDivider()

mainTab:CreateToggle({
   Name = "表情额外槽位",
   CurrentValue = false,
   Flag = "emotesExtraSlotsToggle",
   Callback = function(Value)
         localPlayer:SetAttribute("ExtraSlots", Value)
   end,
})

mainTab:CreateToggle({
   Name = "表情搜索栏",
   CurrentValue = false,
   Flag = "emotesSearchBarToggle",
   Callback = function(Value)
       localPlayer:SetAttribute("EmoteSearchBar", Value)
   end,
})

mainTab:CreateDivider()
mainTab:CreateSection("ESP 死亡倒计时")

-- 技能检测表
local strongSkills = {
    ["Omni Directional Punch"] = true,
    ["Death Counter"] = true,
    ["Serious Punch"] = true,
    ["Table Flip"] = true
}
local weakSkills = {
    ["Consecutive Punches"] = true,
    ["Normal Punch"] = true,
    ["Shove"] = true,
    ["Uppercut"] = true
}

local espEnabled = false
local state = {}

-- 创建 Billboard（增加 isSelf 参数控制颜色）
local function createBillboard(target, text, isSelf)
    if not (target and target:FindFirstChild("Head")) then return end
    local bb = target.Head:FindFirstChild("SkillTag") or Instance.new("BillboardGui")
    bb.Name = "SkillTag"
    bb.Size = UDim2.new(0, 80, 0, 35)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.Adornee = target.Head
    bb.AlwaysOnTop = true
    if not bb.Parent then bb.Parent = target.Head end

    local label = bb:FindFirstChild("TextLabel") or Instance.new("TextLabel", bb)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = isSelf and Color3.fromRGB(0, 255, 255) or Color3.new(1,1,1)  -- 自己是青色，别人是白色
    label.TextStrokeTransparency = 0.5
    label.Text = text
end

-- 移除 Billboard
local function removeBillboard(target)
    if target and target:FindFirstChild("Head") and target.Head:FindFirstChild("SkillTag") then
        target.Head.SkillTag:Destroy()
    end
end

-- 获取技能类型
local function getSkillType(backpack)
    for _, tool in ipairs(backpack:GetChildren()) do
        if strongSkills[tool.Name] then return "strong" end
        if weakSkills[tool.Name] then return "weak" end
    end
end

-- 清除所有 Billboard
local function clearAllBillboards()
    for _, plr in ipairs(players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") then
            removeBillboard(plr.Character)
        end
    end
    state = {}
end

-- ESP 开关（默认开启）
mainTab:CreateToggle({
    Name = "死亡倒计时",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        espEnabled = Value
        if not Value then
            clearAllBillboards()
        end
    end
})

-- ESP 核心检测循环（包含自己）
runService.Heartbeat:Connect(function()
    if not espEnabled then return end
    for _, plr in ipairs(players:GetPlayers()) do
        -- 移除 plr ~= localPlayer 的限制，现在包含自己
        local char = plr.Character
        local backpack = plr:FindFirstChildOfClass("Backpack")
        if char and backpack then
            local skillType = getSkillType(backpack)
            local lastState = state[plr]

            -- 判断是否为自己
            local isSelf = (plr == localPlayer)

            if not lastState then
                state[plr] = skillType
                if skillType == "strong" then
                    createBillboard(char, "💢", isSelf)
                else
                    removeBillboard(char)
                end
            else
                if skillType == "strong" then
                    if lastState ~= "strong" then
                        createBillboard(char, "💢", isSelf)
                    end
                    state[plr] = "strong"
                elseif skillType == "weak" and lastState == "strong" then
                    createBillboard(char, "☠", isSelf)
                    state[plr] = "weak"
                    task.delay(math.random(8,9), function()
                        if state[plr] == "weak" then
                            removeBillboard(char)
                        end
                    end)
                end
            end
        end
    end
end)

-- 玩家离开时清理
players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        removeBillboard(plr.Character)
    end
    state[plr] = nil
end)
----------------------------------------------------------------------------------
-- 传送标签页

teleportTab:CreateSection("传送点")

teleportTab:CreateButton({
    Name = "中央区",
    Callback = function()
        humanoidRootPart.CFrame = CFrame.new(148, 441, 27)
    end
})

teleportTab:CreateButton({
    Name = "原子房间",
    Callback = function()
        humanoidRootPart.CFrame = CFrame.new(1079, 155, 23003)
    end
})

teleportTab:CreateButton({
    Name = "死亡计数器房间",
    Callback = function()
        humanoidRootPart.CFrame = CFrame.new(-92, 29, 20347)
    end
})

teleportTab:CreateButton({
    Name = "基岩板",
    Callback = function()
        humanoidRootPart.CFrame = CFrame.new(968, 20, 23088)
    end
})

teleportTab:CreateButton({
    Name = "山丘 1",
    Callback = function()
        humanoidRootPart.CFrame = CFrame.new(266, 699, 458)
    end
})

teleportTab:CreateButton({
    Name = "山丘 2",
    Callback = function()
        humanoidRootPart.CFrame = CFrame.new(551, 630, -265)
    end
})

teleportTab:CreateButton({
    Name = "山丘 3",
    Callback = function()
        humanoidRootPart.CFrame = CFrame.new(-107, 642, -328)
    end
})
