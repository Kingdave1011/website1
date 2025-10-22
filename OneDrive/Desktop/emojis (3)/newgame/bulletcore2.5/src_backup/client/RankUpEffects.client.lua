-- Rank Up Effects and Notifications
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create rank up notification GUI
local rankUpGui = Instance.new("ScreenGui")
rankUpGui.Name = "RankUpNotification"
rankUpGui.ResetOnSpawn = false
rankUpGui.Parent = playerGui

local notification = Instance.new("Frame")
notification.Name = "Notification"
notification.Size = UDim2.new(0, 400, 0, 100)
notification.Position = UDim2.new(0.5, -200, 0, -120)
notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
notification.BorderSizePixel = 2
notification.BorderColor3 = Color3.fromRGB(255, 215, 0)
notification.Parent = rankUpGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = notification

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "RANK UP!"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = notification

local rankLabel = Instance.new("TextLabel")
rankLabel.Name = "Rank"
rankLabel.Size = UDim2.new(1, 0, 0.6, 0)
rankLabel.Position = UDim2.new(0, 0, 0.4, 0)
rankLabel.BackgroundTransparency = 1
rankLabel.Text = "Private (Level 10)"
rankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rankLabel.TextScaled = true
rankLabel.Font = Enum.Font.Gotham
rankLabel.Parent = notification

-- Create rank up sound
local rankUpSound = Instance.new("Sound")
rankUpSound.Name = "RankUpSound"
rankUpSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
rankUpSound.Volume = 0.5
rankUpSound.Parent = SoundService

-- Particle effects
local function createParticleEffect()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local rootPart = character.HumanoidRootPart
    
    -- Create attachment for particles
    local attachment = Instance.new("Attachment")
    attachment.Parent = rootPart
    
    -- Golden sparkles
    local particles = Instance.new("ParticleEmitter")
    particles.Parent = attachment
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
    particles.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    }
    particles.Lifetime = NumberRange.new(1, 2)
    particles.Rate = 100
    particles.SpreadAngle = Vector2.new(360, 360)
    particles.Speed = NumberRange.new(5, 10)
    
    -- Enable particles
    particles.Enabled = true
    
    -- Disable after 3 seconds
    wait(3)
    particles.Enabled = false
    
    -- Clean up after particles fade
    game:GetService("Debris"):AddItem(attachment, 5)
end

-- Show rank up notification
local function showRankUp(newLevel, oldLevel)
    local GameData = require(ReplicatedStorage.Shared.GameData)
    
    -- Find rank info
    local rankInfo = nil
    for _, rank in ipairs(GameData.Ranks) do
        if newLevel >= rank.MinLevel then
            rankInfo = rank
        end
    end
    
    if rankInfo then
        -- Update notification text
        rankLabel.Text = rankInfo.Name .. " (Level " .. newLevel .. ")"
        rankLabel.TextColor3 = rankInfo.Color
        notification.BorderColor3 = rankInfo.Color
        titleLabel.TextColor3 = rankInfo.Color
        
        -- Play sound
        rankUpSound:Play()
        
        -- Animate notification
        notification.Position = UDim2.new(0.5, -200, 0, -120)
        
        local slideIn = TweenService:Create(
            notification,
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(0.5, -200, 0, 50)}
        )
        
        local slideOut = TweenService:Create(
            notification,
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -200, 0, -120)}
        )
        
        slideIn:Play()
        
        -- Create particle effect
        spawn(createParticleEffect)
        
        -- Hide after 4 seconds
        slideIn.Completed:Connect(function()
            wait(3)
            slideOut:Play()
        end)
    end
end

-- Listen for rank up events
if ReplicatedStorage:FindFirstChild("RemoteEvents") then
    local rankUpRemote = ReplicatedStorage.RemoteEvents:WaitForChild("RankUp")
    rankUpRemote.OnClientEvent:Connect(showRankUp)
end