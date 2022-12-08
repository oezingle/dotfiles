-- Hook into NetworkManager

-- TODO buttons should have better radiuses - applet toolkit

local client = require("src.widgets.network_manager.client")()
local no_scroll = require("src.widgets.helper.no_scroll")

require("src.widgets.network_manager.ap")
local device           = require("src.widgets.network_manager.device")
local interface_widget = device.interface_widget
local wifi_widget      = device.wifi_widget
require("src.widgets.network_manager.connection")

local wibox = require("wibox")

local exitable_dialog = require('widgets.util.exitable_dialog')

local widget = wibox.widget {
    {
        widget = wibox.widget.textbox,
        font = "Inter Regular 12",
        text = "Network Manager"
    },
    {
        id = "interface-list",
        layout = wibox.layout.fixed.vertical
    },
    layout = wibox.layout.fixed.vertical,

    forced_width = 512
}

local interface_list = widget:get_children_by_id("interface-list")[1]

local function update_widget()
    -- remove children
    interface_list:reset()

    for _, device in ipairs(client:get_devices()) do
        local type = device:get_device_type()

        if device:is_real() then
            if type == "WIFI" then
                interface_list:add(wifi_widget(device))
            elseif type == "ETHERNET" then
                interface_list:add(interface_widget(device))
            end
        end
    end
end

update_widget()

local popup, close_button = exitable_dialog {
    widget = widget
}

close_button:connect_signal("button::press", no_scroll(function()
    awesome.emit_signal("module::network:update")
end))

awesome.connect_signal("module::network:update", function()
    update_widget()
end)

local function network_manager_widget()
    popup.visible = not popup.visible

    if popup.visible then
        update_widget()
    end
end

return network_manager_widget
