-- Xbox-visible prototype diagnostics and stamina HUD.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "GlovesUpCombatHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.Name = "StatusPanel"
panel.AnchorPoint = Vector2.new(0, 1)
panel.Position = UDim2.new(0, 24, 1, -35)
panel.Size = UDim2.fromOffset(340, 145)
panel.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
panel.BackgroundTransparency = 0.12
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
local function label(name, y, height, fontSize)
    local l = Instance.new("TextLabel")
    l.Name = name
    l.Position = UDim2.fromOffset(12, y)
    l.Size = UDim2.new(1, -24, 0, height)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(245, 245, 245)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamBold
    l.TextSize = fontSize
    l.Parent = panel
    return l
end
local title = label("Title", 8, 22, 17)
title.Text = "EXIT 6  |  GLOVES UP GUNS DOWN"
local stamina = label("Stamina", 37, 26, 20)
local status = label("Status", 70, 24, 16)
local controls = label("Controls", 102, 32, 12)
controls.TextWrapped = true
controls.Text = "Xbox: X Jab | Y Cross | B Hook | A Uppercut | RT Guard | Right stick Punch"
local remote = ReplicatedStorage:WaitForChild("CombatRequest", 12)
if not remote then
    status.Text = "SERVER OFFLINE: CombatRequest missing"
    status.TextColor3 = Color3.fromRGB(255, 105, 105)
    warn("[GUGD] CombatRequest missing: verify CombatService and Rojo sync")
else
    status.Text = "CONNECTED - ready to test punches"
    status.TextColor3 = Color3.fromRGB(120, 240, 170)
    remote.OnClientEvent:Connect(function(event, actor, detail, _, damage)
        if event == "punch" and actor == player then
            status.Text = "SERVER ACCEPTED: " .. tostring(detail)
        elseif event == "slip" and actor == player then
            status.Text = "SLIP: " .. tostring(detail)
        elseif event == "impact" and actor == player then
            status.Text = "HIT REGISTERED: " .. tostring(damage)
        end
    end)
end
local function updateStamina()
    local n = player:GetAttribute("BoxingStamina")
    stamina.Text = "STAMINA: " .. (typeof(n) == "number" and (tostring(n) .. " / 100") or "WAITING FOR SERVER")
end
player:GetAttributeChangedSignal("BoxingVisualDebug"):Connect(function()
    local v = player:GetAttribute("BoxingVisualDebug")
    if v then status.Text = "VISUAL: " .. tostring(v) end
end)
player:GetAttributeChangedSignal("BoxingStamina"):Connect(updateStamina)
updateStamina()
UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Gamepad1 then
        if input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.ButtonY
            or input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonB then
            status.Text = "INPUT SEEN: " .. input.KeyCode.Name
        end
    end
end)
print("[GUGD] Xbox combat HUD loaded")
