-- Shop GUI System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create Shop GUI
local shopGui = Instance.new("ScreenGui")
shopGui.Name = "ShopGUI"
shopGui.ResetOnSpawn = false
shopGui.Parent = playerGui

local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 600, 0, 400)
shopFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
shopFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shopFrame.BorderSizePixel = 2
shopFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
shopFrame.Visible = false
shopFrame.Parent = shopGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = shopFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.BorderSizePixel = 0
title.Text = "🛒 WEAPON SHOP"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = shopFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = shopFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

-- Items container
local itemsFrame = Instance.new("ScrollingFrame")
itemsFrame.Name = "ItemsFrame"
itemsFrame.Size = UDim2.new(1, -20, 1, -70)
itemsFrame.Position = UDim2.new(0, 10, 0, 60)
itemsFrame.BackgroundTransparency = 1
itemsFrame.BorderSizePixel = 0
itemsFrame.ScrollBarThickness = 8
itemsFrame.Parent = shopFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = itemsFrame

-- Create item entry
local function createItemEntry(itemName, itemData)
    local itemFrame = Instance.new("Frame")
    itemFrame.Name = itemName
    itemFrame.Size = UDim2.new(1, -16, 0, 80)
    itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    itemFrame.BorderSizePixel = 1
    itemFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    itemFrame.Parent = itemsFrame
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 5)
    itemCorner.Parent = itemFrame
    
    -- Item name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = itemData.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = itemFrame
    
    -- Description
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
    descLabel.Position = UDim2.new(0, 10, 0.5, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = itemData.Description
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = itemFrame
    
    -- Price
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Size = UDim2.new(0.2, 0, 0.4, 0)
    priceLabel.Position = UDim2.new(0.5, 0, 0.3, 0)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = itemData.Price .. " XP"
    priceLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    priceLabel.TextScaled = true
    priceLabel.Font = Enum.Font.GothamBold
    priceLabel.Parent = itemFrame
    
    -- Buy button
    local buyButton = Instance.new("TextButton")
    buyButton.Size = UDim2.new(0.15, 0, 0.6, 0)
    buyButton.Position = UDim2.new(0.8, 0, 0.2, 0)
    buyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    buyButton.BorderSizePixel = 0
    buyButton.Text = "BUY"
    buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyButton.TextScaled = true
    buyButton.Font = Enum.Font.GothamBold
    buyButton.Parent = itemFrame
    
    local buyCorner = Instance.new("UICorner")
    buyCorner.CornerRadius = UDim.new(0, 5)
    buyCorner.Parent = buyButton
    
    -- Purchase logic
    buyButton.MouseButton1Click:Connect(function()
        local shopRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("ShopPurchase")
        if shopRemote then
            shopRemote:FireServer(itemName)
        end
    end)
end

-- Toggle shop visibility
local function toggleShop()
    shopFrame.Visible = not shopFrame.Visible
end

-- Close shop
closeButton.MouseButton1Click:Connect(function()
    shopFrame.Visible = false
end)

-- Open shop with B key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.B then
        toggleShop()
    end
end)

-- Receive shop data
if ReplicatedStorage:FindFirstChild("RemoteEvents") then
    local shopDataRemote = ReplicatedStorage.RemoteEvents:WaitForChild("ShopData")
    shopDataRemote.OnClientEvent:Connect(function(shopItems)
        -- Clear existing items
        for _, child in pairs(itemsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Add new items
        for itemName, itemData in pairs(shopItems) do
            createItemEntry(itemName, itemData)
        end
        
        -- Update canvas size
        itemsFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)
end