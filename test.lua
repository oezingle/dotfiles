#!/usr/bin/lua

-- TODO some way to expect output from awesome? tail cmd? async shit?

jit = jit or nil
if jit then
    for k, v in pairs(package) do
        print(k, v)
    end

    table.insert(package.searchers or package.loaders, function (library)
        if not library:match("%.init$") then
            local path = package.searchpath(library .. ".init", package.path)
            
            if path then
                return function () 
                    return require(library .. ".init")
                end                
            end
        end
    end)
end

local _, err = pcall(require, "gears")

if err and arg then
    if arg[1] == "awesome" then
        print("Running in awesome-client for you")

        os.execute("cat " .. arg[0] .. " | grep -v \"#!/usr/bin/lua\" | awesome-client")

        print("Check your AwesomeWM logs")
    else
        print("Running tests in lua CLI. To run in awesomewm, call 'test.lua awesome'")

        require("test.init")
    end

    os.exit()
else
    awesome.emit_signal("awesome::dotfiles::test")
end
