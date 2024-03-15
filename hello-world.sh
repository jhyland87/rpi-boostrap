#!/env bash

_none="\e[0m"
_bold="\e[1m"
_dim="\e[2m"
_ital="\e[3m"
_dirtyyellow="\e[38;5;142m"
_nobold="\e[22m"
_red="\e[31m"


function sayhello {
    local to=${1:-World}

    printf "${_dim}%s${_none}  ${_bold}${_ital}Hello ${_dirtyyellow}%s${_none}\n" $(date +"%Y-%m-%dT%H-%M-%SZ") "${to}"
}


sayhello $1