-- Advanced Clan System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local ClanSystem = {}

-- Clan data structure
local Clans = {}
local PlayerClans = {}
local ClanInvites = {}
local BannedPlayers = {} -- Track banned players per clan

-- Clan configuration
local ClanConfig = {
    MaxMembers = 50, -- Increased for larger clans
    MaxClanNameLength = 25,
    CreationCost = 1000,
    DataStoreName = "BulletCoreClans",
    MinLevelForCreation = 5, -- Minimum level required to create clans
    ProfanityFilter = {
        "badword1", "badword2", "inappropriate" -- Add actual profanity words here
    },
    ClanEmblems = {
        Default = "rbxassetid://1234567890",
        Bronze = "rbxassetid://1234567891",
        Silver = "rbxassetid://1234567892",
        Gold = "rbxassetid://1234567893",
        Diamond = "rbxassetid://1234567894"
    },
    -- Clan progression configuration
    ClanProgression = {
        MaxLevel = 100,
        XPRequirements = {
            [1] = 0, [2] = 100, [3] = 250, [4] = 450, [5] = 700,
            [6] = 1000, [7] = 1350, [8] = 1750, [9] = 2200, [10] = 2700
        },
        LevelBenefits = {
            [1] = {MaxMembers = 10, VaultSlots = 5},
            [2] = {MaxMembers = 12, VaultSlots = 6},
            [3] = {MaxMembers = 14, VaultSlots = 7},
            [4] = {MaxMembers = 16, VaultSlots = 8},
            [5] = {MaxMembers = 18, VaultSlots = 9},
            [6] = {MaxMembers = 20, VaultSlots = 10},
            [7] = {MaxMembers = 22, VaultSlots = 11},
            [8] = {MaxMembers = 25, VaultSlots = 12},
            [9] = {MaxMembers = 28, VaultSlots = 13},
            [10] = {MaxMembers = 30, VaultSlots = 15}
        }
    },
    -- Role permissions system
    RolePermissions = {
        Leader = {
            CanInvite = true,
            CanKick = true,
            CanBan = true,
            CanPromote = true,
            CanDemote = true,
            CanEditSettings = true,
            CanManageVault = true,
            CanDisbandClan = true,
            CanAssignRoles = true
        },
        Admin = {
            CanInvite = true,
            CanKick = true,
            CanBan = false,
            CanPromote = false,
            CanDemote = true,
            CanEditSettings = true,
            CanManageVault = true,
            CanDisbandClan = false,
            CanAssignRoles = false
        },
        Moderator = {
            CanInvite = true,
            CanKick = true,
            CanBan = false,
            CanPromote = false,
            CanDemote = false,
            CanEditSettings = false,
            CanManageVault = false,
            CanDisbandClan = false,
            CanAssignRoles = false
        },
        Member = {
            CanInvite = false,
            CanKick = false,
            CanBan = false,
            CanPromote = false,
            CanDemote = false,
            CanEditSettings = false,
            CanManageVault = false,
            CanDisbandClan = false,
            CanAssignRoles = false
        }
    }
}

-- Content moderation function
local function containsProfanity(text)
    local lowerText = string.lower(text)
    for _, badWord in pairs(ClanConfig.ProfanityFilter) do
        if string.find(lowerText, badWord) then
            return true
        end
    end
    return false
end

-- Create new clan
function ClanSystem.CreateClan(player, clanName, clanTag, description, emblemId)
    -- Check if player is already in a clan
    if PlayerClans[player.UserId] then
        return false, "You are already in a clan"
    end

    -- Check player level requirement
    local playerLevel = 1 -- This should be retrieved from player data system
    if playerLevel < ClanConfig.MinLevelForCreation then
        return false, "You need to reach level " .. ClanConfig.MinLevelForCreation .. " to create a clan"
    end

    -- Validate clan name
    if string.len(clanName) > ClanConfig.MaxClanNameLength or string.len(clanName) < 3 then
        return false, "Clan name must be 3-20 characters"
    end

    if string.len(clanTag) > 5 or string.len(clanTag) < 2 then
        return false, "Clan tag must be 2-5 characters"
    end

    -- Content moderation
    if containsProfanity(clanName) or containsProfanity(clanTag) or (description and containsProfanity(description)) then
        return false, "Inappropriate content detected. Please use appropriate language."
    end

    -- Check if clan name already exists
    for _, clan in pairs(Clans) do
        if clan.Name:lower() == clanName:lower() or clan.Tag:lower() == clanTag:lower() then
            return false, "Clan name or tag already exists"
        end
    end

    -- Create clan data
    local clanId = #Clans + 1
    local newClan = {
        Id = clanId,
        Name = clanName,
        Tag = clanTag,
        Owner = player.UserId,
        Members = {
            [player.UserId] = {
                UserId = player.UserId,
                Name = player.Name,
                Role = "Leader",
                JoinedDate = os.time(),
                Contribution = 0,
                LastActive = os.time()
            }
        },
        CreatedDate = os.time(),
        Description = description or "A tactical gaming clan",
        Level = 1,
        XP = 0,
        Funds = 0,
        Emblem = emblemId or ClanConfig.ClanEmblems.Default,
        IsPrivate = false,
        MemberCount = 1,
        Vault = {
            SharedCash = 0,
            SharedItems = {},
            ClanPerks = {}
        },
        Activity = {
            TotalKills = 0,
            TotalDeaths = 0,
            MatchesPlayed = 0,
            LastActivity = os.time()
        },
        Settings = {
            RecruitOpen = true,
            MinLevel = 1,
            AutoKick = false,
            AutoKickDays = 7
        }
    }

    Clans[clanId] = newClan
    PlayerClans[player.UserId] = clanId

    -- Save to datastore
    ClanSystem.SaveClanData(clanId)

    -- Update chat tags
    local ChatTagSystem = require(script.Parent.ChatTagSystem)
    ChatTagSystem.RefreshPlayerClan(player)

    print(player.Name .. " created clan: " .. clanName .. " [" .. clanTag .. "]")
    return true, "Clan created successfully!"
end

-- Join clan
function ClanSystem.JoinClan(player, clanId)
    local clan = Clans[clanId]
    if not clan then
        return false, "Clan not found"
    end

    if PlayerClans[player.UserId] then
        return false, "You are already in a clan"
    end

    if clan.MemberCount >= ClanConfig.MaxMembers then
        return false, "Clan is full"
    end

    if clan.IsPrivate then
        return false, "This is a private clan"
    end

    -- Check if player is banned from this clan
    if BannedPlayers[clanId] and BannedPlayers[clanId][player.UserId] then
        return false, "You are banned from this clan"
    end

    -- Add player to clan
    clan.Members[player.UserId] = {
        UserId = player.UserId,
        Name = player.Name,
        Role = "Member",
        JoinedDate = os.time()
    }
    clan.MemberCount = clan.MemberCount + 1

    PlayerClans[player.UserId] = clanId

    -- Save to datastore
    ClanSystem.SaveClanData(clanId)

    -- Update chat tags
    local ChatTagSystem = require(script.Parent.ChatTagSystem)
    ChatTagSystem.RefreshPlayerClan(player)

    print(player.Name .. " joined clan: " .. clan.Name)
    return true, "Joined clan successfully!"
end

-- Leave clan
function ClanSystem.LeaveClan(player)
    local clanId = PlayerClans[player.UserId]
    if not clanId then
        return false, "You are not in a clan"
    end

    local clan = Clans[clanId]
    if not clan then
        return false, "Clan not found"
    end

    -- Check if player is leader
    local memberData = clan.Members[player.UserId]
    if memberData.Role == "Leader" then
        -- Transfer leadership or disband
        local memberCount = 0
        local newLeader = nil

        for userId, member in pairs(clan.Members) do
            if userId ~= player.UserId then
                memberCount = memberCount + 1
                if not newLeader or member.Role == "Officer" then
                    newLeader = userId
                end
            end
        end

        if memberCount > 0 and newLeader then
            clan.Members[newLeader].Role = "Leader"
            clan.Owner = newLeader
        else
            -- Disband clan
            ClanSystem.DisbandClan(clanId)
            PlayerClans[player.UserId] = nil
            return true, "Clan disbanded as you were the last member"
        end
    end

    -- Remove player from clan
    clan.Members[player.UserId] = nil
    clan.MemberCount = clan.MemberCount - 1
    PlayerClans[player.UserId] = nil

    -- Save to datastore
    ClanSystem.SaveClanData(clanId)

    -- Update chat tags
    local ChatTagSystem = require(script.Parent.ChatTagSystem)
    ChatTagSystem.RefreshPlayerClan(player)

    print(player.Name .. " left clan: " .. clan.Name)
    return true, "Left clan successfully"
end

-- Promote/demote member
function ClanSystem.ChangeMemberRole(player, targetPlayer, newRole)
    local clanId = PlayerClans[player.UserId]
    if not clanId then
        return false, "You are not in a clan"
    end

    local clan = Clans[clanId]
    if not clan then
        return false, "Clan not found"
    end

    -- Check permissions
    local playerRole = clan.Members[player.UserId].Role
    if playerRole ~= "Leader" and playerRole ~= "Officer" then
        return false, "Insufficient permissions"
    end

    if not clan.Members[targetPlayer.UserId] then
        return false, "Player not in clan"
    end

    -- Update role
    clan.Members[targetPlayer.UserId].Role = newRole

    -- Save to datastore
    ClanSystem.SaveClanData(clanId)

    print(player.Name .. " changed " .. targetPlayer.Name .. " role to " .. newRole)
    return true, "Role updated successfully"
end

-- Send clan invite
function ClanSystem.SendInvite(player, targetPlayer, clanId)
    local clan = Clans[clanId]
    if not clan then
        return false, "Clan not found"
    end

    if PlayerClans[player.UserId] ~= clanId then
        return false, "You are not in this clan"
    end

    -- Check permissions
    local playerRole = clan.Members[player.UserId].Role
    if playerRole ~= "Leader" and playerRole ~= "Officer" then
        return false, "Insufficient permissions to invite"
    end

    if PlayerClans[targetPlayer.UserId] then
        return false, "Player is already in a clan"
    end

    -- Send invite
    if not ClanInvites[targetPlayer.UserId] then
        ClanInvites[targetPlayer.UserId] = {}
    end

    ClanInvites[targetPlayer.UserId][clanId] = {
        ClanName = clan.Name,
        ClanTag = clan.Tag,
        Inviter = player.Name,
        Timestamp = os.time()
    }

    print(player.Name .. " invited " .. targetPlayer.Name .. " to clan " .. clan.Name)
    return true, "Invite sent successfully"
end

-- Respond to clan invite
function ClanSystem.RespondToInvite(player, clanId, accept)
    if not ClanInvites[player.UserId] or not ClanInvites[player.UserId][clanId] then
        return false, "No invite found"
    end

    if accept then
        return ClanSystem.JoinClan(player, clanId)
    else
        -- Decline invite
        ClanInvites[player.UserId][clanId] = nil
        return true, "Invite declined"
    end
end

-- Disband clan
function ClanSystem.DisbandClan(clanId)
    local clan = Clans[clanId]
    if not clan then return end

    -- Remove all members
    for userId, _ in pairs(clan.Members) do
        PlayerClans[userId] = nil
    end

    -- Remove clan
    Clans[clanId] = nil

    print("Clan disbanded: " .. clan.Name)
end

-- Get clan info
function ClanSystem.GetClanInfo(clanId)
    return Clans[clanId]
end

-- Get player's clan
function ClanSystem.GetPlayerClan(player)
    local clanId = PlayerClans[player.UserId]
    return clanId and Clans[clanId] or nil
end

-- Check if player has permission for action
function ClanSystem.HasPermission(player, clanId, permission)
    local clan = Clans[clanId]
    if not clan then return false end

    local memberData = clan.Members[player.UserId]
    if not memberData then return false end

    local role = memberData.Role
    local permissions = ClanConfig.RolePermissions[role]

    return permissions and permissions[permission] or false
end

-- Kick member from clan
function ClanSystem.KickMember(player, targetPlayer)
    local clanId = PlayerClans[player.UserId]
    if not clanId then
        return false, "You are not in a clan"
    end

    local clan = Clans[clanId]
    if not clan then
        return false, "Clan not found"
    end

    -- Check permissions
    if not ClanSystem.HasPermission(player, clanId, "CanKick") then
        return false, "Insufficient permissions to kick members"
    end

    if not clan.Members[targetPlayer.UserId] then
        return false, "Player not in clan"
    end

    -- Can't kick the leader
    if clan.Members[targetPlayer.UserId].Role == "Leader" then
        return false, "Cannot kick the clan leader"
    end

    -- Remove player from clan
    clan.Members[targetPlayer.UserId] = nil
    clan.MemberCount = clan.MemberCount - 1
    PlayerClans[targetPlayer.UserId] = nil

    -- Save to datastore
    ClanSystem.SaveClanData(clanId)

    -- Update chat tags
    local ChatTagSystem = require(script.Parent.ChatTagSystem)
    ChatTagSystem.RefreshPlayerClan(targetPlayer)

    print(player.Name .. " kicked " .. targetPlayer.Name .. " from clan " .. clan.Name)
    return true, "Player kicked successfully"
end

-- Ban member from clan
function ClanSystem.BanMember(player, targetPlayer, reason)
    local clanId = PlayerClans[player.UserId]
    if not clanId then
        return false, "You are not in a clan"
    end

    local clan = Clans[clanId]
    if not clan then
        return false, "Clan not found"
    end

    -- Check permissions
    if not ClanSystem.HasPermission(player, clanId, "CanBan") then
        return false, "Insufficient permissions to ban members"
    end

    if not clan.Members[targetPlayer.UserId] then
        return false, "Player not in clan"
    end

    -- Can't ban the leader
    if clan.Members[targetPlayer.UserId].Role == "Leader" then
        return false, "Cannot ban the clan leader"
    end

    -- Add to ban list
    if not BannedPlayers[clanId] then
        BannedPlayers[clanId] = {}
    end

    BannedPlayers[clanId][targetPlayer.UserId] = {
        PlayerName = targetPlayer.Name,
        BannedBy = player.Name,
        Reason = reason or "No reason provided",
        BanDate = os.time()
    }

    -- Remove from clan
    clan.Members[targetPlayer.UserId] = nil
    clan.MemberCount = clan.MemberCount - 1
    PlayerClans[targetPlayer.UserId] = nil

    -- Save to datastore
    ClanSystem.SaveClanData(clanId)

    -- Update chat tags
    local ChatTagSystem = require(script.Parent.ChatTagSystem)
    ChatTagSystem.RefreshPlayerClan(targetPlayer)

    print(player.Name .. " banned " .. targetPlayer.Name .. " from clan " .. clan.Name)
    return true, "Player banned successfully"
end

-- Unban player from clan
function ClanSystem.UnbanPlayer(player, targetUserId)
    local clanId = PlayerClans[player.UserId]
    if not clanId then
        return false, "You are not in a clan"
    end

    -- Check permissions
    if not ClanSystem.HasPermission(player, clanId, "CanBan") then
        return false, "Insufficient permissions to unban members"
    end

    if not BannedPlayers[clanId] or not BannedPlayers[clanId][targetUserId] then
        return false, "Player not banned from this clan"
    end

    -- Remove from ban list
    BannedPlayers[clanId][targetUserId] = nil

    print(player.Name .. " unbanned player " .. targetUserId .. " from clan " .. clanId)
    return true, "Player unbanned successfully"
end

-- Add XP to clan
function ClanSystem.AddClanXP(clanId, xpAmount)
    local clan = Clans[clanId]
    if not clan then return false end

    clan.XP = clan.XP + xpAmount
    local oldLevel = clan.Level

    -- Check for level up
    while clan.Level < ClanConfig.ClanProgression.MaxLevel do
        local xpRequired = ClanConfig.ClanProgression.XPRequirements[clan.Level + 1]
        if not xpRequired or clan.XP < xpRequired then
            break
        end

        clan.Level = clan.Level + 1

        -- Apply level benefits
        if ClanConfig.ClanProgression.LevelBenefits[clan.Level] then
            local benefits = ClanConfig.ClanProgression.LevelBenefits[clan.Level]
            -- Update max members if specified
            if benefits.MaxMembers then
                clan.MaxMembers = benefits.MaxMembers
            end
        end
    end

    -- Save if level changed
    if oldLevel ~= clan.Level then
        ClanSystem.SaveClanData(clanId)
        print("Clan " .. clan.Name .. " leveled up to level " .. clan.Level)
        return true, clan.Level
    end

    return false, oldLevel
end

-- Update clan activity
function ClanSystem.UpdateClanActivity(clanId, kills, deaths, matches)
    local clan = Clans[clanId]
    if not clan then return end

    if kills then clan.Activity.TotalKills = clan.Activity.TotalKills + kills end
    if deaths then clan.Activity.TotalDeaths = clan.Activity.TotalDeaths + deaths end
    if matches then clan.Activity.MatchesPlayed = clan.Activity.MatchesPlayed + matches end

    clan.Activity.LastActivity = os.time()
end

-- Get clan statistics
function ClanSystem.GetClanStats(clanId)
    local clan = Clans[clanId]
    if not clan then return nil end

    return {
        Level = clan.Level,
        XP = clan.XP,
        TotalKills = clan.Activity.TotalKills,
        TotalDeaths = clan.Activity.TotalDeaths,
        MatchesPlayed = clan.Activity.MatchesPlayed,
        KDRatio = clan.Activity.TotalDeaths > 0 and (clan.Activity.TotalKills / clan.Activity.TotalDeaths) or clan.Activity.TotalKills,
        MemberCount = clan.MemberCount,
        MaxMembers = clan.MaxMembers or ClanConfig.MaxMembers,
        Funds = clan.Funds,
        CreatedDate = clan.CreatedDate
    }
end

-- Get clan leaderboard
function ClanSystem.GetClanLeaderboard(sortBy, limit)
    sortBy = sortBy or "Level"
    limit = limit or 10

    local clanList = {}
    for clanId, clanData in pairs(Clans) do
        table.insert(clanList, {
            Id = clanId,
            Name = clanData.Name,
            Tag = clanData.Tag,
            Level = clanData.Level,
            XP = clanData.XP,
            MemberCount = clanData.MemberCount,
            TotalKills = clanData.Activity.TotalKills,
            KDRatio = clanData.Activity.TotalDeaths > 0 and (clanData.Activity.TotalKills / clanData.Activity.TotalDeaths) or clanData.Activity.TotalKills
        })
    end

    -- Sort clans
    if sortBy == "Level" then
        table.sort(clanList, function(a, b) return a.Level > b.Level end)
    elseif sortBy == "XP" then
        table.sort(clanList, function(a, b) return a.XP > b.XP end)
    elseif sortBy == "Members" then
        table.sort(clanList, function(a, b) return a.MemberCount > b.MemberCount end)
    elseif sortBy == "Kills" then
        table.sort(clanList, function(a, b) return a.TotalKills > b.TotalKills end)
    elseif sortBy == "KD" then
        table.sort(clanList, function(a, b) return a.KDRatio > b.KDRatio end)
    end

    -- Return top clans
    local result = {}
    for i = 1, math.min(limit, #clanList) do
        table.insert(result, clanList[i])
    end

    return result
end

-- Transfer clan leadership
function ClanSystem.TransferLeadership(player, newLeader)
    local clanId = PlayerClans[player.UserId]
    if not clanId then
        return false, "You are not in a clan"
    end

    local clan = Clans[clanId]
    if not clan then
        return false, "Clan not found"
    end

    -- Check if player is current leader
    if clan.Owner ~= player.UserId then
        return false, "Only the clan leader can transfer leadership"
    end

    if not clan.Members[newLeader.UserId] then
        return false, "Player is not a member of this clan"
    end

    -- Transfer leadership
    clan.Owner = newLeader.UserId
    clan.Members[player.UserId].Role = "Admin" -- Demote old leader to Admin
    clan.Members[newLeader.UserId].Role = "Leader" -- Promote new leader

    -- Save to datastore
    ClanSystem.SaveClanData(clanId)

    print(player.Name .. " transferred clan leadership to " .. newLeader.Name)
    return true, "Leadership transferred successfully"
end

-- Update clan settings
function ClanSystem.UpdateClanSettings(player, settings)
    local clanId = PlayerClans[player.UserId]
    if not clanId then
        return false, "You are not in a clan"
    end

    local clan = Clans[clanId]
    if not clan then
        return false, "Clan not found"
    end

    -- Check permissions
    if not ClanSystem.HasPermission(player, clanId, "CanEditSettings") then
        return false, "Insufficient permissions to edit clan settings"
    end

    -- Update settings
    for key, value in pairs(settings) do
        if clan.Settings[key] ~= nil then
            clan.Settings[key] = value
        end
    end

    -- Save to datastore
    ClanSystem.SaveClanData(clanId)

    print(player.Name .. " updated clan settings for " .. clan.Name)
    return true, "Settings updated successfully"
end

-- Get banned players for clan
function ClanSystem.GetBannedPlayers(clanId)
    return BannedPlayers[clanId] or {}
end

-- Save clan data to datastore
function ClanSystem.SaveClanData(clanId)
    local clan = Clans[clanId]
    if not clan then return end

    local success, errorMessage = pcall(function()
        local clanStore = DataStoreService:GetDataStore(ClanConfig.DataStoreName)
        clanStore:SetAsync("Clan_" .. clanId, clan)
    end)

    if not success then
        warn("Failed to save clan data: " .. errorMessage)
    end
end

-- Load clan data from datastore
function ClanSystem.LoadClanData(clanId)
    local success, clanData = pcall(function()
        local clanStore = DataStoreService:GetDataStore(ClanConfig.DataStoreName)
        return clanStore:GetAsync("Clan_" .. clanId)
    end)

    if success and clanData then
        Clans[clanId] = clanData
        return clanData
    end

    return nil
end

-- Initialize clan system
function ClanSystem.Initialize()
    -- Create remote events
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not remoteEvents then
        remoteEvents = Instance.new("Folder")
        remoteEvents.Name = "RemoteEvents"
        remoteEvents.Parent = ReplicatedStorage
    end

    -- Clan events
    if not remoteEvents:FindFirstChild("CreateClan") then
        Instance.new("RemoteEvent", remoteEvents).Name = "CreateClan"
    end

    if not remoteEvents:FindFirstChild("JoinClan") then
        Instance.new("RemoteEvent", remoteEvents).Name = "JoinClan"
    end

    if not remoteEvents:FindFirstChild("LeaveClan") then
        Instance.new("RemoteEvent", remoteEvents).Name = "LeaveClan"
    end

    if not remoteEvents:FindFirstChild("ClanInvite") then
        Instance.new("RemoteEvent", remoteEvents).Name = "ClanInvite"
    end

    if not remoteEvents:FindFirstChild("UpdateClanInfo") then
        Instance.new("RemoteEvent", remoteEvents).Name = "UpdateClanInfo"
    end

    if not remoteEvents:FindFirstChild("KickMember") then
        Instance.new("RemoteEvent", remoteEvents).Name = "KickMember"
    end

    if not remoteEvents:FindFirstChild("BanMember") then
        Instance.new("RemoteEvent", remoteEvents).Name = "BanMember"
    end

    if not remoteEvents:FindFirstChild("TransferLeadership") then
        Instance.new("RemoteEvent", remoteEvents).Name = "TransferLeadership"
    end

    if not remoteEvents:FindFirstChild("UpdateClanSettings") then
        Instance.new("RemoteEvent", remoteEvents).Name = "UpdateClanSettings"
    end

    if not remoteEvents:FindFirstChild("GetClanStats") then
        Instance.new("RemoteEvent", remoteEvents).Name = "GetClanStats"
    end

    if not remoteEvents:FindFirstChild("GetClanLeaderboard") then
        Instance.new("RemoteEvent", remoteEvents).Name = "GetClanLeaderboard"
    end

    -- Listen for clan events
    local createClanRemote = remoteEvents:FindFirstChild("CreateClan")
    if createClanRemote then
        createClanRemote.OnServerEvent:Connect(function(player, clanName, clanTag)
            local success, message = ClanSystem.CreateClan(player, clanName, clanTag)
            -- Send response back to client
            local responseRemote = remoteEvents:FindFirstChild("ClanResponse")
            if responseRemote then
                responseRemote:FireClient(player, success, message)
            end
        end)
    end

    local joinClanRemote = remoteEvents:FindFirstChild("JoinClan")
    if joinClanRemote then
        joinClanRemote.OnServerEvent:Connect(function(player, clanId)
            local success, message = ClanSystem.JoinClan(player, clanId)
            local responseRemote = remoteEvents:FindFirstChild("ClanResponse")
            if responseRemote then
                responseRemote:FireClient(player, success, message)
            end
        end)
    end

    local leaveClanRemote = remoteEvents:FindFirstChild("LeaveClan")
    if leaveClanRemote then
        leaveClanRemote.OnServerEvent:Connect(function(player)
            local success, message = ClanSystem.LeaveClan(player)
            local responseRemote = remoteEvents:FindFirstChild("ClanResponse")
            if responseRemote then
                responseRemote:FireClient(player, success, message)
            end
        end)
    end

    -- Advanced clan management events
    local kickMemberRemote = remoteEvents:FindFirstChild("KickMember")
    if kickMemberRemote then
        kickMemberRemote.OnServerEvent:Connect(function(player, targetPlayer)
            local success, message = ClanSystem.KickMember(player, targetPlayer)
            local responseRemote = remoteEvents:FindFirstChild("ClanResponse")
            if responseRemote then
                responseRemote:FireClient(player, success, message)
            end
        end)
    end

    local banMemberRemote = remoteEvents:FindFirstChild("BanMember")
    if banMemberRemote then
        banMemberRemote.OnServerEvent:Connect(function(player, targetPlayer, reason)
            local success, message = ClanSystem.BanMember(player, targetPlayer, reason)
            local responseRemote = remoteEvents:FindFirstChild("ClanResponse")
            if responseRemote then
                responseRemote:FireClient(player, success, message)
            end
        end)
    end

    local transferLeadershipRemote = remoteEvents:FindFirstChild("TransferLeadership")
    if transferLeadershipRemote then
        transferLeadershipRemote.OnServerEvent:Connect(function(player, newLeader)
            local success, message = ClanSystem.TransferLeadership(player, newLeader)
            local responseRemote = remoteEvents:FindFirstChild("ClanResponse")
            if responseRemote then
                responseRemote:FireClient(player, success, message)
            end
        end)
    end

    local updateClanSettingsRemote = remoteEvents:FindFirstChild("UpdateClanSettings")
    if updateClanSettingsRemote then
        updateClanSettingsRemote.OnServerEvent:Connect(function(player, settings)
            local success, message = ClanSystem.UpdateClanSettings(player, settings)
            local responseRemote = remoteEvents:FindFirstChild("ClanResponse")
            if responseRemote then
                responseRemote:FireClient(player, success, message)
            end
        end)
    end

    local getClanStatsRemote = remoteEvents:FindFirstChild("GetClanStats")
    if getClanStatsRemote then
        getClanStatsRemote.OnServerEvent:Connect(function(player, clanId)
            local stats = ClanSystem.GetClanStats(clanId)
            local responseRemote = remoteEvents:FindFirstChild("ClanStatsResponse")
            if responseRemote then
                responseRemote:FireClient(player, stats)
            end
        end)
    end

    local getClanLeaderboardRemote = remoteEvents:FindFirstChild("GetClanLeaderboard")
    if getClanLeaderboardRemote then
        getClanLeaderboardRemote.OnServerEvent:Connect(function(player, sortBy, limit)
            local leaderboard = ClanSystem.GetClanLeaderboard(sortBy, limit)
            local responseRemote = remoteEvents:FindFirstChild("ClanLeaderboardResponse")
            if responseRemote then
                responseRemote:FireClient(player, leaderboard)
            end
        end)
    end

    print("🏰 Advanced Clan System initialized!")
end

-- Get all clans for browsing
function ClanSystem.GetAllClans()
    local clans = {}
    for clanId, clanData in pairs(Clans) do
        table.insert(clans, {
            Id = clanId,
            Name = clanData.Name,
            Tag = clanData.Tag,
            MemberCount = clanData.MemberCount,
            Level = clanData.Level,
            IsPrivate = clanData.IsPrivate
        })
    end
    return clans
end

return ClanSystem
