
# Author: Cornelius
# Usage:
#   source gh.sh

function _gh()
{
    local cur
    cur=${COMP_WORDS[COMP_CWORD]}

    if (($COMP_CWORD == 1)); then
        # cache commands
        if [[ -z $gh_commands ]] ; then
            gh_commands=$( gh | cut -d- -f1 | sed -e 's/^[ ]*//' )
        fi
        COMPREPLY=( $( compgen -W "$gh_commands" -- $cur ) )
        return 0
    elif (($COMP_CWORD == 2 )); then
        local subcmd=${COMP_WORDS[1]}
        if [[ $subcmd == "fork" || $subcmd == "pull" ]] ; then
            local gh_forks=$(gh network --id)
            COMPREPLY=( $( compgen -W "$gh_forks" -- $cur ) )
            return 0
        elif [[ $subcmd == "upload" ]] ; then
            COMPREPLY=( $( compgen -A file -- $cur ) )
            return 0
        fi
    fi
    if [[ $COMP_WORDS > 1 && $cur =~ ^-- ]] ; then
        local subcmd=${COMP_WORDS[1]}
        local cmdoptions=""
        case $subcmd in
            clone|all)
                cmdoptions='--ssh --ro --http --https'
                ;;
            pull)
                cmdoptions='--merge --branch'
                ;;
            network)
                cmdoptions='--id'
                ;;
        esac
        if [[ -n $cmdoptions ]] ; then
            COMPREPLY=( $( compgen -W "$cmdoptions" -- $cur ) )
        fi
        return 0
    fi
}

complete -F _gh gh
