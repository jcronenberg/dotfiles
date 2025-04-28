--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ
      * (c) 2013, Rman
      * (c) 2025, Jorik Cronenberg

--]]

local helpers  = require("lain.helpers")
local awful    = require("awful")
local naughty  = require("naughty")
local wibox    = require("wibox")
local math     = math
local string   = string
local type     = type
local tonumber = tonumber
local gears    = require("gears")

-- PulseAudio volume bar
-- lain.widget.pulsearc

local function factory(args)
    local pulsearc = {
        colors = {
            icon            = "#FFFFFF",
            mute            = "#EB8F8F",
            unmute          = "#A4CE8A"
        },

        _current_level = 0,
        _mute          = "no",
        device         = "N/A"
    }

    args             = args or {}

    local timeout    = args.timeout or 5
    local settings   = args.settings or function() end
    local width      = args.width or 28
    local height     = args.height or 1
    local paddings   = args.paddings or 3
    local thickness  = args.thickness or 2
    local icon       = args.icon

    pulsearc.colors              = args.colors or pulsearc.colors
    pulsearc.followtag           = args.followtag or false
    --pulsearc.notification_preset = args.notification_preset
    pulsearc.devicetype          = args.devicetype or "sink"
    pulsearc.cmd                 = args.cmd or "pacmd list-" .. pulsearc.devicetype .. "s | sed -n -e '/*/,$!d' -e '/index/p' -e '/base volume/d' -e '/volume:/p' -e '/muted:/p' -e '/device\\.string/p'"

    --if not pulsearc.notification_preset then
    --    pulsearc.notification_preset = {
    --        font = "Monospace 10"
    --    }
    --end

    pulsearc.arc = wibox.widget {
        {
            id = "icon",
            image = gears.color.recolor_image(icon, pulsearc.colors.icon),
            resize = true,
            widget = wibox.widget.imagebox,
        },
        max_value = 100,
        thickness = thickness,
        start_angle = 4.71238898, -- 2pi*3/4
        forced_height = height,
        forced_width = width,
        paddings = paddings,
        widget = wibox.container.arcchart,
        set_volume_level = function(new_value)
            pulsearc.arc.value = new_value
        end,
        mute = function()
            pulsearc.arc.colors = { pulsearc.colors.mute }
        end,
        unmute = function()
            pulsearc.arc.colors = { pulsearc.colors.unmute }
        end
    }

    function pulsearc.update(callback)
        helpers.async({ awful.util.shell, "-c", type(pulsearc.cmd) == "string" and pulsearc.cmd or pulsearc.cmd() },
        function(s)
            volume_now = {
                index  = string.match(s, "index: (%S+)") or "N/A",
                device = string.match(s, "device.string = \"(%S+)\"") or "N/A",
                muted  = string.match(s, "muted: (%S+)") or "N/A"
            }

            pulsearc.device = volume_now.index

            local ch = 1
            volume_now.channel = {}
            for v in string.gmatch(s, ":.-(%d+)%%") do
              volume_now.channel[ch] = v
              ch = ch + 1
            end

            volume_now.left  = volume_now.channel[1] or "N/A"
            volume_now.right = volume_now.channel[2] or "N/A"

            local volu = volume_now.left
            local mute = volume_now.muted

            if volu:match("N/A") or mute:match("N/A") then return end

            if tonumber(volu) ~= pulsearc._current_level or mute ~= pulsearc._mute then
                pulsearc._current_level = tonumber(volu)
                pulsearc._mute = mute
                pulsearc.arc.set_volume_level(pulsearc._current_level)
                if mute == "yes" then
                    pulsearc.arc.mute()
                else
                    pulsearc.arc.unmute()
                end

                settings()

                if type(callback) == "function" then callback() end
            end
        end)
    end

    helpers.newtimer(string.format("pulsearc-%s-%s", pulsearc.devicetype, pulsearc.device), timeout, pulsearc.update)

    return pulsearc
end

return factory
