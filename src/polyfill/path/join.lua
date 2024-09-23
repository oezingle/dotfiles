local sep = require("src.polyfill.path.sep")

---@param ... string
local function join(...)
    local elements = table.pack(...)

    local ret = {}

    for i, item in ipairs(elements) do
        local is_first = i == 1
        -- local is_last  = i == #elements

        -- Remove starts with slash
        if item:sub(1, 1) == sep and not is_first then
            item = item:sub(2)
        end

        -- Remove starts with ./
        if item:sub(1, 2) == ("." .. sep) and not is_first then
            item = item:sub(3)
        end

        if item:sub(-1) == sep then
            item = item:sub(1, -2)
        end

        -- TODO FIXME strip whitespace

        if item:match("%S") then
            table.insert(ret, item)
        end
    end

    local joined = table.concat(ret, sep)
        -- remove /./
        :gsub("[/\\].[/\\]", sep)
        -- remove /<path>/../
        :gsub("[/\\][^/\\]+[/\\]%.%.[/\\]", sep)

    return joined
end

return join
