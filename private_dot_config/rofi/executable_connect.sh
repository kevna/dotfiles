#!/bin/bash
if [[ -z "$@" ]]; then
	# echo -en "\0markup-rows\x1ftrue\n" # Turn on markup
	# Make sure that the vpn is up otherwise we'll timeout trying to connect
	if [[ ! -e "/proc/sys/net/ipv4/conf/tun0" ]]; then
		echo -e "\0message\x1fActivating VPN..."
		nmcli con up id ST_VPN >/dev/null &
	fi
	echo -e "\0markup-rows\x1ftrue\n"
	# Identify the devbox to connect too
	# printf "10.4.%s.1\n" {2..49} 55 {62..72} 98 99 222
	for box in {2..49} 55 {62..72} 98 99 222; do
		printf "<tt>10.4.%s.1</tt> <span size='smaller' style='italic'>Dev%s</span>\n" $box $box
	done
	echo "<tt>10.35.12.193</tt> <span size='smaller' style='italic'>Dev50</span>"
	echo "<tt>10.35.12.235</tt> <span size='smaller' style='italic'>Dev51</span>"
	echo "<tt>10.4.201.1</tt> <span size='smaller' style='italic'>build1</span>"
	echo "<tt>10.4.202.1</tt> <span size='smaller' style='italic'>build2</span>"
	echo "<tt>10.4.203.1</tt> <span size='smaller' style='italic'>build3</span>"
	echo "<tt>10.4.204.1</tt> <span size='smaller' style='italic'>build4</span>"
	echo "<tt>10.4.205.1</tt> <span size='smaller' style='italic'>build5</span>"
	echo "<tt>10.240.5.111</tt> <span size='smaller' style='italic'>build105</span>"
	echo "<tt>10.240.6.111</tt> <span size='smaller' style='italic'>build106</span>"
else
	# PS1=\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$
	# cmd="env EDITOR=vim sudo tmux new -As $sessionname || sudo -i"
	# cmd="sudo bash -li <<< ' export EDITOR=\"vim\" TERM=rxvt-unicode-256color; cd /usr/local/ST; svn st; shortstatus.sh || svn info; exec </dev/tty;'"
	# cmd="env EDITOR=vim TERM=rxvt-unicode-256color sudo bash -li <<< ' cd /usr/local/ST; shortstatus.sh -v; export PS1=\"\[\a\e[91m\]\u\[\e[90m\]@\[\e[95m\]\h\[\e[90m\]:\[\e[96m\]\w\[\e[91m\]\\\${?#0}\[\e[m\]\\\\$ \"; exec</dev/tty'"
	# urxvtcd --name "ssh" -e ssh "ops@$@" -ttt "$cmd"
	ip=$@
	if [[ "$@" =~ "<tt>" ]]; then
		ip=$(echo $ip | awk -F'</?tt>' '{print $2}')
	fi
	if [[ "$ip" =~ "@" ]]; then
		user=${ip%%@*}
	else
		user="ops"
	fi
	ip=${ip##*@}
	jump=""
	shell="bash -li"
	cmd="export EDITOR=vim TERM=xterm-256color COLORTERM=truecolor PROMPT_COMMAND=\"PS_ERR=\\\${?#0}\" PS1=\"\[\a\e[91m\]\u\[\e[90m\]@\[\e[92m\]\h\[\e[90m\]:\[\e[94m\]\w\[\e[91m\]\\\${PS_ERR:-\[\e[92m\]0}\[\e[m\]\\\\$ \""
	if [[ "$user" == "ops" ]]; then
		shell="sudo $shell"
		cmd="cd /usr/local/ST; clear; shortstatus.py -vc 2>/dev/null || shortstatus.sh -nv; $cmd"
	fi
	if [[ "$ip" != 10.4.* ]]; then
		jump="-J ops@10.4.28.1"
	fi
	coproc (kitty --name "work_ssh$ip" -o shell ssh $jump "$user@$ip" -ttt "$shell <<< ' $cmd; exec</dev/tty'" &)
fi
