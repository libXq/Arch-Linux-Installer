#!/usr/bin/env bash

set -o nounset -o pipefail -o errtrace -o errexit
shopt -s inherit_errexit extglob

source ./src/log/log.sh
source ./src/sys/sys.sh
source ./src/dlg/dlg.sh
source ./src/ins/ins.sh

declare -A _AVS

log::ini
dlg::run _AVS settings.cfg
ins::run _AVS
