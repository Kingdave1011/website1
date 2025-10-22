-- Minimap with Shot Indicators
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MinimapController = {}

-- Get minimap frame
local hudGui = playerGui:WaitForChild("BulletCoreHUD")
local minimapFrame = hudGui:WaitForChild("Minimap")

-- Minimap settings
local MINIMAP_RANGE = 100
local shotIndicators = {}

-- Create player dot on minimap
local function createPlayerDot(targetPlayer, color)
    local dot = Instance.new("Frame")
    dot.Name = targetPlayer.Name .. "_Dot"
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.BackgroundColor3 = color or Color3.fromRGB(0, 255, 0)
    dot.BorderSizePixel = 0
    dot.Parent = minimapFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = dot
    
    return dot
end

-- Create shot indicator
local function createShotIndicator(position, shooterName)
    local indicator = Instance.new("Frame")
    indicator.Name = "ShotIndicator_" .. tick()
    indicator.Size = UDim2.new(0, 8, 0, 8)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    indicator.BorderSizePixel = 0
    indicator.Parent = minimapFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = indicator
    
    -- Add pulsing effect
    local pulse = TweenService:Create(
        indicator,
        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Size = UDim2.new(0, 12, 0, 12)}
    )
    pulse:Play()
    
    -- Store indicator data
    shotIndicators[indicator] = {
        CreatedTime = tick(),
        Position = position,
        Shooter = shooterName
    }
    
    -- Remove after 3 seconds
    game:GetService("Debris"):AddItem(indicator, 3)
    
    return indicator
end

-- Convert world position to minimap position
local function worldToMinimap(worldPos, playerPos)
    local relativePos = worldPos - playerPos
    local distance = relativePos.Magnitude
    
    if distance > MINIMAP_RANGE then
        relativePos = relativePos.Unit * MINIMAP_RANGE
    end
    
    local minimapX = (relativePos.X / MINIMAP_RANGE) * 0.5 + 0.5
    local minimapY = (relativePos.Z / MINIMAP_RANGE) * 0.5 + 0.5
    
    return UDim2.new(minimapX, -3, minimapY, -3)
end

-- Update minimap
local function updateMinimap()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local playerPos = character.HumanoidRootPart.Position
    
    -- Update player dots
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dotName = otherPlayer.Name .. "_Dot"
            local dot = minimapFrame:FindFirstChild(dotName)
            
            if not dot then
                dot = createPlayerDot(otherPlayer, Color3.fromRGB(0, 150, 255))
            end
            
            local otherPos = otherPlayer.Character.HumanoidRootPart.Position
            local distance = (otherPos - playerPos).Magnitude
            
            if distance <= MINIMAP_RANGE then
                dot.Position = worldToMinimap(otherPos, playerPos)
                dot.Visible = true
            else
                dot.Visible = false
            end
        end
    end
    
    -- Update bot dots
    for _, bot in pairs(workspace:GetChildren()) do
        if bot.Name:match("Bot_") and bot:FindFirstChild("HumanoidRootPart") then
            local dotName = bot.Name .. "_Dot"
            local dot = minimapFrame:FindFirstChild(dotName)
            
            if not dot then
                dot = createPlayerDot({Name = bot.Name}, Color3.fromRGB(255, 100, 100))
            end
            
            local botPos = bot.HumanoidRootPart.Position
            local distance = (botPos - playerPos).Magnitude
            
            if distance <= MINIMAP_RANGE then
                dot.Position = worldToMinimap(botPos, playerPos)
                dot.Visible = true
            else
                dot.Visible = false
            end
        end
    end
    
    -- Update shot indicators
    local currentTime = tick()
    for indicator, data in pairs(shotIndicators) do
        if currentTime - data.CreatedTime > 3 then
            shotIndicators[indicator] = nil
        elseif indicator.Parent then
            indicator.Position = worldToMinimap(data.Position, playerPos)
        end
    end
end

-- Simulate shot detection (replace with actual weapon system later)
local function simulateShotDetection()
    -- This would be called by the weapon system when shots are fired
    for _, bot in pairs(workspace:GetChildren()) do
        if bot.Name:match("Bot_") and bot:FindFirstChild("HumanoidRootPart") then
            if math.random() < 0.01 then -- Random chance for demo
                createShotIndicator(bot.HumanoidRootPart.Position, bot.Name)
            end
        end
    end
end

-- Start minimap updates
RunService.Heartbeat:Connect(function()
    updateMinimap()
    simulateShotDetection()
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(leavingPlayer)
    local dot = minimapFrame:FindFirstChild(leavingPlayer.Name .. "_Dot")
    if dot then
        dot:Destroy()
    end
end)