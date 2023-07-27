
local Component = require("lib.widgey.Component")

local Vertical = Component:extend("Vertical")

-- TODO why the fuck the transformer just not work :(
-- TODO first xml_gsub replacer (quoteless literals) might be broken

function Vertical:render()
    return self:xml([[
        <wibox.layout.flex.vertical onClick={function () print("hi") end} spacing="{self.props.spacing}">
            {self.props.children}
        </wibox.layout.flex.vertical>
    ]])
end

return Vertical