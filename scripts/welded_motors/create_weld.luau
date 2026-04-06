--!strict

local types = require(script.Parent.steps_types)

type create_weld_step = types.step & {

}

local function execute_show_create_button(self: types.step, context: types.step_context)
	local self = self :: create_weld_step

	local id

	local args: types.text_button_args = {
		label = "test";
		click_handler = function()
			print("test clicked")

			local args: types.text_label_args = {
				label = "test clicked";
			}
			context:show_ui(self, id, { type = "label", args = args })
		end,
	}
	id = context:show_ui(self, nil, { type = "button", args = args })
end

local step_constructors: { () -> types.step } = {
	function(): types.step
		local instance: create_weld_step = {
			name = "show create button";
			execute = execute_show_create_button;
		}
		return instance
	end,
}

return function() : types.steps
	local result = {}
	for _, constructor in step_constructors do
		table.insert(result, constructor())
	end
	return result
end
