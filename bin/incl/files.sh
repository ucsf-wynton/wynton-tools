pwd=${BASH_SOURCE%/*}

# shellcheck source=incl/asserts.sh
source "${pwd}"/asserts.sh

function change_dir {
    local opwd
    opwd=${PWD}
    assert_dir_exists "$1"
    cd "$1" || error "Failed to set working directory to $1"
    mdebug "New working directory: '$1' (was '${opwd}')"
}

function make_dir {
    mkdir -p "$1" || error "Failed to create new working directory $1"
}

function remove_dir {
    rm -rf "$1" || error "Failed to remove directory $1"
}

function equal_dirs {
    local a
    local b
    a=$(readlink -f "$1")
    b=$(readlink -f "$2")
    [[ "${a}" == "${b}" ]]
}

function wait_for_file {
    local file
    local maxseconds
    local delay
    
    file=${1:?}
    maxseconds=${2:-300}
    delay=${3:-1.0}
    
    t0=${SECONDS}
    until [[ -f "${file}" && $((SECONDS - t0)) -lt "${maxseconds}" ]]; do
        sleep "${delay}"
    done
    [[ -f "${file}" ]] || error "Waited for file ${file}, but gave up after ${maxseconds} seconds"
}


function file_info() {
    local file=${1:?}
    local is_owner=${2:true}
    local info
    info="'${file}'"

    if [[ ! -f "${file}" ]]; then
        if ${is_owner}; then
            info="${info} <no such file>"
        else
            info="${info} ${yellow}Cannot access file, because you ($USER) may lack access permissions${reset}"
        fi
        echo "${info}"
        return 1
    fi

    if [[ -L "${file}" ]]; then
        file=$(readlink -f "$file")
	info="${info} -> '${file}'"
    fi

    ## File-permission, username, and group
    info="${info} [$(stat -c "%s bytes, %A, owner=%U, group=%G" "${file}"); $(file --brief "${file}")]"

    echo "${info}"
}


function dir_info() {
    local dir=${1:?}
    local is_owner=${2:true}
    local info
    info="'${dir}'"

    if [[ ! -d "${dir}" ]]; then
        if ${is_owner}; then
            info="${info} <no such directory>"
        else
            info="${info} ${yellow}Cannot access directory, because you ($USER) may lack access permissions${reset}"
        fi
        echo "${info}"
        return 1
    fi

    if [[ -L "${dir}" ]]; then
        dir=$(readlink -f "$dir")
	info="${info} -> '${dir}'"
    fi

    ## File-permission, username, and group
    info="${info} [$(stat -c "%A, owner=%U, group=%G" "${dir}")]"

    echo "${info}"
}
