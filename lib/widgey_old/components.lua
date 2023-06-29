local generate_wibox_component = require("lib.widgey_old.component.generate_wibox_component")
local LiteralComponent = require("lib.widgey_old.component.LiteralComponent")
local WiboxWidgetComponent = require("lib.widgey_old.component.WiboxWidgetComponent")
local Vertical = require("lib.widgey_old.component.Vertical")

-- TODO either break table out into new file (yay!) or create dependency injectors (ew!)
local components = {
    ---@type table<string, Component>
    table = {
        ["wibox.container.margin"] = generate_wibox_component("wibox.container.margin", { "margins" }),
        ["wibox.widget.textbox"] = generate_wibox_component("wibox.widget.textbox", { "text" }),
        ["wibox.layout.flex.vertical"] = generate_wibox_component("wibox.layout.flex.vertical", {}),
        ["wibox.widget"] = WiboxWidgetComponent,
        ["Literal"] = LiteralComponent,
        ["Vertical"] = Vertical,
    }
}

---@param name string
function components.find(name)
    return components.table[name]
end

---@param name string
---@param class Component
function components.add(name, class)
    components.table[name] = class
end

-- TODO CHECK PROP_KEYS
---@param name string
---@param props table<string, any>
function components.create(name, props)
    local Component = components.find(name)

    assert(Component, string.format("Component by name %s not found", name))

    local icomponent = Component()

    icomponent:set_props(props)

    return icomponent:render()
end

return components
