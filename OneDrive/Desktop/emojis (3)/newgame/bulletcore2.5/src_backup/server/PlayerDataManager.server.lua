-- Player Data Management System
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = require(ReplicatedStorage.Shared.GameData)

local PlayerDataStore = DataStoreService:GetDataStore("BulletCorePlayerData")
local PlayerData = {}

-- Remote Events
local remoteEvents = Instance.new("Folder")
remoteEvents.Name = "RemoteEvents"
remoteEvents.Parent = ReplicatedStorage

local updateStatsRemote = Instance.new("RemoteEvent")
updateStatsRemote.Name = "UpdateStats"
updateStatsRemote.Parent = remoteEvents

local rankUpRemote = Instance.new("RemoteEvent")
rankUpRemote.Name = "RankUp"
rankUpRemote.Parent = remoteEvents

-- Load player data
local function loadPlayerData(player)
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync(player.UserId)
    end)
    
    if success and data then
        PlayerData[player.UserId] = data
    else
        PlayerData[player.UserId] = GameData.DefaultStats
    end
    
    -- Send data to client
    updateStatsRemote:FireClient(player, PlayerData[player.UserId])
end

-- Save player data
local function savePlayerData(player)
    if PlayerData[player.UserId] then
        pcall(function()
            PlayerDataStore:SetAsync(player.UserId, PlayerData[player.UserId])
        end)
    end
end

-- Add XP and check for rank up
local function addXP(player, amount)
    local data = PlayerData[player.UserId]
    if not data then return end

    local oldLevel = data.Level
    local oldXP = data.XP
    data.XP = data.XP + amount

    -- Check for level up
    while data.Level < 100 and data.XP >= GameData.XPRequirements[data.Level] do
        data.XP = data.XP - GameData.XPRequirements[data.Level]
        data.Level = data.Level + 1
    end

    -- If leveled up, trigger rank up event
    if data.Level > oldLevel then
        rankUpRemote:FireClient(player, data.Level, oldLevel)

        -- Announce in chat
        local rankInfo = nil
        for _, rank in ipairs(GameData.Ranks) do
            if data.Level >= rank.MinLevel then
                rankInfo = rank
            end
        end

        if rankInfo then
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = player.Name .. " reached " .. rankInfo.Name .. " (Level " .. data.Level .. ")!";
                Color = rankInfo.Color;
                Font = Enum.Font.GothamBold;
            })
        end
    end

    -- Fire money change event for real-time HUD updates
    local moneyChangeRemote = remoteEvents:FindFirstChild("MoneyChange")
    if moneyChangeRemote then
        moneyChangeRemote:FireClient(player, data.XP)
    end

    updateStatsRemote:FireClient(player, data)
end

-- Function to set XP directly (for purchases, etc.)
local function setXP(player, amount)
    local data = PlayerData[player.UserId]
    if not data then return end

    data.XP = amount

    -- Fire money change event for real-time HUD updates
    local moneyChangeRemote = remoteEvents:FindFirstChild("MoneyChange")
    if moneyChangeRemote then
        moneyChangeRemote:FireClient(player, data.XP)
    end

    updateStatsRemote:FireClient(player, data)
end

-- Player events
Players.PlayerAdded:Connect(function(player)
    loadPlayerData(player)
end)

Players.PlayerRemoving:Connect(function(player)
    savePlayerData(player)
    PlayerData[player.UserId] = nil
end)

-- Create MoneyChange remote event
local moneyChangeRemote = Instance.new("RemoteEvent")
moneyChangeRemote.Name = "MoneyChange"
moneyChangeRemote.Parent = remoteEvents

-- Expose functions
_G.BulletCore = _G.BulletCore or {}
_G.BulletCore.AddXP = addXP
_G.BulletCore.SetXP = setXP
_G.BulletCore.GetPlayerData = function(player)
    return PlayerData[player.UserId]
end
