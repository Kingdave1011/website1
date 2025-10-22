-- Advanced Sound System for Weapons and Game Audio
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local SoundSystem = {}

-- Sound configurations for different weapons
local WeaponSounds = {
    Pistol = {
        Shoot = {
            SoundId = "rbxassetid://142761353", -- Pistol shot sound
            Volume = 0.7,
            Pitch = 1.0
        },
        Reload = {
            SoundId = "rbxassetid://142761367", -- Reload sound
            Volume = 0.5,
            Pitch = 1.0
        },
        Empty = {
            SoundId = "rbxassetid://142761380", -- Empty magazine click
            Volume = 0.3,
            Pitch = 1.2
        }
    },
    AssaultRifle = {
        Shoot = {
            SoundId = "rbxassetid://142761353", -- AR shot sound (placeholder)
            Volume = 0.8,
            Pitch = 0.9
        },
        Reload = {
            SoundId = "rbxassetid://142761367", -- AR reload sound
            Volume = 0.6,
            Pitch = 1.0
        },
        Empty = {
            SoundId = "rbxassetid://142761380", -- Empty click
            Volume = 0.4,
            Pitch = 1.1
        }
    },
    Shotgun = {
        Shoot = {
            SoundId = "rbxassetid://142761353", -- Shotgun blast
            Volume = 1.0,
            Pitch = 0.8
        },
        Reload = {
            SoundId = "rbxassetid://142761367", -- Shotgun reload
            Volume = 0.7,
            Pitch = 1.0
        },
        Empty = {
            SoundId = "rbxassetid://142761380", -- Empty click
            Volume = 0.5,
            Pitch = 1.0
        }
    },
    Sniper = {
        Shoot = {
            SoundId = "rbxassetid://142761353", -- Sniper shot
            Volume = 0.9,
            Pitch = 0.7
        },
        Reload = {
            SoundId = "rbxassetid://142761367", -- Sniper reload
            Volume = 0.6,
            Pitch = 1.0
        },
        Empty = {
            SoundId = "rbxassetid://142761380", -- Empty click
            Volume = 0.4,
            Pitch = 1.3
        }
    }
}

-- Impact and environment sounds
local ImpactSounds = {
    Player = {
        SoundId = "rbxassetid://142761353", -- Flesh impact (placeholder)
        Volume = 0.6,
        Pitch = 1.0
    },
    Wall = {
        SoundId = "rbxassetid://142761367", -- Wall impact (placeholder)
        Volume = 0.4,
        Pitch = 1.0
    },
    Metal = {
        SoundId = "rbxassetid://142761380", -- Metal impact (placeholder)
        Volume = 0.5,
        Pitch = 1.2
    }
}

-- UI and game sounds
local UISounds = {
    HitMarker = {
        SoundId = "rbxassetid://142761353", -- Hit marker sound (placeholder)
        Volume = 0.3,
        Pitch = 1.5
    },
    KillConfirmed = {
        SoundId = "rbxassetid://142761367", -- Kill sound (placeholder)
        Volume = 0.5,
        Pitch = 1.0
    },
    Headshot = {
        SoundId = "rbxassetid://142761380", -- Headshot bonus (placeholder)
        Volume = 0.4,
        Pitch = 1.8
    }
}

-- Active sound instances for management
local activeSounds = {}
local soundCooldowns = {}

-- Create a sound instance
local function createSound(soundData, parent)
    local sound = Instance.new("Sound")
    sound.SoundId = soundData.SoundId
    sound.Volume = soundData.Volume
    sound.Pitch = soundData.Pitch
    sound.Parent = parent or SoundService

    -- Add fade out effect for better audio experience
    sound.Played:Connect(function()
        sound.Ended:Connect(function()
            if sound.Parent then
                TweenService:Create(sound, TweenInfo.new(0.2), {Volume = 0}):Play()
                wait(0.2)
                sound:Destroy()
            end
        end)
    end)

    return sound
end

-- Play weapon sound effect
function SoundSystem.PlayWeaponSound(weaponName, soundType, position)
    local weaponConfig = WeaponSounds[weaponName]
    if not weaponConfig or not weaponConfig[soundType] then return end

    local soundData = weaponConfig[soundType]
    local character = player.Character
    if not character then return end

    -- Create positional sound if position provided
    local parent = position and character:FindFirstChild("Head") or SoundService

    -- Check for cooldown to prevent sound spam
    local cooldownKey = weaponName .. "_" .. soundType
    if soundCooldowns[cooldownKey] and tick() - soundCooldowns[cooldownKey] < 0.1 then
        return
    end
    soundCooldowns[cooldownKey] = tick()

    local sound = createSound(soundData, parent)

    -- Add slight randomization for more realistic sound variation
    sound.Pitch = sound.Pitch + (math.random(-5, 5) / 100)
    sound.Volume = sound.Volume + (math.random(-10, 10) / 100)

    sound:Play()

    -- Track active sound
    table.insert(activeSounds, sound)

    -- Clean up old sounds
    if #activeSounds > 20 then
        local oldSound = table.remove(activeSounds, 1)
        if oldSound.Parent then
            oldSound:Destroy()
        end
    end
end

-- Play impact sound effect
function SoundSystem.PlayImpactSound(surfaceType, position)
    local soundData = ImpactSounds[surfaceType] or ImpactSounds.Wall
    if not soundData then return end

    -- Create a temporary part for positional audio
    local soundPart = Instance.new("Part")
    soundPart.Size = Vector3.new(1, 1, 1)
    soundPart.Position = position
    soundPart.Anchored = true
    soundPart.CanCollide = false
    soundPart.Transparency = 1
    soundPart.Parent = workspace

    local sound = createSound(soundData, soundPart)

    -- Add randomization
    sound.Pitch = sound.Pitch + (math.random(-10, 10) / 100)
    sound.Volume = soundData.Volume + (math.random(-15, 15) / 100)

    sound:Play()

    -- Clean up after sound ends
    sound.Ended:Connect(function()
        soundPart:Destroy()
    end)

    -- Track active sound
    table.insert(activeSounds, sound)
end

-- Play UI sound effect
function SoundSystem.PlayUISound(soundType)
    local soundData = UISounds[soundType]
    if not soundData then return end

    local sound = createSound(soundData)

    -- UI sounds don't need positional audio
    sound.Parent = SoundService

    sound:Play()

    -- Track active sound
    table.insert(activeSounds, sound)
end

-- Play environmental sound
function SoundSystem.PlayEnvironmentSound(soundName, position, volume, pitch)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundName -- You can replace with actual sound IDs
    sound.Volume = volume or 0.5
    sound.Pitch = pitch or 1.0

    if position then
        local soundPart = Instance.new("Part")
        soundPart.Size = Vector3.new(1, 1, 1)
        soundPart.Position = position
        soundPart.Anchored = true
        soundPart.CanCollide = false
        soundPart.Transparency = 1
        soundPart.Parent = workspace
        sound.Parent = soundPart

        sound.Ended:Connect(function()
            soundPart:Destroy()
        end)
    else
        sound.Parent = SoundService
    end

    sound:Play()
    table.insert(activeSounds, sound)
end

-- Set master volume
function SoundSystem.SetMasterVolume(volume)
    SoundService.MasterVolume = math.clamp(volume, 0, 1)
end

-- Mute/Unmute all sounds
function SoundSystem.SetMuted(muted)
    SoundService.MasterVolume = muted and 0 or 1
end

-- Clean up all active sounds
function SoundSystem.Cleanup()
    for _, sound in ipairs(activeSounds) do
        if sound.Parent then
            sound:Destroy()
        end
    end
    activeSounds = {}
    soundCooldowns = {}
end

-- Initialize sound system
function SoundSystem.Initialize()
    -- Create master sound group for volume control
    local masterGroup = SoundService:FindFirstChild("MasterGroup")
    if not masterGroup then
        masterGroup = Instance.new("SoundGroup")
        masterGroup.Name = "MasterGroup"
        masterGroup.Volume = 0.7
        masterGroup.Parent = SoundService
    end

    -- Listen for sound events from server
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        -- Hit marker sound
        local hitMarkerRemote = remoteEvents:FindFirstChild("HitMarker")
        if hitMarkerRemote then
            hitMarkerRemote.OnClientEvent:Connect(function()
                SoundSystem.PlayUISound("HitMarker")
            end)
        end

        -- Impact effect sound
        local impactRemote = remoteEvents:FindFirstChild("ImpactEffect")
        if impactRemote then
            impactRemote.OnClientEvent:Connect(function(position, normal, surfaceType)
                SoundSystem.PlayImpactSound(surfaceType or "Wall", position)
            end)
        end

        -- Screen shake (could add sound here too)
        local screenShakeRemote = remoteEvents:FindFirstChild("ScreenShake")
        if screenShakeRemote then
            screenShakeRemote.OnClientEvent:Connect(function(intensity)
                -- Could play a generic impact sound here
            end)
        end
    end

    -- Clean up sounds when player leaves
    player.CharacterRemoving:Connect(function()
        SoundSystem.Cleanup()
    end)

    print("🔊 Sound System initialized!")
end

return SoundSystem
