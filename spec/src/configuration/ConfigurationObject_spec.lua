require("src.amenities.init")

local ConfigurationObject = require("src.configuration.ConfigurationObject")
local typed = require("src.typed")

describe("ConfigurationObject", function()
    do
        ---@type Zingle.Awesome.ConfigurationObject
        local object

        it("provides a single section", function()
            object = ConfigurationObject.create({
                key = "bruh",
                display = "The bruh key",
                type = typed.String("i default to bruh")
            })
        end)

        describe("provides a default value", function()
            it("replaces nil", function()
                assert.equal(object:default(), "i default to bruh")
            end)

            it("can be overwritten", function()
                assert.equal(object:default("overload!"), "overload!")
            end)
        end)
    end

    do
        ---@type Zingle.Awesome.ConfigurationObject
        local object

        describe("provies nested configuration", function()
            it("initializes nicely", function()
                object = ConfigurationObject.create({
                    key = "root",
                    display = "Root",
                    type = typed.Table(),
                    children = {
                        ConfigurationObject.create({
                            key = "bruh",
                            display = "The bruh key",
                            type = typed.String("i default to bruh")
                        }),
                        ConfigurationObject.create({
                            key = "glorp",
                            display = "Glorp section",
                            type = typed.String("Glorp time baby")
                        })
                    }
                })
            end)

            describe("with default values", function()
                it("replaces nil", function()
                    assert.equal(object:default().bruh, "i default to bruh")
                end)

                it("can be overriden", function()
                    assert.equal(object:default({ bruh = "Get fucked" }).bruh, "Get fucked")
                end)

                it("maintains non-overriden values", function()
                    assert.equal(object:default({ bruh = "Get fucked" }).glorp, "Glorp time baby")
                end)
            end)
        end)

        --[[
        describe("stringifies nicely", function ()
            print(object)
        end)
        ]]

        -- ( Would be nice to reliably export configs to  )
        --[[
        describe("luaifies nicely", function()
            print(object:tolua())
        end)
        ]]
    end
end)
