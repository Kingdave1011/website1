-- Advanced Clan Management GUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ClanGUI = {}

-- Create clan GUI
function ClanGUI.Create()
    -- Remove existing clan GUI
    local existingClan = playerGui:FindFirstChild("ClanGUI")
    if existingClan then
        existingClan:Destroy()
    end

    local clanGui = Instance.new("ScreenGui")
    clanGui.Name = "ClanGUI"
    clanGui.ResetOnSpawn = false
    clanGui.Parent = playerGui

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 1000, 0, 700)
    mainFrame.Position = UDim2.new(0.5, -500, 0.5, -350)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = clanGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 150, 0)
    mainStroke.Thickness = 3
    mainStroke.Parent = mainFrame

    -- Animated background
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    background.BorderSizePixel = 0
    background.Parent = mainFrame

    -- Title
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 80)
    titleFrame.Position = UDim2.new(0, 0, 0, 0)
    titleFrame.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    titleFrame.BorderSizePixel = 0
    titleFrame.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 600, 0, 60)
    title.Position = UDim2.new(0.5, -300, 0.1, 0)
    title.BackgroundTransparency = 1
    title.Text = "🏰 CLAN MANAGEMENT"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = titleFrame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 50, 0, 50)
    closeButton.Position = UDim2.new(0.98, -60, 0.1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextScaled = true
    closeButton.Parent = mainFrame

    -- Clan info section
    local clanInfoFrame = Instance.new("Frame")
    clanInfoFrame.Size = UDim2.new(0, 450, 0, 200)
    clanInfoFrame.Position = UDim2.new(0.02, 0, 0.12, 0)
    clanInfoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    clanInfoFrame.BackgroundTransparency = 0.5
    clanInfoFrame.BorderSizePixel = 0
    clanInfoFrame.Parent = mainFrame

    local clanInfoCorner = Instance.new("UICorner")
    clanInfoCorner.CornerRadius = UDim.new(0, 10)
    clanInfoCorner.Parent = clanInfoFrame

    -- Clan management section
    local clanManageFrame = Instance.new("Frame")
    clanManageFrame.Size = UDim2.new(0, 500, 0, 500)
    clanManageFrame.Position = UDim2.new(0.48, 0, 0.12, 0)
    clanManageFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    clanManageFrame.BackgroundTransparency = 0.5
    clanManageFrame.BorderSizePixel = 0
    clanManageFrame.Parent = mainFrame

    local clanManageCorner = Instance.new("UICorner")
    clanManageCorner.CornerRadius = UDim.new(0, 10)
    clanManageCorner.Parent = clanManageFrame

    -- Create clan button
    local createClanButton = Instance.new("TextButton")
    createClanButton.Size = UDim2.new(0, 300, 0, 60)
    createClanButton.Position = UDim2.new(0.5, -150, 0.85, 0)
    createClanButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    createClanButton.BorderSizePixel = 0
    createClanButton.Text = "🏰 CREATE NEW CLAN"
    createClanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    createClanButton.Font = Enum.Font.SourceSansBold
    createClanButton.TextScaled = true
    createClanButton.Parent = mainFrame

    local createClanCorner = Instance.new("UICorner")
    createClanCorner.CornerRadius = UDim.new(0, 12)
    createClanCorner.Parent = createClanButton

    -- Browse clans button
    local browseClansButton = Instance.new("TextButton")
    browseClansButton.Size = UDim2.new(0, 300, 0, 60)
    browseClansButton.Position = UDim2.new(0.5, -150, 0.75, 0)
    browseClansButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    browseClansButton.BorderSizePixel = 0
    browseClansButton.Text = "🔍 BROWSE CLANS"
    browseClansButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    browseClansButton.Font = Enum.Font.SourceSansBold
    browseClansButton.TextScaled = true
    browseClansButton.Parent = mainFrame

    local browseClansCorner = Instance.new("UICorner")
    browseClansCorner.CornerRadius = UDim.new(0, 12)
    browseClansCorner.Parent = browseClansButton

    -- Close functionality
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        ClanGUI.IsVisible = false
    end)

    -- Create clan functionality
    createClanButton.MouseButton1Click:Connect(function()
        ClanGUI.ShowCreateClanDialog(mainFrame)
    end)

    -- Browse clans functionality
    browseClansButton.MouseButton1Click:Connect(function()
        ClanGUI.ShowClanBrowser(mainFrame)
    end)

    return mainFrame
end

-- Show create clan dialog
function ClanGUI.ShowCreateClanDialog(parentFrame)
    -- Create dialog overlay
    local dialogFrame = Instance.new("Frame")
    dialogFrame.Size = UDim2.new(0, 400, 0, 300)
    dialogFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    dialogFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    dialogFrame.BorderSizePixel = 0
    dialogFrame.Parent = parentFrame

    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 12)
    dialogCorner.Parent = dialogFrame

    local dialogTitle = Instance.new("TextLabel")
    dialogTitle.Size = UDim2.new(1, 0, 0, 40)
    dialogTitle.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    dialogTitle.BorderSizePixel = 0
    dialogTitle.Text = "CREATE NEW CLAN"
    dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    dialogTitle.Font = Enum.Font.SourceSansBold
    dialogTitle.Parent = dialogFrame

    -- Clan name input
    local nameFrame = Instance.new("Frame")
    nameFrame.Size = UDim2.new(0.8, 0, 0, 50)
    nameFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
    nameFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    nameFrame.BorderSizePixel = 0
    nameFrame.Parent = dialogFrame

    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 8)
    nameCorner.Parent = nameFrame

    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(0.9, 0, 0.8, 0)
    nameInput.Position = UDim2.new(0.05, 0, 0.1, 0)
    nameInput.BackgroundTransparency = 1
    nameInput.Text = "Enter clan name..."
    nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameInput.Font = Enum.Font.SourceSans
    nameInput.Parent = nameFrame

    -- Clan tag input
    local tagFrame = Instance.new("Frame")
    tagFrame.Size = UDim2.new(0.8, 0, 0, 50)
    tagFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
    tagFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tagFrame.BorderSizePixel = 0
    tagFrame.Parent = dialogFrame

    local tagCorner = Instance.new("UICorner")
    tagCorner.CornerRadius = UDim.new(0, 8)
    tagCorner.Parent = tagFrame

    local tagInput = Instance.new("TextBox")
    tagInput.Size = UDim2.new(0.9, 0, 0.8, 0)
    tagInput.Position = UDim2.new(0.05, 0, 0.1, 0)
    tagInput.BackgroundTransparency = 1
    tagInput.Text = "Enter clan tag..."
    tagInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    tagInput.Font = Enum.Font.SourceSans
    tagInput.Parent = tagFrame

    -- Create button
    local confirmButton = Instance.new("TextButton")
    confirmButton.Size = UDim2.new(0, 150, 0, 50)
    confirmButton.Position = UDim2.new(0.25, 0, 0.7, 0)
    confirmButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    confirmButton.BorderSizePixel = 0
    confirmButton.Text = "CREATE CLAN"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.Font = Enum.Font.SourceSansBold
    confirmButton.TextScaled = true
    confirmButton.Parent = dialogFrame

    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 8)
    confirmCorner.Parent = confirmButton

    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0, 150, 0, 50)
    cancelButton.Position = UDim2.new(0.625, 0, 0.7, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "CANCEL"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.Font = Enum.Font.SourceSansBold
    cancelButton.TextScaled = true
    cancelButton.Parent = dialogFrame

    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 8)
    cancelCorner.Parent = cancelButton

    -- Confirm functionality
    confirmButton.MouseButton1Click:Connect(function()
        local clanName = nameInput.Text
        local clanTag = tagInput.Text

        if clanName ~= "" and clanTag ~= "" then
            -- Send create clan request
            local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
            if remoteEvents then
                local createClanRemote = remoteEvents:FindFirstChild("CreateClan")
                if createClanRemote then
                    createClanRemote:FireServer(clanName, clanTag)
                end
            end

            dialogFrame:Destroy()
        end
    end)

    -- Cancel functionality
    cancelButton.MouseButton1Click:Connect(function()
        dialogFrame:Destroy()
    end)
end

-- Show clan browser
function ClanGUI.ShowClanBrowser(parentFrame)
    -- Create browser overlay
    local browserFrame = Instance.new("Frame")
    browserFrame.Size = UDim2.new(0, 600, 0, 400)
    browserFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    browserFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    browserFrame.BorderSizePixel = 0
    browserFrame.Parent = parentFrame

    local browserCorner = Instance.new("UICorner")
    browserCorner.CornerRadius = UDim.new(0, 12)
    browserCorner.Parent = browserFrame

    local browserTitle = Instance.new("TextLabel")
    browserTitle.Size = UDim2.new(1, 0, 0, 40)
    browserTitle.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    browserTitle.BorderSizePixel = 0
    browserTitle.Text = "BROWSE CLANS"
    browserTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    browserTitle.Font = Enum.Font.SourceSansBold
    browserTitle.Parent = browserFrame

    -- Clan list
    local clanListFrame = Instance.new("ScrollingFrame")
    clanListFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
    clanListFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
    clanListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    clanListFrame.BorderSizePixel = 0
    clanListFrame.ScrollBarThickness = 8
    clanListFrame.Parent = browserFrame

    local clanListCorner = Instance.new("UICorner")
    clanListCorner.CornerRadius = UDim.new(0, 8)
    clanListCorner.Parent = clanListFrame

    local clanListLayout = Instance.new("UIListLayout")
    clanListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    clanListLayout.Padding = UDim.new(0, 10)
    clanListLayout.Parent = clanListFrame

    -- Close button
    local closeBrowserButton = Instance.new("TextButton")
    closeBrowserButton.Size = UDim2.new(0, 150, 0, 50)
    closeBrowserButton.Position = UDim2.new(0.75, 0, 0.9, 0)
    closeBrowserButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBrowserButton.BorderSizePixel = 0
    closeBrowserButton.Text = "CLOSE"
    closeBrowserButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBrowserButton.Font = Enum.Font.SourceSansBold
    closeBrowserButton.TextScaled = true
    closeBrowserButton.Parent = browserFrame

    local closeBrowserCorner = Instance.new("UICorner")
    closeBrowserCorner.CornerRadius = UDim.new(0, 8)
    closeBrowserCorner.Parent = closeBrowserButton

    -- Close browser functionality
    closeBrowserButton.MouseButton1Click:Connect(function()
        browserFrame:Destroy()
    end)

    -- Load clans (placeholder for now)
    ClanGUI.LoadClanList(clanListFrame)
end

-- Load clan list
function ClanGUI.LoadClanList(clanListFrame)
    clanListFrame:ClearAllChildren()

    -- Request clan list from server
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        local getClansRemote = remoteEvents:FindFirstChild("GetAllClans")
        if getClansRemote then
            getClansRemote:FireServer()
        end
    end

    -- Create sample clan entries (placeholder)
    for i = 1, 5 do
        local clanEntry = Instance.new("Frame")
        clanEntry.Size = UDim2.new(1, 0, 0, 80)
        clanEntry.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        clanEntry.BorderSizePixel = 0
        clanEntry.Parent = clanListFrame

        local clanEntryCorner = Instance.new("UICorner")
        clanEntryCorner.CornerRadius = UDim.new(0, 8)
        clanEntryCorner.Parent = clanEntry

        local clanName = Instance.new("TextLabel")
        clanName.Size = UDim2.new(0.4, 0, 0.5, 0)
        clanName.Position = UDim2.new(0.02, 0, 0.1, 0)
        clanName.BackgroundTransparency = 1
        clanName.Text = "Sample Clan " .. i
        clanName.TextColor3 = Color3.fromRGB(255, 255, 255)
        clanName.Font = Enum.Font.SourceSansBold
        clanName.Parent = clanEntry

        local clanMembers = Instance.new("TextLabel")
        clanMembers.Size = UDim2.new(0.3, 0, 0.5, 0)
        clanMembers.Position = UDim2.new(0.45, 0, 0.1, 0)
        clanMembers.BackgroundTransparency = 1
        clanMembers.Text = "25 Members"
        clanMembers.TextColor3 = Color3.fromRGB(150, 150, 150)
        clanMembers.Font = Enum.Font.SourceSans
        clanMembers.Parent = clanEntry

        local joinButton = Instance.new("TextButton")
        joinButton.Size = UDim2.new(0.2, 0, 0.6, 0)
        joinButton.Position = UDim2.new(0.78, 0, 0.2, 0)
        joinButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        joinButton.BorderSizePixel = 0
        joinButton.Text = "JOIN"
        joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        joinButton.Font = Enum.Font.SourceSansBold
        joinButton.Parent = clanEntry

        local joinCorner = Instance.new("UICorner")
        joinCorner.CornerRadius = UDim.new(0, 6)
        joinCorner.Parent = joinButton

        -- Join functionality
        joinButton.MouseButton1Click:Connect(function()
            print("Attempting to join Sample Clan " .. i)
        end)
    end
end

-- Toggle clan GUI
function ClanGUI.Toggle()
    if not ClanGUI.MainFrame then
        ClanGUI.MainFrame = ClanGUI.Create()
    end

    ClanGUI.IsVisible = not ClanGUI.IsVisible
    ClanGUI.MainFrame.Visible = ClanGUI.IsVisible
end

-- Initialize clan GUI
function ClanGUI.Initialize()
    -- Listen for clan GUI toggle (e.g., from main menu)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.C then
            ClanGUI.Toggle()
        end
    end)

    print("🏰 Clan GUI initialized!")
end

return ClanGUI
