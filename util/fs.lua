-- synchronous file system operations

local gfs = require("gears.filesystem")

-- https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua

--- Check if a file or directory exists in this path
---@param file string path to a file
---@return boolean exists, string? error if the file path exists
local function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

--- Check if the path is a directory
---@param path string
---@return boolean
local function isdir(path)
    return gfs.is_dir(path)
end

--- Make a directory including parent directories
---@param path string directory path to create
local function mkdir(path)
    gfs.make_directories(path)
end

--- Read a file as a string
---@param path string the file path to read
---@return string|nil contents the file's contents or nil
local function read_file(path)
    local file = io.open(path, "r") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

--- Remove a file or directory
---@param path string the file/directory path
---@param recursive boolean whether or not to use the rm -r flag
local function remove(path, recursive)
    os.execute("rm " .. (recursive and "-r " or "") .. path)
end

--- Write content to a file
---@param path string path to the file
---@param content string contents to write
---@return nil
local function write_file(path, content)
    local file = io.open(path, "w")

    if not file then return nil end

    file:write(content)

    file:flush()
    file:close()
end

return {
    exists = exists,
    mkdir  = mkdir,
    isdir  = isdir,
    read   = read_file,
    write  = write_file,
    rm     = remove
}
