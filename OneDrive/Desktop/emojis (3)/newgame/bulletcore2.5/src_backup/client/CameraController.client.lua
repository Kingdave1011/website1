-- Third Person Camera Controller
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Camera settings
local CAMERA_DISTANCE = 8
local CAMERA_HEIGHT = 2
local SENSITIVITY = 0.3

-- Camera state
local cameraAngleX = 0
local cameraAngleY = 0
local isMenuOpen = false

-- Initialize third person camera
local function setupCamera()
    camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end

-- Update camera position and rotation
local function updateCamera()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or isMenuOpen then
        return
    end
    
    local rootPart = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    
    if humanoid and humanoid.Health > 0 then
        -- Calculate camera position
        local cameraOffset = Vector3.new(
            math.sin(cameraAngleY) * CAMERA_DISTANCE,
            CAMERA_HEIGHT + math.sin(cameraAngleX) * 3,
            math.cos(cameraAngleY) * CAMERA_DISTANCE
        )
        
        local cameraPosition = rootPart.Position + cameraOffset
        
        -- Set camera CFrame
        camera.CFrame = CFrame.lookAt(cameraPosition, rootPart.Position + Vector3.new(0, CAMERA_HEIGHT, 0))
    end
end

-- Handle right mouse button for camera rotation
local isRotating = false

mouse.Button2Down:Connect(function()
    if not isMenuOpen then
        isRotating = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    end
end)

mouse.Button2Up:Connect(function()
    isRotating = false
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end)

-- Handle mouse movement for camera rotation (only when right-clicking)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isRotating and not isMenuOpen then
        local delta = input.Delta
        cameraAngleY = cameraAngleY - delta.X * SENSITIVITY * 0.01
        cameraAngleX = math.clamp(cameraAngleX - delta.Y * SENSITIVITY * 0.01, -1.4, 1.4)
    end
end)

-- Handle shooting
mouse.Button1Down:Connect(function()
    if isMenuOpen then return end
    
    local target = mouse.Target
    if target and target.Parent:FindFirstChild("Humanoid") then
        local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
        if targetPlayer and targetPlayer ~= player then
            -- Fire shooting event
            local shootRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("Shoot")
            if shootRemote then
                shootRemote:FireServer(targetPlayer, mouse.Hit.Position)
            end
        end
    end
end)

-- Track menu state
local function updateMenuState()
    local menuGui = player.PlayerGui:FindFirstChild("MainMenu")
    if menuGui and menuGui:FindFirstChild("MenuFrame") then
        isMenuOpen = menuGui.MenuFrame.Visible
    end
end

-- Character spawned
player.CharacterAdded:Connect(function(character)
    setupCamera()
    character:WaitForChild("HumanoidRootPart")
    RunService.Heartbeat:Connect(updateCamera)
end)

-- Update menu state regularly
RunService.Heartbeat:Connect(updateMenuState)

if player.Character then
    setupCamera()
end