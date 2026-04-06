--!strict

local debug_log = true

local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local types = require(script.Parent.steps_types)
local utils = require(script.Parent.utils)

type create_joint_step = types.step & {
	selection_ui_ids: { types.ui_id };
}

local function create_selected_item_common_args(instance: Instance, args: { types.step_ui_item })
	-- icon
	do
		local icon_args: types.class_icon_args = {
			class_name = instance.ClassName;
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
			label = instance.Name
		}
		local step_ui_item: types.step_ui_item = {
			type = "label";
			args = label_args;
		}
		table.insert(args, step_ui_item)
	end
end

local function show_selection_ui(self: create_joint_step, context: types.step_context)

	for _, id in self.selection_ui_ids do
		context:remove_ui(self, id)
	end
	self.selection_ui_ids = {}

	local selection = Selection:Get()
	local selected_base_parts = utils.get_instances_of_type(selection, "BasePart")
	local selected_attachments = utils.get_instances_of_type(selection, "Attachment")

	-- current selection info
	do
		local selection_info
		if 0 == #selection then
			selection_info = "nothing is selected"
		else
			selection_info = "selected instances: " .. tostring(#selection)
		end
		local args: types.text_label_args = {
			label = selection_info
		}
		local id = context:show_ui(self, nil, { type = "label", args = args })
		table.insert(self.selection_ui_ids, id)

		-- selection list
		for _, selected in selection do
			if table.find(selected_base_parts, selected)
				or table.find(selected_attachments, selected)
			then
				continue
			end

			local args = {}
			create_selected_item_common_args(selected, args)
			local id = context:show_ui(self, nil, unpack(args))
			table.insert(self.selection_ui_ids, id)
		end
	end

	-- weld ui
	do
		local welds_disabled = #selected_base_parts < 2

		-- weld info
		do
			local weld_text
			if welds_disabled then
				weld_text = "select at least two base parts to create a weld, currently selected: " .. tostring(#selected_base_parts);
			else
				weld_text = "weld " .. tostring(#selected_base_parts) .. " base parts:";
			end

			local args: types.text_label_args = {
				label = weld_text
			}
			local id = context:show_ui(self, nil, { type = "label", args = args })
			table.insert(self.selection_ui_ids, id)
		end

		for _, selected in selected_base_parts do
			local args = {}
			create_selected_item_common_args(selected, args)

			-- create weld button
			if not welds_disabled then
				local button_args: types.text_button_args = {
					label = "Weld here";
					click_handler = function()
						if debug_log then print("create weld selected_base_parts", #selected_base_parts) end
						local selected = selected :: BasePart
						local recording = ChangeHistoryService:TryBeginRecording("Weld " .. tostring(#selected_base_parts) .. " parts")
						assert(recording)
						for _, selected_base_part in selected_base_parts do
							local selected_base_part = selected_base_part :: BasePart
							if selected_base_part == selected then continue end

							local weld = Instance.new("Weld")
							weld.Part0 = selected
							weld.Part1 = selected_base_part
							weld.C1 = CFrame.new(selected.Position - selected_base_part.Position)
							weld.Name = selected_base_part.Name
							weld.Parent = selected
						end
						ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
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

	-- motor6d ui
	do
		local motor6d_disabled = 2 ~= #selected_attachments

		-- motor6d info
		do

			local motor6d_text
			if motor6d_disabled then
				motor6d_text = "select two attachments to create a motor6d, currently selected: " .. tostring(#selected_attachments);
			else
				motor6d_text = "create motor5d:";
			end

			local args: types.text_label_args = {
				label = motor6d_text
			}
			local id = context:show_ui(self, nil, { type = "label", args = args })
			table.insert(self.selection_ui_ids, id)
		end

		for _, selected in selected_attachments do
			local args = {}

			-- add parent info
			do
				assert(selected.Parent)
				create_selected_item_common_args(selected.Parent, args)
			end

			create_selected_item_common_args(selected, args)

			-- create weld button
			if not motor6d_disabled then
				local button_args: types.text_button_args = {
					label = "Create Motor6d here";
					click_handler = function()
						if debug_log then print("create motor6d selected_base_parts", #selected_base_parts) end
						local selected = selected :: BasePart
						local recording = ChangeHistoryService:TryBeginRecording("Create Motor6d " .. tostring(#selected_base_parts) .. " parts")
						assert(recording)
						for _, selected_base_part in selected_base_parts do
							local selected_base_part = selected_base_part :: BasePart
							if selected_base_part == selected then continue end

							local weld = Instance.new("Weld")
							weld.Part0 = selected
							weld.Part1 = selected_base_part
							weld.C1 = CFrame.new(selected.Position - selected_base_part.Position)
							weld.Name = selected_base_part.Name
							weld.Parent = selected
						end
						ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
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
end

local function execute_show_create_button(self: types.step, context: types.step_context)
	local self = self :: create_joint_step

	local selection = Selection:Get()

	local function on_selection_changed()
		if debug_log then print("on_selection_changed") end
		show_selection_ui(self, context)
	end

	local selection_changed = Selection.SelectionChanged:Connect(on_selection_changed)
	context:register_connection(self, selection_changed)

	on_selection_changed()
end

local step_constructors: { () -> types.step } = {
	function(): types.step
		local instance: create_joint_step = {
			name = "create joint";
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
