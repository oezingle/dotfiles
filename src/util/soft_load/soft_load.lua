local SoftLoadedAsset = require "src.util.soft_load.SoftLoadedAsset"
local TimerService    = require "src.util.Service.TimerService"

local soft_load = {
    ---@type Zingle.SoftLoadedAsset[]
    assets = {}
}

---@param path string
---@param ttl integer? time-to-live in seconds
---@return Zingle.SoftLoadedAsset
function soft_load.load(path, ttl)
    local asset = SoftLoadedAsset({
        path = path,
        ttl  = ttl
    })

    table.insert(soft_load.assets, asset)

    return asset
end

soft_load.service = TimerService.create({
    name = "soft_load"
})

function soft_load.service:on_timer()
    local assets = soft_load.assets

    local now = os.clock()

    for _, asset in ipairs(assets) do
        if asset.last_load + asset.ttl < now then
            asset:kill()
        end
    end
end

return soft_load