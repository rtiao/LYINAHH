-- Client-side game script for LYIN AHH
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

print("Starting client script...")

-- Get the Events folder
local Events = ReplicatedStorage:WaitForChild("Events")
local GameEvent = Events:WaitForChild("GameEvent")

print("Found Events folder and GameEvent")

-- Create main UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LYINAHHUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = StarterGui

print("Created ScreenGui")

-- Create main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

print("Created main frame")

-- Create role label
local roleLabel = Instance.new("TextLabel")
roleLabel.Size = UDim2.new(1, 0, 0.2, 0)
roleLabel.Position = UDim2.new(0, 0, 0, 0)
roleLabel.BackgroundTransparency = 1
roleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
roleLabel.Text = "Your Role: Waiting..."
roleLabel.TextScaled = true
roleLabel.Parent = mainFrame

print("Created role label")

-- Create scenario label
local scenarioLabel = Instance.new("TextLabel")
scenarioLabel.Size = UDim2.new(1, 0, 0.2, 0)
scenarioLabel.Position = UDim2.new(0, 0, 0.2, 0)
scenarioLabel.BackgroundTransparency = 1
scenarioLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
scenarioLabel.Text = "Scenario: Unknown"
scenarioLabel.TextScaled = true
scenarioLabel.Parent = mainFrame

print("Created scenario label")

-- Create timer label
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0.2, 0)
timerLabel.Position = UDim2.new(0, 0, 0.4, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.Text = "Time: 3:00"
timerLabel.TextScaled = true
timerLabel.Parent = mainFrame

print("Created timer label")

-- Create accusation button
local accuseButton = Instance.new("TextButton")
accuseButton.Size = UDim2.new(0.4, 0, 0.1, 0)
accuseButton.Position = UDim2.new(0.3, 0, 0.7, 0)
accuseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
accuseButton.Text = "Accuse Player"
accuseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
accuseButton.Parent = mainFrame

print("Created accusation button")

-- Create reason input
local reasonInput = Instance.new("TextBox")
reasonInput.Size = UDim2.new(0.8, 0, 0.1, 0)
reasonInput.Position = UDim2.new(0.1, 0, 0.6, 0)
reasonInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
reasonInput.Text = "Enter reason for accusation..."
reasonInput.TextColor3 = Color3.fromRGB(255, 255, 255)
reasonInput.PlaceholderText = "Why do you think they're lying?"
reasonInput.Parent = mainFrame

print("Created reason input")

-- Create player list
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0.8, 0, 0.3, 0)
playerList.Position = UDim2.new(0.1, 0, 0.8, 0)
playerList.BackgroundTransparency = 1
playerList.Parent = mainFrame

print("Created player list")

-- Function to update timer
local function updateTimer(timeLeft)
    local minutes = math.floor(timeLeft / 60)
    local seconds = math.floor(timeLeft % 60)
    timerLabel.Text = string.format("Time: %d:%02d", minutes, seconds)
    
    -- Change color based on time remaining
    if timeLeft <= 30 then
        timerLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    elseif timeLeft <= 60 then
        timerLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
    else
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Function to show notification
local function showNotification(message, duration)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0.4, 0, 0.1, 0)
    notification.Position = UDim2.new(0.3, 0, -0.1, 0)
    notification.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    notification.Text = message
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Parent = mainFrame
    
    -- Animate notification
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(notification, tweenInfo, {Position = UDim2.new(0.3, 0, 0.1, 0)})
    tween:Play()
    
    -- Remove notification after duration
    wait(duration)
    
    local fadeOut = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local fadeTween = TweenService:Create(notification, fadeOut, {Position = UDim2.new(0.3, 0, -0.1, 0)})
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Function to update player list
local function updatePlayerList()
    -- Clear existing buttons
    for _, child in ipairs(playerList:GetChildren()) do
        child:Destroy()
    end
    
    -- Create new buttons for each player
    local yOffset = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 0.2, 0)
            button.Position = UDim2.new(0, 0, yOffset, 0)
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            button.Text = player.Name
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Parent = playerList
            
            -- Add hover effect
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end)
            
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end)
            
            button.MouseButton1Click:Connect(function()
                if reasonInput.Text ~= "" and reasonInput.Text ~= "Enter reason for accusation..." then
                    GameEvent:FireServer("Accuse", {
                        accusedName = player.Name,
                        reason = reasonInput.Text
                    })
                    reasonInput.Text = "Enter reason for accusation..."
                else
                    showNotification("Please enter a reason for your accusation!", 2)
                end
            end)
            
            yOffset = yOffset + 0.25
        end
    end
end

-- Handle game events
GameEvent.OnClientEvent:Connect(function(action, data)
    print("Received game event:", action)
    if action == "Welcome" then
        roleLabel.Text = "Welcome to LYIN AHH!"
        scenarioLabel.Text = "Waiting for game to start..."
        showNotification("Welcome to LYIN AHH!", 3)
    elseif action == "RoleAssigned" then
        roleLabel.Text = "Your Role: " .. data
        if data == "Liar" then
            scenarioLabel.Text = "You are the Liar! Make up a story!"
            showNotification("You are the Liar!", 3)
        end
    elseif action == "RoundStarted" then
        scenarioLabel.Text = "Scenario: " .. data
        showNotification("Round Started!", 2)
    elseif action == "UpdateTimer" then
        updateTimer(data)
    elseif action == "RoundEnded" then
        roleLabel.Text = "Round Over!"
        scenarioLabel.Text = "Scenario was: " .. data.scenario
        
        local resultText = ""
        if data.liar == Players.LocalPlayer.Name then
            resultText = "You were the Liar!"
        else
            resultText = "The Liar was: " .. data.liar
        end
        
        if data.mostVoted then
            resultText = resultText .. "\nMost voted player: " .. data.mostVoted
        end
        
        timerLabel.Text = resultText
        showNotification(resultText, 5)
    elseif action == "Accusation" then
        showNotification(data.accuser .. " accused " .. data.accused .. " for: " .. data.reason, 3)
    end
end)

-- Update player list when players join/leave
Players.PlayerAdded:Connect(function(player)
    print("Player joined:", player.Name)
    updatePlayerList()
    showNotification(player.Name .. " joined the game!", 2)
end)

Players.PlayerRemoving:Connect(function(player)
    print("Player left:", player.Name)
    updatePlayerList()
    showNotification(player.Name .. " left the game!", 2)
end)

-- Initialize the client
print("LYIN AHH game client initialized!") 