
local test = require("lib.test")

local unpad = require("lib.widgey.unpad")

test.suite("unpad",
    test.assert(unpad("   padded!") == "padded!", "single line"),
    test.assert(unpad([[
        padded!
    ]]) == "padded!", "single line in multiline string"),
    test.assert(unpad([[
        padded!
        padded!
    ]]) == [[padded!
padded!]], "multiline"),
    test.assert(unpad([[
        padded!
            padded!
    ]]) == [[padded!
    padded!]], "multiline with intentional padding"),
    test.assert(unpad([[
        padded!

    ]]) == [[padded!
]], "multiline with intentional return")
)