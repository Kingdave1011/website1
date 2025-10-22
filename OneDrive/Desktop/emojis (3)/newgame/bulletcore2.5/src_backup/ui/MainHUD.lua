-- BULLETCORE 2 - Advanced Tactical HUD
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- Remove existing HUD
local existingHUD = playerGui:FindFirstChild("BulletCoreHUD")
if existingHUD then
    existingHUD:Destroy()
end

-- Create main HUD
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BulletCoreHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Tactical Crosshair System
local crosshair = Instance.new("Frame")
crosshair.Name = "TacticalCrosshair"
crosshair.Size = UDim2.new(0, 30, 0, 30)
crosshair.Position = UDim2.new(0.5, -15, 0.5, -15)
crosshair.BackgroundTransparency = 1
crosshair.Parent = screenGui

-- Crosshair center dot
local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.new(0, 4, 0, 4)
centerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
centerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
centerDot.BorderSizePixel = 0
centerDot.Parent = crosshair

local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(1, 0)
centerCorner.Parent = centerDot

-- Crosshair lines
local crosshairLines = {}
for i = 1, 4 do
    local line = Instance.new("Frame")
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BackgroundTransparency = 0.8
    line.BorderSizePixel = 0
    line.Parent = crosshair
    table.insert(crosshairLines, line)
end

-- Position crosshair lines (tactical style)
crosshairLines[1].Size = UDim2.new(0, 12, 0, 2) -- Top
crosshairLines[1].Position = UDim2.new(0.5, -6, 0.3, 0)
crosshairLines[2].Size = UDim2.new(0, 12, 0, 2) -- Bottom
crosshairLines[2].Position = UDim2.new(0.5, -6, 0.7, -2)
crosshairLines[3].Size = UDim2.new(0, 2, 0, 12) -- Left
crosshairLines[3].Position = UDim2.new(0.3, 0, 0.5, -6)
crosshairLines[4].Size = UDim2.new(0, 2, 0, 12) -- Right
crosshairLines[4].Position = UDim2.new(0.7, -2, 0.5, -6)

-- Compact Health & Armor System (Bottom Left)
local healthContainer = Instance.new("Frame")
healthContainer.Name = "HealthContainer"
healthContainer.Size = UDim2.new(0, 180, 0, 45)
healthContainer.Position = UDim2.new(0.015, 0, 0.88, 0)
healthContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
healthContainer.BackgroundTransparency = 0.4
healthContainer.BorderSizePixel = 0
healthContainer.Parent = screenGui

local healthCorner = Instance.new("UICorner")
healthCorner.CornerRadius = UDim.new(0, 6)
healthCorner.Parent = healthContainer

-- Health Bar (Horizontal)
local healthBg = Instance.new("Frame")
healthBg.Size = UDim2.new(0.75, 0, 0, 12)
healthBg.Position = UDim2.new(0.05, 0, 0.3, 0)
healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
healthBg.BorderSizePixel = 0
healthBg.Parent = healthContainer

local healthBgCorner = Instance.new("UICorner")
healthBgCorner.CornerRadius = UDim.new(0, 6)
healthBgCorner.Parent = healthBg

-- Health Bar Fill
local healthBar = Instance.new("Frame")
healthBar.Size = UDim2.new(1, 0, 1, 0)
healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
healthBar.BorderSizePixel = 0
healthBar.Parent = healthBg

local healthBarCorner = Instance.new("UICorner")
healthBarCorner.CornerRadius = UDim.new(0, 6)
healthBarCorner.Parent = healthBar

local healthGradient = Instance.new("UIGradient")
healthGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 0))
}
healthGradient.Parent = healthBar

-- Compact Health Text
local healthText = Instance.new("TextLabel")
healthText.Size = UDim2.new(0.75, 0, 0.4, 0)
healthText.Position = UDim2.new(0.05, 0, 0.05, 0)
healthText.BackgroundTransparency = 1
healthText.Text = "100%"
healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
healthText.Font = Enum.Font.SourceSansBold
healthText.TextScaled = true
healthText.Parent = healthContainer

-- Armor Bar (Small)
local armorBg = Instance.new("Frame")
armorBg.Size = UDim2.new(0.2, 0, 0, 8)
armorBg.Position = UDim2.new(0.82, 0, 0.4, 0)
armorBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
armorBg.BorderSizePixel = 0
armorBg.Parent = healthContainer

local armorBar = Instance.new("Frame")
armorBar.Size = UDim2.new(0, 0, 1, 0)
armorBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
armorBar.BorderSizePixel = 0
armorBar.Parent = armorBg

-- Compact Minimap (Top Right Corner)
local minimapContainer = Instance.new("Frame")
minimapContainer.Name = "MinimapContainer"
minimapContainer.Size = UDim2.new(0, 120, 0, 120)
minimapContainer.Position = UDim2.new(0.985, -135, 0.015, 0)
minimapContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
minimapContainer.BackgroundTransparency = 0.5
minimapContainer.BorderSizePixel = 0
minimapContainer.Parent = screenGui

local minimapCorner = Instance.new("UICorner")
minimapCorner.CornerRadius = UDim.new(0, 8)
minimapCorner.Parent = minimapContainer

-- Minimap Display
local minimapDisplay = Instance.new("Frame")
minimapDisplay.Size = UDim2.new(0.9, 0, 0.9, 0)
minimapDisplay.Position = UDim2.new(0.05, 0, 0.05, 0)
minimapDisplay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minimapDisplay.BorderSizePixel = 0
minimapDisplay.Parent = minimapContainer

local minimapCorner2 = Instance.new("UICorner")
minimapCorner2.CornerRadius = UDim.new(0, 6)
minimapCorner2.Parent = minimapDisplay

-- Player dot on minimap
local playerDot = Instance.new("Frame")
playerDot.Size = UDim2.new(0, 4, 0, 4)
playerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
playerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
playerDot.BorderSizePixel = 0
playerDot.Parent = minimapDisplay

local playerDotCorner = Instance.new("UICorner")
playerDotCorner.CornerRadius = UDim.new(1, 0)
playerDotCorner.Parent = playerDot

-- Compact Compass (Top Center)
local compassFrame = Instance.new("Frame")
compassFrame.Size = UDim2.new(0, 100, 0, 25)
compassFrame.Position = UDim2.new(0.5, -50, 0.02, 0)
compassFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
compassFrame.BackgroundTransparency = 0.6
compassFrame.BorderSizePixel = 0
compassFrame.Parent = screenGui

local compassCorner = Instance.new("UICorner")
compassCorner.CornerRadius = UDim.new(0, 12)
compassCorner.Parent = compassFrame

local compassText = Instance.new("TextLabel")
compassText.Size = UDim2.new(1, 0, 1, 0)
compassText.BackgroundTransparency = 1
compassText.Text = "N"
compassText.TextColor3 = Color3.fromRGB(255, 255, 255)
compassText.Font = Enum.Font.SourceSansBold
compassText.Parent = compassFrame

-- Compact Money Display (Top Right, below minimap)
local moneyContainer = Instance.new("Frame")
moneyContainer.Name = "MoneyContainer"
moneyContainer.Size = UDim2.new(0, 120, 0, 35)
moneyContainer.Position = UDim2.new(0.985, -135, 0.15, 0)
moneyContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
moneyContainer.BackgroundTransparency = 0.5
moneyContainer.BorderSizePixel = 0
moneyContainer.Parent = screenGui

local moneyCorner = Instance.new("UICorner")
moneyCorner.CornerRadius = UDim.new(0, 6)
moneyCorner.Parent = moneyContainer

local moneyText = Instance.new("TextLabel")
moneyText.Size = UDim2.new(1, 0, 1, 0)
moneyText.Position = UDim2.new(0, 0, 0, 0)
moneyText.BackgroundTransparency = 1
moneyText.Text = "0 XP"
moneyText.TextColor3 = Color3.fromRGB(255, 215, 0)
moneyText.Font = Enum.Font.SourceSansBold
moneyText.TextScaled = true
moneyText.Parent = moneyContainer

-- Compact Ammo Display (Bottom Right)
local ammoContainer = Instance.new("Frame")
ammoContainer.Name = "AmmoContainer"
ammoContainer.Size = UDim2.new(0, 140, 0, 60)
ammoContainer.Position = UDim2.new(0.985, -155, 0.91, 0)
ammoContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ammoContainer.BackgroundTransparency = 0.5
ammoContainer.BorderSizePixel = 0
ammoContainer.Parent = screenGui

local ammoCorner = Instance.new("UICorner")
ammoCorner.CornerRadius = UDim.new(0, 6)
ammoCorner.Parent = ammoContainer

-- Compact ammo display
local ammoDisplay = Instance.new("TextLabel")
ammoDisplay.Size = UDim2.new(1, 0, 0.5, 0)
ammoDisplay.Position = UDim2.new(0, 0, 0.1, 0)
ammoDisplay.BackgroundTransparency = 1
ammoDisplay.Text = "15/45"
ammoDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
ammoDisplay.Font = Enum.Font.SourceSansBold
ammoDisplay.TextScaled = true
ammoDisplay.Parent = ammoContainer

local weaponName = Instance.new("TextLabel")
weaponName.Size = UDim2.new(1, 0, 0.3, 0)
weaponName.Position = UDim2.new(0, 0, 0.65, 0)
weaponName.BackgroundTransparency = 1
weaponName.Text = "PISTOL"
weaponName.TextColor3 = Color3.fromRGB(255, 150, 0)
weaponName.Font = Enum.Font.SourceSansBold
weaponName.TextScaled = true
weaponName.Parent = ammoContainer

-- Low ammo warning indicator (compact)
local lowAmmoWarning = Instance.new("Frame")
lowAmmoWarning.Size = UDim2.new(1, 0, 1, 0)
lowAmmoWarning.Position = UDim2.new(0, 0, 0, 0)
lowAmmoWarning.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
lowAmmoWarning.BackgroundTransparency = 0.7
lowAmmoWarning.BorderSizePixel = 0
lowAmmoWarning.Visible = false
lowAmmoWarning.Parent = ammoContainer

local lowAmmoCorner = Instance.new("UICorner")
lowAmmoCorner.CornerRadius = UDim.new(0, 6)
lowAmmoCorner.Parent = lowAmmoWarning

-- Reload progress bar (compact)
local reloadBarBg = Instance.new("Frame")
reloadBarBg.Size = UDim2.new(0.9, 0, 0, 3)
reloadBarBg.Position = UDim2.new(0.05, 0, 0.9, 0)
reloadBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
reloadBarBg.BorderSizePixel = 0
reloadBarBg.Visible = false
reloadBarBg.Parent = ammoContainer

local reloadBar = Instance.new("Frame")
reloadBar.Size = UDim2.new(0, 0, 1, 0)
reloadBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
reloadBar.BorderSizePixel = 0
reloadBar.Parent = reloadBarBg

local reloadBarCorner = Instance.new("UICorner")
reloadBarCorner.CornerRadius = UDim.new(0, 1.5)
reloadBarCorner.Parent = reloadBarBg

-- Update crosshair position
RunService.Heartbeat:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    crosshair.Position = UDim2.new(0, mousePos.X - 15, 0, mousePos.Y - 15)
end)

-- Health update function (Compact)
local function updateHealth()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        local healthPercent = humanoid.Health / humanoid.MaxHealth

        healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)

        -- Compact percentage display
        if healthPercent >= 1 then
            healthText.Text = "100%"
        elseif healthPercent > 0 then
            healthText.Text = math.floor(healthPercent * 100) .. "%"
        else
            healthText.Text = "0%"
        end

        -- Dynamic health bar color
        if healthPercent > 0.7 then
            healthGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 0))
            }
        elseif healthPercent > 0.4 then
            healthGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 0))
            }
        else
            healthGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0))
            }
        end
    end
end

-- Armor update function
local function updateArmor(armorPercent)
    armorBar.Size = UDim2.new(armorPercent, 0, 1, 0)
end

-- Character events
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.HealthChanged:Connect(updateHealth)
    updateHealth()
end)

if player.Character then
    updateHealth()
end

-- Compass update
RunService.Heartbeat:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local direction = player.Character.HumanoidRootPart.CFrame.LookVector
        local angle = math.atan2(direction.X, direction.Z) * 180 / math.pi

        if angle < -22.5 then
            compassText.Text = "NW ↖"
        elseif angle < 22.5 then
            compassText.Text = "N ↑"
        elseif angle < 67.5 then
            compassText.Text = "NE ↗"
        elseif angle < 112.5 then
            compassText.Text = "E →"
        elseif angle < 157.5 then
            compassText.Text = "SE ↘"
        elseif angle < -157.5 or angle > 157.5 then
            compassText.Text = "S ↓"
        elseif angle < -112.5 then
            compassText.Text = "SW ↙"
        elseif angle < -67.5 then
            compassText.Text = "W ←"
        end
    end
end)

-- Money/XP update function
local function updateMoneyDisplay(xp)
    moneyText.Text = tostring(xp) .. " XP"
    -- Add a subtle animation when money changes
    TweenService:Create(moneyText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 100)}):Play()
    wait(0.2)
    TweenService:Create(moneyText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 215, 0)}):Play()
end

-- Listen for remote events
if ReplicatedStorage:FindFirstChild("RemoteEvents") then
    local remoteEvents = ReplicatedStorage.RemoteEvents

    -- Update stats event (includes XP/money updates)
    local updateStatsRemote = remoteEvents:FindFirstChild("UpdateStats")
    if updateStatsRemote then
        updateStatsRemote.OnClientEvent:Connect(function(stats)
            if stats and stats.XP then
                updateMoneyDisplay(stats.XP)
            end
            if stats and stats.Level then
                -- Could add level display here if needed
                print("Level updated to:", stats.Level)
            end
        end)
    end

    -- Update ammo event with enhanced visuals
    local updateAmmoRemote = remoteEvents:FindFirstChild("UpdateAmmo")
    if updateAmmoRemote then
        updateAmmoRemote.OnClientEvent:Connect(function(current, total, weapon)
            ammoDisplay.Text = tostring(current) .. "/" .. tostring(total)
            weaponName.Text = weapon or "UNKNOWN"

            -- Low ammo warning system
            local ammoPercent = current / 15 -- Assuming pistol magazine size
            if weapon == "Pistol" then
                ammoPercent = current / 15
            elseif weapon == "AssaultRifle" then
                ammoPercent = current / 30
            elseif weapon == "Shotgun" then
                ammoPercent = current / 8
            elseif weapon == "Sniper" then
                ammoPercent = current / 5
            end

            if ammoPercent <= 0.25 and current > 0 then -- 25% or less ammo
                lowAmmoWarning.Visible = true
                -- Pulsing effect for low ammo
                TweenService:Create(lowAmmoWarning, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.3}):Play()
            else
                lowAmmoWarning.Visible = false
                lowAmmoWarning.BackgroundTransparency = 0.7
            end

            -- Change ammo text color based on ammo level
            if ammoPercent <= 0.25 then
                ammoDisplay.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red for low ammo
            elseif ammoPercent <= 0.5 then
                ammoDisplay.TextColor3 = Color3.fromRGB(255, 255, 100) -- Yellow for medium ammo
            else
                ammoDisplay.TextColor3 = Color3.fromRGB(255, 255, 255) -- White for good ammo
            end
        end)
    end

    -- Listen for reload start event from client
    local reloadStartRemote = remoteEvents:FindFirstChild("ReloadStart")
    if not reloadStartRemote then
        -- Create reload start event if it doesn't exist
        reloadStartRemote = Instance.new("RemoteEvent")
        reloadStartRemote.Name = "ReloadStart"
        reloadStartRemote.Parent = remoteEvents
    end

    reloadStartRemote.OnClientEvent:Connect(function(reloadTime)
        -- Show reload progress bar
        reloadBarBg.Visible = true
        reloadBar.Size = UDim2.new(0, 0, 1, 0)

        -- Animate reload progress
        local tween = TweenService:Create(reloadBar, TweenInfo.new(reloadTime), {Size = UDim2.new(1, 0, 1, 0)})
        tween:Play()

        -- Hide reload bar when done
        tween.Completed:Connect(function()
            reloadBarBg.Visible = false
        end)
    end)

    -- Money/XP change event (for immediate updates)
    local moneyChangeRemote = remoteEvents:FindFirstChild("MoneyChange")
    if moneyChangeRemote then
        moneyChangeRemote.OnClientEvent:Connect(function(newXP)
            updateMoneyDisplay(newXP)
        end)
    end
end

-- Initialize money display on load
local function initializeMoneyDisplay()
    if ReplicatedStorage:FindFirstChild("RemoteEvents") then
        local remoteEvents = ReplicatedStorage.RemoteEvents
        local updateStatsRemote = remoteEvents:FindFirstChild("UpdateStats")
        if updateStatsRemote then
            -- Request current stats from server
            updateStatsRemote:FireServer()
        end
    end
end

-- Initialize after a short delay to ensure everything is loaded
wait(1)
initializeMoneyDisplay()

-- Hit marker effect
local hitMarker = Instance.new("Frame")
hitMarker.Size = UDim2.new(0, 40, 0, 40)
hitMarker.Position = UDim2.new(0.5, -20, 0.5, -20)
hitMarker.BackgroundTransparency = 1
hitMarker.Visible = false
hitMarker.Parent = screenGui

for i = 1, 4 do
    local line = Instance.new("Frame")
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    line.BorderSizePixel = 0
    line.Parent = hitMarker

    if i == 1 then
        line.Size = UDim2.new(0, 20, 0, 2)
        line.Position = UDim2.new(0.5, -10, 0, 0)
    elseif i == 2 then
        line.Size = UDim2.new(0, 20, 0, 2)
        line.Position = UDim2.new(0.5, -10, 1, -2)
    elseif i == 3 then
        line.Size = UDim2.new(0, 2, 0, 20)
        line.Position = UDim2.new(0, 0, 0.5, -10)
    else
        line.Size = UDim2.new(0, 2, 0, 20)
        line.Position = UDim2.new(1, -2, 0.5, -10)
    end
end

-- Function to show hit marker
local function showHitMarker()
    hitMarker.Visible = true
    TweenService:Create(hitMarker, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    wait(0.2)
    TweenService:Create(hitMarker, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    hitMarker.Visible = false
end

-- Listen for hit events
if ReplicatedStorage:FindFirstChild("RemoteEvents") then
    local hitRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("HitMarker")
    if hitRemote then
        hitRemote.OnClientEvent:Connect(showHitMarker)
    end
end

print("🎯 BULLETCORE 2 Tactical HUD loaded successfully!")
