

---@diagnostic disable-next-line:duplicate-set-field
table.pack = function (...)
    return {n=select('#',...), ...}
end

table.unpack = unpack