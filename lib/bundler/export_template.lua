do
    local folder_of_this_file

    -- https://stackoverflow.com/questions/4521085/main-function-in-lua

    if pcall(debug.getlocal, 4, 1) then
        folder_of_this_file = (...):match("(.-)[^%.]+$")

        -- TODO should match to end
        if not folder_of_this_file:match("<OUTDIR_END>%.$") then
            folder_of_this_file = folder_of_this_file .. "<OUTDIR_END>."
        end
    else
        folder_of_this_file = arg[0]:gsub("[^%./\\]+%..+$", ""):gsub("[/\\]", ".")
    end

    require(folder_of_this_file .. "_shim")
end

local module = require("<UUID>.src.<OUT_FILE>")

-- module is a table, module has function __from_cli, and this file was not require()'d
if type(module) == "table" and type(module.__from_cli) == "function" and table.pack(...)[1] == (arg or {})[1] then
    module.__from_cli()
end

return module