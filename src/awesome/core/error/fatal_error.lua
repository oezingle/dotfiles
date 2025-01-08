-- No static dependencies, all error handled. If anything whatsoever fails, this file will do the utmost to do as much as possible.

---@param to_try function
---@param print_msg string
local function try_catch_print(to_try, print_msg)
    -- no unpack here. might not exist under LuaJIT
    local ok = pcall(to_try)

    if not ok then
        print(print_msg)
    end
end

---@param err string
local function fatal_error(err)
    -- log might not exist. I don't care.
    try_catch_print(function()
        log.fatal(err)
    end, err)

    try_catch_print(function()
        local Service = require("src.util.Service.Service")

        Service.stop_all({ "cli" })
            :after(function()
                log.info("Successfully stopped all services")
            end)
    end, "Failed to stop services.")

    -- try to write the error to a file.
    try_catch_print(function()
        local write_error_log = require("src.awesome.core.error.write_error_log")

        write_error_log(err)
    end, "Failed to write error log.")

    -- try to show the user the error.
    try_catch_print(function()
        local error_page = require("src.awesome.ui.preload.error_page")

        error_page.display(err)
    end, "Failed to show error page.")
end

return fatal_error
