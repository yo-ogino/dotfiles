#
# users generic .zshrc file for zsh(1)
# 

## Environment variable configuration
#
# LANG
#
export LANG=ja_JP.UTF-8

## Default shell configuration
#
# set prompt
#
autoload colors
colors
case ${UID} in
0)
PROMPT="%B%{${fg[cyan]}%}%/#%{${reset_color}%}%b "
PROMPT2="%B%{${fg[cyan]}%}%_#%{${reset_color}%}%b "
SPROMPT="%B%{${fg[cyan]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
[ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
PROMPT="%{${fg[cyan]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
;;
*)
PROMPT="%{${fg[cyan]}%}%/%%%{${reset_color}%} "
PROMPT2="%{${fg[cyan]}%}%_%%%{${reset_color}%} "
SPROMPT="%{${fg[cyan]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
[ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
PROMPT="%{${fg[cyan]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
;;
esac

# auto change directory
#
setopt auto_cd

# auto directory pushd that you can get dirs list by cd -[tab]
#
setopt auto_pushd

# command correct edition before each completion attempt
#
#setopt correct

# compacked complete list display
#
setopt list_packed

# no remove postfix slash of command line
#
setopt noautoremoveslash

# no beep sound when complete list displayed
#
setopt nolistbeep


## Keybind configuration
#
# emacs like keybind (e.x. Ctrl-a goes to head of a line and Ctrl-e goes 
#   to end of it)
#
bindkey -e

# historical backward/forward search with linehead string binded to ^P/^N
#
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end


## Command history configuration
#
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups     # ignore duplication command history list
setopt share_history        # share command history data

## Completion configuration
#
fpath=(~/.zsh/functions/Completion ${fpath})
  autoload -U compinit
  compinit

## zsh editor
#
  autoload zed

## Prediction configuration
#
#autoload predict-on
#predict-off


## Alias configuration
#
# expand aliases before completing
#
  setopt complete_aliases     # aliased ls needs if file/dir completions work

  alias where="command -v"
  alias j="jobs -l"

  case "${OSTYPE}" in
  freebsd*|darwin*)
# add -F option
  alias ls="ls -G -w -F"
  ;;
  linux*)
# add -F option
  alias ls="ls --color -F"
  ;;
  esac

  alias la="ls -a"
  alias lf="ls -F"
  alias ll="ls -l"

  alias du="du -h"
  alias df="df -h"

  alias su="su -l"

  case "${OSTYPE}" in
  darwin*)
  alias updateports="sudo port selfupdate; sudo port outdated"
  alias portupgrade="sudo port upgrade installed"
  ;;
  freebsd*)
  case ${UID} in
  0)
updateports() 
{
  if [ -f /usr/ports/.portsnap.INDEX ]
    then
      portsnap fetch update
  else
    portsnap fetch extract update
      fi
      (cd /usr/ports/; make index)

      portversion -v -l \<
}
alias appsupgrade='pkgdb -F && BATCH=YES NO_CHECKSUM=YES portupgrade -a'
;;
esac
;;
esac


## terminal configuration
#
unset LSCOLORS
case "${TERM}" in
xterm)
export TERM=xterm-color
;;
kterm)
export TERM=kterm-color
# set BackSpace control character
stty erase
;;
cons25)
unset LANG
export LSCOLORS=ExFxCxdxBxegedabagacad
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors 'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
;;
esac

# set terminal title including current directory
# ***Mac***
case "${TERM}" in
kterm*|xterm*)
precmd() {
  echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
}
export LSCOLORS=cxfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

#export LSCOLORS=gxfxcxdxbxegedabagacad
#export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
#zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
;;
esac

## load user .zshrc configuration file
#
[ -f ~/.zshrc.mine ] && source ~/.zshrc.mine

## Shift-Tab
bindkey "\e[Z" reverse-menu-complete

# カレントディレクトリ短縮表示
case "$TERM" in
  xterm*|kterm*|rxvt*)
    PROMPT=$(print "%B%{\e[34m%}%m:%(5~,%-2~/.../%2~,%~)%{\e[33m%}%# %b")
    PROMPT=$(print "%{\e]2;%n@%m: %~\7%}$PROMPT") # title bar
    ;;
  *)
    PROMPT='%m:%c%# '
    ;;
esac

# MacVim
case "${OSTYPE}" in
  darwin*)
    alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
    alias vim='env_LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
esac

# 大文字小文字区別なし
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ビープ音なし
setopt no_beep

# rvenv
 export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

alias re='rbenv exec'
alias be='bundle exec'

# tmux
alias tm='/usr/local/bin/tmuxx'

#mysql
alias mysqlp="mysql --pager='less -S'"

# oh my zsh
ZSH=$HOME/.oh-my-zsh
plugins=(git)
export ZSH_THEME="wedisagree"
source $ZSH/oh-my-zsh.sh

# for sudo vim
alias 'svim'='sudo vim -u $HOME/dotfiles/.vimrc_sudo'

# rails
alias rails='bundle exec rails'
alias rake='bundle exec rake'
alias bundleinstall='bundle install --path vendor/bundle'

# nodebrew
PATH=$HOME/.nodebrew/current/bin:$PATH

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

alias ssh='TERM=screen ssh'

[ -f ~/.zshrc.personal ] && source ~/.zshrc.personal

export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)

export GOPATH=$HOME/.go

eval "$(hub alias -s)"

# git
function prf () {
  git fetch -f upstream pull/$1/head:pr$1
  git co pr$1
}

function reset_hard () {
  git fetch upstream
  git reset --hard upstream/$1
}

function psg () {
  ps aux | grep $1
}

function ssh_tunnels () {
  psg '[s]sh.\+-L'
}

function kill_ssh_tunnels () {
  psg "[s]sh.\+-L $1" | awk '{print $2}' | xargs kill
}

function bm_release_tag () {
  tag="$1-$(date +'%Y%m%d-%H%M')"
  git tag -s -m $tag $tag
  git push upstream $tag
  echo $tag | pbcopy
}

