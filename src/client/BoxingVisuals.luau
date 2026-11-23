-- Authored Roblox animation playback. No procedural joint rotations.
local Players = game:GetService("Players")
local Visuals = {}
local STANCE_ID = "rbxassetid://101022751659368"
local JAB_ID = "rbxassetid://80156173812079"
local tracks = {}

local function ensureStance(player)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    local existing = tracks[player]
    if existing and existing.character == character then return existing.track end
    if existing then existing.track:Stop(0.1) end
    local animation = Instance.new("Animation")
    animation.AnimationId = STANCE_ID
    local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
    animation:Destroy()
    if not ok then
        warn("[GUGD] Failed to load boxing stance:", track)
        return
    end
    track.Looped = true
    track.Priority = Enum.AnimationPriority.Action
    tracks[player] = {character = character, track = track, jab = nil}
    track:Play(0.2)
    print("[GUGD] Boxing stance playing for", player.Name)
    return track
end

function Visuals.Punch(player, move)
    ensureStance(player)
    if move ~= "jab" then
        if player == Players.LocalPlayer then
            player:SetAttribute("BoxingVisualDebug", "ANIMATION PENDING: " .. tostring(move))
        end
        return
    end
    local entry = tracks[player]
    if not entry then return end
    if not entry.jab then
        local humanoid = entry.character:FindFirstChildOfClass("Humanoid")
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if not animator then return end
        local animation = Instance.new("Animation")
        animation.AnimationId = JAB_ID
        local ok, jabTrack = pcall(function() return animator:LoadAnimation(animation) end)
        animation:Destroy()
        if not ok then
            warn("[GUGD] Failed to load jab:", jabTrack)
            return
        end
        jabTrack.Priority = Enum.AnimationPriority.Action2
        jabTrack.Looped = false
        entry.jab = jabTrack
    end
    -- Keep the looping stance underneath; the jab temporarily overrides its keyed joints.
    entry.jab:Stop(0)
    entry.jab:Play(0.06, 1, 1)
    if player == Players.LocalPlayer then
        player:SetAttribute("BoxingVisualDebug", "JAB ANIMATION PLAYING")
    end
end

function Visuals.Guard(player, _enabled)
    ensureStance(player)
end

function Visuals.Slip(player, _direction)
    ensureStance(player)
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.spawn(function()
            local humanoid = character:WaitForChild("Humanoid", 15)
            if not humanoid then return end
            humanoid:WaitForChild("Animator", 15)
            -- RigRepair may create Motor6Ds after the character spawns.
            local deadline = os.clock() + 12
            while character.Parent and os.clock() < deadline do
                local motors = 0
                for _, child in character:GetDescendants() do
                    if child:IsA("Motor6D") then motors += 1 end
                end
                if motors >= 10 then break end
                task.wait(0.25)
            end
            ensureStance(player)
        end)
    end)
    if player.Character then
        task.spawn(function()
            local character = player.Character
            local humanoid = character:WaitForChild("Humanoid", 15)
            if not humanoid then return end
            humanoid:WaitForChild("Animator", 15)
            task.wait(0.5)
            ensureStance(player)
        end)
    end
end

for _, player in Players:GetPlayers() do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    local entry = tracks[player]
    if entry then entry.track:Stop(0.1) end
    tracks[player] = nil
end)

return Visuals
