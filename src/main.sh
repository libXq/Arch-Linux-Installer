#!/usr/bin/env bash

set -o errtrace -o errexit -o pipefail -o nounset
shopt -s inherit_errexit extglob

source ./src/log/log.sh
source ./src/sys/sys.sh
source ./src/dlg/dlg.sh
source ./src/ins/ins.sh

declare -A AVS

log::ini
dlg::run AVS config.ini
ins::run AVS
