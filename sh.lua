local awful = require('awful')
local config = require('config')
local filesystem = require('gears').filesystem
local get_wallpaper = require('util.get_wallpaper')
local check_dependencies = require('util.check_dependencies')

local config_dir = filesystem.get_configuration_dir()

-- keep a process around so long as awesome is active
---@param command string
local function pidwatch(command)
    -- local pid = awful.spawn.with_shell(config_dir .. "sh/pidwatch.sh awesome " .. command)

    -- only drawback of this method is that it doesn't handle w mcrashes
    local pid = awful.spawn.with_shell(command)

    awesome.connect_signal("exit", function ()
        -- -pid = kill group
        awesome.kill(-pid, awesome.unix_signal['SIGTERM'])
    end)
end

-- Two finger right click
check_dependencies({ "xinput" }, function()
    awful.spawn("xinput set-prop \"Synaptics TM3289-021\" \"libinput Click Method Enabled\" 0, 1")
end, "Two finger right click")

-- picom
--check_dependencies({ 'picom' }, function()
pidwatch("picom --experimental-backends")
--end, "picom compositor")

-- xfce4 power manager
--check_dependencies({ 'xfce4-power-manager ' }, function()
pidwatch("xfce4-power-manager")
--end, "xfce4 power manager - autosleep, battery management")

check_dependencies("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1", function ()
    pidwatch("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end, "gnome polkit agent")

check_dependencies({ 'redshift', '/usr/lib/geoclue-2.0/demos/agent' }, function()
    local redshift = require("util.redshift")

    redshift.init(1)

    -- TODO sort out geoclue man - why does the demo have to run?
    pidwatch("/usr/lib/geoclue-2.0/demos/agent")
end, "redshift blue light adjustment")

-- gestures
if config.gimmicks.gestures then
    check_dependencies({ 'libinput-gestures' }, function()
        pidwatch('libinput-gestures')
    end, "gesture support")
end

if config.gimmicks.pywal then
    check_dependencies({ 'wal' }, function()
        local function update_pywal()
            awful.spawn.with_shell("wal -i '" .. get_wallpaper() .. "'")
        end

        update_pywal()

        awesome.connect_signal("wallpaper_should_change", update_pywal)
    end, 'pywal color scheme generation')
end

-- pulse audio
check_dependencies({ "start-pulseaudio-x11" }, function()
    awful.spawn("start-pulseaudio-x11")
end, "pulseaudio audio")

-- some xinput stuff
-- Enable trackpad while typing
awful.spawn("xinput set-prop 10 325 0")
-- Enable middle click
awful.spawn("xinput set-prop 10 333 1")

-- TODO fix custom network applet
pidwatch("nm-applet")

return {
    pidwatch = pidwatch
}
