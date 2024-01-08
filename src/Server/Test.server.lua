local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestEZ = require(ReplicatedStorage.DevPackages.TestEZ)

task.wait(5)

TestEZ.TestBootstrap:run({ReplicatedStorage.lib.lib})

-- local function Not(Callback: () -> boolean?): () -> boolean
-- 	return function(...)
-- 		return not Callback(...)
-- 	end
-- end

-- local function EnoughPlayers(): boolean
-- 	return (#Players:GetPlayers() >= 1)
-- end

-- while task.wait() do
-- 	ConditionEnvironment.new(function(Environment)
-- 		print("Starting Round!")
	
-- 		print("Waiting for players!")
	
-- 		repeat task.wait() until EnoughPlayers()
-- 		Environment:AddCondition("IsEnoughPlayers", Not(EnoughPlayers), function()
-- 			warn("Someone left, restarting game!")
-- 		end)
	
-- 		print("Enough players joined!")
	
-- 		print("Intermission")
-- 		task.wait(5)
	
-- 		print("Starting soon!")
-- 		task.wait(5)
	
-- 		Environment:RemoveCondition("IsEnoughPlayers")
	
-- 		local RemoveMap = Environment:Always(function()
-- 			print("REMOVING MAP")
-- 		end)

-- 		-- task.delay(5, function()
-- 		-- 	Environment:AddCondition("ForceRestart", function()
-- 		-- 		return true
-- 		-- 	end, function()
-- 		-- 		print("Simulating Restart")
-- 		-- 	end)
-- 		-- end)

-- 		print("Game started!")
-- 		task.wait(5)

-- 		RemoveMap()

-- 		print("Game ending!")
-- 		task.wait(2)

-- 		RemoveMap()
-- 	end):catch(warn):await()
-- end