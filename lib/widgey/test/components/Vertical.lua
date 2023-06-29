
local Component = require("lib.widgey.Component")

local Vertical = Component:extend("Vertical")

function Vertical:render()
    return self:xml([[
        <wibox.layout.flex.vertical spacing="{self.props.spacing}">
            {self.props.children}
        </wibox.layout.flex.vertical>
    ]])
end

return Vertical