-- modified from
-- https://github.com/manilarome/the-glorious-dotfiles/blob/master/config/awesome/gnawesome/module/exit-screen.lua

local awful                = require('awful')
local gears                = require('gears')
local wibox                = require('wibox')
local dpi                  = require('beautiful').xresources.apply_dpi

local config               = require("config")
local shapes               = require("src.util.shapes")

local get_icon             = require("src.util.fs.get_icon")

local button               = require("src.widgets.helper.button")
local get_decoration_color = require("src.util.color.get_decoration_color")

local msg_table            = {
	'See you never',
}

local greeter_message      = wibox.widget {
	markup = 'Choose wisely!',
	font = 'Inter UltraLight 24',
	align = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local profile_name         = wibox.widget {
	markup = 'user@hostname',
	font = 'Inter Bold 12',
	align = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local update_user_name     = function()
	awful.spawn.easy_async_with_shell(
		[[
		fullname="$(getent passwd `whoami` | cut -d ':' -f 5 | cut -d ',' -f 1 | tr -d "\n")"
		if [ -z "$fullname" ];
		then
				printf "$(whoami)@$(hostname)"
		else
			printf "$fullname"
		fi
		]],
		function(stdout)
			stdout = stdout:gsub('%\n', '')
			local first_name = stdout:match('(.*)@') or stdout:match('(.-)%s')
			first_name = first_name:sub(1, 1):upper() .. first_name:sub(2)
			profile_name:set_markup(stdout)
			profile_name:emit_signal('widget::redraw_needed')
		end
	)
end

update_user_name()

local update_greeter_msg = function()
	greeter_message:set_markup(msg_table[math.random(#msg_table)])
	greeter_message:emit_signal('widget::redraw_needed')
end

update_greeter_msg()

local build_power_button = function(name, icon, callback)
	return button.centered(
		{
			nil,
			{
				{
					image = icon,
					widget = wibox.widget.imagebox,
					forced_width = 32,
					forced_height = 32,
				},
				layout = wibox.container.place
			},
			{
				{
					text = name,
					font = 'Inter Regular 10',
					widget = wibox.widget.textbox
				},
				layout = wibox.container.place
			},
			layout = wibox.layout.align.vertical,
			expand = "inside",
			forced_width = 96,
			forced_height = 96,
		},
		callback
	)
end

local suspend_command = function()
	awesome.emit_signal('module::exit_screen:hide')
	awful.spawn.with_shell('dm-tool lock & systemctl suspend')
end

local logout_command = function()
	awesome.quit()
end

local lock_command = function()
	awesome.emit_signal('module::exit_screen:hide')

	awful.spawn.with_shell("dm-tool lock")
end

local poweroff_command = function()
	awful.spawn.with_shell('poweroff')
	awesome.emit_signal('module::exit_screen:hide')
end

local reboot_command = function()
	awful.spawn.with_shell('reboot')
	awesome.emit_signal('module::exit_screen:hide')
end

local poweroff = build_power_button('Shutdown', get_icon("exit-menu/power-outline.svg"), poweroff_command)
local reboot = build_power_button('Restart', get_icon("exit-menu/refresh-outline.svg"), reboot_command)
local suspend = build_power_button('Sleep', get_icon("exit-menu/bed-outline.svg"), suspend_command)
local logout = build_power_button('Logout', get_icon("exit-outline.svg"), logout_command)
local lock = build_power_button('Lock', get_icon("exit-menu/lock-closed-outline.svg"), lock_command)

local create_exit_screen = function(s)
	s.exit_screen = wibox
		{
			screen = s,
			type = 'splash',
			visible = false,
			ontop = true,
			bg = "#00000066",
			fg = "#fff",
			height = s.geometry.height,
			width = s.geometry.width,
			x = s.geometry.x,
			y = s.geometry.y
		}

	s.exit_screen:buttons(
		gears.table.join(
			awful.button(
				{},
				2,
				function()
					awesome.emit_signal('module::exit_screen:hide')
				end
			),
			awful.button(
				{},
				3,
				function()
					awesome.emit_signal('module::exit_screen:hide')
				end
			)
		)
	)

	s.exit_screen:setup {
		wibox.widget {
			{
				{
					{
						layout = wibox.layout.align.vertical,
						profile_name,
						{
							widget = wibox.container.margin,
							margins = dpi(15),
							greeter_message
						},
						{
							{
								poweroff,
								reboot,
								suspend,
								logout,
								lock,
								layout = wibox.layout.fixed.horizontal,
								spacing = 10,
							},
							spacing = dpi(30),
							layout = wibox.layout.fixed.vertical
						},
					},
					layout = wibox.container.margin,
					margins = 10,
				},
				layout = wibox.container.background,
				shape = shapes.rounded_rect(),
				bg = config.popup.bg,
				shape_border_width = config.border.floating_width,
				shape_border_color = get_decoration_color()
			},
			layout = wibox.container.place
		},
		widget = wibox.container.background,
	}
end

screen.connect_signal(
	'request::desktop_decoration',
	function(s)
		create_exit_screen(s)
	end
)

screen.connect_signal(
	'removed',
	function(s)
		create_exit_screen(s)
	end
)

local exit_screen_grabber = awful.keygrabber {
	auto_start = true,
	stop_event = 'release',
	keypressed_callback = function(self, mod, key, command)
		if key == 's' then
			suspend_command()
		elseif key == 'e' then
			logout_command()
		elseif key == 'l' then
			lock_command()
		elseif key == 'p' then
			poweroff_command()
		elseif key == 'r' then
			reboot_command()
		elseif key == 'Escape' or key == 'q' or key == 'x' then
			awesome.emit_signal('module::exit_screen:hide')
		end
	end
}

awesome.connect_signal(
	'module::exit_screen:show',
	function()
		for s in screen do
			---@diagnostic disable-next-line:undefined-field
			s.exit_screen.visible = false
		end
		awful.screen.focused().exit_screen.visible = true
		exit_screen_grabber:start()
	end
)

awesome.connect_signal(
	'module::exit_screen:hide',
	function()
		update_greeter_msg()
		exit_screen_grabber:stop()
		for s in screen do
			---@diagnostic disable-next-line:undefined-field
			s.exit_screen.visible = false
		end
	end
)

return create_exit_screen
