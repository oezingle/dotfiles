---@nospec too simple

require("src.amenities.entry.configurable")({
    -- lgi is a can of worms I don't want to open
    "global.lgi",
    -- inspection is a debug feature, ignore it.
    "global.inspect",
    -- luarocks loader should be in package.path and package.cpath already
    "luarocks",
    -- Language server doesn't care
    "awesome_types",
    -- This change is already done
    "agnostic.table_pack",
    "agnostic.search_init"
})