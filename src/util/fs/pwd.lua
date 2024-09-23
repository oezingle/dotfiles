local has_lfs, lfs = pcall(require, "lfs")

local is_windows = require "src.util.fs.is_windows"

---@alias fs.Pwd fun(): string

local function pwd_windows ()
    local handle = io.popen("cd", "r")

    if not handle then
        error("Unable to run child windows process \"cd\"")
    end

    local cwd = handle:read("a")

    return cwd
end

local function pwd_unix ()
    return os.getenv("PWD")
end

local function pwd_lfs ()
    return lfs.currentdir()
end

local pwd = nil
if has_lfs then
    pwd = pwd_lfs    
elseif is_windows then
    pwd = pwd_windows
else
    pwd = pwd_unix()
end

return {
    pwd = pwd,

    pwd_lfs = pwd_lfs,
    pwd_unix = pwd_unix,
    pwd_windows = pwd_windows,
}