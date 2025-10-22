-- Performance Monitoring and Optimization System
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local PerformanceMonitor = {}

-- Performance metrics
local performanceData = {
    FPS = 60,
    Ping = 0,
    MemoryUsage = 0,
    RenderTime = 0,
    PhysicsTime = 0,
    NetworkTime = 0,
    FrameTime = 0
}

-- Performance history for trend analysis
local fpsHistory = {}
local pingHistory = {}
local memoryHistory = {}

-- Optimization settings
local optimizationSettings = {
    TargetFPS = 60,
    MaxRenderDistance = 1000,
    GraphicsQuality = "High",
    EnableParticles = true,
    EnableShadows = true,
    EnableLighting = true,
    AdaptiveQuality = true
}

-- UI scaling for different devices
local deviceSettings = {
    IsMobile = false,
    IsTablet = false,
    ScreenSize = Vector2.new(1920, 1080),
    ScaleFactor = 1.0,
    TouchEnabled = false
}

-- Performance monitoring functions
local function updatePerformanceMetrics()
    -- Update FPS
    local currentFPS = 1 / RunService.RenderStepped:Wait()
    performanceData.FPS = math.floor(currentFPS)

    -- Store in history for trend analysis
    table.insert(fpsHistory, performanceData.FPS)
    if #fpsHistory > 100 then
        table.remove(fpsHistory, 1)
    end

    -- Update ping (simplified)
    performanceData.Ping = player:GetNetworkPing() * 1000

    -- Update memory usage
    local stats = game:GetService("Stats")
    performanceData.MemoryUsage = stats:GetTotalMemoryUsageMb()

    -- Update frame time
    performanceData.FrameTime = RunService.RenderStepped:Wait() * 1000
end

-- Adaptive quality adjustment
local function adjustGraphicsQuality()
    if not optimizationSettings.AdaptiveQuality then return end

    local avgFPS = 0
    for _, fps in ipairs(fpsHistory) do
        avgFPS = avgFPS + fps
    end
    avgFPS = avgFPS / #fpsHistory

    if avgFPS < 30 and optimizationSettings.GraphicsQuality == "High" then
        optimizationSettings.GraphicsQuality = "Medium"
        optimizationSettings.MaxRenderDistance = 500
        optimizationSettings.EnableParticles = false
        print("🔧 Performance: Reduced quality to Medium")
    elseif avgFPS < 45 and optimizationSettings.GraphicsQuality == "Medium" then
        optimizationSettings.GraphicsQuality = "Low"
        optimizationSettings.MaxRenderDistance = 250
        optimizationSettings.EnableShadows = false
        print("🔧 Performance: Reduced quality to Low")
    elseif avgFPS > 55 and optimizationSettings.GraphicsQuality == "Low" then
        optimizationSettings.GraphicsQuality = "Medium"
        optimizationSettings.MaxRenderDistance = 500
        optimizationSettings.EnableShadows = true
        print("🔧 Performance: Increased quality to Medium")
    elseif avgFPS > 70 and optimizationSettings.GraphicsQuality == "Medium" then
        optimizationSettings.GraphicsQuality = "High"
        optimizationSettings.MaxRenderDistance = 1000
        optimizationSettings.EnableParticles = true
        print("🔧 Performance: Increased quality to High")
    end
end

-- Device detection and optimization
local function detectDevice()
    local userInputService = game:GetService("UserInputService")
    local guiService = game:GetService("GuiService")

    deviceSettings.IsMobile = userInputService.TouchEnabled
    deviceSettings.IsTablet = guiService:IsTenFootInterface()
    deviceSettings.TouchEnabled = userInputService.TouchEnabled

    -- Get screen size
    local camera = workspace.CurrentCamera
    if camera then
        deviceSettings.ScreenSize = camera.ViewportSize
    end

    -- Calculate scale factor based on screen size
    local baseResolution = Vector2.new(1920, 1080)
    deviceSettings.ScaleFactor = math.min(
        deviceSettings.ScreenSize.X / baseResolution.X,
        deviceSettings.ScreenSize.Y / baseResolution.Y
    )

    -- Apply mobile-specific optimizations
    if deviceSettings.IsMobile then
        optimizationSettings.TargetFPS = 30
        optimizationSettings.GraphicsQuality = "Low"
        optimizationSettings.MaxRenderDistance = 300
        optimizationSettings.EnableParticles = false
        print("📱 Mobile device detected - Applied mobile optimizations")
    end
end

-- Create performance monitoring UI
local function createPerformanceUI()
    local performanceUI = Instance.new("ScreenGui")
    performanceUI.Name = "PerformanceUI"
    performanceUI.ResetOnSpawn = false
    performanceUI.Parent = player.PlayerGui

    -- Performance display (can be toggled)
    local perfFrame = Instance.new("Frame")
    perfFrame.Size = UDim2.new(0, 200, 0, 120)
    perfFrame.Position = UDim2.new(1, -210, 0, 10)
    perfFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    perfFrame.BackgroundTransparency = 0.7
    perfFrame.BorderSizePixel = 0
    perfFrame.Visible = false -- Hidden by default
    perfFrame.Parent = performanceUI

    local perfCorner = Instance.new("UICorner")
    perfCorner.CornerRadius = UDim.new(0, 8)
    perfCorner.Parent = perfFrame

    -- FPS label
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 0.2, 0)
    fpsLabel.Position = UDim2.new(0, 0, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 60"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.TextScaled = true
    fpsLabel.Parent = perfFrame

    -- Ping label
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(1, 0, 0.2, 0)
    pingLabel.Position = UDim2.new(0, 0, 0.2, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: 0ms"
    pingLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    pingLabel.Font = Enum.Font.SourceSansBold
    pingLabel.TextScaled = true
    pingLabel.Parent = perfFrame

    -- Memory label
    local memoryLabel = Instance.new("TextLabel")
    memoryLabel.Size = UDim2.new(1, 0, 0.2, 0)
    memoryLabel.Position = UDim2.new(0, 0, 0.4, 0)
    memoryLabel.BackgroundTransparency = 1
    memoryLabel.Text = "Memory: 0MB"
    memoryLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    memoryLabel.Font = Enum.Font.SourceSansBold
    memoryLabel.TextScaled = true
    memoryLabel.Parent = perfFrame

    -- Quality label
    local qualityLabel = Instance.new("TextLabel")
    qualityLabel.Size = UDim2.new(1, 0, 0.2, 0)
    qualityLabel.Position = UDim2.new(0, 0, 0.6, 0)
    qualityLabel.BackgroundTransparency = 1
    qualityLabel.Text = "Quality: High"
    qualityLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    qualityLabel.Font = Enum.Font.SourceSansBold
    qualityLabel.TextScaled = true
    qualityLabel.Parent = perfFrame

    -- Device info label
    local deviceLabel = Instance.new("TextLabel")
    deviceLabel.Size = UDim2.new(1, 0, 0.2, 0)
    deviceLabel.Position = UDim2.new(0, 0, 0.8, 0)
    deviceLabel.BackgroundTransparency = 1
    deviceLabel.Text = "Device: PC"
    deviceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    deviceLabel.Font = Enum.Font.SourceSansBold
    deviceLabel.TextScaled = true
    deviceLabel.Parent = perfFrame

    return performanceUI, perfFrame, fpsLabel, pingLabel, memoryLabel, qualityLabel, deviceLabel
end

-- Update performance display
local function updatePerformanceDisplay(perfFrame, fpsLabel, pingLabel, memoryLabel, qualityLabel, deviceLabel)
    fpsLabel.Text = string.format("FPS: %d", performanceData.FPS)

    -- Color code FPS
    if performanceData.FPS >= 50 then
        fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
    elseif performanceData.FPS >= 30 then
        fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
    else
        fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
    end

    pingLabel.Text = string.format("Ping: %dms", math.floor(performanceData.Ping))

    -- Color code ping
    if performanceData.Ping <= 50 then
        pingLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
    elseif performanceData.Ping <= 100 then
        pingLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
    else
        pingLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
    end

    memoryLabel.Text = string.format("Memory: %.1fMB", performanceData.MemoryUsage)
    qualityLabel.Text = string.format("Quality: %s", optimizationSettings.GraphicsQuality)

    -- Update device info
    local deviceType = "PC"
    if deviceSettings.IsMobile then
        deviceType = "Mobile"
    elseif deviceSettings.IsTablet then
        deviceType = "Tablet"
    end
    deviceLabel.Text = string.format("Device: %s (%.2fx)", deviceType, deviceSettings.ScaleFactor)
end

-- Apply graphics optimizations
local function applyGraphicsOptimizations()
    local lighting = game:GetService("Lighting")

    if optimizationSettings.GraphicsQuality == "Low" then
        -- Disable expensive effects
        lighting.GlobalShadows = false
        lighting.FogEnd = 100

        -- Reduce particle effects
        for _, particle in ipairs(workspace:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = false
            end
        end
    elseif optimizationSettings.GraphicsQuality == "Medium" then
        lighting.GlobalShadows = true
        lighting.FogEnd = 500

        -- Enable some particles
        for _, particle in ipairs(workspace:GetDescendants()) do
            if particle:IsA("ParticleEmitter") and particle:GetAttribute("Essential") then
                particle.Enabled = true
            end
        end
    else -- High
        lighting.GlobalShadows = true
        lighting.FogEnd = 1000

        -- Enable all particles
        for _, particle in ipairs(workspace:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle.Enabled = true
            end
        end
    end
end

-- Responsive UI scaling
local function applyResponsiveScaling(guiObject)
    if not guiObject then return end

    -- Apply scale factor to UI elements
    local function scaleElement(element)
        if element:IsA("GuiObject") then
            -- Scale size
            if element.Size ~= UDim2.new() then
                local originalSize = element:GetAttribute("OriginalSize")
                if not originalSize then
                    element:SetAttribute("OriginalSize", element.Size)
                    originalSize = element.Size
                end

                element.Size = UDim2.new(
                    originalSize.X.Scale * deviceSettings.ScaleFactor,
                    originalSize.X.Offset * deviceSettings.ScaleFactor,
                    originalSize.Y.Scale * deviceSettings.ScaleFactor,
                    originalSize.Y.Offset * deviceSettings.ScaleFactor
                )
            end

            -- Scale position
            if element.Position ~= UDim2.new() then
                local originalPos = element:GetAttribute("OriginalPosition")
                if not originalPos then
                    element:SetAttribute("OriginalPosition", element.Position)
                    originalPos = element.Position
                end

                element.Position = UDim2.new(
                    originalPos.X.Scale * deviceSettings.ScaleFactor,
                    originalPos.X.Offset * deviceSettings.ScaleFactor,
                    originalPos.Y.Scale * deviceSettings.ScaleFactor,
                    originalPos.Y.Offset * deviceSettings.ScaleFactor
                )
            end

            -- Scale text size
            if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
                local originalTextSize = element:GetAttribute("OriginalTextSize")
                if not originalTextSize then
                    element:SetAttribute("OriginalTextSize", element.TextSize)
                    originalTextSize = element.TextSize
                end

                element.TextSize = originalTextSize * deviceSettings.ScaleFactor
            end
        end

        -- Recursively scale children
        for _, child in ipairs(element:GetChildren()) do
            scaleElement(child)
        end
    end

    scaleElement(guiObject)
end

-- Toggle performance monitor visibility
local function togglePerformanceMonitor()
    local performanceUI = player.PlayerGui:FindFirstChild("PerformanceUI")
    if performanceUI then
        local perfFrame = performanceUI:FindFirstChild("PerformanceFrame")
        if perfFrame then
            perfFrame.Visible = not perfFrame.Visible
        end
    end
end

-- Initialize performance monitoring
function PerformanceMonitor.Initialize()
    detectDevice()

    local performanceUI, perfFrame, fpsLabel, pingLabel, memoryLabel, qualityLabel, deviceLabel = createPerformanceUI()

    -- Set frame reference for external access
    perfFrame.Name = "PerformanceFrame"
    perfFrame.Parent = performanceUI

    -- Start performance monitoring
    RunService.RenderStepped:Connect(function(deltaTime)
        updatePerformanceMetrics()
        adjustGraphicsQuality()
        applyGraphicsOptimizations()

        -- Update display if visible
        if perfFrame.Visible then
            updatePerformanceDisplay(perfFrame, fpsLabel, pingLabel, memoryLabel, qualityLabel, deviceLabel)
        end
    end)

    -- Apply responsive scaling to all existing UI
    for _, gui in ipairs(player.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            applyResponsiveScaling(gui)
        end
    end

    -- Toggle performance monitor with F3
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.F3 then
            togglePerformanceMonitor()
        end
    end)

    print("📊 Performance Monitor initialized!")
    print(string.format("🔧 Device detected: %s (Scale: %.2fx)",
        deviceSettings.IsMobile and "Mobile" or "PC",
        deviceSettings.ScaleFactor))
end

-- Public API functions
function PerformanceMonitor.GetPerformanceData()
    return performanceData
end

function PerformanceMonitor.GetDeviceSettings()
    return deviceSettings
end

function PerformanceMonitor.SetGraphicsQuality(quality)
    local validQualities = {"Low", "Medium", "High"}
    if table.find(validQualities, quality) then
        optimizationSettings.GraphicsQuality = quality
        applyGraphicsOptimizations()
        print("🔧 Graphics quality set to: " .. quality)
    end
end

function PerformanceMonitor.TogglePerformanceMonitor()
    togglePerformanceMonitor()
end

return PerformanceMonitor
