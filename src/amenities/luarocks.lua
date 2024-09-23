
local ok, err = pcall(require, "luarocks.loader")

if not ok then
    log.warn("Unable to load luarocks loader")
end