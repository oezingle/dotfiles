---@nospec too simple

--- Include path/init.lua, which modern lua does but luajit doesn't
package.path = package.path .. "./?/init.lua"