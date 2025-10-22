-- Advanced Lighting and Atmosphere System
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local AdvancedLighting = {}

-- Time of day states
local TimeStates = {
    Dawn = {Time = 6, Brightness = 2, Color = Color3.fromRGB(255, 200, 150)},
    Morning = {Time = 9, Brightness = 3, Color = Color3.fromRGB(255, 220, 180)},
    Noon = {Time = 12, Brightness = 4, Color = Color3.fromRGB(255, 255, 255)},
    Afternoon = {Time = 15, Brightness = 3.5, Color = Color3.fromRGB(255, 230, 200)},
    Evening = {Time = 18, Brightness = 2.5, Color = Color3.fromRGB(255, 180, 120)},
    Night = {Time = 21, Brightness = 1.5, Color = Color3.fromRGB(150, 150, 200)}
}

-- Current time state
local currentTimeState = "Noon"
local timeTransitionProgress = 0

-- Create advanced lighting effects
function AdvancedLighting.CreateAtmosphere()
    -- Remove existing lighting effects
    local existingEffects = Lighting:FindFirstChild("AdvancedLightingEffects")
    if existingEffects then
        existingEffects:Destroy()
    end

    local effectsFolder = Instance.new("Folder")
    effectsFolder.Name = "AdvancedLightingEffects"
    effectsFolder.Parent = Lighting

    -- Enhanced sun rays
    local sunRays = Instance.new("SunRaysEffect")
    sunRays.Intensity = 0.3
    sunRays.Spread = 0.8
    sunRays.Parent = effectsFolder

    -- Bloom effect
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.4
    bloom.Size = 24
    bloom.Threshold = 0.9
    bloom.Parent = effectsFolder

    -- Color correction
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Brightness = 0.1
    colorCorrection.Contrast = 0.3
    colorCorrection.Saturation = 0.2
    colorCorrection.Parent = effectsFolder

    -- Depth of field
    local depthOfField = Instance.new("DepthOfFieldEffect")
    depthOfField.FarIntensity = 0.5
    depthOfField.FocusDistance = 50
    depthOfField.InFocusRadius = 20
    depthOfField.Parent = effectsFolder

    -- Atmospheric blur
    local blur = Instance.new("BlurEffect")
    blur.Size = 2
    blur.Parent = effectsFolder

    return effectsFolder, sunRays, bloom, colorCorrection, depthOfField, blur
end

-- Create dynamic shadow system
function AdvancedLighting.CreateDynamicShadows()
    -- Enhanced shadow map
    local shadowMap = Instance.new("Folder")
    shadowMap.Name = "DynamicShadowSystem"
    shadowMap.Parent = workspace

    -- Create shadow casters for major objects
    for _, object in pairs(workspace:GetDescendants()) do
        if object:IsA("Part") and object.Size.Magnitude > 10 then
            -- Add shadow properties
            if not object:FindFirstChild("ShadowPart") then
                local shadow = Instance.new("Part")
                shadow.Name = "ShadowPart"
                shadow.Size = Vector3.new(object.Size.X, 0.1, object.Size.Z)
                shadow.Position = object.Position - Vector3.new(0, object.Size.Y/2 + 0.1, 0)
                shadow.Anchored = true
                shadow.CanCollide = false
                shadow.Transparency = 0.7
                shadow.BrickColor = BrickColor.new("Dark stone grey")
                shadow.Material = Enum.Material.SmoothPlastic
                shadow.Parent = shadowMap

                -- Weld to parent object
                local weld = Instance.new("Weld")
                weld.Part0 = shadow
                weld.Part1 = object
                weld.C0 = CFrame.new(0, -object.Size.Y/2 - 0.1, 0)
                weld.Parent = shadow
            end
        end
    end

    return shadowMap
end

-- Update time of day
function AdvancedLighting.UpdateTimeOfDay(targetTime)
    local targetState = nil

    -- Find appropriate time state
    for stateName, stateData in pairs(TimeStates) do
        if math.abs(stateData.Time - targetTime) < 1.5 then
            targetState = stateName
            break
        end
    end

    if not targetState then
        targetState = "Noon" -- Default fallback
    end

    if targetState ~= currentTimeState then
        -- Transition to new time state
        AdvancedLighting.TransitionTimeOfDay(targetState)
    end
end

-- Transition between time states
function AdvancedLighting.TransitionTimeOfDay(newState)
    local oldState = TimeStates[currentTimeState]
    local newStateData = TimeStates[newState]

    if not oldState or not newStateData then return end

    -- Animate lighting properties
    TweenService:Create(Lighting, TweenInfo.new(5), {
        Brightness = newStateData.Brightness,
        OutdoorAmbient = newStateData.Color * 0.3,
        ColorShift_Top = newStateData.Color * 0.8
    }):Play()

    -- Update sky
    if Lighting:FindFirstChild("Sky") then
        TweenService:Create(Lighting.Sky, TweenInfo.new(5), {
            SunAngularSize = 15,
            MoonAngularSize = 15,
            StarCount = newState == "Night" and 1000 or 0
        }):Play()
    end

    currentTimeState = newState
    print("🌅 Transitioned to " .. newState .. " lighting")
end

-- Create ambient occlusion effect
function AdvancedLighting.CreateAmbientOcclusion()
    local aoFolder = Instance.new("Folder")
    aoFolder.Name = "AmbientOcclusion"
    aoFolder.Parent = Lighting

    -- Create AO post-processing effect
    local aoEffect = Instance.new("ColorCorrectionEffect")
    aoEffect.Name = "AmbientOcclusionEffect"
    aoEffect.Contrast = 0.5
    aoEffect.Saturation = -0.2
    aoEffect.Parent = aoFolder

    return aoEffect
end

-- Create volumetric lighting
function AdvancedLighting.CreateVolumetricLighting()
    local volumetricFolder = Instance.new("Folder")
    volumetricFolder.Name = "VolumetricLighting"
    volumetricFolder.Parent = Lighting

    -- Create light shafts effect
    local lightShafts = Instance.new("SunRaysEffect")
    lightShafts.Name = "VolumetricLightShafts"
    lightShafts.Intensity = 0.4
    lightShafts.Spread = 1.2
    lightShafts.Parent = volumetricFolder

    -- Create atmospheric scattering
    local atmosphere = Instance.new("Atmosphere")
    atmosphere.Density = 0.3
    atmosphere.Offset = 0.5
    atmosphere.Color = Color3.fromRGB(200, 200, 255)
    atmosphere.Decay = Color3.fromRGB(150, 150, 200)
    atmosphere.Glare = 0.2
    atmosphere.Haze = 0.1
    atmosphere.Parent = Lighting

    return volumetricFolder, lightShafts, atmosphere
end

-- Create dynamic weather system
function AdvancedLighting.CreateWeatherSystem()
    local weatherFolder = Instance.new("Folder")
    weatherFolder.Name = "DynamicWeather"
    weatherFolder.Parent = Lighting

    -- Cloud system
    local clouds = Instance.new("Clouds")
    clouds.Cover = 0.3
    clouds.Density = 0.4
    clouds.Color = Color3.fromRGB(255, 255, 255)
    clouds.Parent = weatherFolder

    -- Fog system
    local fog = Instance.new("Atmosphere")
    fog.Name = "DynamicFog"
    fog.Density = 0.2
    fog.Offset = 0.1
    fog.Color = Color3.fromRGB(200, 200, 220)
    fog.Decay = Color3.fromRGB(180, 180, 200)
    fog.Glare = 0.1
    fog.Haze = 0.3
    fog.Parent = weatherFolder

    return weatherFolder, clouds, fog
end

-- Initialize advanced lighting
function AdvancedLighting.Initialize()
    -- Create all lighting systems
    local effectsFolder = AdvancedLighting.CreateAtmosphere()
    local shadowSystem = AdvancedLighting.CreateDynamicShadows()
    local aoEffect = AdvancedLighting.CreateAmbientOcclusion()
    local volumetricSystem = AdvancedLighting.CreateVolumetricLighting()
    local weatherSystem = AdvancedLighting.CreateWeatherSystem()

    -- Set initial lighting state
    Lighting.Brightness = 3
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.FogEnd = 200
    Lighting.FogStart = 50
    Lighting.FogColor = Color3.fromRGB(200, 200, 220)

    -- Start time cycle
    AdvancedLighting.StartTimeCycle()

    print("✨ Advanced Lighting System initialized!")
end

-- Start automatic time cycle
function AdvancedLighting.StartTimeCycle()
    local cycleTime = 0

    RunService.Heartbeat:Connect(function(deltaTime)
        cycleTime = cycleTime + deltaTime

        -- Complete cycle every 10 minutes (adjust as needed)
        local timeOfDay = (cycleTime / 600) * 24 -- 24 hour cycle in 10 minutes

        -- Update lighting based on time
        AdvancedLighting.UpdateTimeOfDay(timeOfDay)
    end)
end

-- Manual time setting
function AdvancedLighting.SetTimeOfDay(hour)
    AdvancedLighting.UpdateTimeOfDay(hour)
end

-- Get current time state
function AdvancedLighting.GetCurrentTimeState()
    return currentTimeState
end

-- Toggle dynamic shadows
function AdvancedLighting.ToggleShadows(enabled)
    if Lighting:FindFirstChild("DynamicShadowSystem") then
        Lighting.DynamicShadowSystem.Enabled = enabled
    end
end

-- Adjust weather intensity
function AdvancedLighting.SetWeatherIntensity(intensity)
    -- Adjust cloud cover and fog based on intensity (0-1)
    local clouds = Lighting:FindFirstChild("DynamicWeather") and Lighting.DynamicWeather:FindFirstChild("Clouds")
    if clouds then
        clouds.Cover = intensity * 0.8
        clouds.Density = intensity * 0.6
    end

    local fog = Lighting:FindFirstChild("DynamicWeather") and Lighting.DynamicWeather:FindFirstChild("DynamicFog")
    if fog then
        fog.Density = intensity * 0.5
        fog.Haze = intensity * 0.4
    end
end

return AdvancedLighting
