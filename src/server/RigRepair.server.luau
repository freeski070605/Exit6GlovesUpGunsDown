-- Restore missing standard R15 Motor6D joints from matching RigAttachments.
-- Only repairs absent joints; never replaces existing motors.
local Players = game:GetService("Players")
local links = {
    {"HumanoidRootPart", "LowerTorso", "Root", "RootRigAttachment"},
    {"LowerTorso", "UpperTorso", "Waist", "WaistRigAttachment"},
    {"UpperTorso", "Head", "Neck", "NeckRigAttachment"},
    {"UpperTorso", "LeftUpperArm", "LeftShoulder", "LeftShoulderRigAttachment"},
    {"LeftUpperArm", "LeftLowerArm", "LeftElbow", "LeftElbowRigAttachment"},
    {"LeftLowerArm", "LeftHand", "LeftWrist", "LeftWristRigAttachment"},
    {"UpperTorso", "RightUpperArm", "RightShoulder", "RightShoulderRigAttachment"},
    {"RightUpperArm", "RightLowerArm", "RightElbow", "RightElbowRigAttachment"},
    {"RightLowerArm", "RightHand", "RightWrist", "RightWristRigAttachment"},
    {"LowerTorso", "LeftUpperLeg", "LeftHip", "LeftHipRigAttachment"},
    {"LeftUpperLeg", "LeftLowerLeg", "LeftKnee", "LeftKneeRigAttachment"},
    {"LeftLowerLeg", "LeftFoot", "LeftAnkle", "LeftAnkleRigAttachment"},
    {"LowerTorso", "RightUpperLeg", "RightHip", "RightHipRigAttachment"},
    {"RightUpperLeg", "RightLowerLeg", "RightKnee", "RightKneeRigAttachment"},
    {"RightLowerLeg", "RightFoot", "RightAnkle", "RightAnkleRigAttachment"},
}
local function repair(character)
    local hum = character:WaitForChild("Humanoid", 15)
    if not hum or hum.RigType ~= Enum.HumanoidRigType.R15 then return end
    character:WaitForChild("HumanoidRootPart", 15)
    character:WaitForChild("UpperTorso", 15)
    task.wait(1)
    local before = 0
    for _, v in character:GetDescendants() do
        if v:IsA("Motor6D") then before += 1 end
    end
    print("[GUGD] R15 joint audit", character.Name, "before=", before)
    if before >= 15 then return end
    local created = 0
    for _, spec in links do
        local parentPart = character:FindFirstChild(spec[1])
        local childPart = character:FindFirstChild(spec[2])
        if not parentPart or not childPart or not parentPart:IsA("BasePart") or not childPart:IsA("BasePart") then
            warn("[GUGD] Missing R15 body part:", spec[1], spec[2])
            continue
        end
        local already = false
        for _, obj in character:GetDescendants() do
            if obj:IsA("Motor6D") and obj.Part0 == parentPart and obj.Part1 == childPart then
                already = true
                break
            end
        end
        if already then continue end
        local a0 = parentPart:FindFirstChild(spec[4])
        local a1 = childPart:FindFirstChild(spec[4])
        if not a0 or not a1 or not a0:IsA("Attachment") or not a1:IsA("Attachment") then
            warn("[GUGD] Missing rig attachments:", spec[3], spec[4])
            continue
        end
        local motor = Instance.new("Motor6D")
        motor.Name = spec[3]
        motor.Part0 = parentPart
        motor.Part1 = childPart
        motor.C0 = a0.CFrame
        motor.C1 = a1.CFrame
        motor.Parent = parentPart
        created += 1
    end
    local after = 0
    for _, v in character:GetDescendants() do
        if v:IsA("Motor6D") then after += 1 end
    end
    print("[GUGD] R15 JOINT REPAIR", character.Name, "created=", created, "total=", after)
    if after < 15 then warn("[GUGD] R15 rig still incomplete; inspect missing attachment warnings") end
end
local function setup(player)
    player.CharacterAdded:Connect(function(c) task.spawn(repair, c) end)
    if player.Character then task.spawn(repair, player.Character) end
end
Players.PlayerAdded:Connect(setup)
for _, p in Players:GetPlayers() do setup(p) end
