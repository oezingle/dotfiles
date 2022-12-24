local awful = require("awful")
local wibox = require("wibox")
local atk   = require("src.widgets.helper.applet.toolkit")

-- TODO more specs

local function create_system_specs()
    local system_specs = wibox.widget {
        atk.title("System Specifications"),
        atk.subtitle("CPU Model"),
        atk.id_text("cpu-model"),

        atk.subtitle("System Model"),
        {
            atk.id_text("system-vendor"),
            {
                atk.id_text("product-family"),

                layout = wibox.container.place,
                halign = "right"
            },

            layout = wibox.layout.fixed.horizontal,
            spacing = 15,
        },

        layout = wibox.layout.fixed.vertical
    }

    awful.spawn.easy_async_with_shell("cat /proc/cpuinfo | grep model\\ name | head -n 1 | sed -E 's/model name\\s+:\\s+(.*)@.*/\\1/g'"
        , function(stdout)
        -- TODO these could all be in sed
        local cpu_model = stdout
            :gsub(" CPU", "")-- intel cpus
            :gsub(" %d+%-Core Processor", "")-- amd cpus
            :gsub("%(R%)", "®")
            :gsub("%(TM%)", "™")

        system_specs:get_children_by_id("cpu-model")[1].text = cpu_model
    end)

    awful.spawn.easy_async("cat /sys/devices/virtual/dmi/id/sys_vendor", function(stdout)
        system_specs:get_children_by_id("system-vendor")[1].text = stdout:gsub("\n", "")
    end)

    awful.spawn.easy_async("cat /sys/devices/virtual/dmi/id/product_family", function(stdout)
        system_specs:get_children_by_id("product-family")[1].text = stdout:gsub("\n", "")
    end)

    return system_specs
end

return create_system_specs
