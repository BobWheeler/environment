# .bashrc

for __arg in  $*; do
    if [ $__arg = -debug ]; then __debug_bashrc=true; break; fi
done
unset __arg

[[ $(hostname) =~ \.prod\. ]] && export ONPRODMACHINE="true"

function __assert_defined () {
    local var ref remedy rc
    if [ $# -eq 0 ]; then echo "usage: __assert_set var1 [var2 [var3 ...]] || return 1" >&2; return -1; fi

    declare -A  remedy
    remedy[ATFCOMPONENT]="run setatf"
    remedy[ATFTEST]="run setatf"
    remedy[REPOBASE]="set in .bashrc"
    remedy[DEFAULT_REPOBASE]="set in environment"
    remedy[REPONAME]="run setrepo"
    remedy[REPOROOT]="run setrepo"

    rc=0
    for var in $*; do
	declare -n ref=$var
	if [ -z "${remedy[$var]}" ]; then
	    echo "Internal error: unknown environment variable $var used in function ${FUNCNAME[1]} in source file ${BASH_SOURCE[2]}" >&2
	    rc=1
	elif [ -z "$ref" ]; then
	    echo "${FUNCNAME[@]:((${#FUNCNAME[@]} - 1))}: enviroment variable $var is not set, ${remedy[$var]}" >&2
	    rc=1
	fi
    done

    return $rc
}

export BASHMODULESLOADED=""

function __addmodule () {
    if ! echo "$BASHMODULESLOADED" | egrep -q "(:|^)$1(:|$)"; then
	export BASHMODULESLOADED="$BASHMODULESLOADED:$1"
    fi
}

function modules () {
    echo "Modules loaded:--------------$BASHMODULESLOADED" | tr ':' '\n'
}

export BASHFUNCTIONSLOADED=""

declare -A __functiondescription


function __addfunction () {
    if ! echo "$BASHFUNCTIONSLOADED" | egrep -q "(:|^)$1(:|$)"; then
	export BASHFUNCTIONSLOADED="$BASHFUNCTIONSLOADED:$1"
	__functiondescription["$1"]="$2"
    fi
}

function functions () {
    for fun in $(echo $BASHFUNCTIONSLOADED | tr ':' '\n' | sort); do
	printf "%-20s  %s\n" $fun  "${__functiondescription[$fun]}"
    done
}

if [ -n $(echo $- | grep i) ]; then
    cd ~/.bash.d
    rm -f *~

    for __module in *; do
	if [ -n "$__debug_bashrc" ]; then echo loading $__module; fi
	. $__module
    done
    unset __module

    cd ~-
fi

unset __debug_bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
