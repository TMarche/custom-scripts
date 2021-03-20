#!/bin/bash

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

## This will need a lot of work in order to function correctly
googlebooks () {
    local SEARCH_STR="${1:-}"
    BOOKS=$(findbooks -p "${SEARCH_STR}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    SEARCH_STRINGS=$(echo "${BOOKS}" | grep -oP "\/([^\/]*?)\.pdf\$" | grep -oP "\w+" | grep -v "pdf")
    for SEARCH_STRING in "${SEARCH_STRINGS}"; do
        URL="https://www.google.com/search?rlz=1C1CHBF_enUS874US874&sxsrf=ALeKk021G8JFaE1QUxjqI4RjUpbiPVeg9w%3A1615756163275&ei=g3tOYIePEIeo_QapgJZI&q=${SEARCH_STRING}&oq=${SEARCH_STRING}&gs_lcp=Cgdnd3Mtd2l6EAMyBAgAEA0yBAgAEA0yBAguEA0yBAgAEA0yBAgAEA0yBAgAEA0yBAgAEA0yBAgAEA0yBggAEA0QHjIGCAAQDRAeOgQIABBHOgYIABAHEB5QiAlY5yxggDJoAHADeACAAZIBiAH1ApIBAzAuM5gBAKABAaoBB2d3cy13aXrIAQjAAQE&sclient=gws-wiz&ved=0ahUKEwjH3J7h2LDvAhUHVN8KHSmABQkQ4dUDCA0&uact=5"
        chrome $URL 
    done;
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
