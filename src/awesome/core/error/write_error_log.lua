local dir = require("src.util.dir")
local fs = require("src.util.fs")

---@param message string
local function write_error_log (message)
    local path = dir.generated.log(tostring(os.time()) .. ".txt", true)

    fs.mkdir_p(path)

    fs.write(path, message)
end

return write_error_log