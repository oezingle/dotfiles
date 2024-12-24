local LuaC = require "src.util.soft_load.LuaC"

local clock = os.clock

describe("load()", function ()
    it("is faster in binary mode", function ()
        local chunk = [[
            local function bruh ()
                print("Hello World!")
            end
        ]]

        local chunk_bin = LuaC.from_string(chunk):to_string()

        local t_start = os.clock()

        for i = 1,1000 do
            local c = load(chunk, nil, "t")
        end

        local t_mid = os.clock()

        for j = 1,1000 do
            local c = load(chunk_bin, nil, "b")
        end

        local t_end = os.clock()

        local t_text = t_mid - t_start
        local t_bin = t_end - t_mid

        assert.True(t_text > t_bin)

        print("TEXT", t_text)
        print("BIN", t_bin)
    end)
end)