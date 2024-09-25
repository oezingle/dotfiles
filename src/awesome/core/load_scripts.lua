local join             = require("src.polyfill.path.join")
local dir              = require("src.util.dir")
local fs               = require("src.util.fs")
local Action           = require("src.util.Action")
local Service          = require("src.util.Service")

local load_scripts     = {
    ---@type table<string, any>
    modules = {},
}

local validator        = {}
load_scripts.validator = validator

function validator.is_action(object)
    return
        type(object) == "table" and
        object.instanceOf and
        object:instanceOf(Action)
end

function validator.is_service(object)
    return
        type(object) == "table" and
        object.instanceOf and
        object:instanceOf(Service)
end

--[[
--- TODO FIXME custom require - setfenv for any calls to require() in loaded files
---@param modname string
function load_scripts.require(modname)

end


function load_scripts.make_loaded()

end
]]

---@alias Zingle.Awesome.LoadScripts.FileInfo { validator: (fun(module: any): boolean)? }

---@return table<string, Zingle.Awesome.LoadScripts.FileInfo>
function load_scripts.find_files()
    local files_existing = {}

    -- TODO FIXME make these paths betterer
    for dir_name, settings in pairs({
        [dir.src.awesome.actions()] = {
            validator = validator.is_action
        },
        [dir.src.awesome.services()] = {
            validator = validator.is_service
        },
        [dir.config.actions()] = {
            validator = validator.is_action,
            expected = false
        },
        [dir.config.services()] = {
            validator = validator.is_service,
            expected = false
        },
        [dir.config.scripts()] = {
            expected = false
        }
    }) do
        if not fs.exists(dir_name) then
            if settings.expected then
                log.warn(string.format("Expected directory %q, found nothing", dir_name))
            end
        elseif not fs.is_dir(dir_name) then
            if settings.expected then
                log.error(string.format("Expected directory %q, found file", dir_name))
            end
        else
            for _, file in ipairs(fs.ls(dir_name)) do
                local path = join(dir_name, file)

                if fs.is_dir(path) then
                    path = join(path, "init.lua")
                end

                files_existing[path] = {
                    validator = settings.validator
                }
            end
        end
    end

    return files_existing
end

---@param existing table<string, Zingle.Awesome.LoadScripts.FileInfo>
function load_scripts.prune(existing)
    local has_dead = false

    for path in pairs(load_scripts.modules) do
        if not existing[path] then
            log.info(string.format("Script %q found to be removed", path))

            load_scripts.modules[path] = nil

            has_dead = true
        end
    end

    if has_dead then
        collectgarbage("collect")
    end
end

function load_scripts.reset()
    load_scripts.modules = {}
end

function load_scripts.poll()
    local files = load_scripts.find_files()

    for file, info in pairs(files) do
        if not load_scripts.modules[file] then
            local chunk, err = loadfile(file)

            if chunk then
                log.debug("Loading", file)

                local module = chunk()

                local validated = not info.validator or info.validator(module)

                if validated then
                    load_scripts.modules[file] = module

                    log.info("Loaded", file)
                else
                    log.error(string.format("Ignoring %s, as it failed validation", file))
                end
            else
                log.error(string.format("Unable to load file %q: %s", file, err))
            end
        end
    end

    load_scripts.prune(files)
end

return load_scripts
