i3-msg 'workspace 01; append_layout ~/.config/i3/workspace1.json'
snap run teams-for-linux &
firefox &
kitty --name work_scratchbook -o shell nvim scratchbook.txt release.txt &
