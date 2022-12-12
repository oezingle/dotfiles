local test = require("lib.test")

local time = require("src.util.time")

test.suite("time",
    test.assert(
        time.current().hour == os.date("*t").hour,
        "Current Hour"
    ),
    test.assert(
        time.from_string("18:30").min == 30,
        "Time Parsing"
    ),
    test.assert(
        time.to_seconds(time.from_string("1:30")) == 90 * 60,
        "To Seconds"
    )
)
