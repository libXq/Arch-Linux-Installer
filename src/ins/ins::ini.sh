#!/usr/bin/env bash

function ins::ini::var {
  x[root_path]=/mnt/
  x[boot_path]=/mnt/boot/
}

function ins::ini::sysinfo {
  x[ram_size]=$(sys::mem::total)
  x[cpu_vendor]=$(sys::cpu::vendor)
  x[gpu_vendor]=$(sys::gpu::vendor)
  x[gpu_module]=$(sys::gpu::module)
}

function ins::ini::time {
  + timedatectl set-timezone "${x[timezone]}"
  + timedatectl set-ntp true

  while :; do
    sleep 1
    if [[ $(timedatectl |
      grep --max-count=1 --only-matching --ignore-case --perl-regexp \
        --regexp='^system\s*clock\s*synchronized\s*[[:punct:]]*\s*\K\w+') == yes ]]; then
      break
    fi
  done

  + hwclock --systohc --utc
}

function ins::ini::mirrorlist {
  + tee /etc/pacman.d/mirrorlist <<<$(
    reflector --latest=5 --protocol=https \
      --sort=rate 2>/dev/null |
      grep --line-regexp --regexp='Server.*'
  )
}

function ins::ini {
  ins::ini::var
  ins::ini::sysinfo
  ins::ini::time
  ins::ini::mirrorlist
}
