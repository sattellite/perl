#!/usr/bin/env perl
use strict;
use warnings;
no warnings "all";
use utf8;

use XML::Simple;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use IO::File;
use File::Path qw(make_path);
use File::Download;

my %month = ( '01' => 'января',   '02' => 'февраля',
              '03' => 'марта',    '04' => 'апреля',
              '05' => 'мая',      '06' => 'июня',
              '07' => 'июля',     '08' => 'августа',
              '09' => 'сентября', '10' => 'октября',
              '11' => 'ноября',   '12' => 'декабря' );

my %day = (    '1' => 'Понедельник. ', '2' => 'Вторник. ',
               '3' => 'Среда. ',       '4' => 'Четверг. ',
               '5' => 'Пятница. ',     '6' => 'Суббота. ',
               '7' => 'Воскресенье. ', '8' => 'Понедельник. ' );

{   # Скачивание и распаковка файла с ТВ-программой
    my $url = 'http://www.teleguide.info/download/new3/xmltv.xml.gz';
    my $dwn = File::Download->new({
        overwrite => 1,
    });

    if ($dwn->download($url) == 0) {
        print "Скачиваю программу на неделю.\n";
        $dwn->download( $url );
    } else {
        die "Не могу загрузить файл по ссылке $url";
    }
    
    my $fileIn = "xmltv.xml.gz";
    my $fileOut = "xmltv.xml";
    print "Распаковываю скачанный файл.\n";
    gunzip $fileIn => $fileOut or die "$GunzipError";
}

print "Подготовка к обработке.\n";
my $fileHandle = IO::File->new( 'xmltv.xml' );
my $xmlTree = XMLin( $fileHandle );

print "Обработка и создание файлов\n\n";

my $directory = &date();
make_path $directory unless -d $directory;

my @channelID = qw(1 2 676 4 104 101 103 109 209 235 100052 663 226 326 288 300047 289 3 105 300020 595 272 300007 100010 5 107 108 503 300003 727 300035 255 325 222 313 330 100018 100017);

my $progData = $xmlTree->{'programme'};

foreach my $channel ( @channelID ) {
    my $dayCounter = "1";
    my ( $times, $d, $title, $out );
    my $createFile = "$xmlTree->{'channel'}->{$channel}->{'display-name'}->{'content'}";
    for ( my $i = 0; $i < @$progData; $i++ ) {
        my $progNow = @$progData->["$i"];
        if ( ( $progNow->{'channel'} ) == $channel ) {

            my $date = $progNow->{'start'};

            if ( $progNow->{'desc'}->{'content'} ) {
                $title = $progNow->{'title'}->{'content'}."\n<br><em>".$progNow->{'desc'}->{'content'}.'</em><br>';
            } else {
                $title = $progNow->{'title'}->{'content'}.'<br>';
            }

            $date =~ m/(....)(..)(..)(..)(..).+?/si;

            if ( $d ne $3 ) {
                $times = '<br><h3><strong>'.$day{"$dayCounter"}.$3.' '.$month{"$2"}."<\/strong><\/h3><hr><br>\n<strong><span style=\"color: #3366ff\">".$4.':'.$5.'</span></strong>';
                $d = $3;
                $dayCounter++;
            } else {
                $times = '<strong><span style="color: #3366ff">'.$4.':'.$5.'</span></strong>';
            }
            
            $out .= "$times $title\n";
        }
    }
    $out =~ s/^<br><h3>/<h3>/i;
    &writeToFile( $createFile, $out );
}

print "\nЗавершение работы скрипта.\n";

sub date
{ # Сегодняшняя дата
    my ($d,$m,$y) = (localtime(time))[3,4,5];
    $y += 1900; $m += 1;

    # Если число однозначное, то пририсовать ноль к нему
    if(scalar split( '', $d ) == 1) { $d = '0'.$d };
    if(scalar split( '', $m ) == 1) { $m = '0'.$m };

    my $dat = $y.'-'.$m.'-'.$d;
    return $dat;
} # date

sub writeToFile
{   # Запись в файл
    open (FILE, ">", "$directory/$_[0]" );
    print FILE $_[1];
    close FILE;
    print "Создан файл: \"$_[0]\"\n";
} # writeToFile
