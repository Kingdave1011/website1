-- Weapon Client Handler
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local WeaponClient = {}
local SoundSystem = require(script.Parent.SoundSystem)

-- Current weapon
local currentWeapon = "Pistol"
local isAiming = false
local canShoot = true
local isReloading = false

-- Create weapon UI
local function createWeaponUI()
    local weaponUI = Instance.new("ScreenGui")
    weaponUI.Name = "WeaponUI"
    weaponUI.ResetOnSpawn = false
    weaponUI.Parent = player.PlayerGui

    -- Weapon display
    local weaponDisplay = Instance.new("Frame")
    weaponDisplay.Size = UDim2.new(0, 300, 0, 100)
    weaponDisplay.Position = UDim2.new(0.5, -150, 1, -120)
    weaponDisplay.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    weaponDisplay.BackgroundTransparency = 0.5
    weaponDisplay.BorderSizePixel = 0
    weaponDisplay.Parent = weaponUI

    local weaponCorner = Instance.new("UICorner")
    weaponCorner.CornerRadius = UDim.new(0, 8)
    weaponCorner.Parent = weaponDisplay

    -- Weapon name
    local weaponName = Instance.new("TextLabel")
    weaponName.Size = UDim2.new(1, 0, 0.4, 0)
    weaponName.Position = UDim2.new(0, 0, 0, 0)
    weaponName.BackgroundTransparency = 1
    weaponName.Text = "PISTOL"
    weaponName.TextColor3 = Color3.fromRGB(255, 150, 0)
    weaponName.Font = Enum.Font.SourceSansBold
    weaponName.Parent = weaponDisplay

    -- Ammo display
    local ammoDisplay = Instance.new("TextLabel")
    ammoDisplay.Size = UDim2.new(1, 0, 0.6, 0)
    ammoDisplay.Position = UDim2.new(0, 0, 0.4, 0)
    ammoDisplay.BackgroundTransparency = 1
    ammoDisplay.Text = "12 / 36"
    ammoDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    ammoDisplay.Font = Enum.Font.SourceSansBold
    ammoDisplay.TextScaled = true
    ammoDisplay.Parent = weaponDisplay

    return weaponUI, weaponDisplay, weaponName, ammoDisplay
end

-- Shoot function
local function shoot()
    if not canShoot or isReloading then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local targetPosition = mouse.Hit.Position

    -- Call server to handle shooting
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        local shootRemote = remoteEvents:FindFirstChild("Shoot")
        if shootRemote then
            shootRemote:FireServer(currentWeapon, targetPosition)
        end
    end

    -- Play shooting sound effect
    SoundSystem.PlayWeaponSound(currentWeapon, "Shoot")

    -- Enhanced screen shake effect based on weapon type
    local shakeIntensity = 0.1
    if currentWeapon == "Shotgun" then
        shakeIntensity = 0.15
    elseif currentWeapon == "Sniper" then
        shakeIntensity = 0.08
    elseif currentWeapon == "AssaultRifle" then
        shakeIntensity = 0.12
    end

    local camera = workspace.CurrentCamera
    if camera then
        local shakeTween = TweenService:Create(camera, TweenInfo.new(0.1), {
            CFrame = camera.CFrame * CFrame.new(
                math.random(-shakeIntensity, shakeIntensity),
                math.random(-shakeIntensity, shakeIntensity),
                0
            )
        })
        shakeTween:Play()
    end

    -- Weapon-specific fire rate delays
    local fireRate = 0.5 -- Default for pistol
    if currentWeapon == "AssaultRifle" then
        fireRate = 0.1
    elseif currentWeapon == "Shotgun" then
        fireRate = 0.8
    elseif currentWeapon == "Sniper" then
        fireRate = 1.5
    end

    canShoot = false
    wait(fireRate)
    canShoot = true
end

-- Reload function
local function reload()
    if isReloading then return end

    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        local reloadRemote = remoteEvents:FindFirstChild("Reload")
        if reloadRemote then
            isReloading = true

            -- Get weapon-specific reload time
            local reloadTime = 2.0 -- Default for pistol
            if currentWeapon == "AssaultRifle" then
                reloadTime = 2.5
            elseif currentWeapon == "Shotgun" then
                reloadTime = 3.0
            elseif currentWeapon == "Sniper" then
                reloadTime = 4.0
            end

            -- Fire reload start event to HUD for progress display
            local reloadStartRemote = remoteEvents:FindFirstChild("ReloadStart")
            if reloadStartRemote then
                reloadStartRemote:FireServer(reloadTime)
            end

            -- Fire reload event to server
            reloadRemote:FireServer(currentWeapon, reloadTime)

            -- Play reload sound immediately
            SoundSystem.PlayWeaponSound(currentWeapon, "Reload")

            -- Wait for reload to complete
            wait(reloadTime)
            isReloading = false
        end
    end
end

-- Auto-reload when out of ammo
local function checkAmmoAndReload()
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        local updateAmmoRemote = remoteEvents:FindFirstChild("UpdateAmmo")
        if updateAmmoRemote then
            -- Listen for ammo updates to trigger auto-reload
            updateAmmoRemote.OnClientEvent:Connect(function(current, total, weapon)
                if current <= 0 and total > 0 and not isReloading then
                    -- Auto-reload when out of ammo
                    reload()
                end
            end)
        end
    end
end

-- Switch weapon function
local function switchWeapon(weaponName)
    if weaponName == currentWeapon then return end

    local allowedWeapons = {"Pistol", "AssaultRifle", "Shotgun", "Sniper"}
    local weaponIndex = 0

    for i, weapon in ipairs(allowedWeapons) do
        if weapon == currentWeapon then
            weaponIndex = i
            break
        end
    end

    if weaponIndex > 0 then
        if weaponName then
            -- Switch to specific weapon if available
            for _, weapon in ipairs(allowedWeapons) do
                if weapon == weaponName then
                    currentWeapon = weaponName
                    break
                end
            end
        else
            -- Cycle to next weapon
            weaponIndex = (weaponIndex % #allowedWeapons) + 1
            currentWeapon = allowedWeapons[weaponIndex]
        end

        -- Update UI
        if weaponUI and weaponName then
            weaponName.Text = string.upper(currentWeapon)
        end

        print("Switched to weapon: " .. currentWeapon)
    end
end

-- Initialize weapon client
function WeaponClient.Initialize()
    local weaponUI, weaponDisplay, weaponName, ammoDisplay = createWeaponUI()

    -- Listen for ammo updates
    local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if remoteEvents then
        local updateAmmoRemote = remoteEvents:FindFirstChild("UpdateAmmo")
        if updateAmmoRemote then
            updateAmmoRemote.OnClientEvent:Connect(function(current, total, weapon)
                ammoDisplay.Text = current .. " / " .. total
                weaponName.Text = weapon
                currentWeapon = weapon
            end)
        end
    end

    -- Input handling
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            shoot()
        elseif input.KeyCode == Enum.KeyCode.R then
            reload()
        elseif input.KeyCode == Enum.KeyCode.Q then
            switchWeapon() -- Cycle weapons
        elseif input.KeyCode == Enum.KeyCode.One then
            switchWeapon("Pistol")
        elseif input.KeyCode == Enum.KeyCode.Two then
            switchWeapon("AssaultRifle")
        elseif input.KeyCode == Enum.KeyCode.Three then
            switchWeapon("Shotgun")
        elseif input.KeyCode == Enum.KeyCode.Four then
            switchWeapon("Sniper")
        end
    end)

    -- Aim down sights
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            isAiming = true
            -- Zoom in camera for ADS
            local camera = workspace.CurrentCamera
            if camera then
                TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = 50}):Play()
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            isAiming = false
            -- Zoom out camera
            local camera = workspace.CurrentCamera
            if camera then
                TweenService:Create(camera, TweenInfo.new(0.3), {FieldOfView = 70}):Play()
            end
        end
    end)

    print("🔫 Weapon Client initialized!")
end

return WeaponClient
