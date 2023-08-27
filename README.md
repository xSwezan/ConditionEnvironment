ConditionEnvironment is a versatile tool for managing game situations. It allows you to set up specific conditions that, when met, trigger designated actions. Whether it's ensuring player counts or handling special rounds, this library empowers you to create dynamic and responsive gameplay experiences.

Here's an example of a simple round system created using ConditionEnvironments:
```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConditionEnvironment = require(path.to.module)

local function Not(Callback: () -> boolean?): () -> boolean
	return function(...)
		return not Callback(...)
	end
end

local function EnoughPlayers(): boolean
	return (#Players:GetPlayers() > 1)
end

while task.wait() do
	ConditionEnvironment.new(function(Environment)
		print("Starting Round!")
	
		print("Waiting for players!")
	
		repeat task.wait() until EnoughPlayers()
		Environment:AddCondition("IsEnoughPlayers", Not(EnoughPlayers), function()
			warn("Someone left, restarting game!")
		end)
	
		print("Enough players joined!")
	
		print("Intermission")
		task.wait(5)
	
		print("Starting soon!")
		task.wait(5)
	
		Environment:RemoveCondition("IsEnoughPlayers")
	
		print("Game started!")
		task.wait(5)
	end):await()
end
```