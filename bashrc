# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# MacOS defence
if [[ "$(uname -s)" == "Darwin" ]]; then
   # assumes homebrew packages coreutils and findutils are installed. If not, you probably want to install them anyway
   eval "$(/opt/homebrew/bin/brew shellenv)"
   export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"

   if [[ -x /opt/homebrew/bin/ggrep ]]; then
      alias grep=/opt/homebrew/bin/ggrep
   fi
fi

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

# disable XON/XOFF for Ctrl-S forward-history search, only for interactive shells
[[ $- == *i* ]] && stty -ixon

# capture the current folder for later use
environmentdir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"));

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
# This often includes the git-prompt too
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# include bash completion for git on the off-chance we don't already have it from above
if [[ -r "${environmentdir}/bash-completion-git" ]]; then
    source "${environmentdir}/bash-completion-git"
fi

# include the fancy git prompt logic
if [[ -r "${environmentdir}/git-prompt.sh" ]]; then
    STW_PS1_USEGITPROMPT="true"
    STW_PS1_GITSTATUS="true"
    source "${environmentdir}/git-prompt.sh"
else
    # we don't have this available, skip it entirely.
    STW_PS1_USEGITPROMPT="false"
fi

# setup colour codes
tput colors > /dev/null
if [ "$?" = "0" ]; then
    ColLRed="\001\e[1;31m\002"
    ColLYellow="\001\e[1;33m\002"
    ColDYellow="\001\e[0;33m\002"
    ColLGreen="\001\e[1;32m\002"
    ColLBlue="\001\e[1;34m\002"
    ColDPurple="\001\e[0;35m\002"
    ColLPurple="\001\e[1;35m\002"
    ColLCyan="\001\e[1;36m\002"
    ColReset="\001\e[m\002"
    export STW_PS1_GITSTATUS="true"
else
    ColLRed=""
    ColLYellow=""
    ColLGreen=""
    ColLBlue=""
    ColDPurple=""
    ColLPurple=""
    ColLCyan=""
    ColReset=""
    export STW_PS1_GITSTATUS="false"
fi

function stw_printcolours
{
    for x in {0..8}; do
        for i in {30..37}; do
            for a in {40..47}; do
                echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "
            done
            echo
        done
    done
    echo ""
}

# functions used in prompt
function __stw_ps1_p4
{
    which p4 &> /dev/null

    if [ $? -eq 1 ]; then
        return
    fi

    p4 client -o &>/dev/null

    if [ $? -eq 0 ]; then
        perforceclient=$(p4 client -o 2>/dev/null | grep Client: | grep -v \# | cut -f 2)

        echo -ne "[${ColLYellow}${perforceclient}${ColReset}]"
    fi
}

function __stw_ps1_readlink
{
    currdir=$(pwd)
    realdir=$(readlink -f "$(pwd)")

    if [ "$realdir" != "$currdir" ]; then
        echo -ne "${ColReset}|${ColLCyan}"
        echo -ne "${realdir/#$HOME/\~}"
        echo -ne "${ColReset}"
    fi
}

function __stw_ps1_dirstack
{
    currdir=$(pwd)
    shortcurdir=$(echo -ne "${currdir/#$HOME/\~}")
    dirstack=$(dirs)

    if [ "$dirstack" != "$shortcurdir" ]; then
        echo -ne "\n${ColReset}[stack: ${ColLPurple}${dirstack/${shortcurdir} /}${ColReset}]"
    fi
}

function __stw_ps1_username
{
    initCol="$ColLGreen"

    if [ $EUID -eq 0 ]; then
        initCol="$ColLRed"
    fi

    echo -ne $initCol$USER
}

function __stw_ps1_tz
{
    curtz=$(date +%:::z)
    if [[ "$curtz" != "+00" ]]; then
        echo -n " $curtz";
    fi
}

function __stw_ps1_environment
{
    flag=0

    if [[ ${1:-0} -eq 0 ]]; then
        which terraform &> /dev/null
        if [ $? -eq 0 ]; then
            if [[ -r ${PWD}/.terraform/environment ]]; then
                echo -ne "[TF:${ColDPurple}$(cat ${PWD}/.terraform/environment)${ColReset}]"
                flag=1
            fi
        fi
    fi

    if [[ ! -z $AWSUME_PROFILE ]]; then
        if [[ ${1:-0} -eq 0 ]]; then
            echo -ne "[AWS:${ColDYellow}${AWSUME_PROFILE}${ColReset}]"
        else
            echo -ne "[AWS:${AWSUME_PROFILE}]"
        fi
        flag=1
    fi

    if [[ ! -z $PS1ENV ]]; then
        if [[ ${1:-0} -eq 0 ]]; then
            echo -ne "[${ColDYellow}${PS1ENV}${ColReset}]"
        else
            echo -ne "[${PS1ENV}]"
        fi
        flag=1
    fi

    if [[ $flag -eq 1 ]]; then echo -n " "; fi
}

# If this is an xterm(ish), enable the fancy prompts
case "$TERM" in
cygwin|xterm|xterm-256color|screen|linux|screen.linux|screen.xterm-256color)

    # check for Perforce; if present then include the perforce section
    which p4 &> /dev/null
    if [ $? -eq 0 ]; then
        ps1_p4segment='$(__stw_ps1_p4)'
    else
        ps1_p4segment=''
    fi

    # set up the fancy bits of the prompt
    ps1_timesegment='\t$(__stw_ps1_tz)'
    ps1_pwdsegment='\w$(__stw_ps1_readlink)'
    ps1_usersegment='$(__stw_ps1_username)@\H'${ColReset}
    ps1_stacksegment='$(__stw_ps1_dirstack)'
    ps1_envsegment='$(__stw_ps1_environment)'

    if [ "$OS" = "Windows_NT" ]; then
        # msys is *really* slow, so we have to make some concessions here

        # disable super-fancy prompt
        export STW_PS1_GITSTATUS="false"
        ps1_timesegment='\t'
        ps1_pwdsegment='\w'
        ps1_usersegment=$ColLGreen'${USERDOMAIN}\\\\${USERNAME}@\H'${ColReset}
        ps1_p4segment=''
        ps1_stacksegment=''
        ps1_envsegment=''
    fi

    # set up the two halves of the prompt
    ps1a="\n$ColReset[${ColLRed}${ps1_timesegment}${ColReset}][${ps1_usersegment}:${ColLBlue}${ps1_pwdsegment}${ColReset}]"
    ps1b="${ps1_p4segment}${ps1_stacksegment}\n${ps1_envsegment}\s \\$ "

    # set up the title bar of the terminal window
    PROMPT_COMMAND='printf "\033]0;%s%s@%s:%s\007" "$(__stw_ps1_environment 1)" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'

    if [[ $STW_PS1_USEGITPROMPT = "true" ]]; then
        # we have a git prompt available, format PS1 via the git command.
        PROMPT_COMMAND="${PROMPT_COMMAND}; __git_ps1 '${ps1a}' '${ps1b}'"
    else
        # no git prompt; set PS1 directly.
        PS1="${ps1a}${ps1b}"
    fi
    ;;
*)
    # basic prompt only. :(
    PS1='[\u@\H:\w]\n\s \$ '
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x $(which dircolors) ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
fi

############################################################################
#  preferred editors
#

editorPriority="nano pico vim vi"
for app in $editorPriority; do
    appPath=$(which $app)
    if [[ $? -eq 0 ]]; then
        export EDITOR=$appPath
        export VISUAL=$appPath
        break
    fi
done

alias nano=$EDITOR

############################################################################
# dotfiles deployment
#

function stw-deploy-dotfiles() {
    rm ~/.nanorc ~/.screenrc ~/.gitconfig
    ln -s ${environmentdir}/nanorc ~/.nanorc
    ln -s ${environmentdir}/screenrc ~/.screenrc
    ln -s ${environmentdir}/gitconfig ~/.gitconfig
}

############################################################################
# domain-specific configuration
#

fqdnhash=$(hostname -d | sha256sum)
if [[ $fqdnhash = "ce016ed63c3ed4238554bce0be9f5c0ce5cdd471d2ad23edd7215cb3ed7bae6c" ]] || [[ $fqdnhash = "036783db4feb982dbbb443d69bd0f11e4ea4ca2303bdc166acd52914be7a1887" ]]; then

    # override and lock out changes
    export TMOUT=$((2*24*60*60))
    readonly TMOUT

    # load current user's settings
    if [[ -f ~/.bash_profile ]] ; then
        source ~/.bash_profile
    fi

    # set this if it's not already set by the user
    if [[ "$ORACLE_HOME" == "" ]]; then
        export ORACLE_HOME=/export/users/oracle/product/19.7.0
        export PATH=$PATH:$ORACLE_HOME/bin
    fi

    # fix; this is broken by other bashrc configurations
    export LS_COLORS='rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lz=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.bz=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.rar=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.axv=38;5;13:*.anx=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.axa=38;5;45:*.oga=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:'

    if [[ -r /tmp/.stw-aliases ]]; then
        source /tmp/.stw-aliases
    fi
fi

############################################################################
# ALIASES
#

alias ll='ls -lh'
alias cdl='cd $(readlink -f "$(pwd)")'
alias la='ls -A'

# alias grabagent="echo \"export SSH_AUTH_SOCK='$SSH_AUTH_SOCK'\" > ~/.ssh-agent"
# alias screen='grabagent;screen'

# force to gpg2
which gpg2 &> /dev/null
if [ $? -eq 0 ]; then
    alias gpg=$(which gpg2)
fi

alias pls='sudo $(history -p \!\!)'
alias colourdiff="sed 's/^-/\x1b[31m-/;s/^+/\x1b[32m+/;s/^@/\x1b[1;34m@/;s/$/\x1b[0m/'"

# set this in case we don't have it already
which sl &> /dev/null
if [ $? -ne 0 ]; then
    alias sl='echo Steam Locomotive not available, did you mean "ls"?'
fi

# Terraform trickery
complete -C terraform terraform tf
alias tf=terraform
alias tfp='terraform plan -out tfplan'
alias tfa='terraform apply tfplan'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tfc='terraform console'
alias tfaaa='terraform apply --auto-approve'

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

############################################################################
# Misc
#

if [ -f ~/.ssh-agent ]; then
    . ~/.ssh-agent
fi

export PATH=$HOME/bin:$PATH:/usr/local/bin:/usr/local/games:$HOME/.local/bin

if [[ -d ${environmentdir}/git-commands ]]; then
    export PATH=${PATH}:${environmentdir}/git-commands
fi
