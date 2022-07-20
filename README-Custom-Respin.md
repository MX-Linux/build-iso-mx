# All changes need to be preformed within the bulid-iso-mx folder as cloned from the git repo

Example based on adding a 32-bit MX Base iso.  For this exercise, we'll be integrating a new 
template and theme for an ISO we'll call "mxbase32"

````
$ git clone https://github.com/MX-Linux/build-iso-mx
$ cd build-iso-mx
````


## Templates

In the Template folder, copy the template of the build that is the closest fit, e.g.
````
$ cp -r mx32 mxbase32
````

Now we have a template, we need to edit the packages.list file to include/exclude 
packages as needed for the build.


## Themes

Familiarise yourself with how each theme is laid out and either use one as is, or 
create a new one that fits your need. If creating a new theme, be sure to follow
the same layout and structure as the themes already in use. 

When build-iso runs, you will be given an opportunity to choose a theme.


## Build Variables

The variables are stored in what's called `defaults`.

There are three files that is of your concern, with their precedence 

- `defaults-system` -- lowest
- `defaults` or `defaults-<buildname>`
- `defaults-local` -- highest

The `<buildname>` can be `base`, `kde`, `min`, etc. (see the Input folder for more examples).
It can also be a name of your own liking, as long as you put it in the Input folder.

Start with `defaults-system` to see what values are available,
then override it on your `defaults-<buildname>` (if you're to create one).
Try not to change `defaults-local` too often and consider it for temporary use (e.g. testing).

You can also use `defaults` or `defaults-base` as your boilerplate to create your own, e.g.
````
$ cp defaults-base defaults-base32
````


### Provisioning the ISO naming schema

In the Input folder, edit the defaults file to add your distro name, look for line/s containing `DISTRO_VERSION="<version>"`

Type the version name you wish to add into a new line and comment out those no longer required by placing `#` in front, e.g.

    #DISTRO_VERSION="21.1"
    DISTRO_VERSION="21.1_base32"   <-- this line was added


### Adjusting the system defaults to match your preferences

Available variables

- `ARCH` -- pick between `amd64` and `i386`
- `DISTRO_NAME` -- you can pick a distro name, default: `MX`
- `RELEASE_DATE` -- change to today's date

----

- `ENABLE_LOCALES` -- pick one of `Default`, `Single`, and `All`
- `DEBIAN_RELEASE` -- debian version to base on, e.g. `bullseye`
- `MIRROR` -- debian mirror, default: `us`
- `LOCALE` -- a valid unix locale, default: `en_US.UTF-8`
- `TIME_ZONE` -- a valid timezone, default: `America/New_York`

----

- `LIVE_USER` -- default username, default: `demo`
- `NEW_HOSTNAME` -- arbitrary system hostname, default: `mx1`


### Setting Kernel type and revision

Using the example above, changing the revision to a higher number is all that's needed
to intall the latest security patched kernel revision.
Consult to the Debian package repo to check for the highest available revision number.
You can also use `K_REVISION="*"` to refer to the latest value.

Available variables:

- `K_VERSION`="5.10.0"             <---- Select the kernel Version
- `K_REVISION`="13"                <---- Change to match latest kernel Revision #
- `K_TEMPLATE`="%V%G-%R-%A"        <---- Ensure the template matches your Architecture
- `UNSIGNED`=""

Variables for `K_TEMPLATE` starts with `%`:

- `V`: value of `K_VERSION`
- `G`: not actually used
- `R`: value of `K_REVISION`
- `A`: is architecture.


### Choosing compression for the ISO

In the Input folder, edit the defaults file to change compression type.
When producing an ISO for release, uncomment the 2 lines with zx as the compression 
type and comment out the 2 lines with lz4 as compression type to produce an ISO
that is roughly 30% smaller.

    #COMPRESSION_TYPE="xz"
    #COMPRESSION_TYPE_CODE="-comp xz -Xbcj x86"
    COMPRESSION_TYPE="lz4"
    COMPRESSION_TYPE_CODE="-comp lz4 -Xhc"
