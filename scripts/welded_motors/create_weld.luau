--!strict

local Selection = game:GetService("Selection")

local types = require(script.Parent.steps_types)
local utils = require(script.Parent.utils)

type create_weld_step = types.step & {
	selection_ui_ids: { types.ui_id };
}

local function show_selection_ui(self: create_weld_step, context: types.step_context)

	for _, id in self.selection_ui_ids do
		context:remove_ui(self, id)
	end
	self.selection_ui_ids = {}

	local selection = Selection:Get()
	local selected_base_parts = utils.get_base_parts(selection)

	local weld_disabled = #selected_base_parts < 2

	if #selected_base_parts < 2 then
		local args: types.text_label_args = {
			label = "select at least two base parts to create a weld, currently selected: " .. tostring(#selected_base_parts);
		}
		local id = context:show_ui(self, nil, { type = "label", args = args })
		table.insert(self.selection_ui_ids, id)
	end

	for _, selected in selection do
		local args: { types.step_ui_item } = {}

		-- icon
		do
			local icon_args: types.class_icon_args = {
				class_name = selected.ClassName;
			}
			local step_ui_item: types.step_ui_item = {
				type = "class_icon";
				args = icon_args;
			}
			table.insert(args, step_ui_item)
		end

		-- name
		do
			local label_args: types.text_label_args = {
				label = selected.Name
			}
			local step_ui_item: types.step_ui_item = {
				type = "label";
				args = label_args;
			}
			table.insert(args, step_ui_item)
		end

		local this_is_a_base_part = table.find(selected_base_parts, selected)

		-- create weld button
		if this_is_a_base_part and not weld_disabled then
			local button_args: types.text_button_args = {
				label = "weld";
				click_handler = function()

				end,
			}
			local step_ui_item: types.step_ui_item = {
				type = "button";
				args = button_args;
			}
			table.insert(args, step_ui_item)
		end

		local id = context:show_ui(self, nil, unpack(args))
		table.insert(self.selection_ui_ids, id)
	end
end

local function execute_show_create_button(self: types.step, context: types.step_context)
	local self = self :: create_weld_step

	local selection = Selection:Get()

	local function on_selection_changed()
		show_selection_ui(self, context)
	end

	local selection_changed = Selection.SelectionChanged:Connect(on_selection_changed)
	context:register_connection(self, selection_changed)

	on_selection_changed()
end

local step_constructors: { () -> types.step } = {
	function(): types.step
		local instance: create_weld_step = {
			name = "show create button";
			execute = execute_show_create_button;

			selection_ui_ids = {};
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
