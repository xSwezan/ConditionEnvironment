return function()
	local ConditionEnvironment = require(script.Parent.Parent)

	it("should correctly yield when a condition is met", function()
		local start = os.clock()

		ConditionEnvironment.new(function(Environment)
			Environment:AddCondition("yieldTest", function()
				return true
			end, function()
				task.wait(1)
			end)

			task.wait(3)
		end):await()

		expect(os.clock() - start).to.be.near(1, .03)
	end)

	it("should correctly yield when a condition is not met", function()
		local start = os.clock()

		ConditionEnvironment.new(function(Environment)
			Environment:AddCondition("yieldTest", function()
				return false
			end, function()
				task.wait(1)
			end)

			task.wait(3)
		end):await()

		expect(os.clock() - start).to.be.near(3, .03)
	end)
end