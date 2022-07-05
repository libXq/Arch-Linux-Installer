#!/usr/bin/env bash

function dlg::get::lst::keymaps {
  local -a arr
  local i

  while read -r i; do
    if loadkeys --parse --quiet "${i}" &>/dev/null; then
      arr+=("${i}" "$(dlg::fmt::keymap "${i}")")
    fi
  done < <(
    basename --suffix=.map.gz \
      /usr/share/kbd/keymaps/mac/all/mac!(*@(dvorak|template)*).map.gz \
      /usr/share/kbd/keymaps/i386/@(azerty|qwert[zy])/!(@(azerty|emacs|defkeymap)*).map.gz
  )

  [[ -n ${arr-} ]] &&
    printf '%s=%s\n' "${arr[@]}" |
    sort --field-separator='=' \
      --key=2,2 \
      --key=1,1 --unique
}

function dlg::get::lst::timezones {
  local -a arr
  local i j

  while IFS=$'\t ' read -r i j _; do
    if [[ ${i} == [Zz] && ${j} =~ ^(.*/)?[[:upper:]]{3,}.*$ && -f \
      /usr/share/zoneinfo/${j} ]]; then
      arr+=("${j}" "$(dlg::fmt::timezone "${j}")")
    fi
  done </usr/share/zoneinfo/tzdata.zi

  [[ -n ${arr-} ]] &&
    printf '%s=%s\n' "${arr[@]}" |
    sort --field-separator='=' \
      --key=1.2,1.7 --key=2.2,2.4gr \
      --key=1,1 --unique
}

function dlg::get::lst::locales {
  local -a arr
  local i

  while IFS=$'\t ' read -r i j _; do
    if [[ ${i} =~ ^\#*([[:lower:]]{2,3}_[[:upper:]]{2}([.@][-[:alnum:]]+)?)$ && \
      ${j} == +([-[:alnum:]]) ]]; then
      arr+=("${BASH_REMATCH[1]}" "$(dlg::fmt::locale "${BASH_REMATCH[1]} ${j}")")
    fi
  done </etc/locale.gen

  [[ -n ${arr-} ]] &&
    printf '%s=%s\n' "${arr[@]}" |
    sort --field-separator='=' \
      --key=2,2 \
      --key=1,1 --unique
}

function dlg::get::lst::drives {
  local -a arr
  local i

  while read -r i; do
    if [[ -b ${i} ]]; then
      arr+=("${i}" "$(dlg::fmt::drive "${i}")")
    fi
  done < <(
    lsblk --raw --nodeps --noheadings \
      --exclude=7,11 --output=PATH
  )

  [[ -n ${arr-} ]] &&
    printf '%s=%s\n' "${arr[@]}"
}
