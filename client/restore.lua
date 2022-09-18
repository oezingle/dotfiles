-- restore the geometry of clients when switching back to floating
-- https://www.reddit.com/r/awesomewm/comments/cn02m6/floating_clients_restore_position_after_layout/

local awful  = require("awful")
local gears  = require("gears")
local config = require("config")

local client_or_tag_floating = require("util.client.client_or_tag_floating")
local should_show_titlebars = require("util.client.should_show_titlebars")

local client_geos = {}

-- TODO still have titlebars on clients that request not to

local function apply_geometry(c)
    if client_or_tag_floating(c) and not c.fullscreen then
        c:geometry(client_geos[c.window])
    end
end

local function save_geometry(c)
    if client_or_tag_floating(c) and not c.fullscreen then
        client_geos[c.window] = c:geometry()
    end
end

tag.connect_signal("property::layout", function(t)
    for _, c in ipairs(t:clients()) do
        if client_or_tag_floating(c) and not c.fullscreen then
            apply_geometry(c)
        end
        if c.has_titlebar then
            c:emit_signal("request::titlebars")
        end
    end
end)

local function apply_geometry_and_set_titlebar(c)
    apply_geometry(c)

    if should_show_titlebars(c) then
        awful.titlebar.show(c, config.decorations.titlebar.pos)
    else
        awful.titlebar.hide(c, config.decorations.titlebar.pos)
    end
end

client.connect_signal("property::floating", apply_geometry_and_set_titlebar)
client.connect_signal("tagged", apply_geometry_and_set_titlebar)

client.connect_signal("property::geometry", save_geometry)
client.connect_signal("manage", save_geometry)
client.connect_signal("unmanage", function(c) client_geos[c.window] = nil end)
