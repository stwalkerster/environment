# The following lines were added by compinstall

zstyle ':completion:*' completer _list _complete _ignored _match _correct _approximate
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' max-errors 3 numeric
zstyle ':completion:*' old-menu false
zstyle :compinstall filename '/home/stwalkerster/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
bindkey -e
# End of lines configured by zsh-newuser-install

export PS1=$'%{\e[m%}[%{\e[1;31m%}%*%{\e[m%}][%{\e[1;32m%}%n@%m%{\e[m%}:%{\e[1;34m%}%~%{\e[m%}]
zsh %# '

alias ls='ls --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
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

alias c=clear
