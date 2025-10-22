-- Achievement Notification System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create achievement notification GUI
local achievementGui = Instance.new("ScreenGui")
achievementGui.Name = "AchievementNotifications"
achievementGui.ResetOnSpawn = false
achievementGui.Parent = playerGui

local notification = Instance.new("Frame")
notification.Name = "AchievementNotification"
notification.Size = UDim2.new(0, 350, 0, 80)
notification.Position = UDim2.new(1, 10, 0, 100) -- Start off-screen
notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
notification.BorderSizePixel = 2
notification.BorderColor3 = Color3.fromRGB(255, 215, 0)
notification.Parent = achievementGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = notification

-- Achievement icon
local icon = Instance.new("ImageLabel")
icon.Name = "Icon"
icon.Size = UDim2.new(0, 50, 0, 50)
icon.Position = UDim2.new(0, 15, 0.5, -25)
icon.BackgroundTransparency = 1
icon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
icon.ImageColor3 = Color3.fromRGB(255, 215, 0)
icon.Parent = notification

-- Achievement text
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -80, 0.4, 0)
titleLabel.Position = UDim2.new(0, 75, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ACHIEVEMENT UNLOCKED!"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = notification

local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "AchievementName"
nameLabel.Size = UDim2.new(1, -80, 0.3, 0)
nameLabel.Position = UDim2.new(0, 75, 0.4, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Achievement Name"
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = notification

local descLabel = Instance.new("TextLabel")
descLabel.Name = "Description"
descLabel.Size = UDim2.new(1, -80, 0.3, 0)
descLabel.Position = UDim2.new(0, 75, 0.7, 0)
descLabel.BackgroundTransparency = 1
descLabel.Text = "Achievement description"
descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
descLabel.TextScaled = true
descLabel.Font = Enum.Font.Gotham
descLabel.TextXAlignment = Enum.TextXAlignment.Left
descLabel.Parent = notification

-- XP reward indicator
local xpLabel = Instance.new("TextLabel")
xpLabel.Name = "XPReward"
xpLabel.Size = UDim2.new(0, 60, 0, 20)
xpLabel.Position = UDim2.new(1, -70, 0, 5)
xpLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
xpLabel.BorderSizePixel = 0
xpLabel.Text = "+100 XP"
xpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
xpLabel.TextScaled = true
xpLabel.Font = Enum.Font.GothamBold
xpLabel.Parent = notification

local xpCorner = Instance.new("UICorner")
xpCorner.CornerRadius = UDim.new(0, 4)
xpCorner.Parent = xpLabel

-- Achievement sound
local achievementSound = Instance.new("Sound")
achievementSound.Name = "AchievementSound"
achievementSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
achievementSound.Volume = 0.7
achievementSound.Pitch = 1.2
achievementSound.Parent = SoundService

-- Show achievement notification
local function showAchievement(achievement)
    -- Update notification content
    nameLabel.Text = achievement.Name
    descLabel.Text = achievement.Description
    xpLabel.Text = "+" .. achievement.XPReward .. " XP"
    
    -- Play sound
    achievementSound:Play()
    
    -- Animate notification
    notification.Position = UDim2.new(1, 10, 0, 100)
    
    local slideIn = TweenService:Create(
        notification,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -360, 0, 100)}
    )
    
    local slideOut = TweenService:Create(
        notification,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 10, 0, 100)}
    )
    
    -- Icon pulse effect
    local iconPulse = TweenService:Create(
        icon,
        TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {Size = UDim2.new(0, 55, 0, 55)}
    )
    
    slideIn:Play()
    iconPulse:Play()
    
    -- Hide after 4 seconds
    slideIn.Completed:Connect(function()
        wait(3.5)
        iconPulse:Cancel()
        icon.Size = UDim2.new(0, 50, 0, 50)
        slideOut:Play()
    end)
end

-- Listen for achievement events
if ReplicatedStorage:FindFirstChild("RemoteEvents") then
    local achievementRemote = ReplicatedStorage.RemoteEvents:WaitForChild("AchievementUnlocked")
    achievementRemote.OnClientEvent:Connect(showAchievement)
end