local class = require("lib.30log")
local slaxml = require("lib.slaxml")

local components = require("lib.widgey_old.components")
local Component = require("lib.widgey_old.Component")

-- TODO slaxml does a shit job cleaning up text nodes so i need to do this myself

-- TODO rewrite? transpiled code spits out tables, but standard lua spits out text. not good.

local XMLTransformer = class("XMLTransformer", {
    -- spaces or tabs
    indent_char = "\t"
})

Component.set_xml_transformer(XMLTransformer)

---@param doc string?
function XMLTransformer:init(doc)
    if doc then
        self:set_document(doc)
    end

    self.static = false
end

---@param doc string
---@return self self
function XMLTransformer:set_document(doc)
    self.root = slaxml:dom(doc)

    return self
end

function XMLTransformer:first_child()
    local children = self.root.kids

    for _, child in pairs(children or {}) do
        if child.type == "element" then
            return child
        end
    end
end

--- Set static rendering mode - references to self.props aren't removed, so components work nicely!
---@param static boolean
---@return self self
function XMLTransformer:set_static(static)
    self.static = static

    return self
end

--- Generate a lua chunk that creates a wibox.widget from the given XML document
---@return string
function XMLTransformer:run()
    return assert(self:render_node(self:first_child()), "Attempted to render nil")
end

-- TODO children should be
-- - aware of their index array (nth child for all n parents)
-- - able to return suffix code (return self-executing function if need be, allows signals + dynamics)

---@param xmlnode XML.Node
---@return string | nil
function XMLTransformer:render_node(xmlnode)
    if self:ignore_node(xmlnode) then
        return nil
    end

    if xmlnode.type == "comment" then
        --return self:transform_comment(xmlnode --[[ @as XML.CommentNode ]])

        -- TODO return something more useful at some point soon
        return nil
    elseif xmlnode.type == "text" then
        -- Wrap in quotes? i too tired
        xmlnode.value = xmlnode.value:match("^%s*(.-)%s*$")

        local literal = xmlnode.value:match("^%{(.*)%}$")

        if literal then
            return xmlnode.value
        else
            return self:transform_text(xmlnode --[[ @as XML.Node.Text ]])
        end
    elseif xmlnode.type == "element" then
        local children = {}

        for _, kid in pairs(xmlnode.kids or {}) do
            local child = self:render_node(kid)

            if child then
                table.insert(children, child)
            end
        end

        -- annoying ass language server mf
        ---@type { children: string|nil, [string]: string }
        local props = {
            -- TODO good way to ignore comments here (no comma)? metadata?
            children = #children > 0 and table.concat(children, ",\n") or nil
        }

        for _, attr in pairs(xmlnode.attr) do
            local name = attr.name
            local value = attr.value

            if name and value then
                if not self.static then
                    -- Unfulfilled props default to nil if we get to here with them
                    if value:match("^%{self%.props%.%a+%}$") then
                        return "nil"
                    end
                end

                props[name] = value
            end
        end

        return components.create(xmlnode.name, props)
    end

    print(string.format("unhandled XML node type %s", xmlnode.type))

    return nil
end

--[[
--- Pipe the result of the XMLTransformer into load() to create native lua code
-- TODO haven't tested locals yet!
function XMLTransformer:luaify()
    local rendered = self:run()

    local env = setmetatable(get_locals(3), { __index = _G })

    -- prefix return because the value is discarded otherwise. Could be changed in future to allow suffix code
    local fn, err = load("return " .. rendered, "Transformed LuaX", nil, env)

    if fn then
        return fn()
    else
        print(rendered)

        error(err)
    end
end
]]

--- Check if this node should be ignored
---@param xmlnode XML.Node
---@return boolean
function XMLTransformer:ignore_node(xmlnode)
    if xmlnode.type == "text" and xmlnode.value:match("^%s*$") then
        return true
    end

    return false
end

--- Get the depth of the given node in the document
---@param xmlnode XML.Node
---@return number depth
function XMLTransformer:get_depth(xmlnode)
    if xmlnode.parent then
        return self:get_depth(xmlnode.parent) + 1
    end

    return 0
end

---@param comment_node XML.Node.Comment
function XMLTransformer:transform_comment(comment_node)
    return "--" .. comment_node.value
end

-- TODO remove left padding post-newline
---@param text_node XML.Node.Text
function XMLTransformer:transform_text(text_node)
    return XMLTransformer():set_document(
        string.format([[<wibox.widget.textbox text="%s" />]], text_node.value)
    ):run()
end

return XMLTransformer
