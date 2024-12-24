local Virtualize = require("src.util.Virtualize")

describe("Virtualize", function()
    it("Converts paths", function()
        local virtualized_json = Virtualize()
            :set_input("lib.json.json")
            :get_module()

        local json = require("lib.json.json")
        assert.are_not_equal(json, virtualized_json)

        assert.deep_equals(json, virtualized_json)
    end)
    it("Converts string chunks", function()
        local gloop = Virtualize()
            :set_input([[
                local function gloop ()
                    return { gloop = true }
                end

                return gloop
            ]])
            :get_module()

        assert.is_function(gloop)

        assert.True(gloop().gloop)
    end)
    it("Converts function chunks", function()
        local gloop = Virtualize()
            :set_input(function()
                local function gloop()
                    return { gloop = true }
                end

                return gloop
            end)
            :get_module()

        assert.is_function(gloop)

        assert.True(gloop().gloop)
    end)

    it("Hides unsafe globals", function()
        local bruh = Virtualize()
            :set_input(function()
                return io
            end)
            :get_module()

        assert.is_nil(bruh)
    end)

    -- TODO FIXME it does!
    it("Doesn't have a metatable vulnerability", function()
        local mt = Virtualize()
            :set_input(function()
                return getmetatable(_G)
            end)
            :get_module()

        assert.is_nil(mt)
    end)
    it("Doesn't have a xpcall vulnerability", function()
        local g = Virtualize()
            :set_input(function()
                local ok, ret = xpcall(function()
                    error("Error here!")
                end, function()
                    return _G
                end)

                return ret
            end)
            :get_module()

        assert.is_table(g)

        assert.is_nil(g.debug)
    end)
    it("Doesn't have a package.loaded vulnerability", function()
        local loaded = Virtualize()
            :set_input(function()
                return package.loaded
            end)
            :get_module()

        assert.is_table(loaded)
        assert.equal(0, #loaded)
    end)
    it("Doesn't have a library insertion vulnerability", function()
        assert.has_error(function()
            Virtualize()
                :set_input(function()
                    ---@diagnostic disable-next-line:duplicate-set-field
                    table.concat = function()
                        -- os.execute("echo 'Hello world!'")

                        return nil
                    end
                end)
                :get_module()
        end, "Cannot add new value to library table")

        assert.is_not_nil(table.concat({ "hello", "world" }, " "))
    end)

    -- TODO is this behaviour i want?
    it("Doesn't pass arguments to chunks", function()
        local args = Virtualize()
            :set_input(function(...)
                return table.pack(...)
            end)
            :get_module()

        assert.is_table(args)
        assert.equal(0, #args)
    end)
end)
