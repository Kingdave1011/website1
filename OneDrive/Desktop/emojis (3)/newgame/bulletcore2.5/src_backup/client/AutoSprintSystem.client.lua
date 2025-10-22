-- Auto-Sprint System for Fast-Paced Gameplay
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local AutoSprintSystem = {}

-- Auto-sprint configuration
local autoSprintConfig = {
    Enabled = true,
    SprintSpeed = 25, -- Default sprint speed
    WalkSpeed = 16, -- Default walk speed
    StaminaEnabled = false,
    StaminaMax = 100,
    StaminaRegen = 10, -- per second
    StaminaCost = 15 -- per second while sprinting
}

-- Sprint state tracking
local sprintState = {
    IsSprinting = false,
    CurrentStamina = autoSprintConfig.StaminaMax,
    LastDirection = Vector3.new(0, 0, 0),
    MovementInput = Vector3.new(0, 0, 0)
}

-- Movement detection
local movementKeys = {
    W = false,
    A = false,
    S = false,
    D = false
}

-- Create sprint indicator UI
local function createSprintUI()
    local sprintUI = Instance.new("ScreenGui")
    sprintUI.Name = "SprintUI"
    sprintUI.ResetOnSpawn = false
    sprintUI.Parent = player.PlayerGui

    -- Sprint indicator
    local sprintIndicator = Instance.new("Frame")
    sprintIndicator.Size = UDim2.new(0, 200, 0, 60)
    sprintIndicator.Position = UDim2.new(0.5, -100, 0.8, 0)
    sprintIndicator.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    sprintIndicator.BackgroundTransparency = 0.8
    sprintIndicator.BorderSizePixel = 0
    sprintIndicator.Visible = false
    sprintIndicator.Parent = sprintUI

    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 8)
    indicatorCorner.Parent = sprintIndicator

    -- Sprint text
    local sprintText = Instance.new("TextLabel")
    sprintText.Size = UDim2.new(1, 0, 0.6, 0)
    sprintText.Position = UDim2.new(0, 0, 0, 0)
    sprintText.BackgroundTransparency = 1
    sprintText.Text = "SPRINTING"
    sprintText.TextColor3 = Color3.fromRGB(255, 255, 255)
    sprintText.Font = Enum.Font.SourceSansBold
    sprintText.TextScaled = true
    sprintText.Parent = sprintIndicator

    -- Stamina bar (if stamina enabled)
    local staminaBar = Instance.new("Frame")
    staminaBar.Size = UDim2.new(0.8, 0, 0.3, 0)
    staminaBar.Position = UDim2.new(0.1, 0, 0.7, 0)
    staminaBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    staminaBar.BorderSizePixel = 0
    staminaBar.Visible = autoSprintConfig.StaminaEnabled
    staminaBar.Parent = sprintIndicator

    local staminaCorner = Instance.new("UICorner")
    staminaCorner.CornerRadius = UDim.new(1, 0)
    staminaCorner.Parent = staminaBar

    local staminaFill = Instance.new("Frame")
    staminaFill.Size = UDim2.new(1, 0, 1, 0)
    staminaFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    staminaFill.BorderSizePixel = 0
    staminaFill.Parent = staminaBar

    local staminaFillCorner = Instance.new("UICorner")
    staminaFillCorner.CornerRadius = UDim.new(1, 0)
    staminaFillCorner.Parent = staminaFill

    return sprintUI, sprintIndicator, staminaFill
end

-- Update sprint state based on movement
local function updateSprintState()
    if not autoSprintConfig.Enabled then return end

    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- Check if player is moving
    local isMoving = false
    local moveDirection = Vector3.new(0, 0, 0)

    -- Check keyboard input
    if movementKeys.W or movementKeys.A or movementKeys.S or movementKeys.D then
        isMoving = true

        -- Calculate movement direction
        if movementKeys.W then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
        if movementKeys.S then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
        if movementKeys.A then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
        if movementKeys.D then moveDirection = moveDirection + Vector3.new(1, 0, 0) end

        moveDirection = moveDirection.Unit
    end

    -- Auto-sprint logic
    if isMoving and autoSprintConfig.Enabled then
        -- Check stamina if enabled
        if autoSprintConfig.StaminaEnabled then
            if sprintState.CurrentStamina > 0 then
                startSprinting(humanoid)
            else
                stopSprinting(humanoid)
            end
        else
            -- No stamina limit - always sprint when moving
            startSprinting(humanoid)
        end
    else
        stopSprinting(humanoid)
    end

    -- Update movement direction for consistency
    sprintState.LastDirection = moveDirection
end

-- Start sprinting
local function startSprinting(humanoid)
    if sprintState.IsSprinting then return end

    sprintState.IsSprinting = true

    -- Set sprint speed
    humanoid.WalkSpeed = autoSprintConfig.SprintSpeed

    -- Update UI indicator
    if sprintIndicator then
        sprintIndicator.Visible = true
        TweenService:Create(sprintIndicator, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
    end

    -- Start stamina drain if enabled
    if autoSprintConfig.StaminaEnabled then
        startStaminaDrain()
    end
end

-- Stop sprinting
local function stopSprinting(humanoid)
    if not sprintState.IsSprinting then return end

    sprintState.IsSprinting = false

    -- Set walk speed
    humanoid.WalkSpeed = autoSprintConfig.WalkSpeed

    -- Update UI indicator
    if sprintIndicator then
        TweenService:Create(sprintIndicator, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play()
        wait(0.3)
        sprintIndicator.Visible = false
    end

    -- Start stamina regen if enabled
    if autoSprintConfig.StaminaEnabled then
        startStaminaRegen()
    end
end

-- Stamina management
local function startStaminaDrain()
    if not autoSprintConfig.StaminaEnabled then return end

    RunService:BindToRenderStep("StaminaDrain", Enum.RenderPriority.Character.Value + 1, function()
        if sprintState.IsSprinting then
            sprintState.CurrentStamina = sprintState.CurrentStamina - autoSprintConfig.StaminaCost * RunService.RenderStepped:Wait()

            if sprintState.CurrentStamina <= 0 then
                sprintState.CurrentStamina = 0
                -- Force stop sprinting when stamina depleted
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        stopSprinting(humanoid)
                    end
                end
            end

            -- Update stamina bar
            if staminaFill then
                local staminaPercent = sprintState.CurrentStamina / autoSprintConfig.StaminaMax
                staminaFill.Size = UDim2.new(staminaPercent, 0, 1, 0)

                -- Change color based on stamina level
                if staminaPercent > 0.5 then
                    staminaFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
                elseif staminaPercent > 0.25 then
                    staminaFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
                else
                    staminaFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
                end
            end
        end
    end)
end

local function startStaminaRegen()
    if not autoSprintConfig.StaminaEnabled then return end

    RunService:BindToRenderStep("StaminaRegen", Enum.RenderPriority.Character.Value + 1, function()
        if not sprintState.IsSprinting and sprintState.CurrentStamina < autoSprintConfig.StaminaMax then
            sprintState.CurrentStamina = sprintState.CurrentStamina + autoSprintConfig.StaminaRegen * RunService.RenderStepped:Wait()

            if sprintState.CurrentStamina > autoSprintConfig.StaminaMax then
                sprintState.CurrentStamina = autoSprintConfig.StaminaMax
            end

            -- Update stamina bar
            if staminaFill then
                local staminaPercent = sprintState.CurrentStamina / autoSprintConfig.StaminaMax
                staminaFill.Size = UDim2.new(staminaPercent, 0, 1, 0)

                -- Regen color (blue-ish)
                staminaFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            end
        end
    end)
end

-- Input handling for movement keys
local function handleInputBegan(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.W then
            movementKeys.W = true
        elseif input.KeyCode == Enum.KeyCode.A then
            movementKeys.A = true
        elseif input.KeyCode == Enum.KeyCode.S then
            movementKeys.S = true
        elseif input.KeyCode == Enum.KeyCode.D then
            movementKeys.D = true
        end
    end
end

local function handleInputEnded(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.W then
            movementKeys.W = false
        elseif input.KeyCode == Enum.KeyCode.A then
            movementKeys.A = false
        elseif input.KeyCode == Enum.KeyCode.S then
            movementKeys.S = false
        elseif input.KeyCode == Enum.KeyCode.D then
            movementKeys.D = false
        end
    end
end

-- Initialize auto-sprint system
function AutoSprintSystem.Initialize()
    -- Create UI elements
    local sprintUI, indicator, stamina = createSprintUI()
    sprintIndicator = indicator
    staminaFill = stamina

    -- Connect input handlers
    UserInputService.InputBegan:Connect(handleInputBegan)
    UserInputService.InputEnded:Connect(handleInputEnded)

    -- Start movement monitoring
    RunService.RenderStepped:Connect(updateSprintState)

    -- Load settings from SettingsGUI if available
    local settingsGUI = require(script.Parent.SettingsGUI)
    if settingsGUI.GetSettings then
        local settings = settingsGUI.GetSettings()
        if settings.Gameplay then
            autoSprintConfig.Enabled = settings.Gameplay.AutoSprint
        end
    end

    print("🏃 Auto-Sprint System initialized!")
    print("💨 Auto-sprint is " .. (autoSprintConfig.Enabled and "ENABLED" or "DISABLED"))
end

-- Public API functions
function AutoSprintSystem.SetEnabled(enabled)
    autoSprintConfig.Enabled = enabled
    print("🏃 Auto-sprint " .. (enabled and "enabled" or "disabled"))
end

function AutoSprintSystem.SetSprintSpeed(speed)
    autoSprintConfig.SprintSpeed = speed
end

function AutoSprintSystem.SetWalkSpeed(speed)
    autoSprintConfig.WalkSpeed = speed
end

function AutoSprintSystem.EnableStamina(enabled)
    autoSprintConfig.StaminaEnabled = enabled
    if staminaFill then
        staminaFill.Parent.Parent.Visible = enabled
    end
end

function AutoSprintSystem.GetSprintState()
    return {
        IsSprinting = sprintState.IsSprinting,
        CurrentStamina = sprintState.CurrentStamina,
        StaminaMax = autoSprintConfig.StaminaMax,
        StaminaEnabled = autoSprintConfig.StaminaEnabled
    }
end

return AutoSprintSystem
