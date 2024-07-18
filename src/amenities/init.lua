---@nospec too simple

-- allow calling logger functions wherever you damn please
require("src.amenities.global.logger")
-- allow calling class() wherever you damn please
require("src.amenities.global.30log")
-- allows getting a stringified representation of a lua object wherever you damn please
require("src.amenities.global.inspect")


-- table.pack() & table.unpack()
require("src.amenities.table_pack")

-- This one should be a luajit default in my mind
-- require("src.somelib") works to the same effect as require("src.somelib.init") 
require("src.amenities.search_init")

-- allow the language server to see AwesomeWM types
require("src.amenities.require_awesome_types")
