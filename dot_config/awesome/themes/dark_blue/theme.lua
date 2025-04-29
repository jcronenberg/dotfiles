--[[

     Dark Blue AwesomeWM Theme

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")
local pulsearc = require("pulsearc")
local bat = require("bat")

local string, os = string, os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.default_dir                               = require("awful.util").get_themes_dir() .. "default"
theme.icon_dir                                  = os.getenv("HOME") .. "/.config/awesome/themes/dark_blue/icons"
theme.wallpaper1                                = os.getenv("HOME") .. "/.config/awesome/themes/dark_blue/wall.jpg"
theme.wallpaper2                                = os.getenv("HOME") .. "/.config/awesome/themes/dark_blue/wall.jpg"
theme.font                                      = "Roboto Bold 10"
theme.taglist_font                              = "Roboto Condensed Regular 10"
theme.dark_blue_accent                          = "#ff22a5"
theme.dark_blue_main_light                      = "#4898f7"
theme.dark_blue_main_dark                       = "#4898f7"
theme.fg_normal                                 = theme.dark_blue_main_dark -- unselected text color, includes clock, cal etc.
theme.fg_focus                                  = theme.dark_blue_main_light
theme.bg_focus                                  = "#00000000" -- background color for taglist and clock, cal etc.
theme.bg_normal                                 = "#00000000" -- background color for the whole wibar
theme.fg_urgent                                 = "#000000" -- text color for alert
theme.bg_urgent                                 = theme.dark_blue_accent -- background color for alert
theme.systray_bg                                = "#000032" -- background for the systray (try to match to wallpaper, as this has not transparency)
theme.systray_icon_spacing                      = 2
theme.border_width                              = dpi(1)
theme.border_normal                             = theme.dark_blue_main_dark
theme.border_focus                              = theme.dark_blue_accent
theme.taglist_fg_focus                          = "#ffffff"
theme.tasklist_bg_normal                        = "#00000000"
theme.tasklist_bg_focus                         = theme.dark_blue_main_light
--theme.tasklist_fg_focus                         = theme.dark_blue_accent .. "00" -- color for selected task (needs to be transparent, but even then somehow has effect)
--theme.tasklist_fg_focus                         = "#ffffff" -- color for selected task (needs to be transparent, but even then somehow has effect)
theme.menu_height                               = dpi(20)
theme.menu_width                                = dpi(160)
theme.menu_icon_size                            = dpi(32)
theme.awesome_icon_launcher                     = theme.icon_dir .. "/awesome_icon.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = false
theme.tasklist_disable_task_name                = true
theme.useless_gap                               = dpi(6)
theme.gap_single_client                         = true
theme.master_width_factor                       = 0.5
theme.layout_machi                              = theme.icon_dir .. "/machi.png"
theme.layout_tile                               = theme.icon_dir .. "/tile.png"
theme.layout_fairv                              = theme.icon_dir .. "/fairv.png"
theme.layout_magnifier                          = theme.icon_dir .. "/magnifier.png"
theme.layout_centerwork                         = theme.icon_dir .. "/centerwork.png"
theme.layout_tilebottom                         = theme.icon_dir .. "/tilebottom.png"
theme.wibar_border_width                        = 2

theme.musicplr = string.format("%s -e ncmpcpp", awful.util.terminal)

local markup = lain.util.markup
local blue   = "#80CCE6"
local space3 = markup.font("Roboto 3", " ")

-- Clock
local mytextclock = wibox.widget.textclock(markup(theme.fg_normal, space3 .. "%H:%M:%S" .. markup.font("Roboto 4", " ")),1)
mytextclock.font = theme.font
local clockbg = wibox.container.background(mytextclock, theme.bg_focus, gears.shape.rectangle)
local clockwidget = wibox.container.margin(clockbg, dpi(0), dpi(0), dpi(5), dpi(5))

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
local battery_indicator = bat({
    icons = {
        full = theme.icon_dir .. "/Ic_battery_full_48px.svg",
        charging = theme.icon_dir .. "/Ic_battery_charging_full_48px.svg"
    },
    color = theme.dark_blue_main_dark,
    settings = function()
        widget.text_widget:set_markup(space3 .. markup.font(theme.font, string.format("%02d", bat_now.capacity)
                          .. "%") .. markup.font("Roboto 5", " "))
    end
})
battery_indicator.update()
local bat_widget = battery_indicator.widget

-- Pulseaudio volume arc
theme.volume = pulsearc({
    icon = theme.icon_dir .. "/audio-volume-high-symbolic.svg",
    colors = {
        icon       = theme.dark_blue_main_dark,
        unmute     = theme.dark_blue_main_light,
        mute       = theme.dark_blue_accent
    },
})
local volumewidget = wibox.container.margin(
    wibox.container.background(
        theme.volume.arc,
        theme.bg_focus,
        gears.shape.rectangle
    ),
    dpi(0),
    dpi(0),
    dpi(9),
    dpi(9)
)
volumewidget:connect_signal("button::press", function() awful.spawn.with_shell("pavucontrol") end)

-- CPU
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(space3 .. markup.font(theme.font, "💻 " .. string.format("%02d", cpu_now.usage)
                          .. "% ") .. markup.font("Roboto 5", " "))
    end
})
local cpuwidget = wibox.container.margin(
    wibox.container.background(
        cpu.widget,
        theme.bg_focus,
        gears.shape.rectangle
    ),
    dpi(0),
    dpi(0),
    dpi(8),
    dpi(5)
)
cpuwidget:connect_signal("button::press", function() awful.spawn.with_shell("alacritty -e htop") end)

-- Net
--local net = lain.widget.net({
--    settings = function()
--        widget:set_markup(markup.font(theme.font, "DOWN: " .. string.format("%07.1f", net_now.received)
--                          .. "  UP: " .. string.format("%07.1f", net_now.sent) .. "  " .. markup.font("Roboto 5", " ")))
--    end
--})
--local networkwidget = wibox.container.margin(
--    wibox.container.background(
--        net.widget,
--        theme.bg_focus,
--        gears.shape.rectangle
--    ),
--    dpi(0),
--    dpi(0),
--    dpi(5),
--    dpi(5)
--)

-- Launcher
--local mylauncher = awful.widget.button({ image = theme.awesome_icon_launcher })
--mylauncher:connect_signal("button::press", function() awful.util.mymainmenu:toggle() end)

local fadeout_timer

function theme.at_screen_connect(s)
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

    -- Helper function to create a border around a wibox
    local border_cont = function(border_box)
        local box = wibox.container.background(
            border_box,
            theme.bg_focus,
            function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 6) end
        )
        box.shape_border_width = theme.wibar_border_width
        box.shape_border_color = theme.border_normal
        box.bg = beautiful.bg_normal
        box.shape_clip = true
        return box
    end

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons, { bg_focus = theme.fg_focus })
    s.mytag = border_cont(wibox.container.margin(s.mytaglist, dpi(1), dpi(1), dpi(0), dpi(0)))

    -- Create a tasklist widget
    local mytasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = awful.util.tasklist_buttons,
        layout   = {
            spacing = 0,
            layout  = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    id     = 'clienticon',
                    widget = awful.widget.clienticon,
                },
                margins = 10,
                widget  = wibox.container.margin
            },
            id            = 'background_role',
            widget        = wibox.container.background,
            create_callback = function(self, c, index, objects)
                self:get_children_by_id('clienticon')[1].client = c
            end,
        },
    }
    s.mytasklist = border_cont(mytasklist)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(40) })

    -- Create systray
    s.mysystraywidget = wibox.widget.systray()
    beautiful.bg_systray = theme.systray_bg
    beautiful.systray_icon_spacing = theme.systray_icon_spacing
    mysystraycont = wibox.container.background(s.mysystraywidget, theme.bg_focus, gears.shape.rectangle)
    s.mysystray = wibox.container.margin(mysystraycont, dpi(0), dpi(4), dpi(10), dpi(10))
    -- systray will only be shown when systraybutton is pressed
    s.mysystray.visible = false
    s.mywibox:connect_signal('mouse::leave', function ()
        -- Hide systray
        s.mysystray.visible = false
    end)
    local systray_button = wibox.widget {
        text = "◀",
        widget = wibox.widget.textbox,
    }
    systray_button:buttons(gears.table.join(
        awful.button({}, 1, function()
            s.mysystray.visible = not s.mysystray.visible
        end)
    ))
    s.mysystraybutton = wibox.container.margin(systray_button, dpi(0), dpi(4), dpi(0), dpi(0))
    -- Only show systraybutton on primary screen, as the others are empty anyway
    s.mysystraybutton.visible = s == screen.primary
    s:connect_signal('primary_changed', function()
        s.mysystraybutton.visible = s == screen.primary
    end)

    -- Add widgets to the wibox
    s.mywibox:setup {
        {
            layout = wibox.layout.align.horizontal,
            s.mytag, -- Left widget
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = 4,
                border_cont(wibox.container.margin(bat_widget, 4, 4)),
                border_cont(wibox.container.margin(wibox.widget {
                    layout = wibox.layout.fixed.horizontal,
                    s.mysystray,
                    s.mysystraybutton,
                    cpuwidget,
                }, 8, 4)),
                border_cont(wibox.container.margin(volumewidget, 8, 8)),
                border_cont(wibox.container.margin(wibox.widget {
                    layout = wibox.layout.fixed.horizontal,
                    calendarwidget,
                    clockwidget,
                }, 8, 8)),
                border_cont(wibox.container.margin(s.mylayoutbox, 4, 4)),
            },
            expand = "none",
        },
        left = theme.useless_gap + dpi(3),
        right = theme.useless_gap + dpi(3),
        top = dpi(4),
        layout = wibox.container.margin,
    }
end

return theme
