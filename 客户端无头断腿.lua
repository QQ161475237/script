--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
getgenv().InvisibleHead = true
getgenv().PhantomLeg = true

repeat task.wait() until game:IsLoaded()

local plr = game:GetService("Players").LocalPlayer

local function purgeFaces(h)
    for _, x in ipairs(h:GetChildren()) do
        if x:IsA("Decal") then x.Transparency = 1 end
    end
end

local function ghostHead(char)
    if not getgenv().InvisibleHead then return end
    local h = char:FindFirstChild("Head") or char:WaitForChild("Head", 3)
    if not h then return end

    h.Transparency = 1
    purgeFaces(h)

    h.ChildAdded:Connect(function(o)
        if o:IsA("Decal") then o.Transparency = 1 end
    end)

    task.spawn(function()
        local t = os.clock()
        while os.clock() - t < 2 and h.Parent do
            purgeFaces(h)
            task.wait(0.1)
        end
    end)
end

local function shadowLeg(char)
    if not getgenv().PhantomLeg then return end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
    if not hum then return end

    local oldShell = char:FindFirstChild("PhantomShell")
    if oldShell then oldShell:Destroy() end

    if hum.RigType == Enum.HumanoidRigType.R15 then
        local limbs = {
            {"RightLowerLeg", 902942093, true},
            {"RightUpperLeg", 902942096, false, 902843398},
            {"RightFoot", 902942089, true}
        }
        for _, info in ipairs(limbs) do
            local p = char:FindFirstChild(info[1])
            if p and p:IsA("MeshPart") then
                p.MeshId = "http://www.roblox.com/asset/?id=" .. info[2]
                if info[3] then p.Transparency = 1 end
                if info[4] then p.TextureID = "http://roblox.com/asset/?id=" .. info[4] end
            end
        end
    else
        local base = char:FindFirstChild("Right Leg")
        if not base then return end

        base.Transparency = 1

        local shell = Instance.new("Part")
        shell.Name = "PhantomShell"
        shell.Size = Vector3.new(1, 2, 1)
        shell.CanCollide = false
        shell.Massless = true
        shell.Transparency = 1
        shell.CFrame = base.CFrame * CFrame.new(0, 0.75, 0)
        shell.Parent = char

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = shell
        weld.Part1 = base
        weld.Parent = shell

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "http://www.roblox.com/asset/?id=902942093"
        mesh.TextureId = "http://roblox.com/asset/?id=902843398"
        mesh.Scale = Vector3.new(0.85, 1.25, 0.85)
        mesh.Parent = shell
    end
end

-- this just execute the script immediately and reapply its
task.wait(0.5)
if plr.Character then
    ghostHead(plr.Character)
    shadowLeg(plr.Character)
end

plr.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    ghostHead(char)
    shadowLeg(char)
end)