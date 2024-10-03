local class = require("lib.30log")

---@alias PromiseCallback fun(resolve: function, reject: function?) | nil

---@alias PromiseChainFunction<T> (fun(arg: T): any)|nil

-- { after: fun(self: Promise, callback: (fun(arg: T): any)|nil): Promise<T|any>|Promise }

-- yo what the fuck lua-language-server
---@generic R
---@class Promise<T> : Log.BaseFunctions, { after: fun(self: Promise, callback: (fun(arg: T): `R`|nil)|nil): Promise<R> }, { catch: fun(self: Promise, callback: (fun(arg: T): any)|nil): Promise<T|nil>|Promise }, { chain: fun(self: Promise, after: (fun(arg: T): any)|nil, catch: (fun(arg: any): any)|nil): Promise<T|nil>|Promise }, { await: (fun(self: Promise<T>): T) }, { fulfilled: boolean }, { _private: { callback: PromiseCallback, value: any, was_resolved: boolean } } Similar to JavaScript promises
---@field _private { callback: PromiseCallback, value: any, was_resolved: boolean }
---@field fulfilled boolean
---@field triggered boolean
---@field next Promise|nil
---@field prev Promise|nil
---@field new fun(self: Promise)
---@operator call(fun(res: function, rej: function)):Promise
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

    -- stupid simple solution but it works
    self._private.was_resolved = not reject

    self.fulfilled = true

    -- Check if the returned value is a Promise,
    -- in which case that Promise is passed down to this scope
    if #value == 1 and type(value) == "table" and type(value[1]) == "table" and value[1].__is_a_promise then
        ---@type Promise
        local child = value[1]

        if child.fulfilled then
            -- set value now
            self._private.value = child._private.value
        else
            -- TODO this doesn't work


            --- Attach returned promise's chain into this chain
            if self.next then
                local last = child

                ---@diagnostic disable-next-line:need-check-nil
                while last.next do
                    last = last.next
                end

                last.next = self.next

                ---@diagnostic disable-next-line:need-check-nil
                last.next.prev = last
            end


            -- throw in the child promise
            self.next = child

            return
        end
    else
        self._private.value = value
    end

    if self.next and not self.next.triggered then
        self.next:_trigger()
    end
end

--- Generate a function that resolves the promise, without having to pass self as the first argument
local function Promise_get_resolver(self)
    ---@param ... any[]
    return function(...)
        Promise_settle(self, table.pack(...))
    end
end

--- Generate a function that rejects the promise, without having to pass self as the first argument
local function Promise_get_rejecter(self)
    ---@param ... any[]
    return function(...)
        Promise_settle(self, table.pack(...), true)
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
                return table.pack(after(table.unpack(arguments or {})))
            end, function(err) return err end)

            if after_succeded then
                resolve(table.unpack(after_res))
            else
                reject(after_res)
            end
        else
            -- TODO resolve if catch returns a non-error? somehow?
            reject(catch(table.unpack(arguments)))
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

if lgi then
    local GLib = lgi.GLib

    -- TODO only works if this loop's idle priority is equal to the other's
    -- TODO hangs if higher, instantly returns if lower
    -- TODO make :catch resolve error object
    ---@generic T
    ---@param promise Promise<T>
    ---@return T
    function Promise.await(promise)
        local mainloop = GLib.MainLoop(nil, false)

        local context = mainloop:get_context()

        local ok, err = true, nil

        promise:catch(function(msg)
            ok, err = false, msg
        end)

        -- Push context to default so g_idle_add works on this loop,
        -- not on an AwesomeWM loop
        -- https://stackoverflow.com/questions/19903537/how-to-attach-gsocketservice-to-non-default-main-loop-context
        context:push_thread_default()

        GLib.idle_add(GLib.PRIORITY_DEFAULT, function()
            if promise.fulfilled then
                mainloop:quit()

                return false
            end

            if not ok then
                mainloop:quit()

                return false
            end

            return true
        end)

        context:pop_thread_default()

        mainloop:run()

        if not ok then
            error(err)
        end

        return table.unpack(promise._private.value)
    end
end


--- Return a Promise that resolves with the value given by ...
---@generic T
---@param ... Promise<T> | T
---@return Promise<T>
function Promise.resolve(...)
    local args = table.pack(...)

    return Promise(function(res)
        res(table.unpack(args))
    end)
end

--- Return a Promise that rejects with the value given by ...
---@generic T
---@param ... Promise<T> | T
---@return Promise<T>
function Promise.reject(...)
    local args = table.pack(...)

    return Promise(function(_, rej)
        rej(table.unpack(args))
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
                    values[i] = table.pack(...)

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
