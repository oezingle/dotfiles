local DirectoryPoller = require("src.awesome.core.DirectoryPoller")
local Action          = require("src.util.Action")
local Service         = require("src.util.Service")
local TimerService    = require("src.util.Service.TimerService")
local dir             = require("src.util.dir")
local Virtualize      = require("src.util.Virtualize")

local validator       = {}

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

local load_scripts = {
    ---@type Zingle.Awesome.DirectoryPoller[]
    pollers = {},
    validator = validator
}

function load_scripts.virtual_loader(path)
    return Virtualize()
        :set_name(string.format("load_scripts.loader %s", path))
        :set_env(load_scripts.env)
        :allow_module_begins_with("lib.30log")
        :allow_module_begins_with("lib.log")
        :allow_module_begins_with("src.polyfill")
        :allow_module_begins_with("src.amenities")
        :allow_module_begins_with("src.util.typed")
        :set_input(path)
        :get_module()
end

load_scripts.settings = {
    [dir.src.awesome.actions()] = {
        validator = validator.is_action
    },
    [dir.src.awesome.services()] = {
        validator = validator.is_service
    },
    [dir.config.actions()] = {
        validator = validator.is_action,
        loader = load_scripts.virtual_loader,
        expected = false
    },
    [dir.config.services()] = {
        validator = validator.is_service,
        loader = load_scripts.virtual_loader,
        expected = false
    },
    [dir.config.scripts()] = {
        loader = load_scripts.virtual_loader,
        expected = false,
    }
}

load_scripts.env = (function()
    local mock_Service = {
        create = Service,
        register = Service.register,
        statuses = Service.statuses
    }

    local mock_TimerService = {
        create = TimerService,
        register = TimerService.register,
        statuses = TimerService.statuses
    }

    return Virtualize()
        :set_name("load_scripts.env preload")
        :allow_module_begins_with("lib.30log")
        :allow_module_begins_with("lib.log")
        :allow_module_begins_with("src.polyfill")
        :allow_module_begins_with("src.amenities")
        :allow_module_begins_with("src.util.typed")
        :unlock_env()
        :preload_module("src.amenities.entry.virtual")
        :lock_env()
        :preload_module("src.util.Set")
        :preload_module("src.util.Action")
        :preload_module_unsafe("src.util.Service.Service", mock_Service)
        :preload_module_unsafe("src.util.Service.TimerService", mock_TimerService)
        :get_env()
end)()

function load_scripts.reset()
    load_scripts.pollers = {}

    for dir, settings in pairs(load_scripts.settings) do
        local poller = DirectoryPoller.create({
            dir = dir,
            expected = settings.expected,
            validator = settings.validator,
            loader = settings.loader
        })

        table.insert(load_scripts.pollers, poller)
    end
end

function load_scripts.poll()
    for _, poller in ipairs(load_scripts.pollers) do
        poller:poll()
    end
end

return load_scripts
