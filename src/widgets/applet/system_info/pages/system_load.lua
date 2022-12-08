local cpu_arc      = require("src.widgets.applet.system_info.cpu_arc")
local memory_usage = require("src.widgets.applet.system_info.memory_usage")
local awful        = require("awful")
local wibox        = require("wibox")
local atk          = require("src.widgets.applet.applet.toolkit")

local function create_system_load()
    local system_load = wibox.widget {
        atk.title("System Load"),
        atk.subtitle("CPU Load"),
        {
            -- CPU arccharts: generated later because we need to grep the cpu count
            id = "cpu-core-charts",

            layout = wibox.layout.flex.horizontal,
            spacing = 15,
        },

        atk.subtitle("Memory"),
        memory_usage(false),
        atk.subtitle("Swap"),
        memory_usage(true),

        --[[
            atk.subtitle("Disk Usage")
            {
                id = "disk-usages",

                layout = wibox.layout.fixed.vertical,
                spacing = 15,
            },
        ]]

        layout = wibox.layout.fixed.vertical,
        spacing = 5,
    }

    do
        awful.spawn.easy_async("grep -c ^processor /proc/cpuinfo", function(result)
            local layout = system_load:get_children_by_id("cpu-core-charts")[1]

            local core_count = tonumber(result) - 1

            for core = 0, core_count do
                local arc, timer = cpu_arc(core)

                system_load:connect_signal("property::visible", function (w)
                    if w.visible then
                        timer:again()
                    else
                        timer:stop()
                    end
                end)

                layout:add(arc)
            end
        end)

        --[[
            awful.spawn.easy_async_with_shell("lsblk -n -b | awk 'match($0, /^[a-z]+/) {print $1 }'", function(stdout)
                local disk_usages = system_load:get_children_by_id("disk-usages")[1]

                for disk in string.gmatch(stdout, "[^\r\n]+") do
                    -- add a widgets.applet.system_info.disk_usage widget to the disk-usages list
                    -- [archart] [disk name]
                    -- [archart] [use] [avail] [total]
                end
            end)
        ]]
    end

    return system_load
end

return create_system_load
