#!/usr/bin/env perl
use strict;
use warnings;

use LWP;
use HTTP::Request::Common;
use Encode;
use File::Path qw(make_path);

my $url      = 'http://www.kulichki.tv/andgon/cgi-bin/itv.cgi';
my $week_url = 'http://www.kulichki.tv';
my $ch_url   = 'http://www.kulichki.tv/cgi-bin/gpack.cgi';


my $ua = LWP::UserAgent->new;

my $w = &week();
my $v = &get_ch();

my %chanels = ( # Список каналов
    'Первый'         =>  "47.$v",
    'Россия 1'       =>  "52.$v",
    'НТВ'            =>  "41.$v",
    'ТВ-Центр'       =>  "63.$v",
    'ТНТ'            =>  "65.$v",
    'ТВ-3'           =>  "64.$v",
    'ДТВ'            =>  "26.$v",
    'РенТВ'          =>  "13.$v",
    'СТС'            =>  "59.$v",
    '5 канал'        =>  "49.$v",
    'Россия 2'       =>  "53.$v",
    'Россия К'       =>  "54.$v",
    'Звезда'         =>  "27.$v",
    'Беларусь ТВ'    =>  "22.$v",
    'Мир'            =>  "37.$v",
    'TV XXI'         =>  "60.$v",
    'TV 1000'        =>  "62.$v",
    'Школьник ТВ'    =>  "70.$v",
    'Viasat History' =>  "21.$v",
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


# Вывести список каналов и выбрать нужный
print "Список каналов:\n00: Все каналы\n";
for my $l ( sort keys %list ) {
    print "$l: $list{$l}\n";
}

print "Веберите канал из списка: ";
my $choise = <STDIN>;
chomp( $choise );

# Создать директорию для хранения анонсов
my $dir = &dat();
make_path $dir unless -d $dir;

# Сформировать анонс
if ( $choise eq '00' ) {
    for my $l ( sort keys %list ) {
        my $p = &pars( &get_an( $chanels{$list{$l}} ) );
        my $e = &effect( $p );
        &wr( $e, $l );
    }
} elsif ( $choise =~ /^[01]\d$/) {
    my $p = &pars( &get_an( $chanels{$list{$choise}} ) );
    my $e = &effect( $p );
    &wr( $e, $choise );
} else {
    print "Такого канала не найдено. Внимательней читай что пишешь.\n";
    exit;
}

sub dat 
{   # Сегодняшняя дата
    my ($d,$m,$y) = (localtime(time))[3,4,5];
    $y += 1900; $m += 1;

    # Если число однозначное, то пририсовать ноль к нему
    if(scalar split( '', $d ) == 1) { $d = '0'.$d };
    if(scalar split( '', $m ) == 1) { $m = '0'.$m };

    my $dat = $y.'-'.$m.'-'.$d;
    return $dat;
}

sub wr
{   # Запись в файл
    my ( $e, $choise ) = @_;

    my $file = $list{$choise};
    #$file = &dat().' '.$file;
    

    open (CH, ">", "$dir/$file" );
    print CH $e;
    close CH;
    print "Создан файл \"$file\"\n";
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
            week   => $w,
            day    => '1,2,3,4,5,6,7',
            chanel => $ch,
        },
    );

    my $response = $ua -> request( $request );
    my $str = &encoding( $response -> content );
    return $str;
}

sub get_ch
{   # Запрос по каналам 
    my $request = POST($ch_url,
        Content    => {
            week   => $w,
            pakets => 'anons',
        },
    );

    my $response = $ua -> request( $request );
    my $str = $response -> content;
    $str =~ /input type="checkbox" name="chanel" value="(.*?)"/si;
    $str = (split(/\./, $1))[1];
    return $str;
}


sub week
{   # Номер недели
    my $req = HTTP::Request -> new(GET => $week_url);
    my $resw = $ua -> request( $req );
    my $week = $resw -> content;
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
    $text =~ s/\(Анонс gmt\+\d+\).*?(<br)/$1/sig;
    $text =~ s/^(\d.*)/<br \/>\n$1/mig;
    $text =~ s/^(\d+:\d+\s)(.*)\(/$1<span style="color: #3366ff">$2<\/span>\(/mig;
    $text =~ s/^(\d.*)(\()/<strong>$1<\/strong>$2/mig;
    $text =~ s/(Режиссер.*)(<br \/>)/<em>$1<\/em>$2/mig;
    $text =~ s/(В ролях.*)(<br \/>)/<em>$1<\/em>$2/mig;
    return $text;
}


=head1 ОПИСАНИЕ

Создание недельного анонса ТВ прорамм для телевизионных каналов.
Создается поддиректория формата I<year>-I<month>-I<day>
и в ней создаются файлы с названиями каналов, которые содержат внутри себя
HTML-разметку.

Программа создана по однйо простой причине - сэконосить себе 3 дня рабочего времени
и заниматься более полезной работой на своем рабочем месте.

=head1 ИСПОЛЬЗОВАНИЕ

 ./anounce.pl
 И выбор номера необходимого канала.

=head1 АВТОР

Aleksander Groschev
E-Mail: L<< E<lt>sattellite@bks-tv.ruE<gt> >>
JabberID: L<< E<lt>sattellite@bks-tv.ruE<gt> >> 

=head1 ЛИЦЕНЗИЯ

Эта программа распространяется под лицензией MIT (MIT License)

Copyright (c) 2010 Aleksander Groschev

Данная лицензия разрешает, безвозмездно, лицам, получившим копию данного программного
обеспечения и сопутствующей документации (в дальнейшем именуемыми "Программное
Обеспечение"), использовать Программное Обеспечение без ограничений, включая
неограниченное право на использование, копирование, изменение, добавление, публикацию,
распространение, сублицензирование и/или продажу копий Программного Обеспечения,
также как и лицам, которым предоставляется данное Программное Обеспечение, при
соблюдении следующих условий:

Вышеупомянутый копирайт и данные условия должны быть включены во все копии или
значимые части данного Программного Обеспечения.

ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ ЛЮБОГО ВИДА ГАРАНТИЙ,
ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ ГАРАНТИЯМИ ТОВАРНОЙ
ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ И НЕНАРУШЕНИЯ ПРАВ. НИ В КАКОМ
СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ ОТВЕТСТВЕННОСТИ ПО ИСКАМ О ВОЗМЕЩЕНИИ
УЩЕРБА, УБЫТКОВ ИЛИ ДРУГИХ ТРЕБОВАНИЙ ПО ДЕЙСТВУЮЩИМ КОНТРАКТАМ, ДЕЛИКТАМ ИЛИ ИНОМУ,
ВОЗНИКШИМ ИЗ, ИМЕЮЩИМ ПРИЧИНОЙ ИЛИ СВЯЗАННЫМ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ ИЛИ
ИСПОЛЬЗОВАНИЕМ ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫМИ ДЕЙСТВИЯМИ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.

=head4 TODO
1. Дописать парсинг прочих возможных каналов с нужных сайтов
- http://www.viasat-channels.tv/
- http://www.teleguide.info/download/new3/xmltv.xml.gz
- На всякий случай http://www.tvpilot.ru/

=cut
