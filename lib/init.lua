local RunService = game:GetService("RunService")
local Promise = require(script.Parent.Promise)
local Types = require(script.Types)

local ConditionEnvironment = {}
ConditionEnvironment.__index = ConditionEnvironment

-->------------------<--
--> Lifetime Methods <--
-->------------------<--

function ConditionEnvironment.new(Function: () -> nil): Types.ConditionEnvironment
	local self = setmetatable({
		Conditions = {};

		__connections = {};
	}, ConditionEnvironment)

	self.PromiseThread = Promise.try(Function, self) :: Types.Promise

	return Promise.new(function(resolve, reject, onCancel)
		self.PromiseThread:andThen(resolve)

		table.insert(self.__connections, RunService.Heartbeat:Connect(function()
			for Name: string, ConditionInfo: {Callback: () -> boolean?, ConditionMet: () -> nil?} in self.Conditions or {} do
				if (type(ConditionInfo.Callback) ~= "function") then continue end
				if (ConditionInfo.Callback() ~= true) then continue end
	
				local Args: {any} = {ConditionInfo.Callback()}
				if (Args[1] ~= true) then continue end

				if (type(ConditionInfo.ConditionMet) == "function") then
					task.spawn(ConditionInfo.ConditionMet)
				end
	
				resolve(select(2, unpack(Args)))
				self:Destroy()
			end
		end))
	end)
end

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

function ConditionEnvironment:AddCondition(Name: string, Callback: () -> boolean, ConditionMet: () -> nil?)
	self.Conditions[Name] = {
		Callback = Callback;
		ConditionMet = ConditionMet;
	}
end

function ConditionEnvironment:RemoveCondition(...: string)
	for _, Name: string in {...} do
		if (type(Name) ~= "string") then continue end

		self.Conditions[Name] = nil
	end
end

return ConditionEnvironment