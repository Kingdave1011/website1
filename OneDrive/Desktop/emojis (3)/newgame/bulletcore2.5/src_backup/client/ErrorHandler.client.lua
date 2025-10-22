-- Comprehensive Error Handling and Debugging System
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local ErrorHandler = {}

-- Error tracking
local errorLog = {}
local warningLog = {}
local performanceIssues = {}

-- Error categories
local ErrorCategories = {
    CRITICAL = "CRITICAL",
    ERROR = "ERROR",
    WARNING = "WARNING",
    INFO = "INFO",
    PERFORMANCE = "PERFORMANCE"
}

-- Error configuration
local errorConfig = {
    MaxLogSize = 100,
    EnableConsoleOutput = true,
    EnableRemoteReporting = false, -- Set to true for production error reporting
    EnablePerformanceTracking = true,
    AutoRestartOnCriticalError = false
}

-- Error display UI
local errorUI = nil
local errorFrame = nil
local errorList = nil

-- Create error reporting UI
local function createErrorUI()
    errorUI = Instance.new("ScreenGui")
    errorUI.Name = "ErrorHandlerUI"
    errorUI.ResetOnSpawn = false
    errorUI.Parent = player.PlayerGui

    -- Main error frame
    errorFrame = Instance.new("Frame")
    errorFrame.Size = UDim2.new(0, 400, 0, 300)
    errorFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    errorFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    errorFrame.BackgroundTransparency = 0.3
    errorFrame.BorderSizePixel = 0
    errorFrame.Visible = false
    errorFrame.Parent = errorUI

    local errorCorner = Instance.new("UICorner")
    errorCorner.CornerRadius = UDim.new(0, 8)
    errorCorner.Parent = errorFrame

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🚨 Error Monitor"
    titleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextScaled = true
    titleLabel.Parent = errorFrame

    -- Error list
    errorList = Instance.new("ScrollingFrame")
    errorList.Size = UDim2.new(1, -20, 1, -80)
    errorList.Position = UDim2.new(0, 10, 0, 40)
    errorList.BackgroundTransparency = 1
    errorList.ScrollBarThickness = 8
    errorList.Parent = errorFrame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(0.5, -50, 1, -35)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BackgroundTransparency = 0.2
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = errorFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton

    -- Connect close button
    closeButton.MouseButton1Click:Connect(function()
        errorFrame.Visible = false
    end)

    return errorUI
end

-- Log error with category and severity
function ErrorHandler.LogError(errorMessage, category, severity, context)
    local errorEntry = {
        Message = errorMessage,
        Category = category or ErrorCategories.ERROR,
        Severity = severity or "Medium",
        Context = context or "Unknown",
        Timestamp = os.time(),
        FrameCount = RunService:GetFrameCount()
    }

    -- Add to log
    table.insert(errorLog, errorEntry)

    -- Maintain log size limit
    if #errorLog > errorConfig.MaxLogSize then
        table.remove(errorLog, 1)
    end

    -- Console output if enabled
    if errorConfig.EnableConsoleOutput then
        print(string.format("[ERROR] [%s] %s - %s", category, severity, errorMessage))
    end

    -- Update UI if visible
    if errorFrame and errorFrame.Visible then
        updateErrorDisplay()
    end

    -- Handle critical errors
    if category == ErrorCategories.CRITICAL then
        handleCriticalError(errorEntry)
    end

    return errorEntry
end

-- Log warning
function ErrorHandler.LogWarning(warningMessage, context)
    local warningEntry = {
        Message = warningMessage,
        Category = ErrorCategories.WARNING,
        Context = context or "Unknown",
        Timestamp = os.time(),
        FrameCount = RunService:GetFrameCount()
    }

    table.insert(warningLog, warningEntry)

    if #warningLog > errorConfig.MaxLogSize then
        table.remove(warningLog, 1)
    end

    if errorConfig.EnableConsoleOutput then
        print(string.format("[WARNING] %s - %s", context, warningMessage))
    end
end

-- Log performance issue
function ErrorHandler.LogPerformanceIssue(issueMessage, metrics, context)
    local perfEntry = {
        Message = issueMessage,
        Category = ErrorCategories.PERFORMANCE,
        Metrics = metrics or {},
        Context = context or "Unknown",
        Timestamp = os.time(),
        FrameCount = RunService:GetFrameCount()
    }

    table.insert(performanceIssues, perfEntry)

    if #performanceIssues > errorConfig.MaxLogSize then
        table.remove(performanceIssues, 1)
    end

    if errorConfig.EnableConsoleOutput then
        print(string.format("[PERFORMANCE] %s - %s", context, issueMessage))
    end
end

-- Handle critical errors
local function handleCriticalError(errorEntry)
    -- Attempt to save error log before crash
    saveErrorLog()

    -- Show error to user
    showCriticalError(errorEntry)

    -- Auto-restart if enabled
    if errorConfig.AutoRestartOnCriticalError then
        wait(3)
        player:Kick("Critical error occurred - restarting...")
    end
end

-- Show critical error to user
local function showCriticalError(errorEntry)
    -- Create critical error popup
    local criticalFrame = Instance.new("Frame")
    criticalFrame.Size = UDim2.new(0, 500, 0, 200)
    criticalFrame.Position = UDim2.new(0.5, -250, 0.5, -100)
    criticalFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    criticalFrame.BorderSizePixel = 0
    criticalFrame.Parent = player.PlayerGui

    local criticalCorner = Instance.new("UICorner")
    criticalCorner.CornerRadius = UDim.new(0, 8)
    criticalCorner.Parent = criticalFrame

    local errorTitle = Instance.new("TextLabel")
    errorTitle.Size = UDim2.new(1, 0, 0, 40)
    errorTitle.Position = UDim2.new(0, 0, 0, 0)
    errorTitle.BackgroundTransparency = 1
    errorTitle.Text = "🚨 CRITICAL ERROR"
    errorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    errorTitle.Font = Enum.Font.SourceSansBold
    errorTitle.TextScaled = true
    errorTitle.Parent = criticalFrame

    local errorMessage = Instance.new("TextLabel")
    errorMessage.Size = UDim2.new(1, -20, 1, -80)
    errorMessage.Position = UDim2.new(0, 10, 0, 50)
    errorMessage.BackgroundTransparency = 1
    errorMessage.Text = errorEntry.Message
    errorMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
    errorMessage.Font = Enum.Font.SourceSans
    errorMessage.TextScaled = true
    errorMessage.TextWrapped = true
    errorMessage.Parent = criticalFrame

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(0.5, -50, 1, -35)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundTransparency = 0.2
    closeButton.BorderSizePixel = 0
    closeButton.Text = "OK"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = criticalFrame

    closeButton.MouseButton1Click:Connect(function()
        criticalFrame:Destroy()
    end)

    -- Auto-close after 10 seconds
    wait(10)
    if criticalFrame.Parent then
        criticalFrame:Destroy()
    end
end

-- Update error display UI
local function updateErrorDisplay()
    if not errorList then return end

    -- Clear existing entries
    for _, child in ipairs(errorList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    -- Add recent errors
    local startY = 0
    local recentErrors = {}

    -- Combine all logs
    for _, error in ipairs(errorLog) do
        table.insert(recentErrors, {Entry = error, Type = "ERROR"})
    end
    for _, warning in ipairs(warningLog) do
        table.insert(recentErrors, {Entry = warning, Type = "WARNING"})
    end
    for _, perf in ipairs(performanceIssues) do
        table.insert(recentErrors, {Entry = perf, Type = "PERFORMANCE"})
    end

    -- Sort by timestamp (most recent first)
    table.sort(recentErrors, function(a, b)
        return a.Entry.Timestamp > b.Entry.Timestamp
    end)

    -- Display recent entries
    for i = 1, math.min(10, #recentErrors) do
        local entry = recentErrors[i]
        local errorLabel = Instance.new("TextLabel")
        errorLabel.Size = UDim2.new(1, 0, 0, 20)
        errorLabel.Position = UDim2.new(0, 0, 0, startY)
        errorLabel.BackgroundTransparency = 1
        errorLabel.Text = string.format("[%s] %s", entry.Type, entry.Entry.Message)
        errorLabel.TextColor3 = getErrorColor(entry.Type)
        errorLabel.Font = Enum.Font.SourceSans
        errorLabel.TextScaled = true
        errorLabel.TextXAlignment = Enum.TextXAlignment.Left
        errorLabel.Parent = errorList

        startY = startY + 22
    end

    -- Update canvas size
    errorList.CanvasSize = UDim2.new(0, 0, 0, startY)
end

-- Get color for error type
local function getErrorColor(errorType)
    if errorType == "ERROR" then
        return Color3.fromRGB(255, 100, 100)
    elseif errorType == "WARNING" then
        return Color3.fromRGB(255, 200, 100)
    elseif errorType == "PERFORMANCE" then
        return Color3.fromRGB(100, 200, 255)
    else
        return Color3.fromRGB(200, 200, 200)
    end
end

-- Save error log to file (for debugging)
local function saveErrorLog()
    local logData = {
        PlayerId = player.UserId,
        PlayerName = player.Name,
        Timestamp = os.time(),
        Errors = errorLog,
        Warnings = warningLog,
        PerformanceIssues = performanceIssues
    }

    -- In a real implementation, you would save this to a file or send to a server
    print("Error log saved for debugging")
end

-- Monitor for common issues
local function monitorForIssues()
    -- Monitor FPS
    local fps = 1 / RunService.RenderStepped:Wait()
    if fps < 15 then
        ErrorHandler.LogPerformanceIssue(
            string.format("Low FPS detected: %.1f", fps),
            {FPS = fps, FrameTime = 1/fps * 1000},
            "PerformanceMonitor"
        )
    end

    -- Monitor memory usage
    local stats = game:GetService("Stats")
    local memoryUsage = stats:GetTotalMemoryUsageMb()
    if memoryUsage > 500 then -- 500MB threshold
        ErrorHandler.LogWarning(
            string.format("High memory usage: %.1fMB", memoryUsage),
            "MemoryMonitor"
        )
    end

    -- Monitor ping
    local ping = player:GetNetworkPing() * 1000
    if ping > 200 then -- 200ms threshold
        ErrorHandler.LogWarning(
            string.format("High ping detected: %.1fms", ping),
            "NetworkMonitor"
        )
    end
end

-- Safe require wrapper
function ErrorHandler.SafeRequire(moduleName, modulePath)
    local success, result = pcall(function()
        return require(modulePath)
    end)

    if not success then
        ErrorHandler.LogError(
            string.format("Failed to load module '%s': %s", moduleName, result),
            ErrorCategories.CRITICAL,
            "High",
            "ModuleLoader"
        )
        return nil
    end

    return result
end

-- Safe function call wrapper
function ErrorHandler.SafeCall(func, errorMessage, ...)
    local success, result = pcall(func, ...)

    if not success then
        ErrorHandler.LogError(
            string.format("%s: %s", errorMessage or "Function call failed", result),
            ErrorCategories.ERROR,
            "Medium",
            "SafeCall"
        )
        return nil
    end

    return result
end

-- Initialize error handler
function ErrorHandler.Initialize()
    createErrorUI()

    -- Start monitoring
    RunService.RenderStepped:Connect(monitorForIssues)

    -- Override print for error tracking
    local originalPrint = print
    _G.print = function(...)
        local args = {...}
        local message = ""
        for i, arg in ipairs(args) do
            message = message .. tostring(arg)
            if i < #args then message = message .. " " end
        end

        -- Check if it's an error message
        if string.find(message, "error") or string.find(message, "Error") or string.find(message, "ERROR") then
            ErrorHandler.LogError(message, ErrorCategories.ERROR, "Low", "PrintOverride")
        end

        originalPrint(...)
    end

    print("🛡️ Error Handler initialized!")
end

-- Public API functions
function ErrorHandler.ShowErrorMonitor()
    if errorFrame then
        errorFrame.Visible = true
        updateErrorDisplay()
    end
end

function ErrorHandler.HideErrorMonitor()
    if errorFrame then
        errorFrame.Visible = false
    end
end

function ErrorHandler.GetErrorCount()
    return #errorLog
end

function ErrorHandler.GetWarningCount()
    return #warningLog
end

function ErrorHandler.GetPerformanceIssueCount()
    return #performanceIssues
end

function ErrorHandler.ExportErrorLog()
    return {
        Errors = errorLog,
        Warnings = warningLog,
        PerformanceIssues = performanceIssues,
        Timestamp = os.time()
    }
end

function ErrorHandler.ClearLogs()
    errorLog = {}
    warningLog = {}
    performanceIssues = {}
    print("🧹 Error logs cleared")
end

return ErrorHandler
