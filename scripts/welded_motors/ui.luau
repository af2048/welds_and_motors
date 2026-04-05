--!strict

local debug_log = true

export type ui = {

}

type ui_impl = ui & {
	widget: DockWidgetPluginGui;
}

local function init(self: ui_impl)
	if debug_log then print("init") end
end

local function cleanup(self: ui_impl)
	if debug_log then print("cleanup") end
end

local function create(self: ui_impl)
	if debug_log then print("create") end

	local main = script.Parent.main:Clone()
	main.Parent = self.widget

	self.widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		if self.widget.Enabled then
			init(self)
		else
			cleanup(self)
		end
	end)
end

return {
	createUi = function(widget: DockWidgetPluginGui): ui
		local instance: ui_impl = {
			widget = widget;
		}

		create(instance)

		if widget.Enabled then
			init(instance)
		end

		return instance
	end,
}
