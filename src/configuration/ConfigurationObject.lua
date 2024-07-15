local nil_coalesce        = require("src.polyfill.nil_coalesce")
local split               = require("src.polyfill.string.split")

-- TODO __index metamethod would do wonders here - toss an error immediately.

--- Would be an alias, but that would break non-templated usage
---@class Zingle.Awesome.ConfigurationObject.Fields<T> : { key: string, display: string | false, enabled?: boolean, type: T, children: Zingle.Awesome.ConfigurationObject[] }
---@field key string
---@field display string | false Pretty printed key, or false if this section should be hidden
---@field enabled boolean Whether or not users can touch these values. Does not control if they are visible.
---@field type Zingle.Typed.Type | nil The type of this section, or nil if the section is key-value using its children.
---@field children Zingle.Awesome.ConfigurationObject[]

---@class Zingle.Awesome.ConfigurationObject<T> : Log.BaseFunctions, Zingle.Awesome.ConfigurationObject.Fields, { type: T, key: string, display: string, enabled: boolean, register_child: (fun(self: self, object: Zingle.Awesome.ConfigurationObject)), default: (fun(self: self, passed: any): any) }
---
---@field children Zingle.Awesome.ConfigurationObject[]
---
---@operator call:Zingle.Awesome.ConfigurationObject
local ConfigurationObject = class("Zingle.Awesome.ConfigurationObject")

---@param options Zingle.Awesome.ConfigurationObject.Fields
function ConfigurationObject:init(options)
    self.key = options.key
    self.display = options.display
    self.enabled = nil_coalesce(options.enabled, true)
    self.type = options.type

    self.children = options.children or {}
end

---@param object Zingle.Awesome.ConfigurationObject
function ConfigurationObject:register_child(object)
    table.insert(self.children, object)
end

---@param passed any
function ConfigurationObject:default(passed)
    if not self.enabled then
        return nil
    end

    local default = self.type and self.type:default(passed) or {}

    -- TODO edge case where default is a non-iterable value - probably unlikely, but could occur!
    for _, child in ipairs(self.children) do
        local key = child.key

        local child_passed = type(passed) == "table" and passed[key]

        default[key] = child:default(child_passed)
    end

    return default
end

function ConfigurationObject:__tostring()
    local top_line = string.format("%s %q <%s>", self.type:display(), self.key, self.type:default()) ..
        (self.display and string.format(" - Displays as %q", self.display) or "")

    local lines = {
        top_line
    }

    for _, child in ipairs(self.children) do
        local s_child = tostring(child)

        for _, line in ipairs(split(s_child, "\n")) do
            table.insert(lines, "\t" .. line)
        end
    end

    return table.concat(lines, "\n")
end

function ConfigurationObject:tolua(config)
    local default = self.type:default(config)

    local t = type(default)

    -- TODO FIXME sometimes table values' defaults simply consist of key-value
    -- TODO pairs. represent this! ( see src/configuration/section/default.lua:13)
    if t == "table" then
        local lines = {}

        for _, child in ipairs(self.children) do
            local subconfig = type(config) == "table" and config[child.key] or nil

            local lua_child = child:tolua(subconfig)

            for _, line in ipairs(split(lua_child, "\n")) do
                table.insert(lines, "\t" .. line)
            end
        end

        return string.format("{\n%s\n}", table.concat(lines, "\n"))
    elseif t == "string" then
        return string.format("%s = %q", self.key, default)
    elseif t == "number" or t == "nil" or t == "boolean" then
        return string.format("%s = %s", self.key, tostring(default))
    else
        error(string.format("Unable to luaify value of type %s", t))
    end

    -- return string.format("%s = %s", self.key, luaify_value(default))
end

---@generic T
---@param options Zingle.Awesome.ConfigurationObject.Fields<`T`>
---@return Zingle.Awesome.ConfigurationObject<T>
function ConfigurationObject.create(options)
    return ConfigurationObject(options)
end

return ConfigurationObject
