local testable = require("util.testable")
local Class = require("util.Class")
local pack = require("agnostic.version.pack")
local unpack = require("agnostic.version.unpack")

-- I decided against using is_instance because I want Promise.lua to be 'portable' for da github

---@alias PromiseCallback fun(resolve: function, reject: function?)

---@class Promise Similar to JavaScript promises
---@field _private { callback: PromiseCallback, value: any, was_resolved: boolean }
---@field fulfilled boolean
---@field triggered boolean
---@field next Promise|nil
---@field prev Promise|nil
---@field new fun(self: Promise)
local Promise = {}

-- Promise is now a class
Class(Promise)

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
function Promise:new(callback)
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
    if #value == 1 and type(value) == "table" then
        local mt = getmetatable(value[1])

        if mt and mt.__index == Promise then
            local child = value[1]

            if child.fulfilled then
                -- set value now
                value = child._private.value
            else
                -- throw in the child promise
                self.next = child
            end
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

return testable(Promise, {
    testable.test(function()
        Promise(function(res)
            res("Hello?")
        end)
            :after(function(input)
                return input:gsub("?", "!")
            end)
            :after(function(input)
                assert(input)
            end)
    end, "Promise()"),

    testable.test(function()
        Promise.resolve()
            :after(function()
                return "Promise test 2"
            end)
            :after(function(input)
                assert(input)
            end)
    end, "Promise.resolve()"),
    testable.test(function()
        Promise.resolve("Hello")
            :after(function(input)
                assert(input)
            end)
    end, "Promise.resolve(<value>)"),

    testable.test(function()
        Promise.reject("Testing!")
            :after(function()
                print("I shouldn't fire!")

                assert(false)
            end)
            :catch(function(value)
                assert(value == "Testing!")
            end)

            -- TODO fix this behavior
            --[[
            :catch(function()
                print("I shouldn't fire!")

                -- assert(false)
            end)
            ]]
    end, "Promise.reject()"),

    testable.test(function()
        Promise.resolve()
            :after(function()
                error("Hello catch()")
            end)
            :after(function()
                -- Promise:chain has no-op functions by default, so :after silently includes a :catch handler
                print("I'm a rejection condiut test!")
            end)
            :catch(function(message)
                assert(message)
            end)
    end, "Promise:after() throws an error"),

    testable.test(function()
        Promise.resolve()
            :after(function()
                return Promise.resolve("Hola")
            end)
            :after(function(input)
                assert(type(input) == "string")
            end)
    end, "Promise nesting"),

    testable.test(function()
        Promise.all({
            Promise.resolve("Hello!"),
            Promise.resolve("Hola!"),
        })
            :after(function(values)
                assert(values[1][1] == "Hello!")
                assert(values[2][1] == "Hola!")
            end)
    end, "Promise.all()"),

    testable.awesome_only_test(function()
        Promise(function(res)
            require("awful.spawn").easy_async("which awesome", res)
        end)
            :after(function(awesome_path)
                assert(awesome_path and type(awesome_path) == "string")
            end)
    end, "Async Promise"),

    testable.awesome_only_test(function()
        Promise(function(_, rej)
            require("awful.spawn").easy_async("which awesome", rej)
        end)
            :catch(function(awesome_path)
                assert(awesome_path)
            end)
    end, "Async Promise Rejection"),

    testable.awesome_only_test(function()
        Promise.resolve()
            :after(function()
                return Promise(function(res)
                    require("awful.spawn").easy_async("which awesome", res)
                end)
            end)
            -- Check that nested :after works
            :after(function(...)
                return ...
            end)
            :after(function(awesome_path)
                assert(awesome_path and type(awesome_path) == "string")
            end)
    end, "Async Promise Nesting"),

    testable.awesome_only_test(function()
        Promise.all({
            Promise(function(res)
                require("awful.spawn").easy_async("which awesome", res)
            end),
            Promise(function(res)
                require("awful.spawn").easy_async("which awesome-client", res)
            end),
        })
            :after(function(values)
                assert(values[1][1] == "Hello!")
                assert(values[2][1] == "Hola!")
            end)
    end, "Async Promise.all()"),
})
