
local NM = require("src.widgets.network_manager.nm")()

local client = NM.Client.new()

-- Get the NetworkManager client
local function get_client ()
    return client
end

return get_client