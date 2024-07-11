
local spawn_vanilla_sync = require("src.util.spawn.vanilla_sync")

describe("spawn_vanilla_sync", function ()
    it("returns program output with a newline", function ()
        local ret = spawn_vanilla_sync("uname")

        assert.equal("Linux\n", ret)
    end)
end)