-- Weapon Handler Server
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local WeaponHandler = {}

-- Load weapon configurations from shared modules
local Weapons = {
    Pistol = require(game:GetService("ReplicatedStorage").Shared.Weapons.Pistol),
    AssaultRifle = require(game:GetService("ReplicatedStorage").Shared.Weapons.AssaultRifle),
    Shotgun = require(game:GetService("ReplicatedStorage").Shared.Weapons.Shotgun),
    Sniper = require(game:GetService("ReplicatedStorage").Shared.Weapons.Sniper)
}

-- Player weapon data
local playerWeapons = {}

-- Create RemoteEvents if they don't exist
local function ensureRemoteEvents()
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not remoteEvents then
        remoteEvents = Instance.new("Folder")
        remoteEvents.Name = "RemoteEvents"
        remoteEvents.Parent = ReplicatedStorage
    end

    -- Create events
    if not remoteEvents:FindFirstChild("Shoot") then
        Instance.new("RemoteEvent", remoteEvents).Name = "Shoot"
    end

    if not remoteEvents:FindFirstChild("UpdateAmmo") then
        Instance.new("RemoteEvent", remoteEvents).Name = "UpdateAmmo"
    end

    if not remoteEvents:FindFirstChild("HitMarker") then
        Instance.new("RemoteEvent", remoteEvents).Name = "HitMarker"
    end

    if not remoteEvents:FindFirstChild("ImpactEffect") then
        Instance.new("RemoteEvent", remoteEvents).Name = "ImpactEffect"
    end

    if not remoteEvents:FindFirstChild("BulletTrail") then
        Instance.new("RemoteEvent", remoteEvents).Name = "BulletTrail"
    end

    if not remoteEvents:FindFirstChild("MuzzleFlash") then
        Instance.new("RemoteEvent", remoteEvents).Name = "MuzzleFlash"
    end

    if not remoteEvents:FindFirstChild("ScreenShake") then
        Instance.new("RemoteEvent", remoteEvents).Name = "ScreenShake"
    end

    if not remoteEvents:FindFirstChild("Explosion") then
        Instance.new("RemoteEvent", remoteEvents).Name = "Explosion"
    end

    if not remoteEvents:FindFirstChild("Reload") then
        Instance.new("RemoteEvent", remoteEvents).Name = "Reload"
    end
end

-- Give player a weapon
function WeaponHandler.GiveWeapon(player, weaponName)
    if not playerWeapons[player.UserId] then
        playerWeapons[player.UserId] = {}
    end

    local weapon = Weapons[weaponName]
    if weapon then
        playerWeapons[player.UserId][weaponName] = {
            Name = weapon.Name,
            Damage = weapon.Damage,
            CurrentAmmo = weapon.MagazineSize,
            TotalAmmo = weapon.MagazineSize * 3,
            MagazineSize = weapon.MagazineSize,
            FireRate = weapon.FireRate,
            LastFire = 0
        }

        -- Update client
        local remoteEvents = ReplicatedStorage.RemoteEvents
        local updateAmmoRemote = remoteEvents:FindFirstChild("UpdateAmmo")
        if updateAmmoRemote then
            updateAmmoRemote:FireClient(player,
                playerWeapons[player.UserId][weaponName].CurrentAmmo,
                playerWeapons[player.UserId][weaponName].TotalAmmo,
                weaponName)
        end

        print("Gave " .. weaponName .. " to " .. player.Name)
        return true
    end
    return false
end

-- Handle shooting
function WeaponHandler.Shoot(player, weaponName, targetPosition)
    local playerData = playerWeapons[player.UserId]
    if not playerData or not playerData[weaponName] then
        return false
    end

    local weapon = playerData[weaponName]
    local currentTime = tick()

    -- Check fire rate
    if currentTime - weapon.LastFire < weapon.FireRate then
        return false
    end

    -- Check ammo
    if weapon.CurrentAmmo <= 0 then
        -- Auto-reload if out of ammo
        WeaponHandler.Reload(player, weaponName)
        return false
    end

    -- Raycast for hit detection
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end

    local origin = character.HumanoidRootPart.Position
    local direction = (targetPosition - origin).Unit

    -- Add some inaccuracy for realism
    local spread = (1 - Weapons[weaponName].Accuracy) * 0.1
    direction = direction + Vector3.new(
        math.random(-spread, spread),
        math.random(-spread, spread),
        math.random(-spread, spread)
    )
    direction = direction.Unit

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction * Weapons[weaponName].Range, raycastParams)

    -- Update ammo
    weapon.CurrentAmmo = weapon.CurrentAmmo - 1
    weapon.LastFire = currentTime

    -- Update client ammo display
    local remoteEvents = ReplicatedStorage.RemoteEvents
    local updateAmmoRemote = remoteEvents:FindFirstChild("UpdateAmmo")
    if updateAmmoRemote then
        updateAmmoRemote:FireClient(player, weapon.CurrentAmmo, weapon.TotalAmmo, weaponName)
    end

    -- Handle hit
    if result then
        local hitPlayer = Players:GetPlayerFromCharacter(result.Instance.Parent)
        if hitPlayer and hitPlayer ~= player then
            -- Apply damage
            local damage = Weapons[weaponName].Damage

            -- Send hit marker to shooter
            local hitMarkerRemote = remoteEvents:FindFirstChild("HitMarker")
            if hitMarkerRemote then
                hitMarkerRemote:FireClient(player)
            end

            -- Send impact effect to all players
            local impactRemote = remoteEvents:FindFirstChild("ImpactEffect")
            if impactRemote then
                impactRemote:FireAllClients(result.Position, result.Normal)
            end

            -- Apply damage to target (simplified - would need proper health system)
            print(player.Name .. " hit " .. hitPlayer.Name .. " for " .. damage .. " damage with " .. weaponName)
            return true
        else
            -- Hit environment - create impact effect
            local impactRemote = remoteEvents:FindFirstChild("ImpactEffect")
            if impactRemote then
                impactRemote:FireAllClients(result.Position, result.Normal)
            end
        end
    end

    -- Create bullet trail effect
    local bulletTrailRemote = remoteEvents:FindFirstChild("BulletTrail")
    if bulletTrailRemote then
        bulletTrailRemote:FireAllClients(origin, targetPosition)
    end

    return false
end

-- Reload weapon
function WeaponHandler.Reload(player, weaponName)
    local playerData = playerWeapons[player.UserId]
    if not playerData or not playerData[weaponName] then
        return false
    end

    local weapon = playerData[weaponName]

    if weapon.CurrentAmmo >= weapon.MagazineSize or weapon.TotalAmmo <= 0 then
        return false
    end

    local ammoNeeded = weapon.MagazineSize - weapon.CurrentAmmo
    local ammoToReload = math.min(ammoNeeded, weapon.TotalAmmo)

    weapon.CurrentAmmo = weapon.CurrentAmmo + ammoToReload
    weapon.TotalAmmo = weapon.TotalAmmo - ammoToReload

    -- Update client
    local remoteEvents = ReplicatedStorage.RemoteEvents
    local updateAmmoRemote = remoteEvents:FindFirstChild("UpdateAmmo")
    if updateAmmoRemote then
        updateAmmoRemote:FireClient(player, weapon.CurrentAmmo, weapon.TotalAmmo, weaponName)
    end

    return true
end

-- Initialize weapon handler
function WeaponHandler.Initialize()
    ensureRemoteEvents()

    -- Listen for shoot events
    local remoteEvents = ReplicatedStorage.RemoteEvents
    local shootRemote = remoteEvents:FindFirstChild("Shoot")
    if shootRemote then
        shootRemote.OnServerEvent:Connect(function(player, weaponName, targetPosition)
            WeaponHandler.Shoot(player, weaponName, targetPosition)
        end)
    end

    -- Listen for reload events
    local reloadRemote = remoteEvents:FindFirstChild("Reload")
    if reloadRemote then
        reloadRemote.OnServerEvent:Connect(function(player, weaponName)
            WeaponHandler.Reload(player, weaponName)
        end)
    end

    print("🔫 Weapon Handler initialized!")
end

-- Give starter weapons to new players
Players.PlayerAdded:Connect(function(player)
    wait(1) -- Wait for character to load

    -- Give pistol as starter weapon
    WeaponHandler.GiveWeapon(player, "Pistol")
end)

return WeaponHandler
