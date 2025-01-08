
---@type Zingle.Awesome.PackageProvider
local PackageProvider = require("src.util.package_manager.PackageProvider")
local Promise        = require("src.polyfill.Promise")

describe("PackageProvider", function ()
    it("cannot be used on this system", function ()
        Promise.resolve(PackageProvider.can_use())
            :after(function (can_use)
                assert.False(can_use)
            end)
            :catch(function (arg)
                error(arg)
            end)
    end)
end)