local wibox = require("wibox")

local button_widget    = require("widgets.util.button")
local confirm_widget   = require("widgets.components.confirm")
local exitable_dialog  = require("widgets.util.exitable_dialog")
local heading_and_text = require("widgets.components.heading_and_text")
local id_placeholder   = require("widgets.components.id_placeholder")

local connection = require("widgets.network_manager.connection")
local delete_connection = connection.delete_connection
local activate_connection_and_reload = connection.activate_connection_and_reload

local connection_info_widget = wibox.widget {
    id_placeholder("connection-name"),
    id_placeholder("connection-type"),
    id_placeholder("activate-button"),
    id_placeholder("delete-button"),

    spacing = 5,
    layout = wibox.layout.fixed.vertical
}

local function get_by_id(id)
    return connection_info_widget:get_children_by_id(id)[1]
end

local dialog = exitable_dialog {
    widget = connection_info_widget,
    visible = false
}

awesome.connect_signal("module::network:update", function()
    dialog.visible = false
end)

local function show_connection_info(device, connection)
    get_by_id("connection-name").widget = heading_and_text("Connection Name", connection:get_id())
    get_by_id("connection-type").widget = heading_and_text("Connection Type", connection:get_connection_type())

    get_by_id("activate-button").widget = button_widget(
        {
            widget = wibox.widget.textbox,
            text = "Activate Connection"
        },
        function()
            activate_connection_and_reload(device, connection)
        end
    )
    get_by_id("delete-button").widget = button_widget(
        {
            widget = wibox.widget.textbox,
            text = "Delete Connection"
        },
        function()
            confirm_widget(
                function()
                    delete_connection(connection)
                end,
                "delete this connection?"
            )
        end
    )

    dialog.visible = true
end

return {
    show_connection_info = show_connection_info
}