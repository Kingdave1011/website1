-- BULLETCORE 2 Server Initialization
print("🎮 BULLETCORE 2 Server Starting...")

-- Initialize core systems
local WeaponHandler = require(script.Parent.WeaponHandler)
WeaponHandler.Initialize()

local AdminSystem = require(script.Parent.AdminSystem)
AdminSystem.Initialize()

local IntelligentBotSystem = require(script.Parent.IntelligentBotSystem)
IntelligentBotSystem.Initialize()

local ChatTagSystem = require(script.Parent.ChatTagSystem)
ChatTagSystem.Initialize()

local ClanSystem = require(script.Parent.ClanSystem)
ClanSystem.Initialize()

-- Initialize other systems (placeholders for now)
local function initializeGameManager()
    print("✅ Game Manager loaded!")
end

local function initializePlayerDataManager()
    print("✅ Player Data Manager loaded!")
end

local function initializeShopManager()
    print("✅ Shop Manager loaded!")
end

-- Initialize systems
initializeGameManager()
initializePlayerDataManager()
initializeShopManager()

print("🚀 BULLETCORE 2 Server fully loaded with all systems!")
