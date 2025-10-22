-- Modern Weapon Shop with 3D Previews
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ShopGUI = {}

-- Enhanced Weapon Database with Visual Assets
local WeaponDatabase = {
    Pistol = {
        Name = "Tactical Pistol",
        Description = "High-precision sidearm with advanced grip technology and laser sighting",
        Price = 500,
        ModelID = "rbxassetid://9823847291", -- High-quality pistol model
        IconID = "rbxassetid://9823847292", -- Pistol icon
        BackgroundImage = "rbxassetid://9823847293", -- Weapon background
        Damage = 35,
        FireRate = 0.4,
        MagazineSize = 15,
        Accuracy = 85,
        Range = 80,
        Rarity = "Common",
        Category = "Sidearm",
        Attachments = {"Laser Sight", "Extended Mag"},
        UnlockLevel = 1
    },
    AssaultRifle = {
        Name = "Combat Rifle",
        Description = "Versatile assault rifle with superior range and accuracy for all combat situations",
        Price = 1200,
        ModelID = "rbxassetid://9823847294",
        IconID = "rbxassetid://9823847295",
        BackgroundImage = "rbxassetid://9823847296",
        Damage = 45,
        FireRate = 0.08,
        MagazineSize = 30,
        Accuracy = 75,
        Range = 120,
        Rarity = "Rare",
        Category = "Primary",
        Attachments = {"Scope", "Silencer", "Grip"},
        UnlockLevel = 5
    },
    SniperRifle = {
        Name = "Precision Sniper",
        Description = "Long-range sniper rifle with devastating stopping power and thermal optics",
        Price = 2500,
        ModelID = "rbxassetid://9823847297",
        IconID = "rbxassetid://9823847298",
        BackgroundImage = "rbxassetid://9823847299",
        Damage = 85,
        FireRate = 1.2,
        MagazineSize = 5,
        Accuracy = 95,
        Range = 200,
        Rarity = "Epic",
        Category = "Primary",
        Attachments = {"Thermal Scope", "Bipod", "Extended Mag"},
        UnlockLevel = 15
    },
    Shotgun = {
        Name = "Tactical Shotgun",
        Description = "Close-quarters combat shotgun with devastating spread damage",
        Price = 800,
        ModelID = "rbxassetid://9823847300",
        IconID = "rbxassetid://9823847301",
        BackgroundImage = "rbxassetid://9823847302",
        Damage = 60,
        FireRate = 0.8,
        MagazineSize = 8,
        Accuracy = 40,
        Range = 40,
        Rarity = "Rare",
        Category = "Primary",
        Attachments = {"Slug Rounds", "Extended Tube"},
        UnlockLevel = 3
    },
    SMG = {
        Name = "Submachine Gun",
        Description = "Rapid-fire SMG perfect for close-quarters engagements",
        Price = 900,
        ModelID = "rbxassetid://9823847303",
        IconID = "rbxassetid://9823847304",
        BackgroundImage = "rbxassetid://9823847305",
        Damage = 30,
        FireRate = 0.05,
        MagazineSize = 25,
        Accuracy = 60,
        Range = 60,
        Rarity = "Common",
        Category = "Primary",
        Attachments = {"Rapid Fire", "Drum Mag"},
        UnlockLevel = 2
    }
}

-- Create modern shop GUI
function ShopGUI.Create()
    -- Remove existing shop
    local existingShop = playerGui:FindFirstChild("ShopGUI")
    if existingShop then
        existingShop:Destroy()
    end

    local shopGui = Instance.new("ScreenGui")
    shopGui.Name = "ShopGUI"
    shopGui.ResetOnSpawn = false
    shopGui.Parent = playerGui

    -- Main shop frame
    local shopFrame = Instance.new("Frame")
    shopFrame.Name = "ShopFrame"
    shopFrame.Size = UDim2.new(1, 0, 1, 0)
    shopFrame.Position = UDim2.new(0, 0, 0, 0)
    shopFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shopFrame.BorderSizePixel = 0
    shopFrame.Visible = false
    shopFrame.Parent = shopGui

    -- Animated tactical background
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    background.BorderSizePixel = 0
    background.Parent = shopFrame

    -- Hexagonal grid pattern
    for i = 1, 100 do
        local hex = Instance.new("Frame")
        hex.Size = UDim2.new(0, 60, 0, 60)
        hex.Position = UDim2.new(0, math.random(0, 1920), 0, math.random(0, 1080))
        hex.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        hex.BackgroundTransparency = 0.7
        hex.BorderSizePixel = 0
        hex.Rotation = 30
        hex.Parent = background

        local hexCorner = Instance.new("UICorner")
        hexCorner.CornerRadius = UDim.new(0, 8)
        hexCorner.Parent = hex
    end

    -- Title section
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 0, 80)
    titleFrame.Position = UDim2.new(0, 0, 0, 0)
    titleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    titleFrame.BorderSizePixel = 0
    titleFrame.Parent = shopFrame

    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 100, 0))
    }
    titleGradient.Parent = titleFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 600, 0, 60)
    title.Position = UDim2.new(0.5, -300, 0.1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ TACTICAL ARMORY"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = titleFrame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 50, 0, 50)
    closeButton.Position = UDim2.new(0.98, -60, 0.02, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextScaled = true
    closeButton.Parent = shopFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    -- Weapon categories
    local categoryFrame = Instance.new("Frame")
    categoryFrame.Size = UDim2.new(0, 300, 0, 50)
    categoryFrame.Position = UDim2.new(0.02, 0, 0.12, 0)
    categoryFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    categoryFrame.BorderSizePixel = 0
    categoryFrame.Parent = shopFrame

    local categoryCorner = Instance.new("UICorner")
    categoryCorner.CornerRadius = UDim.new(0, 8)
    categoryCorner.Parent = categoryFrame

    -- Weapon list
    local weaponListFrame = Instance.new("Frame")
    weaponListFrame.Size = UDim2.new(0, 350, 0, 600)
    weaponListFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
    weaponListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    weaponListFrame.BackgroundTransparency = 0.5
    weaponListFrame.BorderSizePixel = 0
    weaponListFrame.Parent = shopFrame

    local weaponListCorner = Instance.new("UICorner")
    weaponListCorner.CornerRadius = UDim.new(0, 10)
    weaponListCorner.Parent = weaponListFrame

    local weaponListLayout = Instance.new("UIListLayout")
    weaponListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    weaponListLayout.Padding = UDim.new(0, 10)
    weaponListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    weaponListLayout.Parent = weaponListFrame

    -- 3D Weapon preview area
    local previewFrame = Instance.new("Frame")
    previewFrame.Size = UDim2.new(0, 800, 0, 500)
    previewFrame.Position = UDim2.new(0.5, -400, 0.2, 0)
    previewFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    previewFrame.BackgroundTransparency = 0.3
    previewFrame.BorderSizePixel = 0
    previewFrame.Parent = shopFrame

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 15)
    previewCorner.Parent = previewFrame

    local previewStroke = Instance.new("UIStroke")
    previewStroke.Color = Color3.fromRGB(0, 255, 255)
    previewStroke.Thickness = 2
    previewStroke.Parent = previewFrame

    -- Weapon preview viewport
    local viewportFrame = Instance.new("ViewportFrame")
    viewportFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
    viewportFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    viewportFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    viewportFrame.BackgroundTransparency = 0.5
    viewportFrame.BorderSizePixel = 0
    viewportFrame.Parent = previewFrame

    local viewportCorner = Instance.new("UICorner")
    viewportCorner.CornerRadius = UDim.new(0, 10)
    viewportCorner.Parent = viewportFrame

    -- Weapon info panel
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(0.9, 0, 0.2, 0)
    infoFrame.Position = UDim2.new(0.05, 0, 0.85, 0)
    infoFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = previewFrame

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoFrame

    -- Weapon name
    local weaponNameLabel = Instance.new("TextLabel")
    weaponNameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    weaponNameLabel.Position = UDim2.new(0, 0, 0, 0)
    weaponNameLabel.BackgroundTransparency = 1
    weaponNameLabel.Text = "Select a weapon to preview"
    weaponNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    weaponNameLabel.Font = Enum.Font.SourceSansBold
    weaponNameLabel.Parent = infoFrame

    -- Weapon description
    local weaponDescLabel = Instance.new("TextLabel")
    weaponDescLabel.Size = UDim2.new(1, 0, 0.4, 0)
    weaponDescLabel.Position = UDim2.new(0, 0, 0.3, 0)
    weaponDescLabel.BackgroundTransparency = 1
    weaponDescLabel.Text = "Weapon information will appear here"
    weaponDescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    weaponDescLabel.Font = Enum.Font.SourceSans
    weaponDescLabel.TextWrapped = true
    weaponDescLabel.Parent = infoFrame

    -- Purchase button
    local purchaseButton = Instance.new("TextButton")
    purchaseButton.Size = UDim2.new(0.8, 0, 0.2, 0)
    purchaseButton.Position = UDim2.new(0.1, 0, 0.75, 0)
    purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    purchaseButton.BorderSizePixel = 0
    purchaseButton.Text = "PURCHASE - $0"
    purchaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    purchaseButton.Font = Enum.Font.SourceSansBold
    purchaseButton.TextScaled = true
    purchaseButton.Parent = infoFrame

    local purchaseCorner = Instance.new("UICorner")
    purchaseCorner.CornerRadius = UDim.new(0, 8)
    purchaseCorner.Parent = purchaseButton

    -- Create weapon buttons
    local function createWeaponButton(weaponData)
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, -20, 0, 80)
        buttonFrame.BackgroundTransparency = 1
        buttonFrame.Parent = weaponListFrame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        button.BorderSizePixel = 0
        button.Text = ""
        button.Parent = buttonFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button

        -- Weapon icon
        local weaponIcon = Instance.new("ImageLabel")
        weaponIcon.Size = UDim2.new(0, 60, 0, 60)
        weaponIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
        weaponIcon.BackgroundTransparency = 1
        weaponIcon.Image = weaponData.IconID or ""
        weaponIcon.Parent = button

        -- Weapon name
        local weaponName = Instance.new("TextLabel")
        weaponName.Size = UDim2.new(0.4, 0, 0.3, 0)
        weaponName.Position = UDim2.new(0.35, 0, 0.1, 0)
        weaponName.BackgroundTransparency = 1
        weaponName.Text = weaponData.Name
        weaponName.TextColor3 = Color3.fromRGB(255, 255, 255)
        weaponName.Font = Enum.Font.SourceSansBold
        weaponName.Parent = button

        -- Weapon price
        local weaponPrice = Instance.new("TextLabel")
        weaponPrice.Size = UDim2.new(0.3, 0, 0.3, 0)
        weaponPrice.Position = UDim2.new(0.35, 0, 0.6, 0)
        weaponPrice.BackgroundTransparency = 1
        weaponPrice.Text = "$" .. weaponData.Price
        weaponPrice.TextColor3 = Color3.fromRGB(0, 255, 0)
        weaponPrice.Font = Enum.Font.SourceSansBold
        weaponPrice.Parent = button

        -- Rarity indicator
        local rarityIndicator = Instance.new("Frame")
        rarityIndicator.Size = UDim2.new(0.15, 0, 0.6, 0)
        rarityIndicator.Position = UDim2.new(0.8, 0, 0.2, 0)
        rarityIndicator.BackgroundColor3 = ShopGUI.GetRarityColor(weaponData.Rarity)
        rarityIndicator.BorderSizePixel = 0
        rarityIndicator.Parent = button

        local rarityCorner = Instance.new("UICorner")
        rarityCorner.CornerRadius = UDim.new(0, 8)
        rarityCorner.Parent = rarityIndicator

        -- Hover effects
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
        end)

        button.MouseButton1Click:Connect(function()
            ShopGUI.ShowWeaponPreview(weaponData, viewportFrame, weaponNameLabel, weaponDescLabel, purchaseButton)
        end)

        return button
    end

    -- Create weapon buttons for all weapons
    for weaponName, weaponData in pairs(WeaponDatabase) do
        createWeaponButton(weaponData)
    end

    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        shopFrame.Visible = false
    end)

    return shopFrame
end

-- Get rarity color
function ShopGUI.GetRarityColor(rarity)
    local colors = {
        Common = Color3.fromRGB(150, 150, 150),
        Rare = Color3.fromRGB(0, 150, 255),
        Epic = Color3.fromRGB(150, 0, 255),
        Legendary = Color3.fromRGB(255, 150, 0)
    }
    return colors[rarity] or Color3.fromRGB(150, 150, 150)
end

-- Show 3D weapon preview
function ShopGUI.ShowWeaponPreview(weaponData, viewportFrame, nameLabel, descLabel, purchaseButton)
    -- Update info
    nameLabel.Text = weaponData.Name
    descLabel.Text = weaponData.Description
    purchaseButton.Text = "PURCHASE - $" .. weaponData.Price

    -- Clear existing viewport
    viewportFrame:ClearAllChildren()

    -- Create 3D weapon preview (placeholder for now)
    local camera = Instance.new("Camera")
    camera.Parent = viewportFrame
    viewportFrame.CurrentCamera = camera

    -- Set camera position for weapon preview
    camera.CFrame = CFrame.new(Vector3.new(0, 0, 5), Vector3.new(0, 0, 0))

    -- Create weapon model (placeholder)
    local weaponModel = Instance.new("Model")
    weaponModel.Name = weaponData.Name
    weaponModel.Parent = viewportFrame

    -- Add a simple part to represent the weapon
    local weaponPart = Instance.new("Part")
    weaponPart.Size = Vector3.new(1, 0.5, 2)
    weaponPart.Position = Vector3.new(0, 0, 0)
    weaponPart.BrickColor = BrickColor.new("Dark stone grey")
    weaponPart.Material = Enum.Material.Metal
    weaponPart.Parent = weaponModel

    -- Animate weapon
    local rotationSpeed = 0
    RunService.Heartbeat:Connect(function(deltaTime)
        rotationSpeed = rotationSpeed + deltaTime * 50
        weaponModel:SetPrimaryPartCFrame(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(rotationSpeed), 0))
    end)

    -- Purchase functionality
    purchaseButton.MouseButton1Click:Connect(function()
        -- Implement purchase logic here
        print("Purchasing " .. weaponData.Name .. " for $" .. weaponData.Price)
    end)
end

-- Initialize shop
ShopGUI.Create()

return ShopGUI
