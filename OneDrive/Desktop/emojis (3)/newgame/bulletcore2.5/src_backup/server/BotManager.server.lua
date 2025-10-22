-- AI Bot Management System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local GameData = require(ReplicatedStorage.Shared.GameData)

local BotManager = {}
local activeBots = {}
local botCount = 0

-- Create bot character
local function createBot(difficulty)
    difficulty = difficulty or "Normal"
    local botSettings = GameData.BotDifficulty[difficulty]
    
    botCount = botCount + 1
    local botName = "Bot_" .. botCount
    
    -- Create bot model
    local bot = Instance.new("Model")
    bot.Name = botName
    bot.Parent = workspace
    
    -- Create humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = botSettings.Health
    humanoid.Health = botSettings.Health
    humanoid.Parent = bot
    
    -- Create body parts
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 2, 1)
    rootPart.Material = Enum.Material.Plastic
    rootPart.BrickColor = BrickColor.new("Bright blue")
    rootPart.CanCollide = false
    rootPart.Parent = bot
    
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Material = Enum.Material.Plastic
    head.BrickColor = BrickColor.new("Light orange")
    head.Parent = bot
    
    -- Weld head to root
    local headWeld = Instance.new("WeldConstraint")
    headWeld.Part0 = rootPart
    headWeld.Part1 = head
    headWeld.Parent = rootPart
    
    head.CFrame = rootPart.CFrame + Vector3.new(0, 1.5, 0)
    
    -- Add health bar above bot
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 100, 0, 20)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Parent = head
    
    local healthFrame = Instance.new("Frame")
    healthFrame.Size = UDim2.new(1, 0, 1, 0)
    healthFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthFrame.BorderSizePixel = 0
    healthFrame.Parent = billboardGui
    
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthFrame
    
    -- Bot AI data
    local botData = {
        Model = bot,
        Humanoid = humanoid,
        RootPart = rootPart,
        Head = head,
        HealthBar = healthBar,
        Difficulty = difficulty,
        Settings = botSettings,
        Target = nil,
        LastShotTime = 0,
        Path = nil
    }
    
    -- Update health bar when health changes
    humanoid.HealthChanged:Connect(function()
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
        
        if healthPercent > 0.6 then
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif healthPercent > 0.3 then
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        else
            healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
    
    -- Bot death
    humanoid.Died:Connect(function()
        activeBots[botName] = nil
        wait(2)
        bot:Destroy()
    end)
    
    -- Spawn bot at random location
    local spawnFolder = workspace:FindFirstChild("SpawnPoints")
    if spawnFolder then
        local spawnPoints = spawnFolder:GetChildren()
        if #spawnPoints > 0 then
            local randomSpawn = spawnPoints[math.random(1, #spawnPoints)]
            rootPart.CFrame = randomSpawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
    
    activeBots[botName] = botData
    return botData
end

-- Bot AI behavior
local function updateBotAI(botData)
    if not botData.Model.Parent or botData.Humanoid.Health <= 0 then
        return
    end
    
    local bot = botData.Model
    local humanoid = botData.Humanoid
    local rootPart = botData.RootPart
    
    -- Find nearest player target
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if distance < nearestDistance and distance < 100 then
                nearestPlayer = player
                nearestDistance = distance
            end
        end
    end
    
    botData.Target = nearestPlayer
    
    if nearestPlayer and nearestPlayer.Character then
        local targetRoot = nearestPlayer.Character.HumanoidRootPart
        local direction = (targetRoot.Position - rootPart.Position).Unit
        
        -- Look at target
        rootPart.CFrame = CFrame.lookAt(rootPart.Position, targetRoot.Position)
        
        -- Move towards target if far away
        if nearestDistance > 20 then
            humanoid:MoveTo(targetRoot.Position)
        else
            humanoid:MoveTo(rootPart.Position) -- Stop moving
        end
        
        -- Shoot at target
        local currentTime = tick()
        if currentTime - botData.LastShotTime > botData.Settings.ReactionTime then
            botData.LastShotTime = currentTime
            
            -- Simulate shooting with accuracy
            if math.random() < botData.Settings.Accuracy then
                local shootRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("Shoot")
                if shootRemote then
                    shootRemote:FireServer(nearestPlayer, targetRoot.Position)
                end
            end
        end
    else
        -- Patrol behavior when no target
        if not humanoid.MoveToFinished then
            local randomPos = rootPart.Position + Vector3.new(
                math.random(-20, 20),
                0,
                math.random(-20, 20)
            )
            humanoid:MoveTo(randomPos)
        end
    end
end

-- Main bot update loop
RunService.Heartbeat:Connect(function()
    for _, botData in pairs(activeBots) do
        updateBotAI(botData)
    end
end)

-- Spawn 6 bots with varied difficulty
for i = 1, 6 do
    local difficulty = "Normal"
    if i <= 2 then
        difficulty = "Easy"
    elseif i >= 5 then
        difficulty = "Hard"
    end
    createBot(difficulty)
end

-- Expose bot creation function
_G.BulletCore = _G.BulletCore or {}
_G.BulletCore.CreateBot = createBot