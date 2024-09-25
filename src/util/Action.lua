local log = require("lib.log")
local typed = require("src.util.typed.typed")

---@class Zingle.Awesome.Action : Log.BaseFunctions
---@field log Logger
---@field call fun(self: self, ...: any) Handle this action generically
---@field on_call fun(self: self, ...: any)
---@field command string?
---@field args Zingle.Typed.Type[]?
---
---@field names table<string, Zingle.Awesome.Action>
---@field commands table<string, Zingle.Awesome.Action>
---@operator call:Zingle.Awesome.Action
local Action = class("Zingle.Awesome.Action", {
    names = {},
    commands = {},
})

setmetatable(Action.names, { __mode = "v" })
setmetatable(Action.commands, { __mode = "v" })

function Action:init(name)
    self.name = name

    Action.names[name] = self
end

---@param command string?
---@return Zingle.Awesome.Action
function Action:set_command(command)
    local command = command
    if command then
        Action.commands[command] = self
    end

    return self
end

function Action:set_logger(log)
    self.log = log

    return self
end

---@param name string
---@param ... any
function Action.call_by_name (name, ...)
    local action = Action.names[name]

    if not action then
        log.warn(string.format("Unknown action requested by name %q", name))

        return
    end

    action:call(...)
end

function Action:call(...)
    --- Allow :call with tables (instances) or strings (action name)
    if type(self) == "string" then
        return Action.call_by_name(self, ...)
    end

    local args = table.pack(...)


    if self.args and not typed.check(self.args, args) then
        -- TODO FIXME nice error
        return
    end

    -- TODO FIXME pcall here
    self.on_call(self, ...)
end

---@class Zingle.Awesome.Action.Options
---@field command string?
---@field args Zingle.Typed.Type[]?
---@field on_call fun(self: Zingle.Awesome.Action, ...: any[])?

---@param name string
---@param options Zingle.Awesome.Action.Options
---@return Zingle.Awesome.Action
function Action.create(name, options)
    local instance = Action(name)
        :set_command(options.command)

    instance.on_call = options.on_call

    return instance
end

return Action
