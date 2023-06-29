local Component = require("lib.widgey.Component")

local WiboxWidgetComponent = Component:extend("WiboxWidgetComponent", "wibox.widget")

function WiboxWidgetComponent:render()
    return self:lua("wibox.widget(self.props.children)")
end

return WiboxWidgetComponent
