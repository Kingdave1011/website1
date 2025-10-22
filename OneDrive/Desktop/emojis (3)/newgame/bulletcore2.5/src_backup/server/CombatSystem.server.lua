-- Combat System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote Events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local shootRemote = Instance.new("RemoteEvent")
shootRemote.Name = "Shoot"
shootRemote.Parent = remoteEvents

local hitRemote = Instance.new("RemoteEvent")
hitRemote.Name = "Hit"
hitRemote.Parent = remoteEvents

-- Handle shooting
shootRemote.OnServerEvent:Connect(function(player, targetPlayer, hitPosition)
    if not player.Character or not targetPlayer.Character then return end
    
    local character = player.Character
    local targetCharacter = targetPlayer.Character
    local humanoid = targetCharacter:FindFirstChild("Humanoid")
    
    if humanoid and humanoid.Health > 0 then
        -- Deal damage
        local damage = 25
        humanoid.Health = math.max(0, humanoid.Health - damage)
        
        -- Fire hit effect to all clients
        hitRemote:FireAllClients(targetPlayer, hitPosition, damage)
        
        -- Award XP for hit
        if _G.BulletCore and _G.BulletCore.AddXP then
            _G.BulletCore.AddXP(player, 10)
        end
        
        -- Check for kill
        if humanoid.Health <= 0 then
            -- Award kill XP
            if _G.BulletCore and _G.BulletCore.AddXP then
                _G.BulletCore.AddXP(player, 100)
            end
            
            -- Update stats
            local playerData = _G.BulletCore.GetPlayerData(player)
            local targetData = _G.BulletCore.GetPlayerData(targetPlayer)
            
            if playerData then
                playerData.Kills = playerData.Kills + 1
            end
            if targetData then
                targetData.Deaths = targetData.Deaths + 1
            end
        end
    end
end)