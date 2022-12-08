local wibox = require("wibox")
local gears = require("gears")
local no_scroll = require("src.widgets.helper.no_scroll")
local gtimer = gears.timer

local config = require("config")
local shapes = require("src.util.shapes")
local get_font = require("src.util.get_font")

local client_true_geometry = require("src.util.client.true_geometry")

-- TODO awful.mouse.wibox.move instead of mousegrabber?

local clienticon_or_xorg = require("src.widgets.components.clienticon_or_xorg")
local client_preview = require("src.widgets.components.client_preview")
local nolayout = require("src.widgets.screen_preview.nolayout")

-- TODO don't show tag layout change modal

-- TODO better client preview positioning - make clients close to their actual position

-- TODO sort out minimized windows rendering weird when hovered
-- the clients' content cairo surfaces are invalidated by the minimize function
-- saving to file would be slow, having a close() callback would look weird as windows would be closing as the preview closes
-- maybe switch the widget's content on mouse::enter?

-- Recreate the large preview of the currently selected tag for this screen
local function update_selected_tag_preview(s, preview_width, preview_height)
    local client_preview_area = s.screen_preview:get_children_by_id("tag-clients-preview")[1]

    client_preview_area:reset()

    local t = s.selected_tag

    local clients = t:clients()

    local angle_step = math.rad(360 / #clients)

    local angle_offset = math.rad(math.random(-90, 90))

    local scale = #clients * 0.75

    -- Width and Height of the individual client's preview size
    local client_preview_height = preview_height / scale

    local min_yoffset = 0
    local max_yoffset = preview_height - client_preview_height - 24 - 5

    local sin = math.sin
    local cos = math.cos

    local old_layout

    if t.layout ~= nolayout then
        old_layout = t.layout
    end

    t.layout = nolayout

    local clients_minimized = {}

    for _, c in ipairs(clients) do
        -- save minimized state
        clients_minimized[c.window] = c.minimized

        -- make visible
        if c.minimized then
            c.minimized = false
        end
    end

    local function render_client_preview(index, c)
        local geo = client_true_geometry(c)

        local client_ratio = geo.width / geo.height

        local client_preview_width = client_preview_height * client_ratio

        local xoffset, yoffset = 0, 0

        if #clients == 1 then
            client_preview_height = preview_height * 7 / 8

            -- recalculate
            client_preview_width = client_preview_height * client_ratio

            xoffset = preview_width / 2 - client_preview_width / 2
            yoffset = preview_height / 2 - client_preview_height / 2
        else
            -- middle of the large preview window + trigonometry - center based on size of widget
            xoffset = (preview_width / 2) + (cos(angle_step * index + angle_offset) * client_preview_width) -
                (client_preview_width / 2)
            yoffset = (preview_height / 2) + (sin(angle_step * index + angle_offset) * client_preview_height) -
                (client_preview_height / 2)

            local min_xoffset = 0
            local max_xoffset = preview_width - client_preview_width

            if xoffset < min_xoffset then
                xoffset = min_xoffset
            elseif xoffset > max_xoffset then
                xoffset = max_xoffset
            end

            if yoffset < min_yoffset then
                yoffset = min_yoffset
            elseif yoffset > max_yoffset then
                yoffset = max_yoffset
            end
        end

        local preview = wibox.widget {
            {
                client_preview(c),

                layout = wibox.container.background,

                shape = shapes.rounded_rect(),
                shape_border_width = c.floating and config.border.floating_width or config.border.tiled_width,
                shape_border_color = c.decoration_color,

                id = "preview-background",

                forced_width = client_preview_width,
                forced_height = client_preview_height
            },
            {
                layout = wibox.container.place,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 5,
                    {
                        widget = clienticon_or_xorg,

                        client = c,

                        forced_width = 24,
                        forced_height = 24,
                    },
                    {
                        -- TODO pretty unreadable on some backgrounds
                        widget = wibox.widget.textbox,
                        text = c.name,
                        font = get_font(14)
                    }
                }
            },
            layout = wibox.layout.fixed.vertical,
            spacing = 5
        }

        -- TODO indicator bg color change breaks minimized windows' preview
        preview:connect_signal("mouse::enter", function()
            local preview_background = preview:get_children_by_id("preview-background")[1]

            preview_background.shape_border_color = config.tag.focus
        end)

        preview:connect_signal("mouse::leave", function()
            local preview_background = preview:get_children_by_id("preview-background")[1]

            preview_background.shape_border_color = c.decoration_color
        end)

        preview:connect_signal("button::press", no_scroll(function()
            local window_drag_area = s.screen_preview:get_children_by_id("window-drag-area")[1]

            local tiny_ass_preview = wibox.widget {
                layout = wibox.container.background,
                forced_width = (preview_height / 7) * client_ratio,
                forced_height = preview_height / 7,

                opacity = 0.9,

                client_preview(c)
            }

            local initial_x
            local initial_y

            window_drag_area:add_at(tiny_ass_preview, {
                x = -400,
                y = 0
            })

            -- TODO can cause a 'mousegrabber already running' error - multiple clients think they're hovered

            mousegrabber.run(function(m)
                local x = m.x
                local y = m.y

                if not initial_x or not initial_y then
                    initial_x = x
                    initial_y = y
                end

                if m.buttons[1] then
                    window_drag_area:move(1, {
                        x = x,
                        y = y + 10
                    })

                    return true
                end

                -- If the mouse isn't pressed, check if there's a tag preview that the client can be moved into
                local hover_widgets = mouse.current_widgets

                for _, hover_widget in ipairs(hover_widgets) do
                    if hover_widget.get_children_by_id and #hover_widget:get_children_by_id("tag-preview") > 0 then
                        local tag_preview = hover_widget

                        local tag_name = tag_preview:get_children_by_id("tag-name")[1].text

                        for _, t in ipairs(s.tags) do
                            if t.name == tag_name then
                                c:move_to_tag(t)

                                c:jump_to()

                                window_drag_area:reset()

                                -- There's a new window to render somewhere!

                                -- fired twice; delayed to allow layouts to take
                                gtimer {
                                    callback = function()
                                        awesome.emit_signal("screen_preview::refresh_tag_previews")
                                    end,
                                    timeout = 0.1,
                                    single_shot = true,
                                    autostart = true,
                                    call_now = true
                                }

                                return false
                            end
                        end

                        break
                    end
                end

                -- Check if the mouse hasn't moved too far - this is an ok drag check
                if math.abs(x - initial_x) < 20 and math.abs(y - initial_y) < 20 then
                    -- Call the signal manually because mousegrabber steals the event away
                    preview:emit_signal("button::release")
                end

                window_drag_area:reset()

                return false
            end, "hand1")
        end))

        preview:connect_signal("button::release", function()
            s.screen_preview.old_tags = {}

            if old_layout then
                t.layout = old_layout
            end

            c:jump_to()

            awesome.emit_signal("screen_preview::hide")
        end)

        client_preview_area:add_at(preview, {
            x = xoffset,
            y = yoffset,
        })

        -- restore minimized state
        local minimized = clients_minimized[c.window]

        if minimized then
            gtimer.delayed_call(function()
                c.minimized = minimized
            end)
        end
    end

    -- Render visible clients
    for index, c in ipairs(clients) do
        if not clients_minimized[c.window] then
            render_client_preview(index, c)
        end
    end

    awesome.connect_signal("screen_preview::hide", function()
        if old_layout then
            t.layout = old_layout

            old_layout = nil
        end
    end)

    -- Render clients that were hidden with a 0.1s delay
    gtimer {
        timeout = 0.1,
        autostart = true,
        single_shot = true,
        callback = function()
            for index, c in ipairs(clients) do
                if clients_minimized[c.window] then
                    render_client_preview(index, c)
                end
            end

            if old_layout then
                t.layout = old_layout
            end
        end
    }
end

return update_selected_tag_preview
