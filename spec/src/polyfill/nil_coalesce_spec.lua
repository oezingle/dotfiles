require("src.amenities.init")

local nil_coalesce = require("src.polyfill.nil_coalesce")

describe("nil_coalesce", function ()
    it("passes the first value if non-nil", function ()
        local value = nil_coalesce(false)

        assert.False(value)
    end)

    it("passes the second value if non-nil", function ()
        local value = nil_coalesce(nil, false)

        assert.False(value)
    end)

    it("passes the third value if non-nil", function ()
        local value = nil_coalesce(nil, nil, false)

        assert.False(value)
    end)

    --- Proof by induction, and so on...
end)