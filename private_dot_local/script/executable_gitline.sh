#!/bin/sh

if test -d .git || git rev-parse --git-dir >/dev/null 2>&1; then
	branch="$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"
	echo -n " $branch"

	ahead="$(git rev-list @{u}..HEAD 2>/dev/null | wc -l)"
	behind="$(git rev-list HEAD..@{u} 2>/dev/null | wc -l)"
	if [ $ahead -gt 0 ] && [ $behind -gt 0 ]; then
		echo -n "\e[91;7m↕$(($ahead + $behind))\e[m"
	elif [ $ahead -gt 0 ]; then
		echo -n "↑$ahead"
	elif [ $behind -gt 0 ]; then
		echo -n "↓$behind"
	fi

	# appending "." prevents an ending newline being stripped
	# this makes ou untracked calculation simpler
	status="$(git status --porcelain && echo '.')"
	if [ "$status" != "." ]; then
		echo -n "("
		len="$(echo "$status" | wc -l)"
		status="$(echo "$status" | grep -v '^??')"
		untracked="$(($len - $(echo "$status" | wc -l)))"

		if [ "$status" != "" ]; then
			staged="$(echo "$status" | grep '^\w' | wc -l)"
			unstaged="$(echo "$status" | grep '^.\w' | wc -l)"
			echo -n "\e[32m${staged#0}\e[31m${unstaged#0}"
		fi
		echo -n "\e[90m${untracked#0}\e[m)"
	fi

	stash="$(git stash list --porcelain | wc -l)"
	if [ "$stash" -gt 0 ]; then
		echo -n "{${stash}}"
	fi
fi

