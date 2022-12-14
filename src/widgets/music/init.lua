local awful = require("awful")
local wibox = require("wibox")
local shapes = require("src.util.shapes")
local gears = require("gears")
local config = require("config")
local no_scroll = require("src.widgets.helper.no_scroll")

local gfs = gears.filesystem
local config_dir = gfs.get_configuration_dir()

local get_font = require("src.util.get_font")

local update_album_art = require("src.widgets.music.update_album_art")
local cmd_widget_generator = require("src.widgets.helper.cmd_widget_generator")

--[[
    TODO rounding the album art seems impossible unless I:
     - steal code from https://github.com/awesomeWM/oocairo/blob/master/examples/loading-images.lua
     - use that code to load an image, but save its pixel width and height
     - push those values into a generator function for a clip_shape function
     - use that shape function to round the corners 
        - might also have to account for the difference in radius between high-res image and low-res container
]]

-- TODO make cleaner system for updates
--  - rework widgets

local set_song_name = cmd_widget_generator("playerctl metadata --format '{{ xesam:title }} '", "Not Playing")

local set_artist = cmd_widget_generator("playerctl metadata --format '{{ xesam:artist }}'", " ")

local set_played_time = cmd_widget_generator("playerctl position --format '{{ duration(position) }}'", "-:--")

local set_song_duration = cmd_widget_generator("playerctl metadata --format '{{ duration(mpris:length) }}'", "0:00")

local function set_played_time_bar(progressbar)
    awful.spawn.easy_async(
        'playerctl metadata --format "{{ 1.0 * position / mpris:length }}"',
        function(response)
            local decimal = tonumber(response)

            if decimal then
                progressbar.value = decimal
            else
                progressbar.value = 0
            end
        end
    )
end

local function set_correct_playback_button_state(widget)
    awful.spawn.easy_async(
        "playerctl status",
        function(response)
            local playing = response == "Playing\n"

            if playing then
                widget.image = config_dir .. "icon/music/pause.svg"
            else
                widget.image = config_dir .. "icon/music/play.svg"
            end
        end
    )
end

local function music_widget()
    local widget = wibox.widget {
        {
            {
                {
                    {
                        {
                            widget = wibox.widget.imagebox,
                            image = config_dir .. "icon/music/musical-notes.svg",

                            resize = true,

                            id = "album-image",
                        },
                        forced_width = 256,
                        forced_height = 256,
                        widget = wibox.container.place,
                    },
                    -- allows forced_width / forced_height to work
                    widget = wibox.container.background,
                },
                {
                    forced_width = 256,

                    layout = wibox.container.scroll.horizontal,
                    speed = 25,
                    id = "name-scroll",
                    {
                        widget = wibox.widget.textbox,
                        font = get_font(12),
                        id = "song-name",
                        text = "Song Name"
                    }
                },
                {
                    widget = wibox.widget.textbox,
                    font = get_font(10),
                    id = "artist-name",
                    text = "Artist Name"
                },
                layout = wibox.layout.fixed.vertical,
                spacing = 2
            },
            {
                {
                    -- TODO change to slider to have a playback indicator circle, generate custom color for 'bar'
                    widget = wibox.widget.progressbar,
                    value = 0,
                    max_value = 1,

                    id = "song-progressbar",

                    background_color = config.progressbar.bg,
                    color = config.progressbar.fg,

                    forced_width = 128,
                    forced_height = 4,

                    shape = shapes.rounded_rect(100)
                },
                {
                    {
                        widget = wibox.widget.textbox,
                        text = "0:00",
                        id = "song-current-time"
                    },
                    {
                        widget = wibox.widget.textbox,
                        text = "",
                    },
                    {
                        widget = wibox.widget.textbox,
                        text = "0:00",
                        id = "song-duration"
                    },
                    layout = wibox.layout.align.horizontal,
                    expand = "inside",

                },
                layout = wibox.layout.fixed.vertical,
            },
            {
                {
                    widget = wibox.widget.textbox,
                    text = ""
                },
                {
                    {
                        widget = wibox.widget.imagebox,
                        image = config_dir .. "icon/music/play-back.svg",
                        id = "button-skip-back",

                        forced_width = 32,
                        forced_height = 32,
                    },
                    {
                        widget = wibox.widget.imagebox,
                        image = config_dir .. "icon/music/play.svg",
                        id = "button-play-pause",
                        forced_width = 32,
                        forced_height = 32,
                    },
                    {
                        widget = wibox.widget.imagebox,
                        image = config_dir .. "icon/music/play-forward.svg",
                        id = "button-skip-forward",

                        forced_width = 32,
                        forced_height = 32,
                    },
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 24,
                },
                {
                    widget = wibox.widget.textbox,
                    text = ""
                },
                layout = wibox.layout.align.horizontal,
                expand = "outside"
            },
            layout = wibox.layout.fixed.vertical,
            spacing = 3,
            fill_space = false,

            -- i don't like that i have to determine this number manually
            forced_height = 360
        },
        widget = wibox.container.margin,
        margins = 15,
    }

    local subwidgets = {
        album_image = widget:get_children_by_id("album-image")[1],

        song_name = widget:get_children_by_id("song-name")[1],
        artist_name = widget:get_children_by_id("artist-name")[1],

        song_current_time = widget:get_children_by_id("song-current-time")[1],
        song_progressbar = widget:get_children_by_id("song-progressbar")[1],
        song_duration = widget:get_children_by_id("song-duration")[1],

        button_skip_back = widget:get_children_by_id("button-skip-back")[1],
        button_play_pause = widget:get_children_by_id("button-play-pause")[1],
        button_skip_forward = widget:get_children_by_id("button-skip-forward")[1],
    }

    local name_scroll = widget:get_children_by_id("name-scroll")[1]

    -- pause scrolling the name unless the mouse is hovering
    name_scroll:pause()
    name_scroll:set_fps(30)
    name_scroll:connect_signal("mouse::enter", function()
        name_scroll:continue()
    end)
    name_scroll:connect_signal("mouse::leave", function()
        name_scroll:pause()
        name_scroll:reset_scrolling()
    end)

    local timer = gears.timer {
        timeout   = 1,
        call_now  = true,
        autostart = false,
        callback  = function()
            if not widget.visible then
                return
            end

            update_album_art(subwidgets.album_image)

            set_song_name(subwidgets.song_name)
            set_artist(subwidgets.artist_name)

            set_played_time(subwidgets.song_current_time)
            set_song_duration(subwidgets.song_duration)

            set_played_time_bar(subwidgets.song_progressbar)

            set_correct_playback_button_state(subwidgets.button_play_pause)
        end
    }

    widget:connect_signal("property::visible", function(w)
        local visible = w.visible

        if visible then
            -- TODO trigger callback on visible change!

            timer:again()
        else
            timer:stop()
        end
    end)

    subwidgets.button_skip_back:connect_signal("button::press", no_scroll(function()
        awful.spawn("playerctl previous")
    end))

    subwidgets.button_skip_forward:connect_signal("button::press", no_scroll(function()
        awful.spawn("playerctl next")
    end))

    subwidgets.button_play_pause:connect_signal("button::press", no_scroll(function()
        awful.spawn.easy_async(
            "playerctl play-pause",
            function()
                set_correct_playback_button_state(subwidgets.button_play_pause)
            end
        )
    end))

    return widget
end

return music_widget
