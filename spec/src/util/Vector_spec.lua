
local Vector = require("src.util.Vector")

describe("Vector", function ()
    it("can access x, y, z as named keys", function ()
        local v = Vector({ 1, 0, -1 })

        assert.equal(1, v[1])
        assert.equal(0, v[2])
        assert.equal(-1, v[3])

        assert.equal(1, v.x)
        assert.equal(0, v.y)
        assert.equal(-1, v.z)
    end)

    it("can set x, y, z as named keys", function ()
        local v = Vector({ 0, 0, 0 })

        v.x = 1
        assert.equal(1, v[1])
        assert.equal(1, v.x)

        v.y = 2
        assert.equal(2, v[2])
        assert.equal(2, v.y)

        v.z = 3
        assert.equal(3, v[3])
        assert.equal(3, v.z)
    end)

    it("adds vectors", function ()
        local v1 = Vector({ 1, 0, -1 })
        local v2 = Vector({ 0, 1, 2 })

        local v = v1 + v2
        assert.equal(v.x, 1)
        assert.equal(v.y, 1)
        assert.equal(v.z, 1)
    end)

    it("adds nil vector", function ()
        local v1 = Vector({ 1, 1, 1 })
        local v2 = Vector({ })

        local v = v1 + v2
        assert.equal(v.x, 1)
        assert.equal(v.y, 1)
        assert.equal(v.z, 1)
    end)

    it("subtracts vectors", function ()
        local v1 = Vector({ 1, 0, 1 })
        local v2 = Vector({ 0, -2, -2 })

        local v = v1 - v2
        assert.equal(v.x, 1)
        assert.equal(v.y, 2)
        assert.equal(v.z, 3)
    end)

    it("subtracts nil vector", function ()
        local v1 = Vector({ 1, 1, 1 })
        local v2 = Vector({ })

        local v = v1 - v2
        assert.equal(v.x, 1)
        assert.equal(v.y, 1)
        assert.equal(v.z, 1)
    end)

    it("has accurate magnitude", function ()
        local v = Vector({ 1, 3})

        assert.equal(math.sqrt(10), v:magnitude())
    end)
end)