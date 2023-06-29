local class = require("lib.30log")
-- local components = require("lib.widgey_old.components")

---@module 'lib.widgey_old.XMLTransformer'
local XMLTransformer

-- TODO FIXME: default props. NOW!

local Component = class("Component")

function Component.set_xml_transformer(XMLTransformer_lib)
    XMLTransformer = XMLTransformer_lib
end

---@generic T
---@param self Component<T>
---@param props T
---@return self self
function Component:set_props(props)
    self.props = props

    return self
end

Component._old_extend = Component.extend

-- TODO way to control name of class vs name in component table. Eg. wibox namespace. WiboxWidget<wibox.widgetname> vs wibox.widgetname

---@param name string
---@param component_name string? if you want a different key in the component table
---@return Component
function Component:extend(name, component_name)
    local class = self:_old_extend(name)

    component_name = component_name or name

    -- components.add(name, class)

    return class
end

function Component:render()
    return ""
end

--- TODO this is hacky
-- ---@protected
---@param xmldoc string
function Component:xml(xmldoc)
    local PROP_PATTERN = "%%{self%%.props%%.%s%%}"

    for prop, value in pairs(self.props) do
        if prop ~= "children" then
            xmldoc = xmldoc:gsub(
                string.format(PROP_PATTERN, prop),
                value
            )
        end
    end

    local transformed = XMLTransformer():set_document(xmldoc):run()

    -- Children is consumed improperly as text if left pre-transform
    if self.props.children then
        transformed = transformed:gsub(
            string.format(PROP_PATTERN, "children"),
            self.props.children
        )
    end

    --if self.props.children then
    --    transformed = transformed:gsub("{self.props.children}", "unpack(self.props.children)")
    --end
    --
    --return self:_run_lua("return " .. transformed)

    return transformed
end

--[[
-- TODO call get_locals() from here? mayhaps?
---@protected
---@param luastring string
function Component:_run_lua(luastring)
    local env = setmetatable({ self = self }, { __index = _G })
    
    local fn, err = load(luastring, nil, nil, env)

    if fn then
        return 
    end
end
]]

return Component
