#!/usr/bin/env bash

source ./src/dlg/dlg::fmt.sh
source ./src/dlg/dlg::get.sh
source ./src/dlg/dlg::ini.sh
source ./src/dlg/dlg::tui.sh

function dlg::export {
  local -n r_aar_src=${1}
  local -n r_aar_dst=${2}
  local i

  for i in keymap timezone locale drive hostname; do
    if [[ -n ${r_aar_src["${i}"]-} ]]; then
      r_aar_dst["${i}"]=${r_aar_src["${i}"]}
    fi
  done

  if [[ -n ${r_aar_src[options]-} ]]; then
    local IFS=$'\n'

    for i in ${r_aar_src[options]}; do
      r_aar_dst["option_${i}"]=1
    done
  fi
}

function dlg::run {
  local -n r_aar=${1}
  local -A sts sls
  local -a ops kms tzs lcs drs lst

  dlg::ini sts ops kms tzs lcs drs "${2-}"

  while true; do
    lst=(
      1 "$(printf '{%-1s} %s' "${sls[keymap]:+*}" 'Select Keymap')"
      2 "$(printf '{%-1s} %s' "${sls[timezone]:+*}" 'Select Timezone')"
      3 "$(printf '{%-1s} %s' "${sls[locale]:+*}" 'Select Locale')"
      4 "$(printf '{%-1s} %s' "${sls[drive]:+*}" 'Select Drive')"
      5 "$(printf '{%-1s} %s' "${sls[hostname]:+*}" 'Set Hostname')"
    )

    if [[ -n ${ops-} ]]; then
      lst+=(6 "$(printf '{%-1s} %s' "${sls[options]:+*}" 'Additional Options')")
    fi

    if [[ -n ${sls[keymap]-} && -n ${sls[timezone]-} && -n \
      ${sls[locale]-} && -n ${sls[drive]-} && -n \
      ${sls[hostname]-} ]]; then
      lst+=(7 'Start Installation')
    fi

    dlg::tui::menu sls[0] lst 'Arch Linux Installer' '' \
      "${sts[height]-}" "${sts[width]-}" \
      "${sts[height_sub]-}" "${sts[color]-}" ||
      { { ((${?} != 1)) && false; } || {
        log::message 'aborted'
        exit
      }; }

    case "${sls[0]}" in
    1)
      dlg::tui::radiolist sls[keymap] kms 'Keymap' '' \
        "${sts[height]-}" "${sts[width]-}" \
        "${sts[height_sub]-}" "${sts[color]-}" ||
        { ((${?} != 1)) && false; }
      ;;
    2)
      dlg::tui::radiolist sls[timezone] tzs 'Timezone' '' \
        "${sts[height]-}" "${sts[width]-}" \
        "${sts[height_sub]-}" "${sts[color]-}" ||
        { ((${?} != 1)) && false; }
      ;;
    3)
      dlg::tui::radiolist sls[locale] lcs 'Locale' '' \
        "${sts[height]-}" "${sts[width]-}" \
        "${sts[height_sub]-}" "${sts[color]-}" ||
        { ((${?} != 1)) && false; }
      ;;
    4)
      dlg::tui::radiolist sls[drive] drs 'Drive' '' \
        "${sts[height]-}" "${sts[width]-}" \
        "${sts[height_sub]-}" "${sts[color]-}" ||
        { ((${?} != 1)) && false; }
      ;;
    5)
      dlg::tui::inputbox sls[hostname] 'Hostname' '' \
        "${sts[height]-}" "${sts[width]-}" \
        "${sts[color]-}" ||
        { ((${?} != 1)) && false; }
      ;;
    6)
      dlg::tui::checklist sls[options] ops 'Additional Options' '' \
        "${sts[height]-}" "${sts[width]-}" \
        "${sts[height_sub]-}" "${sts[color]-}" ||
        { ((${?} != 1)) && false; }
      ;;
    7)
      {
        dlg::tui::yesnobox 'Start Installation' \
          "$(dlg::fmt::summary sls)" \
          "${sts[height]-}" "${sts[width]-}" \
          "${sts[color]-}" &&
          dlg::export sls r_aar &&
          break
      } ||
        { ((${?} != 1)) && false; }
      ;;
    esac
  done
}
