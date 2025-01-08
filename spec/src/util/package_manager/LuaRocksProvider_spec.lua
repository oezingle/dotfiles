local LuaRocksProvider = require("src.util.package_manager.LuaRocksProvider")
local which            = require("src.util.spawn.which")

-- log.level = "trace"

if which("luarocks") then
    describe("LuaRocksProvider #fs", function()
        local provider = LuaRocksProvider()

        it("can_use", function()
            provider:can_use():after(function(has)
                assert.True(has)
            end)
        end)

        it("has busted", function()
            provider:has("busted"):after(function(info)
                assert.True(info.has)
                assert.equal("/usr/share/lua/5.4/busted", info.location)
            end)
        end)

        it("does not have fakepackage-that-does-not-exist", function()
            provider:has("fakepackage-that-does-not-exist"):after(function(info)
                assert.False(info.has)
            end)
        end)

        it("can install busted", function()
            local info = { name = "busted" }

            provider:install(info, true)
            ---@diagnostic disable-next-line:redundant-parameter
                :after(function(has, installed)
                    assert.True(has)
                    assert.True(installed)
                end)
        end)

        it("already has busted", function()
            local info = { name = "busted" }

            provider:install(info)
            ---@diagnostic disable-next-line:redundant-parameter
                :after(function(has, installed)
                    assert.True(has)
                    assert.False(installed)
                end)
        end)
    end)
end
