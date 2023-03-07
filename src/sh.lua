local awful              = require('awful')
local config             = require('config')
local check_dependencies = require('src.util.check_dependencies')
local directories        = require('src.util.fs.directories')

-- TODO use awful.spawn.single_instance

-- keep a process around so long as awesome is active
---@param command string
---@param silent boolean?
local function pidwatch(command, silent)
    silent = silent or false

    -- local pid = awful.spawn.with_shell(config_dir .. "sh/pidwatch.sh awesome " .. command)

    -- only drawback of this method is that it doesn't handle w mcrashes
    local pid = awful.spawn.with_shell(command .. (silent and " > /dev/null 2>&1" or ""))

    awesome.connect_signal("exit", function()
        -- -pid = kill group
        awesome.kill(-pid, awesome.unix_signal.SIGTERM)
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
    pidwatch("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1", true)
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

local wal = require("src.util.wal")

wal.create_hook()

-- pulse audio
check_dependencies({ "start-pulseaudio-x11" }, function()
    awful.spawn("start-pulseaudio-x11")
end, "pulseaudio audio")

-- screen locking
if config.lock_time then
    check_dependencies({ "xautolock" }, function()
        pidwatch(string.format("xautolock -secure -detectsleep -time %s -locker \"dm-tool lock; systemctl suspend\"",
            tostring(config.lock_time)))
    end, "xautolock screen locking")
end

-- some xinput stuff
-- Enable trackpad while typing
awful.spawn("xinput set-prop 10 325 0")
-- Enable middle click (some apps don't care)
-- TODO run this every time unlocked
awful.spawn("xinput set-prop 10 333 1")

pidwatch("nm-applet", true)

local rofi_cmd = string.format("PATH=$PATH:%s %s > /dev/null 2>&1", directories.config .. "applets", config.apps.rofi)

local function rofi()
    awful.spawn.with_shell(rofi_cmd)
end

return {
    pidwatch = pidwatch,
    rofi = rofi
}

-- xdg-mime default thunar.desktop inode/directory
