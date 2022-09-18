local function no_scroll(fn)
    return function(data, lx, ly, button)
        if button ~= 4 and button ~= 5 then
            fn(data, lx, ly, button)
        end
    end
end

return no_scroll
