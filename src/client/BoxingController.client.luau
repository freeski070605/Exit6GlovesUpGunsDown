-- Xbox-first input prototype. Animations will be bound after motion capture.
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local Visuals = require(script.Parent:WaitForChild("BoxingVisuals"))
local remote = ReplicatedStorage:WaitForChild("CombatRequest")
local lastPunch = 0
local localBusyUntil = 0
local punchCooldown = 0.12
local stickThreshold = 0.72
local wasOutside = false
local bodyModifier = false
local guard = false

local function punch(move: string)
    local now = os.clock()
    if now - lastPunch < punchCooldown or now < localBusyUntil or guard then return end
    lastPunch = now
    localBusyUntil = now + punchCooldown
    remote:FireServer("punch", move)
    Visuals.Punch(player, move)

end
local function setGuard(enabled: boolean)
    if guard == enabled then return end
    guard = enabled
    remote:FireServer("guard", enabled)
    Visuals.Guard(player, enabled)
end
local function guardAction(_, state)
    if state == Enum.UserInputState.Begin then setGuard(true)
    elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then setGuard(false) end
    return Enum.ContextActionResult.Sink
end
local function bodyAction(_, state)
    bodyModifier = state == Enum.UserInputState.Begin
    return Enum.ContextActionResult.Sink
end
local function slipAction(_, state, input)
    if state == Enum.UserInputState.Begin then
        local direction = (input and input.KeyCode == Enum.KeyCode.Q) and "left" or "right"
        remote:FireServer("slip", direction)
        Visuals.Slip(player, direction)
    end
    return Enum.ContextActionResult.Sink
end
ContextActionService:BindAction("BoxGuard", guardAction, true, Enum.KeyCode.ButtonR2, Enum.KeyCode.F)
ContextActionService:BindAction("BoxBody", bodyAction, true, Enum.KeyCode.ButtonL2, Enum.KeyCode.LeftShift)
ContextActionService:BindAction("BoxSlipLeft", slipAction, true, Enum.KeyCode.Q)
ContextActionService:BindAction("BoxSlipRight", slipAction, true, Enum.KeyCode.E)
ContextActionService:BindAction("BoxJab", function(_, state)
    if state == Enum.UserInputState.Begin then punch("jab") end
    return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.ButtonX, Enum.KeyCode.One)
ContextActionService:BindAction("BoxCross", function(_, state)
    if state == Enum.UserInputState.Begin then punch("cross") end
    return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.ButtonY, Enum.KeyCode.Two)
ContextActionService:BindAction("BoxHook", function(_, state)
    if state == Enum.UserInputState.Begin then punch("leadHook") end
    return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.ButtonB, Enum.KeyCode.Three)
ContextActionService:BindAction("BoxUppercut", function(_, state)
    if state == Enum.UserInputState.Begin then punch("rearUppercut") end
    return Enum.ContextActionResult.Sink
end, true, Enum.KeyCode.ButtonA, Enum.KeyCode.Four)

UserInputService.InputChanged:Connect(function(input)
    if input.KeyCode ~= Enum.KeyCode.Thumbstick2 then return end
    local v = input.Position
    if v.Magnitude < 0.35 then wasOutside = false; return end
    if v.Magnitude < stickThreshold or wasOutside then return end
    wasOutside = true
    if math.abs(v.X) > math.abs(v.Y) then
        punch(v.X < 0 and "jab" or "cross")
    else
        punch(v.Y > 0 and "leadHook" or "rearUppercut")
    end
end)
remote.OnClientEvent:Connect(function(event, actor, detail)
    if actor == player then return end
    if event == "punch" then Visuals.Punch(actor, detail)
    elseif event == "slip" then Visuals.Slip(actor, detail) end
end)
