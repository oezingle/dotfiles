
local Component = require("lib.widgey.Component")

local generate_wibox_component = require("lib.widgey.components.generate_wibox_component")

local components = {
    ---@private
    table = {}
}

Component.set_component_db(components)

---@param name string
---@param class table
function components.add(name, class)
    components.table[name] = class
end

---@param name string
function components.find(name)
    return assert(components.table[name], string.format("No element '%s'", name))
end

require("lib.widgey.components.WiboxWidgetComponent")

generate_wibox_component("wibox.widget.textbox", {})

generate_wibox_component("wibox.container.margin", {})

generate_wibox_component("wibox.layout.flex.vertical", {})

return components