--[[

	 Licensed under GNU General Public License v2
	  * (c) 2025,      Jorik Cronenberg
	  * (c) 2013,      Luca CPZ
	  * (c) 2010-2012, Peter Hofmann

--]]

local helpers  = require("lain.helpers")
local fs       = require("gears.filesystem")
local naughty  = require("naughty")
local wibox    = require("wibox")
local gears    = require("gears")
local math     = math
local string   = string
local ipairs   = ipairs
local tonumber = tonumber

-- Battery infos

local function factory(args)
    local pspath = args.pspath or "/sys/class/power_supply/"

    if not fs.is_dir(pspath) then
        --naughty.notify { text = "lain.widget.bat: invalid power supply path", timeout = 0 }
        return
    end

    args              = args or {}

    local color       = args.color
    local icons       = args.icons
    local icon_widget = wibox.widget.imagebox(
        gears.color.recolor_image(icons.full, color),
        true,
        gears.shape.rectangle
    )
    local text_widget = wibox.widget.textbox()
    local bat         = { widget = args.widget or wibox.widget {
           layout  = wibox.layout.fixed.horizontal,
           {
               {
                   id = "icon_widget",
                   widget = icon_widget,
                   forced_width = 24,
                   forced_height = 24,
               },
               id = "icon_margin",
               top = 10,
               left = -2,
               right = -4,
               widget = wibox.container.margin,
           },
           {
               id = "text_widget",
               widget = text_widget,
           },
        },
        icon_widget = icon_widget,
        text_widget = text_widget,
    }
    local timeout     = args.timeout or 30
    local batteries   = args.batteries or (args.battery and {args.battery}) or {}
    local settings    = args.settings or function() end

    function bat.get_batteries()
        helpers.line_callback("ls -1 " .. pspath, function(line)
            local bstr =  string.match(line, "BAT%w+")
            if bstr then
                batteries[#batteries + 1] = bstr
            else
                ac = string.match(line, "A%w+") or ac
            end
        end)
    end

    if #batteries == 0 then bat.get_batteries() end

    bat_now = {
        charging  = false,
        capacity  = 100,
    }

    function bat.update()
        bat.widget.visible = #batteries == 0
        bat.widget:emit_signal("visibility_changed")
        local sum_cap = 0
        local charging = false
        local bat_amount = 0

        for i, battery in ipairs(batteries) do
            local bstr    = pspath .. battery
            local present = helpers.first_line(bstr .. "/present")

            if tonumber(present) == 1 then
                bat_amount = bat_amount + 1
                local cap = tonumber(helpers.first_line(bstr .. "/capacity"))
                sum_cap = sum_cap + (cap or 0)
                local status = helpers.first_line(bstr .. "/status") or "N/A"
                if status == "Charging" then
                    charging = true
                end
            end
        end
        bat_now.charging = charging
        bat_now.capacity = (bat_amount > 0 and math.floor(sum_cap / bat_amount) or 100)

        -- Update icon
        if charging then
            bat.icon_widget.image = gears.color.recolor_image(icons.charging, color)
        else
            bat.icon_widget.image = gears.color.recolor_image(icons.full, color)
        end

        widget = bat.widget
        settings()
    end

    helpers.newtimer("batteries", timeout, bat.update)

    return bat
end

return factory
