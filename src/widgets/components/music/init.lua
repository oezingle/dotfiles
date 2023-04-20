local awful = require("awful")
local wibox = require("wibox")
local shapes = require("src.util.shapes")
local gears = require("gears")
local config = require("config")
local no_scroll = require("src.widgets.helper.function.no_scroll")
local spawn = require("src.agnostic.spawn")
local json = require("lib.json")
local get_current_player = require("src.widgets.components.music.get_current_player")

local get_icon = require("src.util.fs.get_icon")

local get_font = require("src.util.get_font")

local update_album_art = require("src.widgets.components.music.update_album_art")

---@alias PlayerctlStatus "Playing"|"Paused"

---@class PlayerctlMetadataQueryResult
---@field title string
---@field artist string
---@field time string
---@field length string
---@field time_frac number 0.0-1.0
---@field art_url string
---@field status PlayerctlStatus

--- Set the correct playback visual
---@param status PlayerctlStatus
---@param widget table
local function set_correct_playback_button_state(status, widget)
    if status == "Playing" then
        widget.image = get_icon("music/pause.svg")
    else
        widget.image = get_icon("music/play.svg")
    end
end

local query_string = " metadata --format '{\"title\":\"{{xesam:title}}\", \"artist\":\"{{xesam:artist}}\", \"time\":\"{{duration(position)}}\", \"length\":\"{{duration(default(mpris:length,1))}}\", \"time_frac\":{{1.0*position/default(mpris:length,1)}}, \"status\":\"{{status}}\", \"art_url\":\"{{mpris:artUrl}}\"}'"

local function set_media_info(media_info_widgets)
    get_current_player(function(player)
        if not player then
            media_info_widgets.title.text = "Not Playing"

            media_info_widgets.artist.text = " "

            media_info_widgets.time.text = "-:--"

            media_info_widgets.length.text = "0:00"

            media_info_widgets.time_frac.value = 0

            update_album_art(media_info_widgets.art, {})
            
            set_correct_playback_button_state("Paused", media_info_widgets.play_pause_button)
        else
            local cmd = "playerctl -p " .. player .. query_string

            spawn(cmd, function(res)
                ---@type PlayerctlMetadataQueryResult
                local metadata = json.decode(res)

                media_info_widgets.title.text = metadata.title

                media_info_widgets.artist.text = metadata.artist

                media_info_widgets.time.text = metadata.time

                media_info_widgets.length.text = metadata.length

                media_info_widgets.time_frac.value = metadata.time_frac

                update_album_art(media_info_widgets.art, metadata)

                set_correct_playback_button_state(metadata.status, media_info_widgets.play_pause_button)
            end)
        end
    end)
end

local function music_widget()
    local widget = wibox.widget {
        {
            {
                {
                    {
                        {
                            widget = wibox.widget.imagebox,
                            image = get_icon("music/musical-notes.svg"),

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
                        image = get_icon("music/play-back.svg"),
                        id = "button-skip-back",

                        forced_width = 32,
                        forced_height = 32,
                    },
                    {
                        widget = wibox.widget.imagebox,
                        image = get_icon("music/play.svg"),
                        id = "button-play-pause",
                        forced_width = 32,
                        forced_height = 32,
                    },
                    {
                        widget = wibox.widget.imagebox,
                        image = get_icon("music/play-forward.svg"),
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

    -- Bind all the shit
    do
        local media_info_widgets = {
            art = widget:get_children_by_id("album-image")[1],

            title = widget:get_children_by_id("song-name")[1],
            artist = widget:get_children_by_id("artist-name")[1],

            time = widget:get_children_by_id("song-current-time")[1],
            time_frac = widget:get_children_by_id("song-progressbar")[1],
            length = widget:get_children_by_id("song-duration")[1],

            play_pause_button = widget:get_children_by_id("button-play-pause")[1]
        }

        local button_skip_back = widget:get_children_by_id("button-skip-back")[1]
        local button_skip_forward = widget:get_children_by_id("button-skip-forward")[1]

        -- name scroll
        do
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
        end

        local timer = gears.timer {
            timeout   = 1,
            call_now  = true,
            autostart = false,
            callback  = function()
                if not widget.visible then
                    return
                end

                -- update_album_art(media_info_widgets.art)

                set_media_info(media_info_widgets)
            end
        }

        -- tell timer to chill
        widget:connect_signal("property::visible", function(w)
            local visible = w.visible

            if visible then
                -- TODO trigger callback on visible change!

                timer:again()
            else
                timer:stop()
            end
        end)

        -- buttons
        do
            button_skip_back:connect_signal("button::press", no_scroll(function()
                awful.spawn("playerctl previous")
            end))

            button_skip_forward:connect_signal("button::press", no_scroll(function()
                awful.spawn("playerctl next")
            end))

            media_info_widgets.play_pause_button:connect_signal("button::press", no_scroll(function()
                get_current_player(function(player)
                    local insert_player = player and " -p " .. player or ""

                    -- pause
                    spawn("playerctl" .. insert_player .. " play-pause", function()
                        -- then update media info
                        set_media_info(media_info_widgets)
                    end)
                end)
            end))
        end
    end

    return widget
end

return music_widget
