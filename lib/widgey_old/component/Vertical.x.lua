
local Component = require("lib.widgey_old.Component")

local Vertical = Component:extend("Vertical")

Vertical.prop_keys = {
    children = true,
    spacing = true,
}

function Vertical:render()
    return self:xml([[
        <wibox.layout.flex.vertical spacing="{self.props.spacing}">
            {self.props.children}
        </wibox.layout.flex.vertical>
    ]])
end

return Vertical