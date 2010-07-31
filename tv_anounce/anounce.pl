#!/usr/bin/env perl
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

# Вывести список каналов
print "Список каналов:\n";
for my $l ( sort keys %list ) {
    print "$l: $list{$l}\n";
}
print "Веберите канал из списка: ";
my $choise = <STDIN>;
chomp( $choise );

# Сформировать анонс
my $p = &pars( &get_an( $chanels{$list{$choise}} ) );
my $e = &effect( $p );

# Запись в файл
open (CH, ">", "tv/$list{$choise}");
print CH $e;
close CH;
print "Создан файл $list{$choise}";

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
    		# Дни недели по порядку (в итоге вся неделя)
	    	#
		    # Канал берется из значения чекбоксов указанных в $url
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
# - Сделать возможность использовать эти каналы ^^^
# - Дописать парсинг прочих возможных каналов с нужных сайтов
