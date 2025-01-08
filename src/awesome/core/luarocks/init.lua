
local ensure   = require("src.awesome.core.luarocks.ensure")
local needs    = require("src.awesome.core.luarocks.needs")
local packages = require("src.awesome.core.luarocks.packages")

return {
    ensure = ensure,
    needs = needs,
    packages = packages
}
