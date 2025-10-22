-- Hit Effects and Feedback
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Hit marker sound
local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxasset://sounds/impact_water.mp3"
hitSound.Volume = 0.5
hitSound.Parent = SoundService

-- Create hit marker
local function createHitMarker(position)
    local hitMarker = Instance.new("BillboardGui")
    hitMarker.Size = UDim2.new(0, 100, 0, 50)
    hitMarker.StudsOffset = Vector3.new(0, 2, 0)
    hitMarker.Parent = workspace
    
    local damageLabel = Instance.new("TextLabel")
    damageLabel.Size = UDim2.new(1, 0, 1, 0)
    damageLabel.BackgroundTransparency = 1
    damageLabel.Text = "-25"
    damageLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    damageLabel.TextScaled = true
    damageLabel.Font = Enum.Font.GothamBold
    damageLabel.Parent = hitMarker
    
    -- Animate hit marker
    local tween = TweenService:Create(damageLabel, TweenInfo.new(1), {
        Position = UDim2.new(0, 0, -1, 0),
        TextTransparency = 1
    })
    tween:Play()
    
    -- Clean up
    tween.Completed:Connect(function()
        hitMarker:Destroy()
    end)
    
    -- Position at hit location
    hitMarker.Adornee = workspace.Terrain
    hitMarker.StudsOffset = position
end

-- Listen for hit events
if ReplicatedStorage:FindFirstChild("RemoteEvents") then
    local hitRemote = ReplicatedStorage.RemoteEvents:WaitForChild("Hit")
    hitRemote.OnClientEvent:Connect(function(targetPlayer, hitPosition, damage)
        -- Play hit sound
        hitSound:Play()
        
        -- Create hit marker
        createHitMarker(hitPosition)
        
        -- Screen flash for the hit player
        if targetPlayer == player then
            local screenGui = player.PlayerGui:FindFirstChild("BulletCoreHUD")
            if screenGui then
                local flash = Instance.new("Frame")
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                flash.BackgroundTransparency = 0.7
                flash.BorderSizePixel = 0
                flash.Parent = screenGui
                
                local flashTween = TweenService:Create(flash, TweenInfo.new(0.3), {
                    BackgroundTransparency = 1
                })
                flashTween:Play()
                
                flashTween.Completed:Connect(function()
                    flash:Destroy()
                end)
            end
        end
    end)
end