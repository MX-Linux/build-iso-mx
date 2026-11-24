README-LIVE-BOOT-FILES.txt
==========================
The GRUB / shim boot files of the MX live ISO: what they are, when to
renew them, and how - for the ISO builder.

Home of the tools: build-iso Tools/live-boot-files/
    mk-boot-files          builds the whole boot file set from Debian's packages
    mk-efi-img.sh          builds efi.img (used by mk-boot-files)
    build-eltorito.sh      the module list of the BIOS cores; lists the
                           modules inside a core image (-l)
    inventory-boot-files   tells which Debian build each boot file is
    snapshot-deb           verified download of OLD Debian packages
                           (snapshot.debian.org), for comparisons
No root is needed for any of them.


Contents
--------
 1. The boot files and the one rule
 2. Where they live: build-iso first, then mx-iso-template
 2a. The order of an update
 3. When to renew them
 4. Prepare the build host
 5. Renew the set - step by step
 6. A new Debian release (e.g. forky)
 7. Making the ISO (xorriso)
 8. Troubleshooting
 9. Reference


1. The boot files and the one rule
----------------------------------
    file (paths as on the ISO)        boots                      from Debian package
    EFI/boot/bootx64.efi              UEFI 64-bit (+Secure Boot) shim-signed
    EFI/boot/mmx64.efi                MOK manager (Secure Boot)  shim-helpers-amd64-signed
    EFI/boot/grubx64.efi              UEFI 64-bit                grub-efi-amd64-signed (gcdx64)
    EFI/boot/bootia32.efi             UEFI 32-bit (64-bit CPU)   grub-efi-ia32-unsigned (gcdia32)
    boot/grub/efi.img                 El Torito UEFI image / ESP the 4 files above + grub.cfg
    boot/grub/i386-pc/eltorito.img    BIOS, GRUB as boot loader  built: grub-mkimage
    boot/grub/i386-pc/core.img        isolinux "Switch to Grub",  built: grub-mkimage
                                      rescue "GRUB loader"
    boot/grub/i386-pc/                BIOS modules               grub-pc-bin
    boot/grub/x86_64-efi/             UEFI 64 modules            grub-efi-amd64-bin
    boot/grub/i386-efi/               UEFI 32 modules            grub-efi-ia32-bin
    boot/grub/boot-files/MANIFEST     which .deb, which version, how built
    boot/grub/boot-files/SHA256SUMS   checksums of all the files above
    (optional, Intel Macs: System/Library/CoreServices/boot.efi + label,
     plist, /mach_kernel - mk-boot-files --mac)

THE RULE: a GRUB core (grubx64.efi, bootia32.efi, eltorito.img,
core.img) only works with modules of the SAME GRUB build. A new core
next to old modules (or the other way round) fails in exactly that boot
mode: "symbol not found", "file ... .mod not found", or a grub> prompt.
So the whole set is always built and replaced together, from one GRUB
version - never single files.

The menus (boot/grub/grub.cfg, config/, theme/), isolinux/syslinux and
the live system are NOT part of the set.


2. Where they live: build-iso first, then mx-iso-template
---------------------------------------------------------
    Debian packages (one GRUB version, one shim version)
        |  Tools/live-boot-files/mk-boot-files
        v
    OUT/live-boot-files-<grub-version>.tar  (+ MANIFEST, SHA256SUMS inside)
        |
        +--> build-iso  Template/COMMON/iso/  and  Template/COMMON/iso-multi/
        |                (build-iso makes the release ISOs)
        |
        +--> mx-iso-template  mx-iso-template/, iso-template-generic/,
                              mx-iso-template-multi/, iso-template-generic-multi/
                              (the package; mx-snapshot takes its boot files
                              from the installed package)
The set is prepared ONCE, in the build-iso preparation step; mx-iso-template
gets the SAME tar. Both say in boot/grub/boot-files/MANIFEST which set
they carry - compare the two MANIFEST files, they must be identical.


2a. The order of an update
--------------------------
Always the same five steps, in this order - also when a step was done
before (then just check it, e.g. the MANIFEST):
    1. build the set              mk-boot-files                      (5.1-5.4)
    2. set -> build-iso           Template/COMMON/iso, iso-multi     (5.5)
    3. SAME set -> mx-iso-template  its 4 trees                      (5.6)
    4. template package           build it, upload to the MX repo   (5.6)
    5. run build-iso                                                 (5.7)
Why 3 and 4 come BEFORE 5: the ISO gets boot files from two places -
its own Template/ (step 2) and the mx-iso-template PACKAGE installed in
the live system (from the repo). mx-snapshot takes its boot files from
that package. Built before step 4, the ISO itself boots with the new set,
but every snapshot made from it gets the OLD set again.
A local test before the package is in the repo: put the new
mx-iso-template deb into build-iso's Deb/COMMON/ (build-iso installs
Deb/ files with apt). Its version must be HIGHER than the repo's (the
same version with other content, or a lower one, is a "downgrade" for
apt: it stops to ask, with -y it refuses); only ONE
mx-iso-template deb there, not iso-template-generic (conflicts); remove
it once the repo has it.
Copy-and-paste version of all this: README-BOOT-FILES-QUICK.txt in the
build-iso top folder.


3. When to renew them
---------------------
- Debian publishes a GRUB or shim update (security fixes, often a new
  SBAT generation - see 9c). Check: apt-cache policy grub-pc-bin shim-signed
  against the "GRUB:" line of boot/grub/boot-files/MANIFEST.
- A new Debian release is the base of the next MX (section 6).
- A change of our own boot setup (efi.img grub.cfg, core module set).
What the template carries right now:
    head -3 Template/COMMON/iso/boot/grub/boot-files/MANIFEST
    Tools/live-boot-files/inventory-boot-files Template/COMMON/iso
(inventory-boot-files also works for any .iso or template tarball, and
names the Debian build when given unpacked packages with -r NAME=DIR.)


4. Prepare the build host
-------------------------
Packages (Tools/prepare-build-host-*.sh installs them):
    apt  dpkg  debian-archive-keyring   download + signature checks
    mtools  dosfstools                  efi.img (FAT, no mount)
    python3  squashfs-tools  xorriso    the self-check (inventory-boot-files)
    isolinux                            isohdpfx.bin for the ISO (section 7)
GRUB itself does NOT have to be installed: the tools take grub-mkimage
from the downloaded packages of the same version.


5. Renew the set - step by step
-------------------------------
5.1 Choose the versions
    Same Debian release as the host:
        apt-cache policy grub-pc-bin shim-signed shim-helpers-amd64-signed
    Another release (e.g. building on trixie for forky): section 6.
    By default mk-boot-files takes apt's candidate versions;
    --grub V --shim V --shim-helpers V pin them.

5.2 Build
        cd build-iso
        Tools/live-boot-files/mk-boot-files -o ~/live-boot-files/<grub-version>
    (any dir outside the git tree; below: OUT = that dir)
    It downloads the packages with apt-get download (apt checks the
    signatures; .debs kept from an earlier run are reused only when their
    SHA256 matches apt's index), unpacks them, builds eltorito.img, core.img, efi.img,
    writes MANIFEST + SHA256SUMS, checks itself and packs the tar.
    Last lines:
        Verify: OK (all files from grub2 <version> / shim, cores = <version> modules)
        <sha256 of the tar>...  (same packages -> same hash)
    Anything else -> section 8.

5.3 Check
        less OUT/iso-tree/boot/grub/boot-files/MANIFEST
        less OUT/VERIFY.txt
    VERIFY.txt compares every file with the packages and every module
    inside the cores; it must not say MIXED or UNKNOWN.
    Compare with what is in the template now:
        Tools/live-boot-files/inventory-boot-files Template/COMMON/iso OUT/iso-tree
    The end of the output lists which files changed.
    Reproducible: the same packages always give the same bytes. A second
    person can run 5.2 and must get the same tar sha256.

5.4 Test before committing (recommended)
    Put the set into an existing ISO and boot it in a VM, or make a
    test build. Check at least:
      - BIOS: from DVD and from USB (dd); isolinux menu "Switch to Grub"
      - UEFI and UEFI with Secure Boot: from DVD and from USB
      - in the GRUB main menu press Esc once: countdown stops, menu stays
      - Boot Rescue Menus -> GRUB menus / GRUB loader with an installed
        system on a disk (the cores must not ask that system for modules)
      - boot to the desktop at least once with Secure Boot on

5.5 Put it into build-iso
    For Template/COMMON/iso and Template/COMMON/iso-multi:
        cd Template/COMMON/iso
        rm -rf boot/grub/i386-pc boot/grub/x86_64-efi boot/grub/i386-efi
        rm -rf EFI/boot EFI/BOOT System mach_kernel
        tar -xf OUT/live-boot-files-<grub-version>.tar
        sha256sum -c --quiet boot/grub/boot-files/SHA256SUMS && echo OK
    Delete the module dirs first: a newer GRUB may drop modules (2.14 drops
    efi_uga, gfxterm_menu, ...); an old .mod left behind is a version mix.
    Then: git status (only boot files may show up), commit.

5.6 Hand the same set to mx-iso-template
    The same tar, the same commands as 5.5, in each of its four trees:
        mx-iso-template/  iso-template-generic/
        mx-iso-template-multi/  iso-template-generic-multi/
    Check: boot/grub/boot-files/MANIFEST identical in build-iso and in all
    four template trees (cmp, or compare the sha256 lines).
    Then build the template package and get it into the MX repo BEFORE
    the build-iso run (2a: else snapshots get the old set). Local test:
    Deb/COMMON (2a).

5.7 Build the ISO as usual, as a normal user (build-iso calls sudo by
    itself): ./build-iso --user-default <defaults file>. Section 7 says
    what build-iso does with the set.


6. A new Debian release (e.g. forky)
------------------------------------
The tools are not tied to trixie. For a release other than the host's:
        Tools/live-boot-files/mk-boot-files -o ~/live-boot-files/forky-<grub-version> --suite forky
    --suite makes a private apt setup in the out dir (no root, the host's
    apt sources are not touched), signature-checked with Debian's archive
    keyring; repeatable (e.g. --suite trixie --suite trixie-security);
    *-security uses security.debian.org; --mirror URL for another mirror.
Checklist for the first set of a new release:
  - grub-mkimage of that release must run on the build host. If the host
    is older (C library too old), mk-boot-files stops with a message:
    run it on a host or in a chroot of the new release.
    (Tested: forky's GRUB 2.14 runs on a trixie host.)
  - Package changes: since 2.14 grub-mkimage & co. are in grub2-common
    (before: grub-common); mk-boot-files fetches both. If Debian renames
    or splits packages again, mk-boot-files stops with "no <pkg>_<version>
    .deb" -> adjust its package list (PKGS/ORDER).
  - Modules removed or added: compare
        diff <(ls OLD_OUT/iso-tree/boot/grub/x86_64-efi) <(ls NEW_OUT/iso-tree/boot/grub/x86_64-efi)
    and search the MX menus for removed ones, e.g. 2.14 has no efi_uga
    and no gfxterm_menu:  grep -rn 'insmod' Template/COMMON/iso/boot/grub/
  - build-eltorito.sh profile "full" drops modules the new GRUB lacks
    (prints a NOTE); new useful modules can be added there.
  - SBAT (9c): strings EFI/boot/grubx64.efi | grep '^grub'
  - Run the whole test list (5.4) - menus, Esc, rescue, Secure Boot.
  - Then the same order as always (2a): build-iso, mx-iso-template, the
    template package, then the build-iso run - in the new release's
    branches.


7. Making the ISO (xorriso)
---------------------------
build-iso makes the hybrid ISO (DVD + USB stick, BIOS + UEFI) in ONE
native xorriso run - no separate isohybrid step. The command is a bash
array with a comment on every option (make_xorriso_iso). In short:
    BIOS:  isolinux (isohdpfx.bin MBR) - or GRUB (eltorito.img +
           boot_hybrid.img from the SAME set) with --grub-only
    UEFI:  boot/grub/efi.img as El Torito image and as EFI partition
    layout: partition 1 starts at 32 KiB (-boot_image any partition_offset=16),
           MBR type 0x00 - clean for fdisk/parted, as Debian's ISOs
    Intel Macs (optional, set built with --mac): HFS+, Apple Partition
           Map, blessed /System/Library/CoreServices/boot.efi
Check a finished ISO:
    xorriso -indev X.iso -report_system_area plain -report_el_torito plain
    xorriso -indev X.iso -report_el_torito cmd     (the native commands)
    /sbin/fdisk -l X.iso
    Tools/live-boot-files/inventory-boot-files X.iso


8. Troubleshooting
------------------
mk-boot-files: "no <pkg>_<version> .deb"
    The version is not in the apt sources (mirror not updated yet, or the
    package was superseded). apt-cache policy <pkg>; or --suite.
mk-boot-files: "grub-mkimage ... does not run on this host"
    Packages of a newer release: build on a host/chroot of that release.
VERIFY.txt says MIXED / "files not from the packages"
    Do not use the set; report it (a package changed in an unexpected way).
GRUB: "symbol not found" / "file .../xyz.mod not found" / grub> prompt
    Core and modules of different builds: an old file was left over, or
    a single file was copied by hand. inventory-boot-files on the ISO
    shows which file is from which build; rebuild the set (5.2) and
    replace it completely (5.5).
UEFI from USB: Esc in the main menu drops to grub>
    efi.img with an old grub.cfg ("configfile"). The set from
    mk-boot-files uses "source" (menu stays top-level).
EFI/BOOT and EFI/boot both on the ISO
    The old upper-case dir was not deleted before tar -xf (5.5).
32-bit UEFI: menu ok, black screen after choosing an entry
    Known; the same with the 25.3 ISOs before the new set. Not caused by
    the boot files.
Secure Boot: "SBAT self-check failed" / "Security Policy Violation"
    The firmware's SbatLevel is higher than the grubx64.efi's generation
    (9c): the set is too old - renew it (section 5).


9. Reference
------------
9a. mk-boot-files options
    -o OUTDIR             output dir (created; e.g. ~/live-boot-files/<grub-version>)
    --suite S / --mirror  another Debian release (section 6)
    --debs DIR            use .debs from DIR (no download); each is checked
                          against apt's index when apt knows the version,
                          else a WARNING
    --grub V --shim V --shim-helpers V   pin versions
    --bootia32 debian|standalone   Debian's gcdia32.efi (default) or a
                          grub-mkstandalone image
    --cores full|minimal  modules built into eltorito.img and core.img:
                          full (default, ~100 modules: filesystems,
                          RAID/LVM/LUKS, loaders, video) or minimal: the
                          small lists as used by MX-25.3 (mid Nov 2026)
    --efi-cfg FILE        another grub.cfg inside efi.img
    --mac [LABEL]         + Intel Mac files (boot.efi = 32+64-bit GRUB
                          glued, boot picker label)
    --force               rebuild into an existing out dir

9b. Why the cores carry the full module set
    The rescue menus can switch GRUB's $prefix to a FOUND system ("GRUB
    menus"), or start core.img from another stick ("GRUB loader"). From
    then on every module the core does not carry is loaded from THERE -
    another GRUB build, or no i386-pc dir at all (EFI-only installs).
    Tested: with the 11-module core of 2026 "insmod linux" gave
    "linux.mod not found"; with the full core all modules are resident.

9c. SBAT in short
    Every signed EFI file carries a table of "security generations", e.g.
    grub,7. The firmware keeps a minimum (SbatLevel); shim refuses files
    below it. The level only goes up (shim, distro or Windows updates)
    and only matters with Secure Boot on. A GRUB security fix that makes
    old files unsafe raises the generation - an ISO with an older file
    stops booting with Secure Boot once the level is raised. So renew the
    set when Debian raises it.

9d. Reproducible builds
    All file times = the grub2 changelog date (SOURCE_DATE_EPOCH, UTC),
    fixed FAT serial, sorted tar. The MANIFEST holds the .deb SHA256s and
    the exact rebuild command.
