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
# include my svn function stoo
. ~/environment/svn-functions

# set the prompt

function __stw_prompt_time
{
	"\e[m[\e[1;31m\t\e[m]"
}

function __stw_prompt_location
{
	"[\e[1;32m\u@\H\e[m:\e[1;34m\w\e[m]"
}

PS1='\n\e[m[\e[1;31m\t\e[m][\e[1;32m\u@\H\e[m:\e[1;34m\w\e[m]$(__git_ps1 "[$(__stw_git_status)%s\e[m:\e[0;35m$(__stw_get_git_rev_name)\e[m]$(__stw_git_numeric_status)$(__stw_get_git_stash_status)")$(__stw_svn_status)\nbash \$ '

# If this is an xterm set the title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]2;\u@\h:\w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'

alias status='git status'
alias add='git add'
alias commit='git commit'
alias push='git push'
alias pull='git pull'
alias stash='git stash'

alias reload=". ~/environment/bashrc"

alias cde="cd ~/environment"

alias makeloop='while true; do make; ./project ; sleep 1; done'

alias c=clear

alias scr='~/environment/grabssh; screen -r'
alias scrd='~/environment/grabssh; screen -rd'

alias screnum='~/environment/screnum'

alias ssh='source ~/environment/fixssh; ssh'
alias fixssh='source ~/environment/fixssh'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export EDITOR=/usr/bin/nano
export VISUAL=/usr/bin/nano
export PATH=$HOME/bin:$PATH:/usr/local/bin:/usr/local/games:/var/lib/gems/1.8/bin/
export PYTHONPATH="/usr/local/lib/svn-python":="/usr/local/lib/svn-python/svn":="/usr/local/lib/svn-python/libsvn"
