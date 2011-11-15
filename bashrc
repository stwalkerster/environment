## /etc/bashrc

# System wide functions and aliases
# Environment stuff goes in /etc/profile

# By default, we want this to get set.
# Even for non-interactive, non-login shells.
if [ $UID -gt 99 ] && [ "`id -gn`" = "`id -un`" ]; then
	umask 002
else
	umask 022
fi

# are we an interactive shell?
if [ "$PS1" ]; then
    case $TERM in
	xterm*)
		if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
			PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
		else
	    	PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}"; echo -ne "\007"'
		fi
		;;
	screen)
		if [ -e /etc/sysconfig/bash-prompt-screen ]; then
			PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
		else
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}"; echo -ne "\033\\"'
		fi
		;;
	*)
		[ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
	    ;;
    esac
    # Turn on checkwinsize
    shopt -s checkwinsize
    [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "
fi

if ! shopt -q login_shell ; then # We're not a login shell
	# Need to redefine pathmunge, it get's undefined at the end of /etc/profile
    pathmunge () {
		if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
			if [ "$2" = "after" ] ; then
				PATH=$PATH:$1
			else
				PATH=$1:$PATH
			fi
		fi
	}

	for i in /etc/profile.d/*.sh; do
		if [ -r "$i" ]; then
			. $i
	fi
	done
	unset i
	unset pathmunge
fi
# vim:ts=4:sw=4


. ~/environment/bash-completion-git

# colour prompt:
#PS1="\[\e]0;\u@\h: \w\a\]\e[m[\e[1;31m\t\e[m][\e[1;32m\u@\H\e[m:\e[1;34m\w\e[m]\$ "
export PS1='\n\[\e]2;\u@\h:\w\a\]\e[m[\e[1;31m\t\e[m][\e[1;32m\u@\H\e[m:\e[1;34m\w\e[m]$(__git_ps1 "[\e[1;33m%s\e[m]")\n\$ '
export EDITOR=/usr/bin/nano
export VISUAL=/usr/bin/nano
export PATH=$PATH:/usr/local/bin:/usr/local/games:/var/lib/gems/1.8/bin/svn2git

export PYTHONPATH="/usr/local/lib/svn-python":="/usr/local/lib/svn-python/svn":="/usr/local/lib/svn-python/libsvn"

alias ls="ls --color"
alias ll="ls -l --color";
