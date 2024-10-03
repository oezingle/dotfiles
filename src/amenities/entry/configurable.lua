local includes = require("src.polyfill.list.includes")

---@alias Zingle.Awesome.Amenities.Disable
---| "global.logger" 
---| "global.30log" 
---| "global.lgi" 
---| "global.inspect" 
---|
---| "agnostic.table_pack" 
---| "agnostic.search_init" 
---|
---| "awesome_types" 
---| "seed_random" 
---| "luarocks"

---@param disable Zingle.Awesome.Amenities.Disable[]?
return function(disable)
    local disable = disable or {}

    if not includes(disable, "global.logger") then
        -- allow calling logger functions wherever you damn please
        require("src.amenities.global.logger")
    end
    if not includes(disable, "global.30log") then
        -- allow calling class() wherever you damn please
        require("src.amenities.global.30log")
    end
    if not includes(disable, "global.lgi") then
        -- allow using lgi global wherever you damn please
        require("src.amenities.global.lgi")
    end
    if not includes(disable, "global.inspect") then
        -- allow getting a stringified representation of a lua object wherever you damn please
        require("src.amenities.global.inspect")
    end

    if not includes(disable, "agnostic.table_pack") then
        -- table.pack() & table.unpack()
        require("src.amenities.agnostic.table_pack")
    end
    if not includes(disable, "agnostic.search_init") then
        -- This one should be a luajit default in my mind
        -- require("src.somelib") works to the same effect as require("src.somelib.init")
        require("src.amenities.agnostic.search_init")
    end

    if not includes(disable, "awesome_types") then
        -- allow the language server to see AwesomeWM types
        require("src.amenities.require_awesome_types")
    end

    if not includes(disable, "seed_random") then
        -- seed math.random()
        require("src.amenities.seed_random")
    end

    if not includes(disable, "luarocks") then
        -- allow requiring luarocks rocks
        require("src.amenities.luarocks")
    end
end
