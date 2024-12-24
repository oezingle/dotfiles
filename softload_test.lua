
require("src.amenities.init")

local SoftLoadedAsset = require("src.util.soft_load.SoftLoadedAsset")

local inpath = "src/awesome/ui/taskbar/Taskbar.lua"

local asset = SoftLoadedAsset({
    path = inpath
})

print(asset:get_module())