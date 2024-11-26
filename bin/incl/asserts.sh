# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# DATA TYPES
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Check if an integer
function is_integer {
    grep -q -E "^[[:digit:]]+$" <<< "${1:?}"
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ASSERTIONS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Usage: assert_file_exists /path/to/file
function assert_file_exists {
    [[ $# -ne 1 ]] && error "${FUNCNAME[0]}() requires a single argument: $#"
    [[ -n "$1" ]] || error "File name must be non-empty: '$1'"
    [[ -f "$1" ]] || error "No such file: '$1' (working directory '${PWD}')"
}

function assert_link_exists {
    [[ $# -ne 1 ]] && error "${FUNCNAME[0]}() requires a single argument: $#"
    [[ -n "$1" ]] || error "File name must be non-empty: '$1'"
    [[ -L "$1" ]] || error "File is not a link: '$1' (working directory '${PWD}')"
    [[ -e "$1" ]] || error "[File] link is broken: '$1' (working directory '${PWD}')"
}

## Usage: assert_file_executable /path/to/file
function assert_file_executable {
    [[ $# -ne 1 ]] && error "${FUNCNAME[0]}() requires a single argument: $#"
    assert_file_exists "$1"
    [[ -x "$1" ]] || error "File exists but is not executable: '$1' (working directory '${PWD}')"
}

## Usage: assert_dir_exists /path/to/folder
function assert_dir_exists {
    [[ $# -ne 1 ]] && error "${FUNCNAME[0]}() requires a single argument: $#"
    [[ -n "$1" ]] || error "Directory name must be non-empty: '$1'"
    [[ -d "$1" ]] || error "No such directory: '$1' (working directory '${PWD}')"
}

## Usage: assert_executable command
function assert_executable {
  command -v "${1:?}" &> /dev/null || error "No such executable: ${1}"
}

## Usage: assert_executable string
function assert_integer {
    is_integer "${1:?}" || error "Not an integer: ${1}"
}


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
