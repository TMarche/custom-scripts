#!/bin/bash

BOOK_LOC="/c/Users/tmarc/OneDrive/Desktop/Media/Books"

findbooks () {
        local SEARCH_STR="${1:-}"
        find ${BOOK_LOC} -type f -iname "*.pdf" | grep -iP "${SEARCH_STR}"
}

openbooks () {
        local SEARCH_STR="${1:-}"
        msedge $(findbooks "${SEARCH_STR}" | grep -vP "0.0.0.2") &> /dev/null &
}

win2lin () { f="${1/C://c}"; printf '%s\n' "${f//\\//}"; }
