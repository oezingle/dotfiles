local class = require("lib.30log")

local fs = require("src.util.fs.operations")

local folder_of_this_file = (...):match("(.-)[^%.]+$")

---@module "bundler.path"
local pathlib = require(folder_of_this_file .. "path")

local random = math.random
--- Pure-lua function to generate a UUID
---@source https://gist.github.com/jrus/3197011
---@return string uuid
local function uuid()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

    local uuid = string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)

    return uuid
end

--- Return a string that has been escaped, so it can
--- be used in String search functions as a literal
--- https://stackoverflow.com/questions/9790688/escaping-strings-for-gsub
---@param str string
---@return string
local function escape_string(str)
    local rep = str:gsub("([^%w])", "%%%1")

    return rep
end

---@class Bundler : Log.BaseFunctions
---@field config Bundler.Config
---@field uuid string|nil
---@field paths { lua: { src: string }, src: string, dep: string }
---@operator call : Bundler
local Bundler = class("Bundler", {})

---@param config Bundler.Config
function Bundler:init(config)
    self.paths = {
        lua = {}
    }

    self:set_config(config)
end

---@param config Bundler.Config
---@return self self for convenience
function Bundler:set_config(config)
    self.config = config

    return self
end

---@protected
function Bundler:_create_folders()
    if fs.exists(self.config.out_dir) then
        fs.rm(self.config.out_dir, true)
    end

    fs.mkdir(self.config.out_dir)

    fs.mkdir(self.paths.dep)

    fs.cp(self.config.in_dir, self.paths.src)
end

---@protected
function Bundler:_generate_uuid()
    self.uuid = uuid()
end

---@protected
---@param lua_path string
---@param required_by string
---@return boolean success
function Bundler:_find_dependency(lua_path, required_by)
    local test_paths = pathlib.from_lua(lua_path)

    local real_path = nil

    for _, test_path in pairs(test_paths) do
        if fs.exists(test_path) then
            real_path = test_path

            break
        end
    end

    if real_path then
        local build_path = self.paths.dep .. pathlib.sep .. real_path

        if fs.exists(build_path) then
            local content = fs.read(build_path)

            content = string.format("--- required by %s", required_by or "?") .. "\n" .. content

            fs.write(build_path, content)

            return true
        end

        local dir = build_path:match("^(.+)" .. pathlib.sep .. ".+%..+$")

        if not fs.exists(dir) then
            fs.mkdir(dir)
        end

        local content = fs.read(real_path)

        content = string.format("--- required by %s", required_by or "?") .. "\n" .. content

        fs.write(build_path, content)

        -- TODO this is probably gonna create an issue with overwriting files
        -- TODO beuler? beuler?
        self:_replace_requires(build_path)

        return true
    else
        -- TODO consider flag for this in config - error instead of warn
        -- TODO config.libraries or something to ignore runtime libraries
        -- TODO check package.path & package.cpath for these before warning - dependencies should be allowed!

        warn(string.format("library %s not found in project", lua_path))

        return false
    end
end

---@protected
---@param file string
function Bundler:_replace_requires(file)
    assert(self.uuid, "uuid not set")

    local contents = fs.read(file)

    assert(contents, string.format("Reading %s failed", file))

    for call, path in contents:gmatch([[(require%(['"]([^"']+)['"]%))]]) do
        ---@type string
        path = path

        local call_escaped = escape_string(call)

        if path:match("^" .. escape_string(self.paths.lua.src)) then
            local new_path = path:gsub(escape_string(self.paths.lua.src) .. "%.", "")

            contents = contents:gsub(call_escaped, string.format("require(\"%s.src.%s\")", self.uuid, new_path))
        else
            local success = self:_find_dependency(path, file)

            -- Otherwise, this could very well be an external library
            if success then
                contents = contents:gsub(call_escaped, string.format("require(\"%s.dep.%s\")", self.uuid, path))
            end
        end
    end

    fs.write(file, contents)
end

---@protected
---@param dir string
function Bundler:_recursive_replace(dir)
    if dir:sub(-1) ~= "/" then
        dir = dir .. "/"
    end

    for _, item in ipairs(fs.list(dir)) do
        local fullpath = dir .. item

        if item:sub(-1) == "/" then
            self:_recursive_replace(fullpath)
        else
            if pathlib.extension(item) == ".lua" then
                -- look for fucking uh fuck uhm uh require()

                self:_replace_requires(fullpath)
            end
        end
    end
end

---@protected
function Bundler:_create_shim()
    local shim_path = folder_of_this_file:gsub("%.", pathlib.sep) .. "shim_template.lua"

    -- The uuid is double escaped, so gsub doesn't complain
    local double_escaped_uuid = escape_string(self.uuid):gsub("%%", "%%%%")

    local shim_template = fs.read(shim_path):gsub("<UUID>", double_escaped_uuid)

    fs.write(self.config.out_dir .. pathlib.sep .. "_shim.lua", shim_template)
end

---@protected
function Bundler:_create_exports()
    for _, export in pairs(self.config.exports) do
        local export_path = folder_of_this_file:gsub("%.", pathlib.sep) .. "export_template.lua"

        local outdir_end = self.config.out_dir:match("[/\\]([^/\\]+)$")

        local export_template = fs.read(export_path)
            :gsub("<UUID>", self.uuid)
            :gsub("<OUT_FILE>", export.out_file)
            :gsub("<OUTDIR_END>", outdir_end)

        fs.write(self.config.out_dir .. pathlib.sep .. export.out_file .. ".lua", export_template)
    end
end

---@protected
function Bundler:_create_public()
    if self.config.public_dir then
        for _, file in pairs(fs.list(self.config.public_dir)) do
            fs.cp(self.config.public_dir .. pathlib.sep .. file, self.config.out_dir .. pathlib.sep .. file)
        end
    end
end

function Bundler:run()
    self.paths.dep = self.config.out_dir .. pathlib.sep .. "dep"

    self.paths.src = self.config.out_dir .. pathlib.sep .. "src"

    self:_create_folders()

    self:_generate_uuid()

    self.paths.lua.src = pathlib.to_lua(self.config.in_dir)

    self.paths.lua.dep = pathlib.to_lua(self.paths.dep)

    self:_recursive_replace(self.paths.src)

    self:_create_shim()

    self:_create_exports()

    self:_create_public()
end

return Bundler
