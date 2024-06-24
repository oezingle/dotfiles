
-- create global warn()
require("src.amenities.warn")

-- table.pack() & table.unpack()
require("src.amenities.table_pack")

-- This one should be a luajit default in my mind
-- require("src.somelib") works to the same effect as require("src.somelib.init") 
require("src.amenities.search_init")

-- allow calling class() wherever you damn please
require("src.amenities.global_30log")

-- allow the language server to see AwesomeWM types
require("src.amenities.require_awesome_types")