#!/usr/bin/env perl
use warnings;
no warnings "all";
use Weather::Google;
use strict;
use open qw(:utf8 :std);
use utf8;

my ($msg, $city) = @_;
$city = $ARGV[0]; $city = 'Брянск' unless $city;
my $w = new Weather::Google( $city, {language => 'ru'} );
my @wt = $w->current qw( condition temp_c humidity wind_condition );
my @wh = $w->tomorrow qw( condition high );
my $weather = "Погода предоставлена Google\n\n"."Сейчас в городе $city за окном:\n$wt[0]\n".
"Температура: $wt[1] °C\n$wt[2]\n$wt[3]\n\nЗавтра:\n$wh[0]\nТемпература: $wh[1] °C\n";
unless (scalar @{$w->forecast}) {
    print "Тю\n";
    return;
}
print $weather;
