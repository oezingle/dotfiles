
local Component = require("lib.widgey_old.Component")

---@class WiboxWidgetComponent : Component
local WiboxWidgetComponent = Component:extend("WiboxWidgetComponent")

WiboxWidgetComponent.prop_keys = {
    children = true
}

function WiboxWidgetComponent:render()
    return string.format("wibox.widget(%s)", self.props.children)
end

return WiboxWidgetComponent