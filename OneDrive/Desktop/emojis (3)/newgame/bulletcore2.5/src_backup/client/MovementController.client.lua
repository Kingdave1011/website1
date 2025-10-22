-- WASD Movement Controller
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local keys = {
    W = false,
    A = false,
    S = false,
    D = false,
    Space = false
}

-- Handle key input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        keys.W = true
    elseif input.KeyCode == Enum.KeyCode.A then
        keys.A = true
    elseif input.KeyCode == Enum.KeyCode.S then
        keys.S = true
    elseif input.KeyCode == Enum.KeyCode.D then
        keys.D = true
    elseif input.KeyCode == Enum.KeyCode.Space then
        keys.Space = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        keys.W = false
    elseif input.KeyCode == Enum.KeyCode.A then
        keys.A = false
    elseif input.KeyCode == Enum.KeyCode.S then
        keys.S = false
    elseif input.KeyCode == Enum.KeyCode.D then
        keys.D = false
    elseif input.KeyCode == Enum.KeyCode.Space then
        keys.Space = false
    end
end)

-- Movement update
RunService.Heartbeat:Connect(function()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character.HumanoidRootPart
    
    if humanoid and humanoid.Health > 0 then
        local cameraCFrame = camera.CFrame
        local moveVector = Vector3.new()
        
        -- Calculate movement direction based on camera
        if keys.W then
            moveVector = moveVector + cameraCFrame.LookVector
        end
        if keys.S then
            moveVector = moveVector - cameraCFrame.LookVector
        end
        if keys.A then
            moveVector = moveVector - cameraCFrame.RightVector
        end
        if keys.D then
            moveVector = moveVector + cameraCFrame.RightVector
        end
        
        -- Normalize and apply movement
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit
            humanoid:Move(moveVector, false)
        end
        
        -- Jump
        if keys.Space then
            humanoid.Jump = true
        end
    end
end)