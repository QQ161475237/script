local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowCustomCursor = true
local Window = Library:CreateWindow({
	Title = "MerTSB",
	Footer = "此脚本完全免费  Q群：544199307",
	NotifySide = "Right",
	ShowCustomCursor = true,

	BackgroundImage = "rbxassetid://103051766393042",
	BackgroundTransparency = 0.15,
	BackgroundScale = 1,
})

local Tabs = {
	Player = Window:AddTab("玩家", "user"),
	ESP = Window:AddTab("视觉", "eye"),
    OtherTab = Window:AddTab("其它",'boxes'),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- =============================================
-- 【功能 1】防防反监控（可开关）
-- =============================================
local AntiCounterTab = Tabs.Player:AddLeftGroupbox("🔥 防反预警", "shield")
AntiCounterTab:AddToggle("AntiCounterAlert", {
	Text = "防反检测（高亮+提示）",
	Default = false,
	Callback = function(state)
		getgenv().AntiCounterEnabled = state
	end
})

local COUNTER_ID_LIST = {"15311685628","12351854556"}
local TipGui, TipFrame
local HighlightCache = {}

local function InitAntiCounterUI()
	if TipGui then TipGui:Destroy() end
	local Player = game.Players.LocalPlayer
	local PlayerGui = Player.PlayerGui

	TipGui = Instance.new("ScreenGui")
	TipGui.Name = "CounterTipGui"
	TipGui.ResetOnSpawn = false
	TipGui.Parent = PlayerGui

	TipFrame = Instance.new("Frame")
	TipFrame.Size = UDim2.new(0,320,0,50)
	TipFrame.Position = UDim2.new(0.5,-160,0.02,0)
	TipFrame.BackgroundColor3 = Color3.new(0.15,0,0)
	TipFrame.BackgroundTransparency = 0.3
	TipFrame.Visible = false
	TipFrame.Parent = TipGui

	local TipText = Instance.new("TextLabel")
	TipText.Size = UDim2.new(1,0,1,0)
	TipText.BackgroundTransparency = 1
	TipText.Text = "🔥有人使用防反🔥"
	TipText.TextColor3 = Color3.new(1,0.2,0.2)
	TipText.Font = Enum.Font.GothamBold
	TipText.TextSize = 22
	TipText.Parent = TipFrame
end

local function GetPureId(s) return string.match(s,"%d+") end
local function IsCounterAnim(char)
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local anim = hum and hum:FindFirstChildOfClass("Animator")
	if not anim then return false end
	for _,t in pairs(anim:GetPlayingAnimationTracks()) do
		local a = t.Animation
		if a and table.find(COUNTER_ID_LIST, GetPureId(a.AnimationId)) then
			return true
		end
	end
	return false
end

local function SetHighlight(p, on)
	if not p.Character then return end
	if on then
		if not HighlightCache[p] then
			local hl = Instance.new("Highlight")
			hl.FillColor = Color3.new(1,0,0)
			hl.OutlineColor = Color3.new(1,0,0)
			hl.FillTransparency = 0.5
			hl.OutlineTransparency = 0
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = p.Character
			HighlightCache[p] = hl
		end
	else
		if HighlightCache[p] then
			HighlightCache[p]:Destroy()
			HighlightCache[p] = nil
		end
	end
end

InitAntiCounterUI()
game.RunService.Heartbeat:Connect(function()
	if not getgenv().AntiCounterEnabled then
		TipFrame.Visible = false
		for p in pairs(HighlightCache) do SetHighlight(p,false) end
		return
	end
	local has = false
	for _,plr in pairs(game.Players:GetPlayers()) do
		local c = IsCounterAnim(plr.Character)
		SetHighlight(plr,c)
		if c then has = true end
	end
	TipFrame.Visible = has
end)

-- =============================================
-- 【功能 2】DashCD 显示 改为按钮启动
-- =============================================
local DashTab = Tabs.Player:AddLeftGroupbox("⚡ 动作冷却", "timer")
DashTab:AddButton("开启侧闪/冲刺拳CD显示", function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local player = Players.LocalPlayer
	local playerGui = player.PlayerGui

	local DASH_ANIM_IDS = {"rbxassetid://10480793962","rbxassetid://10480796021"}
	local PUNCH_ANIM_IDS = {"rbxassetid://10479335397","rbxassetid://10491993682"}
	local TEXTURE_ID = "rbxassetid://103051766393042"

	local old = playerGui:FindFirstChild("DashCDUI")
	if old then old:Destroy() end

	local MainUI = Instance.new("ScreenGui")
	MainUI.Name = "DashCDUI"
	MainUI.ResetOnSpawn = false
	MainUI.Parent = playerGui

	local Panel = Instance.new("Frame")
	Panel.Size = UDim2.new(0,280,0,175)
	Panel.Position = UDim2.new(0.05,0,0.5,-87)
	Panel.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
	Panel.BackgroundTransparency = 0.15
	Panel.Parent = MainUI

	local drag = false
	Panel.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true
			local s = i.Position
			local p = Panel.Position
			UIS.InputChanged:Connect(function(ch)
				if drag and ch.UserInputType == Enum.UserInputType.MouseMovement then
					local d = ch.Position - s
					Panel.Position = UDim2.new(p.X.Scale,p.X.Offset+d.X,p.Y.Scale,p.Y.Offset+d.Y)
				end
			end)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
	end)

	local bg = Instance.new("ImageLabel")
	bg.Size = UDim2.new(1,0,1,0)
	bg.BackgroundTransparency = 1
	bg.Image = TEXTURE_ID
	bg.Parent = Panel

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,8)
	corner.Parent = Panel

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0,22,0,22)
	close.Position = UDim2.new(1,-28,0,4)
	close.BackgroundTransparency = 1
	close.Text = "X"
	close.TextColor3 = Color3.new(1,0.5,0.5)
	close.Parent = Panel
	close.MouseButton1Click:Connect(function() MainUI:Destroy() end)

	local L1 = Instance.new("TextLabel")
	L1.Size = UDim2.new(1,-20,0,22)
	L1.Position = UDim2.new(0,10,0,12)
	L1.BackgroundTransparency = 1
	L1.Text = "侧闪 (就绪)"
	L1.TextColor3 = Color3.new(1,1,1)
	L1.TextSize = 25
	L1.Parent = Panel

	local B1 = Instance.new("Frame")
	B1.Size = UDim2.new(0.9,0,0,18)
	B1.Position = UDim2.new(0.05,0,0.33,0)
	B1.BackgroundColor3 = Color3.new(0.15,0.15,0.2)
	B1.Parent = Panel

	local Bar1 = Instance.new("Frame")
	Bar1.Size = UDim2.new(0,0,1,0)
	Bar1.BackgroundColor3 = Color3.new(0,1,0.5)
	Bar1.Parent = B1

	local L2 = Instance.new("TextLabel")
	L2.Size = UDim2.new(1,-20,0,22)
	L2.Position = UDim2.new(0,10,0,92)
	L2.BackgroundTransparency = 1
	L2.Text = "冲刺拳/后闪 (就绪)"
	L2.TextColor3 = Color3.new(1,1,1)
	L2.TextSize = 25
	L2.Parent = Panel

	local B2 = Instance.new("Frame")
	B2.Size = UDim2.new(0.9,0,0,18)
	B2.Position = UDim2.new(0.05,0,0.74,0)
	B2.BackgroundColor3 = Color3.new(0.15,0.15,0.2)
	B2.Parent = Panel

	local Bar2 = Instance.new("Frame")
	Bar2.Size = UDim2.new(0,0,1,0)
	Bar2.BackgroundColor3 = Color3.new(0,1,0.5)
	Bar2.Parent = B2

	local cd1,cd2 = 0,0
	local dur1,dur2 = 2,5
	local ud,up = false

	local function play(list)
		local c = player.Character
		if not c then return false end
		local h = c:FindFirstChildOfClass("Humanoid")
		local a = h and h:FindFirstChildOfClass("Animator")
		if not a then return false end
		for _,t in pairs(a:GetPlayingAnimationTracks()) do
			local anim = t.Animation
			if anim and table.find(list, anim.AnimationId) then return true end
		end
		return false
	end

	RunService.Heartbeat:Connect(function(dt)
		if cd1>0 then
			cd1 = math.max(0,cd1-dt)
			Bar1.Size = UDim2.new(cd1/dur1,0,1,0)
			if cd1<=0 then
				L1.Text = "侧闪 (就绪)"
				Bar1.BackgroundColor3 = Color3.new(0,1,0.5)
				ud = false
			end
		end
		if cd2>0 then
			cd2 = math.max(0,cd2-dt)
			Bar2.Size = UDim2.new(cd2/dur2,0,1,0)
			if cd2<=0 then
				L2.Text = "冲刺拳/后闪 (就绪)"
				Bar2.BackgroundColor3 = Color3.new(0,1,0.5)
				up = false
			end
		end
		if not ud and cd1<=0 and play(DASH_ANIM_IDS) then
			ud = true cd1=dur1
			Bar1.Size = UDim2.new(1,0,1,0)
			Bar1.BackgroundColor3 = Color3.new(0,0.7,1)
			L1.Text = "侧闪 (冷却中)"
		end
		if not up and cd2<=0 and play(PUNCH_ANIM_IDS) then
			up = true cd2=dur2
			Bar2.Size = UDim2.new(1,0,1,0)
			Bar2.BackgroundColor3 = Color3.new(1,0.4,0)
			L2.Text = "冲刺拳/后闪 (冷却中)"
		end
	end)
end)

-- =============================================
-- 【功能 3】Aimbot 自瞄（按钮启动）
-- =============================================
local AimbotTab = Tabs.Player:AddLeftGroupbox("🎯 自瞄", "crosshair")
AimbotTab:AddButton("启动自瞄(带GUI)", function()
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

local target = nil
local lockedTarget = nil
local MOUSE_LOCKED = false
local changingKey = false
local minimized = false 

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

local menuGui = Instance.new("ScreenGui")
menuGui.Name = "AimbotMenu"
menuGui.ResetOnSpawn = false
menuGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 290)
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

local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(1, 0, 0, 2)
accentBar.Position = UDim2.new(0, 0, 0, 0)
accentBar.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
accentBar.BorderSizePixel = 0
accentBar.Parent = mainFrame

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

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.BackgroundTransparency = 0.7
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseBtn

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -32)
contentContainer.Position = UDim2.new(0, 0, 0, 32)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.9, 0, 0, 1)
divider.Position = UDim2.new(0.05, 0, 0, 0)
divider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
divider.BorderSizePixel = 0
divider.Parent = contentContainer

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

local smoothSection = Instance.new("Frame")
smoothSection.Size = UDim2.new(1, -20, 0, 50)
smoothSection.Position = UDim2.new(0, 10, 0, 58)
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

local fovSection = Instance.new("Frame")
fovSection.Size = UDim2.new(1, -20, 0, 50)
fovSection.Position = UDim2.new(0, 10, 0, 113)
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

local keySection = Instance.new("Frame")
keySection.Size = UDim2.new(1, -20, 0, 45)
keySection.Position = UDim2.new(0, 10, 0, 168)
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

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 24)
footer.Position = UDim2.new(0, 0, 1, -24)
footer.BackgroundTransparency = 1
footer.Text = "MerzzL | 锁定单一目标"
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextColor3 = Color3.fromRGB(100, 100, 130)
footer.Parent = contentContainer

local function toggleMinimize()
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
			Size = UDim2.new(0, 240, 0, 290)
		}):Play()
		MinBtn.Text = "—"
	end
end

MinBtn.MouseButton1Click:Connect(toggleMinimize)
CloseBtn.MouseButton1Click:Connect(function() menuGui:Destroy() screenGui:Destroy() end)

local function updateAimbotState()
	if AIMBOT_ENABLED then
		toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
		toggleBtn.Text = "● 启用"
		statusDot.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
		fovCircle.Visible = true
		fovOuter.Visible = true
		dot.Visible = true
	else
		toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		toggleBtn.Text = "○ 禁用"
		statusDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		fovCircle.Visible = false
		fovOuter.Visible = false
		dot.Visible = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		MOUSE_LOCKED = false
		lockedTarget = nil
	end
end

local function updateFOVSize()
	fovCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
	fovOuter.Size = UDim2.new(0, FOV_RADIUS*2 + 6, 0, FOV_RADIUS*2 + 6)
	fovValue.Text = tostring(FOV_RADIUS)
end

smoothMinus.MouseButton1Click:Connect(function()
	SMOOTHNESS = math.clamp(SMOOTHNESS - 0.05, 0.01, 1)
	smoothValue.Text = string.format("%.2f", SMOOTHNESS)
end)

smoothPlus.MouseButton1Click:Connect(function()
	SMOOTHNESS = math.clamp(SMOOTHNESS + 0.05, 0.01, 1)
	smoothValue.Text = string.format("%.2f", SMOOTHNESS)
end)

fovMinus.MouseButton1Click:Connect(function()
	FOV_RADIUS = math.clamp(FOV_RADIUS - 10, 50, 400)
	updateFOVSize()
end)

fovPlus.MouseButton1Click:Connect(function()
	FOV_RADIUS = math.clamp(FOV_RADIUS + 10, 50, 400)
	updateFOVSize()
end)

toggleBtn.MouseButton1Click:Connect(function()
	AIMBOT_ENABLED = not AIMBOT_ENABLED
	updateAimbotState()
end)

changeKeyBtn.MouseButton1Click:Connect(function()
	changingKey = true
	changeKeyBtn.Text = "按键..."
	changeKeyBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 60)
end)

UserInputService.InputBegan:Connect(function(input, processed)
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

local function isVisible(targetCharacter)
	if not targetCharacter then return false end
	local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local origin = camera.CFrame.Position
	local direction = hrp.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {player.Character, targetCharacter}
	local result = Workspace:Raycast(origin, direction, params)
	return result == nil
end

local function getClosestInFOV()
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

RunService.RenderStepped:Connect(function()
	if not AIMBOT_ENABLED then
		if MOUSE_LOCKED then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
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
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
				MOUSE_LOCKED = true
			end
		end
	else
		if MOUSE_LOCKED then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			MOUSE_LOCKED = false
		end
		lockedTarget = nil
	end
end)

player.CharacterAdded:Connect(function()
	camera.CameraType = Enum.CameraType.Custom
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	MOUSE_LOCKED = false
	lockedTarget = nil
end)

updateAimbotState()

pcall(function()
	StarterGui:SetCore("SendNotification", {
		Title = "自瞄系统",
		Text = "已加载 | 锁定单一目标模式",
		Duration = 3
	})
end)
end)

-- =============================================
-- 【功能 4】隐身头部 + 幽灵腿（按钮）
-- =============================================
local GhostTab = Tabs.Player:AddLeftGroupbox("👻 无头断腿", "ghost")
GhostTab:AddButton("无头断腿客户端)", function()
getgenv().InvisibleHead = true
getgenv().PhantomLeg = true
 
repeat task.wait() until game:IsLoaded()
 
local plr = game:GetService("Players").LocalPlayer
 
local function purgeFaces(h)
    for _, x in ipairs(h:GetChildren()) do
        if x:IsA("Decal") then
            x.Transparency = 1
        end
    end
end
 
local function ghostHead(char)
    if not getgenv().InvisibleHead then return end
 
    local h = char:FindFirstChild("Head") or char:WaitForChild("Head", 2)
    if not h then return end
 
    h.Transparency = 1
    purgeFaces(h)
 
    h.ChildAdded:Connect(function(o)
        if o:IsA("Decal") then
            o.Transparency = 1
        end
    end)
 
    task.spawn(function()
        local t = os.clock()
        while os.clock() - t < 3 do
            purgeFaces(h)
            task.wait(0.12)
        end
    end)
end
 
local function shadowLeg(char)
    if not getgenv().PhantomLeg then return end
 
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2)
    if not hum then return end
 
    if hum.RigType == Enum.HumanoidRigType.R15 then
        local limbs = {
            {"RightLowerLeg", 902942093, true},
            {"RightUpperLeg", 902942096, false, 902843398},
            {"RightFoot",     902942089, true}
        }
 
        for _, info in ipairs(limbs) do
            local p = char:FindFirstChild(info[1])
            if p then
                p.MeshId = "http://www.roblox.com/asset/?id=" .. info[2]
                if info[3] then p.Transparency = 1 end
                if info[4] then
                    p.TextureID = "http://roblox.com/asset/?id=" .. info[4]
                end
            end
        end
    else
        local base = char:FindFirstChild("Right Leg")
        if not base then return end
 
        base.Transparency = 1
 
        local shell = char:FindFirstChild("PhantomShell")
        if shell then shell:Destroy() end
 
        shell = Instance.new("Part")
        shell.Name = "PhantomShell"
        shell.Size = Vector3.new(1, 2, 1)
        shell.CanCollide = false
        shell.Massless = true
        shell.CFrame = base.CFrame * CFrame.new(0, 0.75, 0)
        shell.Parent = char
 
        local lock = Instance.new("WeldConstraint")
        lock.Part0 = shell
        lock.Part1 = base
        lock.Parent = shell
 
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "http://www.roblox.com/asset/?id=902942093"
        mesh.TextureId = "http://roblox.com/asset/?id=902843398"
        mesh.Scale = Vector3.new(0.85, 1.25, 0.85)
        mesh.Parent = shell
    end
end
 
local function onSpawn(char)
    ghostHead(char)
    shadowLeg(char)
end
 
if plr.Character then
    task.defer(onSpawn, plr.Character)
end
 
plr.CharacterAdded:Connect(onSpawn)
end)

-- =============================================
-- 【功能 5】Silent Aim 无声瞄准 / 全服锁定（新增）
-- =============================================
local SilentAimTab = Tabs.Player:AddLeftGroupbox("🎯 Silent Aim", "cross")
SilentAimTab:AddButton("启动无声瞄准(全服锁定)", function()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- 默认配置
local Config = {
    Enabled = false,
    Smoothness = 0.35,
    BlockTeam = false,
}

-- 当前锁定的目标
local lockedTarget = nil

-- 创建 UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentAim"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 主面板
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 130)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 120, 220)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- 圆角
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

-- 顶部装饰条
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 2)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🎯 目标锁定 (全服)"
TitleText.TextColor3 = Color3.fromRGB(230, 230, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 13
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- 关闭按钮
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 拖动功能
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- 内容区域
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -38)
Content.Position = UDim2.new(0, 8, 0, 34)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- 开关按钮
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 60, 0, 26)
ToggleBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
ToggleBtn.Text = "关闭"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.TextSize = 12
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

-- 状态指示灯
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(1, -10, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = ToggleBtn

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

-- 队友按钮
local TeamBtn = Instance.new("TextButton")
TeamBtn.Size = UDim2.new(1, 0, 0, 28)
TeamBtn.Position = UDim2.new(0, 0, 0, 36)
TeamBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TeamBtn.Text = "👥 不屏蔽队友"
TeamBtn.TextColor3 = Color3.fromRGB(200, 180, 120)
TeamBtn.Font = Enum.Font.GothamSemibold
TeamBtn.TextSize = 12
TeamBtn.BorderSizePixel = 0
TeamBtn.Parent = Content

local TeamCorner = Instance.new("UICorner")
TeamCorner.CornerRadius = UDim.new(0, 6)
TeamCorner.Parent = TeamBtn

-- 目标显示
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, 0, 0, 20)
TargetLabel.Position = UDim2.new(0, 0, 0, 74)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "🎯 目标: 无"
TargetLabel.TextColor3 = Color3.fromRGB(160, 160, 200)
TargetLabel.Font = Enum.Font.Gotham
TargetLabel.TextSize = 11
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = Content

-- ========== 更新 UI ==========
local function UpdateUI()
    if Config.Enabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 80)
        ToggleBtn.Text = "开启"
        ToggleBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
        StatusDot.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        ToggleBtn.Text = "关闭"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
        StatusDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        lockedTarget = nil
        TargetLabel.Text = "🎯 目标: 无"
        TargetLabel.TextColor3 = Color3.fromRGB(160, 160, 200)
    end
    
    if Config.BlockTeam then
        TeamBtn.BackgroundColor3 = Color3.fromRGB(45, 65, 55)
        TeamBtn.Text = "🚫 屏蔽队友"
        TeamBtn.TextColor3 = Color3.fromRGB(150, 255, 150)
    else
        TeamBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        TeamBtn.Text = "👥 不屏蔽队友"
        TeamBtn.TextColor3 = Color3.fromRGB(200, 180, 120)
    end
end

local function UpdateTargetDisplay()
    if lockedTarget and lockedTarget.player then
        local name = lockedTarget.player.Name
        if #name > 14 then name = name:sub(1, 11) .. "..." end
        TargetLabel.Text = "🎯 目标: " .. name
        TargetLabel.TextColor3 = Color3.fromRGB(255, 200, 120)
    else
        TargetLabel.Text = "🎯 目标: 无"
        TargetLabel.TextColor3 = Color3.fromRGB(160, 160, 200)
    end
end

-- 开关点击
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    UpdateUI()
    if not Config.Enabled then
        lockedTarget = nil
        UpdateTargetDisplay()
    end
end)

-- 队友按钮
TeamBtn.MouseButton1Click:Connect(function()
    Config.BlockTeam = not Config.BlockTeam
    if not Config.BlockTeam then
        lockedTarget = nil
        UpdateTargetDisplay()
    end
    UpdateUI()
end)

-- ========== 核心逻辑（全服锁定，无距离/FOV限制） ==========

-- 获取所有存活玩家（排除自己）
local function getAllAlivePlayers()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if not hum or hum.Health <= 0 then continue end
        if not head or not hrp then continue end
        
        -- 队友检查
        if Config.BlockTeam then
            local myTeam = LocalPlayer.Team
            if myTeam and player.Team == myTeam then continue end
        end
        
        table.insert(players, {
            player = player,
            head = head,
            root = hrp,
            humanoid = hum
        })
    end
    return players
end

-- 获取最近的玩家（基于世界距离，无限制）
local function getClosestPlayer()
    local players = getAllAlivePlayers()
    if #players == 0 then return nil end
    
    local selfChar = LocalPlayer.Character
    local selfRoot = selfChar and selfChar:FindFirstChild("HumanoidRootPart")
    if not selfRoot then return nil end
    
    local closest = nil
    local closestDist = math.huge
    
    for _, p in ipairs(players) do
        local dist = (p.root.Position - selfRoot.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = p
        end
    end
    
    return closest
end

-- 检查目标是否仍然有效
local function isTargetValid(target)
    if not target or not target.player then return false end
    local char = target.player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not hum or hum.Health <= 0 then return false end
    if not head or not hrp then return false end
    
    -- 更新引用
    target.head = head
    target.root = hrp
    target.humanoid = hum
    
    -- 队友检查（如果开启屏蔽）
    if Config.BlockTeam then
        local myTeam = LocalPlayer.Team
        if myTeam and target.player.Team == myTeam then return false end
    end
    
    return true
end

-- 主循环
RunService.RenderStepped:Connect(function(deltaTime)
    if not Config.Enabled then return end
    
    local selfChar = LocalPlayer.Character
    if not selfChar then
        if lockedTarget then
            lockedTarget = nil
            UpdateTargetDisplay()
        end
        return
    end
    
    local selfRoot = selfChar:FindFirstChild("HumanoidRootPart")
    if not selfRoot then return end
    
    -- 检查当前目标是否仍然有效
    if lockedTarget and not isTargetValid(lockedTarget) then
        lockedTarget = nil
        UpdateTargetDisplay()
    end
    
    -- 没有目标时，锁定最近玩家
    if not lockedTarget then
        lockedTarget = getClosestPlayer()
        UpdateTargetDisplay()
        if lockedTarget then
            print("[全服锁定] 锁定目标: " .. lockedTarget.player.Name)
        end
    end
    
    -- 转向锁定目标
    if lockedTarget and lockedTarget.head then
        local targetPos = lockedTarget.head.Position
        local currentPos = selfRoot.Position
        local direction = Vector3.new(targetPos.X - currentPos.X, 0, targetPos.Z - currentPos.Z).Unit
        
        if direction.Magnitude > 0 then
            local targetCFrame = CFrame.lookAt(currentPos, currentPos + direction)
            local speed = 1 - math.min(Config.Smoothness, 0.99)
            selfRoot.CFrame = selfRoot.CFrame:Lerp(targetCFrame, speed)
        end
    end
end)

-- 角色重生时重置锁定
LocalPlayer.CharacterAdded:Connect(function()
    lockedTarget = nil
    UpdateTargetDisplay()
end)

UpdateUI()
print("[Silent Aim] 全服锁定版已加载")
end)

-- =============================================
-- 原作者欢迎提示
-- =============================================
local Players = game.Players.LocalPlayer
local Target = "Skat3rShad0w2010"
local Showed = {}

local function NotifyAll()
    for _,plr in pairs(game.Players:GetPlayers()) do
        task.spawn(function()
            local g = Instance.new("ScreenGui")
            g.Name = "AuthorMsg"
            g.Parent = plr.PlayerGui
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1,0,0,100)
            t.Position = UDim2.new(0,0,0.3,0)
            t.BackgroundTransparency = 1
            t.Text = "欢迎MerzzL作者进入服务器🔥🔥🔥"
            t.TextSize = 42
            t.Font = Enum.Font.GothamBlack
            t.TextColor3 = Color3.new(1,0.8,0)
            t.TextStrokeTransparency = 0
            t.Parent = g
            task.wait(4)
            g:Destroy()
        end)
    end
end

game.Players.PlayerAdded:Connect(function(plr)
    if not Showed[plr.UserId] and plr.Name == Target then
        Showed[plr.UserId] = true
        NotifyAll()
    end
end)

for _,plr in pairs(game.Players:GetPlayers()) do
    if not Showed[plr.UserId] and plr.Name == Target then
        Showed[plr.UserId] = true
        NotifyAll()
    end
end

-- =============================================
-- UI 设置
-- =============================================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddToggle("KeybindMenuOpen", {Default = Library.KeybindFrame.Visible,Text = "Open Keybind Menu",Callback = function(v)Library.KeybindFrame.Visible = v end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor",Default = true,Callback = function(v)Library.ShowCustomCursor = v end})
MenuGroup:AddDropdown("NotificationSide", {Values = { "Left", "Right" },Default = "Right",Text = "Notification Side",Callback = function(v)Library:SetNotifySide(v)end})
MenuGroup:AddDropdown("DPIDropdown", {Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },Default = "100%",Text = "DPI Scale",Callback = function(v)v = v:gsub("%%", "");Library:SetDPIScale(tonumber(v))end})
MenuGroup:AddSlider("UICornerSlider", {Text = "Corner Radius",Default = Library.CornerRadius,Min = 0,Max = 20,Rounding = 0,Callback = function(v)Window:SetCornerRadius(v)end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function()Library:Unload()end)

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place")
-- =============================================
-- 【右侧】额外动作槽位（FE Ohio 专用）
-- =============================================
local RightGroup = Tabs.Player:AddRightGroupbox("🔧 额外功能", "plus")
RightGroup:AddButton("额外动作槽位", function()
    do
        local id = 10449761463
        if game.PlaceId ~= id then
            return
        end

        local Players = game:GetService("Players")
        local plr = Players.LocalPlayer

        if plr:GetAttribute("ExtraSlots") == nil then
            plr:SetAttribute("ExtraSlots", true)
        end
        
        Library:Notify("✅ 额外动作槽位已解锁", "成功")
    end
end)
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
