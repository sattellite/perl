#!/usr/bin/env perl
use strict;
use warnings;
no warnings "all";

use Data::Dumper;

use XML::Simple;
use IO::File;
use utf8;

my $fh = IO::File->new( 'channels.xml' );
my $file = XMLin( $fh );
#print Dumper( $file );
print key $file->{"channel"};



my @IDs = qw(1);# 2 676 4 104 101 103 109 209 235 100052 663 226 326 288 300047 289 3 105 300020 595 272 300007 100010 5 107 108 503 300003 727 300035 255 325 222 313 330 100018 100017);

foreach my $n ( @IDs ) {
    print "$file->{'channel'}->{$n}->{'display-name'}->{'content'}\t";
    for ( my $i = 0; $i < @{$file->{'programme'}}; $i++) {
        if ( ($file->{'programme'}->["$i"]{'channel'}) == $n ) {
            my $date = &times( $n, $i );
            print "$date\n";
        }
    }
}

sub times
{   # Время
    if ( $file->{'programme'}->["$_[1]"]->{'channel'} = $_[0] ) {
        my $date = $file->{'programme'}->["$_[1]"]->{'start'};
        $date =~ m/(....)(..)(..)(..)(..).+?/si;
        my $times = $1.'-'.$2.'-'.$3.'  '.$4.':'.$5;
        return $times;
#       print "$1\-$2\-$3  $4:$5\n";
    }
} # times