local test = require("lib.test")

local LinkedList = require("src.util.LinkedList")

test.suite("LinkedList",
    test.test(function()
        local list = LinkedList()
            :push("!")
            :push("World")
            :push("Hello")

        local list_t = list:to_table()

        local list_s = table.concat(list_t, " ")

        assert(list_s == "Hello World !")
    end, "stack push"),
    test.test(function()
        local list = LinkedList()
            :push("!")
            :push("World")
            :push("Hello")

        local s = ""

        while not list:is_empty() do
            s = s .. list:pop() .. " "
        end

        assert(s == "Hello World ! ")
    end, "stack pop"),
    test.test(function()
        local list = LinkedList()
            :push({
                key = "value"
            })

        local value = list:first({
            key = "value"
        })

        assert(value)
    end, "first with filter"),
    test.test(function()
        local list = LinkedList()
            :push({
                key = "value"
            })
            :push({
                key = "value",
                othervalue = true
            })

        local elements = list:filter({ key = "value" })

        assert(#elements == 2)
    end, "filter"),
    test.test(function ()
        local entry = { "this shouldn't print" }

        local list = LinkedList()
            :push({ 0 })
            :push(entry)
            :push({ 0 })
            :filter_remove(function (value)                  
                return value == entry
            end)
            :to_table()

        for _, v in ipairs(list) do            
            assert(type(v) == "table")

            assert(type(v[1]) == "number")
        end
    end, "filter_remove")
)

-- TODO test LinkedList:append()