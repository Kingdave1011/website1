-- Mobile Touch Controls System
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local MobileControls = {}

-- Touch control states
local touchStates = {
    MoveJoystick = {Active = false, TouchId = nil, Position = Vector2.new(0, 0)},
    LookJoystick = {Active = false, TouchId = nil, Position = Vector2.new(0, 0)},
    ShootButton = {Active = false, TouchId = nil},
    ReloadButton = {Active = false, TouchId = nil},
    JumpButton = {Active = false, TouchId = nil}
}

-- Control UI elements
local controlElements = {}

-- Mobile control configuration
local controlConfig = {
    JoystickSize = 80,
    ButtonSize = 60,
    JoystickMaxDistance = 50,
    LookSensitivity = 0.5,
    MoveSensitivity = 1.0
}

-- Create mobile control UI
local function createMobileControls()
    local mobileUI = Instance.new("ScreenGui")
    mobileUI.Name = "MobileControls"
    mobileUI.ResetOnSpawn = false
    mobileUI.Parent = player.PlayerGui

    -- Movement joystick (bottom left)
    local moveJoystick = Instance.new("Frame")
    moveJoystick.Size = UDim2.new(0, controlConfig.JoystickSize * 2, 0, controlConfig.JoystickSize * 2)
    moveJoystick.Position = UDim2.new(0, 20, 1, -controlConfig.JoystickSize * 2 - 20)
    moveJoystick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    moveJoystick.BackgroundTransparency = 0.3
    moveJoystick.BorderSizePixel = 0
    moveJoystick.Parent = mobileUI

    local moveCorner = Instance.new("UICorner")
    moveCorner.CornerRadius = UDim.new(1, 0)
    moveCorner.Parent = moveJoystick

    -- Movement joystick knob
    local moveKnob = Instance.new("Frame")
    moveKnob.Size = UDim2.new(0, controlConfig.JoystickSize, 0, controlConfig.JoystickSize)
    moveKnob.Position = UDim2.new(0.5, -controlConfig.JoystickSize/2, 0.5, -controlConfig.JoystickSize/2)
    moveKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    moveKnob.BackgroundTransparency = 0.1
    moveKnob.BorderSizePixel = 0
    moveKnob.Parent = moveJoystick

    local moveKnobCorner = Instance.new("UICorner")
    moveKnobCorner.CornerRadius = UDim.new(1, 0)
    moveKnobCorner.Parent = moveKnob

    -- Look joystick (bottom right)
    local lookJoystick = Instance.new("Frame")
    lookJoystick.Size = UDim2.new(0, controlConfig.JoystickSize * 2, 0, controlConfig.JoystickSize * 2)
    lookJoystick.Position = UDim2.new(1, -controlConfig.JoystickSize * 2 - 20, 1, -controlConfig.JoystickSize * 2 - 20)
    lookJoystick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    lookJoystick.BackgroundTransparency = 0.3
    lookJoystick.BorderSizePixel = 0
    lookJoystick.Parent = mobileUI

    local lookCorner = Instance.new("UICorner")
    lookCorner.CornerRadius = UDim.new(1, 0)
    lookCorner.Parent = lookJoystick

    -- Look joystick knob
    local lookKnob = Instance.new("Frame")
    lookKnob.Size = UDim2.new(0, controlConfig.JoystickSize, 0, controlConfig.JoystickSize)
    lookKnob.Position = UDim2.new(0.5, -controlConfig.JoystickSize/2, 0.5, -controlConfig.JoystickSize/2)
    lookKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    lookKnob.BackgroundTransparency = 0.1
    lookKnob.BorderSizePixel = 0
    lookKnob.Parent = lookJoystick

    local lookKnobCorner = Instance.new("UICorner")
    lookKnobCorner.CornerRadius = UDim.new(1, 0)
    lookKnobCorner.Parent = lookKnob

    -- Shoot button (right side)
    local shootButton = Instance.new("TextButton")
    shootButton.Size = UDim2.new(0, controlConfig.ButtonSize, 0, controlConfig.ButtonSize)
    shootButton.Position = UDim2.new(1, -controlConfig.ButtonSize - 20, 0.5, -controlConfig.ButtonSize/2)
    shootButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    shootButton.BackgroundTransparency = 0.2
    shootButton.BorderSizePixel = 0
    shootButton.Text = "🔫"
    shootButton.TextScaled = true
    shootButton.Parent = mobileUI

    local shootCorner = Instance.new("UICorner")
    shootCorner.CornerRadius = UDim.new(1, 0)
    shootCorner.Parent = shootButton

    -- Reload button (bottom center)
    local reloadButton = Instance.new("TextButton")
    reloadButton.Size = UDim2.new(0, controlConfig.ButtonSize, 0, controlConfig.ButtonSize)
    reloadButton.Position = UDim2.new(0.5, -controlConfig.ButtonSize/2, 1, -controlConfig.ButtonSize - 20)
    reloadButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    reloadButton.BackgroundTransparency = 0.2
    reloadButton.BorderSizePixel = 0
    reloadButton.Text = "🔄"
    reloadButton.TextScaled = true
    reloadButton.Parent = mobileUI

    local reloadCorner = Instance.new("UICorner")
    reloadCorner.CornerRadius = UDim.new(1, 0)
    reloadCorner.Parent = reloadButton

    -- Jump button (left side)
    local jumpButton = Instance.new("TextButton")
    jumpButton.Size = UDim2.new(0, controlConfig.ButtonSize, 0, controlConfig.ButtonSize)
    jumpButton.Position = UDim2.new(0, 20, 0.5, -controlConfig.ButtonSize/2)
    jumpButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    jumpButton.BackgroundTransparency = 0.2
    jumpButton.BorderSizePixel = 0
    jumpButton.Text = "⬆️"
    jumpButton.TextScaled = true
    jumpButton.Parent = mobileUI

    local jumpCorner = Instance.new("UICorner")
    jumpCorner.CornerRadius = UDim.new(1, 0)
    jumpCorner.Parent = jumpButton

    -- Store references
    controlElements = {
        MobileUI = mobileUI,
        MoveJoystick = moveJoystick,
        MoveKnob = moveKnob,
        LookJoystick = lookJoystick,
        LookKnob = lookKnob,
        ShootButton = shootButton,
        ReloadButton = reloadButton,
        JumpButton = jumpButton
    }

    return mobileUI
end

-- Handle touch input
local function handleTouchInput(touch, gameProcessed)
    if gameProcessed then return end

    local touchPosition = touch.Position

    -- Check if touch is on movement joystick
    if isPointInFrame(touchPosition, controlElements.MoveJoystick) then
        touchStates.MoveJoystick.Active = true
        touchStates.MoveJoystick.TouchId = touch
        touchStates.MoveJoystick.Position = touchPosition

        -- Move knob to touch position
        local knobPos = getKnobPosition(touchPosition, controlElements.MoveJoystick)
        controlElements.MoveKnob.Position = knobPos

    -- Check if touch is on look joystick
    elseif isPointInFrame(touchPosition, controlElements.LookJoystick) then
        touchStates.LookJoystick.Active = true
        touchStates.LookJoystick.TouchId = touch
        touchStates.LookJoystick.Position = touchPosition

        -- Move knob to touch position
        local knobPos = getKnobPosition(touchPosition, controlElements.LookJoystick)
        controlElements.LookKnob.Position = knobPos

    -- Check if touch is on shoot button
    elseif isPointInFrame(touchPosition, controlElements.ShootButton) then
        touchStates.ShootButton.Active = true
        touchStates.ShootButton.TouchId = touch

        -- Simulate mouse click for shooting
        simulateMouseClick()

    -- Check if touch is on reload button
    elseif isPointInFrame(touchPosition, controlElements.ReloadButton) then
        touchStates.ReloadButton.Active = true
        touchStates.ReloadButton.TouchId = touch

        -- Trigger reload
        triggerReload()

    -- Check if touch is on jump button
    elseif isPointInFrame(touchPosition, controlElements.JumpButton) then
        touchStates.JumpButton.Active = true
        touchStates.JumpButton.TouchId = touch

        -- Trigger jump
        triggerJump()
    end
end

-- Handle touch movement
local function handleTouchMove(touch, gameProcessed)
    if gameProcessed then return end

    local touchPosition = touch.Position

    -- Update movement joystick
    if touchStates.MoveJoystick.Active and touchStates.MoveJoystick.TouchId == touch then
        touchStates.MoveJoystick.Position = touchPosition

        -- Update knob position
        local knobPos = getKnobPosition(touchPosition, controlElements.MoveJoystick)
        controlElements.MoveKnob.Position = knobPos

        -- Apply movement based on knob position
        applyMovementFromJoystick(knobPos)

    -- Update look joystick
    elseif touchStates.LookJoystick.Active and touchStates.LookJoystick.TouchId == touch then
        touchStates.LookJoystick.Position = touchPosition

        -- Update knob position
        local knobPos = getKnobPosition(touchPosition, controlElements.LookJoystick)
        controlElements.LookKnob.Position = knobPos

        -- Apply camera rotation based on knob position
        applyLookFromJoystick(knobPos)
    end
end

-- Handle touch end
local function handleTouchEnd(touch, gameProcessed)
    if gameProcessed then return end

    -- Reset movement joystick
    if touchStates.MoveJoystick.Active and touchStates.MoveJoystick.TouchId == touch then
        touchStates.MoveJoystick.Active = false
        touchStates.MoveJoystick.TouchId = nil

        -- Reset knob position
        controlElements.MoveKnob.Position = UDim2.new(0.5, -controlConfig.JoystickSize/2, 0.5, -controlConfig.JoystickSize/2)

        -- Stop movement
        stopMovement()

    -- Reset look joystick
    elseif touchStates.LookJoystick.Active and touchStates.LookJoystick.TouchId == touch then
        touchStates.LookJoystick.Active = false
        touchStates.LookJoystick.TouchId = nil

        -- Reset knob position
        controlElements.LookKnob.Position = UDim2.new(0.5, -controlConfig.JoystickSize/2, 0.5, -controlConfig.JoystickSize/2)

        -- Stop camera rotation
        stopCameraRotation()

    -- Reset shoot button
    elseif touchStates.ShootButton.Active and touchStates.ShootButton.TouchId == touch then
        touchStates.ShootButton.Active = false
        touchStates.ShootButton.TouchId = nil

    -- Reset reload button
    elseif touchStates.ReloadButton.Active and touchStates.ReloadButton.TouchId == touch then
        touchStates.ReloadButton.Active = false
        touchStates.ReloadButton.TouchId = nil

    -- Reset jump button
    elseif touchStates.JumpButton.Active and touchStates.JumpButton.TouchId == touch then
        touchStates.JumpButton.Active = false
        touchStates.JumpButton.TouchId = nil
    end
end

-- Helper functions
local function isPointInFrame(point, frame)
    if not frame.Visible then return false end

    local framePos = frame.AbsolutePosition
    local frameSize = frame.AbsoluteSize

    return point.X >= framePos.X and point.X <= framePos.X + frameSize.X and
           point.Y >= framePos.Y and point.Y <= framePos.Y + frameSize.Y
end

local function getKnobPosition(touchPos, joystickFrame)
    local joystickPos = joystickFrame.AbsolutePosition
    local joystickCenter = joystickPos + joystickFrame.AbsoluteSize / 2

    local offset = touchPos - joystickCenter
    local distance = math.min(offset.Magnitude, controlConfig.JoystickMaxDistance)
    local direction = offset.Unit

    local knobOffset = direction * distance
    local knobPos = UDim2.new(0.5, knobOffset.X, 0.5, knobOffset.Y)

    return knobPos
end

local function applyMovementFromJoystick(knobPos)
    -- Calculate movement vector from knob position
    local knobOffset = Vector2.new(
        knobPos.X.Offset / controlConfig.JoystickMaxDistance,
        knobPos.Y.Offset / controlConfig.JoystickMaxDistance
    )

    -- Apply movement (this would integrate with your movement system)
    -- For now, just print the movement vector
    -- print("Movement Vector:", knobOffset)
end

local function applyLookFromJoystick(knobPos)
    -- Calculate look vector from knob position
    local knobOffset = Vector2.new(
        knobPos.X.Offset / controlConfig.JoystickMaxDistance,
        knobPos.Y.Offset / controlConfig.JoystickMaxDistance
    )

    -- Apply camera rotation (this would integrate with your camera system)
    -- For now, just print the look vector
    -- print("Look Vector:", knobOffset)
end

local function stopMovement()
    -- Stop all movement
    -- print("Movement stopped")
end

local function stopCameraRotation()
    -- Stop camera rotation
    -- print("Camera rotation stopped")
end

local function simulateMouseClick()
    -- Simulate left mouse button click for shooting
    local virtualInput = Instance.new("VirtualInputManager")
    if virtualInput then
        -- This is a simplified approach - in practice you'd need to handle this differently
        print("Simulated shoot button press")
    end
end

local function triggerReload()
    -- Trigger reload action (simulate R key press)
    print("Reload triggered")
end

local function triggerJump()
    -- Trigger jump action (simulate spacebar)
    print("Jump triggered")
end

-- Initialize mobile controls
function MobileControls.Initialize()
    -- Only create mobile controls if on touch device
    if not UserInputService.TouchEnabled then
        print("⌨️ Keyboard/Mouse device detected - Mobile controls disabled")
        return
    end

    print("📱 Touch device detected - Initializing mobile controls")
    createMobileControls()

    -- Connect touch event handlers
    UserInputService.TouchStarted:Connect(handleTouchInput)
    UserInputService.TouchMoved:Connect(handleTouchMove)
    UserInputService.TouchEnded:Connect(handleTouchEnd)

    -- Update control positions when screen size changes
    UserInputService:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        -- Controls will automatically scale with the responsive UI system
    end)

    print("📱 Mobile controls initialized!")
end

-- Public API functions
function MobileControls.IsMobile()
    return UserInputService.TouchEnabled
end

function MobileControls.GetTouchStates()
    return touchStates
end

function MobileControls.SetJoystickSensitivity(moveSensitivity, lookSensitivity)
    controlConfig.MoveSensitivity = moveSensitivity or 1.0
    controlConfig.LookSensitivity = lookSensitivity or 0.5
end

return MobileControls
