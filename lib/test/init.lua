
local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module 'test.main'
local lib = require(folder_of_this_file .. 'test.main')

return lib