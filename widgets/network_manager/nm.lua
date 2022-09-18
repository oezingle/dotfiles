
local lgi = require("lgi")

-- get the lgi-wrapped libnm library
local function get_network_manager()
    return lgi.NM
end

return get_network_manager