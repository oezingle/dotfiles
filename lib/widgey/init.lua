
local XMLTransformer = require("lib.widgey.XMLTransformer")

local Component = require("lib.widgey.Component")

-- todo steal loader config once i make that
require("lib.widgey.loader")

local widgey = {}

widgey.Component = Component

---@param xml string
function widgey.render (xml)
    return XMLTransformer()
        :set_document(xml)
        :render()
end

return widgey