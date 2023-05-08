local cpu_arc            = require("src.widgets.applet.system_info.cpu_arc")
local memory_usage       = require("src.widgets.applet.system_info.memory_usage")
local awful              = require("awful")
local wibox              = require("wibox")
local atk                = require("src.widgets.helper.applet.toolkit")
local check_dependencies = require("src.sh.check_dependencies")

local function create_system_load()
    local mem_usage, mem_timer = memory_usage(false)
    local swap_usage, swap_timer = memory_usage(true)

    local timers = { mem_timer, swap_timer }

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
        mem_usage,
        atk.subtitle("Swap"),
        swap_usage,
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
        check_dependencies({ "mpstat" })
            :after(function(met)
                if not met then
                    return
                end

                awful.spawn.easy_async("grep -c ^processor /proc/cpuinfo", function(result)
                    local layout = system_load:get_children_by_id("cpu-core-charts")[1]

                    local core_count = tonumber(result) - 1

                    for core = 0, core_count do
                        local arc, timer = cpu_arc(core)

                        table.insert(timers, timer)

                        layout:add(arc)
                    end
                end)
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

    system_load:connect_signal("property::visible", function(w)
        local visible = w.visible

        for _, timer in ipairs(timers) do
            if visible then
                timer:again()
            else
                if timer.started then
                    timer:stop()
                end
            end
        end
    end)

    -- TODO could cause a bug if someone configures their system to open the applet on startup for some reason
    system_load.visible = false
    system_load:emit_signal("property::visible", system_load)

    return system_load
end

return create_system_load
