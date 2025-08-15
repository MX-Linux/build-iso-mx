
antix_specific_code() {
    local dir=$1

    # -jbb
    mkdir -p $dir/var/log/samba $dir/var/log/fsck

    # Create the /etc/resolv.conf symlink if it does not already exist
    #ln -s /etc/resolvconf/run/resolv.conf $dir/etc/resolv.conf 2>/dev/null
    
    #remove /etc/resolv.conf no matter what it is
	#rm -f $dir/etc/resolv.conf

    rm -f $dir/etc/fstab.hotplug
    
    local protect=$dir/etc/live/protect
    mkdir -p $protect
    touch $protect/persist $protect/remaster
    
    # Must exist for samba to work
    [ -d $dir/var/lib/samba ] && echo -n > $dir/var/lib/samba/unexpected.tdb
    
    #[ ! -e $dir/etc/localtime ] && cp_rm_dest $SQFS_MP/etc/localtime $dir/etc/localtime

    rm -f $dir/etc/console/boottime.old.kmap.gz
    cp $SQFS_MP/etc/console/* $dir/etc/console/ &>/dev/null
    
    local f
    for f in /run/utmp /run/wtmp /etc/ioctl.save /etc/pnm2ppa.conf; do
        mkdir -p $(dirname $dir$f)
        echo -n > $dir$f
    done
    
    for f in /var/log/apt/history.log /var/log/apt/term.log /var/log/dpkg.log; do
        mkdir -p $(dirname $dir$f)
        [ -e $f ] || touch $dir$f
    done
}

antix_specific_code $NEW_ROOT
