-- Restore missing R15 Motor6Ds using Roblox's own rig attachment metadata.
-- Runs on server so joints replicate to Xbox clients. Never rebuild an already jointed character.
local Players = game:GetService("Players")
local function audit(character)
    local humanoid = character:WaitForChild("Humanoid", 15)
    if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then return end
    local root = character:WaitForChild("HumanoidRootPart", 15)
    local torso = character:WaitForChild("UpperTorso", 15)
    local left = character:WaitForChild("LeftUpperArm", 15)
    local right = character:WaitForChild("RightUpperArm", 15)
    if not root or not torso or not left or not right then return end
    task.wait(1)
    local motors = 0
    for _, obj in character:GetDescendants() do
        if obj:IsA("Motor6D") then motors += 1 end
    end
    print("[GUGD] SERVER RIG AUDIT", character.Name, "motors=", motors)
    if motors > 0 then return end
    local ok, err = pcall(function()
        humanoid:BuildRigFromAttachments()
    end)
    if not ok then
        warn("[GUGD] BuildRigFromAttachments failed:", err)
        return
    end
    local after = 0
    for _, obj in character:GetDescendants() do
        if obj:IsA("Motor6D") then after += 1 end
    end
    print("[GUGD] SERVER RIG REPAIR", character.Name, "motors=", after)
    if after == 0 then
        warn("[GUGD] No joints after repair. Inspect avatar attachments and character assembly.")
    end
end
local function setup(player)
    player.CharacterAdded:Connect(function(character)
        task.spawn(audit, character)
    end)
    if player.Character then task.spawn(audit, player.Character) end
end
Players.PlayerAdded:Connect(setup)
for _, player in Players:GetPlayers() do setup(player) end
