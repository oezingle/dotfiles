local pid = io.open("/proc/self/stat"):read():match("[^%s]+")
local stdin_cat = string.format("cat /proc/%s/fd/%d", pid, 0)

local p = io.popen(stdin_cat, "r")
