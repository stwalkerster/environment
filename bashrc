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

environmentdir=`dirname ${BASH_SOURCE[0]}`;

# include bash completion for git on the off-chance we don't already have it
. $environmentdir/bash-completion-git

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
                        echo -ne "\e[1;31m"
                        return
        fi

        if [ `__stw_get_git_wd_staged` == "1" ]
                then
                        echo -ne "\e[1;33m"
                        return
        fi

        if [ `__stw_get_git_wd_untracked` == "1" ]
                then
                        echo -ne "\e[1;34m"
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
                echo -ne $OUTPUT
        fi

        return
}

function __stw_get_git_stash_status
{
        if [ `__stw_get_git_num_stash` != "0" ]
                then
                echo -ne "[\e[0;36m$(__stw_get_git_num_stash)\e[m]"
        fi

        return
}

function __stw_get_p4_workspace
{
    which p4 &> /dev/null
    
    if [ $? -eq 1 ]; then
        return
    fi
    
    p4 client -o &>/dev/null
    
    if [ $? -eq 0 ]; then
        perforceclient=$(p4 client -o 2>/dev/null | grep Client: | grep -v \# | cut -f 2)
        
        echo -ne "[\e[1;33m"
        echo -ne "$perforceclient"
        echo -ne "\e[m]"
    fi
}

function __stw_get_real_dir
{
    currdir=`pwd`
    realdir=$(readlink -f "$(pwd)")
    
    if [ "$realdir" != "$currdir" ]; then
        echo -ne "\e[m|\e[1;36m"
        echo -ne "${realdir/#$HOME/~}"
        echo -ne "\e[m"
    fi
}

function __stw_get_dirstack
{
    currdir=`pwd`
    shortcurdir=$(echo -ne "${currdir/#$HOME/~}")
    dirstack=$(dirs)
    
    if [ "$dirstack" != "$shortcurdir" ]; then
        echo -ne "\n\e[m[stack: \e[1;35m$dirstack\e[m]"
    fi
}

export PROMPT_COMMAND='echo "";for i in `seq 1 $COLUMNS` ;do echo -n "-";done'

# If this is an xterm set the title
case "$TERM" in
cygwin|xterm|screen|linux|screen.linux)
    PromptEnd="\nbash \$ "

    if [ $(id -u) -eq 0 ]; then
        PromptEnd="\n\e[41m\e[97mbash #\e[m "
    fi

    PS1='\e[m[\e[1;31m\t\e[m][\e[1;32m\u@\H\e[m:\e[1;34m\w$(__stw_get_real_dir)\e[m]$(__git_ps1 "[$(__stw_git_status)%s\e[m:\e[0;35m$(__stw_get_git_rev_name)\e[m]$(__stw_git_numeric_status)$(__stw_get_git_stash_status)")$(__stw_get_p4_workspace)$(__stw_get_dirstack)'
    PS1=$PS1$PromptEnd

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
    # git information
    PS1=$PS1'$(__git_ps1 "[$(__stw_git_status)%s\e[m:\e[0;35m$(__stw_get_git_rev_name)\e[m]$(__stw_git_numeric_status)$(__stw_get_git_stash_status)")'

    # prompt
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

alias ssh='ssh -A'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export EDITOR=nano
export VISUAL=/usr/bin/nano
export PATH=$HOME/bin:$PATH:/usr/local/bin:/usr/local/games:/var/lib/gems/1.8/bin:/opt/phabricator/arcanist/bin
export PYTHONPATH="/usr/local/lib/svn-python":="/usr/local/lib/svn-python/svn":="/usr/local/lib/svn-python/libsvn"
