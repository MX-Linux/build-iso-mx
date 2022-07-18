# All changes need to be preformed within the bulid-iso-mx folder as cloned from the git repo

Example based on adding a 32-bit MX Base iso.  For this exercise, we'll be integrating a new 
template and theme for an ISO we'll call "mxbase32"

````
$ git clone https://github.com/MX-Linux/build-iso-mx
$ cd build-iso-mx
````


## Creating the required template.

In the Template folder, copy the template of the build that is the closest fit, e.g.
````
$ cp -r mx32 mxbase32
````

Now we have a template, we need to edit the packages.list file to include/exclude 
packages as needed for the build.


## Using (or creating) a theme for the new build

Familiarise yourself with how each theme is laid out and either use one as is, or 
create a new one that fits your need. If creating a new theme, be sure to follow
the same layout and structure as the themes already in use. 

When build-iso runs, you will be given an opportunity to choose a theme.


## Provisioning the ISO naming schema

In the Input folder, edit the defaults file to add your distro name, look for line/s containing `DISTRO_VERSION="21.1"`

Type the version name you wish to add into a new line and comment out those no longer required by placing `#` in front.

example:

    #DISTRO_VERSION="21.1"
    #DISTRO_VERSION="21.1_ahs"
    DISTRO_VERSION="21.1_base32"   <-- this line was added



## Adjusting the system defaults to match your preferences

    #system defaults, these end up inside the squash file system mostly
    LIVE_USER="demo"                <-- best left as is
    LOCALE="en_US.UTF-8"            <-- changed if desired
    MIRROR="us"                     <-- changed if desired
    NEW_HOSTNAME="mx1"              <-- changed if desired
    RELEASE_DATE="Aug 09, 2020"     <-- change to TODAYS date
    TIME_ZONE="America/New_York"    <-- changes if desired


## Setting Kernel type and revision

While editing the Input/defaults file, select the entry with the best fit 
and enter the kernel Version, Template and Revision for the distro you're assembling

    #standard 64 bit
    #K_REVISION="13"                <---- Change to match latest kernel Revision #
    #K_TEMPLATE="%V%G-%R-%A"        <---- Ensure the template matches your Architecture
    #K_VERSION="5.10.0"             <---- Select the kernel Version
    #UNSIGNED=""

Using the example above, changing the revision from 9 to 10 is all that's needed
to intall the latest security patched kernel revision at the time of writing.


## Choosing compression for the ISO

In the Input folder, edit the defaults file to change compression type.
When producing an ISO for release, uncomment the 2 lines with zx as the compression 
type and comment out the 2 lines with lz4 as compression type to produce an ISO
that is roughly 30% smaller.

    #COMPRESSION_TYPE="xz"
    #COMPRESSION_TYPE_CODE="-comp xz -Xbcj x86"
    COMPRESSION_TYPE="lz4"
    COMPRESSION_TYPE_CODE="-comp lz4 -Xhc"

