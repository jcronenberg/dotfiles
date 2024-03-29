--[[

     Neon AwesomeWM Theme

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")

local string, os = string, os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.default_dir                               = require("awful.util").get_themes_dir() .. "default"
theme.icon_dir                                  = os.getenv("HOME") .. "/.config/awesome/themes/neon/icons"
theme.wallpaper1                                 = os.getenv("HOME") .. "/.config/awesome/themes/neon/wall.jpg"
theme.wallpaper2                                 = os.getenv("HOME") .. "/.config/awesome/themes/neon/wall2.jpg"
theme.font                                      = "Roboto Bold 10"
theme.taglist_font                              = "Roboto Condensed Regular 10"
theme.neon_accent                               = "#ff22a5"
theme.neon_main_light                           = "#4898f7"
theme.neon_main_dark                            = "#4898f7"
theme.fg_normal                                 = theme.neon_main_dark -- unselected text color, includes clock, cal etc.
theme.fg_focus                                  = theme.neon_main_light
theme.bg_focus                                  = "#00000000" -- background color for taglist and clock, cal etc.
theme.bg_normal                                 = "#00000000" -- background color for the whole wibar
theme.fg_urgent                                 = "#000000" -- text color for alert
theme.bg_urgent                                 = theme.neon_accent -- background color for alert
theme.systray_bg                                = "#000032" -- background for the systray (try to match to wallpaper, as this has not transparency)
theme.border_width                              = dpi(1)
theme.border_normal                             = theme.neon_main_dark
theme.border_focus                              = theme.neon_accent
theme.taglist_fg_focus                          = "#ffffff"
theme.tasklist_bg_normal                        = "#00000000"
theme.tasklist_fg_focus                         = theme.neon_accent .. "00" -- color for selected task (needs to be transparent, but even then somehow has effect)
theme.menu_height                               = dpi(20)
theme.menu_width                                = dpi(160)
theme.menu_icon_size                            = dpi(32)
theme.awesome_icon_launcher                     = theme.icon_dir .. "/awesome_icon.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = dpi(4)
theme.gap_single_client                         = false
theme.master_width_factor                       = 0.5
theme.layout_machi                              = theme.icon_dir .. "/machi.png"
theme.layout_tile                               = theme.icon_dir .. "/tile.png"
theme.layout_fairv                              = theme.icon_dir .. "/fairv.png"
theme.layout_magnifier                          = theme.icon_dir .. "/magnifier.png"
theme.layout_centerwork                         = theme.icon_dir .. "/centerwork.png"
theme.layout_tilebottom                         = theme.icon_dir .. "/tilebottom.png"

theme.musicplr = string.format("%s -e ncmpcpp", awful.util.terminal)

local markup = lain.util.markup
local blue   = "#80CCE6"
local space3 = markup.font("Roboto 3", " ")

-- Clock
local mytextclock = wibox.widget.textclock(markup(theme.fg_normal, space3 .. "%H:%M:%S  " .. markup.font("Roboto 4", " ")),1)
mytextclock.font = theme.font
local clockbg = wibox.container.background(mytextclock, theme.bg_focus, gears.shape.rectangle)
local clockwidget = wibox.container.margin(clockbg, dpi(0), dpi(3), dpi(5), dpi(5))

-- Calendar
local mytextcalendar = wibox.widget.textclock(markup.fontfg(theme.font, theme.fg_normal, space3 .. "%d %b " .. markup.font("Roboto 5", " ")))
local calbg = wibox.container.background(mytextcalendar, theme.bg_focus, gears.shape.rectangle)
local calendarwidget = wibox.container.margin(calbg, dpi(0), dpi(0), dpi(5), dpi(5))
theme.cal = lain.widget.cal({
    attach_to = { mytextclock, mytextcalendar },
    notification_preset = {
        fg = theme.fg_normal,
        bg = theme.bg_normal,
        position = "top_right",
        font = "Monospace 10"
    }
})

-- Battery
local bat = lain.widget.bat({
    settings = function()
        bat_header = " Battery: "
        bat_p      = bat_now.perc .. "%  "
        if bat_now.ac_status == 1 then
            bat_p = bat_p .. "Plugged  "
        end
        widget:set_markup(markup.font(theme.font, markup(theme.neon_main_dark, bat_header .. bat_p)))
    end
})

-- ALSA volume bar
theme.volume = lain.widget.pulsebar({
    notification_preset = { font = "Monospace 9"},
    --togglechannel = "IEC958,3",
    width = dpi(80), height = dpi(10), border_width = dpi(0),
    colors = {
        background = "#383838",
        unmute     = theme.neon_main_light,
        mute       = theme.neon_accent
    },
})
theme.volume.bar.paddings = dpi(0)
theme.volume.bar.margins = dpi(5)
local volumewidget = wibox.container.background(theme.volume.bar, theme.bg_focus, gears.shape.rectangle)
volumewidget = wibox.container.margin(volumewidget, dpi(0), dpi(0), dpi(5), dpi(5))
volumewidget:connect_signal("button::press", function() awful.spawn.with_shell("pavucontrol") end)

-- CPU
local cpu_icon = wibox.widget.imagebox(theme.cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(space3 .. markup.font(theme.font, "CPU: " .. string.format("%02d", cpu_now.usage)
                          .. "% ") .. markup.font("Roboto 5", " "))
    end
})
local cpubg = wibox.container.background(cpu.widget, theme.bg_focus, gears.shape.rectangle)
local cpuwidget = wibox.container.margin(cpubg, dpi(0), dpi(0), dpi(5), dpi(5))
cpuwidget:connect_signal("button::press", function() awful.spawn.with_shell("alacritty -e htop") end)

-- Net
local netdown_icon = wibox.widget.imagebox(theme.net_down)
local netup_icon = wibox.widget.imagebox(theme.net_up)
local net = lain.widget.net({
    settings = function()
        widget:set_markup(markup.font(theme.font, "DOWN: " .. string.format("%07.1f", net_now.received)
                          .. "  UP: " .. string.format("%07.1f", net_now.sent) .. "  " .. markup.font("Roboto 5", " ")))
    end
})
local netbg = wibox.container.background(net.widget, theme.bg_focus, gears.shape.rectangle)
local networkwidget = wibox.container.margin(netbg, dpi(0), dpi(0), dpi(5), dpi(5))

-- Launcher
local mylauncher = awful.widget.button({ image = theme.awesome_icon_launcher })
mylauncher:connect_signal("button::press", function() awful.util.mymainmenu:toggle() end)

function theme.at_screen_connect(s)
    -- Quake application
    -- s.quake = lain.util.quake({
    --     app = "alacritty",
    --     argname = "--name %s",
    --     extra = "--class QuakeDD -e tmux",
    --     visible = true,
    --     height = 0.4
    -- })

    theme.wallpapers = {theme.wallpaper1,
		        theme.wallpaper2}

    -- Wallpapers for specific outputs
    local wallpapers = {}
    wallpapers["DisplayPort-1"] = theme.wallpaper2
    wallpapers["DisplayPort-0"] = theme.wallpaper1
    wallpapers["HDMI-A-0"] = theme.wallpaper2

    theme.wallpaper = function( s )
        -- match s.outputs to a output in wallpapers
        for output, wp in pairs(wallpapers) do
            for out, _ in pairs(s.outputs) do
                if out == output then
                    return wp
                end
            end
        end
        -- default if output not in wallpapers
        return theme.wallpapers[2]
    end

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.util.layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({}, 1, function () awful.layout.inc( 1) end),
                           awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
                           awful.button({}, 3, function () awful.layout.inc(-1) end),
                           awful.button({}, 4, function () awful.layout.inc( 1) end),
                           awful.button({}, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons, { bg_focus = theme.fg_focus })

    mytaglistcont = wibox.container.background(s.mytaglist, theme.bg_focus, gears.shape.rectangle)
    s.mytag = wibox.container.margin(mytaglistcont, dpi(0), dpi(0), dpi(5), dpi(5))

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons, { bg_focus = theme.tasklist_fg_focus, shape = gears.shape.rectangle, shape_border_width = 5, shape_border_color = theme.tasklist_bg_normal, align = "center" })

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(32) })

    -- Create systray
    s.mysystraywidget = wibox.widget.systray()
    beautiful.bg_systray = theme.systray_bg
    mysystraycont = wibox.container.background(s.mysystraywidget, theme.bg_focus, gears.shape.rectangle)
    s.mysystray = wibox.container.margin(mysystraycont, dpi(0), dpi(0), dpi(5), dpi(5))
    --mysystraycont = wibox.widget {
    --    {
    --        wibox.widget.systray(),
    --        left   = 10,
    --        top    = 2,
    --        bottom = 2,
    --        right  = 10,
    --        widget = wibox.container.margin,
    --    },
    --    bg         = theme.bg_focus,
    --    shape      = gears.shape.rounded_rect,
    --    shape_clip = true,
    --    widget     = wibox.container.background,
    --}
    --s.mysystray = wibox.container.margin(mysystraycont, dpi(0), dpi(0), dpi(5), dpi(5))

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytag,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            s.mysystray,
            --bat,
            networkwidget,
            cpuwidget,
            volumewidget,
            calendarwidget,
            clockwidget,
            s.mylayoutbox,
        },
    }
end

return theme
