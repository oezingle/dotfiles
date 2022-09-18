-- Bind the width and height of the widget
-- Only reliable if the widget is drawn in one place
local function bind_width_and_height(w)
    w._real_draw = w.draw
    
    w.draw = function(self, context, cr, width, height)
        self.width, self.height = width, height
        w._real_draw(self, context, cr, width, height)
    end

    return w
end

return bind_width_and_height