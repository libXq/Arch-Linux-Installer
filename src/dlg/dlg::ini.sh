#!/usr/bin/env bash

function dlg::ini::cfg {
  local -n r_aar=${1}
  local -n r_arr=${2}
  local i j k

  while IFS=':=' read -r i j k; do
    if [[ ${j} == [[:alnum:]]* ]]; then
      case "${i}" in
      s)
        if [[ ${k} == +([[:digit:]]) ]]; then
          r_aar["${j}"]=${k}
        fi
        ;;
      c)
        if [[ ${k} == +([,[:alnum:]]) ]]; then
          r_aar[color]+=${j}=${k}$'\n'
        fi
        ;;
      o)
        if [[ ${k} == [[:alnum:]]* ]]; then
          r_arr+=("${j}" "${k}")
        fi
        ;;
      esac
    fi
  done <"${3}"

  if [[ -n ${r_aar-} || -n ${r_arr-} ]]; then
    true
  else
    false
  fi
}

function dlg::ini::lst {
  local -n r_arr=${1}
  local i j

  while IFS='=' read -r i j; do
    if [[ ${i} == [!-[:blank:]]* && ${j} == [!-[:blank:]]* ]]; then
      r_arr+=("${i}" "${j}")
    fi
  done <<<${2}

  if [[ -n ${r_arr-} ]]; then
    true
  else
    false
  fi
}

function dlg::ini {
  local -n r_aar=${1}

  if [[ -f ${7-} ]]; then
    dlg::ini::cfg "${1}" "${2}" "${7}"
  fi

  {
    printf 'XXX\n%u\n%s\nXXX\n' 0 'keymaps...'
    dlg::ini::lst "${3}" "$(dlg::get::lst::keymaps)"
    printf 'XXX\n%u\n%s\nXXX\n' 25 'timezones...'
    dlg::ini::lst "${4}" "$(dlg::get::lst::timezones)"
    printf 'XXX\n%u\n%s\nXXX\n' 50 'locales...'
    dlg::ini::lst "${5}" "$(dlg::get::lst::locales)"
    printf 'XXX\n%u\n%s\nXXX\n' 75 'drives...'
    dlg::ini::lst "${6}" "$(dlg::get::lst::drives)"
    printf 'XXX\n%u\n%s\nXXX\n' 100 ' '
  } > >(dlg::tui::gauge 'Initializing' ' ' '' '' 0 "${r_aar[color]-}")
}
