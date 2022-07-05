#!/usr/bin/env bash

function dlg::tui::menu {
  local -n r_var=${1}
  local -n r_arr=${2}
  local out

  out=$(NEWT_COLORS=${8-} whiptail ${3:+--title="${3}"} \
    --notags --default-item="${r_var-}" \
    --menu "${4-}" "${5:-18}" "${6:-52}" "${7:-10}" \
    "${r_arr[@]}" 3>&1 1>&2 2>&3) || return

  r_var=${out}
}

function dlg::tui::radiolist {
  local -n r_var=${1}
  local -n r_arr=${2}
  local -a arr
  local -i i
  local out

  if [[ -n ${r_var-} ]]; then
    for ((i = 0; i < ${#r_arr[@]} - 1; i += 2)); do
      if [[ ${r_arr[i]} == "${r_var}" ]]; then
        arr+=("${r_arr[i]}" "${r_arr[i + 1]}" 'ON')
      else
        arr+=("${r_arr[i]}" "${r_arr[i + 1]}" 'OFF')
      fi
    done
  else
    for ((i = 1; i < ${#r_arr[@]}; i += 2)); do
      arr+=("${r_arr[i - 1]}" "${r_arr[i]}" 'OFF')
    done
  fi

  while out=$(NEWT_COLORS=${8-} whiptail ${3:+--title="${3}"} \
    --notags \
    --radiolist "${4-}" "${5:-18}" "${6:-52}" "${7:-10}" \
    "${arr[@]}" 3>&1 1>&2 2>&3) || return; do
    if [[ -n ${out} ]]; then
      r_var=${out}
      break
    fi
  done
}

function dlg::tui::checklist {
  local -n r_var=${1}
  local -n r_arr=${2}
  local -a arr
  local -i i
  local out

  if [[ -n ${r_var-} ]]; then
    local -a t_arr
    local -i j

    readarray -t t_arr <<<${r_var}

    for ((i = 0, j = 0; i < ${#r_arr[@]} - 1; i += 2)); do
      if ((j < ${#t_arr[@]})) &&
        [[ ${r_arr[i]} == "${t_arr[j]}" ]]; then
        arr+=("${r_arr[i]}" "${r_arr[i + 1]}" 'ON')
        ((++j))
      else
        arr+=("${r_arr[i]}" "${r_arr[i + 1]}" 'OFF')
      fi
    done
  else
    for ((i = 1; i < ${#r_arr[@]}; i += 2)); do
      arr+=("${r_arr[i - 1]}" "${r_arr[i]}" 'OFF')
    done
  fi

  out=$(NEWT_COLORS=${8-} whiptail ${3:+--title="${3}"} \
    --notags --separate-output \
    --checklist "${4-}" "${5:-18}" "${6:-52}" "${7:-10}" \
    "${arr[@]}" 3>&1 1>&2 2>&3) || return

  if [[ -n ${out} ]]; then
    r_var=${out}
  else
    r_var=''
  fi
}

function dlg::tui::inputbox {
  local -n r_var=${1}
  local out

  while out=$(NEWT_COLORS=${6-} whiptail ${2:+--title="${2}"} \
    --inputbox "${3-}" "${4:-8}" "${5:-52}" \
    "${r_var-}" 3>&1 1>&2 2>&3) || return; do
    if [[ ${out} == +([[:graph:]]) ]]; then
      r_var=${out}
      break
    fi
  done
}

function dlg::tui::passwordbox {
  local -n r_var=${1}
  local out

  while out=$(NEWT_COLORS=${6-} whiptail ${2:+--title="${2}"} \
    --passwordbox "${3-}" "${4:-8}" "${5:-52}" \
    "${r_var-}" 3>&1 1>&2 2>&3) || return; do
    if [[ ${out} == +([[:graph:]]) ]]; then
      r_var=${out}
      break
    fi
  done
}

function dlg::tui::messagebox {
  (NEWT_COLORS=${5-} whiptail ${1:+--title="${1}"} \
    --msgbox "${2-}" "${3:-12}" "${4:-52}" \
    2>/dev/null)
}

function dlg::tui::yesnobox {
  (NEWT_COLORS=${5-} whiptail ${1:+--title="${1}"} \
    --yesno "${2-}" "${3:-12}" "${4:-52}" \
    2>/dev/null)
}

function dlg::tui::gauge {
  (NEWT_COLORS=${6-} whiptail ${1:+--title="${1}"} \
    --gauge "${2-}" "${3:-6}" "${4:-52}" "${5:-0}" \
    2>/dev/null)
}
