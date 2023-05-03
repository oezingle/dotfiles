local config             = require('config')
local check_dependencies = require('src.sh.check_dependencies_old')

local rofi               = require("src.sh.rofi")
local pidwatch           = require("src.sh.pidwatch")

require("src.sh.service")

-- TODO why here man
local wal = require("src.util.wal")

wal.create_hook()

-- screen locking
if config.lock_time then
    check_dependencies({ "xautolock" }, function()
        pidwatch(string.format("xautolock -secure -detectsleep -time %s -locker \"dm-tool lock; systemctl suspend\"",
            tostring(config.lock_time)))
    end, "xautolock screen locking")
end

-- TODO make this optional u fucker
-- pidwatch("nm-applet", true)

return {
    pidwatch = pidwatch,
    rofi = rofi
}

-- xdg-mime default thunar.desktop inode/directory
