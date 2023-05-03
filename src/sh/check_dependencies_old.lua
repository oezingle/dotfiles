
local print = require("src.agnostic.print")

local spawn = require("src.agnostic.spawn")

-- TODO replace with ({ dependencies }, silent: boolean?) -> Promise<met: boolean>

--- Run a callback if the required commands/dependencies are installed.
-- 
--- Uses which, meaning you need to provide a command name or exact path
---@param dependencies string|string[]
---@param callback fun()
---@param feature_name string?
local function check_dependencies_old(dependencies, callback, feature_name)
    if type(dependencies) == "string" then
        dependencies = { dependencies }
    end

    if dependencies and #dependencies > 0 then
        local cmd = ''

        for _, dependency in ipairs(dependencies) do
            cmd = cmd .. "which " .. dependency .. " > /dev/null && "
        end

        cmd = cmd .. "printf success"

        spawn(cmd, function(res)
            if res == 'success\n' or res == 'success' then
                callback()
            else
                -- Print dependencies requested so the user can check if they've got them all
                local msg

                if #dependencies > 1 then
                    msg = "Dependencies "

                    for i, dependency in ipairs(dependencies) do
                        if i == #dependencies then
                            msg = msg .. "and/or " .. dependency
                        else
                            msg = msg .. dependency .. ", "
                        end
                    end
                else
                    msg = "Dependency " .. dependencies[1]
                end

                msg = msg .. " not met"

                if feature_name then
                    msg = msg .. ". Disabling feature '" .. feature_name .. "'."
                end

                print(msg)
            end
        end)
    else
        callback()
    end
end

--[[
awesome.connect_signal("awesome::dotfiles::vhs::test", function()
    gdebug.print_warning("check_dependencies tests (2):")

    check_dependencies({ "18def6ccaa90" }, function() end, "test for missing dependency")
    check_dependencies({ "sh" }, function() gdebug.print_warning("test for given dependency") end)
end)
]]

return check_dependencies_old
