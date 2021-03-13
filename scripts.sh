#!/bin/bash

## NOTE: Adjust this such that it can be pulled into config
BOOK_LOC="/c/Users/tmarc/OneDrive/Desktop/Media/Books"

findbooks () {
        local SEARCH_STR="${1:-}"
        find ${BOOK_LOC} -type f -iname "*.pdf" | grep -iP "${SEARCH_STR}"
}

## In order for this command to work, the user must have the 'msedge'
## program set up correctly
openbooks () {
        local SEARCH_STR="${1:-}"
        msedge $(findbooks "${SEARCH_STR}") &> /dev/null &
}

win2lin () { f="${1/C://c}"; printf '%s\n' "${f//\\//}"; }

vimtab () {
	FILE=".vimrc";
	TARGET="${HOME}/${FILE}";
	sed -ri "s/(set[^/]*)(tab|shift)([^/]*)(=[[:digit:]]+)/\1\2\3=${1}/g" ${TARGET};
	echo -e "$(grep -P "set.*?(tab|shift).*?=" ${TARGET})"
}
