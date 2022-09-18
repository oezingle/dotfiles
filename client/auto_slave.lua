local awful = require("awful")

client.connect_signal("manage", function (c)
    if not awesome.startup then awful.client.setslave(c) end
end)