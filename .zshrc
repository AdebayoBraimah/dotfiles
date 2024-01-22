#
# .zshrc
#
# Author: Jeff Geerling
# 
# Edit: Adebayo Braimah
#

# Colors.
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# Ignore '#' in scripts and in zsh.
setopt interactive_comments

# Nicer prompt.
export PS1=$'\n'"%F{green} %*%F{red} %3~ %F{white}"$'\n'"$ "
# export PS1=$'\n'"%F{green} %*%F %3~ %F{white}"$'\n'"$ "

# Enable plugins.
plugins=(git brew history kubectl history-substring-search)

# Custom $PATH with extra locations.
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:${HOME}/bin:${HOME}/go/bin:/usr/local/git/bin:${PATH}
# export PATH=${HOME}/Library/Python/3.9/bin:/opt/homebrew/bin:/usr/local/bin:/usr/local/sbin:${HOME}/bin:${HOME}/go/bin:/usr/local/git/bin:${PATH}

# Bash-style time output.
export TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S'

# Include alias file (if present) containing aliases for ssh, etc.
if [ -f ~/.aliases ]; then
  source ~/.aliases
fi

# Set architecture-specific brew share path.
arch_name="$(uname -m)"
if [ "${arch_name}" = "x86_64" ]; then
    share_path="/usr/local/share"
elif [ "${arch_name}" = "arm64" ]; then
    share_path="/opt/homebrew/share"
else
    echo "Unknown architecture: ${arch_name}"
fi

# Allow history search via up/down keys.
source ${share_path}/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Git aliases.
alias gs='git status'
alias gc='git commit'
alias gp='git pull --rebase'
alias gcam='git commit -am'
alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Completions.
autoload -Uz compinit && compinit
# Case insensitive.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# Git upstream branch syncer.
# Usage: gsync master (checks out master, pull upstream, push origin).
function gsync() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a branch."
     return 0
 fi

 BRANCHES=$(git branch --list $1)
 if [ ! "$BRANCHES" ] ; then
    echo "Branch $1 does not exist."
    return 0
 fi

 git checkout "$1" && \
 git pull upstream "$1" && \
 git push origin "$1"
}

# Tell homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Super useful Docker container oneshots.
# Usage: dockrun, or dockrun [centos7|fedora27|debian9|debian8|ubuntu1404|etc.]
# Run on arm64 if getting errors: `export DOCKER_DEFAULT_PLATFORM=linux/amd64`
dockrun() {
 docker run -it geerlingguy/docker-"${1:-ubuntu1604}"-ansible /bin/bash
}

# Enter a running Docker container.
function denter() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a container ID or name."
     return 0
 fi

 docker exec -it $1 bash
 return 0
}

# Delete a given line number in the known_hosts file.
knownrm() {
 re='^[0-9]+$'
 if ! [[ $1 =~ $re ]] ; then
   echo "error: line number missing" >&2;
 else
   sed -i '' "$1d" ~/.ssh/known_hosts
 fi
}

# Handy Extract Function
extract(){
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)  tar xvjf "$1"  ;;
      *.tar.gz)  tar xvzf "$1"  ;;
      *.bz2)    bunzip2 "$1"   ;;
      *.rar)    unrar x "$1"   ;;
      *.gz)    gunzip "$1"   ;;
      *.tar)    tar xvf "$1"   ;;
      *.tbz2)   tar xvjf "$1"  ;;
      *.tgz)    tar xvzf "$1"  ;;
      *.zip)    unzip "$1"    ;;
      *.Z)     uncompress "$1" ;;
      *.7z)    7z x "$1"    ;;
      *)      echo "'$1' cannot be extracted via >extract<" ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

# Conda aliases
# alias load_conda=""
alias unload_conda="conda deactivate"

# LLVM Flags                                                                                                            
#                                                                                                                       
# Bundled libc++                                                                                                        
LDFLAGS="-L/opt/homebrew/opt/llvm/lib -Wl,-rpath,/opt/homebrew/opt/llvm/lib"                                            
                                                                                                                        
# LLVM                                                                                                                  
# LDFLAGS="-L/opt/homebrew/opt/llvm/lib"                                                                                
                                                                                                                        
# Update Path                                                                                                           
export PATH="/opt/homebrew/opt/llvm/bin:${PATH}"                                                                        
                                                                                                                        
# Compiler flags                                                                                                        
export LDFLAGS=${LDFLAGS}                                                                                               
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include" 

# Ask for confirmation when 'prod' is in a command string.
#prod_command_trap () {
#  if [[ $BASH_COMMAND == *prod* ]]
#  then
#    read -p "Are you sure you want to run this command on prod [Y/n]? " -n 1 -r
#    if [[ $REPLY =~ ^[Yy]$ ]]
#    then
#      echo -e "\nRunning command \"$BASH_COMMAND\" \n"
#    else
#      echo -e "\nCommand was not run.\n"
#      return 1
#    fi
#  fi
#}
#shopt -s extdebug
#trap prod_command_trap DEBUG
