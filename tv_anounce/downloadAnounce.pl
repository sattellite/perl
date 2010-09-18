#!/usr/bin/env perl
no warnings;
use strict;

use LWP;
use URI;
use HTTP::Cookies;
use File::Path qw(make_path);

my $directory = &date() ."_prog";
make_path $directory unless -d $directory;

my $srvHost = "xmltv.s-tv.ru";
my $login = "test;
my $pass = "test";
my $show = "1";
my $xmlTV = "1";

my $url = URI->new( "http://$srvHost/xchenel.php" );
$url->query_form( 'login' => $login, 'pass' => $pass, 'show' => $show, 'xmltv' => $xmlTV );

my $browser = LWP::UserAgent->new();
my $cookies = HTTP::Cookies->new();
$browser -> cookie_jar( $cookies );
$browser -> agent("Mozilla/5.0 (X11; U; Linux x86_64; ru; rv:1.9.2.8) Gecko/20100723 Ubuntu/10.04 (lucid) Firefox/3.6.8");

my $page = $browser -> get( $url ) -> content;

while ( $page =~ /(\/xmltv.php\?prg=\d+\&sh\=0)\".+?>(.+?)<\/a>/sg ) {
    writeToFile( $2, $browser->post( "http://$srvHost$1" )->content );
}

sub writeToFile
{
    if ( -e "$directory/$_[0].xml" ) {
        make_path "$directory/next_week" unless -d "$directory/next_week";
        open ( FILE, ">", "$directory/next_week/$_[0].xml" );
        print FILE $_[0];
        close FILE;
        print "Created file: \"next_week\/$_[0].xml\"\n";
    } else {
        open ( FILE, ">", "$directory/$_[0].xml" );
        print FILE $_[1];
        close FILE;
        print "Created file: \"$_[0].xml\"\n";
    }
}

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

=head1 ОПИСАНИЕ

Скачивание файлов с телепрограммой с сайта L<< http://s-tv.ru >>

=head1 ИСПОЛЬЗОВАНИЕ

 ./downloadAnounce.pl
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
1. Сделать проверку в 23 и 31 строках.

=cut