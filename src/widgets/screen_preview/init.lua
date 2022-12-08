local wibox = require("wibox")
local awful = require("awful")
local shapes = require("src.util.shapes")

local gears = require("gears")
local gtable = gears.table

require("src.widgets.screen_preview.keygrabber")

-- TODO move windows between screens

-- TODO clicking a tag/client doesn't work with multiple displays

local get_wallpaper = require("src.util.get_wallpaper")

-- Broken out to save ~200loc
local update_selected_tag_preview = require("src.widgets.screen_preview.update_selected_tag_preview")
local create_tag_preview_list = require("src.widgets.screen_preview.create_tag_preview_list")
local get_tag_bg = require("src.widgets.screen_preview.get_tag_bg")

local function create_screen_preview(s)
    local width = s.geometry.width
    local height = s.geometry.height

    --[[
    local wh_ratio = width / height

    -- TODO this value doesn't respond to changes in tag counts!
    local tag_count = #s.tags
    ]]

    -- TODO make this value interact with tag_count so that the preview is always the right size
    -- Area of the lower current tag preview
    local preview_width = width * (5 / 6)
    local preview_height = height * (5 / 6)

    s.screen_preview = wibox {
        screen = s,
        type = 'splash',
        visible = false,
        ontop = true,
        bg = "#f00",
        fg = "#fff",
        height = height,
        width = width,
        x = s.geometry.x,
        y = s.geometry.y,

        widget = wibox.widget {
            layout = wibox.layout.stack,
            forced_width = width,
            forced_height = height,
            {
                {
                    widget = wibox.widget.imagebox,
                    image = get_wallpaper(width, height, true),

                    id = "blurred-bg"
                },
                layout = wibox.container.place,
                forced_width = width,
                forced_height = height,
            },
            {
                layout = wibox.container.background,
                bg = "#00000044",
                {
                    {
                        {
                            {
                                layout = wibox.layout.fixed.horizontal,
                                id = "tag-preview-list",
                                spacing = 15,
                            },
                            layout = wibox.container.place,
                        },
                        {
                            {
                                {
                                    widget = wibox.widget.imagebox,
                                    image = get_wallpaper(preview_width, preview_height),

                                    id = "preview-bg",

                                    clip_shape = shapes.rounded_rect()
                                },
                                {
                                    layout = wibox.layout.manual,

                                    forced_width = preview_width,
                                    forced_height = preview_height,

                                    id = "tag-clients-preview"
                                },

                                forced_width = preview_width,
                                forced_height = preview_height,

                                layout = wibox.layout.stack,
                            },

                            layout = wibox.container.place,
                        },
                        layout = wibox.layout.fixed.vertical,
                        spacing = 15,
                    },
                    layout = wibox.container.place
                }
            },
            {
                layout = wibox.layout.manual,
                id = "window-drag-area"
            }
        }
    }

    -- Saved table of selected tags
    s.screen_preview.old_tags = {}

    local tag_border_indicators = {}

    tag.connect_signal("property::selected", function()
        -- do nothing if the screen preview isn't visible
        if not s.screen_preview.visible then
            return
        end

        for _, t in ipairs(s.tags) do
            local border_indicator = tag_border_indicators[t.name]

            border_indicator.shape_border_color = get_tag_bg(t)
        end

        -- delay call to have s.selected_tag ready
        -- gears.timer.delayed_call doesn't work, so I'm assming the main loop will run >0.1s
        -- if the main loop runs slow, it will look bad but not break anything
        gears.timer {
            timeout = 0.1,
            single_shot = true,
            autostart = true,
            callback = function()
                update_selected_tag_preview(s, preview_width, preview_height)
            end
        }
    end)

    -- TODO kinda feels wasteful
    -- easy way to pre-empt the wallpapers being generated
    create_tag_preview_list(s, width, height)

    awesome.connect_signal("screen_preview::refresh_tag_previews", function()
        tag_border_indicators = create_tag_preview_list(s, width, height)
    end)

    awesome.connect_signal("screen_preview::show", function(wanted_screen)
        if not wanted_screen then
            wanted_screen = s
        end

        if s ~= wanted_screen then 
            return 
        end

        s.screen_preview.old_tags = gtable.clone(s.selected_tags, false)

        update_selected_tag_preview(s, preview_width, preview_height)

        awesome.emit_signal("screen_preview::refresh_tag_previews")

        s.screen_preview.visible = true
    end)

    awesome.connect_signal("screen_preview::hide", function(wanted_screen)
        if not wanted_screen then
            wanted_screen = s
        end

        if s ~= wanted_screen then 
            return 
        end

        -- Check if the old_tags table has contents
        if next(s.screen_preview.old_tags) ~= nil then
            -- restore previously viewed tag(s)
            awful.tag.viewmore(s.screen_preview.old_tags)

            s.screen_preview.old_tags = {}
        end

        s.screen_preview.visible = false
    end)

    awesome.connect_signal("screen_preview::toggle", function(wanted_screen)
        if not wanted_screen then
            wanted_screen = s
        end

        if s ~= wanted_screen then 
            return 
        end

        if s.screen_preview.visible then
            awesome.emit_signal("screen_preview::hide", s)
        else
            awesome.emit_signal("screen_preview::show", s)
        end
    end)

    -- support wallpaper changes
    awesome.connect_signal("wallpaper_should_change", function ()
        local first_child = function (id)
            return s.screen_preview:get_children_by_id(id)[1]
        end

        first_child("blurred-bg").image = get_wallpaper(width, height, true)

        first_child("preview-bg").image = get_wallpaper(preview_width, preview_height)
    end)
end

awful.screen.connect_for_each_screen(function(s)
    create_screen_preview(s)
end)
