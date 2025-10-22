-- BulletCore Game Manager
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InsertService = game:GetService("InsertService")
local TeleportService = game:GetService("TeleportService")

local GameManager = {}

-- Game Configuration
local LOBBY_MAP_ID = 204235576
local GAME_MAP_ID = 12692728709
local SPAWN_RADIUS = 10

-- Player states
local playerStates = {} -- "lobby" or "game"

-- Remote Events
local remoteEvents = Instance.new("Folder")
remoteEvents.Name = "RemoteEvents"
remoteEvents.Parent = ReplicatedStorage

local joinGameRemote = Instance.new("RemoteEvent")
joinGameRemote.Name = "JoinGame"
joinGameRemote.Parent = remoteEvents

-- Load maps
local function loadMap(mapId)
    local success, model = pcall(function()
        return InsertService:LoadAsset(mapId)
    end)
    
    if success and model then
        model.Parent = workspace
        return model
    end
    return nil
end

-- Create spawn points around the main spawn
local function createSpawnPoints(mainSpawn, folderName)
    local spawnFolder = Instance.new("Folder")
    spawnFolder.Name = folderName
    spawnFolder.Parent = workspace
    
    -- Create multiple spawn points in a circle around the main spawn
    for i = 1, 8 do
        local angle = (i - 1) * (math.pi * 2 / 8)
        local x = mainSpawn.Position.X + math.cos(angle) * SPAWN_RADIUS
        local z = mainSpawn.Position.Z + math.sin(angle) * SPAWN_RADIUS
        
        local spawnPoint = mainSpawn:Clone()
        spawnPoint.Name = "SpawnPoint" .. i
        spawnPoint.Position = Vector3.new(x, mainSpawn.Position.Y, z)
        spawnPoint.Parent = spawnFolder
    end
    
    return spawnFolder
end

-- Initialize game
local function initialize()
    -- Load lobby map
    local lobbyMap = loadMap(LOBBY_MAP_ID)
    if lobbyMap then
        print("Lobby map loaded successfully")
        
        -- Find the main spawn point and create additional spawns
        local mainSpawn = lobbyMap:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("SpawnLocation")
        if mainSpawn then
            createSpawnPoints(mainSpawn, "LobbySpawns")
        end
    end
    
    -- Load game map
    local gameMap = loadMap(GAME_MAP_ID)
    if gameMap then
        print("Game map loaded successfully")
        
        -- Find game spawn points
        local gameSpawn = gameMap:FindFirstChild("SpawnLocation")
        if gameSpawn then
            createSpawnPoints(gameSpawn, "GameSpawns")
        end
    end
end

-- Spawn player in lobby
local function spawnInLobby(player)
    local character = player.Character
    if not character then return end
    
    local spawnFolder = workspace:FindFirstChild("LobbySpawns")
    if spawnFolder then
        local spawnPoints = spawnFolder:GetChildren()
        if #spawnPoints > 0 then
            local randomSpawn = spawnPoints[math.random(1, #spawnPoints)]
            character:SetPrimaryPartCFrame(randomSpawn.CFrame + Vector3.new(0, 5, 0))
        end
    end
    playerStates[player.UserId] = "lobby"
end

-- Spawn player in game area
local function spawnInGame(player)
    local character = player.Character
    if not character then return end
    
    local spawnFolder = workspace:FindFirstChild("GameSpawns")
    if spawnFolder then
        local spawnPoints = spawnFolder:GetChildren()
        if #spawnPoints > 0 then
            local randomSpawn = spawnPoints[math.random(1, #spawnPoints)]
            character:SetPrimaryPartCFrame(randomSpawn.CFrame + Vector3.new(0, 5, 0))
        end
    end
    playerStates[player.UserId] = "game"
end

-- Handle join game request
joinGameRemote.OnServerEvent:Connect(function(player)
    spawnInGame(player)
end)

-- Player spawning (always start in lobby)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(0.1)
        spawnInLobby(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    playerStates[player.UserId] = nil
end)

initialize()