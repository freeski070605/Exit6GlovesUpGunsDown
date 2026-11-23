-- Xbox boxing visual test: C0 joint offsets survive the default Animator's Transform writes.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Visuals = {}
local poses = {}
local function locate(character)
    local upper = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not upper then return nil end
    local left = upper:FindFirstChild("LeftShoulder") or upper:FindFirstChild("Left Shoulder")
    local right = upper:FindFirstChild("RightShoulder") or upper:FindFirstChild("Right Shoulder")
    if not left or not right then return nil end
    local lower = character:FindFirstChild("LowerTorso")
    return {left = left, right = right, waist = lower and lower:FindFirstChild("Waist"), left0 = left.C0, right0 = right.C0, waist0 = lower and lower:FindFirstChild("Waist") and lower.Waist.C0}
end
local function state(player)
    local character = player.Character
    if not character then return nil end
    local p = poses[player]
    if not p or p.character ~= character then
        p = {character = character, joints = nil, move = nil, started = 0, guard = false, slip = nil, slipStarted = 0}
        poses[player] = p
    end
    if not p.joints then p.joints = locate(character) end
    return p
end
function Visuals.Punch(player, move)
    local p = state(player)
    if p then
        p.move = move
        p.started = os.clock()
        if player == Players.LocalPlayer then
            player:SetAttribute("BoxingVisualDebug", p.joints and ("PUNCH: " .. move) or "NO SHOULDER JOINTS")
            print("[GUGD] Visual punch", move, p.joints ~= nil)
        end
    end
end
function Visuals.Guard(player, enabled)
    local p = state(player)
    if p then p.guard = enabled end
end
function Visuals.Slip(player, direction)
    local p = state(player)
    if p then p.slip = direction; p.slipStarted = os.clock() end
end
local function pulse(elapsed, duration)
    return math.sin(math.pi * math.clamp(elapsed / duration, 0, 1))
end
RunService.RenderStepped:Connect(function()
    local now = os.clock()
    for _, player in Players:GetPlayers() do
        local p = state(player)
        if not p or not p.joints then continue end
        local j = p.joints
        local hum = p.character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        -- C0 offsets relative to original Roblox rig joints.
        local left = CFrame.Angles(math.rad(-65), math.rad(-12), math.rad(-20))
        local right = CFrame.Angles(math.rad(-65), math.rad(12), math.rad(20))
        local torso = CFrame.Angles(0, math.rad(-12), 0)
        if p.guard then
            left = CFrame.Angles(math.rad(-105), 0, math.rad(-14))
            right = CFrame.Angles(math.rad(-105), 0, math.rad(14))
        end
        if p.move then
            local elapsed = now - p.started
            if elapsed >= 0.55 then
                p.move = nil
            else
                local k = pulse(elapsed, 0.55)
                if p.move == "jab" then
                    left = left * CFrame.Angles(math.rad(-95*k), 0, math.rad(10*k))
                    torso = torso * CFrame.Angles(0, math.rad(-16*k), 0)
                elseif p.move == "cross" then
                    right = right * CFrame.Angles(math.rad(-105*k), 0, math.rad(-10*k))
                    torso = torso * CFrame.Angles(0, math.rad(34*k), 0)
                elseif p.move == "leadHook" then
                    left = left * CFrame.Angles(math.rad(-25*k), math.rad(-85*k), math.rad(-35*k))
                    torso = torso * CFrame.Angles(0, math.rad(-28*k), 0)
                elseif p.move == "rearUppercut" then
                    right = right * CFrame.Angles(math.rad(65*k), math.rad(20*k), math.rad(25*k))
                    torso = torso * CFrame.Angles(math.rad(-12*k), math.rad(22*k), 0)
                end
            end
        end
        if p.slip and now - p.slipStarted < 0.4 then
            local k = pulse(now - p.slipStarted, 0.4)
            torso = torso * CFrame.Angles(0, 0, math.rad((p.slip == "left" and -18 or 18)*k))
        end
        j.left.C0 = j.left0 * left
        j.right.C0 = j.right0 * right
        if j.waist and j.waist0 then j.waist.C0 = j.waist0 * torso end
    end
end)
Players.PlayerRemoving:Connect(function(player) poses[player] = nil end)
print("[GUGD] C0 boxing visual controller started")
return Visuals
