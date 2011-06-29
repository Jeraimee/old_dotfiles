[ -z "$PS1" ] && return
export COLOR_NC='\e[0m' # No Color
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_GRAY='\e[0;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'
export TERM=xterm-color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export EDITOR='emacs'
export GIT_EDITOR=$EDITOR
export VISUAL=$EDITOR
# sets title of window to be user@host
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*} ${PWD}"; echo -ne "\007"'

export PS1='\h:\W \u$(__git_ps1 " \[${COLOR_RED}\](%s)\[${COLOR_NC}\]")\$ '

# readline settings
bind "set completion-ignore-case on"
bind "set bell-style none" # No bell, because it's damn annoying
bind "set show-all-if-ambiguous On" # this allows you to automatically show completion without double tab-ing

# history (bigger size, no duplicates, always append):
export HISTCONTROL=erasedups
export HISTSIZE=10000
shopt -s histappend

# Sets the binary path to /sw/bin if
# it exists
#
if [ -d /sw/bin ]; then
    BIN_PATH="/sw/bin/"
else
    BIN_PATH=""
fi

# Default terminal title
# Leave empty to have the hostname
# be the default term title
#
DEF_TERMTITLE=""

# Pager ... duh
#
PAGER="less"

# Path modifications
#
# Add personal /bin to path
if [ -d ~/bin ]; then
    export PATH=${PATH}:~/bin
fi

# Small path addition for OS X ;-)
if [ -d /Developer/Tools ]; then
    export PATH=${PATH}:/Developer/Tools
fi

# Path addition for Android SDK
if [ -d /Developer/android-sdk-mac_x86/platform-tools ]; then
    export PATH=${PATH}:/Developer/android-sdk-mac_x86/platform-tools
fi

# Path addition for git-achievements
if [ -d ~/bin/git-achievements ]; then
    export PATH=${PATH}:~/bin/git-achievements
fi

# Path additon for CakePHP
if [ -d /opt/cake ]; then
    export PATH=${PATH}:/opt/cake/cake/console
fi

#
# Programmable Completion Options
#

shopt -s extglob        # necessary
set +o nounset          # otherwise some completions will fail

complete -A hostname   rsh rcp telnet rlogin r ftp ping disk
complete -A command    nohup exec eval trace gdb
complete -A command    command type which
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger

complete -A helptopic  help     # currently same as builtins
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown

complete -A directory  mkdir rmdir
complete -A directory   -o default cd

complete -f -d -X '*.gz'  gzip
complete -f -d -X '*.bz2' bzip2
complete -f -o default -X '!*.gz'  gunzip
complete -f -o default -X '!*.bz2' bunzip2
complete -f -o default -X '!*.pl'  perl perl5

# This is a 'universal' completion function - it works when commands have
# a so-called 'long options' mode , ie: 'ls --all' instead of 'ls -a'
_universal_func ()
{
    case "$2" in
        -*)     ;;
        *)      return ;;
    esac

    case "$1" in
        \~*)    eval cmd=$1 ;;
        *)      cmd="$1" ;;
    esac
    COMPREPLY=( $("$cmd" --help | ${BIN_PATH}sed  -e '/--/!d' -e 's/.*--\([^ ]*\).*/--\1/'| \
grep ^"$2" |sort -u) )
}
complete  -o default -F _universal_func ldd wget bash id info

_configure_func ()
{
    case "$2" in
        -*)     ;;
        *)      return ;;
    esac

    case "$1" in
        \~*)    eval cmd=$1 ;;
        *)      cmd="$1" ;;
    esac

    COMPREPLY=( $("$cmd" --help | awk '{if ($1 ~ /--.*/) print $1}' | grep ^"$2" | sort -u) )
}
complete -F _configure_func configure

_killall ()
{
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    # get a list of processes (the first sed evaluation
    # takes care of swapped out processes, the second
    # takes care of getting the basename of the process)
    COMPREPLY=( $( /bin/ps -u $USER -o comm  | \
        ${BIN_PATH}sed -e '1,1d' -e 's#[]\[]##g' -e 's#^.*/##'| \
        awk '{if ($0 ~ /^'$cur'/) print $0}' ))

    return 0
}
complete -F _killall killall killps

source ~/.git-completion.bash
