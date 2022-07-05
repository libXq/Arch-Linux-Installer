#!/usr/bin/env bash

function ins::maj::make::partitions {
  + wipefs --all "${x[drive]}"
  + sgdisk --zap-all \
    --new=1:0:+512MiB --typecode=1:ef00 \
    --new=2:0:0 --typecode=2:8304 "${x[drive]}"
  + udevadm settle

  x[boot_partition]=$(sys::blk::partition 1 "${x[drive]}")
  x[root_partition]=$(sys::blk::partition 2 "${x[drive]}")
  x[boot_partition_puuid]=$(sys::blk::puuid "${x[boot_partition]}")
  x[root_partition_puuid]=$(sys::blk::puuid "${x[root_partition]}")
}

function ins::maj::make::filesystems {
  + wipefs --all "${x[root_partition]}"
  + wipefs --all "${x[boot_partition]}"

  if [[ ${x[option_nojournal]-} == 1 ]]; then
    + mkfs.ext4 -O ^has_journal "${x[root_partition]}"
  else
    + mkfs.ext4 "${x[root_partition]}"
  fi

  + mkfs.fat -F 32 "${x[boot_partition]}"
}

function ins::maj::make::swapfile {
  x[swap_file]=${x[root_path]}swap

  + dd if=/dev/zero of="${x[swap_file]}" \
    count="$((x[ram_size] * 2 + 4096))B" oflag=noatime \
    status=noxfer
  + chmod 600 "${x[swap_file]}"
  + mkswap "${x[swap_file]}"

  x[swap_file_offset]=$(sys::fle::offset "${x[swap_file]}")
}

function ins::maj::prepare::filesystems {
  local IFS=','
  local -a o=(defaults)

  if [[ ${x[option_noatime]-} == 1 ]]; then
    o+=(noatime)
  fi

  if [[ ${x[option_discard]-} == 1 ]]; then
    o+=(discard)
  fi

  + mount --options="${o[*]}" \
    --source="${x[root_partition]}" \
    --target="${x[root_path]}"

  if [[ ${x[option_swapfile]-} == 1 ]]; then
    ins::maj::make::swapfile
  fi

  + mount --mkdir --options="${o[*]}" \
    --source="${x[boot_partition]}" \
    --target="${x[boot_path]}"
}

function ins::maj::install::system {
  local -a o=(base linux linux-firmware sudo terminus-font)

  case "${x[cpu_vendor]-}" in
  Intel) o+=(intel-ucode) ;;
  AMD) o+=(amd-ucode) ;;
  esac

  if [[ ${x[option_gpuaccel]-} == 1 ]]; then
    case "${x[gpu_module]-}" in
    amdgpu) o+=(libva-mesa-driver) ;;
    i915) o+=(intel-media-driver) ;;
    esac

    o+=(mesa)
  fi

  + pacstrap "${x[root_path]}" "${o[@]}"
}
