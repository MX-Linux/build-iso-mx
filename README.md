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


## Special notes

Allow roughly 10 GB drive space for most completed projects.

Consider having separate build-iso-mx folders for different architectures.

Best run on a machine with specs of at least:  
- 5th Gen Intel [Quad-Core] or AMD FX 6100 [6-Core] processor
- 8 GB DDR-1333 SDRAM
- Fast SSD with 50+ GB available drive space
- Efficient Cooling System

