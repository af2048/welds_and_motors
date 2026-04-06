--!strict

local create_weld_steps = require(script.Parent.create_joint)
local types = require(script.Parent.steps_types)

local function createSteps(): { types.steps }
	local result = {}
	table.insert(result, create_weld_steps())
	return result
end

return {
	createSteps = createSteps;
}
