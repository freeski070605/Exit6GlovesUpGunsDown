-- Prototype server authority. Uses coarse target volume until animation-driven hitboxes exist.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage:WaitForChild("CombatConfig"))
local Moves = require(ReplicatedStorage:WaitForChild("MoveDefinitions"))
local remote = ReplicatedStorage:FindFirstChild("CombatRequest") or Instance.new("RemoteEvent")
remote.Name = "CombatRequest"
remote.Parent = ReplicatedStorage

type Fighter = {stamina: number, busyUntil: number, guard: boolean, slipUntil: number, lastSlip: number}
local fighters: {[Player]: Fighter} = {}
local function state(player: Player): Fighter
    if not fighters[player] then
        fighters[player] = {stamina = Config.MaxStamina, busyUntil = 0, guard = false, slipUntil = 0, lastSlip = -10}
    end
    return fighters[player]
end
local function rootAndHumanoid(player: Player)
    local character = player.Character
    if not character then return nil, nil end
    return character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Humanoid")
end
local function reset(player: Player)
    fighters[player] = {stamina = Config.MaxStamina, busyUntil = 0, guard = false, slipUntil = 0, lastSlip = -10}
end
Players.PlayerAdded:Connect(function(player)
    reset(player)
    player.CharacterAdded:Connect(function() reset(player) end)
end)
Players.PlayerRemoving:Connect(function(player) fighters[player] = nil end)
for _, player in Players:GetPlayers() do
    reset(player)
    player.CharacterAdded:Connect(function() reset(player) end)
end
remote.OnServerEvent:Connect(function(player: Player, action: any, moveId: any)
    if typeof(action) ~= "string" then return end
    local now = os.clock()
    local fighter = state(player)
    local root, humanoid = rootAndHumanoid(player)
    if not root or not humanoid or humanoid.Health <= 0 then return end
    if action == "guard" then
        if typeof(moveId) ~= "boolean" then return end
        fighter.guard = moveId
        humanoid.WalkSpeed = moveId and Config.GuardWalkSpeed or Config.WalkSpeed
        return
    end
    if action == "slip" then
        if typeof(moveId) ~= "string" or (moveId ~= "left" and moveId ~= "right") then return end
        if now < fighter.busyUntil or now - fighter.lastSlip < Config.SlipCooldown then return end
        fighter.lastSlip = now
        fighter.slipUntil = now + Config.SlipDuration
        fighter.busyUntil = now + Config.SlipDuration
        remote:FireAllClients("slip", player, moveId)
        return
    end
    if action ~= "punch" or typeof(moveId) ~= "string" then return end
    local move = Moves[moveId]
    if not move or now < fighter.busyUntil or fighter.guard or fighter.stamina < move.staminaCost then return end
    fighter.stamina -= move.staminaCost
    fighter.busyUntil = now + move.startup + move.active + move.recovery
    remote:FireAllClients("punch", player, moveId)
    task.delay(move.startup + move.active * 0.5, function()
        local currentRoot, currentHumanoid = rootAndHumanoid(player)
        if not currentRoot or not currentHumanoid or currentHumanoid.Health <= 0 then return end
        local bestTarget: Player? = nil
        local bestDistance = math.huge
        for _, other in Players:GetPlayers() do
            if other ~= player then
                local targetRoot, targetHumanoid = rootAndHumanoid(other)
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local delta = targetRoot.Position - currentRoot.Position
                    local distance = delta.Magnitude
                    if distance > 0.01 and distance <= math.min(move.range, Config.MaxRangeStuds)
                        and currentRoot.CFrame.LookVector:Dot(delta.Unit) >= Config.FacingDotMinimum
                        and distance < bestDistance then
                        bestTarget, bestDistance = other, distance
                    end
                end
            end
        end
        if bestTarget then
            local target = state(bestTarget)
            local _, targetHumanoid = rootAndHumanoid(bestTarget)
            if targetHumanoid then
                local multiplier = 1
                if now < target.slipUntil then multiplier = Config.SlipDamageMultiplier
                elseif target.guard then multiplier = Config.GuardDamageMultiplier end
                local damage = (Config.BaseDamage[moveId] or 0) * multiplier
                if damage > 0 then targetHumanoid:TakeDamage(damage) end
                remote:FireAllClients("impact", player, bestTarget, moveId, damage)
            end
        end
    end)
end)
RunService.Heartbeat:Connect(function(dt)
    for player, fighter in fighters do
        if player.Parent == Players then
            fighter.stamina = math.min(Config.MaxStamina, fighter.stamina + Config.StaminaRegenPerSecond * dt)
            player:SetAttribute("BoxingStamina", math.floor(fighter.stamina + 0.5))
        end
    end
end)
