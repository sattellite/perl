#!/usr/bin/env perl
use strict;
#use warnings;

use XML::DOM;
use LWP;
use utf8;

my $ua = new LWP::UserAgent();
my $req = HTTP::Request -> new( GET => 'http://rp5.ru/xml/1859/ru' ); # 1859 - 
my $res = $ua -> request( $req );                                     # Bryansk
my $str = $res -> content;

if ( $res -> is_success ) {
    print &answer();
}  else {
    print "Ошибка\n";
}

sub parser 
{
    my ( $string ) = @_;
    my @arr;
    my $p = new XML::DOM::Parser;
    my $doc = $p -> parse( $str );
    my $root = $doc -> getDocumentElement();
    my $items = $doc -> getElementsByTagName( "$string" );
    for ( my $i = 0; $i < $items -> getLength; $i++ ) {
        my $item = $items -> item( $i );
        my $it = $item -> getFirstChild() -> getData();
        push( @arr, $it );
    }
    return @arr;
}

sub answer
{
    my @cloud = &parser( 'cloud_cover' );
    my @temp = &parser( 'temperature' );
    my @city = &parser( 'point_name2' );
    my @date = &parser( 'point_date' );
    my @pres = &parser( 'pressure' );
    my @prec = &parser( 'precipitation' );
    my @humi = &parser( 'humidity' );
    my @wd = &parser( 'wind_direction' );
    my @wv = &parser( 'wind_velocity' );
    my $answer = "Сводка погоды предоставлена RP5.ru\n\nПогода $city[0] ($date[0]):\n\nСегодня утром:\nТемпература: $temp[0] °C\nОблачность: $cloud[0]%\nОсадки: $prec[0] мм\nДавление: $pres[0] мм.рт.ст.\nВлажность: $humi[0]%\nНаправление ветра: $wd[0]\nСкорость ветра: $wv[0] м/с\n\nСегодня вечером:\nТемпература: $temp[1] °C\nОблачность: $cloud[1]%\nОсадки: $prec[1] мм\nДавление: $pres[1] мм.рт.ст.\nВлажность: $humi[1]%\nНаправление ветра: $wd[1]\nСкорость ветра: $wv[1] м/с\n\nЗавтра утром:\nТемпература: $temp[2] °C\nОблачность: $cloud[2]%\nОсадки: $prec[2] мм\nДавление: $pres[2] мм.рт.ст.\nВлажность: $humi[2]%\nНаправление ветра: $wd[2]\nСкорость ветра: $wv[2] м/с\n\nЗавтра вечером:\nТемпература: $temp[3] °C\nОблачность: $cloud[3]%\nОсадки: $prec[3] мм\nДавление: $pres[3] мм.рт.ст.\nВлажность: $humi[3]%\nНаправление ветра: $wd[3]\nСкорость ветра: $wv[3] м/с\n";
    return $answer;
}
