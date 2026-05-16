local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UPDATE_INTERVAL = 0.05
local FONT_SIZE = 32
local LINE_HEIGHT = 30
local RIGHT_MARGIN = 20
local TOP_MARGIN = 10

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSPingDisplay"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- FPS Label
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 120, 0, LINE_HEIGHT)
FPSLabel.Position = UDim2.new(1, -RIGHT_MARGIN - 550, 0, TOP_MARGIN)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.new(1, 1, 1)
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = FONT_SIZE
FPSLabel.Text = "FPS: --"
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
FPSLabel.Parent = ScreenGui

-- Ping Label
local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 120, 0, LINE_HEIGHT)
PingLabel.Position = UDim2.new(1, -RIGHT_MARGIN - 550, 0, TOP_MARGIN + LINE_HEIGHT)
PingLabel.BackgroundTransparency = 1
PingLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
PingLabel.Font = Enum.Font.Gotham
PingLabel.TextSize = FONT_SIZE - 1
PingLabel.Text = "Ping: --ms"
PingLabel.TextXAlignment = Enum.TextXAlignment.Right
PingLabel.Parent = ScreenGui

-- FPS 计算
local frameCount = 0
local elapsedTime = 0

local function getPing()
    local success, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if success and ping then
        return math.floor(ping)
    end
    return 0
end

local function getColor(value, good, medium)
    if value >= good then
        return Color3.new(0.4, 1, 0.4)
    elseif value >= medium then
        return Color3.new(1, 1, 0.4)
    else
        return Color3.new(1, 0.4, 0.4)
    end
end

RunService.RenderStepped:Connect(function(deltaTime)
    frameCount = frameCount + 1
    elapsedTime = elapsedTime + deltaTime
    
    if elapsedTime >= UPDATE_INTERVAL then
        local fps = math.floor(frameCount / elapsedTime)
        FPSLabel.Text = "FPS: " .. fps
        FPSLabel.TextColor3 = getColor(fps, 55, 30)
        
        local ping = getPing()
        PingLabel.Text = "Ping: " .. ping .. "ms"
        PingLabel.TextColor3 = getColor(ping, 80, 150)
        
        frameCount = 0
        elapsedTime = 0
    end
end)

print("[FPS + Ping Display] Loaded! (Top-Right)")
