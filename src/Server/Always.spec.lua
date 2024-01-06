return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ConditionEnvironment = require(ReplicatedStorage.lib)

	it("should throw error if I call an Always callback twice", function()
		ConditionEnvironment.new(function(Environment)
			local callback = Environment:Always(function()end)

			expect(callback).never.to.throw()
			expect(callback).to.throw()
		end)
	end)

	it("should call the Always callbacks when the environment is destroyed", function()
		local callback1Called = false
		local callback2Called = false

		ConditionEnvironment.new(function(Environment)
			local callback = Environment:Always(function()
				callback1Called = true
			end)

			local callback2 = Environment:Always(function()
				callback2Called = true
			end)
		end):await()

		expect(callback1Called).to.equal(true)
		expect(callback2Called).to.equal(true)
	end)
end