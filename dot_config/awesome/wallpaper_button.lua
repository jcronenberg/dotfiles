local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- Wallpaper Widget Factory
local function create_wallpaper_widget(args)
    local wallpaper_popup

    local wallpapers = args.wallpapers
    local change_wallpaper = args.change_wallpaper
    local wallpaper_dir = args.wallpaper_dir
    local icon = args.icon
    local color = args.color

    local icon_widget = wibox.widget.imagebox(
        gears.color.recolor_image(icon, color),
        true,
        gears.shape.rectangle
    )

    -- Create the open button
    local open_popup_button = wibox.widget {
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

    -- Create a wallpaper entry with image and filename
    local function create_wallpaper_entry(path)
        local image_preview = wibox.widget {
            image  = gears.surface.load_uncached(wallpaper_dir .. path),
            resize = true,
            forced_width = 80,
            forced_height = 45,
            widget = wibox.widget.imagebox
        }

        local centered_image = wibox.widget {
            image_preview,
            halign = "center",
            valign = "center",
            widget = wibox.container.place
        }

        local label = wibox.widget {
            text = path,
            align = "center",
            widget = wibox.widget.textbox
        }

        local entry = wibox.widget {
            {
                centered_image,
                label,
                spacing = 4,
                layout = wibox.layout.fixed.vertical
            },
            margins = 6,
            widget = wibox.container.margin
        }

        -- On click: change wallpaper and hide popup
        entry:connect_signal("button::press", function()
            change_wallpaper(wallpaper_dir .. path)
            wallpaper_popup.visible = false
        end)

        return entry
    end

    -- Grid of thumbnails
    local grid_layout = wibox.layout.grid()
    grid_layout.spacing = 10
    grid_layout.forced_num_cols = 3

    for _, wp_path in ipairs(wallpapers) do
        grid_layout:add(create_wallpaper_entry(wp_path))
    end

    -- Popup containing the grid
    wallpaper_popup = awful.popup {
        widget = {
            {
                grid_layout,
                margins = 12,
                widget = wibox.container.margin
            },
            bg = beautiful.bg_normal,
            shape = gears.shape.rounded_rect,
            widget = wibox.container.background
        },
        border_color = beautiful.border_color or color,
        border_width = 2,
        bg = beautiful.bg_normal or "#00000000",
        placement = awful.placement.no_offscreen,
        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 6) end,
        visible = false,
        ontop = true
    }

    -- Toggle popup on button press
    open_popup_button:connect_signal("button::press", function()
        wallpaper_popup.visible = not wallpaper_popup.visible
    end)

    return open_popup_button
end

return create_wallpaper_widget
