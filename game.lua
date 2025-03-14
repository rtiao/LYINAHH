-- Main server-side game script for LYIN AHH
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Create a folder for game events
local Events = Instance.new("Folder")
Events.Name = "Events"
Events.Parent = ReplicatedStorage

-- Create remote events
local GameEvent = Instance.new("RemoteEvent")
GameEvent.Name = "GameEvent"
GameEvent.Parent = Events

-- Game scenarios
local SCENARIOS = {
    "You're late to work",
    "You broke your friend's favorite item",
    "You ate the last slice of pizza",
    "You forgot to do your homework",
    "You lost your friend's pet",
    "You accidentally sent a wrong text",
    "You broke your parent's rules",
    "You spent all your allowance",
    "You lost your friend's game",
    "You ate someone else's lunch"
}

-- Game state
local gameState = {
    isGameRunning = false,
    players = {},
    currentScenario = nil,
    liar = nil,
    roundTime = 180, -- 3 minutes per round
    startTime = 0,
    timerConnection = nil,
    accusations = {},
    votes = {}
}

-- Function to assign roles
local function assignRoles()
    -- Select random scenario
    gameState.currentScenario = SCENARIOS[math.random(1, #SCENARIOS)]
    
    -- Select random liar
    local playerList = {}
    for _, player in pairs(gameState.players) do
        table.insert(playerList, player)
    end
    if #playerList > 0 then
        gameState.liar = playerList[math.random(1, #playerList)]
        
        -- Assign roles to all players
        for _, player in pairs(gameState.players) do
            if player == gameState.liar then
                GameEvent:FireClient(player, "RoleAssigned", "Liar", nil)
            else
                GameEvent:FireClient(player, "RoleAssigned", "Truth Teller", gameState.currentScenario)
            end
        end
        
        -- Notify all players that roles have been assigned
        GameEvent:FireAllClients("RoundStarted", gameState.currentScenario)
    end
end

-- Function to start the game
local function startGame()
    if gameState.isGameRunning then return end
    
    -- Reset game state
    gameState.accusations = {}
    gameState.votes = {}
    
    gameState.isGameRunning = true
    gameState.startTime = tick()
    print("LYIN AHH game started!")
    
    -- Assign initial roles
    assignRoles()
    
    -- Start round timer
    if gameState.timerConnection then
        gameState.timerConnection:Disconnect()
    end
    
    gameState.timerConnection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - gameState.startTime
        local timeLeft = math.max(0, gameState.roundTime - elapsed)
        
        -- Update all clients with remaining time
        GameEvent:FireAllClients("UpdateTimer", timeLeft)
        
        if timeLeft <= 0 then
            endRound()
        end
    end)
end

-- Function to end the round
local function endRound()
    if not gameState.isGameRunning then return end
    
    gameState.isGameRunning = false
    if gameState.timerConnection then
        gameState.timerConnection:Disconnect()
        gameState.timerConnection = nil
    end
    
    print("Round ended!")
    
    -- Calculate votes
    local voteCounts = {}
    for _, vote in pairs(gameState.votes) do
        voteCounts[vote] = (voteCounts[vote] or 0) + 1
    end
    
    -- Find most voted player
    local mostVoted = nil
    local maxVotes = 0
    for player, count in pairs(voteCounts) do
        if count > maxVotes then
            maxVotes = count
            mostVoted = player
        end
    end
    
    -- Reveal the liar and results
    GameEvent:FireAllClients("RoundEnded", {
        scenario = gameState.currentScenario,
        liar = gameState.liar and gameState.liar.Name or "No liar",
        mostVoted = mostVoted,
        voteCounts = voteCounts
    })
    
    -- Reset round time
    gameState.roundTime = 180
end

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " joined the game!")
    gameState.players[player.Name] = player
    GameEvent:FireClient(player, "Welcome", "Welcome to LYIN AHH!")
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    print(player.Name .. " left the game!")
    gameState.players[player.Name] = nil
    
    -- If the liar leaves, end the round
    if gameState.liar == player then
        endRound()
    end
end)

-- Handle player actions
GameEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "Accuse" then
        local accusedPlayer = gameState.players[data.accusedName]
        if accusedPlayer then
            -- Record accusation
            table.insert(gameState.accusations, {
                accuser = player.Name,
                accused = accusedPlayer.Name,
                reason = data.reason
            })
            
            -- Notify all players
            GameEvent:FireAllClients("Accusation", {
                accuser = player.Name,
                accused = accusedPlayer.Name,
                reason = data.reason
            })
        end
    elseif action == "Vote" then
        local votedPlayer = gameState.players[data.votedName]
        if votedPlayer then
            -- Record vote
            gameState.votes[player.Name] = votedPlayer.Name
        end
    end
end)

-- Create admin commands
game:GetService("StarterGui").Chat:RegisterProcessMessageEvent(function(message)
    if message:lower() == "/startgame" then
        local player = Players:GetPlayerByUserId(message.UserId)
        if player and player:IsInGroup(1234567) then -- Replace with your admin group ID
            startGame()
        end
    elseif message:lower() == "/endgame" then
        local player = Players:GetPlayerByUserId(message.UserId)
        if player and player:IsInGroup(1234567) then -- Replace with your admin group ID
            endRound()
        end
    end
end)

-- Initialize the game
print("LYIN AHH game server initialized!") 