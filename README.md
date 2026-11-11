***Note*** the master branch is under development.  If you want the last stable branch, use the "bookworm" branch.

# build-iso-mx
**antiX** build-iso system with settings for MX. This script is used to create variate ISO flavors.


## Requirements

- debootstrap
- genisoimage
- syslinux-utils
- squashfs-tools
- zsync
- expect
- uc-tool-mx (recommended for micrcode injection)


## Running

For usage instructions, run:

- `./build-iso -h` to displays help
- `./build-iso --show-stages` to show the stages of processing
- `./build-iso --show-parts` to show parts of stage-4 and how to control them

Most likely, you would want to run
````
./build-iso --user-default defaults
````
or
````
./build-iso --user-default defaults-kde
````
or whatever `defaults-*` file in the `Input/` directory.

Refer to [README-Custom-Respin.md](README-Custom-Respin.md) for more on customizations.

Bash completion for `build-iso` options is available in `bash-completion/build-iso`.
Source it (e.g. from `~/.bashrc`) to enable it:
````
source /path/to/build-iso-mx/bash-completion/build-iso
````


## Signing the ISO

At the end of stage 8 the ISO is signed with gpg (`SIGN_FILES="true"` in
`Input/defaults-system`): `<iso>.sig` (detached signature) and
`<iso>.sha256.asc` (clear-signed checksum).

It signs as the user who started build-iso, also with `sudo ./build-iso`
(then as `$SUDO_USER`, not root). Optional settings in `Input/defaults-local`:

````
SIGN_KEY="<fingerprint or long key ID>"   # default: gpg's default key
SIGN_AS="root"                            # sign with root's keyring instead
SIGN_PINENTRY="terminal"                  # or "gui"; default "auto"
SIGN_FILES=""                             # don't sign
````

- Without `SIGN_KEY`, gpg picks the key: `default-key` in `~/.gnupg/gpg.conf`
  of the signing user, else the first usable secret key. With more than one
  secret key, set `SIGN_KEY`.
- Find your fingerprint with `gpg --list-secret-keys --keyid-format long`.
- `auto` asks for the passphrase in a desktop dialog when a desktop is
  available, otherwise in the terminal.
- If signing fails, build-iso shows a warning with the likely reason; the
  ISO itself is complete.
- Sign (again) without rebuilding: `./build-iso --sign-only --user-default <defaults-file>`
  (or `--sign-only=<path/to/file.iso>`).
- Use another key just once: `--sign-key=<fingerprint>` (overrides `SIGN_KEY`).
- Don't sign in this run, without editing a defaults file: `--no-sign`;
  sign later with `--sign-only`.
- If `Remaster/iso-files` is not writable for you (e.g. after a sudo run),
  build-iso uses sudo to put the signature files there.

Verify:
````
gpg --verify <iso>.sig <iso>
gpg --verify < <iso>.sha256.asc
sha256sum -c <iso>.sha256
````


## Special notes

Allow roughly 10 GB drive space for most completed projects.

Consider having separate build-iso-mx folders for different architectures.

Best run on a machine with specs of at least:  
- 5th Gen Intel [Quad-Core] or AMD FX 6100 [6-Core] processor
- 8 GB DDR-1333 SDRAM
- Fast SSD with 50+ GB available drive space
- Efficient Cooling System

