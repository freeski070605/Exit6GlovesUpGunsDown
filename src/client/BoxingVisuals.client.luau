-- Prototype procedural upper-body boxing visuals. R15 required.
-- No copyrighted animations; replace with cleaned, licensed motion capture clips later.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("CombatRequest")
local connections = {}
local joints = {}
local offsets = {}
local effect = nil
local lastEvent = ""
local function disconnect()
    for _, connection in connections do connection:Disconnect() end
    table.clear(connections)
    joints = {}
    offsets = {}
    effect = nil
end
local function setup(character)
    disconnect()
    local upper = character:WaitForChild("UpperTorso", 8)
    if not upper then warn("[GUGD] R15 rig required for boxing visuals"); return end
    local function getJoint(name)
        local joint = upper:FindFirstChild(name)
        return if joint and joint:IsA("Motor6D") then joint else nil
    end
    joints.left = getJoint("LeftShoulder")
    joints.right = getJoint("RightShoulder")
    joints.waist = getJoint("Waist")
    local head = character:FindFirstChild("Head")
    local neck = head and head:FindFirstChild("Neck")
    if neck and neck:IsA("Motor6D") then joints.neck = neck end
    if not joints.left or not joints.right then warn("[GUGD] Missing R15 shoulder joints"); return end
    for name in joints do offsets[name] = CFrame.identity end
    table.insert(connections, RunService.PreSimulation:Connect(function(dt)
        local now = os.clock()
        local phase = 0
        local move = ""
        if effect then
            local elapsed = now - effect.started
            if elapsed < effect.duration then
                phase = math.sin(math.pi * elapsed / effect.duration)
                move = effect.move
            else
                effect = nil
            end
        end
        local left = CFrame.Angles(math.rad(-45), 0, math.rad(-12))
        local right = CFrame.Angles(math.rad(-45), 0, math.rad(12))
        local waist = CFrame.Angles(0, math.rad(-9), 0)
        local neck = CFrame.identity
        if move == "jab" then
            left = left * CFrame.Angles(math.rad(-75 * phase), 0, math.rad(12 * phase))
            waist = waist * CFrame.Angles(0, math.rad(-12 * phase), 0)
        elseif move == "cross" then
            right = right * CFrame.Angles(math.rad(-85 * phase), 0, math.rad(-12 * phase))
            waist = waist * CFrame.Angles(0, math.rad(22 * phase), 0)
        elseif move == "leadHook" then
            left = left * CFrame.Angles(math.rad(-35 * phase), math.rad(-65 * phase), 0)
            waist = waist * CFrame.Angles(0, math.rad(-24 * phase), 0)
        elseif move == "rearUppercut" then
            right = right * CFrame.Angles(math.rad(35 * phase), math.rad(18 * phase), 0)
            waist = waist * CFrame.Angles(0, math.rad(16 * phase), 0)
        elseif move == "slip_left" then
            waist = waist * CFrame.Angles(0, 0, math.rad(-17 * phase))
            neck = CFrame.Angles(0, 0, math.rad(8 * phase))
        elseif move == "slip_right" then
            waist = waist * CFrame.Angles(0, 0, math.rad(17 * phase))
            neck = CFrame.Angles(0, 0, math.rad(-8 * phase))
        end
        local target = {left = left, right = right, waist = waist, neck = neck}
        for name, joint in joints do
            local desired = target[name] or CFrame.identity
            offsets[name] = offsets[name]:Lerp(desired, math.clamp(dt * 15, 0, 1))
            joint.Transform = offsets[name]
        end
    end))
    print("[GUGD] R15 procedural boxing visuals ready")
end
if player.Character then task.spawn(setup, player.Character) end
player.CharacterAdded:Connect(setup)
remote.OnClientEvent:Connect(function(event, actor, detail)
    if actor ~= player then return end
    if event == "punch" then
        local durations = {jab = 0.34, cross = 0.43, leadHook = 0.50, rearUppercut = 0.55}
        effect = {move = detail, started = os.clock(), duration = durations[detail] or 0.4}
    elseif event == "slip" then
        effect = {move = "slip_" .. tostring(detail), started = os.clock(), duration = 0.33}
    end
end)
