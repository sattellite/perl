#!/usr/bin/env perl
use warnings;
use strict;

use LWP;
use URI;
use HTTP::Cookies;
use File::Path qw(make_path);
use IO::File;

my $file = IO::File -> new;

my $srvHost = "xmltv.s-tv.ru";
my $login = "test";
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

while ( $page =~ /(\/xmltv.php\?prg=\d+\&sh\=0)\".+?>(.+?)<\/a>.+?(\d{4}\-\d{2}\-\d{2})/sgx ) {
    writeToFile( $2, $browser->post( "http://$srvHost$1" )->content, $3 );
}

sub writeToFile
{
	my ( $tvName, $content, $dir) = @_;
	make_path $dir unless -d $dir;
    $file -> open( "> $dir/$tvName\.xml");
    print $file $content;
    $file -> close;
    print "Created file: \"$dir\/$tvName.xml\"\n";
    return 1;
} #writeToFile

=head1 NAME

Загрузчик телепрограммы с сайта L<< http://s-tv.ru >> в формате XMLTV.

=head1 USAGE

 $ perl downloadAnounce.pl

=head1 DESCRIPTION

Скачивание файлов с телепрограммой с сайта L<< http://s-tv.ru >>.
Скачанные файлы размещаются в директории, название которых соответствует
началу эфирной недели.

=head1 CONFIGURATION

Для использования необходимо только поправить свои логин и пароль, которые
хранятся в переменных $login и $pass.

=head1 AUTHOR

Aleksander Groschev
E-Mail: L<< E<lt>sattellite@bks-tv.ruE<gt> >>
JabberID: L<< E<lt>sattellite@bks-tv.ruE<gt> >> 

=head1 LICENSE AND COPYRIGHT

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

=cut
