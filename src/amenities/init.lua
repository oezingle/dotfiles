---@nospec too simple

-- TODO write an API for a simple error 'page' - ie WM state for when it cannot launch
-- TODO then check for installed packages etc.

-- allow calling logger functions wherever you damn please
require("src.amenities.global.logger")
-- allow calling class() wherever you damn please
require("src.amenities.global.30log")
-- allow using lgi global wherever you damn please
require("src.amenities.global.lgi")
-- allow getting a stringified representation of a lua object wherever you damn please
require("src.amenities.global.inspect")

-- table.pack() & table.unpack()
require("src.amenities.table_pack")

-- This one should be a luajit default in my mind
-- require("src.somelib") works to the same effect as require("src.somelib.init") 
require("src.amenities.search_init")

-- allow the language server to see AwesomeWM types
require("src.amenities.require_awesome_types")

-- seed math.random()
require("src.amenities.seed_random")

-- allow requiring luarocks rocks
require("src.amenities.luarocks")