-- Clan Chat and Communication System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClanChatSystem = {}

-- Clan chat messages
local ClanMessages = {}
local PlayerClanChat = {}

-- Chat configuration
local ChatConfig = {
    MaxMessageLength = 200,
    MaxMessagesPerClan = 100,
    SpamCooldown = 2, -- seconds between messages
    RateLimit = 5 -- messages per minute
}

-- Player message tracking
local PlayerMessageCount = {}
local PlayerLastMessage = {}

-- Send clan message
function ClanChatSystem.SendClanMessage(player, message)
    local clanId = PlayerClanChat[player.UserId]
    if not clanId then
        return false, "You are not in a clan"
    end

    -- Check message length
    if string.len(message) > ChatConfig.MaxMessageLength then
        return false, "Message too long (max " .. ChatConfig.MaxMessageLength .. " characters)"
    end

    -- Check for spam
    local currentTime = tick()
    local lastMessage = PlayerLastMessage[player.UserId] or 0

    if currentTime - lastMessage < ChatConfig.SpamCooldown then
        return false, "Please wait before sending another message"
    end

    -- Rate limiting
    local playerMessages = PlayerMessageCount[player.UserId] or {}
    local recentMessages = 0
    local minuteAgo = currentTime - 60

    for _, messageTime in pairs(playerMessages) do
        if messageTime > minuteAgo then
            recentMessages = recentMessages + 1
        end
    end

    if recentMessages >= ChatConfig.RateLimit then
        return false, "Rate limit exceeded. Please slow down."
    end

    -- Content moderation
    local ClanSystem = require(script.Parent.ClanSystem)
    if containsProfanity(message) then
        return false, "Inappropriate language detected"
    end

    -- Create message data
    local messageData = {
        PlayerName = player.Name,
        PlayerId = player.UserId,
        Message = message,
        Timestamp = os.time(),
        ClanId = clanId
    }

    -- Add to clan messages
    if not ClanMessages[clanId] then
        ClanMessages[clanId] = {}
    end

    table.insert(ClanMessages[clanId], messageData)

    -- Keep only recent messages
    if #ClanMessages[clanId] > ChatConfig.MaxMessagesPerClan then
        table.remove(ClanMessages[clanId], 1)
    end

    -- Update player tracking
    table.insert(playerMessages, currentTime)
    PlayerMessageCount[player.UserId] = playerMessages
    PlayerLastMessage[player.UserId] = currentTime

    -- Send to all clan members
    local clan = ClanSystem.GetClanInfo(clanId)
    if clan then
        for userId, _ in pairs(clan.Members) do
            local clanPlayer = Players:GetPlayerByUserId(userId)
            if clanPlayer then
                local remoteEvents = ReplicatedStorage.RemoteEvents
                local clanChatRemote = remoteEvents:FindFirstChild("ClanChatMessage")
                if clanChatRemote then
                    clanChatRemote:FireClient(clanPlayer, messageData)
                end
            end
        end
    end

    print("[CLAN CHAT] " .. player.Name .. ": " .. message)
    return true, "Message sent"
end

-- Get clan messages
function ClanChatSystem.GetClanMessages(clanId)
    return ClanMessages[clanId] or {}
end

-- Join clan chat
function ClanChatSystem.JoinClanChat(player, clanId)
    PlayerClanChat[player.UserId] = clanId
    print(player.Name .. " joined clan chat for clan " .. clanId)
end

-- Leave clan chat
function ClanChatSystem.LeaveClanChat(player)
    PlayerClanChat[player.UserId] = nil
    print(player.Name .. " left clan chat")
end

-- Initialize clan chat system
function ClanChatSystem.Initialize()
    -- Create remote events
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not remoteEvents then
        remoteEvents = Instance.new("Folder")
        remoteEvents.Name = "RemoteEvents"
        remoteEvents.Parent = ReplicatedStorage
    end

    -- Clan chat events
    if not remoteEvents:FindFirstChild("SendClanMessage") then
        Instance.new("RemoteEvent", remoteEvents).Name = "SendClanMessage"
    end

    if not remoteEvents:FindFirstChild("ClanChatMessage") then
        Instance.new("RemoteEvent", remoteEvents).Name = "ClanChatMessage"
    end

    if not remoteEvents:FindFirstChild("RequestClanMessages") then
        Instance.new("RemoteEvent", remoteEvents).Name = "RequestClanMessages"
    end

    -- Listen for clan chat events
    local sendMessageRemote = remoteEvents:FindFirstChild("SendClanMessage")
    if sendMessageRemote then
        sendMessageRemote.OnServerEvent:Connect(function(player, message)
            local success, response = ClanChatSystem.SendClanMessage(player, message)
            -- Send response back
            local responseRemote = remoteEvents:FindFirstChild("ClanChatResponse")
            if responseRemote then
                responseRemote:FireClient(player, success, response)
            end
        end)
    end

    local requestMessagesRemote = remoteEvents:FindFirstChild("RequestClanMessages")
    if requestMessagesRemote then
        requestMessagesRemote.OnServerEvent:Connect(function(player)
            local clanId = PlayerClanChat[player.UserId]
            if clanId then
                local messages = ClanChatSystem.GetClanMessages(clanId)
                local responseRemote = remoteEvents:FindFirstChild("ClanMessagesResponse")
                if responseRemote then
                    responseRemote:FireClient(player, messages)
                end
            end
        end)
    end

    print("💬 Clan Chat System initialized!")
end

return ClanChatSystem
