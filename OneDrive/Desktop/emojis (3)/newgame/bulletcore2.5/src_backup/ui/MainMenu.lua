-- BULLETCORE 2 - Call of Duty Style Main Menu
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove any existing duplicate menus
local existingMenu = playerGui:FindFirstChild("BulletCoreMenu")
if existingMenu then
    existingMenu:Destroy()
end

-- Create Main Menu GUI
local menuGui = Instance.new("ScreenGui")
menuGui.Name = "BulletCoreMenu"
menuGui.ResetOnSpawn = false
menuGui.Parent = playerGui

-- Main Container
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainFrame"
menuFrame.Size = UDim2.new(1, 0, 1, 0)
menuFrame.Position = UDim2.new(0, 0, 0, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
menuFrame.BorderSizePixel = 0
menuFrame.Parent = menuGui

-- Tactical Background Pattern
local backgroundPattern = Instance.new("Frame")
backgroundPattern.Size = UDim2.new(1, 0, 1, 0)
backgroundPattern.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
backgroundPattern.BorderSizePixel = 0
backgroundPattern.Parent = menuFrame

-- Hexagonal pattern overlay
for i = 1, 50 do
    local hex = Instance.new("Frame")
    hex.Size = UDim2.new(0, 80, 0, 80)
    hex.Position = UDim2.new(0, math.random(0, 1920), 0, math.random(0, 1080))
    hex.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    hex.BackgroundTransparency = 0.8
    hex.BorderSizePixel = 0
    hex.Rotation = 30
    hex.Parent = backgroundPattern

    local hexCorner = Instance.new("UICorner")
    hexCorner.CornerRadius = UDim.new(0, 10)
    hexCorner.Parent = hex
end

-- Animated Scan Lines
local scanLines = Instance.new("Frame")
scanLines.Size = UDim2.new(1, 0, 0, 2)
scanLines.Position = UDim2.new(0, 0, 0, 0)
scanLines.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
scanLines.BackgroundTransparency = 0.8
scanLines.BorderSizePixel = 0
scanLines.Parent = menuFrame

-- Animate scan lines
RunService.Heartbeat:Connect(function()
    scanLines.Position = UDim2.new(0, 0, 0, (tick() * 100) % 1080 / 1080)
end)

-- Title Section
local titleSection = Instance.new("Frame")
titleSection.Size = UDim2.new(1, 0, 0, 200)
titleSection.Position = UDim2.new(0, 0, 0.1, 0)
titleSection.BackgroundTransparency = 1
titleSection.Parent = menuFrame

-- Main Title
local mainTitle = Instance.new("TextLabel")
mainTitle.Size = UDim2.new(0, 800, 0, 80)
mainTitle.Position = UDim2.new(0.5, -400, 0, 0)
mainTitle.BackgroundTransparency = 1
mainTitle.Text = "BULLETCORE 2"
mainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTitle.TextScaled = true
mainTitle.Font = Enum.Font.SourceSansBold
mainTitle.TextStrokeTransparency = 0
mainTitle.TextStrokeColor3 = Color3.fromRGB(255, 150, 0)
mainTitle.Parent = titleSection

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 600, 0, 30)
subtitle.Position = UDim2.new(0.5, -300, 0, 90)
subtitle.BackgroundTransparency = 1
subtitle.Text = "TACTICAL FAST-PACED SHOOTER"
subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.SourceSans
subtitle.Parent = titleSection

-- Version
local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 100, 0, 20)
versionLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v2.0.0"
versionLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
versionLabel.Font = Enum.Font.SourceSans
versionLabel.Parent = menuFrame

-- Menu Buttons Container
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0, 400, 0, 350)
buttonContainer.Position = UDim2.new(0.5, -200, 0.45, 0)
buttonContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
buttonContainer.BackgroundTransparency = 0.5
buttonContainer.BorderSizePixel = 0
buttonContainer.Parent = menuFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = buttonContainer

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(255, 150, 0)
buttonStroke.Thickness = 2
buttonStroke.Parent = buttonContainer

-- Button Layout
local buttonLayout = Instance.new("UIListLayout")
buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
buttonLayout.Padding = UDim.new(0, 15)
buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
buttonLayout.Parent = buttonContainer

-- Create Tactical Button Function
local function createTacticalButton(text, description, color, callback)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -20, 0, 70)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = buttonContainer

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 50)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.SourceSansBold
    button.Parent = buttonFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button

    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(color.R * 255 - 40, color.G * 255 - 40, color.B * 255 - 40))
    }
    buttonGradient.Parent = button

    -- Button glow effect
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = 0.7
    glow.BorderSizePixel = 0
    glow.ZIndex = button.ZIndex - 1
    glow.Parent = buttonFrame

    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 10)
    glowCorner.Parent = glow

    -- Description label
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 15)
    descLabel.Position = UDim2.new(0, 0, 0, 55)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.SourceSans
    descLabel.TextScaled = true
    descLabel.Parent = buttonFrame

    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 55)}):Play()
        TweenService:Create(glow, TweenInfo.new(0.3), {BackgroundTransparency = 0.4}):Play()
        TweenService:Create(button, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 0)}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 50)}):Play()
        TweenService:Create(glow, TweenInfo.new(0.3), {BackgroundTransparency = 0.7}):Play()
        TweenService:Create(button, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end)

    button.MouseButton1Click:Connect(callback)

    return button
end

-- Create Tactical Buttons
createTacticalButton("▶ PLAY", "Create character and enter game", Color3.fromRGB(0, 150, 0), function()
    -- First show character creation
    local characterCreatorGui = playerGui:FindFirstChild("CharacterCreator")
    if characterCreatorGui and characterCreatorGui:FindFirstChild("MainFrame") then
        characterCreatorGui.MainFrame.Visible = true
        menuFrame.Visible = false
    else
        warn("Character Creator GUI not found!")
    end
end)

createTacticalButton("🛒 SHOP", "Browse and purchase weapons", Color3.fromRGB(150, 100, 0), function()
    local shopGui = playerGui:FindFirstChild("ShopGUI")
    if shopGui and shopGui:FindFirstChild("ShopFrame") then
        shopGui.ShopFrame.Visible = true
        menuFrame.Visible = false
    else
        warn("Shop GUI not found!")
    end
end)

createTacticalButton("⚙️ SETTINGS", "Configure game options", Color3.fromRGB(0, 100, 150), function()
    local settingsGui = playerGui:FindFirstChild("SettingsGUI")
    if settingsGui and settingsGui:FindFirstChild("SettingsFrame") then
        settingsGui.SettingsFrame.Visible = true
        menuFrame.Visible = false
    else
        warn("Settings GUI not found!")
    end
end)

createTacticalButton("🎁 DAILY REWARDS", "Claim daily bonuses", Color3.fromRGB(255, 150, 0), function()
    local rewardsGui = playerGui:FindFirstChild("DailyRewards")
    if rewardsGui and rewardsGui:FindFirstChild("MainFrame") then
        rewardsGui.MainFrame.Visible = true
        menuFrame.Visible = false
    else
        warn("Daily Rewards GUI not found!")
    end
end)

createTacticalButton("🏆 LEADERBOARD", "View top players", Color3.fromRGB(150, 0, 150), function()
    showLeaderboard()
end)

createTacticalButton("👑 ADMIN PANEL", "Server management (Admin Only)", Color3.fromRGB(255, 0, 0), function()
    -- Check if player is admin before showing panel
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        local checkAdminRemote = remoteEvents:FindFirstChild("CheckAdminStatus")
        if checkAdminRemote then
            checkAdminRemote:FireServer()
        end
    end
end)

createTacticalButton("🎮 CONTROLS", "View input mappings and gameplay", Color3.fromRGB(50, 150, 100), function()
    showControlsMenu()
end)

createTacticalButton(" CLANS", "Create or join clans", Color3.fromRGB(100, 50, 150), function()
    local clanGui = playerGui:FindFirstChild("ClanGUI")
    if clanGui and clanGui:FindFirstChild("MainFrame") then
        clanGui.MainFrame.Visible = true
        menuFrame.Visible = false
    else
        warn("Clan GUI not found!")
    end
end)

-- Bottom Status Bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 40)
statusBar.Position = UDim2.new(0, 0, 1, -40)
statusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusBar.BorderSizePixel = 0
statusBar.Parent = menuFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusBar

-- Player count
local playerCount = Instance.new("TextLabel")
playerCount.Size = UDim2.new(0, 200, 1, 0)
playerCount.Position = UDim2.new(0.02, 0, 0, 0)
playerCount.BackgroundTransparency = 1
playerCount.Text = "OPERATORS ONLINE: " .. #Players:GetPlayers()
playerCount.TextColor3 = Color3.fromRGB(0, 255, 0)
playerCount.Font = Enum.Font.SourceSansBold
playerCount.Parent = statusBar

-- Server info
local serverInfo = Instance.new("TextLabel")
serverInfo.Size = UDim2.new(0, 300, 1, 0)
serverInfo.Position = UDim2.new(0.98, -300, 0, 0)
serverInfo.BackgroundTransparency = 1
serverInfo.Text = "BULLETCORE 2 - TACTICAL OPS"
serverInfo.TextColor3 = Color3.fromRGB(255, 150, 0)
serverInfo.Font = Enum.Font.SourceSansBold
serverInfo.Parent = statusBar

-- Show menu on spawn
player.CharacterAdded:Connect(function()
    wait(1)
    menuFrame.Visible = true

    -- Update player count
    playerCount.Text = "OPERATORS ONLINE: " .. #Players:GetPlayers()
end)

-- Update player count periodically
RunService.Heartbeat:Connect(function()
    playerCount.Text = "OPERATORS ONLINE: " .. #Players:GetPlayers()
end)

-- Controls Menu Function
local function showControlsMenu()
    -- Create controls overlay
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 800, 0, 600)
    controlsFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    controlsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    controlsFrame.BackgroundTransparency = 0.2
    controlsFrame.BorderSizePixel = 0
    controlsFrame.Parent = menuGui

    local controlsCorner = Instance.new("UICorner")
    controlsCorner.CornerRadius = UDim.new(0, 10)
    controlsCorner.Parent = controlsFrame

    local controlsStroke = Instance.new("UIStroke")
    controlsStroke.Color = Color3.fromRGB(50, 150, 100)
    controlsStroke.Thickness = 2
    controlsStroke.Parent = controlsFrame

    -- Controls title
    local controlsTitle = Instance.new("TextLabel")
    controlsTitle.Size = UDim2.new(1, 0, 0, 50)
    controlsTitle.Position = UDim2.new(0, 0, 0, 0)
    controlsTitle.BackgroundTransparency = 1
    controlsTitle.Text = "🎮 GAME CONTROLS"
    controlsTitle.TextColor3 = Color3.fromRGB(50, 150, 100)
    controlsTitle.Font = Enum.Font.SourceSansBold
    controlsTitle.TextScaled = true
    controlsTitle.Parent = controlsFrame

    -- Controls scroll frame
    local controlsScroll = Instance.new("ScrollingFrame")
    controlsScroll.Size = UDim2.new(1, -20, 1, -100)
    controlsScroll.Position = UDim2.new(0, 10, 0, 60)
    controlsScroll.BackgroundTransparency = 1
    controlsScroll.ScrollBarThickness = 8
    controlsScroll.Parent = controlsFrame

    -- Control categories
    local controlSections = {
        {
            Title = "🎯 Combat Controls",
            Color = Color3.fromRGB(255, 100, 100),
            Controls = {
                {"Left Click / 🔫 Button", "Fire weapon"},
                {"R Key", "Reload weapon"},
                {"Right Click", "Aim down sights"},
                {"Q Key", "Cycle weapons"},
                {"1-4 Keys", "Quick weapon switch"}
            }
        },
        {
            Title = "🏃 Movement Controls",
            Color = Color3.fromRGB(100, 255, 100),
            Controls = {
                {"WASD Keys", "Move character"},
                {"Spacebar / ⬆️ Button", "Jump"},
                {"Left Shift", "Sprint"},
                {"Left Ctrl", "Crouch"},
                {"C Key", "Prone"}
            }
        },
        {
            Title = "📱 Mobile Controls",
            Color = Color3.fromRGB(100, 150, 255),
            Controls = {
                {"Left Joystick", "Movement"},
                {"Right Joystick", "Camera look"},
                {"🔫 Button", "Shoot"},
                {"🔄 Button", "Reload"},
                {"⬆️ Button", "Jump"}
            }
        },
        {
            Title = "🎮 Interface Controls",
            Color = Color3.fromRGB(255, 255, 100),
            Controls = {
                {"Tab / ESC", "Toggle menu"},
                {"F3 Key", "Performance monitor"},
                {"I Key", "Inventory"},
                {"M Key", "Map"},
                {"T Key", "Chat"}
            }
        }
    }

    local startY = 0
    for _, section in ipairs(controlSections) do
        -- Section title
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Size = UDim2.new(1, 0, 0, 30)
        sectionTitle.Position = UDim2.new(0, 0, 0, startY)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = section.Title
        sectionTitle.TextColor3 = section.Color
        sectionTitle.Font = Enum.Font.SourceSansBold
        sectionTitle.TextScaled = true
        sectionTitle.Parent = controlsScroll

        startY = startY + 35

        -- Section controls
        for _, control in ipairs(section.Controls) do
            local controlFrame = Instance.new("Frame")
            controlFrame.Size = UDim2.new(1, 0, 0, 25)
            controlFrame.Position = UDim2.new(0, 0, 0, startY)
            controlFrame.BackgroundTransparency = 1
            controlFrame.Parent = controlsScroll

            local controlInput = Instance.new("TextLabel")
            controlInput.Size = UDim2.new(0.4, 0, 1, 0)
            controlInput.Position = UDim2.new(0, 0, 0, 0)
            controlInput.BackgroundTransparency = 1
            controlInput.Text = control[1]
            controlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            controlInput.Font = Enum.Font.SourceSansBold
            controlInput.TextScaled = true
            controlInput.Parent = controlFrame

            local controlDesc = Instance.new("TextLabel")
            controlDesc.Size = UDim2.new(0.6, 0, 1, 0)
            controlDesc.Position = UDim2.new(0.4, 0, 0, 0)
            controlDesc.BackgroundTransparency = 1
            controlDesc.Text = control[2]
            controlDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
            controlDesc.Font = Enum.Font.SourceSans
            controlDesc.TextScaled = true
            controlDesc.Parent = controlFrame

            startY = startY + 30
        end

        startY = startY + 10 -- Extra spacing between sections
    end

    controlsScroll.CanvasSize = UDim2.new(0, 0, 0, startY)

    -- Close button
    local closeControlsButton = Instance.new("TextButton")
    closeControlsButton.Size = UDim2.new(0, 150, 0, 40)
    closeControlsButton.Position = UDim2.new(0.5, -75, 1, -35)
    closeControlsButton.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
    closeControlsButton.BackgroundTransparency = 0.2
    closeControlsButton.BorderSizePixel = 0
    closeControlsButton.Text = "BACK TO MENU"
    closeControlsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeControlsButton.Font = Enum.Font.SourceSansBold
    closeControlsButton.Parent = controlsFrame

    local closeControlsCorner = Instance.new("UICorner")
    closeControlsCorner.CornerRadius = UDim.new(0, 6)
    closeControlsCorner.Parent = closeControlsButton

    closeControlsButton.MouseButton1Click:Connect(function()
        controlsFrame:Destroy()
    end)

    -- Close with ESC
    local function closeControls()
        if controlsFrame.Parent then
            controlsFrame:Destroy()
        end
    end

    -- Override ESC to close controls instead of main menu
    local originalESC = UserInputService.InputBegan:Connect(function() end) -- Disconnect original
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.Escape then
            closeControls()
        end
    end)
end

-- Apply responsive scaling to menu elements
local function applyResponsiveScaling()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local scaleFactor = math.min(screenSize.X / 1920, screenSize.Y / 1080)

    -- Scale main elements based on screen size
    if scaleFactor < 0.8 then -- Smaller screens
        buttonContainer.Size = UDim2.new(0, 300 * scaleFactor, 0, 250 * scaleFactor)
        buttonContainer.Position = UDim2.new(0.5, -150 * scaleFactor, 0.45, 0)

        titleSection.Size = UDim2.new(1, 0, 0, 150 * scaleFactor)
        titleSection.Position = UDim2.new(0, 0, 0.1, 0)

        mainTitle.Size = UDim2.new(0, 600 * scaleFactor, 0, 60 * scaleFactor)
        mainTitle.Position = UDim2.new(0.5, -300 * scaleFactor, 0, 0)

        subtitle.Size = UDim2.new(0, 450 * scaleFactor, 0, 20 * scaleFactor)
        subtitle.Position = UDim2.new(0.5, -225 * scaleFactor, 0, 70 * scaleFactor)
    end

    -- Adjust button sizes for mobile
    if UserInputService.TouchEnabled then
        buttonContainer.Size = UDim2.new(0, 350, 0, 400)
        buttonContainer.Position = UDim2.new(0.5, -175, 0.4, 0)

        for _, buttonFrame in ipairs(buttonContainer:GetChildren()) do
            if buttonFrame:IsA("Frame") and buttonFrame:FindFirstChild("TextButton") then
                local button = buttonFrame.TextButton
                button.Size = UDim2.new(1, 0, 0, 60) -- Larger buttons for touch
            end
        end
    end
end

-- Apply scaling on initialization and screen resize
applyResponsiveScaling()
UserInputService:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveScaling)

-- Toggle menu with ESC or TAB
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Tab then
        menuFrame.Visible = not menuFrame.Visible
    end
end)

-- Leaderboard function
local function showLeaderboard()
    -- Create leaderboard overlay
    local leaderboardFrame = Instance.new("Frame")
    leaderboardFrame.Size = UDim2.new(0, 700, 0, 500)
    leaderboardFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    leaderboardFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    leaderboardFrame.BackgroundTransparency = 0.2
    leaderboardFrame.BorderSizePixel = 0
    leaderboardFrame.Parent = menuGui

    local leaderboardCorner = Instance.new("UICorner")
    leaderboardCorner.CornerRadius = UDim.new(0, 10)
    leaderboardCorner.Parent = leaderboardFrame

    local leaderboardStroke = Instance.new("UIStroke")
    leaderboardStroke.Color = Color3.fromRGB(150, 0, 150)
    leaderboardStroke.Thickness = 2
    leaderboardStroke.Parent = leaderboardFrame

    -- Leaderboard title
    local leaderboardTitle = Instance.new("TextLabel")
    leaderboardTitle.Size = UDim2.new(1, 0, 0, 50)
    leaderboardTitle.Position = UDim2.new(0, 0, 0, 0)
    leaderboardTitle.BackgroundTransparency = 1
    leaderboardTitle.Text = "🏆 LEADERBOARD"
    leaderboardTitle.TextColor3 = Color3.fromRGB(150, 0, 150)
    leaderboardTitle.Font = Enum.Font.SourceSansBold
    leaderboardTitle.TextScaled = true
    leaderboardTitle.Parent = leaderboardFrame

    -- Loading text
    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Size = UDim2.new(1, 0, 0, 100)
    loadingLabel.Position = UDim2.new(0, 0, 0.2, 0)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Text = "Loading leaderboard...\nComing Soon!"
    loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingLabel.Font = Enum.Font.SourceSansBold
    loadingLabel.TextScaled = true
    loadingLabel.Parent = leaderboardFrame

    -- Close button
    local closeLeaderboardButton = Instance.new("TextButton")
    closeLeaderboardButton.Size = UDim2.new(0, 150, 0, 40)
    closeLeaderboardButton.Position = UDim2.new(0.5, -75, 1, -50)
    closeLeaderboardButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    closeLeaderboardButton.BackgroundTransparency = 0.2
    closeLeaderboardButton.BorderSizePixel = 0
    closeLeaderboardButton.Text = "CLOSE"
    closeLeaderboardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeLeaderboardButton.Font = Enum.Font.SourceSansBold
    closeLeaderboardButton.Parent = leaderboardFrame

    local closeLeaderboardCorner = Instance.new("UICorner")
    closeLeaderboardCorner.CornerRadius = UDim.new(0, 6)
    closeLeaderboardCorner.Parent = closeLeaderboardButton

    closeLeaderboardButton.MouseButton1Click:Connect(function()
        leaderboardFrame:Destroy()
    end)
end

-- Unstuck function for settings
local function createUnstuckButton()
    local unstuckButton = Instance.new("TextButton")
    unstuckButton.Size = UDim2.new(0, 120, 0, 30)
    unstuckButton.Position = UDim2.new(0.02, 0, 0.02, 0)
    unstuckButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    unstuckButton.BackgroundTransparency = 0.3
    unstuckButton.BorderSizePixel = 0
    unstuckButton.Text = "🚨 UNSTUCK"
    unstuckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    unstuckButton.Font = Enum.Font.SourceSansBold
    unstuckButton.Parent = menuFrame

    local unstuckCorner = Instance.new("UICorner")
    unstuckCorner.CornerRadius = UDim.new(0, 4)
    unstuckCorner.Parent = unstuckButton

    -- Glow effect for visibility
    local unstuckGlow = Instance.new("Frame")
    unstuckGlow.Size = UDim2.new(1, 6, 1, 6)
    unstuckGlow.Position = UDim2.new(0, -3, 0, -3)
    unstuckGlow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    unstuckGlow.BackgroundTransparency = 0.6
    unstuckGlow.BorderSizePixel = 0
    unstuckGlow.ZIndex = unstuckButton.ZIndex - 1
    unstuckGlow.Parent = menuFrame

    local unstuckGlowCorner = Instance.new("UICorner")
    unstuckGlowCorner.CornerRadius = UDim.new(0, 6)
    unstuckGlowCorner.Parent = unstuckGlow

    -- Pulsing animation
    RunService.Heartbeat:Connect(function()
        local pulse = math.sin(tick() * 3) * 0.3 + 0.7
        unstuckGlow.BackgroundTransparency = 0.6 + (pulse * 0.2)
    end)

    unstuckButton.MouseButton1Click:Connect(function()
        -- Force close all GUIs and reset player position
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= menuGui then
                gui:Destroy()
            end
        end

        -- Reset character position if stuck
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end

        -- Show success message
        local successFrame = Instance.new("Frame")
        successFrame.Size = UDim2.new(0, 300, 0, 100)
        successFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
        successFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        successFrame.BorderSizePixel = 0
        successFrame.Parent = menuGui

        local successCorner = Instance.new("UICorner")
        successCorner.CornerRadius = UDim.new(0, 8)
        successCorner.Parent = successFrame

        local successText = Instance.new("TextLabel")
        successText.Size = UDim2.new(1, 0, 1, 0)
        successText.BackgroundTransparency = 1
        successText.Text = "✅ UNSTUCK!\nAll GUIs reset and\nposition restored!"
        successText.TextColor3 = Color3.fromRGB(255, 255, 255)
        successText.Font = Enum.Font.SourceSansBold
        successText.TextScaled = true
        successText.Parent = successFrame

        wait(2)
        successFrame:Destroy()
    end)

    return unstuckButton
end

-- Create the unstuck button
local unstuckButton = createUnstuckButton()

-- Initialize
menuFrame.Visible = true
print("🎮 BULLETCORE 2 Main Menu loaded successfully!")
