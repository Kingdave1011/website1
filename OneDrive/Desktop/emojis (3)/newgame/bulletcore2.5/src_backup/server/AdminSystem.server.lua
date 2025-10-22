-- Advanced Admin Panel System with Access Control
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local AdminSystem = {}

-- Admin Configuration
local AdminConfig = {
    SuperAdmins = {
        ["kinlo"] = true, -- Only you have access by default
    },
    Moderators = {
        -- Players you promote to moderator will be added here
    },
    AdminCommands = {
        Kick = true,
        Ban = true,
        Teleport = true,
        GiveWeapon = true,
        GodMode = true,
        SpeedBoost = true,
        SpawnItem = true,
        KillAll = true,
        Shutdown = true,
        Announce = true
    },
    ModeratorCommands = {
        Kick = true,
        Teleport = true,
        GiveWeapon = true,
        SpeedBoost = true,
        SpawnItem = true,
        Announce = false
    },
    BannedPlayers = {},
    MutedPlayers = {},
    ChatTags = {
        SuperAdmin = "[👑]",
        Moderator = "[🛡️]",
        VIP = "[💎]",
        Player = "[🪖]"
    }
}

-- Player admin status
local playerAdminStatus = {}

-- Create RemoteEvents for admin panel
local function ensureAdminEvents()
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not remoteEvents then
        remoteEvents = Instance.new("Folder")
        remoteEvents.Name = "RemoteEvents"
        remoteEvents.Parent = ReplicatedStorage
    end

    -- Admin events
    if not remoteEvents:FindFirstChild("AdminCommand") then
        Instance.new("RemoteEvent", remoteEvents).Name = "AdminCommand"
    end

    if not remoteEvents:FindFirstChild("UpdateAdminPanel") then
        Instance.new("RemoteEvent", remoteEvents).Name = "UpdateAdminPanel"
    end
end

-- Check if player is admin
function AdminSystem.IsAdmin(player)
    return AdminConfig.SuperAdmins[player.Name] == true or playerAdminStatus[player.UserId] == true
end

-- Check if player is moderator
function AdminSystem.IsModerator(player)
    return AdminConfig.Moderators[player.Name] == true or AdminSystem.IsAdmin(player)
end

-- Get player rank
function AdminSystem.GetPlayerRank(player)
    if AdminSystem.IsAdmin(player) then
        return "SuperAdmin"
    elseif AdminSystem.IsModerator(player) then
        return "Moderator"
    else
        return "Player"
    end
end

-- Promote player to admin
function AdminSystem.PromoteAdmin(player, targetPlayer)
    if not AdminSystem.IsAdmin(player) then return false end

    AdminConfig.SuperAdmins[targetPlayer.Name] = true
    playerAdminStatus[targetPlayer.UserId] = true

    -- Notify target
    local remoteEvents = ReplicatedStorage.RemoteEvents
    local updateAdminRemote = remoteEvents:FindFirstChild("UpdateAdminPanel")
    if updateAdminRemote then
        updateAdminRemote:FireClient(targetPlayer, true)
    end

    print(player.Name .. " promoted " .. targetPlayer.Name .. " to admin")
    return true
end

-- Promote player to moderator
function AdminSystem.PromoteModerator(player, targetPlayer)
    if not AdminSystem.IsAdmin(player) then return false end

    AdminConfig.Moderators[targetPlayer.Name] = true

    -- Notify target
    local remoteEvents = ReplicatedStorage.RemoteEvents
    local updateModRemote = remoteEvents:FindFirstChild("UpdateModeratorPanel")
    if updateModRemote then
        updateModRemote:FireClient(targetPlayer, true)
    end

    print(player.Name .. " promoted " .. targetPlayer.Name .. " to moderator")
    return true
end

-- Demote admin
function AdminSystem.DemoteAdmin(player, targetPlayer)
    if not AdminSystem.IsAdmin(player) then return false end
    if targetPlayer.Name == "kinlo" then return false end -- Can't demote super admin

    AdminConfig.SuperAdmins[targetPlayer.Name] = nil
    playerAdminStatus[targetPlayer.UserId] = nil

    -- Notify target
    local remoteEvents = ReplicatedStorage.RemoteEvents
    local updateAdminRemote = remoteEvents:FindFirstChild("UpdateAdminPanel")
    if updateAdminRemote then
        updateAdminRemote:FireClient(targetPlayer, false)
    end

    print(player.Name .. " demoted " .. targetPlayer.Name .. " from admin")
    return true
end

-- Demote moderator
function AdminSystem.DemoteModerator(player, targetPlayer)
    if not AdminSystem.IsAdmin(player) then return false end

    AdminConfig.Moderators[targetPlayer.Name] = nil

    -- Notify target
    local remoteEvents = ReplicatedStorage.RemoteEvents
    local updateModRemote = remoteEvents:FindFirstChild("UpdateModeratorPanel")
    if updateModRemote then
        updateModRemote:FireClient(targetPlayer, false)
    end

    print(player.Name .. " demoted " .. targetPlayer.Name .. " from moderator")
    return true
end

-- Execute admin command
function AdminSystem.ExecuteCommand(player, command, args)
    if not AdminSystem.IsAdmin(player) then return false end

    local targetPlayer = args.TargetPlayer
    local value = args.Value

    if command == "Kick" and targetPlayer then
        targetPlayer:Kick("Kicked by admin: " .. player.Name)
        return true

    elseif command == "Ban" and targetPlayer then
        AdminConfig.BannedPlayers[targetPlayer.UserId] = true
        targetPlayer:Kick("Banned by admin: " .. player.Name)
        return true

    elseif command == "Teleport" and targetPlayer then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            targetPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
        end
        return true

    elseif command == "GiveWeapon" and targetPlayer and value then
        local WeaponHandler = require(script.Parent.WeaponHandler)
        WeaponHandler.GiveWeapon(targetPlayer, value)
        return true

    elseif command == "GodMode" and targetPlayer then
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            targetPlayer.Character.Humanoid.MaxHealth = 999999
            targetPlayer.Character.Humanoid.Health = 999999
        end
        return true

    elseif command == "SpeedBoost" and targetPlayer and value then
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            targetPlayer.Character.Humanoid.WalkSpeed = tonumber(value) or 50
        end
        return true

    elseif command == "SpawnItem" and value then
        -- Spawn item at player location
        local item = Instance.new("Part")
        item.Size = Vector3.new(2, 2, 2)
        item.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
        item.BrickColor = BrickColor.random()
        item.Parent = workspace
        return true

    elseif command == "KillAll" then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                otherPlayer.Character:BreakJoints()
            end
        end
        return true

    elseif command == "Shutdown" then
        -- Server shutdown (use with caution)
        print("Server shutdown initiated by " .. player.Name)
        return true

    elseif command == "Announce" and value then
        -- Announce message to all players
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            print("[ANNOUNCEMENT] " .. value)
        end
        return true
    end

    return false
end

-- Check for banned players
local function checkBannedPlayers(player)
    if AdminConfig.BannedPlayers[player.UserId] then
        player:Kick("You are banned from this server")
        return
    end
end

-- Initialize admin system
function AdminSystem.Initialize()
    ensureAdminEvents()

    -- Listen for admin commands
    local remoteEvents = ReplicatedStorage.RemoteEvents
    local adminCommandRemote = remoteEvents:FindFirstChild("AdminCommand")
    if adminCommandRemote then
        adminCommandRemote.OnServerEvent:Connect(function(player, command, args)
            AdminSystem.ExecuteCommand(player, command, args)
        end)
    end

    -- Check new players for admin status
    Players.PlayerAdded:Connect(function(player)
        checkBannedPlayers(player)

        -- Check if player is admin
        if AdminSystem.IsAdmin(player) then
            local updateAdminRemote = remoteEvents:FindFirstChild("UpdateAdminPanel")
            if updateAdminRemote then
                updateAdminRemote:FireClient(player, true)
            end
        end
    end)

    print("🛡️ Admin System initialized with access control!")
end

-- Get admin commands for UI
function AdminSystem.GetAdminCommands()
    return AdminConfig.AdminCommands
end

-- Get online players for admin panel
function AdminSystem.GetOnlinePlayers()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(players, {
            Name = player.Name,
            UserId = player.UserId,
            IsAdmin = AdminSystem.IsAdmin(player)
        })
    end
    return players
end

return AdminSystem
