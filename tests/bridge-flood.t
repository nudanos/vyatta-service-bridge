#!/usr/bin/perl
# With kernel forwarding there is no DPDK dataplane to flood; bridge ports must
# keep kernel broadcast/multicast flooding on.
use strict; use warnings;
use Test::More;
use File::Temp qw(tempdir);
use lib 'lib';
require './scripts/vyatta-bridge.pl';
my $root = tempdir( CLEANUP => 1 );
for my $kf ( 0, 1 ) {
    my $d = "$root/sys/devices/virtual/net/br0/brif/dp0s3";
    system("mkdir -p $d && echo 1 > $d/multicast_flood && echo 1 > $d/broadcast_flood");
    set_port_flooding( 'br0', 'dp0s3', $kf, "$root/sys" );
    my $want = $kf ? '1' : '0';
    is( `cat $d/multicast_flood` =~ s/\s+//r, $want, "multicast_flood with kernel_forwarding=$kf" );
    is( `cat $d/broadcast_flood` =~ s/\s+//r, $want, "broadcast_flood with kernel_forwarding=$kf" );
}
done_testing();
