
local Promise = require("src.polyfill.Promise")

---@alias PromiseIter.Control { break: fun(), return: fun(value: any) }

---@generic T
---@param callback fun(control: PromiseIter.Control, ...: T): Promise
local function promise_iter(callback, ...)
    local iter = table.pack(...)

    local promise = Promise.resolve()

    local tail = promise

    local state = {
        should_break = false,
        ret = nil,
    }
    ---@type PromiseIter.Control
    local control = {
        ['break'] = function()
            state.should_break = true
        end,
        ['return'] = function(value)
            state.should_break = true
            state.ret = value
        end
    }

    --- Unroll promises syncronously
    for a, b, c, d, e, f, g, h in table.unpack(iter) do
        tail = tail:after(function()
            --- Only call callbacks given a lack of break
            if not state.should_break then
                return Promise.resolve(callback(control, a, b, c, d, e, f, g, h))
            end
        end)
    end

    tail:after(function ()
        return state.ret
    end)

    return promise
end

return promise_iter

--[[

---@generic T
---@param cb PromiseIter.Callback<T>
---@param iter PromiseIter.StatefulIterator<T>
local function promise_iter_stateful (cb, iter)
    local element = iter()

    return cb(element)
        :after(function (no_continue)
            if no_continue then
                return
            end

            return promise_iter_stateful(cb, iter)
        end)
end

---@generic T
---@param cb PromiseIter.Callback<T>
---@param iter PromiseIter.StatelessIterator<T>
---@param a table
---@param i number
local function promise_iter_stateless (cb, iter, a, i)
    local element, new_i = iter(a, i)

    return cb(element)
        :after(function (no_continue)
            if no_continue then
                return
            end

            return promise_iter_stateless(cb, iter, a, new_i)
        end)
end

---@overload fun(cb: PromiseIter.Callback<any>, iter: PromiseIter.StatelessIterator<any>)
---@overload fun(cb: PromiseIter.Callback<any>, iter: PromiseIter.StatelessIterator<any>, a: table, i: number)
local function promise_iter (...)
    local argv = #table.pack(...)

    if argv == 2 then
        return promise_iter_stateful(...)
    elseif argv == 4 then
        return promise_iter_stateless(...)
    else
        error(string.format("promise_iter expects 2 or 4 arguments, not %d!", argv))
    end
end

return promise_iter
]]
