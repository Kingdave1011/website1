-- Advanced Admin Panel UI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local AdminPanel = {}
AdminPanel.IsVisible = false
AdminPanel.IsAdmin = false

-- Create admin panel GUI
function AdminPanel.Create()
    -- Remove existing panel
    local existingPanel = playerGui:FindFirstChild("AdminPanel")
    if existingPanel then
        existingPanel:Destroy()
    end

    local adminGui = Instance.new("ScreenGui")
    adminGui.Name = "AdminPanel"
    adminGui.ResetOnSpawn = false
    adminGui.Parent = playerGui

    -- Main panel frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 900, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = adminGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 150, 0)
    mainStroke.Thickness = 3
    mainStroke.Parent = mainFrame

    -- Animated background pattern
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    background.BorderSizePixel = 0
    background.Parent = mainFrame

    -- Hexagonal pattern
    for i = 1, 30 do
        local hex = Instance.new("Frame")
        hex.Size = UDim2.new(0, 40, 0, 40)
        hex.Position = UDim2.new(0, math.random(0, 900), 0, math.random(0, 600))
        hex.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        hex.BackgroundTransparency = 0.8
        hex.BorderSizePixel = 0
        hex.Rotation = 30
        hex.Parent = background

        local hexCorner = Instance.new("UICorner")
        hexCorner.CornerRadius = UDim.new(0, 6)
        hexCorner.Parent = hex
    end

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 60)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleBarGradient = Instance.new("UIGradient")
    titleBarGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 80, 0))
    }
    titleBarGradient.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 300, 0, 40)
    title.Position = UDim2.new(0.02, 0, 0.1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ ADMIN CONTROL PANEL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = titleBar

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(0.96, 0, 0.1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextScaled = true
    closeButton.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    -- Player list section
    local playerListFrame = Instance.new("Frame")
    playerListFrame.Size = UDim2.new(0, 350, 0, 400)
    playerListFrame.Position = UDim2.new(0.02, 0, 0.12, 0)
    playerListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    playerListFrame.BackgroundTransparency = 0.5
    playerListFrame.BorderSizePixel = 0
    playerListFrame.Parent = mainFrame

    local playerListCorner = Instance.new("UICorner")
    playerListCorner.CornerRadius = UDim.new(0, 8)
    playerListCorner.Parent = playerListFrame

    local playerListTitle = Instance.new("TextLabel")
    playerListTitle.Size = UDim2.new(1, 0, 0, 30)
    playerListTitle.Position = UDim2.new(0, 0, 0, 0)
    playerListTitle.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    playerListTitle.BorderSizePixel = 0
    playerListTitle.Text = "ONLINE PLAYERS"
    playerListTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerListTitle.Font = Enum.Font.SourceSansBold
    playerListTitle.Parent = playerListFrame

    -- Player list scrolling frame
    local playerScrollFrame = Instance.new("ScrollingFrame")
    playerScrollFrame.Size = UDim2.new(0.96, 0, 0.8, 0)
    playerScrollFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
    playerScrollFrame.BackgroundTransparency = 1
    playerScrollFrame.BorderSizePixel = 0
    playerScrollFrame.ScrollBarThickness = 8
    playerScrollFrame.Parent = playerListFrame

    -- Command section
    local commandFrame = Instance.new("Frame")
    commandFrame.Size = UDim2.new(0, 500, 0, 400)
    commandFrame.Position = UDim2.new(0.42, 0, 0.12, 0)
    commandFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    commandFrame.BackgroundTransparency = 0.5
    commandFrame.BorderSizePixel = 0
    commandFrame.Parent = mainFrame

    local commandCorner = Instance.new("UICorner")
    commandCorner.CornerRadius = UDim.new(0, 8)
    commandCorner.Parent = commandFrame

    local commandTitle = Instance.new("TextLabel")
    commandTitle.Size = UDim2.new(1, 0, 0, 30)
    commandTitle.Position = UDim2.new(0, 0, 0, 0)
    commandTitle.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    commandTitle.BorderSizePixel = 0
    commandTitle.Text = "ADMIN COMMANDS"
    commandTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    commandTitle.Font = Enum.Font.SourceSansBold
    commandTitle.Parent = commandFrame

    -- Target player selection
    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(0.9, 0, 0, 50)
    targetFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    targetFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    targetFrame.BorderSizePixel = 0
    targetFrame.Parent = commandFrame

    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 6)
    targetCorner.Parent = targetFrame

    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(0.4, 0, 1, 0)
    targetLabel.Position = UDim2.new(0.02, 0, 0, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target Player:"
    targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetLabel.Font = Enum.Font.SourceSansBold
    targetLabel.Parent = targetFrame

    local targetDropdown = Instance.new("TextButton")
    targetDropdown.Size = UDim2.new(0.55, 0, 0.8, 0)
    targetDropdown.Position = UDim2.new(0.43, 0, 0.1, 0)
    targetDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    targetDropdown.BorderSizePixel = 0
    targetDropdown.Text = "Select Player"
    targetDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetDropdown.Font = Enum.Font.SourceSansBold
    targetDropdown.Parent = targetFrame

    local targetDropdownCorner = Instance.new("UICorner")
    targetDropdownCorner.CornerRadius = UDim.new(0, 4)
    targetDropdownCorner.Parent = targetDropdown

    -- Command buttons
    local commandButtonsFrame = Instance.new("Frame")
    commandButtonsFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
    commandButtonsFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
    commandButtonsFrame.BackgroundTransparency = 1
    commandButtonsFrame.Parent = commandFrame

    local commandLayout = Instance.new("UIGridLayout")
    commandLayout.CellSize = UDim2.new(0.3, 0, 0, 50)
    commandLayout.CellPadding = UDim2.new(0.05, 0.05)
    commandLayout.Parent = commandButtonsFrame

    -- Create command buttons
    local commands = {
        {Name = "Kick", Color = Color3.fromRGB(255, 100, 100)},
        {Name = "Ban", Color = Color3.fromRGB(255, 50, 50)},
        {Name = "Teleport", Color = Color3.fromRGB(100, 150, 255)},
        {Name = "Give Weapon", Color = Color3.fromRGB(100, 255, 100)},
        {Name = "God Mode", Color = Color3.fromRGB(255, 255, 100)},
        {Name = "Speed Boost", Color = Color3.fromRGB(255, 150, 255)},
        {Name = "Spawn Item", Color = Color3.fromRGB(150, 255, 150)},
        {Name = "Kill All", Color = Color3.fromRGB(255, 100, 255)},
        {Name = "Shutdown", Color = Color3.fromRGB(255, 0, 0)},
        {Name = "Announce", Color = Color3.fromRGB(255, 200, 100)}
    }

    local commandButtons = {}

    for _, cmd in pairs(commands) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundColor3 = cmd.Color
        button.BorderSizePixel = 0
        button.Text = cmd.Name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.SourceSansBold
        button.TextScaled = true
        button.Parent = commandButtonsFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button

        -- Hover effects
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {Size = UDim2.new(1.05, 0, 1.05, 0)}):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        end)

        button.MouseButton1Click:Connect(function()
            AdminPanel.ExecuteCommand(cmd.Name)
        end)

        table.insert(commandButtons, button)
    end

    -- Value input for commands that need it
    local valueFrame = Instance.new("Frame")
    valueFrame.Size = UDim2.new(0.9, 0, 0, 40)
    valueFrame.Position = UDim2.new(0.05, 0, 0.85, 0)
    valueFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    valueFrame.BorderSizePixel = 0
    valueFrame.Parent = commandFrame

    local valueCorner = Instance.new("UICorner")
    valueCorner.CornerRadius = UDim.new(0, 6)
    valueCorner.Parent = valueFrame

    local valueInput = Instance.new("TextBox")
    valueInput.Size = UDim2.new(0.8, 0, 0.8, 0)
    valueInput.Position = UDim2.new(0.02, 0, 0.1, 0)
    valueInput.BackgroundTransparency = 1
    valueInput.Text = "Enter value..."
    valueInput.TextColor3 = Color3.fromRGB(150, 150, 150)
    valueInput.Font = Enum.Font.SourceSans
    valueInput.Parent = valueFrame

    -- Status display
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0.96, 0, 0, 80)
    statusFrame.Position = UDim2.new(0.02, 0, 0.85, 0)
    statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    statusFrame.BackgroundTransparency = 0.5
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = mainFrame

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Admin Panel Ready"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.Parent = statusFrame

    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        AdminPanel.IsVisible = false
    end)

    -- Populate player list
    AdminPanel.RefreshPlayerList(playerScrollFrame)

    return mainFrame, targetDropdown, valueInput, statusLabel
end

-- Refresh player list
function AdminPanel.RefreshPlayerList(playerScrollFrame)
    playerScrollFrame:ClearAllChildren()

    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        -- Request player list from server
        local getPlayersRemote = remoteEvents:FindFirstChild("GetOnlinePlayers")
        if getPlayersRemote then
            getPlayersRemote:FireServer()
        end
    end

    -- Create player buttons (placeholder)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(1, 0, 0, 50)
            playerButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            playerButton.BorderSizePixel = 0
            playerButton.Text = player.Name .. (AdminPanel.IsAdmin and " ⭐" or "")
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.Font = Enum.Font.SourceSansBold
            playerButton.Parent = playerScrollFrame

            local playerCorner = Instance.new("UICorner")
            playerCorner.CornerRadius = UDim.new(0, 6)
            playerCorner.Parent = playerButton

            playerButton.MouseButton1Click:Connect(function()
                -- Set as target player
                AdminPanel.SelectedPlayer = player
                print("Selected target player: " .. player.Name)
            end)
        end
    end
end

-- Execute admin command
function AdminPanel.ExecuteCommand(command)
    if not AdminPanel.IsAdmin then return end

    local args = {
        TargetPlayer = AdminPanel.SelectedPlayer,
        Value = AdminPanel.ValueInput and AdminPanel.ValueInput.Text or ""
    }

    local remoteEvents = ReplicatedStorage.RemoteEvents
    local adminCommandRemote = remoteEvents:FindFirstChild("AdminCommand")
    if adminCommandRemote then
        adminCommandRemote:FireServer(command, args)
        AdminPanel.UpdateStatus("Executed: " .. command)
    end
end

-- Update status display
function AdminPanel.UpdateStatus(message)
    if AdminPanel.StatusLabel then
        AdminPanel.StatusLabel.Text = message
        TweenService:Create(AdminPanel.StatusLabel, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(0, 255, 0)}):Play()
    end
end

-- Toggle admin panel visibility
function AdminPanel.Toggle()
    if AdminPanel.MainFrame then
        AdminPanel.IsVisible = not AdminPanel.IsVisible
        AdminPanel.MainFrame.Visible = AdminPanel.IsVisible
    end
end

-- Initialize admin panel
function AdminPanel.Initialize()
    -- Check if player is admin
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        local updateAdminRemote = remoteEvents:FindFirstChild("UpdateAdminPanel")
        if updateAdminRemote then
            updateAdminRemote.OnClientEvent:Connect(function(isAdmin)
                AdminPanel.IsAdmin = isAdmin
                if isAdmin then
                    local mainFrame, targetDropdown, valueInput, statusLabel = AdminPanel.Create()
                    AdminPanel.MainFrame = mainFrame
                    AdminPanel.TargetDropdown = targetDropdown
                    AdminPanel.ValueInput = valueInput
                    AdminPanel.StatusLabel = statusLabel

                    print("🛡️ Admin Panel initialized for " .. player.Name)
                end
            end)
        end
    end

    -- Toggle with F9
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.F9 then
            AdminPanel.Toggle()
        end
    end)
end

return AdminPanel
