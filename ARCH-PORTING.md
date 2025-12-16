# Arch Support (Porting Notes)

This repository is designed around the antiX/MX live stack (Debian-family bootstrap + a custom initrd that mounts `antiX/linuxfs`). Arch support is being added using the “B” approach: keep the stage pipeline and ISO layout, but swap Debian-specific tooling for Arch where possible.

## Current Status
- Stage 0: supports `DISTRO_FAMILY=arch` and uses `Template/Arch/`.
- Stage 2: uses `pacstrap` to create the root filesystem.
- Stage 4 (in chroot): uses `pacman` + `mkinitcpio`, builds an `archiso.img`, generates locales, and creates the live user.
- Stage 6–8: create an archiso-style ISO layout and build the ISO via `grub-mkrescue` (experimental).

## Debian → Arch command mapping
- Bootstrap: `debootstrap` → `pacstrap` (from `arch-install-scripts`)
- Chroot helper: `chroot` → `arch-chroot` (recommended, optional)
- Update/install: `apt-get update/install` → `pacman -Syu` / `pacman -S --needed`
- Remove: `apt-get purge/autoremove` → `pacman -Rns`
- Package list: `dpkg-query -l` → `pacman -Qqe` (or `pacman -Qq`)
- Initramfs: `initramfs-tools` → `mkinitcpio -P`
- Locale: `update-locale` → write `/etc/locale.conf` + run `locale-gen`

## What’s still missing (bootable Arch ISO)
To boot an Arch-based live system, we must implement an Arch-compatible initramfs + boot parameters that can:
1) discover the ISO medium,
2) mount the squashfs (`antiX/linuxfs`) or change the ISO layout to an Arch-compatible one,
3) set up overlay/persistence (optional),
4) `switch_root` into the live rootfs.

Practical options:
- **Reuse existing antiX initrd**: port init scripts to work with an Arch rootfs (busybox, mount helpers, `udev`/`systemd` differences, library paths).
- **Embed an archiso-style initramfs**: keep this repo’s ISO assembly but adopt archiso init hooks and filesystem layout expectations.

## mx-remaster considerations
`~/mx-remaster/installed-to-live` and `live-files/*` are apt/debconf oriented (repo localization, dpkg prompts). For Arch, only the generic parts are directly reusable:
- bind-mount templating and exclude list generation,
- persistence helpers (after adapting mount/layout expectations),
- squashfs tooling wrappers.

## Validation Checklist (once Stage 6+ is implemented)
- Debian/MX host needs extra pacman pieces: `pacman-package-manager`, `makepkg`, `archlinux-keyring` (Debian installs keyrings under `/usr/share/keyrings`; the builder links them into `/usr/share/pacman/keyrings`).
- Build host has: `pacstrap`, `pacman`, `mksquashfs`, ISO tool (`xorriso` or `genisoimage`), bootloader tooling used by this repo.
- Stage 2 creates a bootable rootfs: `/etc/pacman.d/mirrorlist` exists, `pacman -Q` works in chroot.
- Stage 4 produces: `LIVE_USER` exists, `locale-gen` ran, `mkinitcpio -P` succeeds, and basic tooling exists (e.g. `hostname` from `inetutils`).
- If pacman reports “could not determine cachedir mount point” or “not enough free disk space”, ensure `/proc` is mounted in-chroot and there is sufficient free space under `/var/cache/pacman/pkg` (downloads are large).
- If `mount` inside the chroot says “failed to read mtab”, create `/etc/mtab` as a symlink to `/proc/self/mounts` (the Arch chroot path now does this automatically).
- If archiso is installed but `/usr/share/archiso/configs/*/mkinitcpio.conf` is missing, the builder falls back to a minimal mkinitcpio config that uses `archiso` hooks (requires the `archiso` mkinitcpio hooks to be installed in the target).
- On some Arch snapshots the mkinitcpio hooks are provided by `mkinitcpio-archiso`; the builder will attempt to install it if hooks are missing.
- ISO boots in UEFI+BIOS: kernel+initramfs load, live root mounts, login works.
- Core runtime checks on the live system: `pacman -Syu` works, DNS works, `journalctl` shows no critical boot failures, shutdown/reboot work.
