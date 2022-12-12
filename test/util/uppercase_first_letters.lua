
local uppercase_first_letters = require("src.util.uppercase_first_letters")

local test = require("lib.test")

test.suite(
    "uppercase_first_letters",
    test.assert(
        uppercase_first_letters("hello") == "Hello",
        "One word"
    ),
    test.assert(
        uppercase_first_letters("hello world!") == "Hello World!",
        "Sentence"
    )
)