-- Daily Rewards System with Visual Assets
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DailyRewards = {}

-- Daily rewards data with visual assets
local RewardsData = {
    [1] = {
        Day = 1,
        Reward = "Cash",
        Amount = 1000,
        Icon = "rbxassetid://1234567890", -- Cash icon
        Rarity = "Common",
        Claimed = false
    },
    [2] = {
        Day = 2,
        Reward = "Double XP",
        Amount = 1,
        Duration = "Hour",
        Icon = "rbxassetid://1234567891", -- XP icon
        Rarity = "Common",
        Claimed = false
    },
    [3] = {
        Day = 3,
        Reward = "Cash",
        Amount = 2500,
        Icon = "rbxassetid://1234567890",
        Rarity = "Rare",
        Claimed = false
    },
    [4] = {
        Day = 4,
        Reward = "Golden Dragon",
        Amount = 1,
        Icon = "rbxassetid://1234567892", -- Weapon icon
        Rarity = "Legendary",
        Claimed = false
    },
    [5] = {
        Day = 5,
        Reward = "Double Cash",
        Amount = 2,
        Duration = "Hours",
        Icon = "rbxassetid://1234567893", -- Cash boost icon
        Rarity = "Epic",
        Claimed = false
    },
    [6] = {
        Day = 6,
        Reward = "Cash",
        Amount = 5000,
        Icon = "rbxassetid://1234567890",
        Rarity = "Epic",
        Claimed = false
    },
    [7] = {
        Day = 7,
        Reward = "Bonus Weapons",
        Amount = 1,
        Icon = "rbxassetid://1234567894", -- Mystery box icon
        Rarity = "Legendary",
        Claimed = false
    }
}

-- Create daily rewards GUI
function DailyRewards.Create()
    -- Remove existing rewards GUI
    local existingRewards = playerGui:FindFirstChild("DailyRewards")
    if existingRewards then
        existingRewards:Destroy()
    end

    local rewardsGui = Instance.new("ScreenGui")
    rewardsGui.Name = "DailyRewards"
    rewardsGui.ResetOnSpawn = false
    rewardsGui.Parent = playerGui

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 800, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = rewardsGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 150, 0)
    mainStroke.Thickness = 3
    mainStroke.Parent = mainFrame

    -- Animated background
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    background.BorderSizePixel = 0
    background.Parent = mainFrame

    -- Background pattern overlay
    for i = 1, 20 do
        local pattern = Instance.new("Frame")
        pattern.Size = UDim2.new(0, 100, 0, 100)
        pattern.Position = UDim2.new(0, math.random(0, 800), 0, math.random(0, 500))
        pattern.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        pattern.BackgroundTransparency = 0.9
        pattern.BorderSizePixel = 0
        pattern.Rotation = math.random(0, 360)
        pattern.Parent = background

        local patternCorner = Instance.new("UICorner")
        patternCorner.CornerRadius = UDim.new(0, 10)
        patternCorner.Parent = pattern
    end

    -- Title section
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 80)
    titleFrame.Position = UDim2.new(0, 0, 0, 0)
    titleFrame.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    titleFrame.BorderSizePixel = 0
    titleFrame.Parent = mainFrame

    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 80, 0))
    }
    titleGradient.Parent = titleFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 500, 0, 50)
    title.Position = UDim2.new(0.5, -250, 0.15, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎁 DAILY REWARDS"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = titleFrame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 50, 0, 50)
    closeButton.Position = UDim2.new(0.96, -60, 0.1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextScaled = true
    closeButton.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    -- Rewards display
    local rewardsContainer = Instance.new("Frame")
    rewardsContainer.Size = UDim2.new(0.9, 0, 0.6, 0)
    rewardsContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
    rewardsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    rewardsContainer.BackgroundTransparency = 0.5
    rewardsContainer.BorderSizePixel = 0
    rewardsContainer.Parent = mainFrame

    local rewardsCorner = Instance.new("UICorner")
    rewardsCorner.CornerRadius = UDim.new(0, 10)
    rewardsCorner.Parent = rewardsContainer

    -- Create reward slots
    for day = 1, 7 do
        DailyRewards.CreateRewardSlot(rewardsContainer, RewardsData[day], day)
    end

    -- Claim button
    local claimButton = Instance.new("TextButton")
    claimButton.Size = UDim2.new(0, 300, 0, 60)
    claimButton.Position = UDim2.new(0.5, -150, 0.85, 0)
    claimButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    claimButton.BorderSizePixel = 0
    claimButton.Text = "🎉 CLAIM REWARD!"
    claimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    claimButton.Font = Enum.Font.SourceSansBold
    claimButton.TextScaled = true
    claimButton.Parent = mainFrame

    local claimCorner = Instance.new("UICorner")
    claimCorner.CornerRadius = UDim.new(0, 12)
    claimCorner.Parent = claimButton

    local claimGradient = Instance.new("UIGradient")
    claimGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 80))
    }
    claimGradient.Parent = claimButton

    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0, 400, 0, 30)
    statusText.Position = UDim2.new(0.5, -200, 0.92, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Complete daily challenges to unlock rewards!"
    statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusText.Font = Enum.Font.SourceSans
    statusText.Parent = mainFrame

    -- Close functionality
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        DailyRewards.IsVisible = false
    end)

    -- Claim functionality
    claimButton.MouseButton1Click:Connect(function()
        DailyRewards.ClaimReward()
    end)

    return mainFrame
end

-- Create individual reward slot
function DailyRewards.CreateRewardSlot(parent, rewardData, day)
    local slotFrame = Instance.new("Frame")
    slotFrame.Size = UDim2.new(0, 100, 0, 120)
    slotFrame.Position = UDim2.new(0, (day - 1) * 110 + 10, 0, 10)
    slotFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    slotFrame.BorderSizePixel = 0
    slotFrame.Parent = parent

    local slotCorner = Instance.new("UICorner")
    slotCorner.CornerRadius = UDim.new(0, 8)
    slotCorner.Parent = slotFrame

    -- Day indicator
    local dayIndicator = Instance.new("TextLabel")
    dayIndicator.Size = UDim2.new(1, 0, 0, 25)
    dayIndicator.Position = UDim2.new(0, 0, 0, 0)
    dayIndicator.BackgroundColor3 = DailyRewards.GetRarityColor(rewardData.Rarity)
    dayIndicator.BorderSizePixel = 0
    dayIndicator.Text = "DAY " .. day
    dayIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
    dayIndicator.Font = Enum.Font.SourceSansBold
    dayIndicator.TextScaled = true
    dayIndicator.Parent = slotFrame

    -- Reward icon
    local rewardIcon = Instance.new("ImageLabel")
    rewardIcon.Size = UDim2.new(0, 60, 0, 60)
    rewardIcon.Position = UDim2.new(0.5, -30, 0.25, 0)
    rewardIcon.BackgroundTransparency = 1
    rewardIcon.Image = rewardData.Icon or "rbxassetid://1234567890"
    rewardIcon.Parent = slotFrame

    -- Reward text
    local rewardText = Instance.new("TextLabel")
    rewardText.Size = UDim2.new(0.9, 0, 0, 25)
    rewardText.Position = UDim2.new(0.05, 0, 0.75, 0)
    rewardText.BackgroundTransparency = 1
    rewardText.Text = rewardData.Reward
    rewardText.TextColor3 = Color3.fromRGB(255, 255, 255)
    rewardText.Font = Enum.Font.SourceSansBold
    rewardText.TextScaled = true
    rewardText.Parent = slotFrame

    -- Amount text
    local amountText = Instance.new("TextLabel")
    amountText.Size = UDim2.new(0.9, 0, 0, 20)
    amountText.Position = UDim2.new(0.05, 0, 0.9, 0)
    amountText.BackgroundTransparency = 1
    amountText.Text = tostring(rewardData.Amount) .. (rewardData.Duration or "")
    amountText.TextColor3 = DailyRewards.GetRarityColor(rewardData.Rarity)
    amountText.Font = Enum.Font.SourceSans
    amountText.TextScaled = true
    amountText.Parent = slotFrame

    -- Claimed overlay
    if rewardData.Claimed then
        local claimedOverlay = Instance.new("Frame")
        claimedOverlay.Size = UDim2.new(1, 0, 1, 0)
        claimedOverlay.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        claimedOverlay.BackgroundTransparency = 0.7
        claimedOverlay.BorderSizePixel = 0
        claimedOverlay.Parent = slotFrame

        local claimedText = Instance.new("TextLabel")
        claimedText.Size = UDim2.new(1, 0, 1, 0)
        claimedText.BackgroundTransparency = 1
        claimedText.Text = "✓ CLAIMED"
        claimedText.TextColor3 = Color3.fromRGB(255, 255, 255)
        claimedText.Font = Enum.Font.SourceSansBold
        claimedText.Parent = claimedOverlay
    end

    -- Hover effects
    slotFrame.MouseEnter:Connect(function()
        TweenService:Create(slotFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
    end)

    slotFrame.MouseLeave:Connect(function()
        TweenService:Create(slotFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
    end)
end

-- Get rarity color
function DailyRewards.GetRarityColor(rarity)
    local colors = {
        Common = Color3.fromRGB(150, 150, 150),
        Rare = Color3.fromRGB(0, 150, 255),
        Epic = Color3.fromRGB(150, 0, 255),
        Legendary = Color3.fromRGB(255, 150, 0)
    }
    return colors[rarity] or Color3.fromRGB(150, 150, 150)
end

-- Claim reward
function DailyRewards.ClaimReward()
    -- Send claim request to server
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        local claimRewardRemote = remoteEvents:FindFirstChild("ClaimDailyReward")
        if claimRewardRemote then
            claimRewardRemote:FireServer()
        end
    end
end

-- Toggle daily rewards
function DailyRewards.Toggle()
    if not DailyRewards.MainFrame then
        DailyRewards.MainFrame = DailyRewards.Create()
    end

    DailyRewards.IsVisible = not DailyRewards.IsVisible
    DailyRewards.MainFrame.Visible = DailyRewards.IsVisible
end

-- Initialize daily rewards
function DailyRewards.Initialize()
    -- Listen for daily rewards toggle (e.g., from main menu)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.R then
            DailyRewards.Toggle()
        end
    end)

    print("🎁 Daily Rewards System initialized!")
end

return DailyRewards
