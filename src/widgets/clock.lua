local wibox     = require('wibox')
local awful     = require('awful')
local beautiful = require('beautiful')
local pywal     = require('src.widgets.util.pywal')
local dpi       = beautiful.xresources.apply_dpi

local function clock_widget(args)

	args = args or {}

	local military_mode = args.military_mode or false


	local clock_format = nil
	if not military_mode then
		clock_format = '<span font="Inter Bold 11">%I:%M %p</span>'
	else
		clock_format = '<span font="Inter Bold 11">%H:%M</span>'
	end

	local clock_widget = pywal(
		wibox.widget.textclock(
			clock_format,
			1
		),
		true
	)

	local clock_tooltip = awful.tooltip
	{
		objects = { clock_widget },
		mode = 'outside',
		delay_show = 1,
		preferred_positions = { 'right', 'left', 'top', 'bottom' },
		preferred_alignments = { 'middle', 'front', 'back' },
		margin_leftright = dpi(8),
		margin_topbottom = dpi(8),
		timer_function = function()
			local ordinal = nil

			local day = os.date('%d')
			local month = os.date('%B')

			local first_digit = string.sub(day, 0, 1)
			local last_digit = string.sub(day, -1)

			if first_digit == '0' then
				day = last_digit
			end

			if last_digit == '1' and day ~= '11' then
				ordinal = 'st'
			elseif last_digit == '2' and day ~= '12' then
				ordinal = 'nd'
			elseif last_digit == '3' and day ~= '13' then
				ordinal = 'rd'
			else
				ordinal = 'th'
			end

			local date_str = os.date('%A') .. ', ' .. month
				.. " " .. day .. ordinal
				
			return date_str
		end,
	}

	clock_widget:connect_signal(
		'button::press',
		function(self, lx, ly, button)
			-- Hide the tooltip when you press the clock widget
			if clock_tooltip.visible and button == 1 then
				clock_tooltip.visible = false
			end
		end
	)

	-- TODO bind a nice calendar widget

	return clock_widget
end

return clock_widget
