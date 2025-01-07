local class = require("lib.30log")

-- TODO improved typing, Promise.await, Promise.race.

---@alias Promise.Callback fun(resolve: function, reject: function?) | nil

---@generic T, Res
---@alias Promise.AfterType fun(self: Promise<`T`>, on_resolve: fun(value: T): `Res`?): Promise<Res>

---@generic T, Res
---@alias Promise.CatchType fun(self:Promise<`T`>, on_reject: fun(value: string): `Res`?): Promise<Res>

---@generic T, Res, Rec
---@alias Promise.ChainType fun(self:Promise<`T`>, on_resolve: (fun(value: T): `Res`?)?, on_reject: (fun(value: string): `Rec`?)?): Promise<Res | Rec>

--- Similar to JavaScript Promises, but `Promise:then()` would be cumbersome due to lua's keyword reservations so we use `Promise:after()`
---@generic NewRes
---@class Promise<Res> : Log.BaseFunctions, { after: fun(self: self, on_resolve: fun(value: Res): NewRes?): Promise<NewRes> }, { catch: fun(self: self, on_reject: fun(value: string): NewRes?): Promise<NewRes> }
---@field protected callback Promise.Callback
---@field protected fulfilled_value any
---@field protected fulfilled_type "reject" | "resolve" | nil
---@field protected has_triggered boolean
---@field protected next self[]
---@field protected prev self?
---
---@field protected trigger fun(self: self): self?
---
---@field after Promise.AfterType 
---@field catch Promise.CatchType
---@field chain Promise.ChainType
---
---@operator call():Promise
local Promise = class("Promise")

Promise.DO_NOTHING = function (...) return ... end

function Promise:init(callback, no_trigger)
    self.callback = callback

    -- self.next is a table:
    --[[
        If you call the then() method twice on the same promise object (instead
        of chaining), then this promise object will have two pairs of
        settlement handlers. All handlers attached to the same promise object
        are always called in the order they were added. Moreover, the two
        promises returned by each call of then() start separate chains and do
        not wait for each other's settlement.

        https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/then
    ]]
    self.next = {}

    if not no_trigger then
        self:trigger()
    end
end

---@param values any[]
---@param settle_type "reject" | "resolve"
function Promise:settle(values, settle_type)
    -- Check if the previous Promise returned another Promise, in which case we
    -- insert into the chain.
    if #values == 1 and type(values[1]) == "table" and values[1].class == Promise then
        ---@type Promise
        local ret_promise = values[1]

        -- If the returned promise is already fulfilled, we 'ignore' it and
        -- forward its value.
        if ret_promise.fulfilled_type then
            self.fulfilled_value = ret_promise.fulfilled_value
            self.fulfilled_type = ret_promise.fulfilled_type
        else
            -- follow promise chain to parent, as it is unchained.
            local first = ret_promise
            ---@diagnostic disable-next-line:need-check-nil
            while first.prev do
                first = first.prev
            end
            first.prev = self

            -- set prev of all next to inserted value
            -- also insert next to ret
            for _, next in pairs(self.next) do
                next.prev = ret_promise

                table.insert(ret_promise.next, next)
            end

            self.next = { first }

            return ret_promise
        end
    else
        self.fulfilled_value = values
        self.fulfilled_type = settle_type
    end

    -- trigger next-es
    for _, next in pairs(self.next) do
        next:trigger()
    end
end

function Promise:trigger()
    --- Is only non-nil if a promise is returned (see Promise:settle)
    local settle_value = nil

    if not self.has_triggered then
        local resolve = function(...)
            settle_value = self:settle(table.pack(...), "resolve")
        end
        local reject = function(...)
            settle_value = self:settle(table.pack(...), "reject")
        end

        self.callback(resolve, reject)
    end

    self.has_triggered = true

    return settle_value
end

function Promise:chain(after, catch)
    -- callback is nil because we need to reference prev
    local next = Promise(nil, true)
    next.prev = self

    next.callback = function(resolve, reject)
        -- prev here is this promise, as we are constructing next.
        ---@diagnostic disable-next-line:invisible
        local prev = assert(next.prev)

        -- get previously fulfilled value and what type that fulfillment is
        ---@diagnostic disable-next-line:invisible
        local args = prev.fulfilled_value
        ---@diagnostic disable-next-line:invisible
        local ftype = assert(prev.fulfilled_type, "Triggered promise " .. tostring(next) .. " has unfulfilled parent " .. tostring(prev))

        -- alternate depending on what situation we have to handle
        local handler 
        if ftype == "resolve" then
            handler = after
        else
            handler = catch
        end 
        if not handler then
            handler = Promise.DO_NOTHING

            ---@diagnostic disable-next-line:invisible
            if ftype == "reject" and #next.next == 0 then
                error(string.format("Unhandled error in Promise: %s", table.unpack(args or {})))    
            end
        end

        local ok, res = xpcall(function()
            return table.pack(handler(table.unpack(args or {})))
        end, function(err)
            -- TODO safety check
            return debug.traceback(err)
        end)

        if ok then
            resolve(table.unpack(res))
        else
            reject(res)
        end
    end

    table.insert(self.next, next)
    if self.fulfilled_type then
        -- This behaviour is a hacky bugfix. next:trigger -> next.callback will
        -- call res/rej instantly if chained. this means we can return the
        -- Promise that res/rej was supplied. Feels wrong but seems to work right.
        local subpromise = next:trigger()

        if subpromise then
            return subpromise
        end
    end

    return next
end

--- append a resolution callback to the promise chain
function Promise:after(callback)
    return self:chain(callback, nil)
end

--- append a rejection callback to the promise chain
function Promise:catch(callback)
    return self:chain(nil, callback)
end

--- Return a Promise that resolves with the value given by ...
---@generic T
---@param ... Promise<T> | `T`
---@return Promise<T>
function Promise.resolve(...)
    local args = table.pack(...)

    return Promise(function(res)
        res(table.unpack(args))
    end)
end

--- Return a Promise that rejects with the value given by ...
---@generic T
---@param ... Promise<`T`> | `T`
---@return Promise<T>
function Promise.reject(...)
    local args = table.pack(...)

    return Promise(function(_, rej)
        rej(table.unpack(args))
    end)
end

---@param promises Promise[]
function Promise.all(promises)
    return Promise(function(res, rej)
        local resolves_left = 0
        local values = {}

        for i, promise in pairs(promises) do
            resolves_left = resolves_left + 1

            promise:chain(function(...)
                values[i] = table.pack(...)

                resolves_left = resolves_left - 1

                -- We can ignore the rejection case here, because resolves_left
                -- will never equal 0 given a single rejection
                if resolves_left == 0 then
                    res(values)
                end
            end, function(err)
                rej(err)
            end)
        end

        -- resolve if no work was done.
        if resolves_left == 0 then
            res(values)
        end
    end)
end

return Promise
