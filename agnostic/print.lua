
---@return fun(...: any)
return (function()
    local has_gears = pcall(require, "gears")

    if has_gears then
        local print_warning = require("gears.debug").print_warning

        return function (...)
            local items = table.pack(...)

            local collector = ""

            for _, item in ipairs(items) do
                collector = collector .. tostring(item) .. " "
            end

            print_warning(collector)
        end
    else
        return print
    end
end)()