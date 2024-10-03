
-- Entrypoint for busted

require("src.amenities.init")

local script_dir = require("src.util.script_dir")
script_dir.script_dir = script_dir.pwd_and_pray

log.level = "warn"

require("spec.helper.assert.has_key")
require("spec.helper.assert.deep_equals")