--!strict

local Selection = game:GetService("Selection")

local types = require(script.Parent.steps_types)

type create_weld_step = types.step & {

}

local function execute_show_create_button(self: types.step, context: types.step_context)
	local self = self :: create_weld_step

	local selection = Selection:Get()

	local id

	local function show_selection()
		local selection = Selection:Get()

		local args: types.text_label_args = {
			label = "select two instances to create weld, currently selected: " .. tostring(#selection);
		}
		id = context:show_ui(self, id, { type = "label", args = args })
	end

	local function show_weld_buttons()
		local selection = Selection:Get()
		for i, selected in selection do
			local label_args: types.text_label_args = {
				label = tostring(i) .. " " .. selected.Name .. " " .. selected:GetFullName()
			}
			local button_args: types.text_button_args = {
				label = "weld";
				click_handler = function()

				end,
			}
			context:show_ui(self, nil, { type = "label", args = label_args }, { type = "button", args = button_args })
		end
	end

	if 2 ~= #selection then
		show_selection()
		local selection_changed = Selection.SelectionChanged:Connect(function()
			local selection = Selection:Get()
			if 2 ~= #selection then
				show_selection()
			else
				show_weld_buttons()
			end
		end)
		context:register_connection(self, selection_changed)
	else
		show_weld_buttons()
	end
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
