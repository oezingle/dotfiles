local Component = require("lib.widgey_old.Component")
local parse_xml_value = require("lib.widgey_old.parse_xml_value")

---@param wibox string
---@param props string[]
local function generate_wibox_component(wibox, props)
    ---@class GeneralWiboxComponent : Component
    local Class = Component:extend(string.format("WiboxComponent[%s]", wibox))

    Class.wibox = wibox

    Class.prop_keys = {}
    for _, v in pairs(props) do
        Class.prop_keys[v] = true
    end

    function Class:render()
        local props = self.props

        local args = {
            string.format("widget = %s", self.wibox)
        }

        for k, v in pairs(props) do
            if k ~= "children" then
                table.insert(args, tostring(k) .. " = " .. parse_xml_value(v))
            end
        end

        table.insert(args, props.children)

        return string.format("{\n%s\n}", table.concat(args, ",\n"))
    end

    return Class
end

return generate_wibox_component
