local folder_of_this_file

-- https://stackoverflow.com/questions/4521085/main-function-in-lua

if pcall(debug.getlocal, 4, 1) then
    folder_of_this_file = (...):match("(.-)[^%.]+$")

    if not folder_of_this_file:match("<OUTDIR_END>%.") then
        folder_of_this_file = folder_of_this_file .. "<OUTDIR_END>."
    end
else
    folder_of_this_file = arg[0]:gsub("[^%./\\]+%..+$", ""):gsub("[/\\]", ".")
end

require(folder_of_this_file .. "_shim")

-- TODO make @module work
---@module "<OUTDIR_END>.src.<OUT_FILE>"
local module = require("<UUID>.src.<OUT_FILE>")

return module