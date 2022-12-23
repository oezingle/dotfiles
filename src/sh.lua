local awful = require('awful')
local config = require('config')
local get_wallpaper = require('src.util.get_wallpaper')
local check_dependencies = require('src.util.check_dependencies')

-- keep a process around so long as awesome is active
---@param command string
local function pidwatch(command)
    -- local pid = awful.spawn.with_shell(config_dir .. "sh/pidwatch.sh awesome " .. command)

    -- only drawback of this method is that it doesn't handle w mcrashes
    local pid = awful.spawn.with_shell(command)

    awesome.connect_signal("exit", function()
        -- -pid = kill group
        awesome.kill(-pid, awesome.unix_signal['SIGTERM'])
    end)
end

-- Two finger right click
check_dependencies({ "xinput" }, function()
    awful.spawn("xinput set-prop \"Synaptics TM3289-021\" \"libinput Click Method Enabled\" 0, 1")
end, "Two finger right click")

-- picom
if config.apps.compositor and #config.apps.compositor then
    pidwatch(config.apps.compositor)
end

-- xfce4 power manager
--check_dependencies({ 'xfce4-power-manager ' }, function()
pidwatch("xfce4-power-manager")
--end, "xfce4 power manager - autosleep, battery management")

check_dependencies("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1", function()
    pidwatch("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end, "gnome polkit agent")

check_dependencies({ 'redshift', '/usr/lib/geoclue-2.0/demos/agent' }, function()
    local redshift = require("src.util.redshift")

    redshift.init()

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
    -- light wallpaper: check if 1x1 version is more than half white, add -l flag

    check_dependencies({ 'wal' }, function()
        local function update_pywal()
            awful.spawn.easy_async_with_shell("wal -i '" .. get_wallpaper() .. "'", function ()
                awesome.emit_signal("wal::changed")
            end)
        end

        update_pywal()

        awesome.connect_signal("wallpaper_should_change", update_pywal)
    end, 'pywal color scheme generation')
end

-- pulse audio
check_dependencies({ "start-pulseaudio-x11" }, function()
    awful.spawn("start-pulseaudio-x11")
end, "pulseaudio audio")

-- screen locking
if config.lock_time then
    -- TODO better fix for copies of xautolock
    awful.spawn("pkill xautolock")

    check_dependencies({ "xautolock" }, function()
        -- TODO re-enable xautolock
        
        -- pidwatch("xautolock -time " .. tostring(config.lock_time) .. " -locker \"dm-tool lock\"")
    end, "xautolock screen locking")
end

-- some xinput stuff
-- Enable trackpad while typing
awful.spawn("xinput set-prop 10 325 0")
-- Enable middle click (some apps don't care)
-- TODO run this every time unlocked
awful.spawn("xinput set-prop 10 333 1")

pidwatch("nm-applet")

local function rofi()
	awful.spawn(config.apps.rofi)	
end

return {
    pidwatch = pidwatch,
    rofi = rofi
}
