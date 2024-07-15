local LuaHotConfigurationProvider = require("src.configuration.LuaHotConfigurationProvider")
local Promise                     = require("src.polyfill.Promise")
local assert_deep_equals          = require("spec.helper.assert_deep_equals")

describe("LuaHotConfigurationProvider", function()
    it("can be used", function()
        local can_use = Promise.await(LuaHotConfigurationProvider.can_use())

        assert.True(can_use)

        package.loaded["config.awesome"] = nil
    end)

    it("reads mtime as a number", function()
        local provider = LuaHotConfigurationProvider(function() end)

        local mtime = provider:mtime()

        assert.is.number(mtime)
    end)

    do
        local provider = LuaHotConfigurationProvider(function() end)

        it("reads config nicely", function()
            local flatconfig = require("config.awesome")
            local hotconfig = provider:get()

            assert_deep_equals(flatconfig, hotconfig)
        end)
    end
end)
