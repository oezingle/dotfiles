
local class = require("lib.30log.30log")

--- Create a class
---@param name string the name of the class
---@param properties table? properties for the class - not instances!
---@return table the bound class object. use :init(), not :new()
return function (name, properties)
    return class(name, properties)
end