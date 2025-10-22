-- Shop System Manager
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote Events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local shopRemote = Instance.new("RemoteEvent")
shopRemote.Name = "ShopPurchase"
shopRemote.Parent = remoteEvents

local shopDataRemote = Instance.new("RemoteEvent")
shopDataRemote.Name = "ShopData"
shopDataRemote.Parent = remoteEvents

-- Shop Items (will find guns in workspace/game)
local shopItems = {}

-- Find gun assets in game
local function findGunAssets()
    local guns = {}
    
    -- Search common locations for gun models
    local searchLocations = {workspace, game.Lighting, ReplicatedStorage}
    
    for _, location in pairs(searchLocations) do
        for _, item in pairs(location:GetDescendants()) do
            if item:IsA("Model") and (
                item.Name:lower():find("gun") or 
                item.Name:lower():find("rifle") or 
                item.Name:lower():find("pistol") or
                item.Name:lower():find("weapon")
            ) then
                table.insert(guns, item)
            end
        end
    end
    
    return guns
end

-- Initialize shop with found guns
local function initializeShop()
    local foundGuns = findGunAssets()
    
    for i, gun in pairs(foundGuns) do
        shopItems[gun.Name] = {
            Name = gun.Name,
            Price = i * 500, -- Price based on order found
            Model = gun,
            Category = "Weapons",
            Description = "Powerful weapon for combat"
        }
    end
    
    print("Shop initialized with " .. #foundGuns .. " weapons")
end

-- Handle purchase
shopRemote.OnServerEvent:Connect(function(player, itemName)
    local playerData = _G.BulletCore.GetPlayerData(player)
    local item = shopItems[itemName]
    
    if not playerData or not item then return end
    
    -- Check if player has enough XP (using XP as currency)
    if playerData.XP >= item.Price then
        playerData.XP = playerData.XP - item.Price
        
        -- Give weapon to player
        if player.Character then
            local weaponClone = item.Model:Clone()
            weaponClone.Parent = player.Character
        end
        
        print(player.Name .. " purchased " .. itemName)
    end
end)

-- Send shop data to client
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        shopDataRemote:FireClient(player, shopItems)
    end)
end)

initializeShop()