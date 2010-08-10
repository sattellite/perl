#!/usr/bin/env perl
use strict;
use warnings;
no warnings "all";


use XML::Simple;
use IO::File;
use File::Path qw(make_path);
use utf8;

my $fh = IO::File->new( 'xmltv.xml' );
my $file = XMLin( $fh );

my %mon = (
    '01' => 'января',
    '02' => 'февраля',
    '03' => 'марта',
    '04' => 'апреля',
    '05' => 'мая',
    '06' => 'июня',
    '07' => 'июля',
    '08' => 'августа',
    '09' => 'сентября',
    '10' => 'октября',
    '11' => 'ноября',
    '12' => 'декабря',
);

my %day = (
    '1' => 'Понедельник. ',
    '2' => 'Вторник. ',
    '3' => 'Среда. ',
    '4' => 'Четверг. ',
    '5' => 'Пятница. ',
    '6' => 'Суббота. ',
    '7' => 'Воскресенье. ',
    '8' => 'Понедельник. ',
);

my @IDs = qw(1 2 676 4 104 101 103 109 209 235 100052 663 226 326 288 300047 289 3 105 300020 595 272 300007 100010 5 107 108 503 300003 727 300035 255 325 222 313 330 100018 100017);

my $dir = &dat();
make_path $dir unless -d $dir;

foreach my $n ( @IDs ) {
    my $a = "1";
    my ( $times, $d, $title, $out );
    my $cr_file = "$file->{'channel'}->{$n}->{'display-name'}->{'content'}";
    for ( my $i = 0; $i < @{$file->{'programme'}}; $i++ ) {
        if ( ($file->{'programme'}->["$i"]{'channel'}) == $n ) {
            my $date = $file->{'programme'}->["$i"]->{'start'};

            if ( $file->{'programme'}->["$i"]->{'desc'}->{'content'} ) {
                $title = $file->{'programme'}->["$i"]->{'title'}->{'content'}."\n<br><em>".$file->{'programme'}->["$i"]->{'desc'}->{'content'}.'</em><br>';
            } else {
                $title = $file->{'programme'}->["$i"]->{'title'}->{'content'}.'<br>';
            }

            $date =~ m/(....)(..)(..)(..)(..).+?/si;

            if ( $d ne $3 ) {
                $times = '<br><h3><strong>'.$day{$a}.$3.' '.$mon{"$2"}."<\/strong><\/h3><hr><br>\n<strong><span style=\"color: #3366ff\">".$4.':'.$5.'</span></strong>';
                $d = $3;
                $a++;
            } else {
                $times = '<strong><span style="color: #3366ff">'.$4.':'.$5.'</span></strong>';
            }
            
            $out .= "$times $title\n";
        }
    }
    open ( CH, ">", "$dir/$cr_file" );
    print CH $out;
    close CH;
    print "Создан файл \"$cr_file\"\n";
}

sub dat
{ # Сегодняшняя дата
    my ($d,$m,$y) = (localtime(time))[3,4,5];
    $y += 1900; $m += 1;

    # Если число однозначное, то пририсовать ноль к нему
    if(scalar split( '', $d ) == 1) { $d = '0'.$d };
    if(scalar split( '', $m ) == 1) { $m = '0'.$m };

    my $dat = $y.'-'.$m.'-'.$d;
    return $dat;
}
