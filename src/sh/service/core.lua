local pack                  = require("src.agnostic.version.pack")
local script_dir            = require("src.agnostic.version.script_dir")
local fs                    = require("src.util.fs")

local service_status        = require("src.sh.service.status")
local json_service_provider = require("src.sh.service.provider.json")

---@alias Service.Info { name: string, description: string, status: Service.Status, dependencies: string[], pid: integer }

---@class Service
---@field get_info fun(self: Service): Service.Info
---@field start fun(self: Service)
---@field stop fun(self: Service)


local services = {
    ---@type Service[]
    list   = {},

    status = service_status
}


---@type string[]
local args = pack(...)

---@param name string
---@return Service|nil
function services.find(name)
    for _, service in ipairs(services.list) do
        if service:get_info().name == name then
            return service
        end
    end

    return nil
end

local function load_services()
    local services_folder = script_dir(args) .. "services"

    for _, service_file in ipairs(fs.list(services_folder)) do
        local path = services_folder .. "/" .. service_file

        local extension = path:match("%.[^.]+$")

        if extension == ".json" then
            local service = json_service_provider()
                :set_name(service_file:gsub("%.json", ""))
                :set_service(fs.json.load(path))

            table.insert(services.list, service)
        elseif extension == ".lua" then
            local lua_path = path
                :gsub(fs.directories.config, "")
                :gsub("%./", "")
                :gsub("/", ".")
                :gsub(extension, "")

            local service = require(lua_path)

            table.insert(services.list, service)
        else
            print(string.format("Unhandleable service found of extension '%s'", extension))
        end
    end

    for _, service in ipairs(services.list) do
        service:start()
    end
end

load_services()

return services
