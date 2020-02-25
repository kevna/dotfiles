#!/bin/bash
xmodmap - <<END
remove Lock = Caps_Lock
remove Control = Control_L
keysym Caps_Lock = Control_L
add Lock = Caps_Lock
add Control = Control_L
END
xcape -e 'Shift_L=Shift_L|9;Shift_R=Shift_R|0;Control_L=Escape'
