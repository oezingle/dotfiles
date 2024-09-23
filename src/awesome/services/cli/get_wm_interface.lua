
local dir = require("src.util.dir")
local fs = require("src.util.fs")
local Gio = lgi.Gio

local function get_wm_interface()
    local path = dir.asset.awesome.core.cli("DBusNode.xml")
    local xml_content = fs.read(path)
    local node_info = Gio.DBusNodeInfo.new_for_xml(xml_content)
    
    -- TODO can i get interface by name?
    return node_info.interfaces[1]
end

return get_wm_interface