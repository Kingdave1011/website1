-- Comprehensive Game Testing and Quality Assurance System
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local GameTester = {}

-- Test results tracking
local testResults = {
    SystemsLoaded = {},
    PerformanceTests = {},
    FunctionalityTests = {},
    CompatibilityTests = {},
    ErrorTests = {}
}

-- Test configuration
local testConfig = {
    EnableAutoTesting = true,
    TestInterval = 5, -- seconds between automated tests
    EnableStressTesting = false,
    MaxStressDuration = 30, -- seconds
    LogTestResults = true
}

-- System health monitoring
local systemHealth = {
    WeaponSystem = {Status = "Unknown", LastCheck = 0},
    SoundSystem = {Status = "Unknown", LastCheck = 0},
    ClanSystem = {Status = "Unknown", LastCheck = 0},
    ShopSystem = {Status = "Unknown", LastCheck = 0},
    PerformanceMonitor = {Status = "Unknown", LastCheck = 0},
    MobileControls = {Status = "Unknown", LastCheck = 0},
    ErrorHandler = {Status = "Unknown", LastCheck = 0}
}

-- Create test interface UI
local function createTestUI()
    local testUI = Instance.new("ScreenGui")
    testUI.Name = "GameTesterUI"
    testUI.ResetOnSpawn = false
    testUI.Parent = player.PlayerGui

    -- Test control panel
    local testFrame = Instance.new("Frame")
    testFrame.Size = UDim2.new(0, 300, 0, 400)
    testFrame.Position = UDim2.new(0, 10, 0.5, -200)
    testFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    testFrame.BackgroundTransparency = 0.3
    testFrame.BorderSizePixel = 0
    testFrame.Visible = false
    testFrame.Parent = testUI

    local testCorner = Instance.new("UICorner")
    testCorner.CornerRadius = UDim.new(0, 8)
    testCorner.Parent = testFrame

    local testStroke = Instance.new("UIStroke")
    testStroke.Color = Color3.fromRGB(100, 200, 255)
    testStroke.Thickness = 2
    testStroke.Parent = testFrame

    -- Test title
    local testTitle = Instance.new("TextLabel")
    testTitle.Size = UDim2.new(1, 0, 0, 30)
    testTitle.Position = UDim2.new(0, 0, 0, 0)
    testTitle.BackgroundTransparency = 1
    testTitle.Text = "🧪 GAME TESTER"
    testTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    testTitle.Font = Enum.Font.SourceSansBold
    testTitle.TextScaled = true
    testTitle.Parent = testFrame

    -- Test buttons
    local testButtons = {}

    -- Run All Tests Button
    local runAllButton = Instance.new("TextButton")
    runAllButton.Size = UDim2.new(1, -20, 0, 35)
    runAllButton.Position = UDim2.new(0, 10, 0, 40)
    runAllButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    runAllButton.BackgroundTransparency = 0.2
    runAllButton.BorderSizePixel = 0
    runAllButton.Text = "▶ RUN ALL TESTS"
    runAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    runAllButton.Font = Enum.Font.SourceSansBold
    runAllButton.Parent = testFrame

    local runAllCorner = Instance.new("UICorner")
    runAllCorner.CornerRadius = UDim.new(0, 4)
    runAllCorner.Parent = runAllButton

    -- Performance Test Button
    local perfTestButton = Instance.new("TextButton")
    perfTestButton.Size = UDim2.new(1, -20, 0, 35)
    perfTestButton.Position = UDim2.new(0, 10, 0, 85)
    perfTestButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    perfTestButton.BackgroundTransparency = 0.2
    perfTestButton.BorderSizePixel = 0
    perfTestButton.Text = "📊 PERFORMANCE TEST"
    perfTestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    perfTestButton.Font = Enum.Font.SourceSansBold
    perfTestButton.Parent = testFrame

    local perfTestCorner = Instance.new("UICorner")
    perfTestCorner.CornerRadius = UDim.new(0, 4)
    perfTestCorner.Parent = perfTestButton

    -- Functionality Test Button
    local funcTestButton = Instance.new("TextButton")
    funcTestButton.Size = UDim2.new(1, -20, 0, 35)
    funcTestButton.Position = UDim2.new(0, 10, 0, 130)
    funcTestButton.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    funcTestButton.BackgroundTransparency = 0.2
    funcTestButton.BorderSizePixel = 0
    funcTestButton.Text = "🔧 FUNCTIONALITY TEST"
    funcTestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    funcTestButton.Font = Enum.Font.SourceSansBold
    funcTestButton.Parent = testFrame

    local funcTestCorner = Instance.new("UICorner")
    funcTestCorner.CornerRadius = UDim.new(0, 4)
    funcTestCorner.Parent = funcTestButton

    -- Compatibility Test Button
    local compatTestButton = Instance.new("TextButton")
    compatTestButton.Size = UDim2.new(1, -20, 0, 35)
    compatTestButton.Position = UDim2.new(0, 10, 0, 175)
    compatTestButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
    compatTestButton.BackgroundTransparency = 0.2
    compatTestButton.BorderSizePixel = 0
    compatTestButton.Text = "📱 COMPATIBILITY TEST"
    compatTestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    compatTestButton.Font = Enum.Font.SourceSansBold
    compatTestButton.Parent = testFrame

    local compatTestCorner = Instance.new("UICorner")
    compatTestCorner.CornerRadius = UDim.new(0, 4)
    compatTestCorner.Parent = compatTestButton

    -- Stress Test Button
    local stressTestButton = Instance.new("TextButton")
    stressTestButton.Size = UDim2.new(1, -20, 0, 35)
    stressTestButton.Position = UDim2.new(0, 10, 0, 220)
    stressTestButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    stressTestButton.BackgroundTransparency = 0.2
    stressTestButton.BorderSizePixel = 0
    stressTestButton.Text = "⚡ STRESS TEST"
    stressTestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stressTestButton.Font = Enum.Font.SourceSansBold
    stressTestButton.Parent = testFrame

    local stressTestCorner = Instance.new("UICorner")
    stressTestCorner.CornerRadius = UDim.new(0, 4)
    stressTestCorner.Parent = stressTestButton

    -- Test Results Display
    local resultsScroll = Instance.new("ScrollingFrame")
    resultsScroll.Size = UDim2.new(1, -20, 1, -290)
    resultsScroll.Position = UDim2.new(0, 10, 0, 265)
    resultsScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    resultsScroll.BackgroundTransparency = 0.5
    resultsScroll.ScrollBarThickness = 6
    resultsScroll.Parent = testFrame

    local resultsCorner = Instance.new("UICorner")
    resultsCorner.CornerRadius = UDim.new(0, 4)
    resultsCorner.Parent = resultsScroll

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(1, -110, 0, -5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BackgroundTransparency = 0.2
    closeButton.BorderSizePixel = 0
    closeButton.Text = "CLOSE"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = testFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton

    -- Store references
    testButtons = {
        RunAll = runAllButton,
        Performance = perfTestButton,
        Functionality = funcTestButton,
        Compatibility = compatTestButton,
        Stress = stressTestButton,
        ResultsScroll = resultsScroll,
        Close = closeButton
    }

    -- Connect button events
    runAllButton.MouseButton1Click:Connect(function()
        runAllTests()
    end)

    perfTestButton.MouseButton1Click:Connect(function()
        runPerformanceTests()
    end)

    funcTestButton.MouseButton1Click:Connect(function()
        runFunctionalityTests()
    end)

    compatTestButton.MouseButton1Click:Connect(function()
        runCompatibilityTests()
    end)

    stressTestButton.MouseButton1Click:Connect(function()
        runStressTest()
    end)

    closeButton.MouseButton1Click:Connect(function()
        testFrame.Visible = false
    end)

    return testUI, testFrame, testButtons
end

-- Test execution functions
local function runAllTests()
    print("🧪 Running comprehensive test suite...")

    -- Clear previous results
    testResults = {
        SystemsLoaded = {},
        PerformanceTests = {},
        FunctionalityTests = {},
        CompatibilityTests = {},
        ErrorTests = {}
    }

    -- Run all test categories
    runSystemLoadTests()
    runPerformanceTests()
    runFunctionalityTests()
    runCompatibilityTests()

    -- Display results
    displayTestResults()

    print("✅ All tests completed!")
end

local function runSystemLoadTests()
    print("🔍 Testing system loading...")

    -- Test core systems
    local systems = {
        {Name = "SoundSystem", Module = "SoundSystem"},
        {Name = "PerformanceMonitor", Module = "PerformanceMonitor"},
        {Name = "MobileControls", Module = "MobileControls"},
        {Name = "WeaponClient", Module = "WeaponClient"},
        {Name = "ErrorHandler", Module = "ErrorHandler"}
    }

    for _, system in ipairs(systems) do
        local success, result = pcall(function()
            local module = require(script.Parent[system.Module])
            if module and type(module.Initialize) == "function" then
                testResults.SystemsLoaded[system.Name] = {
                    Status = "PASS",
                    Message = system.Name .. " loaded successfully",
                    Timestamp = os.time()
                }
            else
                testResults.SystemsLoaded[system.Name] = {
                    Status = "FAIL",
                    Message = system.Name .. " missing Initialize function",
                    Timestamp = os.time()
                }
            end
        end)

        if not success then
            testResults.SystemsLoaded[system.Name] = {
                Status = "ERROR",
                Message = "Failed to load " .. system.Name .. ": " .. result,
                Timestamp = os.time()
            }
        end
    end
end

local function runPerformanceTests()
    print("📊 Running performance tests...")

    -- FPS Test
    local fps = 1 / RunService.RenderStepped:Wait()
    testResults.PerformanceTests.FPS = {
        Status = fps >= 30 and "PASS" or "WARNING",
        Value = math.floor(fps),
        Message = string.format("FPS: %d (Target: 30+)", math.floor(fps)),
        Timestamp = os.time()
    }

    -- Memory Test
    local stats = game:GetService("Stats")
    local memoryUsage = stats:GetTotalMemoryUsageMb()
    testResults.PerformanceTests.Memory = {
        Status = memoryUsage < 200 and "PASS" or (memoryUsage < 400 and "WARNING" or "FAIL"),
        Value = math.floor(memoryUsage),
        Message = string.format("Memory: %dMB (Target: <200MB)", math.floor(memoryUsage)),
        Timestamp = os.time()
    }

    -- Ping Test
    local ping = player:GetNetworkPing() * 1000
    testResults.PerformanceTests.Ping = {
        Status = ping < 100 and "PASS" or (ping < 200 and "WARNING" or "FAIL"),
        Value = math.floor(ping),
        Message = string.format("Ping: %dms (Target: <100ms)", math.floor(ping)),
        Timestamp = os.time()
    }
end

local function runFunctionalityTests()
    print("🔧 Running functionality tests...")

    -- Weapon System Test
    local weaponTest = testWeaponSystem()
    testResults.FunctionalityTests.WeaponSystem = weaponTest

    -- Sound System Test
    local soundTest = testSoundSystem()
    testResults.FunctionalityTests.SoundSystem = soundTest

    -- UI System Test
    local uiTest = testUISystems()
    testResults.FunctionalityTests.UISystems = uiTest

    -- Input System Test
    local inputTest = testInputSystems()
    testResults.FunctionalityTests.InputSystems = inputTest
end

local function runCompatibilityTests()
    print("📱 Running compatibility tests...")

    -- Device Detection Test
    local isMobile = UserInputService.TouchEnabled
    testResults.CompatibilityTests.DeviceDetection = {
        Status = "PASS",
        Message = "Device detected: " .. (isMobile and "Mobile" or "PC"),
        Timestamp = os.time()
    }

    -- Screen Resolution Test
    local camera = workspace.CurrentCamera
    local screenSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    testResults.CompatibilityTests.ScreenResolution = {
        Status = screenSize.X >= 800 and screenSize.Y >= 600 and "PASS" or "WARNING",
        Message = string.format("Resolution: %dx%d", screenSize.X, screenSize.Y),
        Timestamp = os.time()
    }

    -- UI Scaling Test
    local scaleFactor = math.min(screenSize.X / 1920, screenSize.Y / 1080)
    testResults.CompatibilityTests.UIScaling = {
        Status = scaleFactor > 0.5 and "PASS" or "WARNING",
        Message = string.format("Scale factor: %.2f", scaleFactor),
        Timestamp = os.time()
    }
end

local function runStressTest()
    print("⚡ Running stress test...")

    local startTime = tick()
    local iterations = 0

    while tick() - startTime < testConfig.MaxStressDuration do
        -- Simulate heavy load
        for i = 1, 100 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.Position = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
            part.Parent = workspace

            -- Clean up immediately
            game.Debris:AddItem(part, 0)
        end

        iterations = iterations + 1
        wait(0.1)
    end

    local endTime = tick()
    local duration = endTime - startTime
    local avgFPS = iterations / duration

    testResults.PerformanceTests.StressTest = {
        Status = avgFPS >= 30 and "PASS" or "FAIL",
        Value = math.floor(avgFPS),
        Message = string.format("Stress test: %.1f FPS over %.1fs", avgFPS, duration),
        Timestamp = os.time()
    }

    print(string.format("⚡ Stress test completed: %.1f FPS average", avgFPS))
end

-- Individual system tests
local function testWeaponSystem()
    -- Test weapon switching
    local weaponNames = {"Pistol", "AssaultRifle", "Shotgun", "Sniper"}
    local testPassed = true
    local testMessage = "All weapons available"

    for _, weaponName in ipairs(weaponNames) do
        if not _G.WeaponClient or not _G.WeaponClient[weaponName] then
            testPassed = false
            testMessage = "Missing weapon: " .. weaponName
            break
        end
    end

    return {
        Status = testPassed and "PASS" or "FAIL",
        Message = testMessage,
        Timestamp = os.time()
    }
end

local function testSoundSystem()
    -- Test sound loading
    local soundTest = pcall(function()
        return require(script.Parent.SoundSystem)
    end)

    return {
        Status = soundTest and "PASS" or "FAIL",
        Message = soundTest and "Sound system loaded" or "Sound system failed to load",
        Timestamp = os.time()
    }
end

local function testUISystems()
    -- Test UI element creation
    local uiCount = 0
    for _, gui in ipairs(player.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            uiCount = uiCount + 1
        end
    end

    return {
        Status = uiCount >= 3 and "PASS" or "WARNING",
        Message = string.format("UI systems loaded: %d", uiCount),
        Timestamp = os.time()
    }
end

local function testInputSystems()
    -- Test input responsiveness
    local inputTest = UserInputService.MouseEnabled or UserInputService.TouchEnabled

    return {
        Status = inputTest and "PASS" or "FAIL",
        Message = inputTest and "Input system responsive" or "Input system not responding",
        Timestamp = os.time()
    }
end

-- Display test results
local function displayTestResults()
    if not testButtons.ResultsScroll then return end

    -- Clear existing results
    for _, child in ipairs(testButtons.ResultsScroll:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("Frame") then
            child:Destroy()
        end
    end

    local startY = 0

    -- Display system load results
    local systemTitle = Instance.new("TextLabel")
    systemTitle.Size = UDim2.new(1, 0, 0, 25)
    systemTitle.Position = UDim2.new(0, 0, 0, startY)
    systemTitle.BackgroundTransparency = 1
    systemTitle.Text = "🔧 System Loading Tests"
    systemTitle.TextColor3 = Color3.fromRGB(255, 255, 100)
    systemTitle.Font = Enum.Font.SourceSansBold
    systemTitle.TextScaled = true
    systemTitle.Parent = testButtons.ResultsScroll
    startY = startY + 30

    for systemName, result in pairs(testResults.SystemsLoaded) do
        local resultFrame = Instance.new("Frame")
        resultFrame.Size = UDim2.new(1, 0, 0, 20)
        resultFrame.Position = UDim2.new(0, 0, 0, startY)
        resultFrame.BackgroundTransparency = 1
        resultFrame.Parent = testButtons.ResultsScroll

        local resultLabel = Instance.new("TextLabel")
        resultLabel.Size = UDim2.new(1, 0, 1, 0)
        resultLabel.Position = UDim2.new(0, 0, 0, 0)
        resultLabel.BackgroundTransparency = 1
        resultLabel.Text = string.format("%s: %s", systemName, result.Message)
        resultLabel.TextColor3 = getTestResultColor(result.Status)
        resultLabel.Font = Enum.Font.SourceSans
        resultLabel.TextScaled = true
        resultLabel.Parent = resultFrame

        startY = startY + 25
    end

    -- Update canvas size
    testButtons.ResultsScroll.CanvasSize = UDim2.new(0, 0, 0, startY)
end

-- Get color for test result status
local function getTestResultColor(status)
    if status == "PASS" then
        return Color3.fromRGB(100, 255, 100)
    elseif status == "WARNING" then
        return Color3.fromRGB(255, 255, 100)
    elseif status == "FAIL" then
        return Color3.fromRGB(255, 100, 100)
    else
        return Color3.fromRGB(200, 200, 200)
    end
end

-- Toggle test interface
local function toggleTestInterface()
    local testUI = player.PlayerGui:FindFirstChild("GameTesterUI")
    if testUI then
        local testFrame = testUI:FindFirstChild("TestFrame")
        if testFrame then
            testFrame.Visible = not testFrame.Visible
        end
    end
end

-- Initialize game tester
function GameTester.Initialize()
    local testUI, testFrame, testButtons = createTestUI()
    testFrame.Name = "TestFrame"
    testFrame.Parent = testUI

    -- Auto-run tests if enabled
    if testConfig.EnableAutoTesting then
        while true do
            wait(testConfig.TestInterval)
            runAllTests()
        end
    end

    -- Toggle test interface with F4
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.F4 then
            toggleTestInterface()
        end
    end)

    print("🧪 Game Tester initialized!")
end

-- Public API functions
function GameTester.RunAllTests()
    runAllTests()
end

function GameTester.GetTestResults()
    return testResults
end

function GameTester.GetSystemHealth()
    return systemHealth
end

function GameTester.ToggleTestInterface()
    toggleTestInterface()
end

return GameTester
