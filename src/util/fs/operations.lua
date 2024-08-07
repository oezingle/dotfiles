-- TODO check if system has LuaFileSystem, and use it if it does for SPEEED https://github.com/lunarmodules/luafilesystem

-- https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua

local fs = {}

--- Check if a file or directory exists in this path
---@param file string path to a file
---@return boolean exists, string? error if the file path exists
function fs.exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

if awesome then
    local gfs = require("gears.filesystem")

    --- Check if the path is a directory
    ---@param path string
    ---@return boolean
    fs.isdir = function(path)
        return gfs.is_dir(path)
    end

    --- Make a directory including parent directories
    ---@param path string directory path to create
    fs.mkdir = function(path)
        gfs.make_directories(path)
    end
else
    -- https://stackoverflow.com/questions/2833675/using-lua-check-if-file-is-a-directory

    --- Check if the path is a directory
    ---@param path string
    ---@return boolean
    fs.isdir = function(path)
        if os.execute("cd '" .. path .. "'") then
            return true
        else
            return false
        end
    end

    --- Make a directory including parent directories
    ---@param path string directory path to create
    fs.mkdir = function(path)
        os.execute("mkdir -p '" .. path .. "'")
    end
end

--- Read a file as a string
---@param path string the file path to read
---@return string|nil contents the file's contents or nil
function fs.read(path)
    local file = io.open(path, "r") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a"  -- *a or *all reads the whole file
    file:close()
    return content
end

--- Remove a file or directory
---@param path string the file/directory path
---@param recursive boolean? whether or not to use the rm -r flag
function fs.rm(path, recursive)
    recursive = recursive or false

    os.execute(string.format("rm %s %s", recursive and "-r" or "", path))
end

--- Write content to a file
---@param path string path to the file
---@param content string contents to write
---@return nil
function fs.write(path, content)
    local file = io.open(path, "w")

    if not file then return nil end

    file:write(content)

    file:flush()
    file:close()
end

---@param dir string the path of the directory to list out
---@return string[] files the files in the directory
function fs.list(dir)
    local files = {}
    for file in io.popen(string.format("ls -pA %s", dir)):lines() do
        table.insert(files, file)
    end

    print(table.concat(files, ", "))

    return files
end

fs.ls = fs.list

---@param src string
---@param dest string
function fs.mv(src, dest)
    os.execute(string.format("mv %s %s", src, dest))
end

---@param src string
---@param dest string
function fs.cp(src, dest)
    os.execute(string.format("cp -r %s %s", src, dest))
end

return fs
