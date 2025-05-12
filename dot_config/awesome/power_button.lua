local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local function create_power_button(args)
    local icon = args.icon
    local color = args.color

    local power_popup

    -- Menu actions
    local power_menu = {
        { "Suspend", function() awful.spawn("systemctl suspend") end },
        { "Shutdown", function() awful.spawn("systemctl poweroff") end },
        { "Restart", function() awful.spawn("systemctl reboot") end },
        { "Logout", function() awesome.quit() end },
    }

    -- Build vertical layout
    local menu_layout = wibox.layout.fixed.vertical()

    for _, item in ipairs(power_menu) do
        local btn = wibox.widget {
            {
                text = item[1],
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
            widget = wibox.container.margin,
            margins = 8,
        }

        btn:connect_signal("button::press", function()
            power_popup.visible = false
            item[2]()
        end)

        menu_layout:add(btn)
    end

    -- Create the awful.popup
    power_popup = awful.popup {
        widget = {
            menu_layout,
            margins = 10,
            widget = wibox.container.margin,
        },
        border_color = beautiful.border_color or color,
        border_width = 2,
        placement = awful.placement.no_offscreen,
        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 6) end,
        visible = false,
        ontop = true,
        bg = beautiful.bg_normal or "#00000000",
    }

    local icon_widget = wibox.widget.imagebox(
        gears.color.recolor_image(icon, color),
        true,
        gears.shape.rectangle
    )

    -- Create a button with an icon
    local power_button = wibox.widget {
        {
            id = "icon_widget",
            widget = icon_widget,
            forced_width = 24,
            forced_height = 24,
        },
        left   = 10,
        right  = 10,
        top    = 5,
        bottom = 5,
        widget = wibox.container.margin,
        bg     = beautiful.bg_normal,
        shape  = gears.shape.rounded_rect,
        widget = wibox.container.background
    }

    power_button:connect_signal("button::press", function()
        power_popup.screen = awful.screen.focused()
        power_popup.visible = not power_popup.visible
    end)

    return power_button
end

return create_power_button
