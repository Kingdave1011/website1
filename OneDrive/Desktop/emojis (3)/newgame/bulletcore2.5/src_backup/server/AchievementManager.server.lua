-- Achievement System Manager
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameData = require(ReplicatedStorage.Shared.GameData)

-- Remote Events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local achievementUnlockedRemote = Instance.new("RemoteEvent")
achievementUnlockedRemote.Name = "AchievementUnlocked"
achievementUnlockedRemote.Parent = remoteEvents

-- Achievement tracking
local function checkAchievements(player, statType, newValue)
    local playerData = _G.BulletCore.GetPlayerData(player)
    if not playerData then return end
    
    for _, achievement in ipairs(GameData.Achievements) do
        -- Skip if already unlocked
        if playerData.Achievements[achievement.ID] then
            continue
        end
        
        local unlocked = false
        
        -- Check achievement conditions
        if achievement.ID == "first_kill" and statType == "Kills" and newValue >= 1 then
            unlocked = true
        elseif achievement.ID == "headshot_master" and statType == "Headshots" and newValue >= 100 then
            unlocked = true
        elseif achievement.ID == "win_streak" and statType == "WinStreak" and newValue >= 10 then
            unlocked = true
        elseif achievement.ID == "accuracy_ace" and statType == "MatchAccuracy" and newValue >= 90 then
            unlocked = true
        elseif achievement.ID == "damage_dealer" and statType == "DamageDealt" and newValue >= 100000 then
            unlocked = true
        end
        
        if unlocked then
            -- Mark as unlocked
            playerData.Achievements[achievement.ID] = true
            
            -- Award XP
            _G.BulletCore.AddXP(player, achievement.XPReward)
            
            -- Notify client
            achievementUnlockedRemote:FireClient(player, achievement)
            
            print(player.Name .. " unlocked achievement: " .. achievement.Name)
        end
    end
end

-- Expose achievement checking
_G.BulletCore = _G.BulletCore or {}
_G.BulletCore.CheckAchievements = checkAchievements

-- Example usage - these would be called by combat/game systems
--[[
Usage examples:
_G.BulletCore.CheckAchievements(player, "Kills", playerData.Kills)
_G.BulletCore.CheckAchievements(player, "DamageDealt", playerData.DamageDealt)
_G.BulletCore.CheckAchievements(player, "MatchAccuracy", matchAccuracy)
--]]