local test = require("lib.test")
local json = require("lib.json")

local type_checker = require("src.util.get_config.type_checker")

-- https://stackoverflow.com/questions/20325332/how-to-check-if-two-tablesobjects-have-the-same-value-in-lua
local function table_equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or table_equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

-- TODO more rigorous cases - failures, failures, failures

test.suite(
    "type_checker",
    test.assert(true, "checker"),
    test.collection(
        test.assert(true, "primitives"),
        test.collection(
            test.assert(type_checker.check("nil", nil), "nil"),
            test.assert(not type_checker.check("nil", 0), "not nil"),
            test.assert(type_checker.check("number", 0), "number"),
            test.assert(type_checker.check("string", "Hello World!"), "string"),
            test.assert(type_checker.check("boolean", false), "number"),
            test.assert(type_checker.check("table", {}), "simple table"),
            test.assert(type_checker.check("function", function()
            end), "function"),
            test.not_implemented("thread"),
            test.not_implemented("userdata")
        ),

        test.assert(type_checker.check(
            type_checker.generate.table("string", "number"),
            {
                a = 0,
                b = 1,
                c = 2
            }
        ), "complex table"),
        test.collection(
            test.assert(not type_checker.check(
                type_checker.generate.table("string", "number"),
                {
                    [1] = 0
                }
            ), "table key mismatch"),
            test.assert(not type_checker.check(
                type_checker.generate.table("string", "number"),
                {
                    [{ a = "Hello World" }] = 0
                }
            ), "table key mismatch 2"),

            test.assert(not type_checker.check(
                type_checker.generate.table("string", "number"),
                {
                    a = "Hello World"
                }
            ), "table value mismatch"),

            test.assert(not type_checker.check(
                type_checker.generate.table("string", "number"),
                false
            ), "primitive instead of table")
        ),

        test.assert(type_checker.check(
            type_checker.generate.array("string"),
            {
                "a",
                "b",
                "c"
            }
        ), "array (just a table)"),

        test.collection(
            test.assert(type_checker.check(
                type_checker.generate.union({ "string", "number" }),
                "Hello World!"
            ), "union 1"),
            test.assert(type_checker.check(
                type_checker.generate.union({ "string", "number" }),
                1
            ), "union 2")
        ),

        -- TODO class generation
        test.assert(type_checker.check(
            type_checker.generate.class({
                a = "string",
                b = "number"
            }),
            {
                a = "Hello World!",
                b = 1
            }
        ), "class"),

        test.assert(not type_checker.check(
            type_checker.generate.class({
                a = "string",
                b = "number"
            }),
            false
        ), "class"),

        test.assert(type_checker.check(
            type_checker.generate.literal("Hello World!"),
            "Hello World!"
        ), "literal"),

        test.assert(type_checker.check(type_checker.generate.alias("string"), "Hello World!"), "alias"),
        test.assert(type_checker.check(
            type_checker.generate.dict({
                {
                    key = type_checker.generate.literal("a"),
                    value = "string"
                },
                {
                    key = "string",
                    value = "string"
                }
            }),
            {
                a = "Hello",
                b = "World!"
            }
        ), "dict"),

        test.collection(
            test.assert(not type_checker.check(
                type_checker.generate.dict({
                    {
                        key = type_checker.generate.literal("a"),
                        value = "string"
                    },
                    {
                        key = "string",
                        value = "string"
                    }
                }),
                false
            ), "primitive instead of dict"),

            test.assert(not type_checker.check(
                type_checker.generate.dict({
                    {
                        key = type_checker.generate.literal("a"),
                        value = "string"
                    },
                    {
                        key = "string",
                        value = "string"
                    }
                }),
                {
                    b = "Hello"
                }
            ), "dict missing literal"),

            test.assert(not type_checker.check(
                type_checker.generate.dict({
                    {
                        key = type_checker.generate.literal("a"),
                        value = "string"
                    },
                    {
                        key = "string",
                        value = "string"
                    }
                }),
                {
                    a = 0
                }
            ), "dict literal wrong type"),

            test.assert(not type_checker.check(
                type_checker.generate.dict({
                    {
                        key = type_checker.generate.literal("a"),
                        value = "string"
                    },
                    {
                        key = "string",
                        value = "string"
                    }
                }),
                {
                    b = 0
                }
            ), "dict key wrong type")
        )
    ),

    test.assert(true, "parser"),

    test.collection(
        test.test(function()
            local primitives = {
                "nil",
                "number",
                "string",
                "boolean",
                "table",
                "function",
                "thread",
                "userdata"
            }

            for _, primitive in ipairs(primitives) do
                assert(type_checker.parse.type_string(primitive) == primitive)
            end
        end, "primitives"),

        test.assert(table_equals(
            type_checker.parse.type_string("string|number"),
            type_checker.generate.union({ "string", "number" })
        ), "union"),


        test.assert(table_equals(
            type_checker.parse.type_string("string[]"),
            type_checker.generate.array("string")
        ), "array"),

        test.assert(table_equals(
            type_checker.parse.type_string("table<string, number>"),
            type_checker.generate.table("string", "number")
        ), "table"),

        test.assert(table_equals(
            type_checker.parse.type_string("CustomNamedType"),
            type_checker.generate.reference("CustomNamedType")
        ), "reference"),

        test.collection(
            test.assert(table_equals(
                type_checker.parse.type_string("string|CustomNamedType"),
                type_checker.generate.union({ "string", type_checker.generate.reference("CustomNamedType") })
            ), "union with reference"),

            test.assert(table_equals(
                type_checker.parse.type_string("CustomNamedType[]"),
                type_checker.generate.array(type_checker.generate.reference("CustomNamedType"))
            ), "array with reference"),

            test.assert(table_equals(
                type_checker.parse.type_string("table<string, CustomNamedType>"),
                type_checker.generate.table("string", type_checker.generate.reference("CustomNamedType"))
            ), "table with reference")
        ),

        test.assert(table_equals(
            type_checker.parse.type_string("\"Hello World!\""),
            type_checker.generate.literal("Hello World!")
        ), "literal"),

        test.assert(table_equals(
            type_checker.parse.type_string("\"Hello World!\"|number|CustomNamedType|table<string, number[]>"),
            type_checker.generate.union({
                type_checker.generate.literal("Hello World!"),
                "number",
                type_checker.generate.reference("CustomNamedType"),
                type_checker.generate.table(
                    "string",
                    type_checker.generate.array("number")
                )
            })
        ), "evil union"),

        test.assert(table_equals(
            type_checker.parse.type_string("{ a: string, [number]: string }"),
            type_checker.generate.dict({
                {
                    key = type_checker.generate.literal("a"),
                    value = "string",
                },
                {
                    key = "number",
                    value = "string"
                }
            })
        ), "dict"),

        test.assert(table_equals(
            type_checker.parse.type_string("{ a: { [number]: string } }"),
            type_checker.generate.dict({
                {
                    key = type_checker.generate.literal("a"),
                    value = type_checker.generate.dict({
                        {
                            key = "number",
                            value = "string"
                        }
                    }),
                }
            })
        ), "nested dict")
    )
)