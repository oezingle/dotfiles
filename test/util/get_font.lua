
local test = require("lib.test")

local get_font = require("src.util.get_font")

test.suite("get_font", 
    test.test(function ()
        get_font(14)
    end, "Get font"),
    test.test(function ()
        assert(get_font(12) ~= get_font(14))
    end, "Size differs")
)