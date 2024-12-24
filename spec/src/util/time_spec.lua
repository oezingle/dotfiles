
local time = require("src.util.time")

describe("time", function ()
    it("lets you set seconds", function ()
        local t = time.seconds(1)

        assert.table(t)

        assert.is_not_nil(t.toSeconds)
        assert.is_not_nil(t.toEpoch)
        assert.is_not_nil(t.toMinutes)
        assert.is_not_nil(t.toHours)
        assert.is_not_nil(t.toDays)

        assert.equal(1, t:toSeconds())
    end)

    it("lets you set mutliple", function ()
        local t = time():seconds(1):minutes(1)

        assert.equal(61, t:toSeconds())
    end)
end)