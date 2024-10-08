# -------------------------------------------------------------------------
# CLI utility functions
# -------------------------------------------------------------------------
function version {
    grep -E "^#'[ ]*Version:[ ]*" "$0" | sed "s/#'[ ]*Version:[ ]*//g"
}

function help {
    local what res
    what=${1:-""}
    res=$(grep "^#'" "$0" | grep -vE "^(###|#' whatis: )" | cut -b 4-)

    if [[ ${UCSF_WYNTON_TOOLS} == true ]]; then
        res=$(printf "%s\\n" "${res[@]}" | sed -E 's/([^/])wynton-([a-z]+)/\1wynton \2/')
    fi

    if [[ $what == "full" ]]; then
        res=$(echo "$res" | sed '/^---/d')
    else
        res=$(echo "$res" | sed '/^---/Q')
    fi

    printf "%s\\n" "${res[@]}"
}
