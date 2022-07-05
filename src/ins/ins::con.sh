#!/usr/bin/env bash

function ins::con::time {
  + arch-chroot "${x[root_path]}" ln --symbolic --force \
    /usr/share/zoneinfo/"${x[timezone]}" /etc/localtime
}

function ins::con::host {
  + tee "${x[root_path]}"etc/hostname <<<${x[hostname]}

  + tee --append "${x[root_path]}"etc/hosts <<-EOF
		127.0.0.1 localhost
		::1       localhost
		127.0.1.1 ${x[hostname]}
	EOF
}

function ins::con::locale {
  + tee "${x[root_path]}"etc/locale.conf <<-EOF
		LANG=${x[locale]}
		LC_COLLATE=C.UTF-8
	EOF

  + tee "${x[root_path]}"etc/locale.gen <<<$(
    sed \
      --expression="/#${x[locale]}/s/^#//" \
      "${x[root_path]}"etc/locale.gen
  )

  + arch-chroot "${x[root_path]}" locale-gen
}

function ins::con::vconsole {
  + tee "${x[root_path]}"etc/vconsole.conf <<-EOF
		KEYMAP=${x[keymap]}
		FONT=ter-112n
	EOF
}

function ins::con::sysctl {
  if [[ -f ${x[swap_file]-} ]]; then
    + tee "${x[root_path]}"etc/sysctl.d/99-swappiness.conf <<<'vm.swappiness=10'
  fi
}

function ins::con::modprobe {
  if [[ ${x[option_nowatchdog]-} == 1 ]]; then
    + tee "${x[root_path]}"etc/modprobe.d/blacklist.conf <<<'blacklist iTCO_wdt'
  fi
}

function ins::con::mkinitcpio {
  local -r IFS=' '
  local -a m=(
    "${x[gpu_module]}"
  )
  local -a h=(
    systemd
    autodetect
    modconf
    block
    filesystems
    keyboard
    sd-vconsole
    fsck
  )

  + tee "${x[root_path]}"etc/mkinitcpio.conf <<<$(
    sed \
      --expression="s/^MODULES=.*/MODULES=(${m[*]})/" \
      --expression="s/^HOOKS=.*$/HOOKS=(${h[*]})/" \
      "${x[root_path]}"etc/mkinitcpio.conf
  )

  + arch-chroot "${x[root_path]}" mkinitcpio -P
}

function ins::con::fstab {
  local f

  f=$(
    genfstab -t PARTUUID -P "${x[root_path]}" |
      sed --regexp-extended \
        --expression='/^[[:blank:]]*$/d' \
        --expression='s/^[[:blank:]]+//' \
        --expression='s/[[:blank:]]+$//' \
        --expression='s/[[:blank:]]+/ /g' \
        --expression='/^[[:blank:]]*#.*/d'
  )

  if [[ -f ${x[swap_file]-} ]]; then
    f+=$'\n'"${x[swap_file]/*\//\/} none swap defaults 0 0"
  fi

  + tee "${x[root_path]}"etc/fstab <<<${f}
}

function ins::con::systemd {
  + tee "${x[root_path]}"etc/systemd/journald.conf <<<$(
    sed \
      --expression='s/#Storage=.*/Storage=volatile/' \
      "${x[root_path]}"etc/systemd/journald.conf
  )
}

function ins::con::systemd::boot {
  local -r IFS=' '
  local o=(
    options
    root=PARTUUID="${x[root_partition_puuid]}"
    rw
  )

  if [[ -n ${x[swap_file_offset]-} ]]; then
    o+=(
      resume=PARTUUID="${x[root_partition_puuid]}"
      resume_offset="${x[swap_file_offset]}"
    )
  fi

  + arch-chroot "${x[root_path]}" bootctl install
  + mkdir "${x[root_path]}"etc/pacman.d/hooks/

  + tee "${x[root_path]}"etc/pacman.d/hooks/100-systemd-boot.hook <<-'EOF'
		[Trigger]
		Type = Package
		Operation = Upgrade
		Target = systemd

		[Action]
		Description = Upgrading systemd-boot...
		When = PostTransaction
		Exec = /usr/bin/systemctl restart systemd-boot-update.service
	EOF

  + tee "${x[boot_path]}"loader/loader.conf <<-'EOF'
		default linux.conf
		timeout 0
		console-mode max
		editor no
	EOF

  + tee "${x[boot_path]}"loader/entries/linux.conf <<-EOF
		title Linux
		linux /vmlinuz-linux
		initrd /${x[cpu_vendor],,}-ucode.img
		initrd /initramfs-linux.img
		${o[*]}
	EOF
}

function ins::con::sudo {
  + tee "${x[root_path]}"etc/sudoers <<<$(
    sed \
      --expression='/# %wheel ALL=(ALL:ALL) ALL/s/^# //' \
      "${x[root_path]}"etc/sudoers
  )
}

function ins::con::users {
  + arch-chroot "${x[root_path]}" useradd \
    --create-home --skel=/var/empty \
    --groups=wheel,input,audio,video,rfkill,kvm \
    user

  + arch-chroot "${x[root_path]}" passwd user <<<$'user\nuser'

  + arch-chroot "${x[root_path]}" passwd root <<<$'root\nroot'
}
