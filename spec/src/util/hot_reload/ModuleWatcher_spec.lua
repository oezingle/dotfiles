local ModuleWatcher = require("src.util.hot_reload.ModuleWatcher")

describe("ModuleWatcher", function()
    describe("mock_module", function()
        do
            local mod = {
                bruh = true
            }
            local mock = ModuleWatcher.mock_module({ __module = mod })

            it("Mocks table __index", function()
                assert.True(mock.bruh)
            end)
            it("Mocks table __newindex", function()
                mock.sup = true

                assert.equal(mod.sup, mock.sup)
            end)

            it("Mocks table __tostring", function()
                assert.equal(tostring(mod), tostring(mock))
            end)

            it("Mocks table __pairs", function()
                local keys = {}
                for k in pairs(mock) do
                    table.insert(keys, k)
                end

                table.sort(keys, function(a, b)
                    local cmp = a:byte() - b:byte()

                    return cmp > 0
                end)

                assert.equal("sup bruh", table.concat(keys, " "))
            end)

            it("Mocks table __ipairs", function()
                local words = { "Hello", "World", "!" }
                local mock_words = ModuleWatcher.mock_module({ __module = words })

                local res = {}
                for i, v in ipairs(mock_words) do
                    res[i] = v
                end

                assert.equal("Hello World !", table.concat(res, " "))
            end)
        end

        -- TODO __len
        -- TODO __gc

        it("mocks functions", function()
            local function add(a, b)
                return a + b
            end

            local mock_add = ModuleWatcher.mock_module({ __module = add })

            assert.equal(3, mock_add(1, 2))
        end)
    end)
end)
