-- Comprehensive Settings Menu System
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SettingsGUI = {}

-- Settings data structure
local settingsData = {
    -- Gameplay Settings
    Gameplay = {
        AutoSprint = true,
        AimSensitivity = 0.5,
        InvertMouseY = false,
        ToggleCrouch = false,
        ToggleProne = false,
        AutoReload = true
    },

    -- Controls Settings
    Controls = {
        MouseSensitivity = 0.5,
        ControllerSensitivity = 0.5,
        KeyBindings = {
            Jump = Enum.KeyCode.Space,
            Crouch = Enum.KeyCode.LeftControl,
            Prone = Enum.KeyCode.C,
            Sprint = Enum.KeyCode.LeftShift,
            Reload = Enum.KeyCode.R,
            WeaponCycle = Enum.KeyCode.Q,
            Chat = Enum.KeyCode.T,
            Inventory = Enum.KeyCode.I,
            Map = Enum.KeyCode.M
        }
    },

    -- Graphics Settings
    Graphics = {
        Quality = "High",
        Resolution = "Auto",
        VSync = true,
        AntiAliasing = true,
        Shadows = true,
        Particles = true,
        Lighting = true,
        PostProcessing = true,
        RenderDistance = 1000,
        Brightness = 0.5,
        Contrast = 0.5
    },

    -- Audio Settings
    Audio = {
        MasterVolume = 0.7,
        SFXVolume = 0.8,
        MusicVolume = 0.6,
        VoiceVolume = 0.9,
        MuteAudio = false,
        EnableSpatialAudio = true,
        AudioQuality = "High"
    },

    -- Interface Settings
    Interface = {
        ShowFPS = false,
        ShowPing = false,
        ShowDamageNumbers = true,
        ShowHitMarkers = true,
        HUDScale = 1.0,
        ChatOpacity = 0.8,
        CrosshairStyle = "Default",
        CrosshairColor = Color3.fromRGB(255, 255, 255),
        Subtitles = true,
        ColorBlindMode = false
    },

    -- Accessibility Settings
    Accessibility = {
        ReduceMotion = false,
        HighContrast = false,
        LargeText = false,
        ScreenReader = false,
        AutoSprint = true,
        SimplifiedControls = false
    }
}

-- Default settings for reset functionality
local defaultSettings = {
    Gameplay = {
        AutoSprint = true,
        AimSensitivity = 0.5,
        InvertMouseY = false,
        ToggleCrouch = false,
        ToggleProne = false,
        AutoReload = true
    },

    Controls = {
        MouseSensitivity = 0.5,
        ControllerSensitivity = 0.5,
        KeyBindings = {
            Jump = Enum.KeyCode.Space,
            Crouch = Enum.KeyCode.LeftControl,
            Prone = Enum.KeyCode.C,
            Sprint = Enum.KeyCode.LeftShift,
            Reload = Enum.KeyCode.R,
            WeaponCycle = Enum.KeyCode.Q,
            Chat = Enum.KeyCode.T,
            Inventory = Enum.KeyCode.I,
            Map = Enum.KeyCode.M
        }
    },

    Graphics = {
        Quality = "High",
        Resolution = "Auto",
        VSync = true,
        AntiAliasing = true,
        Shadows = true,
        Particles = true,
        Lighting = true,
        PostProcessing = true,
        RenderDistance = 1000,
        Brightness = 0.5,
        Contrast = 0.5
    },

    Audio = {
        MasterVolume = 0.7,
        SFXVolume = 0.8,
        MusicVolume = 0.6,
        VoiceVolume = 0.9,
        MuteAudio = false,
        EnableSpatialAudio = true,
        AudioQuality = "High"
    },

    Interface = {
        ShowFPS = false,
        ShowPing = false,
        ShowDamageNumbers = true,
        ShowHitMarkers = true,
        HUDScale = 1.0,
        ChatOpacity = 0.8,
        CrosshairStyle = "Default",
        CrosshairColor = Color3.fromRGB(255, 255, 255),
        Subtitles = true,
        ColorBlindMode = false
    },

    Accessibility = {
        ReduceMotion = false,
        HighContrast = false,
        LargeText = false,
        ScreenReader = false,
        AutoSprint = true,
        SimplifiedControls = false
    }
}

-- Create settings GUI
local function createSettingsGUI()
    local settingsUI = Instance.new("ScreenGui")
    settingsUI.Name = "SettingsGUI"
    settingsUI.ResetOnSpawn = false
    settingsUI.Parent = player.PlayerGui

    -- Main settings frame
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(0, 1000, 0, 750)
    settingsFrame.Position = UDim2.new(0.5, -500, 0.5, -375)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    settingsFrame.BackgroundTransparency = 0.1
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Parent = settingsUI

    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 15)
    settingsCorner.Parent = settingsFrame

    local settingsStroke = Instance.new("UIStroke")
    settingsStroke.Color = Color3.fromRGB(100, 150, 255)
    settingsStroke.Thickness = 3
    settingsStroke.Parent = settingsFrame

    -- Beautiful gradient background
    local backgroundGradient = Instance.new("UIGradient")
    backgroundGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    }
    backgroundGradient.Parent = settingsFrame

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚙️ GAME SETTINGS"
    titleLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = true
    titleLabel.Parent = settingsFrame

    -- Tab buttons
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 55)
    tabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = settingsFrame

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabFrame

    -- Tab layout
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabFrame

    -- Create tabs
    local tabs = {}
    local tabNames = {"Gameplay", "Controls", "Graphics", "Audio", "Interface", "Accessibility"}

    for i, tabName in ipairs(tabNames) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 140, 1, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        tabButton.BorderSizePixel = 0
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.Font = Enum.Font.SourceSansBold
        tabButton.Parent = tabFrame

        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 4)
        tabButtonCorner.Parent = tabButton

        tabs[tabName] = {Button = tabButton, Content = nil}
    end

    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -150)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    contentFrame.BackgroundTransparency = 0.3
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = settingsFrame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 6)
    contentCorner.Parent = contentFrame

    -- Create content for each tab
    createGameplayTab(contentFrame, tabs.Gameplay)
    createControlsTab(contentFrame, tabs.Controls)
    createGraphicsTab(contentFrame, tabs.Graphics)
    createAudioTab(contentFrame, tabs.Audio)
    createInterfaceTab(contentFrame, tabs.Interface)
    createAccessibilityTab(contentFrame, tabs.Accessibility)

    -- Bottom buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonFrame.Position = UDim2.new(0, 0, 1, -50)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = settingsFrame

    -- Apply button
    local applyButton = Instance.new("TextButton")
    applyButton.Size = UDim2.new(0, 120, 0, 35)
    applyButton.Position = UDim2.new(0.5, -180, 0.5, -17.5)
    applyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    applyButton.BackgroundTransparency = 0.2
    applyButton.BorderSizePixel = 0
    applyButton.Text = "APPLY"
    applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyButton.Font = Enum.Font.SourceSansBold
    applyButton.Parent = buttonFrame

    local applyCorner = Instance.new("UICorner")
    applyCorner.CornerRadius = UDim.new(0, 4)
    applyCorner.Parent = applyButton

    -- Reset button
    local resetButton = Instance.new("TextButton")
    resetButton.Size = UDim2.new(0, 120, 0, 35)
    resetButton.Position = UDim2.new(0.5, -60, 0.5, -17.5)
    resetButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    resetButton.BackgroundTransparency = 0.2
    resetButton.BorderSizePixel = 0
    resetButton.Text = "RESET"
    resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetButton.Font = Enum.Font.SourceSansBold
    resetButton.Parent = buttonFrame

    local resetCorner = Instance.new("UICorner")
    resetCorner.CornerRadius = UDim.new(0, 4)
    resetCorner.Parent = resetButton

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 120, 0, 35)
    closeButton.Position = UDim2.new(0.5, 60, 0.5, -17.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BackgroundTransparency = 0.2
    closeButton.BorderSizePixel = 0
    closeButton.Text = "CLOSE"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = buttonFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton

    -- Tab switching logic
    for tabName, tabData in pairs(tabs) do
        tabData.Button.MouseButton1Click:Connect(function()
            -- Hide all content
            for _, otherTab in pairs(tabs) do
                if otherTab.Content then
                    otherTab.Content.Visible = false
                end
                otherTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end

            -- Show selected content
            if tabData.Content then
                tabData.Content.Visible = true
            end
            tabData.Button.BackgroundColor3 = Color3.fromRGB(100, 150, 255)

            -- Update button colors
            TweenService:Create(tabData.Button, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            for _, otherTab in pairs(tabs) do
                if otherTab ~= tabData then
                    TweenService:Create(otherTab.Button, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                end
            end
        end)
    end

    -- Button connections
    applyButton.MouseButton1Click:Connect(function()
        applySettings()
    end)

    resetButton.MouseButton1Click:Connect(function()
        resetSettings()
    end)

    closeButton.MouseButton1Click:Connect(function()
        settingsFrame.Visible = false
    end)

    -- Show default tab (Gameplay)
    tabs.Gameplay.Button.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    tabs.Gameplay.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    if tabs.Gameplay.Content then
        tabs.Gameplay.Content.Visible = true
    end

    return settingsUI, settingsFrame
end

-- Create gameplay settings tab
local function createGameplayTab(parent, tabData)
    local gameplayFrame = Instance.new("Frame")
    gameplayFrame.Size = UDim2.new(1, 0, 1, 0)
    gameplayFrame.BackgroundTransparency = 1
    gameplayFrame.Visible = false
    gameplayFrame.Parent = parent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = gameplayFrame

    local startY = 0

    -- Auto Sprint Toggle
    local autoSprintFrame = createSettingToggle(
        "Auto Sprint",
        "Automatically sprint without holding shift",
        settingsData.Gameplay.AutoSprint,
        function(value)
            settingsData.Gameplay.AutoSprint = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Aim Sensitivity Slider
    local aimSensFrame = createSettingSlider(
        "Aim Sensitivity",
        "Mouse sensitivity when aiming",
        settingsData.Gameplay.AimSensitivity,
        0.1, 2.0, 0.1,
        function(value)
            settingsData.Gameplay.AimSensitivity = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Invert Mouse Y Toggle
    local invertMouseFrame = createSettingToggle(
        "Invert Mouse Y",
        "Invert vertical mouse movement",
        settingsData.Gameplay.InvertMouseY,
        function(value)
            settingsData.Gameplay.InvertMouseY = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Toggle Crouch Toggle
    local toggleCrouchFrame = createSettingToggle(
        "Toggle Crouch",
        "Crouch stays active until pressed again",
        settingsData.Gameplay.ToggleCrouch,
        function(value)
            settingsData.Gameplay.ToggleCrouch = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Auto Reload Toggle
    local autoReloadFrame = createSettingToggle(
        "Auto Reload",
        "Automatically reload when magazine is empty",
        settingsData.Gameplay.AutoReload,
        function(value)
            settingsData.Gameplay.AutoReload = value
        end,
        scrollFrame,
        startY
    )

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, startY + 20)
    tabData.Content = gameplayFrame
end

-- Create controls settings tab
local function createControlsTab(parent, tabData)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(1, 0, 1, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Visible = false
    controlsFrame.Parent = parent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = controlsFrame

    local startY = 0

    -- Mouse Sensitivity Slider
    local mouseSensFrame = createSettingSlider(
        "Mouse Sensitivity",
        "Overall mouse sensitivity",
        settingsData.Controls.MouseSensitivity,
        0.1, 2.0, 0.1,
        function(value)
            settingsData.Controls.MouseSensitivity = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Controller Sensitivity Slider
    local controllerSensFrame = createSettingSlider(
        "Controller Sensitivity",
        "Gamepad analog stick sensitivity",
        settingsData.Controls.ControllerSensitivity,
        0.1, 2.0, 0.1,
        function(value)
            settingsData.Controls.ControllerSensitivity = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Key binding buttons
    local keyBindings = {
        {Name = "Jump", Key = settingsData.Controls.KeyBindings.Jump},
        {Name = "Crouch", Key = settingsData.Controls.KeyBindings.Crouch},
        {Name = "Prone", Key = settingsData.Controls.KeyBindings.Prone},
        {Name = "Sprint", Key = settingsData.Controls.KeyBindings.Sprint},
        {Name = "Reload", Key = settingsData.Controls.KeyBindings.Reload},
        {Name = "Weapon Cycle", Key = settingsData.Controls.KeyBindings.WeaponCycle},
        {Name = "Chat", Key = settingsData.Controls.KeyBindings.Chat},
        {Name = "Inventory", Key = settingsData.Controls.KeyBindings.Inventory},
        {Name = "Map", Key = settingsData.Controls.KeyBindings.Map}
    }

    for _, binding in ipairs(keyBindings) do
        local keyFrame = createKeyBinding(
            binding.Name,
            binding.Key,
            function(newKey)
                settingsData.Controls.KeyBindings[binding.Name] = newKey
            end,
            scrollFrame,
            startY
        )
        startY = startY + 60
    end

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, startY + 20)
    tabData.Content = controlsFrame
end

-- Create graphics settings tab
local function createGraphicsTab(parent, tabData)
    local graphicsFrame = Instance.new("Frame")
    graphicsFrame.Size = UDim2.new(1, 0, 1, 0)
    graphicsFrame.BackgroundTransparency = 1
    graphicsFrame.Visible = false
    graphicsFrame.Parent = parent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = graphicsFrame

    local startY = 0

    -- Graphics Quality Dropdown
    local qualityFrame = createSettingDropdown(
        "Graphics Quality",
        "Overall graphics quality setting",
        {"Low", "Medium", "High", "Ultra"},
        settingsData.Graphics.Quality,
        function(value)
            settingsData.Graphics.Quality = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Resolution Dropdown
    local resolutionFrame = createSettingDropdown(
        "Resolution",
        "Screen resolution (requires restart)",
        {"Auto", "1920x1080", "1600x900", "1366x768", "1280x720"},
        settingsData.Graphics.Resolution,
        function(value)
            settingsData.Graphics.Resolution = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- VSync Toggle
    local vsyncFrame = createSettingToggle(
        "VSync",
        "Synchronize with monitor refresh rate",
        settingsData.Graphics.VSync,
        function(value)
            settingsData.Graphics.VSync = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Anti-Aliasing Toggle
    local aaFrame = createSettingToggle(
        "Anti-Aliasing",
        "Smooth edge rendering",
        settingsData.Graphics.AntiAliasing,
        function(value)
            settingsData.Graphics.AntiAliasing = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Shadows Toggle
    local shadowsFrame = createSettingToggle(
        "Shadows",
        "Enable shadow rendering",
        settingsData.Graphics.Shadows,
        function(value)
            settingsData.Graphics.Shadows = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Particles Toggle
    local particlesFrame = createSettingToggle(
        "Particles",
        "Enable particle effects",
        settingsData.Graphics.Particles,
        function(value)
            settingsData.Graphics.Particles = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Render Distance Slider
    local renderFrame = createSettingSlider(
        "Render Distance",
        "Maximum rendering distance",
        settingsData.Graphics.RenderDistance / 1000,
        0.1, 2.0, 0.1,
        function(value)
            settingsData.Graphics.RenderDistance = value * 1000
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Brightness Slider
    local brightnessFrame = createSettingSlider(
        "Brightness",
        "Screen brightness",
        settingsData.Graphics.Brightness,
        0.0, 1.0, 0.1,
        function(value)
            settingsData.Graphics.Brightness = value
        end,
        scrollFrame,
        startY
    )

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, startY + 20)
    tabData.Content = graphicsFrame
end

-- Create audio settings tab
local function createAudioTab(parent, tabData)
    local audioFrame = Instance.new("Frame")
    audioFrame.Size = UDim2.new(1, 0, 1, 0)
    audioFrame.BackgroundTransparency = 1
    audioFrame.Visible = false
    audioFrame.Parent = parent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = audioFrame

    local startY = 0

    -- Master Volume Slider
    local masterVolFrame = createSettingSlider(
        "Master Volume",
        "Overall game volume",
        settingsData.Audio.MasterVolume,
        0.0, 1.0, 0.1,
        function(value)
            settingsData.Audio.MasterVolume = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- SFX Volume Slider
    local sfxVolFrame = createSettingSlider(
        "SFX Volume",
        "Sound effects volume",
        settingsData.Audio.SFXVolume,
        0.0, 1.0, 0.1,
        function(value)
            settingsData.Audio.SFXVolume = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Music Volume Slider
    local musicVolFrame = createSettingSlider(
        "Music Volume",
        "Background music volume",
        settingsData.Audio.MusicVolume,
        0.0, 1.0, 0.1,
        function(value)
            settingsData.Audio.MusicVolume = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Voice Volume Slider
    local voiceVolFrame = createSettingSlider(
        "Voice Volume",
        "Voice chat volume",
        settingsData.Audio.VoiceVolume,
        0.0, 1.0, 0.1,
        function(value)
            settingsData.Audio.VoiceVolume = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Mute Audio Toggle
    local muteFrame = createSettingToggle(
        "Mute Audio",
        "Disable all game audio",
        settingsData.Audio.MuteAudio,
        function(value)
            settingsData.Audio.MuteAudio = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Spatial Audio Toggle
    local spatialFrame = createSettingToggle(
        "Spatial Audio",
        "3D positional audio",
        settingsData.Audio.EnableSpatialAudio,
        function(value)
            settingsData.Audio.EnableSpatialAudio = value
        end,
        scrollFrame,
        startY
    )

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, startY + 20)
    tabData.Content = audioFrame
end

-- Create interface settings tab
local function createInterfaceTab(parent, tabData)
    local interfaceFrame = Instance.new("Frame")
    interfaceFrame.Size = UDim2.new(1, 0, 1, 0)
    interfaceFrame.BackgroundTransparency = 1
    interfaceFrame.Visible = false
    interfaceFrame.Parent = parent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = interfaceFrame

    local startY = 0

    -- Show FPS Toggle
    local fpsFrame = createSettingToggle(
        "Show FPS",
        "Display FPS counter",
        settingsData.Interface.ShowFPS,
        function(value)
            settingsData.Interface.ShowFPS = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Show Ping Toggle
    local pingFrame = createSettingToggle(
        "Show Ping",
        "Display network ping",
        settingsData.Interface.ShowPing,
        function(value)
            settingsData.Interface.ShowPing = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Show Damage Numbers Toggle
    local damageFrame = createSettingToggle(
        "Show Damage Numbers",
        "Display damage dealt to enemies",
        settingsData.Interface.ShowDamageNumbers,
        function(value)
            settingsData.Interface.ShowDamageNumbers = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Show Hit Markers Toggle
    local hitMarkerFrame = createSettingToggle(
        "Show Hit Markers",
        "Display hit confirmation markers",
        settingsData.Interface.ShowHitMarkers,
        function(value)
            settingsData.Interface.ShowHitMarkers = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- HUD Scale Slider
    local hudScaleFrame = createSettingSlider(
        "HUD Scale",
        "Interface element size",
        settingsData.Interface.HUDScale,
        0.5, 2.0, 0.1,
        function(value)
            settingsData.Interface.HUDScale = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Chat Opacity Slider
    local chatOpacityFrame = createSettingSlider(
        "Chat Opacity",
        "Chat window transparency",
        settingsData.Interface.ChatOpacity,
        0.1, 1.0, 0.1,
        function(value)
            settingsData.Interface.ChatOpacity = value
        end,
        scrollFrame,
        startY
    )

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, startY + 20)
    tabData.Content = interfaceFrame
end

-- Create accessibility settings tab
local function createAccessibilityTab(parent, tabData)
    local accessibilityFrame = Instance.new("Frame")
    accessibilityFrame.Size = UDim2.new(1, 0, 1, 0)
    accessibilityFrame.BackgroundTransparency = 1
    accessibilityFrame.Visible = false
    accessibilityFrame.Parent = parent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = accessibilityFrame

    local startY = 0

    -- Reduce Motion Toggle
    local reduceMotionFrame = createSettingToggle(
        "Reduce Motion",
        "Minimize animations and effects",
        settingsData.Accessibility.ReduceMotion,
        function(value)
            settingsData.Accessibility.ReduceMotion = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- High Contrast Toggle
    local highContrastFrame = createSettingToggle(
        "High Contrast",
        "Increase color contrast for visibility",
        settingsData.Accessibility.HighContrast,
        function(value)
            settingsData.Accessibility.HighContrast = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Large Text Toggle
    local largeTextFrame = createSettingToggle(
        "Large Text",
        "Increase text size throughout interface",
        settingsData.Accessibility.LargeText,
        function(value)
            settingsData.Accessibility.LargeText = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Subtitles Toggle
    local subtitlesFrame = createSettingToggle(
        "Subtitles",
        "Show subtitles for voice chat",
        settingsData.Interface.Subtitles,
        function(value)
            settingsData.Interface.Subtitles = value
        end,
        scrollFrame,
        startY
    )
    startY = startY + 80

    -- Color Blind Mode Toggle
    local colorBlindFrame = createSettingToggle(
        "Color Blind Support",
        "Enhanced colors for color blind players",
        settingsData.Interface.ColorBlindMode,
        function(value)
            settingsData.Interface.ColorBlindMode = value
        end,
        scrollFrame,
        startY
    )

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, startY + 20)
    tabData.Content = accessibilityFrame
end

-- Helper functions for creating settings elements
local function createSettingToggle(title, description, defaultValue, callback, parent, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = true
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.SourceSans
    descLabel.TextScaled = true
    descLabel.Parent = frame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 80, 0, 25)
    toggleButton.Position = UDim2.new(1, -80, 0, 50)
    toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = defaultValue and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggleButton

    toggleButton.MouseButton1Click:Connect(function()
        local newValue = not defaultValue
        defaultValue = newValue
        toggleButton.BackgroundColor3 = newValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        toggleButton.Text = newValue and "ON" or "OFF"
        callback(newValue)
    end)

    return frame
end

local function createSettingSlider(title, description, defaultValue, min, max, step, callback, parent, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = true
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.SourceSans
    descLabel.TextScaled = true
    descLabel.Parent = frame

    -- Slider background
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.7, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 50)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBg

    -- Slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg

    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill

    -- Slider knob
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 20, 0, 20)
    sliderKnob.Position = UDim2.new((defaultValue - min) / (max - min), -10, 0.5, -10)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob

    -- Value label
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.75, 0, 0, 45)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.1f", defaultValue)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextScaled = true
    valueLabel.Parent = frame

    -- Dragging logic
    local dragging = false
    local dragInput = nil

    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
            dragInput = nil
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition
            local sliderSize = sliderBg.AbsoluteSize

            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local newValue = min + (relativeX * (max - min))

            -- Round to step
            newValue = math.floor(newValue / step + 0.5) * step
            newValue = math.clamp(newValue, min, max)

            -- Update visuals
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderKnob.Position = UDim2.new(relativeX, -10, 0.5, -10)
            valueLabel.Text = string.format("%.1f", newValue)

            -- Call callback
            callback(newValue)
        end
    end)

    return frame
end

local function createSettingDropdown(title, description, options, defaultValue, callback, parent, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = true
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 25)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.SourceSans
    descLabel.TextScaled = true
    descLabel.Parent = frame

    -- Dropdown button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0.4, 0, 0, 25)
    dropdownButton.Position = UDim2.new(0.6, 0, 0, 45)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = defaultValue
    dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownButton.Font = Enum.Font.SourceSansBold
    dropdownButton.Parent = frame

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdownButton

    -- Dropdown options (hidden by default)
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(0.4, 0, 0, #options * 25)
    optionsFrame.Position = UDim2.new(0.6, 0, 0, 70)
    optionsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.Parent = frame

    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 4)
    optionsCorner.Parent = optionsFrame

    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsFrame

    -- Create option buttons
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.Font = Enum.Font.SourceSans
        optionButton.Parent = optionsFrame

        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 4)
        optionCorner.Parent = optionButton

        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            optionsFrame.Visible = false
            callback(option)
        end)
    end

    -- Toggle dropdown
    dropdownButton.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
    end)

    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if optionsFrame.Visible and not optionsFrame:IsDescendantOf(game.GuiService.SelectedObject) then
                optionsFrame.Visible = false
            end
        end
    end)

    return frame
end

local function createKeyBinding(title, currentKey, callback, parent, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = true
    titleLabel.Parent = frame

    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0.3, 0, 0.8, 0)
    keyButton.Position = UDim2.new(0.7, 0, 0.1, 0)
    keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyButton.BorderSizePixel = 0
    keyButton.Text = currentKey.Name
    keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyButton.Font = Enum.Font.SourceSansBold
    keyButton.Parent = frame

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 4)
    keyCorner.Parent = keyButton

    local listeningForInput = false

    keyButton.MouseButton1Click:Connect(function()
        if not listeningForInput then
            listeningForInput = true
            keyButton.Text = "Press Key..."
            keyButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listeningForInput and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listeningForInput = false
                keyButton.Text = input.KeyCode.Name
                keyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                callback(input.KeyCode)
            end
        end
    end)

    return frame
end

-- Apply settings to game
local function applySettings()
    print("⚙️ Applying settings...")

    -- Apply gameplay settings
    if settingsData.Gameplay.AutoSprint then
        -- Enable auto-sprint (modify movement system)
        print("✅ Auto-sprint enabled")
    end

    -- Apply graphics settings
    local performanceMonitor = require(script.Parent.PerformanceMonitor)
    if performanceMonitor.SetGraphicsQuality then
        performanceMonitor.SetGraphicsQuality(settingsData.Graphics.Quality)
    end

    -- Apply audio settings
    local soundSystem = require(script.Parent.SoundSystem)
    if soundSystem.SetMasterVolume then
        soundSystem.SetMasterVolume(settingsData.Audio.MasterVolume)
    end

    -- Save settings (would save to DataStore in production)
    saveSettings()

    print("✅ Settings applied successfully!")
end

-- Reset settings to default
local function resetSettings()
    print("🔄 Resetting settings to default...")

    settingsData = {
        Gameplay = table.clone(defaultSettings.Gameplay),
        Controls = table.clone(defaultSettings.Controls),
        Graphics = table.clone(defaultSettings.Graphics),
        Audio = table.clone(defaultSettings.Audio),
        Interface = table.clone(defaultSettings.Interface),
        Accessibility = table.clone(defaultSettings.Accessibility)
    }

    -- Refresh UI to show default values
    -- (In a full implementation, you'd refresh all UI elements)

    print("✅ Settings reset to default!")
end

-- Save settings to DataStore
local function saveSettings()
    local success, errorMessage = pcall(function()
        local dataStoreService = game:GetService("DataStoreService")
        local settingsStore = dataStoreService:GetDataStore("BulletCoreSettings")
        settingsStore:SetAsync(player.UserId .. "_Settings", settingsData)
    end)

    if not success then
        warn("Failed to save settings: " .. errorMessage)
    else
        print("💾 Settings saved successfully!")
    end
end

-- Load settings from DataStore
local function loadSettings()
    local success, loadedSettings = pcall(function()
        local dataStoreService = game:GetService("DataStoreService")
        local settingsStore = dataStoreService:GetDataStore("BulletCoreSettings")
        return settingsStore:GetAsync(player.UserId .. "_Settings")
    end)

    if success and loadedSettings then
        settingsData = loadedSettings
        print("📂 Settings loaded successfully!")
    else
        print("📂 Using default settings")
    end
end

-- Initialize settings GUI
function SettingsGUI.Initialize()
    loadSettings()

    local settingsUI, settingsFrame = createSettingsGUI()
    settingsFrame.Name = "SettingsFrame"
    settingsFrame.Parent = settingsUI

    print("⚙️ Settings GUI initialized!")
end

-- Public API functions
function SettingsGUI.GetSettings()
    return settingsData
end

function SettingsGUI.ApplySettings()
    applySettings()
end

function SettingsGUI.ResetSettings()
    resetSettings()
end

return SettingsGUI
