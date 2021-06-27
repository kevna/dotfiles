local awful = require("awful")
local gears = require("gears")
-- Widget and layout library
local wibox = require("wibox")

local bindings = require("bindings")

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = require("menu").mainmenu })

-- {{{ Wibar
local battery_monitor = awful.widget.watch("acpi", 30,
    function(widget, stdout)
        percentage = string.match(stdout, "%d+%%")
        remaining = string.match(stdout, "%d+:%d+")
        widget:set_text(percentage .. " " .. remaining)
    end)

-- Create a textclock widget
local mytextclock = wibox.widget.textclock(" %F %H:%M ")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ bindings.modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ bindings.modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.set(beautiful.bg_normal)
        -- gears.wallpaper.maximized(wallpaper, s, true)
    end
end

local function get_layouts(s)
    local layouts
    if s.geometry.height > s.geometry.width then
        -- Portrait display
        layouts = {
            awful.layout.suit.tile.bottom,
            awful.layout.suit.tile.top,
            awful.layout.suit.fair.horizontal,
            -- awful.layout.suit.spiral.dwindle,
            awful.layout.suit.corner.nw,
        }
    else
        -- Landscape display
        layouts = {
            awful.layout.suit.tile,
            awful.layout.suit.tile.left,
            awful.layout.suit.fair,
            awful.layout.suit.spiral.dwindle,
            awful.layout.suit.corner.nw,
        }
    end
    return layouts
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    set_wallpaper(s)
    s.layouts = get_layouts(s)
    for tag in screen.tags do
        awful.layout.set(s.layouts[1], t)
    end
end)
--
-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    s.layouts = get_layouts(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, s.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () utils.screen_layout_inc( 1, s) end),
                           awful.button({ }, 3, function () utils.screen_layout_inc(-1, s) end),
                           awful.button({ }, 4, function () utils.screen_layout_inc( 1, s) end),
                           awful.button({ }, 5, function () utils.screen_layout_inc(-1, s) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            battery_monitor,
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}
