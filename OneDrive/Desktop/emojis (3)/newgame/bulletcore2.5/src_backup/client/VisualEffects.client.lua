-- Advanced Visual Effects System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local VisualEffects = {}

-- Muzzle flash effect
function VisualEffects.CreateMuzzleFlash(parent, position, size)
    local muzzleFlash = Instance.new("Part")
    muzzleFlash.Size = Vector3.new(size, size, size * 2)
    muzzleFlash.Position = position
    muzzleFlash.Anchored = true
    muzzleFlash.CanCollide = false
    muzzleFlash.Material = Enum.Material.Neon
    muzzleFlash.BrickColor = BrickColor.new("Bright orange")
    muzzleFlash.Parent = parent

    -- Add light
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 150, 0)
    light.Brightness = 5
    light.Range = 20
    light.Parent = muzzleFlash

    -- Add particle emitter for smoke
    local smokeEmitter = Instance.new("ParticleEmitter")
    smokeEmitter.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100))
    smokeEmitter.Size = NumberSequence.new(0.5, 2)
    smokeEmitter.Lifetime = NumberRange.new(0.5, 1)
    smokeEmitter.Rate = 50
    smokeEmitter.Speed = NumberRange.new(5, 10)
    smokeEmitter.Parent = muzzleFlash

    -- Animate and destroy
    TweenService:Create(muzzleFlash, TweenInfo.new(0.1), {
        Size = Vector3.new(size * 2, size * 2, size * 4),
        Transparency = 1
    }):Play()

    wait(0.1)
    muzzleFlash:Destroy()
end

-- Impact spark effect
function VisualEffects.CreateImpactEffect(position, normal)
    local impactPart = Instance.new("Part")
    impactPart.Size = Vector3.new(0.5, 0.5, 0.5)
    impactPart.Position = position + normal * 0.1
    impactPart.Anchored = true
    impactPart.CanCollide = false
    impactPart.Material = Enum.Material.Neon
    impactPart.BrickColor = BrickColor.new("Bright yellow")
    impactPart.Parent = workspace

    -- Spark particles
    local sparkEmitter = Instance.new("ParticleEmitter")
    sparkEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 0))
    })
    sparkEmitter.Size = NumberSequence.new(0.2, 1)
    sparkEmitter.Lifetime = NumberRange.new(0.3, 0.6)
    sparkEmitter.Rate = 100
    sparkEmitter.Speed = NumberRange.new(10, 20)
    sparkEmitter.SpreadAngle = Vector2.new(180, 180)
    sparkEmitter.Parent = impactPart

    -- Smoke particles
    local smokeEmitter = Instance.new("ParticleEmitter")
    smokeEmitter.Color = ColorSequence.new(Color3.fromRGB(80, 80, 80))
    smokeEmitter.Size = NumberSequence.new(1, 3)
    smokeEmitter.Lifetime = NumberRange.new(1, 2)
    smokeEmitter.Rate = 30
    smokeEmitter.Speed = NumberRange.new(3, 8)
    smokeEmitter.Parent = impactPart

    -- Animate and destroy
    TweenService:Create(impactPart, TweenInfo.new(0.5), {
        Size = Vector3.new(2, 2, 2),
        Transparency = 1
    }):Play()

    wait(0.5)
    impactPart:Destroy()
end

-- Screen shake effect
function VisualEffects.ScreenShake(intensity, duration)
    local camera = workspace.CurrentCamera
    if not camera then return end

    local originalPosition = camera.CFrame.Position
    local shakeTime = 0

    while shakeTime < duration do
        local deltaTime = wait()
        shakeTime = shakeTime + deltaTime

        local shakeOffset = Vector3.new(
            math.random(-intensity, intensity),
            math.random(-intensity, intensity),
            math.random(-intensity, intensity)
        ) * (1 - shakeTime / duration)

        camera.CFrame = CFrame.new(originalPosition + shakeOffset) * (camera.CFrame - camera.CFrame.Position)
    end

    camera.CFrame = CFrame.new(originalPosition) * (camera.CFrame - camera.CFrame.Position)
end

-- Hit marker effect
function VisualEffects.ShowHitMarker()
    local hitMarker = Instance.new("Frame")
    hitMarker.Size = UDim2.new(0, 60, 0, 60)
    hitMarker.Position = UDim2.new(0.5, -30, 0.5, -30)
    hitMarker.BackgroundTransparency = 1
    hitMarker.Parent = playerGui

    -- Create X shape
    for i = 1, 2 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        line.BorderSizePixel = 0
        line.Parent = hitMarker

        if i == 1 then
            line.Size = UDim2.new(0, 40, 0, 4)
            line.Position = UDim2.new(0.5, -20, 0.5, -2)
            line.Rotation = 45
        else
            line.Size = UDim2.new(0, 40, 0, 4)
            line.Position = UDim2.new(0.5, -20, 0.5, -2)
            line.Rotation = -45
        end
    end

    -- Animate
    TweenService:Create(hitMarker, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    wait(0.3)
    TweenService:Create(hitMarker, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    hitMarker:Destroy()
end

-- Bullet trail effect
function VisualEffects.CreateBulletTrail(startPosition, endPosition)
    local trail = Instance.new("Part")
    trail.Size = Vector3.new(0.1, 0.1, (endPosition - startPosition).Magnitude)
    trail.Position = startPosition + (endPosition - startPosition) / 2
    trail.Anchored = true
    trail.CanCollide = false
    trail.Material = Enum.Material.Neon
    trail.BrickColor = BrickColor.new("Bright blue")
    trail.Parent = workspace

    -- Orient towards end position
    trail.CFrame = CFrame.new(startPosition, endPosition) * CFrame.new(0, 0, -(endPosition - startPosition).Magnitude / 2)

    -- Animate
    TweenService:Create(trail, TweenInfo.new(0.2), {
        Size = Vector3.new(0.3, 0.3, (endPosition - startPosition).Magnitude),
        Transparency = 1
    }):Play()

    wait(0.2)
    trail:Destroy()
end

-- Explosion effect
function VisualEffects.CreateExplosion(position, radius)
    -- Main explosion part
    local explosion = Instance.new("Part")
    explosion.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
    explosion.Position = position
    explosion.Anchored = true
    explosion.CanCollide = false
    explosion.Material = Enum.Material.Neon
    explosion.BrickColor = BrickColor.new("Bright orange")
    explosion.Shape = Enum.PartType.Ball
    explosion.Parent = workspace

    -- Explosion light
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 100, 0)
    light.Brightness = 10
    light.Range = radius * 3
    light.Parent = explosion

    -- Explosion particles
    local fireEmitter = Instance.new("ParticleEmitter")
    fireEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 0))
    })
    fireEmitter.Size = NumberSequence.new(radius * 0.5, radius * 2)
    fireEmitter.Lifetime = NumberRange.new(1, 2)
    fireEmitter.Rate = 200
    fireEmitter.Speed = NumberRange.new(20, 40)
    fireEmitter.SpreadAngle = Vector2.new(180, 180)
    fireEmitter.Parent = explosion

    local smokeEmitter = Instance.new("ParticleEmitter")
    smokeEmitter.Color = ColorSequence.new(Color3.fromRGB(50, 50, 50))
    smokeEmitter.Size = NumberSequence.new(radius, radius * 3)
    smokeEmitter.Lifetime = NumberRange.new(2, 4)
    smokeEmitter.Rate = 100
    smokeEmitter.Speed = NumberRange.new(10, 20)
    smokeEmitter.SpreadAngle = Vector2.new(180, 180)
    smokeEmitter.Parent = explosion

    -- Animate explosion
    TweenService:Create(explosion, TweenInfo.new(1), {
        Size = Vector3.new(radius * 4, radius * 4, radius * 4),
        Transparency = 1
    }):Play()

    -- Screen shake for nearby players
    if (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
        local distance = (position - player.Character.HumanoidRootPart.Position).Magnitude
        if distance < radius * 2 then
            local intensity = (radius * 2 - distance) / (radius * 2) * 2
            VisualEffects.ScreenShake(intensity, 0.5)
        end
    end

    wait(1)
    explosion:Destroy()
end

-- Blood effect (for hits)
function VisualEffects.CreateBloodEffect(position)
    local blood = Instance.new("Part")
    blood.Size = Vector3.new(1, 1, 0.1)
    blood.Position = position
    blood.Anchored = true
    blood.CanCollide = false
    blood.Material = Enum.Material.SmoothPlastic
    blood.BrickColor = BrickColor.new("Bright red")
    blood.Parent = workspace

    local bloodDecal = Instance.new("Decal")
    bloodDecal.Texture = "rbxassetid://123456789" -- Blood texture ID
    bloodDecal.Face = Enum.NormalId.Front
    bloodDecal.Parent = blood

    -- Animate
    TweenService:Create(blood, TweenInfo.new(2), {
        Size = Vector3.new(3, 3, 0.1),
        Transparency = 1
    }):Play()

    wait(2)
    blood:Destroy()
end

-- Post-processing effects
function VisualEffects.ApplyPostProcessing()
    -- Enhance lighting
    Lighting.Brightness = 2
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

    -- Create bloom effect
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.3
    bloom.Size = 24
    bloom.Threshold = 0.8
    bloom.Parent = Lighting

    -- Color correction
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Brightness = 0.1
    colorCorrection.Contrast = 0.2
    colorCorrection.Saturation = 0.1
    colorCorrection.Parent = Lighting

    -- Sun rays effect
    local sunRays = Instance.new("SunRaysEffect")
    sunRays.Intensity = 0.2
    sunRays.Spread = 0.8
    sunRays.Parent = Lighting
end

-- Initialize visual effects
function VisualEffects.Initialize()
    VisualEffects.ApplyPostProcessing()

    -- Listen for remote events
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        -- Muzzle flash event
        local muzzleFlashRemote = remoteEvents:FindFirstChild("MuzzleFlash")
        if muzzleFlashRemote then
            muzzleFlashRemote.OnClientEvent:Connect(function(position, size)
                VisualEffects.CreateMuzzleFlash(workspace, position, size)
            end)
        end

        -- Impact effect event
        local impactRemote = remoteEvents:FindFirstChild("ImpactEffect")
        if impactRemote then
            impactRemote.OnClientEvent:Connect(function(position, normal)
                VisualEffects.CreateImpactEffect(position, normal)
            end)
        end

        -- Screen shake event
        local shakeRemote = remoteEvents:FindFirstChild("ScreenShake")
        if shakeRemote then
            shakeRemote.OnClientEvent:Connect(function(intensity, duration)
                VisualEffects.ScreenShake(intensity, duration)
            end)
        end

        -- Hit marker event
        local hitMarkerRemote = remoteEvents:FindFirstChild("HitMarker")
        if hitMarkerRemote then
            hitMarkerRemote.OnClientEvent:Connect(function()
                VisualEffects.ShowHitMarker()
            end)
        end

        -- Bullet trail event
        local bulletTrailRemote = remoteEvents:FindFirstChild("BulletTrail")
        if bulletTrailRemote then
            bulletTrailRemote.OnClientEvent:Connect(function(startPos, endPos)
                VisualEffects.CreateBulletTrail(startPos, endPos)
            end)
        end

        -- Explosion event
        local explosionRemote = remoteEvents:FindFirstChild("Explosion")
        if explosionRemote then
            explosionRemote.OnClientEvent:Connect(function(position, radius)
                VisualEffects.CreateExplosion(position, radius)
            end)
        end
    end

    print("✨ Advanced Visual Effects System loaded!")
end

return VisualEffects
