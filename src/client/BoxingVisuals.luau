-- Xbox boxing visual test: C0 joint offsets survive the default Animator's Transform writes.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Visuals = {}
local poses = {}
local function locate(character)
    -- Search the full character: custom avatars may not parent joints where R15/R6 normally do.
    local left, right, waist
    local found = {}
    for _, descendant in character:GetDescendants() do
        if descendant:IsA("Motor6D") then
            local name = descendant.Name:lower():gsub("[%s_%-]", "")
            table.insert(found, descendant.Name .. "@" .. descendant.Parent.Name)
            if name == "leftshoulder" then left = descendant
            elseif name == "rightshoulder" then right = descendant
            elseif name == "waist" then waist = descendant end
        end
    end
    if not left or not right then
        return nil, table.concat(found, ", ")
    end
    return {
        left = left, right = right, waist = waist,
        left0 = left.C0, right0 = right.C0, waist0 = waist and waist.C0
    }
end
local function state(player)
    local character = player.Character
    if not character then return nil end
    local p = poses[player]
    if not p or p.character ~= character then
        p = {character = character, joints = nil, lastRigLog = 0, move = nil, started = 0, guard = false, slip = nil, slipStarted = 0}
        poses[player] = p
    end
    if not p.joints then
        local found, diagnostic = locate(character)
        p.joints = found
        if not found and player == Players.LocalPlayer and os.clock() - p.lastRigLog > 5 then
            p.lastRigLog = os.clock()
            local hum = character:FindFirstChildOfClass("Humanoid")
            local parts = {}
            local counts = {BasePart = 0, Bone = 0, Weld = 0, Motor6D = 0, Animator = 0}
            for _, item in character:GetDescendants() do
                for className in counts do
                    if item:IsA(className) then counts[className] += 1 end
                end
                if item:IsA("BasePart") and #parts < 30 then
                    table.insert(parts, item.Name .. "(" .. item.ClassName .. ")")
                end
            end
            warn("[GUGD] RIG AUDIT rigType=", hum and hum.RigType.Name or "NO HUMANOID",
                "character=", character:GetFullName(),
                "parts=", counts.BasePart, "bones=", counts.Bone,
                "welds=", counts.Weld, "motors=", counts.Motor6D,
                "animators=", counts.Animator)
            warn("[GUGD] RIG PART NAMES:", table.concat(parts, ", "))
            warn("[GUGD] Shoulder joints missing; Motor6Ds:", diagnostic)
            player:SetAttribute("BoxingRigDiagnostic", diagnostic ~= "" and diagnostic or "NO MOTOR6D JOINTS")
        elseif found and player == Players.LocalPlayer then
            print("[GUGD] Shoulder joints found:", found.left:GetFullName(), found.right:GetFullName())
            player:SetAttribute("BoxingRigDiagnostic", "RIG FOUND")
        end
    end
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
        local left = CFrame.Angles(math.rad(35), math.rad(-12), math.rad(-12))
        local right = CFrame.Angles(math.rad(35), math.rad(12), math.rad(12))
        local torso = CFrame.Angles(0, math.rad(-12), 0)
        if p.guard then
            left = CFrame.Angles(math.rad(60), 0, math.rad(-12))
            right = CFrame.Angles(math.rad(60), 0, math.rad(12))
        end
        if p.move then
            local elapsed = now - p.started
            if elapsed >= 0.55 then
                p.move = nil
            else
                local k = pulse(elapsed, 0.55)
                if p.move == "jab" then
                    left = left * CFrame.Angles(math.rad(55*k), 0, math.rad(10*k))
                    torso = torso * CFrame.Angles(0, math.rad(-16*k), 0)
                elseif p.move == "cross" then
                    right = right * CFrame.Angles(math.rad(55*k), 0, math.rad(-10*k))
                    torso = torso * CFrame.Angles(0, math.rad(34*k), 0)
                elseif p.move == "leadHook" then
                    left = left * CFrame.Angles(math.rad(20*k), math.rad(-35*k), math.rad(-20*k))
                    torso = torso * CFrame.Angles(0, math.rad(-28*k), 0)
                elseif p.move == "rearUppercut" then
                    right = right * CFrame.Angles(math.rad(35*k), math.rad(12*k), math.rad(15*k))
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
