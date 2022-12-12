local test = require("lib.test")

test.require_awesome("lighten_color", function(name)
    local lighten_color = require("src.util.color.lighten")

    test.suite(name,
        test.assert(
            lighten_color("#000000", 0.1) == "#191919ff",
            "Lighten Slightly"
        ),
        test.assert(
            lighten_color("#000000") == "#191919ff",
            "Lighten Automatically"
        ),
        test.assert(
            lighten_color("#000000", 1.0) == "#ffffffff",
            "Lighten Entirely"
        )
    )
end)
