local wibox = require("wibox")
local no_scroll = require("src.widgets.helper.no_scroll")

local exitable_dialog = require("src.widgets.util.exitable_dialog")
local button_widget   = require("src.widgets.util.button")

local NM = require("src.widgets.network_manager.nm")()

local connection_info = require("src.widgets.network_manager.subwidget.connection_info")
local show_connection_info = connection_info.show_connection_info

local widget = wibox.widget {
    {
        widget = wibox.widget.textbox,
        text = "TEXT_NOT_YET_SET",
        font = "Inter Regular 14",
        id = "header"
    },
    {
        {
            layout = wibox.layout.fixed.vertical,
            spacing = 5,
            id = "connection-list"
        },
        widget = wibox.container.margin,
        left = 5,
    },
    spacing = 10,
    layout = wibox.layout.fixed.vertical
}

local connection_list = widget:get_children_by_id("connection-list")[1]

local dialog, close_button = exitable_dialog {
    widget = widget
}

close_button:connect_signal("button::press", no_scroll(function()
    awesome.emit_signal("module::network:update")
end))

awesome.connect_signal("module::network:update", function()
    dialog.visible = false
end)

local function view_saved_connections(device)
    local interface = device[NM.DEVICE_INTERFACE]

    widget:get_children_by_id("header")[1].text = "Saved Connections for " .. interface

    -- remove children
    connection_list:reset()

    for _, connection in ipairs(device:get_available_connections()) do
        local name = connection:get_filename()
            :gsub("/etc/NetworkManager/system%-connections/", "")
            :gsub("%.nmconnection", "")

        connection_list:add(button_widget(
            {
                widget = wibox.container.margin,
                margins = 5,
                {
                    widget = wibox.widget.textbox,
                    text = name
                }
            },
            function()
                show_connection_info(device, connection)
            end,
            nil,
            false
        ))
    end

    dialog.visible = true
end

return {
    view_saved_connections = view_saved_connections
}