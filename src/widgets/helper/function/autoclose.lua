
-- Close a wibox when the mouse leaves it
---@param wibox table the wibox to autoclose
local function autoclose (wibox)
    local function hide ()
        wibox.visible = false
    end

    wibox:connect_signal('mouse::leave', function()
        button.connect_signal('press', hide)
    end)
    
    wibox:connect_signal('mouse::enter', function()
        button.disconnect_signal('press', hide)
    end)
    
    wibox:connect_signal('property::visible', function(self)
        if not self.visible then
            button.disconnect_signal('press', hide)
        end
    end)
end

return autoclose