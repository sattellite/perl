#!/usr/bin/env perl
# Author: sattellite
# E-Mail: sattellite[at]bks-tv.ru
# License: MIT

#   The MIT License
#
#   Copyright (c) 2010 sattellite
#
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#   THE SOFTWARE.

use strict;
use warnings;

use LWP;
use HTTP::Request::Common;
use Encode;

my $url = 'http://www.kulichki.tv/andgon/cgi-bin/itv.cgi';
my $m_url = 'http://www.kulichki.tv/';

my %chanels = ( # Список каналов
    'Первый'         =>  '47.7',
    'Россия 1'       =>  '52.7',
    'НТВ'            =>  '41.7',
    'ТВ-Центр'       =>  '63.7',
    'ТНТ'            =>  '65.7',
    'ТВ-3'           =>  '64.7',
    'ДТВ'            =>  '26.7',
    'РенТВ'          =>  '13.7',
    'СТС'            =>  '59.7',
    '5 канал'        =>  '49.7',
    'Россия 2'       =>  '53.7',
    'Россия К'       =>  '54.7',
    'Звезда'         =>  '27.7',
    'Беларусь ТВ'    =>  '22.7',
    'Мир'            =>  '37.7',
    'TV XXI'         =>  '60.7',
    'TV 1000'        =>  '62.7',
    'Школьник ТВ'    =>  '70.7',
    'Viasat History' =>  '21.7',
    );

my %list = ( # Список
    '01' => 'Первый',
    '02' => 'Россия 1',
    '03' => 'НТВ',
    '04' => 'ТВ-Центр',
    '05' => 'ТНТ',
    '06' => 'ТВ-3',
    '07' => 'ДТВ',
    '08' => 'РенТВ',
    '09' => 'СТС',
    '10' => '5 канал',
    '11' => 'Россия 2',
    '12' => 'Россия К',
    '13' => 'Звезда',
    '14' => 'Беларусь ТВ',
    '15' => 'Мир',
    '16' => 'TV XXI',
    '17' => 'TV 1000',
    '18' => 'Школьник ТВ',
    '19' => 'Viasat History',
    );

my $ua = LWP::UserAgent->new;

&list();

sub list
{   # Вывести список каналов и выбрать нужный
    print "Список каналов:\n00: Все каналы\n";
    for my $l ( sort keys %list ) {
        print "$l: $list{$l}\n";
    }

    print "Веберите канал из списка: ";
    my $choise = <STDIN>;
    chomp( $choise );
    &anounce( $choise );
    return 1;
}

sub anounce
{   # Сформировать анонс
    my ( $choise ) = @_;
    if ( $choise ne '00' ) {
        my $p = &pars( &get_an( $chanels{$list{$choise}} ) );
        my $e = &effect( $p );
        &wr( $e, $choise );
        return 1;
    } else {
        for my $l ( sort keys %list ) {
            my $p = &pars( &get_an( $chanels{$list{$l}} ) );
            my $e = &effect( $p );
            &wr( $e, $l );
        }
        return 1;
    }
}

sub wr
{   # Запись в файл
    my ( $e, $choise ) = @_;
    my $file = $list{$choise};
    open (CH, ">", "tv/$file" );
    print CH $e;
    close CH;
    print "Создан файл \"$file\"\n";
    return 1;
}

sub encoding
{   # Изменение кодировки с cp1251 в utf-8
    my ( $to_encode ) = @_;
    my $encoded = encode( 'utf-8', decode( 'cp1251', $to_encode ) );
    return $encoded;
}

sub get_an
{   # Запрос анонса
    my ( $ch ) = @_;
    my $request = POST($url,
        Content    => {
            week   => &week,
            day    => '1,2,3,4,5,6,7',
            chanel => $ch,
        },
    );

    my $response = $ua->request( $request );
    my $str = &encoding( $response->content );
    return $str;
}

sub week
{   # Номер недели
    my $req = HTTP::Request -> new(GET => $m_url);
    my $res = $ua -> request( $req );
    my $week = $res -> content;
    $week =~ /input type="hidden" name="week" value=(\d+)/si;
    $week = $1;
    return $week;
}

sub pars
{   # Выпарсивание куска, в котором содержатся анонсы программ
    my ( $str ) = @_;
    $str =~ /(<p><font.*pre>)<table/si;
    $str = $1;
    return $str;
}

sub effect
{   # Оформление текста под таблицу стилей сайта http://bks-tv.ru/
    my ( $text ) = @_;
    $text =~ s/<p>|<pre>|<\/pre>//sig;
    $text =~ s/font size=\+2|font/h3/sig;
    $text =~ s/b>/strong>/sig;
    $text =~ s/\n|<br>/<br \/>\n/sig;
    $text =~ s/<hr>/<hr>\n/sig;
    $text =~ s/\(Анонс gmt\+3\).*?(<br)/$1/sig;
    $text =~ s/^(\d.*)/<br \/>\n$1/mig;
    $text =~ s/^(\d+:\d+\s)(.*)\(/$1<span style="color: #3366ff">$2<\/span>\(/mig;
    $text =~ s/^(\d.*)(\()/<strong>$1<\/strong>$2/mig;
    $text =~ s/(Режиссер.*)(<br \/>)/<em>$1<\/em>$2/mig;
    $text =~ s/(В ролях.*)(<br \/>)/<em>$1<\/em>$2/mig;
    return $text;
}

# TODO
# + Брать номер недели с сайта
# + Иметь список используемых каналов с этого сайта
# + Сделать возможность использовать эти каналы ^^^
# + Запись в файлы всех оформленных анонсов
# - Дописать парсинг прочих возможных каналов с нужных сайтов
