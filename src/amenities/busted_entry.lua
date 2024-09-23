
-- Entrypoint for busted

require("src.amenities.init")

local script_dir = require("src.util.script_dir")
script_dir.script_dir = script_dir.pwd_and_pray

log.level = "warn"