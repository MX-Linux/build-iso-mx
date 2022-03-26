All changes need to be preformed within the bulid-iso-mx folder as cloned from the git repo

Example based on adding a 32-bit MX Base iso.  For this exercise, we'll be integrating a new 
template and theme for an ISO we'll call "mxbase32"

	------------	------------
$ git clone https://github.com/MX-Linux/build-iso-mx

$ cd build-iso-mx
	------------	------------

-----------------------------------------------------------------------
Update: The build-iso script was adjusted to avoid editing the scipt
        to add template names. 
        The following step "Edit the build-iso script..." is not needed.
-----------------------------------------------------------------------

Edit the build-iso script to add the required handler. 
	------------	------------	
Near the bottom of the script, about a page up, using the examples below, find the lines that have content similar to the following and add your intended build name and be sure to follow the current conventions used in the line

Line # 3947
    case $flav in
         mx32|mx64|mxahs|mxkde|mxworkbench32|mxworkbench64) return 0 ;;
         
The line above would now read ... 
         mx32|mx64|mxahs|mxkde|mxbase32|mxworkbench32|mxworkbench64) return 0 ;;

Save the changes and close the editor.
	------------	------------	


Next, we create the required template.
	------------	------------
In the Template folder, copy the template of the build that is the closest fit, e.g.

$ cp -r mx32 mxbase32

Now we have a template, we need to edit the packages.list file to include/exclude 
packages as needed for the build.
	------------	------------


Now we create or use a theme for the new build
	------------	------------
Familiarise yourself with how each theme is laid out and either use one as is, or 
create a new one that fits your need. If creating a new theme, be sure to follow
the same layout and structure as the themes already in use. 

When build-iso runs, you will be given an opportunity to choose a theme.
	------------	------------



Now we provision the ISO naming schema
	------------	------------
In the Input folder, edit the defaults file to add your distro name

look for line/s conatining DISTRO_VERSION="19.2"

Type the version name you wish to add into a new line and comment out those 
no longer required by placing a # in front.

example:
	#DISTRO_VERSION="19.2"
	#DISTRO_VERSION="19.2_ahs"
	DISTRO_VERSION="19.2_base32"   <-- this line was added


Adjust the system defaults to match your preferences

#system defaults, these end up inside the squash file system mostly
LIVE_USER="demo"				<-- best left as is
LOCALE="en_US.UTF-8"								<-- changed if desired
MIRROR="us"											<-- changed if desired
NEW_HOSTNAME="mx1"									<-- changed if desired
RELEASE_DATE="Aug 09, 2020"		<-- change to TODAYS date
TIME_ZONE="America/New_York"						<-- changes if desired

	------------	------------


Set Kernel type and revision
	------------	------------
While editing the Input/defaults file, select the entry with the best fit 
and enter the kernel Version, Template and Revision for the distro you're assembling

	#standard 32 bit
	#K_REVISION="9"					<---- Change to match latest kernel Revision #
	#K_TEMPLATE="%V%G-%R-686-pae"	<---- Ensure the template matches your Architecture
	#K_VERSION="4.19.0"				<---- Select the kernel Version
	#UNSIGNED=""

Using the example above, changing the revision from 9 to 10 is all that's needed
to intall the latest security patched kernel revision at the time of writing.
	------------	------------


Choosing compression for the ISO
	------------	------------
In the Input folder, edit the defaults file to change compression type.
When producing an ISO for release, uncomment the 2 lines with zx as the compression 
type and comment out the 2 lines with lz4 as compression type to produce an ISO
that is roughly 30% smaller.

#COMPRESSION_TYPE="xz"
#COMPRESSION_TYPE_CODE="-comp xz -Xbcj x86"
COMPRESSION_TYPE="lz4"
COMPRESSION_TYPE_CODE="-comp lz4 -Xhc"
	------------	------------
