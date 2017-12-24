#!/usr/bin/perl

use strict;
use Data::Dumper;

my ($entry, @entries, $new_dir, $APPEND);

$APPEND = "";

while (<>) {
    #print;
    chomp;
    s/^LABEL\s+// and do {
        #s/_/ /g;
        $entry = { label => $_ };
        push @entries, $entry;
        next;
    };

    s/^\t(KERNEL|APPEND|INITRD)\s+// and do {
        my $lab = lc $1;
        $new_dir and s{^/antiX}{/$new_dir};
        $entry->{$lab} = $_;
        next;
    };
}


#print Dumper(@entries); exit;

print <<Header;
default 0
timeout 10
color cyan/blue white/blue
foreground ffffff
background 003f7d
gfxmenu /boot/grub/message

Header

for my $entry (@entries) {
    exists $entry->{kernel} or next;
    $new_dir and $entry->{append} = "bdir=$new_dir $entry->{append}";
    print <<Entry
title $entry->{label}
kernel $entry->{kernel} $entry->{append} $APPEND
initrd $entry->{initrd}

Entry

}
