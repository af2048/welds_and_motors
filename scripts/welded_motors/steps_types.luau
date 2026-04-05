--!strict

export type step_name = string

export type step = {
	-- for debug only
	name: step_name;
	execute: (self: step, step_context: step_context) -> ();
}

export type steps = { step }

export type ui_type = "button" | "label"

export type text_button_args = {
	label: string;
	click_handler: () -> ();
}

export type text_label_args = {
	label: string;
}

export type ui_item_args = text_button_args | text_label_args

export type step_ui_item = {
	type: ui_type;
	args: ui_item_args;
}

export type ui_id = any

export type step_context = {
	switch_to_next_step: (self: step_context, step: step) -> ();
	-- shows line of ui
	-- creates new line if id is nil
	-- updates existing line if id is provided
	-- returns id of newly created line
	show_ui: (self: step_context, id: ui_id?, ...step_ui_item) -> ui_id;
}

return {}
