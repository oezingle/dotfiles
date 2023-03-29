--[[
    MouseHandlers are a class-based interface for mousegrabber
     - the most recently created MouseHandler controls mousegrabber
     - can implement pausing etc

    mouse_handler:forward_events()
     - https://awesomewm.org/doc/api/libraries/root.html#fake_input
    ( requires mouse_handler:_set_coords() )

    mouse_handler:init(callback)
        self.callback = callback

        mouse_handler.handlers.prepend(self)
    end

    mouse_handler:cancel ()

    end

    mouse_handler.handlers = some linked list implementation

    mouse_handler.start_mousegrabber()
        if mousegrabber.running() then
            return
        end

        mousegrabber.run(function (coords)
            local handler = mouse_handler.handlers.first()

            handler:_set_coords(coords)

            -- handler callbacks take self as first argument,
            -- so they can call functions like self:cancel()
            -- or self:pause() (when i get around to those)
            local res = handler.callback(handler, coords)

            -- to allow pausing, use a recursive function to
            -- pull handlers.next() and then check if handler.paused
            -- if it is, pull handler.next() and so on
            -- basically write a linked list with a filter operation

            if not res then
                handler:cancel()
            end

            -- Stop the mousegrabber if there aren't any handlers
            -- for performance reasons
            return mouse_handler.handlers.first() ~= nil
        end)
    end
]]

-- TODO test and shit

local class = require("lib.30log")

local LinkedList = require("src.util.LinkedList")

---@alias MouseHandlerCallback fun(self: MouseHandler, coords: MouseCoordsWithButtons): boolean

---@class MouseHandler : LogBaseFunctions
---@operator call: MouseHandler
---@field protected handlers LinkedList<MouseHandler>
---@field paused boolean
---@field callback MouseHandlerCallback
local MouseHandler = class("MouseHandler", {
    handlers = LinkedList()
})

---@param callback MouseHandlerCallback?
function MouseHandler:init(callback)
    self.paused = false

    if callback then
        self:set_callback(callback)
    end

    self.handlers:push(self)

    self:_start()
end

---@param callback MouseHandlerCallback
---@return self self for convienience
function MouseHandler:set_callback(callback)
    self.callback = callback

    return self
end

---@param coords MouseCoordsWithButtons
function MouseHandler:call(coords)
    return self.callback(self, coords)
end

function MouseHandler:pause()
    self.paused = true
end

function MouseHandler:restart()
    self.paused = false

    self:_start()
end

function MouseHandler:cancel()
    self.handlers:filter_remove(function (value)
        return value == self
    end)
end

function MouseHandler:_start()
    if not mousegrabber.isrunning() then
        mousegrabber.run(function(coords)
            local first = self.handlers:first({
                paused = false
            })

            if not first then
                return false
            end

            local continue = first:call(coords)

            if not continue then
                self.handlers:pop()
            end

            return not self.handlers:is_empty()
        end, "hand1")
    end
end
