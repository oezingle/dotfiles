---@nospec too simple

--- Include path/init.lua, which modern lua does but luajit doesn't
if not package.path:match("%.%/%?%/init%.lua") then
    -- log.debug("Installing ./?/init.lua search path")

    package.path = package.path .. ";./?/init.lua"
end
