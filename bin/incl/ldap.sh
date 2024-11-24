#!/usr/bin/env bash

# -------------------------------------------------------
# ASSERTS
# -------------------------------------------------------
#' Assert that all folders specified in a "path" environment variable exist
#'
#' Usage: assert_envpath <envvar> [exclude]*
#'
#' Examples:
#' assert_envpath LD_LIBRARY_PATH
#'
#' # Same, but ignore anything under HOME
#' assert_envpath LD_LIBRARY_PATH "$HOME"
assert_envpath_exist() {
    local name=${1:?}
    local path=${!name}    
    local excl
    local -a missing

    ## Nothing to do?
    [[ -z ${path} ]] && return 0

    shift
    excl=$(IFS="|"; echo "$*")
    
    IFS=':' read -r -a dirs <<< "$path"
    for dir in "${dirs[@]}"; do
	[[ -z ${dir} ]] && continue
	[[ -n ${excl} ]] && grep -q -E "${excl}" <<< "$dir" && continue
        [[ -d "${dir}" ]] || { missing+=( "$dir" ); continue; }
        [[ -r "${dir}" ]] || { missing+=( "$dir [no permission]" ); continue; }
        [[ -x "${dir}" ]] || { missing+=( "$dir [no recursive permission]" ); continue; }
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
	 >&2 echo "Detected non-existing or inaccessible folder(s) in ${name}: [n=${#missing[@]}] ${missing[*]}"
	return 1
    fi
    
    return 0
}


assert_MODULEPATH_exist() {
    ## FIXME: Do not add those missing folders in the first place /HB 2023-10-04
    assert_envpath_exist MODULEPATH /usr/share/modulefiles/Linux /usr/share/modulefiles/Core
}

assert_PATH_exist() {
    assert_envpath_exist PATH "$HOME" "$@"
}

assert_LD_LIBRARY_PATH_exist() {
    assert_envpath_exist LD_LIBRARY_PATH "$HOME" "$@"
}

assert_MANPATH_exist() {
    assert_envpath_exist MANPATH "$HOME" "$@"
}

assert_INFO_PATH_exist() {
    assert_envpath_exist INFO_PATH "$HOME" "$@"
}

assert_CPATH_exist() {
    assert_envpath_exist CPATH "$HOME" "$@"
}

assert_PKG_CONFIG_PATH_exist() {
    assert_envpath_exist PKG_CONFIG_PATH "$HOME" "$@"
}

assert_CUDA_LIB_PATH_exist() {
    assert_envpath_exist CUDA_LIB_PATH "$HOME" "$@"
}


assert_no_base64() {
    local field
    local value=${1:?}
    local pattern="^([[:alpha:]]+):: ([A-Za-z0-9]+[=*])$"
    if grep -i -E "${pattern}" <<< "${value}"; then
        field=$(sed -E "s/${pattern}/\1/" <<< "${value}")
        value=$(sed -E "s/${pattern}/\2/" <<< "${value}")
	>&2 echo "ERROR: Detected a Base64 encoded value in field '${field}': ${value} => '$(base64 --decode <<< "${value}")'"
	exit 1
    fi
}    



# -------------------------------------------------------
# Regular expressions
# -------------------------------------------------------
email_pattern() {
    ## Ideally, we would check using the RFC 5322 regular expression [1], but that's very long
    ## [1] https://stackoverflow.com/a/201378/1072091

    ## Instead, we check with a very basic pattern, cf. https://stackoverflow.com/a/201447/1072091
    tld="[[:alpha:]]+"
    domain="[[:alnum:]]+"
    username="[[:alnum:]._'-]+"   ## yes, you can use apostrophes /HB 2023-10-04
    echo "^${username}@(${domain}[.])+${tld}$"
}

is_ucsf_email() {
    local email=${1:?}
    grep -q -i -E "@(|[[:alnum:]]+[.])ucsf[.]edu$" <<< "${email}"
}

valid_ucsf_id() {
    local id=${1:?}
    
    ## Assert that all are valid Luhn IDs (https://en.wikipedia.org/wiki/Luhn_algorithm)
    if PYTHONPATH="${utils}/python_libs" "${utils}/valid-ucsf-id" "${id}" > /dev/null; then
	return 0
    else
	return 1
    fi
}


# -------------------------------------------------------
# Unix
# -------------------------------------------------------
reserved_usernames() {
    local -a reserved
    
    ## Known reserved usernames on the current system
    reserved=(adm backup bin cyrus daemon ftp games gdm haldaemon lp mail man messagebus mysql news nfsnobody nobody operator postfix postgres qmaild root rpc sshd sys systemd-network uucp www-data)
    
    ## Append reserved usernames on the current host
    mapfile -t reserved < <({ printf "%s\n" "${reserved[@]}"; cut -d : -f 1 /etc/passwd; } | sort -u)

    echo "${reserved[@]}"
}


# -------------------------------------------------------
# LDAP
# -------------------------------------------------------
LDAP_URI="ldap://m1,ldap://m2"
LDAP_SEARCHBASE="dc=cgl,dc=ucsf,dc=edu"
LDAP_FILTER="(wyntonAccess=TRUE)(!(wyntonAdmin=TRUE))"

ldap_search_raw() {
    ldapsearch "$@"
}

ldap_search() {
    local tf

    tf=$(mktemp)

    # -o ldif-wrap=no Avoid wrapping long output lines
    # -x              Simple authentication
    # -H URI          LDAP Uniform Resource Identifier(s)
    # -b basedn       base dn for search [can be overridden]
    # -LLL            print responses in LDIF format without comments and version
    ldapsearch -o ldif-wrap=no -x -H "${LDAP_URI}" -b "${LDAP_SEARCHBASE}" -LLL "$@" 2> "${tf}"

    ## Report on stderr?
    if [[ -s "${tf}" ]]; then
        {
            echo "-- Standard error captured from ldapsearch call ----"
            cat "${tf}"
            echo "----------------------------------------------------"
        } >&2
    fi

    rm "${tf}" || true
}

ldap_get_field() {
    local field=${1:?}
    shift
    printf "%s\n" "$@" | grep -E "^ *${field}:" | sed -E "s/^( *${field}: *| *$)//g"
}

ldap_as_timestamp() {
    local ts=${1}
    if [[ -n ${ts} ]]; then
       ts="${ts:0:8} ${ts:8:2}:${ts:10:2}:${ts:12:2}${ts:14}"
       date --date="${ts}" --rfc-3339=seconds
    else
       echo "N/A"
    fi
}

ldap_as_date() {
    local ts=${1}
    if [[ -n ${ts} ]]; then
       ts="${ts:0:8} ${ts:8:2}:${ts:10:2}:${ts:12:2}${ts:14}"
       date --date="${ts}" --rfc-3339=date
    else
       echo "N/A"
    fi
}

ldap_user_created_on() {
    local user=${1:?}
    local ts
    
    ts=$(ldap_search "(& ${LDAP_FILTER} (uid=${user}))" "createTimestamp" | grep -E "^createTimestamp:" | sed -E 's/^createTimestamp:[[:space:]]+//')
    ldap_as_timestamp "${ts}"
}

ldap_user_modified_on() {
    local user=${1:?}
    local ts
    
    ts=$(ldap_search "(& ${LDAP_FILTER} (uid=${user}))" "modifyTimestamp" | grep -E "^modifyTimestamp:" | sed -E 's/^modifyTimestamp:[[:space:]]+//')
    ldap_as_timestamp "${ts}"
}

ldap_user_access() {
    local user=${1}
    ldap_search -LLL -x "uid=${user}" "wyntonAccess" | grep -q -E "^wyntonAccess:[[:blank:]]TRUE"
}

ldap_user_locked() {
    local user=${1}
    ldap_search -LLL -x "uid=${user}" "isLocked" | grep -q -E "^isLocked:[[:blank:]]TRUE"
}

ldap_user_legend() {
    echo "W=Wynton access, L=locked, P=PHI"
}

#' @returns
#' A string of format `<user> [<user annotations>]`.
ldap_user_info() {
    local user=${1}
    local -a data
    local -a flags=()
    local value
    local meta
    local by
    
    if [[ $# -eq 0 ]]; then
	>&2 echo "ldap_user_info(): No arguments specified"
	exit 1
    elif [[ -z ${1} ]]; then
	>&2 echo "ldap_user_info(): First argument is empty; should be a username"
	exit 1
    fi
    
    mapfile -t data < <(ldap_search "uid=${user}" "createTimestamp" "creatorsName" "dn" "isLocked" "modifyTimestamp" "modifiersName" "wyntonAccess" "protectedAccess" "homeDirectory")

    by="$(ldap_get_field "creatorsName" "${data[@]}")"
    if [[ ${by} == uid=ldapbot,* ]]; then by="c"; else by="C"; fi
    flags+=("${by}=$(ldap_as_date "$(ldap_get_field "createTimestamp" "${data[@]}")")")

    by="$(ldap_get_field "modifiersName" "${data[@]}")"
    if [[ ${by} == uid=ldapbot,* ]]; then by="m"; else by="M"; fi
    flags+=("${by}=$(ldap_as_date "$(ldap_get_field "modifyTimestamp" "${data[@]}")")")
    value=$(ldap_get_field "wyntonAccess" "${data[@]}")
    if [[ ${value} == TRUE ]]; then
        flags+=(" W")
    elif [[ ${value} == FALSE ]]; then
        flags+=("!W")
    else
        flags+=("?W")
    fi

    value=$(ldap_get_field "isLocked" "${data[@]}")
    if [[ ${value} == TRUE ]]; then
        flags+=(" L")
    elif [[ ${value} == FALSE ]]; then
        flags+=("!L")
    else
        flags+=("?L")
    fi

    value=$(ldap_get_field "protectedAccess" "${data[@]}")
    if [[ ${value} == TRUE ]]; then
        flags+=(" P")
    elif [[ ${value} == FALSE ]]; then
        flags+=("!P")
    else
        flags+=("?P")
    fi

    value=$(ldap_get_field "homeDirectory" "${data[@]}")
    meta="${value}"

    printf "[%s] %s\n" "${flags[*]}" "${user} (${meta})"
}


usercerts_source_path() {
  echo "/wynton/home${SGE_ROOT}/common/sgeCA/usercerts"
}


check_user_cert() {
    local cert
    local pathname
    local user
    local since
    
    user=${1:?}
    since=${2}

    if [[ -n "${since}" ]]; then
        ## Validate 'since' and coerce to Unix epoch time
        if date --date="${since}" 2> /dev/null > /dev/null; then
            since=$(date --date="${since}" "+%s")
        else
            >&2 echo "check_user_cert(): Cannot parse 'since' argument as a timestamp: ${since}";
            exit 1;
        fi
    fi

    pathname="$(usercerts_source_path)/${user}/cert.pem"
    assert_file_exists "${pathname}" || return 1

    cert=$(openssl x509 -outform PEM -in "${pathname}")
    [[ -z ${cert} ]] && { >&2 echo "ERROR: Failed to get SGE certificate for user: ${user}"; exit 1; }

    subject=$(openssl x509 -in <(echo "${cert}") -subject -noout)
    if ! grep -q -E "UID[[:blank:]]+=[[:blank:]]+${user}[[:blank:]]*," <<< "${subject}"; then
        printf "ERROR: The SGE certificate for '%s' is for another user %s\n" "${user}" "${subject}"
        return 1
    fi

    if ! openssl x509 -in <(echo "${cert}") -noout -checkend 0 > /dev/null; then
        timestamp=$(openssl x509 -in <(echo "${cert}") -noout -enddate | sed -E "s/^notAfter=//")

        ## Ignore?
        if [[ -n "${since}" ]] && [[ $(date --date="${timestamp}" "+%s") -le "${since}" ]]; then
            return 0
        fi
        
        timestamp=$(date --date="${timestamp}" "+%F %H:%M:%S %z")
        printf "ERROR: The SGE certificate for '%s' has expired on %s\n" "${user}" "${timestamp}"
        return 1
    fi

    return 0
}


# -------------------------------------------------------
# SGE
# -------------------------------------------------------
sge_get_field() {
    local field=${1:?}
    shift
    printf "%s\n" "$@" | grep -E "^${field} " | sed -E "s/^${field} //"
}
