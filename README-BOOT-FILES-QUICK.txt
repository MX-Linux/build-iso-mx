README-BOOT-FILES-QUICK - renew the live boot files, copy and paste
===================================================================
The GRUB/shim boot files of the ISO (eltorito.img, efi.img, EFI/boot/*.efi,
boot/grub/{i386-pc,x86_64-efi,i386-efi}) come from ONE GRUB build, made by
Tools/live-boot-files/mk-boot-files straight from Debian's signed packages.
Details, background, troubleshooting:
    Tools/live-boot-files/README-LIVE-BOOT-FILES.txt   (= "the HOWTO" below)

Paths below: build-iso cloned to ~/build-iso-mx (start there),
mx-iso-template to ~/mx-iso-template, sets go to ~/live-boot-files/.
Everything runs as a normal user. Only build-iso itself needs root, and it
calls sudo by itself (do NOT start it with sudo).


WHEN a new round is needed
--------------------------
  - a new GRUB or shim from Debian          -> all steps below
  - a new live-busybox                      -> build-iso busybox/{x64,386},
                                               then steps 4-5
  - new live GRUB menu files (e.g. a PR to  -> Template/COMMON/iso/boot/grub/
    build-iso-mx), even without a new GRUB     config/ + the same in
                                               mx-iso-template, then 4-5

THE ORDER (always the same, even when a step is already done)
-------------------------------------------------------------
  1. build the set                  mk-boot-files (new GRUB/shim only)
  2. set -> build-iso Template/     tar -x, commit
  3. SAME set -> mx-iso-template    tar -x into its 4 trees, commit
  4. build the template package     -> MX repo, AND at the same time into
                                       build-iso Deb/COMMON (so step 5
                                       need not wait for the repo)
  5. run build-iso
Why 3+4 before 5: the ISO gets boot files from two places - its own
Template/ (step 2) AND the mx-iso-template package inside the live system
(mx-snapshot takes the boot files from there). Skip 3+4 and every
snapshot made from the new ISO has the OLD boot files again.


A. MX-25.4: a new GRUB/shim update on trixie (host = MX-25.x)
-------------------------------------------------------------
 1. Is there anything new?
      apt-cache policy grub-pc-bin shim-signed | grep Candidate
      head -3 Template/COMMON/iso/boot/grub/boot-files/MANIFEST
    Same versions -> nothing to do.

 2. Build the set (G = the new grub2 version from step 1)
      G=2.12-9+deb13u4
      OUT=~/live-boot-files/$G
      Tools/live-boot-files/mk-boot-files -o $OUT
    Last lines: "Verify: OK ..." and the tar sha256. Anything else:
    HOWTO section 8.
    Optional: --mac (Intel Mac boot files, see HOWTO 9a).

 3. Look at it
      less $OUT/VERIFY.txt          # no MIXED, no UNKNOWN
      Tools/live-boot-files/inventory-boot-files Template/COMMON/iso $OUT/iso-tree | tail -20
        # = what changed against the template; here "MIXED/UNKNOWN" only
        # means "no package given to compare with" - VERIFY.txt counts

 4. Into build-iso
      for t in iso iso-multi; do
        ( cd Template/COMMON/$t &&
          rm -rf boot/grub/i386-pc boot/grub/x86_64-efi boot/grub/i386-efi &&
          rm -rf EFI/boot EFI/BOOT System mach_kernel &&
          tar -xf $OUT/live-boot-files-$G.tar &&
          sha256sum -c --quiet boot/grub/boot-files/SHA256SUMS && echo "$t OK" )
      done
      git status --short            # only boot files
      git commit -am "boot files: GRUB $G"

 5. The SAME tar into mx-iso-template (its own git clone, 4 trees)
      cd ~/mx-iso-template
      for t in mx-iso-template iso-template-generic mx-iso-template-multi iso-template-generic-multi; do
        ( cd $t &&
          rm -rf boot/grub/i386-pc boot/grub/x86_64-efi boot/grub/i386-efi &&
          rm -rf EFI/boot EFI/BOOT System mach_kernel &&
          tar -xf $OUT/live-boot-files-$G.tar &&
          sha256sum -c --quiet boot/grub/boot-files/SHA256SUMS && echo "$t OK" )
      done
      git add -A && git commit -m "boot files: GRUB $G"

 6. Build the template package (version above the repo's)
      dch -i "boot files: GRUB $G"
      dpkg-buildpackage -rfakeroot -b -uc -us
    The deb lands next to the clone (~/mx-iso-template_<version>_*.deb).
    Upload to the MX repo as usual. For a local test instead: step 7.
      cd ~/build-iso-mx             # back to build-iso

 7. Only for a local test (package not in the repo yet)
      mkdir -p Deb/COMMON
      cp ~/mx-iso-template_<version>_amd64.deb Deb/COMMON/
    Rules for Deb/COMMON (build-iso installs these with apt):
      - the local version must be HIGHER than the repo's: the SAME
        version with other content, or a lower one, is a "downgrade"
        for apt - it stops to ask, and with -y it refuses
      - only ONE mx-iso-template deb in Deb/COMMON
      - NOT iso-template-generic (it conflicts with mx-iso-template)
      - remove it again once the repo has that version (or a newer one)

 8. Build the ISO (normal user; add your usual options, e.g. -a)
      ./build-iso --user-default defaults-Xfce-64

 9. Check the ISO
      ISO=<the new iso>
      Tools/live-boot-files/inventory-boot-files -s "$ISO"   # one GRUB build
      xorriso -indev "$ISO" -report_system_area plain | grep -iE 'offset|mbr'
    Then boot it: BIOS + UEFI + UEFI Secure Boot, DVD + USB (HOWTO 5.4).


B. MX-27: forky boot files, made on MX-25.x (trixie host)
---------------------------------------------------------
Same order as A. Only step 2 differs: --suite gets forky's packages
through a private apt setup in $OUT (no root, the host's apt sources stay
untouched, signatures checked with Debian's archive keyring).

 1.+2. Build the set (takes forky's current versions)
      OUT=~/live-boot-files/forky
      Tools/live-boot-files/mk-boot-files -o $OUT --suite forky
      head -3 $OUT/iso-tree/boot/grub/boot-files/MANIFEST   # "GRUB: grub2 <G>"
      G=<that grub2 version>        # the tar is $OUT/live-boot-files-$G.tar
 3. Look at it (as A3) - and for a NEW release also (HOWTO section 6):
      diff <(ls ~/live-boot-files/2.12-9+deb13u4/iso-tree/boot/grub/x86_64-efi) \
           <(ls $OUT/iso-tree/boot/grub/x86_64-efi)        # removed modules?
      grep -rn insmod Template/COMMON/iso/boot/grub/         # still used?
      strings $OUT/iso-tree/EFI/boot/grubx64.efi | grep '^grub,'   # SBAT
 4.-9. as A4-A9, in the forky branches of build-iso and mx-iso-template,
    with the forky build settings (DEBIAN_RELEASE etc. in your defaults
    file).


C. CHEAT SHEET
--------------
  What is in the template now?   head -3 Template/COMMON/iso/boot/grub/boot-files/MANIFEST
  What is in an ISO?             Tools/live-boot-files/inventory-boot-files -s X.iso
  Same set in build-iso and the template package?
                                 sha256sum Template/COMMON/iso/boot/grub/boot-files/MANIFEST \
                                   ~/mx-iso-template/*/boot/grub/boot-files/MANIFEST
  Reproducible: the same packages always give the same tar sha256 - a
  second person can run A2 and must get the same hash.
  mk-boot-files options:         Tools/live-boot-files/mk-boot-files --help
