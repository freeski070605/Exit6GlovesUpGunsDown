-- Procedural R15/R6 boxing prototype. Replace with authored animation assets later.
-- Motor6D.Transform is written after Animator evaluation in PreSimulation.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Visuals = {}
local poses = {}
local function joints(character)
    local upper = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local lower = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
    if not upper then return nil end
    return {
        left = upper:FindFirstChild("LeftShoulder") or upper:FindFirstChild("Left Shoulder"),
        right = upper:FindFirstChild("RightShoulder") or upper:FindFirstChild("Right Shoulder"),
        waist = lower and lower:FindFirstChild("Waist"),
        neck = upper:FindFirstChild("Neck"),
    }
end
local function getPose(player)
    local character = player.Character
    if not character then return nil end
    local p = poses[player]
    if not p or p.character ~= character then
        p = {character = character, joints = joints(character), move = nil, started = 0, guard = false, slip = nil, slipStarted = 0}
        poses[player] = p
    end
    return p
end
function Visuals.Punch(player, move)
    local p = getPose(player)
    if p then p.move = move; p.started = os.clock() end
end
function Visuals.Guard(player, enabled)
    local p = getPose(player)
    if p then p.guard = enabled end
end
function Visuals.Slip(player, direction)
    local p = getPose(player)
    if p then p.slip = direction; p.slipStarted = os.clock() end
end
local function swing(time, duration)
    local phase = math.clamp(time / duration, 0, 1)
    return math.sin(phase * math.pi) ^ 0.65
end
RunService.PreSimulation:Connect(function()
    local t = os.clock()
    for _, player in Players:GetPlayers() do
        local p = getPose(player)
        if not p then continue end
        if not p.joints or not p.joints.left or not p.joints.right then
            p.joints = joints(p.character)
        end
        local j = p.joints
        if not j or not j.left or not j.right then continue end
        local humanoid = p.character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        -- Raised hands, tucked elbows and a slight torso turn. Uses original procedural poses.
        local left = CFrame.Angles(math.rad(-48), math.rad(-12), math.rad(-24))
        local right = CFrame.Angles(math.rad(-48), math.rad(12), math.rad(24))
        local torso = CFrame.Angles(0, math.rad(-10), 0)
        if p.guard then
            left = CFrame.Angles(math.rad(-85), math.rad(-14), math.rad(-15))
            right = CFrame.Angles(math.rad(-85), math.rad(14), math.rad(15))
        end
        if p.move then
            local elapsed = t - p.started
            if elapsed > 0.65 then
                p.move = nil
            else
                local power = swing(elapsed, 0.46)
                if p.move == "jab" then
                    left = left * CFrame.Angles(math.rad(-95 * power), 0, math.rad(8 * power))
                    torso = torso * CFrame.Angles(0, math.rad(-14 * power), 0)
                elseif p.move == "cross" then
                    right = right * CFrame.Angles(math.rad(-108 * power), 0, math.rad(-8 * power))
                    torso = torso * CFrame.Angles(0, math.rad(35 * power), 0)
                elseif p.move == "leadHook" then
                    left = left * CFrame.Angles(math.rad(-42 * power), math.rad(-80 * power), math.rad(-30 * power))
                    torso = torso * CFrame.Angles(0, math.rad(-28 * power), 0)
                elseif p.move == "rearUppercut" then
                    right = right * CFrame.Angles(math.rad(35 * power), math.rad(20 * power), math.rad(28 * power))
                    torso = torso * CFrame.Angles(math.rad(-10 * power), math.rad(24 * power), 0)
                end
            end
        end
        if p.slip and t - p.slipStarted < 0.4 then
            local amount = swing(t - p.slipStarted, 0.4)
            torso = torso * CFrame.Angles(0, 0, math.rad((p.slip == "left" and -18 or 18) * amount))
        end
        j.left.Transform = left
        j.right.Transform = right
        if j.waist then j.waist.Transform = torso end
    end
end)
Players.PlayerRemoving:Connect(function(player) poses[player] = nil end)
print("[GUGD] Procedural boxing stance and punch visuals loaded")
return Visuals
