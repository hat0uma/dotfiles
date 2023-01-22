#####################################################################
# init
#####################################################################
# zmodload zsh/zprof && zprof

if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
    zcompile ~/.zshrc
fi

#####################################################################
# plugins
#####################################################################

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

## two regular plugins loaded without investigating.
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

## Plugin history-search-multi-word loaded with investigating.
zinit load zdharma-continuum/history-search-multi-word

## Load the pure theme, with zsh-async library that's bundled with it.
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure

## A glance at the new for-syntax – load all of the above
## plugins with a single command. For more information see:
## https://zdharma.org/zinit/wiki/For-Syntax/
zinit for \
    light-mode  zsh-users/zsh-autosuggestions \
    light-mode  zdharma-continuum/fast-syntax-highlighting \
                zdharma-continuum/history-search-multi-word \
    light-mode pick"async.zsh" src"pure.zsh" \
                sindresorhus/pure

## Binary release in archive, from GitHub-releases page.
## After automatic unpacking it provides program "fzf".
# zinit ice from"gh-r" as"program"
# zinit load junegunn/fzf-bin

## One other binary release, it needs renaming from `docker-compose-Linux-x86_64`.
## This is done by ice-mod `mv'{from} -> {to}'. There are multiple packages per
## single version, for OS X, Linux and Windows – so ice-mod `bpick' is used to
## select Linux package – in this case this is actually not needed, Zinit will
## grep operating system name and architecture automatically when there's no `bpick'.
# zinit ice from"gh-r" as"program" mv"docker* -> docker-compose" bpick"*linux*"
# zinit load docker/compose

## Vim repository on GitHub – a typical source code that needs compilation – Zinit
## can manage it for you if you like, run `./configure` and other `make`, etc. stuff.
## Ice-mod `pick` selects a binary program to add to $PATH. You could also install the
## package under the path $ZPFX, see: http://zdharma.org/zinit/wiki/Compiling-programs
# zinit ice as"program" atclone"rm -f src/auto/config.cache; ./configure" \
#     atpull"%atclone" make pick"src/vim"
# zinit light vim/vim

# Scripts that are built at install (there's single default make target, "install",
# and it constructs scripts by `cat'ing a few files). The make'' ice could also be:
# `make"install PREFIX=$ZPFX"`, if "install" wouldn't be the only, default target.
# zinit ice as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
# zinit light tj/git-extras

## Handle completions without loading any plugin, see "clist" command.
## This one is to be ran just once, in interactive session.
# zinit creinstall %HOME/my_completions

## (this is currently required for annexes)
# zinit light-mode for \
#     zdharma-continuum/z-a-rust \
#     zdharma-continuum/z-a-as-monitor \
#     zdharma-continuum/z-a-patch-dl \
#     zdharma-continuum/z-a-bin-gem-node

### End of Zinit's installer chunk

# other plugins
zinit light zsh-users/zsh-completions

#####################################################################
# aliases and functions
#####################################################################
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias edit='nvim'
alias open='xdg-open'
function nv ()
{
    export NVIM_RESTART_ENABLE=1
    nvim $@
    while [ $? -eq 1 ]; do nvim +RestoreSession; done 
    unset NVIM_RESTART_ENABLE
}

if [[ $NVIM ]]; then
    source _nvim_hooks.zsh
#     NVIM_CMD=$(which nvim)
#     function nvim () {
#         if [[ $@ =~ "--headless" ]]; then
#             $NVIM_CMD $@
#         else
#             $NVIM_CMD --server $PARENT_NVIM_ADDRESS --remote-tab $@
#         fi
#     }
fi

#####################################################################
# others
#####################################################################
typeset -U path PATH
# compinit
# https://gist.github.com/ctechols/ca1035271ad134841284
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C
bindkey -e

# histoy
HISTFILE=$HOME/.zsh-history
HISTSIZE=10000
SAVEHIST=50000
setopt inc_append_history
setopt share_history

setopt auto_cd
setopt auto_pushd
setopt correct
setopt list_packed
zmodload -i zsh/mathfunc

zmodload zsh/zpty

fpath+=${ZDOTDIR:-~}/.zsh_functions

# if (which zprof > /dev/null 2>&1) ;then
#   zprof
# fi

