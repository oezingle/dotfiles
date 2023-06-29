
local test = require("lib.test")

local serialize_prop = require("lib.widgey.Component.serialize_prop")

test.suite("serialize_prop", 
    test.assert(serialize_prop(nil) == "nil", "nil"),
    test.assert(serialize_prop(1.5) == "1.5", "number"),
    test.assert(serialize_prop("Hello World!") == "Hello World!", "string"),
    test.assert(serialize_prop(false) == "false", "boolean"),
    test.test(function ()
        local serial = serialize_prop({ a = function () return 4 end, 1, [true] = 3, 2 })

        local tbl = load("return " .. serial)()

        assert(tbl[1] == 1)
        assert(tbl[2] == 2)
        assert(tbl[true] == 3)
        assert(tbl.a() == 4)
    end, "table"),
    test.test(function ()
        local function fn ()
            return "Hello World!"
        end

        assert(load("return " .. serialize_prop(fn))()() == "Hello World!")
    end, "function")
)

