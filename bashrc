# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=20000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

environmentdir=`dirname ${BASH_SOURCE[0]}`;

# include bash completion for git on the off-chance we don't already have it
. $environmentdir/bash-completion-git

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
        echo -ne "${realdir/#$HOME/\~}"
        echo -ne "\e[m"
    fi
}

function __stw_get_dirstack
{
    currdir=`pwd`
    shortcurdir=$(echo -ne "${currdir/#$HOME/\~}")
    dirstack=$(dirs)
    
    if [ "$dirstack" != "$shortcurdir" ]; then
        echo -ne "\n\e[m[stack: \e[1;35m$dirstack\e[m]"
    fi
}

function __stw_get_username
{
    initCol="$ColLGreen"
    
    if [ $EUID -eq 0 ]; then
        initCol="$ColLRed"
    fi
    
    echo -ne $initCol$USER    
}

tput colors > /dev/null
if [ "$?" = "0" ]; then
    ColLRed="\e[1;31m"
    ColLYellow="\e[1;33m"
    ColLGreen="\e[1;32m"
    ColLBlue="\e[1;34m"
    ColDPurple="\e[0;35m"
    ColLCyan="\e[1;36m"
    ColReset="\e[m"
    export STW_PS1_GITSTATUS="true"
else
    ColLRed=""
    ColLYellow=""
    ColLGreen=""
    ColLBlue=""
    ColDPurple=""
    ColLCyan=""
    ColReset=""
    export STW_PS1_GITSTATUS="false"
fi

which p4 &> /dev/null
if [ $? -eq 0 ]; then
    p4workspaceseg='$(__stw_get_p4_workspace)'
else
    p4workspaceseg=''
fi

   
# If this is an xterm set the title
case "$TERM" in
cygwin|xterm|xterm-256color|screen|linux|screen.linux|screen.xterm-256color)

    if [ "$OS" = "Windows_NT" ]; then
        # msys is *really* slow, so we have to make some concessions here    
        export STW_PS1_GITSTATUS="false"
        
        PROMPT_COMMAND="__git_ps1 '\n$ColReset[$ColLRed\t$ColReset][$ColLGreen\$USERDOMAIN\\\\$USERNAME@\H$ColReset:$ColLBlue\w\$(__stw_get_real_dir)$ColReset]' '$p4workspaceseg\$(__stw_get_dirstack)'$'\nbash \\$ '"
    else
        PROMPT_COMMAND="__git_ps1 '\n$ColReset[$ColLRed\t$ColReset][\$(__stw_get_username)@\H$ColReset:$ColLBlue\w\$(__stw_get_real_dir)$ColReset]' '$p4workspaceseg\$(__stw_get_dirstack)'$'\nbash \\$ '"
    fi

    

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
    # basic prompt
    PS1='[\t][\u@\H:\w]\nbash \$ '

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

alias grabagent="echo \"export SSH_AUTH_SOCK='$SSH_AUTH_SOCK'\" > ~/.ssh-agent"
alias screen='grabagent;screen'

alias gpg='/usr/bin/gpg2'

alias pls='sudo $(history -p \!\!)'
alias pup='pushd /etc/puppet; sudo git pull && sudo puppet agent --enable && sudo puppet agent -t; popd'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f ~/.ssh-agent ]; then
    . ~/.ssh-agent
fi

editorPriority="nano pico vim vi emacs ex ed"
for app in $editorPriority; do 
    appPath=$(which $app)
    if [[ $? -eq 0 ]]; then
        export EDITOR=$appPath
        export VISUAL=$appPath
        break
    fi
done

alias nano=$EDITOR

export PATH=$HOME/bin:$PATH:/usr/local/bin:/usr/local/games:/var/lib/gems/1.8/bin:/opt/phabricator/arcanist/bin
export PYTHONPATH="/usr/local/lib/svn-python":="/usr/local/lib/svn-python/svn":="/usr/local/lib/svn-python/libsvn"

source $environmentdir/git-prompt.sh

# disable XON/XOFF for Ctrl-S forward-history search, only for interactive shells
[[ $- == *i* ]] && stty -ixon
