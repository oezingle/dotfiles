local Component = require("lib.widgey.Component")

---@param wibox string
---@param default_props Component.Props?
local function generate_wibox_component(wibox, default_props)
    ---@class GeneralWiboxComponent : Component
    local Class = Component:extend(string.format("WiboxComponent<%s>", wibox), wibox)

    Class.wibox = wibox

    Class.default_props = {}
    for k, v in pairs(default_props or {}) do
        Class.default_props[k] = v
    end

    -- code is either a string (static) or fn (dynamic)
    ---@param code string|function
    ---@param child_key number[]?
    function Class:add_suffix_code(code, child_key)
        assert(self.parent, string.format("Component %s has no parent", tostring(self)))

        child_key = child_key or {}

        table.insert(child_key, 1, self.props._component_index)

        self.parent:add_suffix_code(code, child_key)
    end

    -- TODO FUCKING TRAILING COMMA
    -- as it turns out one trailing comma is actually ok
    ---@diagnostic disable-next-line:duplicate-set-field
    function Class:render()
        local args = {}

        for k in pairs(self.props) do
            if k ~= "children" then
                table.insert(args, string.format("%s = self.props.%s", k, k))
            end
        end

        return self:lua(string.format([[{
            widget = %s,
            %s,
            self.props.children
        }]], self.wibox, table.concat(args, ",\n")))
    end

    return Class
end

return generate_wibox_component
