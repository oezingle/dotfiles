
local Promise = require("src.polyfill.Promise")

---@alias PromiseIter.Control { break: fun(), return: fun(value: any) }

---@generic T
---@param callback fun(control: PromiseIter.Control, ...: T): Promise
local function promise_iter(callback, ...)
    local iter = table.pack(...)

    local tail = Promise.resolve()

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

    return tail:after(function ()
        return state.ret
    end)
end

return promise_iter
