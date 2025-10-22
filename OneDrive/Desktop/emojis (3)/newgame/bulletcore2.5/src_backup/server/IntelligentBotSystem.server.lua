-- Advanced Intelligent Bot System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local IntelligentBotSystem = {}

-- Bot configuration
local BotConfig = {
    MaxBots = 6,
    SpawnRadius = 50,
    AttackRange = 30,
    DetectionRange = 40,
    MoveSpeed = 16,
    AttackCooldown = 1.5,
    Health = 100,
    Damage = 20,
    Accuracy = 0.7
}

-- Bot states
local BotStates = {
    Idle = "Idle",
    Patrolling = "Patrolling",
    Chasing = "Chasing",
    Attacking = "Attacking",
    Dead = "Dead"
}

-- Active bots
local activeBots = {}
local botTargets = {}

-- Create intelligent bot
function IntelligentBotSystem.CreateBot(position)
    local botModel = Instance.new("Model")
    botModel.Name = "IntelligentBot"
    botModel.Parent = workspace

    -- Create humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = BotConfig.Health
    humanoid.Health = BotConfig.Health
    humanoid.WalkSpeed = BotConfig.MoveSpeed
    humanoid.Parent = botModel

    -- Create body parts
    local head = Instance.new("Part")
    head.Size = Vector3.new(1, 1, 1)
    head.Position = position + Vector3.new(0, 2, 0)
    head.BrickColor = BrickColor.new("Bright red")
    head.Material = Enum.Material.Metal
    head.Parent = botModel

    local torso = Instance.new("Part")
    torso.Size = Vector3.new(2, 2, 1)
    torso.Position = position
    torso.BrickColor = BrickColor.new("Dark stone grey")
    torso.Material = Enum.Material.Metal
    torso.Parent = botModel

    -- Weld parts together
    local neckWeld = Instance.new("Weld")
    neckWeld.Part0 = torso
    neckWeld.Part1 = head
    neckWeld.C0 = CFrame.new(0, 1, 0)
    neckWeld.Parent = torso

    -- Add bot data
    local botData = {
        Model = botModel,
        Humanoid = humanoid,
        State = BotStates.Idle,
        Target = nil,
        LastAttack = 0,
        PatrolPoints = {},
        CurrentPatrolIndex = 1,
        LastSeenTarget = 0
    }

    -- Generate patrol points
    for i = 1, 4 do
        local angle = (i - 1) * (math.pi * 2 / 4)
        local patrolX = position.X + math.cos(angle) * 20
        local patrolZ = position.Z + math.sin(angle) * 20
        table.insert(botData.PatrolPoints, Vector3.new(patrolX, position.Y, patrolZ))
    end

    activeBots[botModel] = botData

    -- Bot AI loop
    RunService.Heartbeat:Connect(function()
        IntelligentBotSystem.UpdateBot(botModel, botData)
    end)

    print("🤖 Intelligent bot created at " .. tostring(position))
    return botModel
end

-- Update bot AI
function IntelligentBotSystem.UpdateBot(botModel, botData)
    if botData.State == BotStates.Dead then return end

    local humanoid = botData.Humanoid
    if not humanoid or humanoid.Health <= 0 then
        botData.State = BotStates.Dead
        botModel:Destroy()
        activeBots[botModel] = nil
        return
    end

    local botPosition = botModel.PrimaryPart and botModel.PrimaryPart.Position or botModel:GetPivot().Position

    -- Find targets
    local nearestPlayer = nil
    local nearestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (botPosition - player.Character.HumanoidRootPart.Position).Magnitude

            if distance < BotConfig.DetectionRange and distance < nearestDistance then
                nearestPlayer = player
                nearestDistance = distance
            end
        end
    end

    -- Update bot behavior based on target
    if nearestPlayer then
        botData.LastSeenTarget = tick()

        if nearestDistance <= BotConfig.AttackRange then
            -- Attack target
            IntelligentBotSystem.AttackTarget(botModel, botData, nearestPlayer)
        else
            -- Chase target
            IntelligentBotSystem.ChaseTarget(botModel, botData, nearestPlayer)
        end
    else
        -- Patrol or idle
        if tick() - botData.LastSeenTarget > 5 then
            IntelligentBotSystem.Patrol(botModel, botData)
        else
            IntelligentBotSystem.Idle(botModel, botData)
        end
    end
end

-- Bot patrol behavior
function IntelligentBotSystem.Patrol(botModel, botData)
    if botData.State ~= BotStates.Patrolling then
        botData.State = BotStates.Patrolling
    end

    local humanoid = botData.Humanoid
    local currentPatrolPoint = botData.PatrolPoints[botData.CurrentPatrolIndex]

    if currentPatrolPoint then
        -- Move to patrol point
        humanoid:MoveTo(currentPatrolPoint)

        -- Check if reached patrol point
        local distanceToPoint = (botModel.PrimaryPart.Position - currentPatrolPoint).Magnitude
        if distanceToPoint < 3 then
            botData.CurrentPatrolIndex = botData.CurrentPatrolIndex + 1
            if botData.CurrentPatrolIndex > #botData.PatrolPoints then
                botData.CurrentPatrolIndex = 1
            end
        end
    end
end

-- Bot chase behavior
function IntelligentBotSystem.ChaseTarget(botModel, botData, target)
    if botData.State ~= BotStates.Chasing then
        botData.State = BotStates.Chasing
    end

    local humanoid = botData.Humanoid
    local targetPosition = target.Character.HumanoidRootPart.Position

    -- Move towards target
    humanoid:MoveTo(targetPosition)

    -- Update target reference
    botData.Target = target
end

-- Bot attack behavior
function IntelligentBotSystem.AttackTarget(botModel, botData, target)
    if botData.State ~= BotStates.Attacking then
        botData.State = BotStates.Attacking
    end

    local humanoid = botData.Humanoid
    local currentTime = tick()

    -- Check attack cooldown
    if currentTime - botData.LastAttack >= BotConfig.AttackCooldown then
        -- Attack target
        IntelligentBotSystem.ShootAtTarget(botModel, botData, target)
        botData.LastAttack = currentTime
    end

    -- Keep distance for better combat
    local botPosition = botModel.PrimaryPart.Position
    local targetPosition = target.Character.HumanoidRootPart.Position
    local distance = (botPosition - targetPosition).Magnitude

    if distance < 10 then
        -- Back away if too close
        local direction = (botPosition - targetPosition).Unit
        humanoid:MoveTo(botPosition + direction * 15)
    elseif distance > BotConfig.AttackRange then
        -- Move closer if too far
        humanoid:MoveTo(targetPosition)
    end
end

-- Bot idle behavior
function IntelligentBotSystem.Idle(botModel, botData)
    if botData.State ~= BotStates.Idle then
        botData.State = BotStates.Idle
    end

    -- Look around randomly
    local humanoid = botData.Humanoid
    humanoid:MoveTo(botModel.PrimaryPart.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
end

-- Bot shooting mechanics
function IntelligentBotSystem.ShootAtTarget(botModel, botData, target)
    local botPosition = botModel.PrimaryPart.Position
    local targetPosition = target.Character.HumanoidRootPart.Position

    -- Calculate shot direction with accuracy
    local direction = (targetPosition - botPosition).Unit
    local spread = (1 - BotConfig.Accuracy) * 0.2
    direction = direction + Vector3.new(
        math.random(-spread, spread),
        math.random(-spread, spread),
        math.random(-spread, spread)
    )
    direction = direction.Unit

    -- Raycast for hit detection
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {botModel}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(botPosition, direction * BotConfig.AttackRange, raycastParams)

    if result then
        local hitPlayer = Players:GetPlayerFromCharacter(result.Instance.Parent)
        if hitPlayer and hitPlayer == target then
            -- Hit target - apply damage
            if target.Character and target.Character:FindFirstChild("Humanoid") then
                target.Character.Humanoid:TakeDamage(BotConfig.Damage)
            end

            -- Send hit effects to all players
            local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
            if remoteEvents then
                local hitMarkerRemote = remoteEvents:FindFirstChild("HitMarker")
                if hitMarkerRemote then
                    hitMarkerRemote:FireAllClients()
                end

                local impactRemote = remoteEvents:FindFirstChild("ImpactEffect")
                if impactRemote then
                    impactRemote:FireAllClients(result.Position, result.Normal)
                end
            end

            print("Bot hit " .. target.Name .. " for " .. BotConfig.Damage .. " damage")
        else
            -- Hit environment
            local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
            if remoteEvents then
                local impactRemote = remoteEvents:FindFirstChild("ImpactEffect")
                if impactRemote then
                    impactRemote:FireAllClients(result.Position, result.Normal)
                end
            end
        end
    end

    -- Create muzzle flash effect
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        local muzzleFlashRemote = remoteEvents:FindFirstChild("MuzzleFlash")
        if muzzleFlashRemote then
            muzzleFlashRemote:FireAllClients(botPosition + direction * 2, 0.5)
        end
    end
end

-- Spawn initial bots
function IntelligentBotSystem.SpawnInitialBots()
    local spawnPoints = {
        Vector3.new(20, 5, 20),
        Vector3.new(-20, 5, 20),
        Vector3.new(20, 5, -20),
        Vector3.new(-20, 5, -20),
        Vector3.new(0, 5, 30),
        Vector3.new(0, 5, -30)
    }

    for i = 1, math.min(BotConfig.MaxBots, #spawnPoints) do
        IntelligentBotSystem.CreateBot(spawnPoints[i])
    end

    print("🤖 Spawned " .. math.min(BotConfig.MaxBots, #spawnPoints) .. " intelligent bots")
end

-- Handle player damage to bots
function IntelligentBotSystem.DamageBot(botModel, damage, player)
    local botData = activeBots[botModel]
    if botData and botData.Humanoid then
        botData.Humanoid:TakeDamage(damage)

        if botData.Humanoid.Health <= 0 then
            botData.State = BotStates.Dead
            botModel:Destroy()
            activeBots[botModel] = nil

            -- Respawn bot after delay
            wait(10)
            if #activeBots < BotConfig.MaxBots then
                local spawnPosition = botModel.PrimaryPart.Position
                IntelligentBotSystem.CreateBot(spawnPosition)
            end
        else
            -- Bot gets angry and targets attacker
            botData.Target = player
            botData.State = BotStates.Chasing
        end
    end
end

-- Initialize bot system
function IntelligentBotSystem.Initialize()
    -- Spawn initial bots
    IntelligentBotSystem.SpawnInitialBots()

    -- Listen for bot damage events
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not remoteEvents then
        remoteEvents = Instance.new("Folder")
        remoteEvents.Name = "RemoteEvents"
        remoteEvents.Parent = ReplicatedStorage
    end

    if not remoteEvents:FindFirstChild("BotDamaged") then
        local botDamageRemote = Instance.new("RemoteEvent")
        botDamageRemote.Name = "BotDamaged"
        botDamageRemote.Parent = remoteEvents

        botDamageRemote.OnServerEvent:Connect(function(player, botModel, damage)
            IntelligentBotSystem.DamageBot(botModel, damage, player)
        end)
    end

    print("🤖 Intelligent Bot System initialized!")
end

-- Get active bot count
function IntelligentBotSystem.GetBotCount()
    return #activeBots
end

-- Respawn all bots
function IntelligentBotSystem.RespawnAllBots()
    -- Clear existing bots
    for botModel, _ in pairs(activeBots) do
        botModel:Destroy()
    end
    activeBots = {}

    -- Spawn new bots
    IntelligentBotSystem.SpawnInitialBots()
end

return IntelligentBotSystem
