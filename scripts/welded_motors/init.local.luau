--!strict

-- Welded Motors Plugin Stub
-- Place this script in a .rbxm plugin file

local ui_module = require(script.ui)

local toolbar = plugin:CreateToolbar("Welded Motors")
local button = toolbar:CreateButton("Open", "Open Welded Motors Widget", "")

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Left,  -- Dock to the left by default
	true,                        -- Initially enabled
	false,                       -- Don't override previous enable state
	300,                         -- Default width
	200,                         -- Default height
	150,                         -- Minimum width
	100                          -- Minimum height
)

local widget = plugin:CreateDockWidgetPluginGuiAsync("WeldedMotorsWidget", widgetInfo)
widget.Title = "Welded Motors"

-- Button toggles the widget
button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

local toggelWidgetAction = plugin:CreatePluginAction("ToggleWidgetActionId"
	, "Toggle Welded Motors"
	, "Toggle Wedled Mototrs widget"
)

local function toggleWidget()
	widget.Enabled = not widget.Enabled
end

local ui = ui_module.createUi(widget)
