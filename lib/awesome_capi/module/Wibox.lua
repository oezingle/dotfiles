---@meta

---@alias Awesome.Cairo.Context table
---@alias Awesome.Wibox table

---@alias Awesome.Wibox.Widget.Base.WidgetPlacement table

---@alias Awesome.Wibox.Widget.Signal 
---| "widget::layout_changed" 	When the layout (size) change.
---| "widget::redraw_needed" 	When the widget content changed.
---| "button::press" 	        When a mouse button is pressed over the widget.
---| "button::release" 	        When a mouse button is released over the widget.
---| "mouse::enter" 	        When the mouse enter a widget.
---| "mouse::leave"             When the mouse leave a widget.

---@class Awesome.Wibox.Widget
---@field connect_signal Awesome.InstanceConnectSignal<self, Awesome.Wibox.Widget.Signal>
---@field disconnect_signal Awesome.InstanceConnectSignal<self, Awesome.Wibox.Widget.Signal>
---
---@field emit_signal Awesome.InstanceEmitSignal<self, Awesome.Wibox.Widget.Signal>
---
---@field protected _private table
---
---@field fit fun(self: self, context: Awesome.Cairo.Context, width: integer, height: integer): integer, integer
---@field layout fun(self: self, context: Awesome.Cairo.Context, width: integer, height: integer): Awesome.Wibox.Widget.Base.WidgetPlacement[]