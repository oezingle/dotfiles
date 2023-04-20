
local awful = require("awful")
local gtimer = require("gears.timer")

local keygrabber_enable = true
local keygrabber = awful.keygrabber {
    keybindings = {
        { {}, 'Escape', function()
            awesome.emit_signal("screen_preview::hide")
        end }
    },
    -- Note that it is using the key name and not the modifier name.
    export_keybindings = false,
    mask_event_callback = true,

    keyreleased_callback = function(self, mods, key)
        if keygrabber_enable then
            local passthroughs = {
                "Tab"
            }

            for number = 0, 9 do
                table.insert(passthroughs, tostring(number))
            end

            for _, passthrough in ipairs(passthroughs) do
                -- if it's a tag switch, invalidate the history objects
                if type(tonumber(passthrough)) ~= "nil" then
                    -- invalidate tag list
                    awful.screen.focused().screen_preview.old_tags = {}
                end

                if key == passthrough then
                    keygrabber_enable = true

                    self:stop()

                    awful.key.execute(mods, key)

                    gtimer {
                        timeout     = 0.1,
                        single_shot = true,
                        autostart   = true,
                        callback    = function()
                            if keygrabber_enable then
                                self:start()

                                keygrabber_enable = false
                            end
                        end
                    }
                end
            end
        else
            self:stop()

            awful.key.execute(mods, key)
        end
    end
}


awesome.connect_signal("screen_preview::show", function ()
    awful.keygrabber({
        keyreleased_callback = function(self)
            self:stop()

            gtimer.delayed_call(function()
                keygrabber_enable = true

                keygrabber:start()
            end)
        end
    }):start()
end)

awesome.connect_signal("screen_preview::hide", function ()
    keygrabber_enable = false

    keygrabber:stop()
end)