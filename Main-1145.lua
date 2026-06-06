task.spawn(function()
    while task.wait(3600) do
        reportTotalUsage()
    end
end)

local function RunSequence()
    wait(0.5)
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ASE_Integrated_System"
    ScreenGui.IgnoreGuiInset = true
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://1846396531"
    sound.Volume = 0.5
    sound.Looped = true
    sound.Parent = ScreenGui
    sound:Play()

    local MainContainer = Instance.new("CanvasGroup")
    MainContainer.Size = UDim2.new(1, 0, 1, 0)
    MainContainer.BackgroundTransparency = 1
    MainContainer.GroupTransparency = 1
    MainContainer.Parent = ScreenGui

    local LoaderFrame = Instance.new("Frame")
    LoaderFrame.Size = UDim2.new(1, 0, 1, 0)
    LoaderFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    LoaderFrame.BorderSizePixel = 0
    LoaderFrame.Parent = MainContainer

    local KSPA_Text = Instance.new("TextLabel")
    KSPA_Text.Size = UDim2.new(0.5, 0, 0, 120)
    KSPA_Text.Position = UDim2.new(0, 0, 0.5, -60)
    KSPA_Text.Text = "欢迎使用"
    KSPA_Text.TextSize = 120
    KSPA_Text.Font = Enum.Font.GothamBold
    KSPA_Text.TextXAlignment = Enum.TextXAlignment.Right
    KSPA_Text.TextTransparency = 1
    KSPA_Text.TextColor3 = Color3.fromRGB(255, 255, 255)
    KSPA_Text.Parent = LoaderFrame

    local KSPA_Grad = Instance.new("UIGradient")
    KSPA_Grad.Color = ColorSequence.new(
        Color3.fromRGB(230, 57, 124),
        Color3.fromRGB(26, 26, 29)
    )
    KSPA_Grad.Rotation = 90
    KSPA_Grad.Parent = KSPA_Text

    local KsPa_Text = Instance.new("TextLabel")
    KsPa_Text.Size = UDim2.new(0.5, 0, 0, 120)
    KsPa_Text.Position = UDim2.new(0.5, 10, 0.5, -60)
    KsPa_Text.Text = " 入场动画by柳叶"
    KsPa_Text.TextSize = 120
    KsPa_Text.Font = Enum.Font.GothamBold
    KsPa_Text.TextXAlignment = Enum.TextXAlignment.Left
    KsPa_Text.TextTransparency = 1
    KsPa_Text.TextColor3 = Color3.fromRGB(255, 255, 255)
    KsPa_Text.Parent = LoaderFrame

    local K_Grad = Instance.new("UIGradient")
    K_Grad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255))
    K_Grad.Rotation = 90
    K_Grad.Parent = KsPa_Text

    local BanText = Instance.new("TextLabel")
    BanText.Size = UDim2.new(0.7, 0, 0, 70)
    BanText.Position = UDim2.new(0.5, 0, -0.15, 0)
    BanText.AnchorPoint = Vector2.new(0.5, 0.5)
    BanText.Text = "搬运Skin"
    BanText.TextSize = 70
    BanText.Font = Enum.Font.GothamBold
    BanText.TextColor3 = Color3.fromRGB(255, 255, 255)
    BanText.BackgroundTransparency = 1
    BanText.TextTransparency = 1
    BanText.TextScaled = false
    BanText.Parent = LoaderFrame

    local BanGrad = Instance.new("UIGradient")
    BanGrad.Color = ColorSequence.new(
        Color3.fromRGB(245, 239, 234),
        Color3.fromRGB(18, 46, 138)
    )
    BanGrad.Rotation = 90
    BanGrad.Parent = BanText

    -- 日志面板容器（深海蓝背景，50%透明度）
    local LogFrame = Instance.new("Frame")
    LogFrame.Size = UDim2.new(0, 100, 0, 100)
    LogFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
    LogFrame.BackgroundColor3 = Color3.fromRGB(18, 46, 138)
    LogFrame.BackgroundTransparency = 1
    LogFrame.ClipsDescendants = true
    LogFrame.Parent = MainContainer

    local LogCorner = Instance.new("UICorner")
    LogCorner.CornerRadius = UDim.new(0, 15)
    LogCorner.Parent = LogFrame

    local LogStroke = Instance.new("UIStroke")
    LogStroke.Thickness = 2
    LogStroke.Color = Color3.fromRGB(255, 255, 255)
    LogStroke.Transparency = 1
    LogStroke.Parent = LogFrame

    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -40, 1, -100)
    Content.Position = UDim2.new(0, 20, 0, 20)
    Content.BackgroundTransparency = 1
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ScrollBarThickness = 0
    Content.Parent = LogFrame

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 10)
    List.Parent = Content

    local function AddUpdate(msg)
        msg = msg or "未知消息"
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 25)
        t.BackgroundTransparency = 1
        t.RichText = true
        t.Text = "» " .. tostring(msg)
        t.TextColor3 = Color3.fromRGB(245, 239, 234)
        t.TextSize = 16
        t.Font = Enum.Font.Ubuntu
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.TextTransparency = 1
        t.Parent = Content
        task.defer(function()
            Content.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y)
        end)
        return t
    end

    local updateLabels = {}
    updateLabels[1] = AddUpdate("欢迎使用 MerzzL Hub")
    updateLabels[2] = AddUpdate("MerzzL制作")
    updateLabels[3] = AddUpdate("感谢您的游玩")
    updateLabels[4] = AddUpdate("永远跑路，永不免费")

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 200, 0, 40)
    CloseBtn.Position = UDim2.new(0.5, -100, 1, -55)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "已阅读/进入"
    CloseBtn.TextColor3 = Color3.fromRGB(245, 239, 234)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.TextTransparency = 1
    CloseBtn.Parent = LogFrame

    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    TweenService:Create(MainContainer, TweenInfo.new(0.8), {GroupTransparency = 0}):Play()
    
    task.wait(0.5)
    
    TweenService:Create(KSPA_Text, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    TweenService:Create(KsPa_Text, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    
    local BanSlideIn = TweenService:Create(BanText, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.22, 0),
        TextTransparency = 0
    })
    BanSlideIn:Play()
    
    local rotate = RunService.RenderStepped:Connect(function()
        KSPA_Grad.Offset = Vector2.new(0, math.sin(tick()*2)*0.2)
        K_Grad.Offset = Vector2.new(0, -math.sin(tick()*2)*0.2)
        BanGrad.Offset = Vector2.new(0, math.sin(tick()*2)*0.2)
    end)
    
    task.wait(2)
    
    local sequence1 = TweenService:Create(KSPA_Text, TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
        Position = UDim2.new(-0.6, 0, 0.5, -60),
        TextTransparency = 1
    })
    local sequence2 = TweenService:Create(KsPa_Text, TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
        Position = UDim2.new(1.1, 0, 0.5, -60),
        TextTransparency = 1
    })
    sequence1:Play()
    sequence2:Play()
    TweenService:Create(LoaderFrame, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
    
    task.wait(1.2)
    
    local BanSlideOut = TweenService:Create(BanText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, -0.25, 0),
        TextTransparency = 1
    })
    BanSlideOut:Play()
    
    local logSequence = TweenService:Create(LogFrame, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 450, 0, 320)
    })
    local strokeSequence = TweenService:Create(LogStroke, TweenInfo.new(1), {Transparency = 0.8})
    logSequence:Play()
    strokeSequence:Play()
    
    task.wait(0.3)
    
    TweenService:Create(CloseBtn, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {
        BackgroundTransparency = 0.9,
        TextTransparency = 0
    }):Play()
    
    task.spawn(function()
        for i, obj in pairs(updateLabels) do
            TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
            task.wait(0.15)
        end
    end)
    
    -- 创建付费信息面板的引用
    local paidPanel = nil
    
    -- 等待日志面板动画完成后再创建付费面板并从下方滑入左侧
    logSequence.Completed:Connect(function()
        if paidPanel then return end -- 防止重复创建
        
        -- 创建付费面板主体
        paidPanel = Instance.new("Frame")
        paidPanel.Size = UDim2.new(0, 280, 0, 350)
        paidPanel.Position = UDim2.new(0, 20, 1.2, 0) -- 初始在屏幕下方之外
        paidPanel.AnchorPoint = Vector2.new(0, 0.5) -- 左边缘锚点，垂直中心锚点
        paidPanel.BackgroundColor3 = Color3.fromRGB(18, 46, 138)
        paidPanel.BackgroundTransparency = 0.6
        paidPanel.BorderSizePixel = 0
        paidPanel.ClipsDescendants = true
        paidPanel.Parent = MainContainer
        
        local panelCorner = Instance.new("UICorner")
        panelCorner.CornerRadius = UDim.new(0, 12)
        panelCorner.Parent = paidPanel
        
        local panelStroke = Instance.new("UIStroke")
        panelStroke.Thickness = 2
        panelStroke.Color = Color3.fromRGB(255, 255, 255)
        panelStroke.Transparency = 0.3
        panelStroke.Parent = paidPanel
        
        -- 滚动框架
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, -20, 1, -20)
        scrollFrame.Position = UDim2.new(0, 10, 0, 10)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 6
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
        scrollFrame.Parent = paidPanel
        
        -- 文本标签
        local contentText = Instance.new("TextLabel")
        contentText.Size = UDim2.new(1, -10, 0, 0)
        contentText.Position = UDim2.new(0, 5, 0, 0)
        contentText.BackgroundTransparency = 1
        contentText.TextWrapped = true
        contentText.TextXAlignment = Enum.TextXAlignment.Left
        contentText.TextYAlignment = Enum.TextYAlignment.Top
        contentText.TextColor3 = Color3.fromRGB(245, 239, 234)
        contentText.Font = Enum.Font.Ubuntu
        contentText.TextSize = 13
        contentText.Text = [[MerzzL Hub [free]


支持服务器：3

1.最强战场  2.Forsaken
3.Ohio

主群596301441]]
        contentText.TextScaled = false
        contentText.Parent = scrollFrame
        
        -- 自动调整文本高度并设置画布大小
        contentText.Size = UDim2.new(1, -10, 0, 0)
        contentText.AutomaticSize = Enum.AutomaticSize.Y
        task.defer(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentText.AbsoluteSize.Y + 10)
        end)
        
        -- 移入动画：从下方滑入到左侧目标位置（垂直中心与弹窗对齐）
        local targetPosition = UDim2.new(0, 20, 0.5, 0) -- 左边缘X=20，垂直中心在屏幕中央
        local slideIn = TweenService:Create(paidPanel, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = targetPosition,
            BackgroundTransparency = 0.5
        })
        slideIn:Play()
    end)
    
    local clicked = false
    CloseBtn.MouseButton1Click:Connect(function()
        if clicked then return end
        clicked = true
        
        -- 如果付费面板存在，先让它向上滑出
        local function finishClose()
            local closeTween = TweenService:Create(MainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                GroupTransparency = 1
            })
            closeTween:Play()
            closeTween.Completed:Wait()
            
            rotate:Disconnect()
            sound:Stop()
            sound:Destroy()
            ScreenGui:Destroy()
        end
        
        if paidPanel and paidPanel.Parent then
            local slideOut = TweenService:Create(paidPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 20, -0.5, 0),
                BackgroundTransparency = 1
            })
            slideOut:Play()
            slideOut.Completed:Connect(function()
                finishClose()
            end)
        else
            finishClose()
        end
    end)
    
    repeat task.wait() until clicked
end

RunSequence()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera
local pgui = lp:WaitForChild("PlayerGui")
local mouse = lp:GetMouse()

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local _Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowCustomCursor = true
local Window = Library:CreateWindow({
    Title = "MerzzL",
    Footer = "此脚本完全免费  Q群：544199307",
    NotifySide = "Right",
    ShowCustomCursor = true,
    BackgroundImage = "rbxassetid://139577718592804",
    BackgroundTransparency = 0.15,
    BackgroundScale = 1,
})

local Tabs = {
    Player = Window:AddTab("玩家", "user"),
    ESP = Window:AddTab("视觉", "eye"),
    OtherTab = Window:AddTab("其它",'boxes'),
    MerzzLTab = Window:AddTab("MerzzL脚本",'crosshair'),
    ScriptTab = Window:AddTab("脚本", "paintbrush"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- MerzzL脚本标签分区
local ForsakenMerzzLBox = Tabs.MerzzLTab:AddLeftGroupbox("Forsaken")
ForsakenMerzzLBox:AddButton({
    Text = "MerzzL",
    Func = function()
        setclipboard([[loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/script/main/main.lua"))()]])
        Library:Notify({Title = "MerzzL", Description = "Forsaken MerzzL 代码已复制", Duration = 2})
    end
})

local TSBMerzzLBox = Tabs.MerzzLTab:AddRightGroupbox("TSB")
TSBMerzzLBox:AddButton({
    Text = "MerzzL",
    Func = function()
        setclipboard([[loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/script/main/obsidian.lua"))()]])
        Library:Notify({Title = "MerzzL", Description = "TSB MerzzL代码已复制", Duration = 2})
    end
})

local OHIOMerzzLBox = Tabs.MerzzLTab:AddLeftGroupbox("OHIO")
OHIOMerzzLBox:AddButton({
    Text = "MerzzL",
    Func = function()
        setclipboard([[loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/IDK/main/MerzzL%20ohio.txt"))()]])
        Library:Notify({Title = "MerzzL", Description = "OHIO MerzzL 代码已复制", Duration = 2})
    end
})

--========================= 内置Aimbot+ESP全局变量 =========================
local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera

_G.aimbotEnabled = false
_G.fovSize = 200
_G.fovColor = Color3.fromRGB(208, 240, 253)
_G.aimbotTeamCheck = true
_G.wallCheck = true
_G.usePrediction = true
_G.predictionValue = 0

_G.BoxESP = false
_G.NameESP = false
_G.DistanceESP = false
_G.SkeletonESP = false
_G.HealthTextESP = false
_G.HealthBarESP = false
_G.TracerESP = false
_G.ChamsESP = false
_G.ESPTargetDistance = 325

-- 保存 Lighting 原始值的全局变量（用于卸载时恢复）
_G.origBrightness = nil
_G.origAmbient = nil
_G.origClockTime = nil
_G.origOutdoor = nil
_G.origFog = nil
_G.origShadow = nil

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = _G.fovSize
fovCircle.Color = _G.fovColor
fovCircle.Filled = false

local ZixyESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/zixypy/zixyx/refs/heads/main/zixyesp.txt'))()
local esp = ZixyESP.new()

local function getScreenPos(part)
    local vector, onScreen = cam:WorldToViewportPoint(part.Position)
    return Vector2.new(vector.X, vector.Y), onScreen
end

local function isValidTarget(plr)
    if plr == lp or not plr.Character or not plr.Character:FindFirstChild("Humanoid") or plr.Character.Humanoid.Health <= 0 then
        return false
    end
    if _G.aimbotTeamCheck and plr.Team == lp.Team then
        return false
    end
    if _G.wallCheck then
        local ray = Ray.new(cam.CFrame.Position, (plr.Character.Head.Position - cam.CFrame.Position).Unit * 500)
        local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {lp.Character})
        if hit and hit:IsDescendantOf(plr.Character) then
            return true
        end
        return false
    end
    return true
end

local function findClosestInFOV()
    local closest = nil
    local minDist = _G.fovSize
    local fovPos
    if uis.TouchEnabled then
        local viewportSize = cam.ViewportSize
        fovPos = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    else
        fovPos = uis:GetMouseLocation()
    end
    
    for _, plr in pairs(plrs:GetPlayers()) do
        if isValidTarget(plr) then
            local head = plr.Character.Head
            local pos, onScreen = getScreenPos(head)
            if onScreen then
                local dist = (pos - fovPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = plr
                end
            end
        end
    end
    return closest, fovPos
end

rs.RenderStepped:Connect(function()
    if _G.aimbotEnabled then
        fovCircle.Visible = true
        fovCircle.Position = uis:GetMouseLocation()
        fovCircle.Radius = _G.fovSize
        fovCircle.Color = _G.fovColor
        
        local target = findClosestInFOV()
        if target then
            local headPos = target.Character.Head.Position
            if _G.usePrediction then
                headPos = headPos + (target.Character.HumanoidRootPart.Velocity * _G.predictionValue)
            end
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, headPos)
        end
    else
        fovCircle.Visible = false
    end

    esp.State.BoxEnabled = _G.BoxESP
    esp.State.SkeletonEnabled = _G.SkeletonESP
    esp.State.TracerEnabled = _G.TracerESP
    esp.State.ChamsEnabled = _G.ChamsESP
    esp:InitiateName(_G.NameESP)
    esp:InitiateDistance(_G.DistanceESP)
    esp:InitiateHealthText(_G.HealthTextESP)
    esp:InitiateHealthBar(_G.HealthBarESP)
    esp:SetDistance(_G.ESPTargetDistance)
end)

esp:Initialize()
esp:InitiateBox(Color3.fromRGB(208, 240, 253))
esp:InitiateSkeleton(Color3.fromRGB(208, 240, 253))
esp:InitiateTracer(Color3.fromRGB(208, 240, 253), "Top Screen")
esp:InitiateChams(Color3.fromRGB(208, 240, 253))

--========================= 全局变量 =========================
_G.TurboSpin = false
_G.SpinSpeed = 50
_G.SpeedActive = false
_G.WalkSpeedVal = 16
_G.GameOriginalWalkSpeed = 16

_G.InfiniteJump = false
_G.NoclipActive = false

_G.ESP_Highlight = false
_G.ESP_Name = false
_G.ESP_Health = false
_G.ESP_Distance = false
_G.ESP_TeamCheck = false
_G.ESP_Font = Enum.Font.GothamBold
_G.ESP_TextSize = 14

_G.InventoryAlwaysShow = false
_G.MapNightVision = false

_G.UnlockFPS = false
_G.ShowFPS = false

local PlayerLeft = Tabs.Player:AddLeftGroupbox("玩家功能")
local PlayerRight = Tabs.Player:AddRightGroupbox("其它")

PlayerLeft:AddToggle("SpinToggle", {
    Text = "人物陀螺自转",
    Default = false,
    Callback = function(v)
        _G.TurboSpin = v
        local plr = game.Players.LocalPlayer
        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            plr.Character.Humanoid.AutoRotate = not v
        end
    end
})

PlayerLeft:AddSlider("SpinSpeedSlider", {
    Text = "自转速度",
    Default = 50,
    Min = 10,
    Max = 350,
    Rounding = 0,
    Callback = function(v)
        _G.SpinSpeed = v
    end
})

PlayerLeft:AddToggle("SpeedToggle", {
    Text = "开启移速",
    Default = false,
    Callback = function(v)
        _G.SpeedActive = v
        local plr = game.Players.LocalPlayer
        if not plr.Character then return end
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if v then
            _G.GameOriginalWalkSpeed = hum.WalkSpeed
            hum.WalkSpeed = _G.WalkSpeedVal
        else
            hum.WalkSpeed = _G.GameOriginalWalkSpeed
        end
    end
})

PlayerLeft:AddSlider("WalkSpeedSlider", {
    Text = "移速自由调节",
    Default = 16,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        _G.WalkSpeedVal = v
        local plr = game.Players.LocalPlayer
        if _G.SpeedActive and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = v
            end
        end
    end
})

-- ========== 无限跳跃 (IY flyjump 原理 + 防连跳) ==========
local infJumpConn = nil
local infJumpDebounce = false

PlayerLeft:AddToggle("InfiniteJumpToggle", {
    Text = "无限跳跃",
    Default = false,
    Callback = function(v)
        _G.InfiniteJump = v
        if infJumpConn then infJumpConn:Disconnect() end
        infJumpDebounce = false
        
        if v then
            infJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                if not infJumpDebounce then
                    infJumpDebounce = true
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                    task.wait()
                    infJumpDebounce = false
                end
            end)
            Library:Notify({Title = "MerzzL", Description = "无限跳跃已开启 (IY模式)", Duration = 2})
        else
            Library:Notify({Title = "MerzzL", Description = "无限跳跃已关闭", Duration = 2})
        end
    end
})

-- ========== 穿墙 Noclip (IY 原理 + 物理驱动) ==========
local noclipConnection = nil
local noclipActive = false

local function setNoclip(state)
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    
    if state then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        local collisionParts = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if table.find(collisionParts, part.Name) then
                    part.CanCollide = true
                else
                    part.CanCollide = false
                end
            end
        end
    end
end

PlayerLeft:AddToggle("NoclipToggle", {
    Text = "穿墙 Noclip",
    Default = false,
    Callback = function(v)
        _G.NoclipActive = v
        noclipActive = v
        
        if noclipConnection then noclipConnection:Disconnect() end
        
        if v then
            setNoclip(true)
            noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if noclipActive then
                    setNoclip(true)
                end
            end)
            Library:Notify({Title = "MerzzL", Description = "穿墙已开启 (IY模式)", Duration = 2})
        else
            if noclipConnection then noclipConnection:Disconnect() end
            setNoclip(false)
            Library:Notify({Title = "MerzzL", Description = "穿墙已关闭", Duration = 2})
        end
    end
})

PlayerRight:AddButton({
    Text = "飞行Beta",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/script/main/FLY%20level%201.lua"))()
        Library:Notify({Title = "MerzzL", Description = "飞行脚本已加载", Duration = 3})
    end
})

PlayerRight:AddButton({
    Text = "cframefly",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/script/main/Cfreamfly.lua"))()
        Library:Notify({Title = "MerzzL", Description = "Cframefly脚本已加载", Duration = 3})
    end
})

PlayerRight:AddButton({
    Text = "踏空行走",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/script/main/踏空行走.lua"))()
        Library:Notify({Title = "MerzzL", Description = "踏空行走脚本已加载", Duration = 3})
    end
})

-- 视觉标签
local ESPFuncBox = Tabs.ESP:AddLeftGroupbox("全套ESP开关")
local VisionBox = Tabs.ESP:AddLeftGroupbox("地图视觉设置")
local ESPBox = Tabs.ESP:AddRightGroupbox("简易ESP")

local _env = getgenv and getgenv() or {}
local LightingTabbox = Tabs.ESP:AddRightTabbox()
local BrightnessTab = LightingTabbox:AddTab("亮度")

BrightnessTab:AddSlider("B",{
    Text = "亮度",
    Min = 0,
    Default = 0,
    Max = 3,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        _env.Brightness = v
    end
})

BrightnessTab:AddToggle("无阴影",{
    Text = "无阴影",
    Default = false,
    Callback = function(v)
        _env.GlobalShadows = v
    end
})

BrightnessTab:AddToggle("除雾",{
    Text = "无雾",
    Default = false,
    Callback = function(v)
        _env.NoFog = v
    end
})

ESPFuncBox:AddToggle("BoxESPTog", {Text = "方框ESP",Default = false,Callback = function(v)_G.BoxESP = v end})
ESPFuncBox:AddToggle("NameESPTog", {Text = "名字ESP",Default = false,Callback = function(v)_G.NameESP = v end})
ESPFuncBox:AddToggle("DistanceESPTog", {Text = "距离ESP",Default = false,Callback = function(v)_G.DistanceESP = v end})
ESPFuncBox:AddToggle("SkeletonESPTog", {Text = "骨架ESP",Default = false,Callback = function(v)_G.SkeletonESP = v end})
ESPFuncBox:AddToggle("HealthTextESPTog", {Text = "血量文字ESP",Default = false,Callback = function(v)_G.HealthTextESP = v end})
ESPFuncBox:AddToggle("HealthBarESPTog", {Text = "血条ESP",Default = false,Callback = function(v)_G.HealthBarESP = v end})
ESPFuncBox:AddToggle("TracerESPTog", {Text = "透视线条",Default = false,Callback = function(v)_G.TracerESP = v end})
ESPFuncBox:AddToggle("ChamsESPTog", {Text = "人物描边Chams",Default = false,Callback = function(v)_G.ChamsESP = v end})
ESPFuncBox:AddToggle("ESPTmCheckTog", {Text = "ESP队伍检测",Default = false,Callback = function(v)esp:TeamCheck(v) end})
ESPFuncBox:AddSlider("ESPDistSlider", {
    Text = "ESP渲染距离",
    Default = 325,
    Min = 100,
    Max = 1000,
    Rounding = 0,
    Callback = function(v)
        _G.ESPTargetDistance = v
    end
})

ESPBox:AddToggle("ESP_Highlight_Tog", {
    Text = "玩家人物高亮",
    Default = false,
    Callback = function(v)
        _G.ESP_Highlight = v
    end
})
ESPBox:AddToggle("ESP_Name_Tog", {
    Text = "简易名字",
    Default = false,
    Callback = function(v)
        _G.ESP_Name = v
    end
})
ESPBox:AddToggle("ESP_Health_Tog", {
    Text = "简易血量",
    Default = false,
    Callback = function(v)
        _G.ESP_Health = v
    end
})
ESPBox:AddToggle("ESP_Distance_Tog", {
    Text = "简易距离",
    Default = false,
    Callback = function(v)
        _G.ESP_Distance = v
    end
})
ESPBox:AddToggle("ESP_TeamCheck_Tog", {
    Text = "简易队伍检测",
    Default = false,
    Callback = function(v)
        _G.ESP_TeamCheck = v
    end
})
ESPBox:AddDropdown("EspFontSelect", {
    Text = "透视名字&血量字体",
    Values = {"Gotham","GothamBold","Roboto","RobotoBold","Code","Legacy","ComicSans","Arial"},
    Default = "GothamBold",
    Callback = function(val)
        _G.ESP_Font = Enum.Font[val]
    end
})
ESPBox:AddSlider("EspTextSize", {
    Text = "透视文字大小",
    Default = 14,
    Min = 8,
    Max = 30,
    Rounding = 0,
    Callback = function(v)
        _G.ESP_TextSize = v
    end
})

VisionBox:AddToggle("MapNightVisionTog", {
    Text = "地图夜视（全图高亮）",
    Default = false,
    Callback = function(v)
        _G.MapNightVision = v
        Library:Notify({Title = "MerzzL", Description = v and "地图夜视已开启" or "地图夜视已关闭", Duration = 2})
    end
})

local AimbotBox = Tabs.OtherTab:AddLeftGroupbox("Aimbot")
local NoHeadBox = Tabs.OtherTab:AddLeftGroupbox("无头断腿")
local IYBox = Tabs.OtherTab:AddLeftGroupbox("IY")
local OtherBox = Tabs.OtherTab:AddLeftGroupbox("其他功能")
local FPSBox = Tabs.OtherTab:AddRightGroupbox("FPS Ping实时显示")
local R15Box = Tabs.OtherTab:AddRightGroupbox("R15")

IYBox:AddButton({
    Text = "执行IY脚本",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()    
        Library:Notify({Title = "MerzzL", Description = "IY脚本已运行", Duration = 3})
    end
})

OtherBox:AddToggle('ChatBox', {
    Text = '显示聊天框 | 一局一开',
    Default = false,
    Callback = function(state)
        game.TextChatService.ChatWindowConfiguration.Enabled = state
    end
})

AimbotBox:AddButton({
    Text = "执行脚本",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/script/main/Aimbot.lua"))()
        Library:Notify({Title = "MerzzL", Description = "Aimbot 脚本已执行", Duration = 3})
    end
})

NoHeadBox:AddButton({
    Text = "客户端",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/script/main/客户端无头断腿.lua"))()
        Library:Notify({Title = "MerzzL", Description = "无头断腿 脚本已执行", Duration = 3})
    end
})

R15Box:AddButton({
    Text = "R15动作包",
    Func = function(v)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/script/main/R15.lua"))()
        Library:Notify({Title = "MerzzL", Description = "R15动作包已加载", Duration = 3})
    end
})

OtherBox:AddToggle("InvAlwaysShowTog", {
    Text = "物品栏始终显示",
    Default = false,
    Callback = function(v)
        _G.InventoryAlwaysShow = v
        Library:Notify({Title = "MerzzL", Description = v and "物品栏始终显示 已开启" or "物品栏始终显示 已关闭", Duration = 2})
    end
})

local instantInteractEnabled = false

OtherBox:AddToggle("InstantInteractToggle", {
    Text = "⚡ 秒互动（无需按住E）",
    Default = false,
    Callback = function(state)
        instantInteractEnabled = state
        
        if state then
            -- 修改所有现有的 ProximityPrompt
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                end
            end
            Library:Notify({Title = "MerzzL", Description = "秒互动已开启，按E瞬间互动", Duration = 2})
        else
            -- 恢复默认值
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0.5
                    prompt.RequiresLineOfSight = true
                end
            end
            Library:Notify({Title = "MerzzL", Description = "秒互动已关闭", Duration = 2})
        end
    end
})

-- 监听新添加的物体（实时生效）
workspace.DescendantAdded:Connect(function(desc)
    if instantInteractEnabled and desc:IsA("ProximityPrompt") then
        desc.HoldDuration = 0
        desc.RequiresLineOfSight = false
    end
end)
-- ========== 秒互动结束 ==========

FPSBox:AddButton({
    Text = "开启FPS+Ping显示",
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/QQ161475237/script/main/FPS%20Ping.lua"))()
        Library:Notify({Title = "MerzzL", Description = "FPS与延迟实时显示已加载", Duration = 2})
    end
})

local TSBBox = Tabs.ScriptTab:AddLeftGroupbox("TSB")
TSBBox:AddButton({Text = "Auto Block-复制代码",Func = function()setclipboard([[loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/565975237a0f7c10df56777eafd8f4813f15d3cde1b206f7e10f6b87af4fa9dfd/download"))()]])end})
TSBBox:AddButton({Text = "BaeMinhHub-复制代码",Func = function()setclipboard([[loadstring(game:HttpGet("https://gist.githubusercontent.com/ngm2807-sudo/3bb38870095ccba814f13993813410f1/raw/32addd5af4b65ffa18a7002eac6e71b9f01076ed/BaeMinhHub.lua"))()]])end})

local ScriptBox = Tabs.ScriptTab:AddLeftGroupbox("Forsaken")
ScriptBox:AddButton({Text = "XK-复制代码",Func = function()setclipboard([[loadstring(game:HttpGet("https://raw.githubusercontent.com/DevSloPo/Main/refs/heads/main/Game/Forsaken"))()]])end})
ScriptBox:AddButton({Text = "NOL-复制代码",Func = function()setclipboard([[loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/68508ac48be056738c8469f5f4d915ce.lua"))()]])end})

local GBBox = Tabs.ScriptTab:AddRightGroupbox("内脏与黑火药")
GBBox:AddButton({Text = "Zero-keyless-复制代码",Func = function()setclipboard([[loadstring(game:HttpGet("https://paste.app/yE2GY5L/raw"))()]])end})
GBBox:AddButton({Text = "Katchi-复制代码",Func = function()setclipboard([[loadstring(game:HttpGet("https://rawscripts.net/raw/Guts-and-Blackpowder-Katchi-Hub-90432"))()]])end})

local DoorsBox = Tabs.ScriptTab:AddRightGroupbox("Doors")
DoorsBox:AddButton({Text = "MRSdoors-复制代码",Func = function()setclipboard([[loadstring(game:HttpGet("https://www.msdoors.xyz/script"))()]])end})

-- FPS显示
task.spawn(function()
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local PlayerGui = lp:WaitForChild("PlayerGui")

    pcall(function()
        if PlayerGui:FindFirstChild("MerzzL_FPS") then
            PlayerGui.MerzzL_FPS:Destroy()
        end
    end)

    local FPSGui = Instance.new("ScreenGui")
    FPSGui.Name = "MerzzL_FPS"
    FPSGui.Parent = PlayerGui
    FPSGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    FPSGui.ResetOnSpawn = false
    FPSGui.AlwaysOnTop = true

    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(0,120,0,30)
    FPSLabel.Position = UDim2.new(1,-130,0,20)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.TextColor3 = Color3.new(0,1,0)
    FPSLabel.Font = Enum.Font.GothamBold
    FPSLabel.TextSize = 18
    FPSLabel.Text = "FPS: 0"
    FPSLabel.Parent = FPSGui

    RunService.RenderStepped:Connect(function(delta)
        if _G.UnlockFPS then
            UserInputService.VSyncEnabled = false
            RunService:SetFrameRate(0)
            workspace:SetPhysicsThrottleRate(0)
        else
            UserInputService.VSyncEnabled = true
            RunService:SetFrameRate(60)
            workspace:SetPhysicsThrottleRate(60)
        end

        FPSGui.Enabled = _G.ShowFPS
        local fps = math.floor(1 / delta + 0.5)
        FPSLabel.Text = "FPS: " .. fps
    end)
end)

-- 后台逻辑：自转、物品栏、地图夜视、亮度/阴影/雾效
task.spawn(function()
    local lp = game.Players.LocalPlayer
    local angle = 0
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local CoreGui = game:GetService("CoreGui")

    -- 保存原始 Lighting 值到全局变量
    _G.origBrightness = Lighting.Brightness
    _G.origAmbient = Lighting.Ambient
    _G.origClockTime = Lighting.ClockTime
    _G.origOutdoor = Lighting.OutdoorAmbient
    _G.origFog = Lighting.FogEnd
    _G.origShadow = Lighting.GlobalShadows

    RunService.Heartbeat:Connect(function()
        if not lp.Character then return end

        if _env.Brightness then
            Lighting.Brightness = _env.Brightness
        end
        if _env.GlobalShadows ~= nil then
            Lighting.GlobalShadows = not _env.GlobalShadows
        end
        if _env.NoFog ~= nil then
            Lighting.FogEnd = _env.NoFog and 1000000 or _G.origFog
        end
        
        if _G.InventoryAlwaysShow then
            pcall(function()
                for _, gui in pairs(CoreGui:GetDescendants()) do
                    if gui.Name:lower():find("backpack") or gui.Name:lower():find("toolbar") then
                        if gui:IsA("GuiObject") then
                            gui.Enabled = true
                            gui.Visible = true
                        end
                    end
                end
            end)
        end

        if _G.MapNightVision then
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(0.8,0.8,0.8)
            Lighting.OutdoorAmbient = Color3.new(0.7,0.7,0.7)
            Lighting.ClockTime = 12
        else
            if not _env.Brightness then
                Lighting.Brightness = _G.origBrightness
            end
            Lighting.Ambient = _G.origAmbient
            Lighting.OutdoorAmbient = _G.origOutdoor
            Lighting.ClockTime = _G.origClockTime
        end
    end)

    lp.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if _G.SpeedActive then
            hum.WalkSpeed = _G.WalkSpeedVal
        end
    end)

    while task.wait(0.01) do
        if not lp.Character then continue end
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        local root = lp.Character:FindFirstChild("HumanoidRootPart")
        if not hum or not root then continue end

        if _G.TurboSpin then
            hum.AutoRotate = false
            angle += math.rad(_G.SpinSpeed/1.2)
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0,angle,0)
        else
            hum.AutoRotate = true
        end
    end
end)

-- 简易ESP渲染
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer

    RunService.RenderStepped:Connect(function()
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
        local lpRoot = lp.Character.HumanoidRootPart

        for _, plr in pairs(Players:GetPlayers()) do
            if plr == lp then continue end
            local char = plr.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then continue end

            local isTeammate = false
            if _G.ESP_TeamCheck and plr.Team then
                if lp.Team and plr.Team == plr.Team then
                    isTeammate = true
                end
            end

            if isTeammate then
                if char:FindFirstChild("ESP_Highlight") then char.ESP_Highlight:Destroy() end
                if char:FindFirstChild("ESP_Billboard") then char.ESP_Billboard:Destroy() end
                continue
            end

            if _G.ESP_Highlight then
                if not char:FindFirstChild("ESP_Highlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "ESP_Highlight"
                    hl.Parent = char
                    hl.FillTransparency = 0.7
                    hl.OutlineTransparency = 0
                    hl.FillColor = Color3.new(1,0,0)
                    hl.OutlineColor = Color3.new(1,1,1)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
            else
                if char:FindFirstChild("ESP_Highlight") then char.ESP_Highlight:Destroy() end
            end

            if _G.ESP_Name or _G.ESP_Health or _G.ESP_Distance then
                local bill = char:FindFirstChild("ESP_Billboard") or Instance.new("BillboardGui")
                bill.Name = "ESP_Billboard"
                bill.Parent = char
                bill.Adornee = hrp
                bill.Size = UDim2.new(0,200,0,75)
                bill.StudsOffset = Vector3.new(0,4,0)
                bill.AlwaysOnTop = true

                local nameL = bill:FindFirstChild("Name") or Instance.new("TextLabel")
                nameL.Name = "Name"
                nameL.Parent = bill
                nameL.Size = UDim2.new(1,0,0,25)
                nameL.BackgroundTransparency = 1
                nameL.Text = plr.Name
                nameL.TextColor3 = Color3.new(1,1,1)
                nameL.TextStrokeTransparency = 0
                nameL.Font = _G.ESP_Font
                nameL.TextSize = _G.ESP_TextSize
                nameL.Visible = _G.ESP_Name

                local hpL = bill:FindFirstChild("HP") or Instance.new("TextLabel")
                hpL.Name = "HP"
                hpL.Parent = bill
                hpL.Size = UDim2.new(1,0,0,25)
                hpL.Position = UDim2.new(0,0,0,25)
                hpL.BackgroundTransparency = 1
                hpL.Text = "HP: "..math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)
                hpL.TextColor3 = Color3.new(0,1,0)
                hpL.TextStrokeTransparency = 0
                hpL.Font = _G.ESP_Font
                hpL.TextSize = _G.ESP_TextSize
                hpL.Visible = _G.ESP_Health

                local distL = bill:FindFirstChild("Distance") or Instance.new("TextLabel")
                distL.Name = "Distance"
                distL.Parent = bill
                distL.Size = UDim2.new(1,0,0,25)
                distL.Position = UDim2.new(0,0,0,50)
                distL.BackgroundTransparency = 1
                local dist = math.floor((lpRoot.Position - hrp.Position).Magnitude)
                distL.Text = "距离: "..dist.."  studs"
                distL.TextColor3 = Color3.new(0.2,0.6,1)
                distL.TextStrokeTransparency = 0
                distL.Font = _G.ESP_Font
                distL.TextSize = _G.ESP_TextSize
                distL.Visible = _G.ESP_Distance
            else
                if char:FindFirstChild("ESP_Billboard") then char.ESP_Billboard:Destroy() end
            end
        end
    end)
end)

-- 卸载恢复
Library:OnUnload(function()
    local plr = game.Players.LocalPlayer
    local Lighting = game:GetService("Lighting")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    -- 恢复 Lighting 原始值
    Lighting.Brightness = _G.origBrightness or 1
    Lighting.Ambient = _G.origAmbient or Color3.new(0.5,0.5,0.5)
    Lighting.OutdoorAmbient = _G.origOutdoor or Color3.new(0.5,0.5,0.5)
    Lighting.ClockTime = _G.origClockTime or 14
    Lighting.GlobalShadows = _G.origShadow or true
    Lighting.FogEnd = _G.origFog or 100000

    UserInputService.VSyncEnabled = true
    RunService:SetFrameRate(60)
    workspace:SetPhysicsThrottleRate(60)

    pcall(function()
        if CoreGui:FindFirstChild("MerzzL_FPS") then
            CoreGui.MerzzL_FPS:Destroy()
        end
    end)

    pcall(function()
        for _, gui in pairs(CoreGui:GetDescendants()) do
            if gui.Name:lower():find("backpack") or gui.Name:lower():find("toolbar") then
                if gui:IsA("GuiObject") then
                    gui.Enabled = false
                end
            end
        end
    end)

    if plr.Character then
        for _, part in pairs(plr.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        local h = plr.Character:FindFirstChildOfClass("Humanoid")
        if h then 
            h.AutoRotate = true 
            h.WalkSpeed = _G.GameOriginalWalkSpeed
        end
    end
    for _,p in pairs(game.Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("ESP_Highlight") then p.Character.ESP_Highlight:Destroy() end
            if p.Character:FindFirstChild("ESP_Billboard") then p.Character.ESP_Billboard:Destroy() end
        end
    end
    _G.InfiniteJump = false
    _G.NoclipActive = false
    _G.MapNightVision = false
    _G.InventoryAlwaysShow = false
    _G.UnlockFPS = false
    _G.ShowFPS = false
    if infJumpConn then infJumpConn:Disconnect() end
    if noclipConnection then noclipConnection:Disconnect() end
    fovCircle:Remove()
end)

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
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

-- 作者欢迎提示
local Players = game.Players.LocalPlayer
local Target = "Imai_MerzzL"
local Showed = {}

local function NotifyAll()
    for _,plr in pairs(Players:GetPlayers()) do
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

Players.PlayerAdded:Connect(function(plr)
    if not Showed[plr.UserId] and plr.Name == Target then
        Showed[plr.UserId] = true
        NotifyAll()
    end
end)

for _,plr in pairs(Players:GetPlayers()) do
    if not Showed[plr.UserId] and plr.Name == Target then
        Showed[plr.UserId] = true
        NotifyAll()
    end
end
