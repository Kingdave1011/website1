-- BulletCore Shared Game Data
local GameData = {}

-- Player Stats Structure
GameData.DefaultStats = {
    Level = 1,
    XP = 0,
    Prestige = 0,
    Kills = 0,
    Deaths = 0,
    Wins = 0,
    Losses = 0,
    Accuracy = 0,
    DamageDealt = 0,
    MatchesPlayed = 0,
    Achievements = {},
    Settings = {
        CrosshairColor = Color3.fromRGB(255, 255, 255),
        AimAssist = true,
        AimAssistStrength = 0.5
    }
}

-- XP Requirements per level
GameData.XPRequirements = {}
for i = 1, 100 do
    GameData.XPRequirements[i] = i * 1000 + (i - 1) * 500
end

-- Rank Names and Colors
GameData.Ranks = {
    {Name = "Recruit", Color = Color3.fromRGB(139, 69, 19), MinLevel = 1},
    {Name = "Private", Color = Color3.fromRGB(128, 128, 128), MinLevel = 10},
    {Name = "Corporal", Color = Color3.fromRGB(0, 128, 0), MinLevel = 20},
    {Name = "Sergeant", Color = Color3.fromRGB(0, 0, 255), MinLevel = 30},
    {Name = "Lieutenant", Color = Color3.fromRGB(128, 0, 128), MinLevel = 40},
    {Name = "Captain", Color = Color3.fromRGB(255, 165, 0), MinLevel = 50},
    {Name = "Major", Color = Color3.fromRGB(255, 0, 0), MinLevel = 60},
    {Name = "Colonel", Color = Color3.fromRGB(255, 215, 0), MinLevel = 70},
    {Name = "General", Color = Color3.fromRGB(255, 255, 0), MinLevel = 80},
    {Name = "Commander", Color = Color3.fromRGB(255, 20, 147), MinLevel = 90},
    {Name = "Legend", Color = Color3.fromRGB(255, 255, 255), MinLevel = 100}
}

-- Achievements
GameData.Achievements = {
    {ID = "first_kill", Name = "First Blood", Description = "Get your first kill", XPReward = 100},
    {ID = "headshot_master", Name = "Headshot Master", Description = "Get 100 headshots", XPReward = 1000},
    {ID = "win_streak", Name = "Unstoppable", Description = "Win 10 matches in a row", XPReward = 2000},
    {ID = "accuracy_ace", Name = "Sharpshooter", Description = "Achieve 90% accuracy in a match", XPReward = 500},
    {ID = "damage_dealer", Name = "Heavy Hitter", Description = "Deal 100,000 total damage", XPReward = 1500}
}

-- Bot Difficulty Settings
GameData.BotDifficulty = {
    Easy = {Accuracy = 0.3, ReactionTime = 1.5, Health = 80},
    Normal = {Accuracy = 0.6, ReactionTime = 1.0, Health = 100},
    Hard = {Accuracy = 0.8, ReactionTime = 0.5, Health = 120}
}

return GameData