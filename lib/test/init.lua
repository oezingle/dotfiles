
local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module 'test.main'
return require(folder_of_this_file .. 'test.main')