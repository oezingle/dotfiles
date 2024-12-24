
local Virtualize = require("src.util.Virtualize")

local fake_self = { name = "test" }

---@diagnostic disable-next-line:invisible
local default_env = Virtualize.get_default_env(fake_self)

local missing = {}

for k in pairs(_G) do
    if not default_env[k] then
        table.insert(missing, tostring(k))
    end    
end

if #missing > 0 then
    print("Virtualize default env should provide:")
    for _, v in ipairs(missing) do
        print("", v)
    end
else
    print("All good!")
end
