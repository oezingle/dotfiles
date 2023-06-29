
local Component = require("lib.widgey_old.Component")

---@class LiteralComponent : Component
local LiteralComponent = Component:extend("LiteralComponent")

LiteralComponent.prop_keys = {
    literal = true
}

function LiteralComponent:render()
    return self.props.literal
end

return LiteralComponent