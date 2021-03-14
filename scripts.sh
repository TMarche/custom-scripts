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

    ## Create search string
    local SEARCH_STR="${POSITIONAL:-}"
    debug "SEARCH_STR: ${SEARCH_STR}"

    ## Pipe into sed to use relative paths for searching
    local ALL_BOOKS=$(find "${BOOK_LOC}" -type f -iname '*.pdf' | sed -n -e "s;^${BOOK_LOC}/;;p")
    local MATCHING_BOOKS=$(echo "${ALL_BOOKS}" | grep -iP "${SEARCH_STR}" --color=always)
    debug "MATCHING_BOOKS:\n${MATCHING_BOOKS}"

    ## Return full file paths -- paths must be rebuilt using BOOK_LOC config var
    if [ ! -z ${USE_FULL_PATHS+x} ]; then
        WITH_PREFIX=$(echo "${MATCHING_BOOKS}" | sed -n -e "s;^;${BOOK_LOC}/;p")
        echo "${WITH_PREFIX}"
        return
    fi

    ## Return truncated file paths
    echo "${MATCHING_BOOKS}"
}

## In order for this command to work, the user must have the 'msedge'
## program added to the system path
## NOTE: msedge requires the FULL PATH of a file in order to open it
openbooks () {
    local SEARCH_STR="${1:-}"
    ## Use 'sed' to strip out color control characters
    msedge $(findbooks -p "${SEARCH_STR}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g") &> /dev/null &
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
        echo -e "$@"
    fi
}
