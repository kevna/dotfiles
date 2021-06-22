local awful = require("awful")


local function screen_layout_inc(i, s)
    s = s or awful.screen.focused()
    awful.layout.inc(i, s, s.layouts)
end


return {
    screen_layout_inc = screen_layout_inc,
}
