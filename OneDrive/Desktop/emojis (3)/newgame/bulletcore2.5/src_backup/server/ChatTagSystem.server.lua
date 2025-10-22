-- Chat Tag System for Ranks
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatService = game:GetService("Chat")

local ChatTagSystem = {}

-- Chat tag configurations
local TagConfig = {
    SuperAdmin = {
        Tag = "[👑]",
        Color = Color3.fromRGB(255, 215, 0), -- Gold
        Priority = 100
    },
    Moderator = {
        Tag = "[🛡️]",
        Color = Color3.fromRGB(0, 150, 255), -- Blue
        Priority = 75
    },
    VIP = {
        Tag = "[💎]",
        Color = Color3.fromRGB(150, 0, 255), -- Purple
        Priority = 50
    },
    Player = {
        Tag = "[🪖]",
        Color = Color3.fromRGB(150, 150, 150), -- Gray
        Priority = 25
    }
}

-- Clan tag colors for different clans
local ClanColors = {
    [1] = Color3.fromRGB(255, 100, 100), -- Red
    [2] = Color3.fromRGB(100, 255, 100), -- Green
    [3] = Color3.fromRGB(100, 100, 255), -- Blue
    [4] = Color3.fromRGB(255, 255, 100), -- Yellow
    [5] = Color3.fromRGB(255, 100, 255), -- Magenta
    [6] = Color3.fromRGB(100, 255, 255), -- Cyan
    [7] = Color3.fromRGB(255, 150, 100), -- Orange
    [8] = Color3.fromRGB(150, 100, 255), -- Purple
    [9] = Color3.fromRGB(100, 150, 255), -- Light Blue
    [10] = Color3.fromRGB(255, 100, 150), -- Pink
}

-- Player rank cache
local playerRanks = {}

-- Get player rank
function ChatTagSystem.GetPlayerRank(player)
    local AdminSystem = require(script.Parent.AdminSystem)
    return AdminSystem.GetPlayerRank(player)
end

-- Update player rank
function ChatTagSystem.UpdatePlayerRank(player)
    local rank = ChatTagSystem.GetPlayerRank(player)
    playerRanks[player.UserId] = rank

    -- Update chat tag
    ChatTagSystem.ApplyChatTag(player, rank)
end

-- Apply chat tag to player
function ChatTagSystem.ApplyChatTag(player, rank)
    local tagData = TagConfig[rank]
    if not tagData then return end

    -- Get player's clan information
    local ClanSystem = require(script.Parent.ClanSystem)
    local clan = ClanSystem.GetPlayerClan(player)
    local tags = {}
    local nameColor = tagData.Color

    -- Add rank tag
    table.insert(tags, {
        TagText = tagData.Tag,
        TagColor = tagData.Color
    })

    -- Add clan tag if player is in a clan
    if clan then
        local clanColor = ClanColors[clan.Id % 10 + 1] or Color3.fromRGB(200, 200, 200)
        table.insert(tags, {
            TagText = "[" .. clan.Tag .. "]",
            TagColor = clanColor
        })
        -- Use clan color for name if they have a clan
        nameColor = clanColor
    end

    -- Set extra data for chat service
    local extraData = {
        NameColor = nameColor,
        ChatColor = tagData.Color,
        Tags = tags
    }

    -- Apply to chat service (if available)
    if ChatService then
        pcall(function()
            ChatService:SetPlayerExtraData(player, extraData)
        end)
    end
end

-- Handle player chatting
local function onPlayerChatted(player, message, recipient)
    local rank = playerRanks[player.UserId] or ChatTagSystem.GetPlayerRank(player)

    -- Add rank prefix to message
    local tagData = TagConfig[rank]
    if tagData then
        local prefixedMessage = tagData.Tag .. " " .. player.Name .. ": " .. message
        print(prefixedMessage) -- This will show in server console with tags
    end
end

-- Initialize chat tag system
function ChatTagSystem.Initialize()
    -- Update ranks for existing players
    for _, player in pairs(Players:GetPlayers()) do
        ChatTagSystem.UpdatePlayerRank(player)
    end

    -- Listen for new players
    Players.PlayerAdded:Connect(function(player)
        ChatTagSystem.UpdatePlayerRank(player)
    end)

    -- Listen for player leaving
    Players.PlayerRemoving:Connect(function(player)
        playerRanks[player.UserId] = nil
    end)

    -- Hook into chat service if available
    if ChatService then
        -- Override the chat function to add tags
        local originalChat = ChatService.InternalApplyChatMessage

        if originalChat then
            ChatService.InternalApplyChatMessage = function(self, messageData)
                local player = messageData.SpeakerUserId and Players:GetPlayerByUserId(messageData.SpeakerUserId)
                if player then
                    local rank = playerRanks[player.UserId] or ChatTagSystem.GetPlayerRank(player)
                    local tagData = TagConfig[rank]

                    if tagData then
                        -- Get player's clan information for chat message formatting
                        local ClanSystem = require(script.Parent.ClanSystem)
                        local clan = ClanSystem.GetPlayerClan(player)
                        local clanText = ""

                        if clan then
                            clanText = "[" .. clan.Tag .. "] "
                        end

                        -- Add both rank and clan tags to message
                        messageData.Message = tagData.Tag .. " " .. clanText .. messageData.Message
                        messageData.NameColor = tagData.Color
                    end
                end

                return originalChat(self, messageData)
            end
        end
    end

    print("💬 Chat Tag System initialized!")
end

-- Manual rank update (for promotions/demotions)
function ChatTagSystem.RefreshPlayerRank(player)
    ChatTagSystem.UpdatePlayerRank(player)
end

-- Refresh clan tag (for joining/leaving clans)
function ChatTagSystem.RefreshPlayerClan(player)
    local rank = playerRanks[player.UserId] or ChatTagSystem.GetPlayerRank(player)
    ChatTagSystem.ApplyChatTag(player, rank)
end

-- Update all players' clan tags (useful when clans are loaded/modified)
function ChatTagSystem.RefreshAllClanTags()
    for _, player in pairs(Players:GetPlayers()) do
        ChatTagSystem.RefreshPlayerClan(player)
    end
end

return ChatTagSystem
