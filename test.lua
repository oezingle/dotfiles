

-- TODO open in xephyr if awesome isn't running

-- TODO some way to expect output from awesome? tail cmd? async shit?

local _, err = pcall(require, "gears")

if err and arg then
    if arg[1] == "awesome" then
        print("Running in awesome-client for you")

        os.execute("cat " .. arg[0] .. " | awesome-client")

        print("Check your AwesomeWM logs")
    else
        print("Running tests in lua CLI. To run in awesomewm, call 'test.lua awesome'")

        require("test.init")
    end
    
    os.exit()
end

local gdebug = require("gears.debug")

gdebug.print_warning("Running dotfile tests")

awesome.emit_signal("awesome::dotfiles::test")