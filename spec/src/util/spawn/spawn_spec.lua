require("src.amenities.init")

local spawn = require("src.util.spawn")

describe("spawn", function ()
    it("opens programs", function ()
        spawn("true")
    end)

    it("reads their outputs", function ()
        spawn("echo \"Hello World\"")
            :after(function (res)
                local message = res.stdout

                assert.equal("Hello World\n", message)
            end)
            :catch(function (err)
                error(err)
            end)
    end)
end)