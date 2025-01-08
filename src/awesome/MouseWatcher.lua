local GLib = lgi.GLib

if not mouse then
    error("MouseWatcher requires Awesome's mouse API")
end

log.alias("[MouseWatcher]")

---@class Zingle.Awesome.MouseWatcher : Log.BaseFunctions
---@field blocking boolean
---
---@field protected stack Zingle.Awesome.MouseWatcher[]
---@field protected in_loop boolean
---@field last { x: integer, y: integer, poll: {[1]: integer, [2]: integer} }
local MouseWatcher = class("Zingle.Awesome.MouseWatcher")

MouseWatcher.stack = {}
MouseWatcher.last = {
    x = -1,
    y = -1,
}

function MouseWatcher.loop_cb()
    local self = MouseWatcher
    
    local coords = mouse.coords() 

    -- TODO check button changes
    if self.last.x ~= coords.x or self.last.y ~= coords.y then
        for _, watcher in ipairs(self.stack) do
            watcher.on_move(coords)

            if watcher.blocking then
                break
            end
        end
    end

    self.last.x = coords.x
    self.last.y = coords.y
end

---@param on_move fun(coordinates: Awesome.MouseCoordsWithButtons)
---@param blocking boolean?
function MouseWatcher:init(on_move, blocking)
    self.on_move = on_move

    self:set_blocking(blocking)
end

---@param on_move fun(coordinates: Awesome.MouseCoordsWithButtons)
---@param blocking boolean?
---@return Zingle.Awesome.MouseWatcher
function MouseWatcher.create(on_move, blocking)
    return MouseWatcher(on_move, blocking)
end

---@param blocking boolean?
---@return self
function MouseWatcher:set_blocking(blocking)
    self.blocking = blocking or false

    return self
end

function MouseWatcher:start()
    table.insert(MouseWatcher.stack, 1, self)

    self.stack_check()
end

function MouseWatcher:stop()
    for i, item in ipairs(MouseWatcher.stack) do
        if item == self then
            table.remove(MouseWatcher.stack, i)

            break
        end
    end

    self.stack_check()
end

--- Checks the state of the stack, starting timer if need be.
function MouseWatcher.stack_check()
    local self = MouseWatcher
    
    if #self.stack == 0 then
        log.debug("Removing MouseWatcher idle callback")

        self.in_loop = false

        return
    end

    log.debug("Adding MouseWatcher idle callback")

    self.in_loop = true

    GLib.idle_add(GLib.PRIORITY_LOW, function ()
        self.loop_cb()

        ---@diagnostic disable-next-line:invisible
        return self.in_loop
    end)
end

return MouseWatcher
