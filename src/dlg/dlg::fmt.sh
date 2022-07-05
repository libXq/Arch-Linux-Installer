#!/usr/bin/env bash

function dlg::fmt::keymap {
  local -l i
  local -u j

  if [[ ${1} == mac[-._]* ]]; then
    IFS='_' read -r _ i j <<<${1//[-.]/_}
    j=MAC${j:+_"${j}"}
  else
    IFS='_' read -r i j <<<${1//[-.]/_}
  fi

  case "${i}" in
  [[:lower:]][[:lower:]]) ;;

  [[:lower:]][[:lower:]]@(+([[:digit:]])|win|alt))
    j=${i:2}${j:+_"${j}"}
    i=${i:0:2}
    ;;
  wangbe?(+([[:digit:]])))
    j=${i/be/}${j:+_"${j}"}
    i=be
    ;;
  tr[fq])
    j=${i:2}${j:+_"${j}"}
    i=tr
    ;;
  @(bashkir|slovene|kyrgyz))
    i=${i:0:2}
    ;;
  croat)
    i=hr
    ;;
  kazakh)
    i=kk
    ;;
  *)
    j=${i}${j:+_"${j}"}
    i=ww
    ;;
  esac

  case ${j} in
  *UTF_8*)
    j=${j/UTF_8/UTF-8}
    ;;
  *KOI8_R*)
    j=${j/KOI8_R/KOI8-R}
    ;;
  esac

  echo "${i}${j:+ ("${j//[_]/) (}")}"
}

function dlg::fmt::timezone {
  local i
  local -u j

  IFS=' ' read -r i j < <(
    TZ=${1} date '+%::z %Z'
  )

  if [[ ${j} != +([[:alpha:]]) ]]; then
    j=${1##*/}
    j=${j//[![:alpha:]]/}
  fi

  echo "(${i})${j:+ "${j}"}"
}

function dlg::fmt::locale {
  local i
  local -u j k

  IFS=' .@' read -r i j k <<<${1}

  if [[ -n ${k} && ${k} != "${j}" ]]; then
    echo "${i} (${k}) (${j})"
  else
    echo "${i}${j:+ ("${j}")}"
  fi
}

function dlg::fmt::drive {
  local i
  local -u j k

  IFS=' ' read -r i j k < <(
    lsblk --raw --nodeps --noheadings \
      --output=MODEL,SIZE,KNAME "${1}"
  )

  echo "${i//\\x20/ }${j:+ ("${j}")}${k:+ ("${k}")}"
}

function dlg::fmt::summary {
  local -n r_aar=${1}
  local i

  for i in keymap timezone locale drive; do
    if [[ -n ${r_aar["${i}"]-} ]]; then
      printf '%-8s : %s\n' "${i}" \
        "$("dlg::fmt::${i}" "${r_aar["${i}"]}")"
    fi
  done

  if [[ -n ${r_aar[hostname]-} ]]; then
    printf '%-8s : %s\n' 'Hosntame' \
      "${r_aar[hostname]}"
  fi

  if [[ -n ${r_aar[options]-} ]]; then
    printf '\n%-8s : %s\n' 'Options' \
      "${r_aar[options]//$'\n'/, }"
  fi
}
