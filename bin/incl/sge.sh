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

