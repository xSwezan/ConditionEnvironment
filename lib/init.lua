local RunService = game:GetService("RunService")
local Promise = require(script.Parent.Promise)

local ConditionEnvironment = {}
ConditionEnvironment.__index = ConditionEnvironment

export type Environment = {
	new: (Function: () -> nil) -> Promise.Promise;

	Destroy: (self: Environment) -> nil;

	AddCondition: (self: Environment, Name: string, Callback: () -> boolean, ConditionMet: () -> nil?) -> nil;
	RemoveCondition: (self: Environment, string...) -> nil;
}

-->------------------<--
--> Lifetime Methods <--
-->------------------<--

-- Returns a Promise, that when cancelled; destroys the Environment, thus making all the code stop running.
function ConditionEnvironment.new(Function: () -> nil): Promise.Promise
	local self = setmetatable({
		Conditions = {};

		__connections = {};
	}, ConditionEnvironment)

	self.PromiseThread = Promise.try(Function, self) :: Promise.Promise

	return Promise.new(function(resolve, reject, onCancel)
		self.PromiseThread:andThen(resolve)

		onCancel(function()
			self:Destroy()
		end)

		table.insert(self.__connections, RunService.Heartbeat:Connect(function()
			for Name: string, ConditionInfo: {Callback: () -> boolean?, ConditionMet: () -> nil?} in self.Conditions or {} do
				if (type(ConditionInfo.Callback) ~= "function") then continue end
				if (ConditionInfo.Callback() ~= true) then continue end
	
				local Args: {any} = {ConditionInfo.Callback()}
				if (Args[1] ~= true) then continue end

				if (type(ConditionInfo.ConditionMet) == "function") then
					ConditionInfo.ConditionMet()
				end
	
				resolve(select(2, unpack(Args)))
				self:Destroy()
			end
		end))
	end)
end

-- Stops the current code and destroys the Environment
function ConditionEnvironment:Destroy()
	for _, Connection: RBXScriptConnection in self.__connections do
		if not (Connection.Connected) then continue end

		Connection:Disconnect()
	end

	if (self.PromiseThread) then
		self.PromiseThread:cancel()
	end

	self = nil
end

-->---------<--
--> Methods <--
-->---------<--

--[=[
	Add a condition that when met (returns true); destroys the environment, thus making all the code stop running.
	```lua
	Environment:AddCondition("IsEnoughPlayers", function()
		return (#Players:GetPlayers() >= 2)
	end, function()
		print("Someone left!")
	end)
	```
]=]
function ConditionEnvironment:AddCondition(Name: string, Callback: () -> boolean, ConditionMet: () -> nil?)
	self.Conditions[Name] = {
		Callback = Callback;
		ConditionMet = ConditionMet;
	}
end

--[=[
	Removes a condition from the environment. Multiple conditions can be removed at the same time by simply providing more condition names.
	```lua
	Environment:RemoveCondition("IsEnoughPlayers", "IsThereAWinner")
	```
]=]
function ConditionEnvironment:RemoveCondition(...: string)
	for _, Name: string in {...} do
		if (type(Name) ~= "string") then continue end

		self.Conditions[Name] = nil
	end
end

return ConditionEnvironment