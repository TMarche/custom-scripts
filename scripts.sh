#!/bin/bash

########################################################################
## CONFIG VARIABLES  NOTE: Should be moved to separate config file    ##
########################################################################

BOOK_LOC="/c/Users/tmarc/OneDrive/Desktop/Media/Books"


########################################################################
## FUNCTIONS                                                          ##
########################################################################

## BOOKS
##########
findbooks () {
    local POSITIONAL=();
    while [[ $# -gt 0 ]]; do
        key="$1";
        case "$key" in
            -p | --full-paths)
                local USE_FULL_PATHS="True"
            ;;
            *)
                local POSITIONAL+=("$1");
                debug "POSITIONAL: ${POSITIONAL[@]}"
            ;;
        esac;
        shift;
    done;

    ## Perform book search
    local SEARCH_STR="${POSITIONAL:-}"
    local BOOK_PATHS="$(find ${BOOK_LOC} -type f -iname '*.pdf')"
    debug "RESULTS: ${RESULTS}"

    ## Return full file paths
    if [ ! -z ${USE_FULL_PATHS+x} ]; then
        echo "${BOOK_PATHS}" | grep -iP "${SEARCH_STR}"
        return
    fi

    ## Return truncated file paths
    echo "${BOOK_PATHS}" | sed -n -e "s/^.*\/Books\///p" | grep -iP "${SEARCH_STR}"
}

## In order for this command to work, the user must have the 'msedge'
## program added to the system path
openbooks () {
    local SEARCH_STR="${1:-}"
    msedge $(findbooks -p "${SEARCH_STR}") &> /dev/null &
}

## MISC
#########
win2lin () { f="${1/C://c}"; printf '%s\n' "${f//\\//}"; }

vimtab () {
    FILE=".vimrc";
    TARGET="${HOME}/${FILE}";
    sed -ri "s/(set[^/]*)(tab|shift)([^/]*)(=[[:digit:]]+)/\1\2\3=${1}/g" ${TARGET};
    echo -e "$(grep -P "set.*?(tab|shift).*?=" ${TARGET})"
}

## If DEBUG is set, then display the given string
function debug() {
    if [ ! -z ${DEBUG+x} ]; then
        echo "$@"
    fi
}
