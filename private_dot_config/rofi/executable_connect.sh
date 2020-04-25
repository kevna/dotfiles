#!/bin/bash
if [[ -z "$@" ]]; then
	# echo -en "\0markup-rows\x1ftrue\n" # Turn on markup
	# Make sure that the vpn is up otherwise we'll timeout trying to connect
	if [[ ! -e "/proc/sys/net/ipv4/conf/tun0" ]]; then
		echo -en "\0message\x1fActivating VPN...\n"
		nmcli con up id ST_VPN >/dev/null &
	fi
	# Identify the devbox to connect too
	printf "10.4.%s.1\n" {2..49} 55 98 99 222
else
	# PS1=\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$
	# cmd="env EDITOR=vim sudo tmux new -As $sessionname || sudo -i"
	# cmd="sudo bash -li <<< ' export EDITOR=\"vim\" TERM=rxvt-unicode-256color; cd /usr/local/ST; svn st; shortstatus.sh || svn info; exec </dev/tty;'"
	# cmd="env EDITOR=vim TERM=rxvt-unicode-256color sudo bash -li <<< ' cd /usr/local/ST; shortstatus.sh -v; export PS1=\"\[\a\e[91m\]\u\[\e[90m\]@\[\e[95m\]\h\[\e[90m\]:\[\e[96m\]\w\[\e[91m\]\\\${?#0}\[\e[m\]\\\\$ \"; exec</dev/tty'"
	# urxvtcd --name "ssh" -e ssh "ops@$@" -ttt "$cmd"
	cmd="env EDITOR=vim sudo bash -li <<< ' cd /usr/local/ST; clear; shortstatus.py -vc 2>/dev/null || shortstatus.sh -nv; export TERM=xterm-256color COLORTERM=truecolor PROMPT_COMMAND=\"PS_ERR=\\\${?#0}\" PS1=\"\[\a\e[91m\]\u\[\e[90m\]@\[\e[92m\]\h\[\e[90m\]:\[\e[94m\]\w\[\e[91m\]\\\${PS_ERR:-\[\e[92m\]0}\[\e[m\]\\\\$ \"; exec</dev/tty'"
	coproc (kitty --name "work_ssh$@" -o shell ssh "ops@$@" -ttt "$cmd" &)
fi
