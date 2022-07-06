#!/usr/bin/env bash

function sys::mem::total {
  lsmem --bytes --summary=only |
    grep --max-count=1 --only-matching --ignore-case --perl-regexp \
      --regexp='^total\s*online\s*memory\s*[[:punct:]]*\s*\K\d+'
}

function sys::cpu::vendor {
  lscpu |
    grep --max-count=1 --only-matching --ignore-case --perl-regexp \
      --regexp='^vendor\s*id\s*[[:punct:]]*\s*\w*\K(intel|amd)'
}

function sys::gpu::vendor {
  lspci -v -mm -k |
    grep --after-context=1 --ignore-case --word-regexp --perl-regexp \
      --regexp='(display|3d|vga\s+compatible)\s+controller' |
    grep --max-count=1 --only-matching --ignore-case --perl-regexp \
      --regexp='^vendor\s*[[:punct:]]*\s*\K\w+'
}

function sys::gpu::module {
  lspci -v -mm -k |
    grep --after-context=6 --ignore-case --word-regexp --perl-regexp \
      --regexp='(display|3d|vga\s+compatible)\s+controller' |
    grep --max-count=1 --only-matching --ignore-case --perl-regexp \
      --regexp='^driver\s*[[:punct:]]*\s*\K\w+'
}

function sys::blk::drives {
  lsblk --raw --nodeps --noheadings --exclude=7,11 --output=PATH |
    grep --only-matching --perl-regexp \
      --regexp='^\K/dev/\w+'
}

function sys::blk::partition {
  lsblk --raw --noheadings --output=MAJ:MIN,PATH "${2}" |
    grep --max-count=1 --only-matching --perl-regexp \
      --regexp="^\d+:${1}\s+\K/dev/\w+"
}

function sys::blk::puuid {
  lsblk --raw --noheadings --output=PARTUUID "${1}" |
    grep --max-count=1 --only-matching --perl-regexp \
      --regexp='^\K[-[:alnum:]]+'
}

function sys::fle::offset {
  filefrag -v "${1}" |
    grep --max-count=1 --only-matching --perl-regexp \
      --regexp='^\s*0:\s+0\.\.\s+\d+:\s+\K\d+'
}
