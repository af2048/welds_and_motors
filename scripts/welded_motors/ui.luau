--!strict

local debug_log = true

local types = require(script.Parent.steps_types)
local steps_factory = require(script.Parent.steps_factory)

export type ui = {

}

type ui_impl = ui & types.step_context & {
	widget: DockWidgetPluginGui;

	next_ui_id: number;
	step_connections: { [types.step]: { RBXScriptConnection } };
	step_ui: { [types.step]: { [number]: Frame } };

	content_frame: Frame?;

	all_steps: { types.steps }?;
}

local function init(self: ui_impl)
	if debug_log then print("init") end

	self.all_steps = steps_factory.createSteps();
	assert(self.all_steps)
	for _, steps in self.all_steps do
		steps[1]:execute(self)
	end
end

local function cleanup(self: ui_impl)
	if debug_log then print("cleanup") end

	for step, connections in self.step_connections do
		if debug_log then print("cleanup, step", `[{step.name}]`, "connections", #connections) end
		for _, c in connections do
			c:Disconnect()
		end
	end
	self.step_connections = {}

	for step, frames in self.step_ui do
		for id, frame in frames do
			if debug_log then print("cleanup, step", `[{step.name}]`, "frame", id) end
			frame:Destroy()
		end
	end
	self.step_ui = {}

	self.all_steps = {}
end

local function create(self: ui_impl)
	if debug_log then print("create") end

	local main = script.Parent.main:Clone()
	main.Parent = self.widget
	self.content_frame = main:FindFirstChild("mainScrollingFrame"):FindFirstChild("content")

	self.widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		if self.widget.Enabled then
			init(self)
		else
			cleanup(self)
		end
	end)
end

local function create_ui_element(item: types.step_ui_item, connections: { RBXScriptConnection }): Instance
	if item.type == "button" then
		local args = item.args :: types.text_button_args
		local button = script.Parent.text_button_template:Clone()
		button.Text = args.label
		table.insert(connections, button.Activated:Once(function() args.click_handler() end))
		return button

	elseif item.type == "label" then
		local args = item.args :: types.text_label_args
		local text_label = script.Parent.text_label_template:Clone()
		text_label.Text = args.label
		return text_label

	else
		assert(false, "unknown type[" .. tostring(item.type) .. "]")
	end
end

local function show_ui(self: types.step_context, step: types.step, id: types.ui_id?, ...): types.ui_id
	local self = self :: ui_impl

	local result_id = id

	if debug_log then print("show_ui, step", `[{step.name}]`, "id", id) end

	local frame: Frame?
	if id then
		frame = self.step_ui[step][id]
		assert(frame, "not found frame with id" .. tostring(id))
		for _, child in frame:GetChildren() do
			child:Destroy()
		end
	else
		frame = script.Parent.frame_template:Clone()
		assert(self.content_frame)
		frame.Parent = self.content_frame
		self.step_ui[step] = self.step_ui[step] or {}
		self.step_ui[step][self.next_ui_id] = frame
		result_id = self.next_ui_id
		self.next_ui_id += 1
	end

	local ui_items: { types.step_ui_item } = { ... }

	if debug_log then print("show_ui, step", `[{step.name}]`, "ui_items", #ui_items) end

	for i, ui_item in ui_items do
		if debug_log then print("show_ui", i, "ui_item.type", `[{ui_item.type}]`) end
		self.step_connections[step] = self.step_connections[step] or {}
		local item = create_ui_element(ui_item, self.step_connections[step]);
		(item :: GuiObject).LayoutOrder = i
		item.Parent = frame
	end

	assert(result_id)
	return result_id
end

local function switch_to_next_step(self: types.step_context, step: types.step)
	local self = self :: ui_impl
end

local function register_connection(self: types.step_context, step: types.step, connection: RBXScriptConnection)
	local self = self :: ui_impl

	self.step_connections[step] = self.step_connections[step] or {}
	table.insert(self.step_connections[step], connection)
end

return {
	createUi = function(widget: DockWidgetPluginGui): ui

		local instance: ui_impl = {
			widget = widget;

			next_ui_id = 0;
			step_connections = {};
			step_ui = {};

			switch_to_next_step = switch_to_next_step;
			show_ui = show_ui;
			register_connection = register_connection;
		}

		create(instance)

		if widget.Enabled then
			init(instance)
		end

		return instance
	end,
}
