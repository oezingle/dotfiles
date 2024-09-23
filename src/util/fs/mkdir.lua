local has_lfs, lfs = pcall(require, "lfs")

local is_windows = require("src.util.fs.is_windows")

---@alias fs.Mkdir fun (path: string): nil

---@type fs.Mkdir
local function mkdir_unix(path)
    os.execute(string.format("mkdir -p %q", path))
end

---@type fs.Mkdir
local function mkdir_lfs(path)
    lfs.mkdir(path)
end

---@type fs.Mkdir
local function mkdir_windows(path)
    os.execute(string.format("mkdir %q", path))
end

local mkdir = nil
if has_lfs then
    mkdir = mkdir_lfs
elseif is_windows then
    mkdir = mkdir_windows
else
    mkdir = mkdir_unix
end

return {
    has_lfs = has_lfs,
    is_windows = is_windows,

    mkdir_unix = mkdir_unix,
    mkdir_windows = mkdir_windows,
    mkdir_lfs = mkdir_lfs,

    ---@type fs.Mkdir
    mkdir = mkdir
}
