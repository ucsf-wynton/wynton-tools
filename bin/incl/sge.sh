# -------------------------------------------------------------------------
# SYSTEM
#
# Requirements:
# * asserts.sh
# -------------------------------------------------------------------------
pwd=${BASH_SOURCE%/*}

# shellcheck source=incl/asserts.sh
source "${pwd}"/asserts.sh


# -------------------------------------------------------------------------
# Time utils
# -------------------------------------------------------------------------
date_iso() {
    date --iso-8601=seconds -d "${1:?}" | sed -E 's/-[[:digit:]]{1,2}(:[[:digit:]]{1,2})$//'
}    

## Convert into days, hours, minutes, and seconds
seconds_to_dhms() {
    local -i s=${1:?}
    local fmt=${2:-"%dd%02dh%02dm%02ds"}
    local -i d h m
    
    d=$(( s / (24 * 60 * 60) ))
    s=$(( s % (24 * 60 * 60) ))
    h=$(( s / (60 * 60) ))
    s=$(( s % (60 * 60) ))
    m=$(( s / 60 ))
    s=$(( s % 60 ))
    printf "${fmt}" "${d}" "${h}" "${m}" "${s}"
}



# -------------------------------------------------------------------------
# Configure
# -------------------------------------------------------------------------
sge_downtime_start() {
    local cal=${1:-"maint_downtime"}
    local raw
    raw=$(qconf -scal "${cal}" | grep -E "^year[[:blank:]]+" | sed -E 's/^year[[:blank:]]+//' | sed 's/[-].*//' | sed -E 's/\b([[:digit:]]+)[.]([[:digit:]]+)[.]([[:digit:]]+)\b/\3-\2-\1/g' | sed -E 's/\b([[:digit:]]):/0\1:/g' | sed 's/=/T/')
    date -d "${raw}"
}


# -------------------------------------------------------------------------
# Accounting
# -------------------------------------------------------------------------
sge_accounting=/opt/sge/wynton/common/accounting

accounting_list_finished() {
    local user=${1?}
    local -i tail_size=${2:-1000000}
    tail -n "$tail_size" "${sge_accounting}" | grep ":${user}:"
}    


# -------------------------------------------------------------------------
# Queue
# -------------------------------------------------------------------------
annotate_qstat() {
    local E q w
    
    E="${red}E${reset}"
    q="${yellow}q${reset}"
    w="${yellow}w${reset}"
    z="${magenta}z${reset}"
    sed -e "s/Eqw/${E}qw/" -e "s/qw/${q}${w}/" -e "s/\bz\b/${z}/"
}

