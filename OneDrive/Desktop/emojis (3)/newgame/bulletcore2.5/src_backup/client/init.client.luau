-- BULLETCORE 2 Client Initialization
print("🎮 BULLETCORE 2 Client Starting...")

-- Initialize core systems
local ErrorHandler = require(script.Parent.ErrorHandler)
ErrorHandler.Initialize()

local SoundSystem = require(script.Parent.SoundSystem)
SoundSystem.Initialize()

local PerformanceMonitor = require(script.Parent.PerformanceMonitor)
PerformanceMonitor.Initialize()

local MobileControls = require(script.Parent.MobileControls)
MobileControls.Initialize()

local AutoSprintSystem = require(script.Parent.AutoSprintSystem)
AutoSprintSystem.Initialize()

local GameTester = require(script.Parent.GameTester)
GameTester.Initialize()

local WeaponClient = require(script.Parent.WeaponClient)
WeaponClient.Initialize()

local VisualEffects = require(script.Parent.VisualEffects)
VisualEffects.Initialize()

local AdvancedLighting = require(script.Parent.AdvancedLighting)
AdvancedLighting.Initialize()

-- Initialize UI systems
local SettingsGUI = require(script.Parent.SettingsGUI)
SettingsGUI.Initialize()

local ModernShopGUI = require(script.Parent.ModernShopGUI)
local AdminPanel = require(script.Parent.AdminPanelGUI)
AdminPanel.Initialize()

local CharacterCreator = require(script.Parent.CharacterCreatorGUI)
CharacterCreator.Initialize()

local DailyRewards = require(script.Parent.DailyRewardsGUI)
DailyRewards.Initialize()

local ClanGUI = require(script.Parent.ClanGUIGUI)
ClanGUI.Initialize()

-- Initialize other client systems (placeholders for now)
local function initializeMainMenu()
    print("✅ Main Menu loaded!")
end

local function initializeHUD()
    print("✅ HUD loaded!")
end

local function initializeCameraController()
    print("✅ Camera Controller loaded!")
end

-- Initialize systems
initializeMainMenu()
initializeHUD()
initializeCameraController()

print("🚀 BULLETCORE 2 Client fully loaded with all systems, visual assets, and advanced lighting!")
