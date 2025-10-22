-- Achievement Unlocked Event
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local achievementEvent = Instance.new("RemoteEvent")
achievementEvent.Name = "AchievementUnlocked"
achievementEvent.Parent = ReplicatedStorage.Events

return achievementEvent
