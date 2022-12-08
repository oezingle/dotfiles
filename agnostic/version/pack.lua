
local pack = table.pack or function (...)
    local tmp = {...}
    tmp.n = select("#", ...)

    return tmp
end

return pack