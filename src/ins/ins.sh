#!/usr/bin/env bash

source ./src/ins/ins::ini.sh
source ./src/ins/ins::maj.sh
source ./src/ins/ins::con.sh

function ins::run {
  local -n x=${1}

  ins::ini
  log::message 'Making partitions...'
  ins::maj::make::partitions
  log::message 'Making filesystems...'
  ins::maj::make::filesystems
  log::message 'Preparing filesystems...'
  ins::maj::prepare::filesystems
  log::message 'Install system...'
  ins::maj::install::system
  log::message 'Configure system...'
  ins::con::time
  ins::con::host
  ins::con::locale
  ins::con::vconsole
  ins::con::sysctl
  ins::con::modprobe
  ins::con::mkinitcpio
  ins::con::fstab
  ins::con::systemd
  ins::con::systemd::boot
  ins::con::sudo
  ins::con::users
  log::message 'Installation complete'
}
