-- Source: https://gist.github.com/intrntbrn/08af1058d887f4d10a464c6f272ceafa
-- awesomewm fancy_taglist: a taglist that contains a tasklist for each tag.

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local dpi   = require("beautiful.xresources").apply_dpi

local module = {}

local generate_filter = function(t)
    return function(c, scr)
        local ctags = c:tags()
        for _, v in ipairs(ctags) do
            if v == t then
                return true
            end
        end
        return false
    end
end

local fancytasklist = function(cfg, t)
    return awful.widget.tasklist({
            screen = cfg.screen or awful.screen.focused(),
            filter = generate_filter(t),
            buttons = cfg.tasklist_buttons,
            layout = {
                spacing = 1,
                layout = wibox.layout.fixed.horizontal
            },
            widget_template = {
                {
                    {
                        id     = 'clienticon',
                        widget = awful.widget.clienticon,
                    },
                    margins = 6,
                    widget  = wibox.container.margin
                },
                id     = 'background_role',
                widget = wibox.container.background,
                create_callback = function(self, c, _, _)
                    self:get_children_by_id("clienticon")[1].client = c
                    --awful.tooltip({
                    --	objects = { self },
                    --	timer_function = function()
                    --		return c.name
                    --	end,
                    --})
                end,
            },
    })
end

function module.new(config)
    local cfg = config or {}

    local s = cfg.screen or awful.screen.focused()
    local taglist_buttons = cfg.taglist_buttons

    return awful.widget.taglist({
            screen = s,
            filter = awful.widget.taglist.filter.all,
            widget_template = {
                {
                    {
                        -- tag
                        {
                            id = "tag_margin",
                            widget = wibox.container.margin,
                            left = 4,
                            bottom = dpi(2),
                            {
                                id = "text_role",
                                widget = wibox.widget.textbox,
                                align = "center",
                            },
                        },
                        {
                            id = "tasklist_margin",
                            widget = wibox.container.margin,
                            left = 2,
                            right = 4,
                            -- tasklist
                            {
                                id = "tasklist_placeholder",
                                layout = wibox.layout.fixed.horizontal,
                            },
                        },
                        layout = wibox.layout.fixed.horizontal,
                    },
                    id = "background_role",
                    widget = wibox.container.background,
                },
                layout = wibox.layout.fixed.horizontal,
                create_callback = function(self, _, index, _)
                    local t = s.tags[index]
                    self:get_children_by_id("tasklist_placeholder")[1]:add(fancytasklist(cfg, t))
                end,
            },
            buttons = taglist_buttons,
    })
end

return module
