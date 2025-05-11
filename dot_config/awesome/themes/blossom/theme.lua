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
local fancy_taglist = require("fancy_taglist")
local wallpaper_button = require("wallpaper_button")

local string, os = string, os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

-- Init theme
local theme = {}

-- Color handling
local colors = require("themes.colors")

local selected_color = "dark_blue"
local colorscheme = colors[selected_color]


-- Wallpaper handling
local wallpaper_dir = os.getenv("HOME") .. "/.config/awesome/themes/wallpapers/"

local function list_files_in_dir(dir_path)
    local files = {}
    local p = io.popen('find "' .. dir_path .. '" -maxdepth 1 -type f 2>/dev/null')
    if p then
        for file in p:lines() do
            local filename = file:match("^.*/(.*)$") or file
            table.insert(files, filename)
        end
        p:close()
    end
    return files
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

theme.wallpaper = wallpaper_dir .. "cloud_sundown.png"

-- Populate theme
theme.default_dir                               = require("awful.util").get_themes_dir() .. "default"
theme.icon_dir                                  = os.getenv("HOME") .. "/.config/awesome/themes/icons"
--theme.wallpaper                                 = os.getenv("HOME") .. "/.config/awesome/themes/blossom/wall.jpg"
--theme.wallpaper2                                = os.getenv("HOME") .. "/.config/awesome/themes/blossom/wall.jpg"
theme.font                                      = "Roboto Bold 10"
theme.taglist_font                              = "Roboto Condensed Regular 24"
theme.fg_normal                                 = colorscheme.main -- unselected text color, includes clock, cal etc.
theme.fg_focus                                  = colorscheme.main
theme.bg_focus                                  = "#00000000" -- background color for taglist and clock, cal etc.
theme.bg_normal                                 = "#00000000" -- background color for the whole wibar
theme.fg_urgent                                 = "#000000" -- text color for alert
theme.bg_urgent                                 = colorscheme.accent -- background color for alert
theme.systray_bg                                = "#000032" -- background for the systray (try to match to wallpaper, as this has not transparency)
theme.systray_icon_spacing                      = 2
theme.border_width                              = dpi(1)
theme.border_normal                             = "#000000A0"
theme.border_focus                              = colorscheme.main
theme.taglist_fg_focus                          = colorscheme.main
theme.tasklist_bg_normal                        = "#00000000"
theme.tasklist_bg_focus                         = colorscheme.main .. "A0"
--theme.tasklist_fg_focus                         = colorscheme.accent .. "00" -- color for selected task (needs to be transparent, but even then somehow has effect)
--theme.tasklist_fg_focus                         = "#ffffff" -- color for selected task (needs to be transparent, but even then somehow has effect)
theme.menu_height                               = dpi(20)
theme.menu_width                                = dpi(160)
theme.menu_icon_size                            = dpi(32)
theme.awesome_icon_launcher                     = theme.icon_dir .. "/awesome_icon.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = false
theme.tasklist_disable_task_name                = true
theme.useless_gap                               = dpi(2)
theme.gap_single_client                         = true
theme.master_width_factor                       = 0.5
theme.layout_machi                              = gears.color.recolor_image(theme.icon_dir .. "/machi.png", colorscheme.main)
theme.layout_tile                               = gears.color.recolor_image(theme.icon_dir .. "/tile.png", colorscheme.main)
theme.layout_fairv                              = gears.color.recolor_image(theme.icon_dir .. "/fairv.png", colorscheme.main)
theme.layout_magnifier                          = gears.color.recolor_image(theme.icon_dir .. "/magnifier.png", colorscheme.main)
theme.layout_centerwork                         = gears.color.recolor_image(theme.icon_dir .. "/centerwork.png", colorscheme.main)
theme.layout_tilebottom                         = gears.color.recolor_image(theme.icon_dir .. "/tilebottom.png", colorscheme.main)
theme.wibar_border_width                        = 2
theme.border_cont_bg                            = "#000000A0"
theme.notification_border_width                 = 2
theme.notification_border_color                 = colorscheme.main
theme.notification_shape                        = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 6) end

theme.musicplr = string.format("%s -e ncmpcpp", awful.util.terminal)

local markup = lain.util.markup
local blue   = "#80CCE6"
local space3 = markup.font("Roboto 3", " ")

function change_wallpaper(new_wallpaper_path)
    for s in screen do
        gears.wallpaper.maximized(new_wallpaper_path, s, true)
    end
end

-- Wallpaper button
local wallpaper_widget = wallpaper_button({
    wallpapers = list_files_in_dir(wallpaper_dir),
    change_wallpaper = change_wallpaper,
    wallpaper_dir = wallpaper_dir,
    icon = theme.icon_dir .. "/wallpaper_icon.svg",
    color = colorscheme.main,
})

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
        full = theme.icon_dir .. "/battery_full.svg",
        charging = theme.icon_dir .. "/battery_charging_full.svg"
    },
    color = colorscheme.main,
    settings = function()
        widget.text_widget:set_markup(space3 .. markup.font(theme.font, string.format("%02d", bat_now.capacity)
                          .. "%") .. markup.font("Roboto 5", " "))
    end
})
local bat_widget = battery_indicator.widget

-- Pulseaudio volume arc
theme.volume = pulsearc({
    icon = theme.icon_dir .. "/volume_high.svg",
    colors = {
        icon       = colorscheme.main,
        unmute     = colorscheme.main,
        mute       = colorscheme.accent
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
    dpi(4),
    dpi(4)
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

function theme.at_screen_connect(s)
    -- Per monitor wallpaper
    --theme.wallpapers = {theme.wallpaper1,
    --    	        theme.wallpaper2}

    ---- Wallpapers for specific outputs
    --local wallpapers = {}
    --wallpapers["DisplayPort-1"] = theme.wallpaper2
    --wallpapers["DisplayPort-0"] = theme.wallpaper1
    --wallpapers["HDMI-A-0"] = theme.wallpaper2

    --theme.wallpaper = function( s )
    --    -- match s.outputs to a output in wallpapers
    --    for output, wp in pairs(wallpapers) do
    --        for out, _ in pairs(s.outputs) do
    --            if out == output then
    --                return wp
    --            end
    --        end
    --    end
    --    -- default if output not in wallpapers
    --    return theme.wallpapers[2]
    --end

    ---- If wallpaper is a function, call it with the screen
    --local wallpaper = theme.wallpaper
    --if type(wallpaper) == "function" then
    --    wallpaper = wallpaper(s)
    --end

    gears.wallpaper.maximized(theme.wallpaper, s, true)

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
        box.shape_border_color = theme.border_focus
        box.bg = theme.border_cont_bg
        box.shape_clip = true
        return box
    end

    -- Create a taglist widget
    s.mytaglist = fancy_taglist.new({
        screen = s,
        taglist_buttons = awful.util.taglist_buttons,
        tasklist_buttons = awful.util.tasklist_buttons,
    })
    s.mytag = border_cont(wibox.container.margin(s.mytaglist, dpi(-2), dpi(-2), dpi(0), dpi(0)))

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(32) })

    -- Create systray
    s.mysystraywidget = wibox.widget.systray()
    beautiful.bg_systray = theme.systray_bg
    beautiful.systray_icon_spacing = theme.systray_icon_spacing
    mysystraycont = wibox.container.background(s.mysystraywidget, theme.bg_focus, gears.shape.rectangle)
    s.mysystray = wibox.container.margin(mysystraycont, dpi(0), dpi(4), dpi(6), dpi(6))
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

    local bat_cont = border_cont(wibox.container.margin(bat_widget, 4, 4))
    -- Will be made visible by the widget, this makes it so it is hidden when no battery is present
    bat_cont.visible = false
    bat_widget:connect_signal("visibility_changed", function()
        bat_cont.visible = bat_widget.visible
    end)

    -- Add widgets to the wibox
    s.mywibox:setup {
        {
            layout = wibox.layout.align.horizontal,
            --wibox.widget {}, -- Middle widget
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = 4,
                border_cont(wibox.container.margin(wallpaper_widget, 8, 8, 4)),
            },
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = 4,
                s.mytag,
            },
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = 4,
                bat_cont,
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
        left = theme.useless_gap + theme.useless_gap / 2,
        right = theme.useless_gap + theme.useless_gap / 2,
        top = dpi(4),
        layout = wibox.container.margin,
    }
end

return theme
