local Service             = require("src.util.Service.Service")
local MouseWatcher        = require("src.awesome.MouseWatcher")
local MotionData          = require("src.util.MotionData")
local Vector              = require("src.util.Vector")
local Timer               = require("src.util.Timer.Timer")
local get_cursor_size     = require("src.awesome.services.mouse_shake_enlarger.get_cursor_size")
local get_cursor_image    = require("src.awesome.services.mouse_shake_enlarger.get_cursor_image")
local gdk_own_widget      = require("src.util.lgi.helper.gdk_own_widget")
local set_cursor          = require("src.awesome.services.mouse_shake_enlarger.set_cursor")
local Animated            = require("src.awesome.Animated")
local wibox               = require("wibox")

-- TODO FIXME is actualy really annoying. Make a fake mouse input below wibox!

-- TODO FIXME use xconf-query or whatever its called to detect cursor settings, if they exist, then fall back to gtk

-- TODO get out of global
-- TODO FIXME i doubled this number because the cursor itself seems to only take
-- TODO FIXME up half of the image. I don't even care anymore.
local default_cursor_size = get_cursor_size() * 2

---@class Zingle.Awesome.Service.MouseShakeEnlarger : Zingle.Awesome.Service
local MouseShakeEnlarger = Service.create({
    name = "mouse-shake-enlarger",
})

-- TODO get out of global
local events = {}
local event_clock = 0

---@param coordinates Awesome.MouseCoordsWithButtons
function MouseShakeEnlarger:on_mouse_move(coordinates)
    self.mousedata:insert(Vector({
        coordinates.x,
        coordinates.y
    }))

    local velocity = self.mousedata:velocity()
    local jerk = self.mousedata:jerk()

    if jerk:magnitude() > 5 then
        local time = os.time()
        -- events must be within 1 second of each other
        if time >= event_clock + 1 then
            events = {}

            event_clock = time
        end

        local signedness = ({
            [false] = {
                [false] = 00,
                [true] = 01,
            },
            [true] = {
                [false] = 10,
                [true] = 11,
            }
        })[velocity.x > 0][velocity.y > 0]

        if events[1] ~= signedness then
            table.insert(events, 1, signedness)
        end

        if #events == 3 then
            self.animation:set_target(default_cursor_size * 2.5)

            Timer({
                callback = function()
                    self.animation:set_target(default_cursor_size)
                end,
                single_shot = true,
                autostart = true,
                timeout = 1
            })

            events = {}
        end
    end

    self.wibox.x = coordinates.x - (default_cursor_size / 4)
    self.wibox.y = coordinates.y - (default_cursor_size / 4)
end

function MouseShakeEnlarger:start()
    self.mouse_watcher:start()
end

function MouseShakeEnlarger:stop()
    self.mouse_watcher:stop()
end

function MouseShakeEnlarger:create_wibox ()
    -- TODO FIXME pass through mouse clicks
    self.wibox = wibox {
        bg = "#0000000000",
        -- bg = "#00FF00FF",
    
        width = 100,
        height = 100,
    
        widget = wibox.widget {
            widget = wibox.widget.imagebox,
            image = get_cursor_image()
        },
    
        ontop = true
    }

    -- Dark magick in this delayed call
    --      once wibox is assigned an Xwindow id, we tell gdk to claim the foriegn
    --      window. Then, we set its cursor to none. This is all because AwesomeWM
    --      doesn't support the 'none' cursor type
    Timer.delayed_call(function()
        local box_window = gdk_own_widget(self.wibox)
        set_cursor("none", box_window)
    end)
end

function MouseShakeEnlarger:create_animation ()
    self.animation = Animated({
        duration = 1 / 4,
        subscribed = function(pos)
            if pos <= default_cursor_size then
                self.wibox.visible = false
            else
                self.wibox.visible = true
                self.wibox.width = pos
                self.wibox.height = pos
            end
        end
    })
end

function MouseShakeEnlarger:register()
    Service.register(self)

    self:create_wibox()
    self:create_animation()

    self.mousedata = MotionData(4)

    self.mouse_watcher = MouseWatcher.create(function(coordinates)
        self:on_mouse_move(coordinates)
    end)
end

MouseShakeEnlarger:register()

return MouseShakeEnlarger
