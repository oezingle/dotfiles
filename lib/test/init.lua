
local folder_of_this_file = (...):match("(.-)[^%.]+$")

local dir = folder_of_this_file:match("test%.$") and '' or 'test.'

print(dir)

---@module 'test.main'
local lib = require(folder_of_this_file .. dir .. 'main')

return lib