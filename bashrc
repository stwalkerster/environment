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

function __stw_get_git_rev_name
{
        git describe --always 2> /dev/null
}

function __stw_get_git_wd_unstaged
{
        git status 2> /dev/null | sed -e '/Changes not staged for commit:$/!d' | wc -l;
}

function __stw_get_git_wd_staged
{
        git status 2> /dev/null | sed -e '/Changes to be committed:$/!d' | wc -l;
}

function __stw_get_git_wd_untracked
{
        git status 2> /dev/null | sed -e '/Untracked files:$/!d' | wc -l;
}

function __stw_get_git_num_unstaged
{
        git diff --name-only 2> /dev/null | wc -l;
}

function __stw_get_git_num_staged
{
        git diff --name-only --cached 2> /dev/null | wc -l
}

function __stw_get_git_num_untracked
{
        git ls-files -o --exclude-standard 2> /dev/null | wc -l
}

function __stw_get_git_num_stash
{
        git stash list 2> /dev/null | wc -l
}

function __stw_git_status
{
        if [ `__stw_get_git_wd_unstaged` == "1" ]
                then
                        echo "\e[1;31m"
                        return
        fi

        if [ `__stw_get_git_wd_staged` == "1" ]
                then
                        echo "\e[1;33m"
                        return
        fi

        if [ `__stw_get_git_wd_untracked` == "1" ]
                then
                        echo "\e[1;34m"
                        return
        fi

        echo "\e[1;32m"
}

function __stw_git_numeric_status
{
        OUTPUT="["

        if [ `__stw_get_git_num_unstaged` != "0" ]
                then
                OUTPUT=$OUTPUT"\e[1;31m$(__stw_get_git_num_unstaged)"
        fi

        if [ `__stw_get_git_num_staged` != "0" ]
                then
                OUTPUT=$OUTPUT"\e[1;33m$(__stw_get_git_num_staged)"
        fi

        if [ `__stw_get_git_num_untracked` != "0" ]
                then
                OUTPUT=$OUTPUT"\e[1;34m$(__stw_get_git_num_untracked)"
        fi

        if [ "$OUTPUT" != "[" ]
                then
                OUTPUT=$OUTPUT"\e[m]"
                echo $OUTPUT
        fi

        return
}

function __stw_get_git_stash_status
{
        if [ `__stw_get_git_num_stash` != "0" ]
                then
                echo "[\e[0;36m$(__stw_get_git_num_stash)\e[m]"
        fi

        return
}




# set the prompt 
PS1='\n\e[m[\e[1;31m\t\e[m][\e[1;32m\u@\H\e[m:\e[1;34m\w\e[m]'

# If this is an xterm set the title
case "$TERM" in
cygwin)
	PS1=$PS1'$(__git_ps1 "[%s:$(__stw_get_git_rev_name)]")\nbash \$ '
	;;
xterm*|rxvt*)
	PS1=$PS1'$(__git_ps1 "[$(__stw_git_status)%s\e[m:\e[0;35m$(__stw_get_git_rev_name)\e[m]$(__stw_git_numeric_status)$(__stw_get_git_stash_status)")'
	PS1="$PS1\nbash \$ "
    PS1="\[\e]2;\u@\h:\w\a\]$PS1"
		
	# enable color support of ls and also add handy aliases
	if [ -x $(which dircolors) ]; then
		test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
		alias ls='ls --color=auto'

		alias grep='grep --color=auto'
		alias fgrep='fgrep --color=auto'
		alias egrep='egrep --color=auto'
	fi
    ;;
*)
	PS1=$PS1'$(__git_ps1 "[$(__stw_git_status)%s\e[m:\e[0;35m$(__stw_get_git_rev_name)\e[m]$(__stw_git_numeric_status)$(__stw_get_git_stash_status)")'
	PS1="$PS1\nbash \$ "
	
	# enable color support of ls and also add handy aliases
	if [ -x $(which dircolors) ]; then
		test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
		alias ls='ls --color=auto'

		alias grep='grep --color=auto'
		alias fgrep='fgrep --color=auto'
		alias egrep='egrep --color=auto'
	fi
    ;;
esac




# some more ls aliases
alias ll='ls -l'
alias la='ls -A'

alias status='git status'
alias add='git add'
alias commit='git commit'
alias push='git push'
alias pull='git pull'
alias stash='git stash'

alias scr='~/environment/grabssh; screen -r'
alias scrd='~/environment/grabssh; screen -rd'

alias screnum='~/environment/screnum'

alias ssh='source ~/environment/fixssh; ssh -A'
alias fixssh='source ~/environment/fixssh'

alias envupdate='pushd ~/environment/; git pull; source bashrc; popd'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export EDITOR=nano
export VISUAL=/usr/bin/nano
export PATH=$HOME/bin:$HOME/sml:$PATH:/usr/local/bin:/usr/local/games:/var/lib/gems/1.8/bin
export PYTHONPATH="/usr/local/lib/svn-python":="/usr/local/lib/svn-python/svn":="/usr/local/lib/svn-python/libsvn"
