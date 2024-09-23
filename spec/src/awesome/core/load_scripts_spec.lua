
local load_scripts = require("src.awesome.core.load_scripts")
local exists       = require("src.util.fs.exists")

describe("load_scripts", function ()
    it("finds a list of files", function ()
        local files = load_scripts.find_files()

        assert.table(files)

        for path in pairs(files) do
            assert.string(path)

            local exist = exists(path)

            assert.True(exist)
        end
    end)
end)