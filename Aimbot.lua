--制作:MerzzL开源
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
while not player do
	task.wait()
	player = Players.LocalPlayer
end

local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local FOV_RADIUS = 150
local SMOOTHNESS = 0.15
local AIMBOT_ENABLED = true
local AIMBOT_KEY = Enum.KeyCode.E

local target = nil
local lockedTarget = nil  -- 锁定的固定目标
local MOUSE_LOCKED = false
local changingKey = false

-- ================== FOV瞄准圈 ==================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FOVGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundColor3 = Color3.fromRGB(255,0,0)
fovCircle.BackgroundTransparency = 0.9
fovCircle.BorderSizePixel = 0
fovCircle.Parent = screenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1,0)
circleCorner.Parent = fovCircle
fovCircle.Visible = AIMBOT_ENABLED

-- ================== 自瞄逻辑 ==================
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

	-- 如果已有锁定目标，先检测是否还活着/存在
	if lockedTarget and lockedTarget.Character then
		local hum = lockedTarget.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			-- 目标还活着，继续锁定，不换其他人
			target = lockedTarget
		else
			-- 目标死了，解除锁定
			lockedTarget = nil
		end
	end

	-- 没有锁定目标才重新找新目标
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

-- ================== 中文设置菜单 ==================
local menuGui = Instance.new("ScreenGui")
menuGui.Name = "AimbotMenu"
menuGui.ResetOnSpawn = false
menuGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,240,0,260)
mainFrame.Position = UDim2.new(0.05,0,0.3,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = menuGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0,12)
frameCorner.Parent = mainFrame

-- 关闭销毁按钮 X
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,24,0,24)
CloseBtn.Position = UDim2.new(1,-30,0,6)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,0.2,0.2)
CloseBtn.TextSize = 18
CloseBtn.Parent = mainFrame

CloseBtn.MouseButton1Click:Connect(function()
	menuGui:Destroy()
	screenGui:Destroy()
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "自瞄设置"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8,0,0,32)
toggleButton.Position = UDim2.new(0.1,0,0,40)
toggleButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Text = "自瞄：开启"
toggleButton.Parent = mainFrame

-- 平滑度
local smoothLabel = Instance.new("TextLabel")
smoothLabel.Size = UDim2.new(1,0,0,25)
smoothLabel.Position = UDim2.new(0,0,0,80)
smoothLabel.BackgroundTransparency = 1
smoothLabel.TextColor3 = Color3.new(1,1,1)
smoothLabel.TextScaled = true
smoothLabel.Text = "平滑度："..string.format("%.2f", SMOOTHNESS)
smoothLabel.Parent = mainFrame

local smoothMinus = Instance.new("TextButton")
smoothMinus.Size = UDim2.new(0,45,0,30)
smoothMinus.Position = UDim2.new(0.1,0,0,110)
smoothMinus.Text = "-"
smoothMinus.BackgroundColor3 = Color3.fromRGB(60,60,60)
smoothMinus.TextColor3 = Color3.new(1,1,1)
smoothMinus.Parent = mainFrame

local smoothPlus = Instance.new("TextButton")
smoothPlus.Size = UDim2.new(0,45,0,30)
smoothPlus.Position = UDim2.new(0.45,0,0,110)
smoothPlus.Text = "+"
smoothPlus.BackgroundColor3 = Color3.fromRGB(60,60,60)
smoothPlus.TextColor3 = Color3.new(1,1,1)
smoothPlus.Parent = mainFrame

-- FOV圆圈大小设置
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1,0,0,25)
fovLabel.Position = UDim2.new(0,0,0,145)
fovLabel.BackgroundTransparency = 1
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.TextScaled = true
fovLabel.Text = "圆圈大小："..FOV_RADIUS
fovLabel.Parent = mainFrame

local fovMinus = Instance.new("TextButton")
fovMinus.Size = UDim2.new(0,45,0,30)
fovMinus.Position = UDim2.new(0.1,0,0,175)
fovMinus.Text = "-"
fovMinus.BackgroundColor3 = Color3.fromRGB(60,60,60)
fovMinus.TextColor3 = Color3.new(1,1,1)
fovMinus.Parent = mainFrame

local fovPlus = Instance.new("TextButton")
fovPlus.Size = UDim2.new(0,45,0,30)
fovPlus.Position = UDim2.new(0.45,0,0,175)
fovPlus.Text = "+"
fovPlus.BackgroundColor3 = Color3.fromRGB(60,60,60)
fovPlus.TextColor3 = Color3.new(1,1,1)
fovPlus.Parent = mainFrame

-- 快捷键
local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1,0,0,25)
keyLabel.Position = UDim2.new(0,0,0,210)
keyLabel.BackgroundTransparency = 1
keyLabel.TextColor3 = Color3.new(1,1,1)
keyLabel.TextScaled = true
keyLabel.Text = "快捷键：[ " .. tostring(AIMBOT_KEY):sub(14) .. " ]"
keyLabel.Parent = mainFrame

local changeKeyBtn = Instance.new("TextButton")
changeKeyBtn.Size = UDim2.new(0.8,0,0,30)
changeKeyBtn.Position = UDim2.new(0.1,0,0,235)
changeKeyBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
changeKeyBtn.TextColor3 = Color3.new(1,1,1)
changeKeyBtn.Text = "更改快捷键"
changeKeyBtn.Parent = mainFrame

-- ================== 功能逻辑 ==================
local function updateAimbotState()
	if AIMBOT_ENABLED then
		toggleButton.Text = "自瞄：开启"
		fovCircle.Visible = true
	else
		toggleButton.Text = "自瞄：关闭"
		fovCircle.Visible = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		MOUSE_LOCKED = false
		lockedTarget = nil
	end
end

-- 更新圆圈尺寸
local function updateFOVSize()
	fovCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
	fovLabel.Text = "圆圈大小："..FOV_RADIUS
end

toggleButton.MouseButton1Click:Connect(function()
	AIMBOT_ENABLED = not AIMBOT_ENABLED
	updateAimbotState()
end)

-- 平滑度调节
smoothMinus.MouseButton1Click:Connect(function()
	SMOOTHNESS = math.clamp(SMOOTHNESS - 0.05, 0.01, 1)
	smoothLabel.Text = "平滑度："..string.format("%.2f", SMOOTHNESS)
end)

smoothPlus.MouseButton1Click:Connect(function()
	SMOOTHNESS = math.clamp(SMOOTHNESS + 0.05, 0.01, 1)
	smoothLabel.Text = "平滑度："..string.format("%.2f", SMOOTHNESS)
end)

-- 圆圈大小调节 限制50~400
fovMinus.MouseButton1Click:Connect(function()
	FOV_RADIUS = math.clamp(FOV_RADIUS - 10, 50, 400)
	updateFOVSize()
end)

fovPlus.MouseButton1Click:Connect(function()
	FOV_RADIUS = math.clamp(FOV_RADIUS + 10, 50, 400)
	updateFOVSize()
end)

-- 更改快捷键
changeKeyBtn.MouseButton1Click:Connect(function()
	changingKey = true
	changeKeyBtn.Text = "按下任意按键..."
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if changingKey then
		changingKey = false
		AIMBOT_KEY = input.KeyCode
		keyLabel.Text = "快捷键：[ " .. tostring(AIMBOT_KEY):sub(14) .. " ]"
		changeKeyBtn.Text = "更改快捷键"
		return
	end
	if input.KeyCode == AIMBOT_KEY then
		AIMBOT_ENABLED = not AIMBOT_ENABLED
		updateAimbotState()
	end
end)

player.CharacterAdded:Connect(function()
	camera.CameraType = Enum.CameraType.Custom
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	MOUSE_LOCKED = false
	lockedTarget = nil
end)

-- 中文加载通知
local function sendNotification(title, text, duration)
	StarterGui:SetCore("SendNotification", {
		Title = title;
		Text = text;
		Duration = duration or 5;
	})
end

sendNotification("提示", "自瞄已加载 | 锁定单一目标模式", 4)
