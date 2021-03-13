#!/bin/sh
function size() {

  ## Process arguments
  if [[ ! $# -gt 0 ]]; then
    size-help
    return
  fi

  local POSITIONAL=()
  while [[ $# -gt 0 ]]; do
    key="$1"

    case "$key" in
      -h|--help)
        local HELP="True"
        ;;
      -u|--union)
        local UNION="True"
        size-debug "UNION: ${UNION}"
        ;;
      -i|--intersection)
        local INTERSECTION="True"
        size-debug "INTERSECTION: ${INTERSECTION}"
        ;;
      -c|--category)
        ## USAGE: size -c js js,ts,tsx
        local CATEGORY="$2"
        size-debug "TOPCOUNT: ${TOPCOUNT}"
        local ITEMS="$3"
        size-debug "ITEMS: ${ITEMS}"
        shift ## Past value
        shift ## Past value
        ;;
      -t|--top)
        local TOPCOUNT="$2"
        size-debug "TOPCOUNT: ${TOPCOUNT}"
        shift ## Past value
        ;;
      -b|--bottom)
        local BOTTOMCOUNT="$2"
        size-debug "BOTTOMCOUNT: ${BOTTOMCOUNT}"
        shift ## Past value
        ;;
      *) ## Unknown option
        local POSITIONAL+=("$1")
        size-debug "POSITIONAL: ${POSITIONAL[@]}"
        ;;
    esac
    shift ## Past argument
  done

  ## Display help info
  if [ ! -z ${HELP+x} ]; then
    size-help
    return
  fi

  ## Validate positional arguments
  set -- "${POSITIONAL[@]}" ## Restore positional arguments
  size-debug "POSITIONAL: ${POSITIONAL[@]}"

  if [ ${#POSITIONAL[@]} -eq 0 ]; then
    echo "ERROR: Must include file extensions."
    size-help
    return
  fi

  ## TODO: Evaluate categories to actual values
  ## Create type array via comma split
  local TYPES=${POSITIONAL[-1]}
  readarray -td '' TYPES < <(awk '{ gsub(/,/,"\0"); print; }' <<<"${TYPES},"); unset 'TYPES[-1]'
  size-debug `declare -p TYPES`
  size-debug "TYPES: ${TYPES[@]}"
  ## TODO: Filter out invalid types

  ## Create subpath array via space split
  local SUBPATHS=${POSITIONAL[@]::${#POSITIONAL[@]}-1}
  readarray -td '' SUBPATHS < <(awk '{ gsub(/ /,"\0"); print; }' <<<"${SUBPATHS} "); unset 'SUBPATHS[-1]'
  size-debug `declare -p SUBPATHS`
  size-debug "SUBPATHS: ${SUBPATHS[@]}"

  ###########################
  ## Get files to evaluate ##
  ###########################

  ## Get matching files by extension
  for TYPE in ${TYPES[@]}; do
    local FILES="${FILES[@]} "$(find -iname "*\.${TYPE}")
  done
  size-debug "TYPECOUNT: ${#TYPES[@]}"

  ## Filter by sub-paths (make note of union vs intersection)
  ## NOT PROCESSING FILES AS ARRAY
  FILES="`echo ${FILES} | tr ' ' '\n'`"
  ## Exclude generated/modules
  FILES=$(echo -e "${FILES}" | grep -v "generated" | grep -v "node_modules")
  for SUBPATH in ${SUBPATHS[@]}; do
    FILES=$(echo -e "${FILES}" | grep -iP "$SUBPATH")
  done

  local FILE_ARR=( ${FILES} )
  size-debug "FILECOUNT: ${#FILE_ARR[@]}"

  ## Check that there are files
  if [ ${#FILE_ARR[@]} -eq 0 ]; then
    echo "WARNING: NO MATCHING FILES FOUND"
    return
  fi

  ## Get top(?)

  ## Get bottom(?)

  ## NOTE: Need to re-evaluate size after getting top/bottom

  ###########################
  ## TODO: Make sub-function
  ###########################

  ## Print sorted by size
  ## NOTE: NEED TO GET FILES BEFORE SENDING HERE
  wc -l ${FILES[@]} | sort -n
}

function size-debug() {
  if [ ! -z ${DEBUG+x} ]; then
    echo "$@"
  fi
}

function size-help() {
  echo "Usage: [OPTIONS] [SUB_PATHS] <file_extensions>"
  echo "EX: size components views/pages ts,tsx"
  echo "   -h, --help           Display help information"
  echo "   -u, --union          Process files found under *any* of the given sub-paths (default)"
  echo "   -i, --intersection   Process files found under *all* of the given sub-paths"
  echo "   -c, --category       Define a new file extension category (not implemented)"
  echo "   -t, --top            Only process top n items"
  echo "   -b, --bottom         Only process bottom n items"
}

