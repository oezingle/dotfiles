local class = require("lib.30log")
local pack = require("src.agnostic.version.pack")
local unpack = require("src.agnostic.version.unpack")

---@alias PromiseCallback fun(resolve: function, reject: function?) | nil

---@alias PromiseChainFunction<T> (fun(arg: T): any)|nil

---@class Promise<T> : LogBaseFunctions, { after: fun(self: Promise, callback: (fun(arg: T): any)|nil): Promise<T|nil>|Promise, catch: fun(self: Promise, callback: (fun(arg: T): any)|nil): Promise<T|nil>|Promise, chain: fun(self: Promise, after: (fun(arg: T): any)|nil, catch: (fun(arg: any): any)|nil): Promise<T|nil>|Promise } Similar to JavaScript promises
---@field _private { callback: PromiseCallback, value: any, was_resolved: boolean }
---@field fulfilled boolean
---@field triggered boolean
---@field next Promise|nil
---@field prev Promise|nil
---@field new fun(self: Promise)
local Promise = class("Promise", {
    __is_a_promise = true
})

--- Generate a promise. does not set metatable or trigger.
---@param callback PromiseCallback
---@return Promise
local function Promise_new_silent(self, callback)
    self._private = self._private or {}

    if callback then
        self._private.callback = callback
    end

    self.next = self.next or nil
    self.prev = self.prev or nil

    self.triggered = false
    self.fulfilled = false

    return self
end

--- Create and trigger a Promise
---@param callback PromiseCallback
---@return Promise
function Promise:init(callback)
    Promise_new_silent(self, callback)

    Promise._trigger(self)

    return self
end

---resolve the promise with some value
---@param self Promise
---@param value any
---@param reject boolean?
local function Promise_settle(self, value, reject)
    local reject = reject or false

    -- Check if the returned value is a Promise,
    -- in which case that Promise is passed down to this scope
    if #value == 1 and type(value) == "table" and type(value[1]) == "table" and value[1].__is_a_promise then
        local child = value[1]

        if child.fulfilled then
            -- set value now
            value = child._private.value
        else
            -- throw in the child promise
            self.next = child
        end
    end

    self._private.value = value

    -- stupid simple solution but it works
    self._private.was_resolved = not reject

    self.fulfilled = true

    if self.next and not self.next.triggered then
        self.next:_trigger()
    end
end

--- Generate a function that resolves the promise, without having to pass self as the first argument
local function Promise_get_resolver(self)
    ---@param ... any[]
    return function(...)
        Promise_settle(self, pack(...))
    end
end

--- Generate a function that rejects the promise, without having to pass self as the first argument
local function Promise_get_rejecter(self)
    ---@param ... any[]
    return function(...)
        Promise_settle(self, pack(...), true)
    end
end

--- append callbacks to the promise chain
---@param after function|nil
---@param catch function|nil
---@return Promise next
function Promise:chain(after, catch)
    after = after or function(...) return ... end
    catch = catch or function(...) return ... end

    if self.next then
        return self.next:chain(after, catch)
    end

    self.next = Promise_new_silent({}, nil)

    setmetatable(self.next, { __index = Promise })

    local next = self.next

    next.prev = self

    -- needs a nil check here lmao
    assert(next)

    next._private.callback = function(resolve, reject)
        -- let next get self's value
        local prev = next.prev

        -- lua language server go brrr
        assert(prev)

        local arguments = prev._private.value

        local was_resolved = prev._private.was_resolved

        if was_resolved then
            -- :after's errors should be handled by :catch

            local after_succeded, after_res = xpcall(function()
                return pack(after(unpack(arguments)))
            end, function(err) return err end)

            if after_succeded then
                resolve(unpack(after_res))
            else
                reject(after_res)
            end
        else
            -- TODO resolve if catch returns a non-error? somehow?
            reject(catch(unpack(arguments)))
        end
    end

    if self.fulfilled then
        next:_trigger()
    end

    return next
end

--- append a resolution callback to the promise chain
---@param callback function|nil
---@return Promise next
function Promise:after(callback)
    return self:chain(callback, nil)
end

--- append a rejection callback to the promise chain
---@param callback function|nil
---@return Promise next
function Promise:catch(callback)
    return self:chain(nil, callback)
end

-- Trigger the callback in the promise
function Promise:_trigger()
    if not self.triggered then
        self._private.callback(Promise_get_resolver(self), Promise_get_rejecter(self))
    end

    self.triggered = true
end

-- TODO Promise:await() - somehow

--- Return a Promise that resolves with the value given by ...
---@return Promise
function Promise.resolve(...)
    local args = pack(...)

    return Promise(function(res)
        res(unpack(args))
    end)
end

--- Return a Promise that rejects with the value given by ...
---@return Promise
function Promise.reject(...)
    local args = pack(...)

    return Promise(function(_, rej)
        rej(unpack(args))
    end)
end

--- Return a promise that waits for all the child promises
--- TODO promise rejections
---@param promises Promise[]
---@return Promise results this promise will return a table of tables of the promises' results
function Promise.all(promises)
    return Promise(function(res)
        local resolves_left = 0

        local values = {}

        for i, promise in ipairs(promises) do
            if promise.fulfilled then
                values[i] = promise._private.value
            else
                resolves_left = resolves_left + 1

                promise:chain(function(...)
                    values[i] = pack(...)

                    resolves_left = resolves_left - 1

                    if resolves_left == 0 then
                        res(values)
                    end
                end)
            end
        end

        if resolves_left == 0 then
            res(values)
        end
    end)
end

return Promise
