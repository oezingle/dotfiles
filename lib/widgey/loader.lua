local XMLTransformer = require("lib.widgey.XMLTransformer")

local class = require("lib.30log")

local f_and_s = require("lib.widgey.f_and_s")
local ftos = f_and_s.ftos

--- A class to act as a parent to an XMLTransformer and shove suffix code back into the component
---@class SuffixCodeScapegoat : Component.Parent, Log.BaseFunctions
---@field suffix_code string[]
local SuffixCodeScapegoat = class("SuffixCodeScapegoat")

function SuffixCodeScapegoat:init()
    self.suffix_code = {}
end

function SuffixCodeScapegoat:is_static()
    return true
end

function SuffixCodeScapegoat:get_suffix_code()
    return self.suffix_code
end

---@param code string|function
---@param child_key number[]
function SuffixCodeScapegoat:add_suffix_code(code, child_key)
    child_key = child_key or {}

    local code = ftos(code)

    local child_key = string.format("{ %s }", table.concat(child_key, ", "))

    table.insert(self.suffix_code, string.format("self:add_suffix_code(%s, %s)", code, child_key))
end

---@param content string
local function transform(content)
    local xmlpattern = "(self:xml%(%[%[(.-)%]%]%))"

    content = content:gsub(xmlpattern, function(_, xml)
        local parent = SuffixCodeScapegoat()

        local transformed = XMLTransformer()
            :set_static(true)
            :set_parent(parent, -1)
            :set_document(xml)
            :render()

        return string.format("%s\n%s", transformed, table.concat(parent:get_suffix_code(), ",\n"))
    end)

    print(content)

    return content
end

-- https://mark1626.github.io/posts/2021/04/21/lua-module-loader/
-- Adapted from lua 5.2

-- TODO also enable a compile-in-place version
-- TODO <name>.x.lua loader transpiles to .lua, spits out __<name>.lua,
-- TODO (name change needed for this loader to work)
-- TODO calls require() for you on the newly transpiled code.
-- TODO also checks mtime to make sure recompile not needed

---@diagnostic disable-next-line:deprecated
table.insert(package.searchers or package.loaders, function(modulename)
    local modulepath = string.gsub(modulename, "%.", "/")
    for path in string.gmatch("./?.x.lua;./?/init.x.lua", "([^;]+)") do
        local filename = string.gsub(path, "%?", modulepath)
        local file = io.open(filename, "rb")
        if file then
            local content = assert(file:read("*a"))
            local transformed_file = transform(content)

            -- TODO bad assert! bad!
            return assert(load(transformed_file, modulename), string.format("Tranforming \"%s\" failed", modulename))
        end
    end

    -- TODO lame ass error message
    return "Unable to load file " .. modulename
end)
