-- Animation-ready bridge. Procedural C0 shoulder/elbow/waist overrides removed.
-- Keep the public interface so Xbox inputs and CombatService remain unchanged.
-- Published R15 animation tracks will be connected here in a later pass.
local Players = game:GetService("Players")
local Visuals = {}

function Visuals.Punch(player, move)
    if player == Players.LocalPlayer then
        player:SetAttribute("BoxingVisualDebug", "ANIMATION PENDING: " .. tostring(move))
    end
end

function Visuals.Guard(_player, _enabled)
    -- Reserved for authored guard animation.
end

function Visuals.Slip(_player, _direction)
    -- Reserved for authored slip animations.
end

print("[GUGD] Procedural boxing poses disabled; awaiting authored R15 animations")
return Visuals
