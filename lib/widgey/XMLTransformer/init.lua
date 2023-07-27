local class = require("lib.30log")
local slaxml = require("lib.slaxml")

local unpad = require("lib.widgey.unpad") -- TODO move to ./XMLTransformer/ ?
local xml_gsub       = require("lib.widgey.XMLTransformer.xml_gsub")

local component_db = require("lib.widgey.component_db")
local Component = require("lib.widgey.Component")

local f_and_s = require("lib.widgey.f_and_s")
local ftos = f_and_s.ftos
local stof = f_and_s.stof

---@class C_XML.Node
---@field type "document"|"text"|"comment"|"element"|"pi"
---@field name string
---@field parent XML.Node
---@field kids XML.Node[]?

---@class XML.Node.Document : C_XML.Node
---@field type "document"
---@field root XML.Node
---@field parent nil

---@class XML.Node.Text : C_XML.Node
---@field type "text"
---@field value string

---@class XML.Node.Comment : C_XML.Node
---@field type "comment"
---@field value string

---@class XML.Node.Element : C_XML.Node
---@field type "element"
---@field attr XML.Attribute[]

---@alias XML.Attribute { type: "attribute", name: string, value: string, nsURI: string, nsPrefix: string, parent: XML.Attribute[] }

---@alias XML.Node C_XML.Node | XML.Node.Text | XML.Node.Document | XML.Node.Comment | XML.Node.Element

---@class XMLTransformer : Component.Parent, Log.BaseFunctions
---@field indent_char string
---@field root Component
---@field static boolean
---@field suffix_code { code: function|string, key: number[] }[]
---@field parent Component.Parent?
---@operator call:XMLTransformer
local XMLTransformer = class("XMLTransformer")

Component.set_xml_transformer(XMLTransformer)

local CommentComponent = require("lib.widgey.components.CommentComponent")

local Textbox = component_db.find("wibox.widget.textbox")

---@param doc string?
function XMLTransformer:init(doc)
    if doc then
        self:set_document(doc)
    end

    self.static = false

    self.suffix_code = {}
end

--- TODO transform doc before passing it in
--- - prop={value} -> prop="{value}"
--- - prop="{"value"}" -> prop="{\"value\"}"
--- this first rule is hard


---@param doc string
---@return self self
function XMLTransformer:set_document(doc)
    ---@type XML.Node.Document
    local xml = slaxml:dom(xml_gsub(doc))

    local first_node = self:first_child(xml)

    local root = assert(self:create_node(first_node), "No root node")

    root:set_parent(self, 1)

    root:codegen()

    self.root = root

    return self
end

--- Set static rendering mode - references to self.props aren't removed, so components work nicely!
---@param static boolean
---@return self self
function XMLTransformer:set_static(static)
    self.static = static

    return self
end

function XMLTransformer:is_static()
    return self.static
end

---@param root XML.Node.Document
function XMLTransformer:first_child(root)
    local children = root.kids

    for _, child in pairs(children or {}) do
        if child.type == "element" then
            return child
        end
    end
end

---@param code string|function
---@param child_key number[]?
function XMLTransformer:add_suffix_code(code, child_key)
    table.insert(self.suffix_code, { code = code, key = child_key })
end

---@param widget table
---@param child_key number[]
function XMLTransformer.find_component(widget, child_key)
    -- we can't just jump to children[index] because components
    -- can render outputs that don't always result in widgets
    -- ie comments
    table.remove(child_key, 1)

    -- todo kinda messy
    local index = child_key[1]

    if index == nil then
        return widget
    end

    local children = widget:get_children()

    for _, child in pairs(children) do
        if child._component_index == index then
            if #child_key > 1 then
                return XMLTransformer.find_component(child, child_key)
            else
                return child
            end
        end
    end

    error("No Child")
end

---@param parent Component.Parent
---@param index number
function XMLTransformer:set_parent(parent, index)
    self.parent = parent

    return self
end

---@return any
function XMLTransformer:render_with_suffix_code()
    local widget = self.root:render()

    if self:is_static() then
        local suffix_code = {}

        for _, obj in pairs(self.suffix_code) do
            local code = ftos(obj.code)

            local suffix = string.format(unpad([[
            do
                local child = __find_component(__widget, { %s })

                ;(%s)(child)
            end
        ]]), table.concat(obj.key, ", "), code)

            table.insert(suffix_code, suffix)
        end

        return string.format(unpad([[
            do
                local __find_component = %s

                local __widget = %s

                %s

                return __widget
            end
        ]]), ftos(self.find_component), widget, table.concat(suffix_code, "\n\n"))
    else
        for _, obj in pairs(self.suffix_code) do
            local code = stof(obj.code)

            local child = self.find_component(widget, obj.key)

            code(child)
        end

        return widget
    end
end

--- !! renderer-specific !!
function XMLTransformer:render()
    if self.parent then
        for _, obj in pairs(self.suffix_code) do
            self.parent:add_suffix_code(obj.code, obj.key)
        end

        return self.root:render()
    else
        return self:render_with_suffix_code()
    end
end

--- !! renderer-specific !!
---@param value string
function XMLTransformer:parse_xml_value(value)
    local lua_value = value:match("^%{(.*)%}$")

    if self:is_static() then
        if lua_value then
            -- return the literal in the brackets
            return lua_value
        else
            -- I don't know why this match is broken
            --if value:match("\n") then
            --    return "\"" .. value .. "\""
            --else
            -- This is just a string
            return string.format("%q", value)
            --end
        end
    else
        if lua_value then
            if lua_value:match("%d+%.?%d-") then
                return tonumber(lua_value)
            end

            if lua_value == "true" then
                return true
            elseif lua_value == "false" then
                return false
            end

            -- self.parent hack fixes props issue in Dynamic mode for XML components
            stof(lua_value, nil, setmetatable({ self = self.parent }, { __index = _G }))
        else
            -- return native string
            return value
        end
    end
end

---@param xmlnode XML.Node
---@return Component|nil
function XMLTransformer:create_node(xmlnode)
    if self:ignore_node(xmlnode) then
        return nil
    end

    if xmlnode.type == "comment" then
        local component = CommentComponent()

        return component
            :set_props({ comment = xmlnode.value })
    elseif xmlnode.type == "text" then
        local text = unpad(xmlnode.value)

        ---@type Component
        local component = Textbox()

        return component
            :set_props({ text = self:parse_xml_value(text) })
    elseif xmlnode.type == "element" then
        ---@type Component
        local component = component_db.find(xmlnode.name)()

        ---@type Component.Props
        local props = {
            children = {}
        }

        for _, attr in pairs(xmlnode.attr) do
            local name = attr.name
            local value = attr.value

            if name and value then
                props[name] = self:parse_xml_value(value)
            end
        end

        -- silly fix: xml components have text of {self.props.children} as an inlet.
        -- this if statement detects that
        if #xmlnode.kids == 1 and xmlnode.kids[1].type == "text" and unpad(xmlnode.kids[1].value) == "{self.props.children}" then
            props.children = "self.props.children"
        else
            for _, kid in pairs(xmlnode.kids or {}) do
                local child = self:create_node(kid)

                table.insert(props.children, child)
            end
        end

        component:set_props(props)

        return component
    end

    print(string.format("unhandled XML node type %s", xmlnode.type))

    return nil
end

--- Check if this XML.Node should be ignored
---@param xmlnode XML.Node
---@return boolean
function XMLTransformer:ignore_node(xmlnode)
    if xmlnode.type == "text" and xmlnode.value:match("^%s*$") then
        return true
    end

    return false
end

return XMLTransformer
