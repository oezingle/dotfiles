
-- TODO test.require(name, { }, callback) that functions similarly
local check_dependencies = require("src.sh.check_dependencies")

check_dependencies({ "wal" })
    :after(function(met)
        if not met then
            error("pywal not installed - cannot test")
        end

        local test = require("lib.test")
    
        local wal = require("src.util.wal")
    
        local scheme = wal()
    
        assert(scheme)
    
        test.suite(
            "pywal",
            test.assert(scheme.wallpaper, "scheme.wallpaper"),
            test.assert(scheme.alpha, "scheme.alpha"),
    
            test.assert(scheme.special, "scheme.special"),
    
            test.collection(
                test.assert(scheme.special.background, "scheme.special.background"),
                test.assert(scheme.special.foreground, "scheme.special.foreground"),
                test.assert(scheme.special.cursor, "scheme.special.cursor")
            ),
    
            test.assert(scheme.colors, "scheme.colors"),
    
            test.collection(
                test.test(function()
                    for i = 0, 15 do
                        assert(scheme.colors["color" .. tostring(i)])
                    end
                end, "scheme.colors.color[0-15]")
            )
        )
    end)