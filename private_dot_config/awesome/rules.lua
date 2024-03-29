local awful = require("awful")

local bindings = require("bindings")


return {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     titlebars_enabled = false,
                     raise = true,
                     keys = bindings.clientkeys,
                     buttons = bindings.clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    {
      rule = {
        class = "Microsoft Teams",
        type = "notification",
      },
      properties = {
        floating = true,
        titlebars_enabled = false,
        focus = false,
        skip_decoration = true,
        skip_taskbar = true,
        ontop = true,
        sticky = true,
      },
    },

    {
      rule = {
        class = "Firefox",
        instance = "Toolkit",
        -- Name isn't always set before the manage signal, which results in unreliable matching
        -- name = "Picture-in-Picture",
      },
      properties = {
        sticky = true,
        floating = true,
        titlebars_enabled = false,
      },
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
