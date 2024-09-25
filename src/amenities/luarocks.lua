
--[[
luarocks --lua-version 5.1 path --bin

export LUA_PATH='/usr/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/share/lua/5.1/?/init.lua;/usr/local/lib/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?/init.lua;/usr/lib/lua/5.1/?.lua;/usr/lib/lua/5.1/?/init.lua;./?.lua;./?/init.lua;/home/zingle/.luarocks/share/lua/5.1/?.lua;/home/zingle/.luarocks/share/lua/5.1/?/init.lua'
export LUA_CPATH='/usr/local/lib/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/lib/lua/5.1/loadall.so;./?.so;/home/zingle/.luarocks/lib/lua/5.1/?.so'
export PATH='/home/zingle/.luarocks/bin:/home/zingle/.nvm/versions/node/v18.0.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/home/zingle/.config/awesome/asset/applets'
]]

local ok, err = pcall(require, "luarocks.loader")

if not ok then
    log.warn("Unable to load luarocks loader")
end