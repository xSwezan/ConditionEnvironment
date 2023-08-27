local Promise = require(script.Parent.Parent.Promise)

local Types = {}

export type Promise = typeof(Promise.new())

export type ConditionEnvironment = {
	new: (Function: () -> nil) -> Promise;
}

return Types