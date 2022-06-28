#programming MacOS
if [[ $OSTYPE == 'darwin'* ]]; then
  # silence info "macOS is using zsh"
  export BASH_SILENCE_DEPRECATION_WARNING=1
fi

################
# temp aliases #
################
alias fwl='cd ~/WEBDEV/projects/fwl/'
alias ebash='cd ~/snap/exercism/5/exercism/bash/'

goevk() {
  root="${HOME}/WEBDEV/projects/goevk"
  api="${root}/api"
  site="${root}/site"
  if [ $# -eq 0 ]
  then cd ${root};
  else cd ${!1}
  fi
}

##########
# Colors #
##########
COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[0;33m"
COLOR_GREEN="\033[0;32m"
COLOR_OCHRE="\033[38;5;95m"
COLOR_BLUE="\033[0;34m"
COLOR_WHITE="\033[0;37m"
COLOR_PURPLE="\033[01;35m"
COLOR_CYAN="\033[01;36m"
COLOR_RESET="\033[0m"

###########
# Exports #
###########
export EDITOR='vim'
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=/opt:/opt/tmux:$PATH
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export PATH=/opt/homebrew/lib/python3.9/site-packages:$PATH

# nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

###########
# Aliases #
###########
alias ll='ls -lva'
alias pomodoro="${HOME}/REPOS/pomodoro/pomodoro.sh"
alias cct="${HOME}/bin/change-color-theme.sh"
alias vim='nvim'
alias ncspot="${HOME}/ncspot/target/release/ncspot"
alias code='open /Applications/Visual\ Studio\ Code.app'

# Quickly access repos
repos() {
  vim="${HOME}/REPOS/dotfiles/vim/"
  dot="${HOME}/REPOS/dotfiles/"
  gtk="${HOME}/REPOS/GTK/"
  snip="${HOME}/REPOS/snippets/"
  if [ $# -eq 0 ]
  then cd ${HOME}/REPOS/;
  else cd ${!1}
  fi
}

# Create a ToDo file with boilerplate
alias ctl="create_td_list.sh"

# Open todo lists
td() {
  if [[ -f "TD.md" ]]; then nvim TD.md
  elif [[ -f "td.md" ]]; then nvim td.md
  else printf "${COLOR_RED}Cannot find ToDo-List in this directory ${ENDC}"
  echo
  fi
}

# Colorize ls output
if [[ $OSTYPE == 'darwin'* ]]; then
  # colorize ls output on macOS
  alias ls='ls -G'
else
  # colorize ls output on linux
  alias ls='ls --color=auto'
fi

# GIT
alias gs='git status'
alias gd='git diff'

# .bashrc (edit + source)
alias eb='vim ${HOME}/.bashrc';
alias sb='source ${HOME}/.bashrc';

# kitty.conf (edit)
alias ekc='vim ${HOME}/REPOS/dotfiles/kitty/kitty.conf'

# xclip
# => send data to clipboard => e.g pwd | xclip
alias xclip='xclip -selection c'


#######
# PS1 #
#######
# use this fn to color PS1 according to exit codes
exit_color() {
  if [[ ${?} == 0 ]]
  then
    echo -e ${COLOR_GREEN}
  else
    echo -e ${COLOR_RED}
  fi
}

PS1="\[$COLOR_WHITE\]"        # Color user + host
# PS1+="\u@\H"                # Print user + host
PS1+="\[\$(exit_color)\]➜ "   # Print '#' for root, else '➜'
PS1+="\[$COLOR_PURPLE\][\W] " # Print Basename of pwd
PS1+="\[\$(git_color)\]"      # Color git status
PS1+="\$(git_info)"           # Print current branch
PS1+="\[$COLOR_RESET\]"       # Reset colors
export PS1

##################
# TAB COMPLETION #
##################
# Only run these commands in interactive sessions
# => Stops error messages on startup
if [[ -t 1 ]]
then
  # Relies on bash version >= 4
  # If multiple matches for completion, Tab cycles through them
  bind "TAB:menu-complete"
  # Display a list of the matching files
  bind "set show-all-if-ambiguous on"
  # Case insesitive completion
  bind "set completion-ignore-case on"
  # Perform partial completion on the first Tab press,
  # only start cycling full results on the second Tab press
  bind "set menu-complete-display-prefix on"
  bind '"\e[Z":menu-complete-backward'

  ######################
  # HISTORY COMPLETION #
  ######################
  # Cycle through history based on characters already typed on the line
  # Clear the line with Ctrl-K
  bind '"\e[A":history-search-backward'
  bind '"\e[B":history-search-forward'
fi


######################
# CUSTOM COMPLETIONS #
######################
# Open GTK files in vim/nvim
gtk() {
if command -v nvim &> /dev/null
then
 nvim $HOME/GTK/$1
else
 vim $HOME/GTK/$1
fi
}

# Open WIP files in vim
wip() {
 vim $HOME/WIP/$1
}

# Completion for gtk
_gtk() {
  local MEMO_DIR=$HOME/GTK
  local cmd=$1 cur=$2 pre=$3
  local arr i file

  arr=( $( cd "$MEMO_DIR" && compgen -f -- "$cur" ) )
  COMPREPLY=()
  for ((i = 0; i < ${#arr[@]}; ++i)); do
    file=${arr[i]}
    if [[ -d $MEMO_DIR/$file ]]; then
      file=$file/
    fi
    COMPREPLY[i]=$file
  done
}
complete -F _gtk -o nospace gtk

# Completion for wip
_wip() {
  local MEMO_DIR=$HOME/WIP
  local cmd=$1 cur=$2 pre=$3
  local arr i file

  arr=( $( cd "$MEMO_DIR" && compgen -f -- "$cur" ) )
  COMPREPLY=()
  for ((i = 0; i < ${#arr[@]}; ++i)); do
    file=${arr[i]}
    if [[ -d $MEMO_DIR/$file ]]; then
      file=$file/
    fi
    COMPREPLY[i]=$file
  done
}
complete -F _wip -o nospace wip

########
# ANKI #
########
# Rename and move screenshots for notes
alias mvss="anki_screenshots_move"

# Convert markdown notes to anki flash cards
parseNotes() {
  WORKING_DIR=$PWD;
  cd ~/REPOS/anki_card_parser/
  source env/env_anki_card_parser/bin/activate;
  python3 parse_notes.py $WORKING_DIR $1;
  deactivate;
  cd -;
}

#######
# GIT #
#######
# Source completions
source ${HOME}/REPOS/dotfiles/bash/completions/git-completion.bash

# Colorize PS1 according to git status
git_color() {
  STATUS=$(command git status --untracked --porcelain 2> /dev/null | tail -n1)
  if [[ -n $STATUS ]]; then
    # there is stuff to commit
    echo -e $COLOR_RED
  else
    # nothing to commit
    echo -e $COLOR_GREEN
  fi
}

# Echo info on branches + commits, used in PS1
git_info() {
  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo "($branch) "
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo "($commit) "
  fi
}

#######
# FZF #
#######
export FZF_DEFAULT_COMMAND='ag -l'

# run fzf with preview window
 alias fzf="fzf     \
   --preview 'bat \
   --style=numbers    \
   --color=always      \
   --line-range :500 {}'\
   "

# Open vim, run :Ag command to search file content
ff() {
  nvim -c ":Ag"
}

# Search files with fzf
# and open them in vim
f() {
  local fname
  fname="$(fzf)" || return
  nvim "${fname}"
}

########
# BUKU #
########
alias b="buku --suggest"

# Search buku using fzf to filter results + open in your favourite browser
bs(){
 BROWSER="Firefox"
 # bookmark=$(buku -p -f 10 | fzf);
 # open -a ${BROWSER} ${bookmark}

  url=$(buku -p -f4 | fzf -m --reverse --preview "buku -p {1}" --preview-window=wrap | cut -f2)
  if [ -n "$url" ]; then
      echo "$url" | xargs open -a ${BROWSER}
  fi
}

#################
## EXPERIMENTS ##
#################

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# including this ensures that new gnome-terminal tabs keep the parent `pwd` !
if [ -e /etc/profile.d/vte.sh ]; then
    . /etc/profile.d/vte.sh
fi

# Play with bind commands
# bind -x '"\C-l": clear; ls'

alias timer="bash ~/Desktop/beep_timer.sh"
