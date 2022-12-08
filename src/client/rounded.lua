-- https://www.reddit.com/r/awesomewm/comments/61s020/round_corners_for_every_client/

local gears = require("gears")

local shapes = require("src.util.shapes")

client.connect_signal("manage", function (c)
    c.shape = shapes.rounded_rect()
end)

client.connect_signal("property::size", function (c)
    if c.fullscreen then
        c.shape = gears.shape.rectangle
    else
        c.shape = shapes.rounded_rect()
    end
end)