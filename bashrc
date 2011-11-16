# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# include bash completion for git on the off-chance we don't already have it
. ~/environment/bash-completion-git
# include my specific git functions
. ~/environment/git-status-colours


# colour prompt:
export PS1='\n\[\e]2;\u@\h:\w\a\]\e[m[\e[1;31m\t\e[m][\e[1;32m\u@\H\e[m:\e[1;34m\w\e[m]$(__git_ps1 "[$(__stw_git_status)%s\e[m]")\n\$ '

export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

export PATH=$PATH:/usr/local/bin:/usr/local/games:/var/lib/gems/1.8/bin/svn2git
export PYTHONPATH="/usr/local/lib/svn-python":="/usr/local/lib/svn-python/svn":="/usr/local/lib/svn-python/libsvn"
