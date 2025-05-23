--[[

     Awesome WM configuration template
     github.com/lcpz

--]]

-- Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
--local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
                      require("awful.hotkeys_popup.keys")
local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi           = require("beautiful.xresources").apply_dpi

-- Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

-- Autostart windowless processes

-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

run_once({ "unclutter -root" }) -- entries must be separated by commas

-- This function implements the XDG autostart specification
--[[
awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
    'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)
--]]
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end


-- Theme stuff
local themes = {
    "holo",
    "tron",
    "neon",
    "dark_blue",
    "blossom",
}

local theme_file   = os.getenv("HOME") .. "/.cache/awesome/current_theme"
local chosen_theme = themes[5]

function read_file(file_name)
    local file = io.open(theme_file)
    if not file then
        return
    end
    local file_content = file:read("*l")
    file:close()
    return file_content
end

function get_current_theme_name()
    local new_theme = read_file(theme_file)
    if has_value(themes, new_theme) then
        chosen_theme = new_theme
    end
end

function set_next_theme()
    local file = io.open(theme_file, "w")
    local next_theme
    for i, name in ipairs(themes) do
        if name == chosen_theme then
            next_theme = themes[i % #themes + 1]
            break
        end
    end
    if file then
        file:write(next_theme)
        file:close()
    else
        print("Failed to open the theme file for writing!")
    end
    awesome.restart()
end

function set_prev_theme()
    local file = io.open(theme_file, "w")
    local next_theme
    for i, name in ipairs(themes) do
        if name == chosen_theme then
            next_theme = themes[i % #themes - 1]
            break
        end
    end
    if file then
        file:write(next_theme)
        file:close()
    else
        print("Failed to open the theme file for writing!")
    end
    awesome.restart()
end
get_current_theme_name()

-- Variable definitions
local modkey       = "Mod4"
local altkey       = "Mod1"
local terminal     = "alacritty"
local vi_focus     = false -- vi-like client focus - https://github.com/lcpz/awesome-copycats/issues/275
local cycle_prev   = true -- cycle trough all previous client or just the first -- https://github.com/lcpz/awesome-copycats/issues/274
local editor       = os.getenv("EDITOR") or "nvim"
local gui_editor   = os.getenv("GUI_EDITOR") or "kate"
local browser      = os.getenv("BROWSER") or "firefox"
local scrlocker    = "slock"

awful.util.terminal = terminal
awful.util.tagnames = { "●", "○", "○" }
awful.util.layouts = { awful.layout.suit.tile, awful.layout.suit.tile.bottom, awful.layout.suit.fair }
local machi = require("layout-machi")
awful.layout.layouts = {
    --awful.layout.suit.floating,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
    --lain.layout.cascade,
    --lain.layout.cascade.tile,
    lain.layout.centerwork,
    --lain.layout.centerwork.horizontal,
    --lain.layout.termfair,
    --lain.layout.termfair.center,
    --machi.default_layout,
    machi.layout.create{ new_placement_cb = function(c, instance, areas, geometry)
        -- Extremely specific, but this works around a issue with the debug build spawned from
        -- the godot editor. It wants to position the window, which messes with the empty
        -- area selection of machi. This makes it so the placement gets deferred until later
        -- so the godot placement shenanigans are done.
        -- (c.name seems to be "Godot" on startup and only gets changed to the proper title afterwards)
        if c.instance == "Godot_Engine" and c.name == "Godot" then
            gears.timer {
                timeout = 1,
                autostart = true,
                single_shot = true,
                callback = function()
                    -- This modifies geometry
                    machi.layout.placement.empty(c, instance, areas, geometry)
                    -- And we can then apply it to the client
                    -- I have absolutely no clue why this isn't done automatically, but hey it works
                    c:geometry(geometry)
                end
            }
        else
            machi.layout.placement.empty(c, instance, areas, geometry)
        end
    end },
}

-- define monitor specific tags
--monitor_tags = {}
--monitor_layouts = {}
--monitor_tags[3840] = { "Email", "VMs", "Other" }
--monitor_layouts[3840] = { awful.layout.suit.fair, awful.layout.suit.fair, awful.layout.suit.fair }
--monitor_tags[1080] = { "Music", "Other" }
--monitor_layouts[1080] = { awful.layout.suit.fair, awful.layout.suit.fair }
--monitor_tags[1920] = { "Email", "VMs", "Music", "Other" }
--monitor_layouts[1920] = { awful.layout.suit.fair, awful.layout.suit.fair, awful.layout.suit.fair, awful.layout.suit.fair }
monitor_extra_tags = {}
monitor_extra_tags[3840] = 2

awful.util.taglist_buttons = my_table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

beautiful.tasklist_disable_icon = true
awful.util.tasklist_buttons = my_table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            --c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 2, function (c) c:kill() end),
    awful.button({ }, 3, function ()
        local instance = nil

        return function ()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({theme = {width = dpi(250)}})
            end
        end
    end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = dpi(2)
lain.layout.cascade.tile.offset_y      = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))


-- Menu
local myawesomemenu = {
    { "Hotkeys", function() return false, hotkeys_popup.show_help end },
    { "Manual", terminal .. " -e man awesome" },
    { "Edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "Restart awesome", awesome.restart },
    { "Quit awesome", function() awesome.quit() end }
}
local mypowermenu = {
    { "Suspend", function() awful.spawn('systemctl suspend') end },
    { "Shutdown", function() awful.spawn('systemctl poweroff') end },
    { "Restart", function() awful.spawn('systemctl reboot') end },
    { "Logout", function() awesome.quit() end },
}
awful.util.mymainmenu = freedesktop.menu.build({
    icon_size = beautiful.menu_height or dpi(16),
    --before = {
    --    { "Awesome", myawesomemenu, beautiful.awesome_icon },
    --    -- other triads can be put here
    --},
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
        { "Power Options", mypowermenu },
    }
})
-- hide menu when mouse leaves it
--awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function() awful.util.mymainmenu:hide() end)

--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it


-- Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)

-- No borders when rearranging only 1 non-floating or maximized client
--screen.connect_signal("arrange", function (s)
--    --local only_one = #s.tiled_clients == 1
--    for _, c in pairs(s.clients) do
--        --if only_one and not c.floating or c.maximized then
--        if c.maximized then
--            c.border_width = 0
--        else
--            c.border_width = beautiful.border_width
--        end
--    end
--end)
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
    -- wibox
    beautiful.at_screen_connect(s)
    -- Add monitor specific tags
    --for output, tags in pairs(monitor_tags) do
    --    if output == s.workarea.width then
    --        for i, tag in ipairs(tags) do
    --            awful.tag.add(tag, { layout = monitor_layouts[output][i],
    --    	    	          screen = s, selected = false } )
    --        end
    --    end
    --end
    for output, amount in pairs(monitor_extra_tags) do
        if output == s.workarea.width then
            for i=1,amount do
                awful.tag.add("○", { layout = awful.layout.layouts[1], screen = s })
            end
        end
    end

    -- Update tag labels based on selection
    s:connect_signal("tag::history::update", function()
        for i, t in ipairs(s.tags) do
            if t.selected then
                t.name = "●"
            else
                t.name = "○"
            end
        end
    end)
    --if s.index <= #monitor_tags then
    --    for i, name in ipairs(monitor_tags[s.index].names) do
    --        awful.tag.add(name, { layout = awful.layout.layouts[1],
    --    		screen = s, selected = false } )
    --    end
    --end
    -- quake setup
    s.quake = lain.util.quake({
        app = "alacritty",
        argname = "--title %s",
        extra = string.format("--config-file %s/.config/alacritty/alacritty_quake.toml --class QuakeDD -e tmux", os.getenv("HOME")),
        visible = false,
        followtag = true,
        overlap = true,
        height = 0.6,
        border = dpi(1),
    })
    -- Hide wibox by default on DreamDeck screen
    for out, _ in pairs(s.outputs) do
        if out == "HDMI-A-0" then s.mywibox.visible = not s.mywibox.visible end
    end
end)


-- Mouse bindings
root.buttons(my_table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end)
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))


-- machi stuff
local editor = machi.editor.create()
-- machina
-- Unfortunately machina seems to mess with floating windows
--local machina = require('machina')()
--local machina_methods = require("machina.methods")
-- Key bindings
globalkeys = my_table.join(
    -- machi
    awful.key({modkey}, "/", editor.start_interactive, {description = "open machi editor", group = "machi"}),
    awful.key({altkey}, "/", function () machi.switcher.start() end, {description = "open machi switcher", group = "machi"}),

    -- machina
    --awful.key({altkey}, "Tab", machina_methods.shuffle("backward"),
    --          {description = "shuffle in group", group = "machina"}),
    --awful.key({modkey}, "Tab", machina_methods.shuffle("backward"),
    --          {description = "shuffle in group", group = "machina"}),
    --awful.key({altkey}, "[", machina_methods.my_shifter("backward"),
    --          {description = "shift backward", group = "machina"}),
    --awful.key({altkey}, "]", machina_methods.my_shifter("forward"),
    --          {description = "shift forward", group = "machina"}),
    --awful.key({altkey, "Shift"}, "[", machina_methods.my_shifter("backward", "swap"),
    --          {description = "swap backward", group = "machina"}),
    --awful.key({altkey, "Shift"}, "]", machina_methods.my_shifter("forward", "swap"),
    --          {description = "swap forward", group = "machina"}),

    ---- move
    --awful.key({modkey, "Shift"}, "h", machina_methods.shift_by_direction("left"),
    --          {description = "shift left", group = "machina move"}),
    --awful.key({modkey, "Shift"}, "j", machina_methods.shift_by_direction("down"),
    --          {description = "shift down", group = "machina move"}),
    --awful.key({modkey, "Shift"}, "k", machina_methods.shift_by_direction("up"),
    --          {description = "shift up", group = "machina move"}),
    --awful.key({modkey, "Shift"}, "l", machina_methods.shift_by_direction("right"),
    --          {description = "shift right", group = "machina move"}),

    ---- swap
    --awful.key({modkey, "Control"}, "h", machina_methods.shift_by_direction("left", "swap"),
    --          {description = "swap left", group = "machina swap"}),
    --awful.key({modkey, "Control"}, "j", machina_methods.shift_by_direction("down", "swap"),
    --          {description = "swap down", group = "machina swap"}),
    --awful.key({modkey, "Control"}, "k", machina_methods.shift_by_direction("up","swap"),
    --          {description = "swap up", group = "machina swap"}),
    --awful.key({modkey, "Control"}, "l", machina_methods.shift_by_direction("right", "swap"),
    --          {description = "swap right", group = "machina swap"}),

    ---- expand
    --awful.key({altkey, "Shift"}, "h", machina_methods.expand_horizontal("left"),
    --          {description = "expand left", group = "machina expand"}),
    --awful.key({altkey, "Shift"}, "l", machina_methods.expand_horizontal("right"),
    --          {description = "expand right", group = "machina expand"}),
    --awful.key({altkey, "Shift"}, "j", machina_methods.expand_vertical("down"),
    --          {description = "expand down", group = "machina expand"}),
    --awful.key({altkey, "Shift"}, "k", machina_methods.expand_vertical("up"),
    --          {description = "expand up", group = "machina expand"}),

    -- X screen locker
    --awful.key({ altkey, "Control" }, "l", function () os.execute("i3lock -i /home/jorik/.config/awesome/themes/" .. chosen_theme .. "/dual_lock.png") end,
    awful.key({ altkey, "Control" }, "l", function () os.execute("betterlockscreen -l blur") end,
              {description = "lock screen", group = "hotkeys"}),

    -- Hotkeys
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description = "show help", group="awesome"}),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    -- awful.key({ modkey,           }, "Tab",
    --     function ()
    --         if cycle_prev then
    --             awful.client.focus.history.previous()
    --         else
    --             awful.client.focus.byidx(-1)
    --         end
    --         if client.focus then
    --             client.focus:raise()
    --         end
    --     end,
    --     {description = "cycle with previous/go back", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey, "Shift" }, "b", function ()
            for s in screen do
                for out, _ in pairs(s.outputs) do
                    if out ~= "HDMI-A-0" then goto continue end
                end
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
                ::continue::
            end
        end,
        {description = "toggle wibox only on HDMI-A-0", group = "awesome"}),
    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
            for s in screen do
                s.mywibox.visible = not s.mywibox.visible
                if s.mybottomwibox then
                    s.mybottomwibox.visible = not s.mybottomwibox.visible
                end
            end
        end,
        {description = "toggle wibox", group = "awesome"}),

    -- Dynamic tagging
    awful.key({ modkey, "Shift" }, "n", function () awful.tag.add("●", { layout = awful.layout.layouts[1], screen = awful.screen.focused() }):view_only() end,
              {description = "add new tag", group = "tag"}),
    awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end,
              {description = "rename tag", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end,
              {description = "move tag to the left", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end,
              {description = "move tag to the right", group = "tag"}),
    awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end,
              {description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ altkey, "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ altkey, "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),

    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Quake terminal
    awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end,
              {description = "launch quake terminal", group = "launcher"}),

    -- Brightness
    awful.key({ }, "XF86MonBrightnessUp", function () os.execute("xbacklight -inc 10") end,
              {description = "+10%", group = "hotkeys"}),
    awful.key({ }, "XF86MonBrightnessDown", function () os.execute("xbacklight -dec 10") end,
              {description = "-10%", group = "hotkeys"}),

    -- ALSA volume control
    awful.key({ altkey }, "Up",
        function ()
            os.execute("pamixer --increase 10")
            beautiful.volume.update()
        end,
        {description = "volume up", group = "hotkeys"}),
    awful.key({ altkey }, "Down",
        function ()
            os.execute("pamixer --decrease 10")
            beautiful.volume.update()
        end,
        {description = "volume down", group = "hotkeys"}),
    awful.key({ altkey }, "m",
        function ()
            os.execute("pamixer --toggle-mute")
            beautiful.volume.update()
        end,
        {description = "toggle mute", group = "hotkeys"}),
    awful.key({ altkey, "Control" }, "m",
        function ()
            os.execute("pamixer --set-volume 100")
            beautiful.volume.update()
        end,
        {description = "volume 100%", group = "hotkeys"}),
    awful.key({ altkey, "Control" }, "0",
        function ()
            os.execute("pamixer --set-volume 0")
            beautiful.volume.update()
        end,
        {description = "volume 0%", group = "hotkeys"}),

    -- Copy primary to clipboard (terminals to gtk)
    -- awful.key({ modkey }, "c", function () awful.spawn.with_shell("xsel | xsel -i -b") end,
    --           {description = "copy terminal to gtk", group = "hotkeys"}),
    -- Copy clipboard to primary (gtk to terminals)
    -- awful.key({ modkey }, "v", function () awful.spawn.with_shell("xsel -b | xsel") end,
    --           {description = "copy gtk to terminal", group = "hotkeys"}),

    -- Default
    --[[ Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end,
    --           {description = "show the menubar", group = "launcher"})
    --]]
    --[[ dmenu
    -- awful.key({ modkey }, "x", function ()
    --         os.execute(string.format("dmenu_run -i -fn 'Monospace' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
    --         beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
    --     end,
    --     {description = "show dmenu", group = "launcher"})
    --]]
    -- alternatively use rofi, a dmenu-like application with more features
    -- check https://github.com/DaveDavenport/rofi for more details
    -- rofi
    awful.key({ modkey }, "r", function ()
           awful.spawn.with_shell("rofi -show combi -theme ~/.config/rofi/themes/holo.rasi")
        end,
        {description = "show rofi combi", group = "launcher"}),
    awful.key({ modkey }, "t", function ()
           awful.spawn.with_shell("rofi -show window -theme ~/.config/rofi/themes/holo.rasi")
        end,
        {description = "show rofi windows", group = "launcher"}),
    awful.key({ modkey }, "e", function ()
           awful.spawn.with_shell("clipctl disable; bwmenu -c 10 -- -matching normal; clipctl enable")
        end,
        {description = "show rofi bitwarden", group = "launcher"}),
    awful.key({ modkey }, "g", function ()
           awful.spawn.with_shell("CM_LAUNCHER=rofi clipmenu -p clipboard")
        end,
        {description = "show rofi clipboard", group = "launcher"}),

    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run {
    --                 prompt       = "Run Lua code: ",
    --                 textbox      = awful.screen.focused().mypromptbox.widget,
    --                 exe_callback = awful.util.eval,
    --                 history_path = awful.util.get_cache_dir() .. "/history_eval"
    --               }
    --           end,
    --           {description = "lua execute prompt", group = "awesome"})
    --]]
    awful.key({ modkey, "Shift" }, "p", function ()
            -- Desired dimensions
            -- If something in e.g. firefox changes adjust these values
            local desired_width = 1920
            local desired_height = 1176

            -- Get the currently focused (active) window
            local c = client.focus

            if c then
                local wa = c.screen.workarea

                -- Set the master width factor
                local new_mwfact = (desired_width - (4 * beautiful.useless_gap) - 1) / wa.width
                c.screen.selected_tag.master_width_factor = new_mwfact

                -- Set the client's height
                local hfact = (desired_height + (4 * beautiful.useless_gap)) / wa.height
                awful.client.setwfact(hfact, c)
            end
        end,
        {description = "set firefox window to 1080p plus tabbar", group = "layout"}),
    awful.key({ modkey, "Control" }, "m", function ()
           awful.spawn.with_shell("sh ~/.screenlayout/main.sh")
        end,
        {description = "apply monitor layout main", group = "screen"}),
    awful.key({ modkey, "Control" }, "i", set_next_theme,
        {description = "next theme", group = "screen"}),
    awful.key({ modkey, "Control" }, "o", set_prev_theme,
        {description = "prev theme", group = "screen"})
)

clientkeys = my_table.join(
    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client,
              {description = "magnify client", group = "client"}),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    -- awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
    --           {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",
        function (c)
            local new_index = c.screen.index + 1
            if new_index > screen.count() then
                new_index = 1
            end
            for s in screen do
                if s.index == new_index then
                    for out, _ in pairs(s.outputs) do
                        if out == "HDMI-A-0" then
                            new_index = new_index + 1
                        end
                    end
                end
            end
            c.move_to_screen(c, new_index)
        end,
              {description = "move to screen (ignore Macroboard monitor)", group = "client"}),
    awful.key({ modkey, "Shift" }, "o",
        function (c)
            c.move_to_screen(c, new_index)
        end,
              {description = "move to screen", group = "client"}),
    awful.key({ altkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = {description = "view tag #", group = "tag"}
        descr_toggle = {description = "toggle tag #", group = "tag"}
        descr_move = {description = "move focused client to tag #", group = "tag"}
        descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
    end
    globalkeys = my_table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  descr_view),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  descr_toggle),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  descr_move),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  descr_toggle_focus)
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)


-- Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Titlebars
    --{ rule_any = { type = { "dialog", "normal" } },
    --  properties = { titlebars_enabled = true } },

    { rule = { class = "DreamDeck" },
      properties = { border_width = dpi(0) } },
}


-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end
    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
    -- rounded corners
    c.shape = function(cr,w,h)
        gears.shape.rounded_rect(cr,w,h,6)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
--client.connect_signal("request::titlebars", function(c)
--    -- Custom
--    if beautiful.titlebar_fun then
--        beautiful.titlebar_fun(c)
--        return
--    end
--
--    -- Default
--    -- buttons for the titlebar
--    local buttons = my_table.join(
--        awful.button({ }, 1, function()
--            c:emit_signal("request::activate", "titlebar", {raise = true})
--            awful.mouse.client.move(c)
--        end),
--        awful.button({ }, 2, function() c:kill() end),
--        awful.button({ }, 3, function()
--            c:emit_signal("request::activate", "titlebar", {raise = true})
--            awful.mouse.client.resize(c)
--        end)
--    )
--
--    awful.titlebar(c, {size = dpi(16)}) : setup {
--        { -- Left
--            awful.titlebar.widget.iconwidget(c),
--            buttons = buttons,
--            layout  = wibox.layout.fixed.horizontal
--        },
--        { -- Middle
--            { -- Title
--                align  = "center",
--                widget = awful.titlebar.widget.titlewidget(c)
--            },
--            buttons = buttons,
--            layout  = wibox.layout.flex.horizontal
--        },
--        { -- Right
--            awful.titlebar.widget.floatingbutton (c),
--            awful.titlebar.widget.maximizedbutton(c),
--            awful.titlebar.widget.stickybutton   (c),
--            awful.titlebar.widget.ontopbutton    (c),
--            awful.titlebar.widget.closebutton    (c),
--            layout = wibox.layout.fixed.horizontal()
--        },
--        layout = wibox.layout.align.horizontal
--    }
--end)

-- Enable sloppy focus, so that focus follows mouse.
--client.connect_signal("mouse::enter", function(c)
--    c:emit_signal("request::activate", "mouse_enter", {raise = vi_focus})
--end)
--
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- possible workaround for tag preservation when switching back to default screen:
-- https://github.com/lcpz/awesome-copycats/issues/251


-- Theme stuff
beautiful.notification_icon_size = 20

-- Autostart
awful.spawn.with_shell("~/bin/startup")
