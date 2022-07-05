#!/usr/bin/env bash

function log::message {
  local -r tm=${EPOCHREALTIME}

  printf '[%(%H:%M:%S)T.%s][M][%s]\n' \
    "${tm%%.*}" "${tm#*.}" "${1}" >&4
  printf '[%(%H:%M:%S)T.%s][\e[34mM\e[0m][%s]\n' \
    "${tm%%.*}" "${tm#*.}" "${1}"
}

function log::debug {
  local -r tm=${EPOCHREALTIME}

  printf '[%(%H:%M:%S)T.%s][D][%s][%s]\n' \
    "${tm%%.*}" "${tm#*.}" "${1}" "${2}" >&4
}

function log::error {
  local -r tm=${EPOCHREALTIME}

  printf '[%(%H:%M:%S)T.%s][E][%s][%s][%s]\n' \
    "${tm%%.*}" "${tm#*.}" "${1}" "${2}" "${3}" >&4
  printf '[%(%H:%M:%S)T.%s][\e[31mE\e[0m][%s][%s][%s]\n' \
    "${tm%%.*}" "${tm#*.}" "${1}" "${2}" "${3}" >&2
}

function + {
  local -i ec
  local co

  log::debug "${*}" "${FUNCNAME[1]}"
  co=$("${@}" 2>&1) || ec=${?}

  if [[ -n ${co} ]]; then
    sed --expression="s/^/\--->/" <<<${co} >&4
  fi

  if [[ -n ${ec-} ]]; then
    log::error ${ec} "${*}" "${FUNCNAME[1]}"
    exit ${ec}
  fi
}

function log::ini {
  declare LOG
  printf -v LOG '%(%d_%m_%Y_%H:%M)T.log'
  exec 4>"${LOG}"
  trap 'log::error ${?} "${BASH_COMMAND}" "${FUNCNAME[0]:-source}"' ERR
}
