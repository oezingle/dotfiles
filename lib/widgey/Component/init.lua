local class = require("lib.30log")
local unpack = require("src.agnostic.version.unpack")
local serialize_prop = require("lib.widgey.Component.serialize_prop")

---@module 'lib.widgey.XMLTransformer'
local XMLTransformer

---@module 'lib.widgey.component_db'
local component_db

-- silly little hack - static rendering works without mocks even!
local wibox = package.loaded['wibox']

-- local wibox = require("wibox")

---@alias Component.Props { children: Component[]?, [string]: any }

---@class Component.Parent
---@field static boolean?
---@field is_static fun(self: Component.Parent): boolean
---@field add_suffix_code fun(self: Component.Parent, code: string|function, child_key: number[]?): nil

---@class Component : Component.Parent, Log.BaseFunctions
---@operator call:Component
---@field props Component.Props
---@field protected code_props table<string, any>
---@field parent Component.Parent
---@field default_props Component.Props?
---@field render fun(self: Component): any
local Component = class("Component")

-- shims & dependency injectors!
do
    function Component.set_xml_transformer(XMLTransformer_lib)
        XMLTransformer = XMLTransformer_lib
    end

    function Component.set_component_db(component_db_lib)
        component_db = component_db_lib
    end

    Component._old_extend = Component.extend

    ---@param name string
    ---@param component_name string? if you want a different key in the component table
    ---@return Component
    function Component:extend(name, component_name)
        local class = self:_old_extend(name)

        component_name = component_name or name

        component_db.add(component_name, class)

        return class
    end
end

function Component:init(props)
    if props then
        self:set_props(props)
    end
end

--- Set the parent of the Component. Ignores nil parents.
---@param parent Component.Parent
---@param index number
function Component:set_parent(parent, index)
    self.parent = parent

    self.props._component_index = index

    return self
end

-- TODO fake nil for default props for typechecking
-- https://stackoverflow.com/questions/40441508/how-to-represent-nil-in-a-table

Component.codegen_handlers = {
    ---@param self Component
    ---@param prop { [1]: string, [2]: string|function }[]
    onSignal = function(self, prop)
        for _, signal in pairs(prop) do
            local name = signal[1]
            local cb = signal[2]

            if type(cb) == "function" then
                cb = string.format("load(%q)", string.dump(cb, true))
            end

            self:add_suffix_code(string.format([[function(w)
                w:connect_signal(%q, %s)
            end]], name, cb))
        end
    end,
    ---@param self Component
    ---@param cb string|function
    onClick = function(self, cb)
        if type(cb) == "function" then
            cb = string.format("load(%q)", string.dump(cb, true))
        end

        self:add_suffix_code(string.format([[function (w)
            w:connect_signal("button::press", function (w, lx, ly, button)
                if button == 1 or button == 2 or button == 3 then
                    ;(%s)(w, lx, ly, button)
                end
            end)
        end]], cb))
    end
}

--- !! renderer-specific !!
---@param props Component.Props
function Component:set_props(props)
    self.props = {}

    self.code_props = {}

    for k, v in pairs(self.default_props or {}) do
        self.props[k] = v
    end

    for k, v in pairs(props) do
        -- TODO check typings
        if self.codegen_handlers[k] then
            -- * stupid issue here - if you try to specify a codegen prop
            -- * value without literal brackets (ie if a codegen handler 
            -- * expects a string argument) it'll parse that as lua and
            -- * throw a big ol error. (this is an issue caused by static)
            if type(v) == "string" then
                local fn, err = load("return " .. v)

                if fn then
                    v = fn()
                else
                    error(err)
                end
            end

            self.code_props[k] = v
        else
            -- TODO don't love this level of nesting
            if self:is_static() and k ~= "children" then
                self.props[k] = assert(serialize_prop(v))
            else
                self.props[k] = v
            end
        end
    end

    if type(props.children) == "table" then
        for i, child in pairs(props.children) do
            child:set_parent(self, i)
        end
    end

    return self
end

--- Recursively generate any suffix code needed.
function Component:codegen()
    for k, v in pairs(self.code_props) do
        self.codegen_handlers[k](self, v)
    end

    if type(self.props.children) == "table" then
        for _, child in pairs(self.props.children) do
            child:codegen()
        end
    end
end

-- TODO get ready to replace all of this when I add XML components
-- todo protected
-- code is either a string (static) or fn (dynamic)
---@param code string|function
---@param child_key number[]?
function Component:add_suffix_code(code, child_key)
    assert(self.parent, string.format("Component %s has no parent", tostring(self)))

    child_key = child_key or {}

    -- table.insert(child_key, 1, self.props._component_index)

    self.parent:add_suffix_code(code, child_key)
end

-- todo protected
function Component:is_static()
    if self.static ~= nil then
        return self.static
    end

    if self.parent then
        return self.parent:is_static()
    end

    return false
end

--- TODO break out into separate file
---@param children Component[]
local function render_children(children)
    local ret = {}

    for _, child in pairs(children or {}) do
        -- inserting by index is faster, but breaks if a component returns nil
        -- for example, if the component only renders in static mode
        table.insert(ret, child:render())
    end

    return ret
end

---@param children Component[]|"self.props.children" children can be the string "self.props.children"
local function __render_children(children)
    if type(children) == "string" then
        return "self.props.children"
    else
        return unpack(render_children(children))
    end
end

--- !! renderer-specific !!
---@param code string
function Component:lua(code)
    if self:is_static() then
        local transformed = code
            :gsub("(self%.props%.([%a_][%a_%d]*))", function(_, prop)
                if prop ~= "children" then
                    return tostring(self.props[prop])
                end
            end)
            :gsub(
                "self%.props%.children",
                table.concat({ __render_children(self.props.children) }, ",\n")
            )

        return transformed
    else
        -- TODO doesn't work for margin??
        code = code:gsub("self%.props%.children", "__render_children(self.props.children)")

        local env = setmetatable({ self = self, wibox = wibox, __render_children = __render_children }, { __index = _G })

        local fn, err = load("return " .. code, tostring(self), nil, env)

        if fn then
            return fn()
        else
            error(err)
        end
    end
end

function Component:xml(xmldoc)
    return self:lua(XMLTransformer()
        :set_static(self:is_static())
        :set_parent(self, 1)
        :set_document(xmldoc)
        :render())
end

return Component
