-- Stats GUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create Stats GUI
local statsGui = Instance.new("ScreenGui")
statsGui.Name = "StatsGUI"
statsGui.ResetOnSpawn = false
statsGui.Parent = playerGui

local statsFrame = Instance.new("Frame")
statsFrame.Name = "StatsFrame"
statsFrame.Size = UDim2.new(0, 500, 0, 400)
statsFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statsFrame.BorderSizePixel = 2
statsFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
statsFrame.Visible = false
statsFrame.Parent = statsGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = statsFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.BorderSizePixel = 0
title.Text = "📊 PLAYER STATS"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = statsFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = statsFrame

-- Stats container
local statsContainer = Instance.new("ScrollingFrame")
statsContainer.Size = UDim2.new(1, -20, 1, -60)
statsContainer.Position = UDim2.new(0, 10, 0, 50)
statsContainer.BackgroundTransparency = 1
statsContainer.BorderSizePixel = 0
statsContainer.ScrollBarThickness = 8
statsContainer.Parent = statsFrame

local statsLayout = Instance.new("UIListLayout")
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
statsLayout.Padding = UDim.new(0, 10)
statsLayout.Parent = statsContainer

-- Create stat entry
local function createStatEntry(label, value, color)
    local statFrame = Instance.new("Frame")
    statFrame.Size = UDim2.new(1, -16, 0, 40)
    statFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statFrame.BorderSizePixel = 0
    statFrame.Parent = statsContainer
    
    local statCorner = Instance.new("UICorner")
    statCorner.CornerRadius = UDim.new(0, 5)
    statCorner.Parent = statFrame
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.Position = UDim2.new(0, 15, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.TextScaled = true
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = statFrame
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0.25, 0, 1, 0)
    valueText.Position = UDim2.new(0.7, 0, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(value)
    valueText.TextColor3 = color or Color3.fromRGB(0, 150, 255)
    valueText.TextScaled = true
    valueText.Font = Enum.Font.GothamBold
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = statFrame
    
    return valueText
end

-- Update stats display
local function updateStats(playerData)
    -- Clear existing stats
    for _, child in pairs(statsContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Add stats
    createStatEntry("🏅 Level", playerData.Level, Color3.fromRGB(255, 215, 0))
    createStatEntry("⭐ XP", playerData.XP, Color3.fromRGB(0, 150, 255))
    createStatEntry("💎 Prestige", playerData.Prestige, Color3.fromRGB(255, 0, 255))
    createStatEntry("💀 Kills", playerData.Kills, Color3.fromRGB(255, 0, 0))
    createStatEntry("☠️ Deaths", playerData.Deaths, Color3.fromRGB(150, 150, 150))
    createStatEntry("📈 K/D Ratio", playerData.Deaths > 0 and math.floor((playerData.Kills / playerData.Deaths) * 100) / 100 or playerData.Kills, Color3.fromRGB(0, 255, 0))
    createStatEntry("🏆 Wins", playerData.Wins, Color3.fromRGB(0, 255, 0))
    createStatEntry("📉 Losses", playerData.Losses, Color3.fromRGB(255, 100, 100))
    createStatEntry("🎯 Accuracy", playerData.Accuracy .. "%", Color3.fromRGB(255, 165, 0))
    createStatEntry("💥 Damage Dealt", playerData.DamageDealt, Color3.fromRGB(255, 50, 50))
    createStatEntry("🎮 Matches Played", playerData.MatchesPlayed, Color3.fromRGB(100, 200, 255))
    
    -- Update canvas size
    statsContainer.CanvasSize = UDim2.new(0, 0, 0, statsLayout.AbsoluteContentSize.Y + 20)
end

-- Listen for stats updates
if ReplicatedStorage:FindFirstChild("RemoteEvents") then
    local updateStatsRemote = ReplicatedStorage.RemoteEvents:WaitForChild("UpdateStats")
    updateStatsRemote.OnClientEvent:Connect(updateStats)
end

-- Close stats
closeButton.MouseButton1Click:Connect(function()
    statsFrame.Visible = false
end)