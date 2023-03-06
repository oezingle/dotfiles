-- https://stackoverflow.com/questions/70512121/could-someone-explain-how-do-buttons-on-widget-work

-- wrap a button::press callback so that mouse buttons 4 & 5 (scroll) don't trigger it
local function no_scroll(fn)
    return function(self, lx, ly, button, mods, metadata)
        if button ~= 4 and button ~= 5 then
            fn(self, lx, ly, button, mods, metadata)
        end
    end
end

return no_scroll
