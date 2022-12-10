local class = require("lib.30log.30log")

if false then
    --- Create a class
    ---@param name string the name of the class
    ---@param properties table? properties for the class - not instances!
    ---@return table the bound class object. use :init(), not :new()
    class = function(name, properties)
        return class(name, properties)
    end
end

return class