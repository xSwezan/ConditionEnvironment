local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Promise = require(script.Parent.Promise)

local ConditionEnvironment = {}
ConditionEnvironment.__index = ConditionEnvironment

export type Environment = {
	new: (Function: (ConditionEnvironment: Environment) -> nil) -> Promise.Promise;

	Destroy: (self: Environment) -> nil;

	AddCondition: (self: Environment, Name: string, Callback: () -> boolean, ConditionMet: () -> nil?) -> nil;
	RemoveCondition: (self: Environment, string) -> nil;

	Always: <T, TArgs...>(self: Environment, Callback: (...any) -> T, TArgs...) -> () -> T;
}

-->------------------<--
--> Lifetime Methods <--
-->------------------<--

-- Returns a Promise, that when cancelled; destroys the Environment, thus making all the code stop running.
function ConditionEnvironment.new(Function: (ConditionEnvironment: Environment) -> nil): Promise.Promise
	local self = setmetatable({
		__conditions = {};
		__connections = {};
		__alwaysCallbacks = {};

		__conditionWasMet = false;
	}, ConditionEnvironment)

	self.PromiseThread = Promise.try(Function, self) :: Promise.Promise

	self.MainPromise = Promise.new(function(resolve, reject, onCancel)
		self.PromiseThread:andThen(function()
			if (self.ConditionMetPromise) then
				self.ConditionMetPromise:await()
			elseif (self.ConditionMetFound) then ---! This absolutely sucks
				repeat RunService.Heartbeat:Wait() until (self.ConditionMetPromise)
				self.ConditionMetPromise:await()
			else
				resolve()
				self:Destroy()
			end
		end)

		onCancel(function()
			self:Destroy()
		end)

		table.insert(self.__connections, RunService.Heartbeat:Connect(function()
			if (self.__conditionWasMet) then return end

			for Name: string, ConditionInfo: {Callback: () -> boolean?, ConditionMet: () -> nil?} in self.__conditions or {} do
				if (type(ConditionInfo.Callback) ~= "function") then continue end
	
				local Args: {any} = {ConditionInfo.Callback()}
				if (Args[1] ~= true) then continue end

				self.__conditionWasMet = true

				if (type(ConditionInfo.ConditionMet) == "function") then
					self.ConditionMetFound = true
					self.ConditionMetPromise = Promise.try(ConditionInfo.ConditionMet)
					self.ConditionMetPromise:await()
				end
	
				resolve(select(2, unpack(Args)))
				self:Destroy()
			end
		end))
	end)

	return self.MainPromise
end

-- Stops the current code and destroys the Environment
function ConditionEnvironment:Destroy()
	for Id: string, Value in self.__alwaysCallbacks do
		local Callback: (...any) -> nil = Value[1]
		if (type(Callback) ~= "function") then continue end

		local Args: {any} = Value[2] or {}
		
		self.__alwaysCallbacks[Id] = nil

		Callback(unpack(Args))
	end

	for _, Connection: RBXScriptConnection in self.__connections do
		if not (Connection.Connected) then continue end

		Connection:Disconnect()
	end

	if (self.PromiseThread) then
		self.PromiseThread:cancel()
		self.PromiseThread = nil
	end

	if (self.MainPromise) then
		self.MainPromise:cancel()
		self.MainPromise = nil
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
	self.__conditions[Name] = {
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

		self.__conditions[Name] = nil
	end
end

--[=[
	Add a callback that will run before the Environment gets destroyed.
	This method returns a function that can be called as a reference to the original callback, though this can only be called once.
	```lua
	local DestroyMap = Environment:Always(function()
		Map:Destroy()
	end)

	-- Another part of the script
	DestroyMap()
	DestroyMap() -- ERROR
	```
]=]
function ConditionEnvironment:Always<T>(Callback: (...any) -> T, ...: any): () -> T
	local Args: {any} = {...}

	local Data = {Callback, Args}
	local Id = HttpService:GenerateGUID()
	-- table.insert(self.__alwaysCallbacks, Data)
	self.__alwaysCallbacks[Id] = Data
	
	return function()
		-- local Index: number? = table.find(self.__alwaysCallbacks, Data)
		if not (self.__alwaysCallbacks[Id]) then
			error("An Always callback can only be called once!")
		end

		self.__alwaysCallbacks[Id] = nil

		return Callback(unpack(Args))
	end
end

return ConditionEnvironment