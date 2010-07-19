#!/usr/bin/env perl
# Скрипт для парсинга RSS ленты формируемой с помощью модуля RSS для phpBB форума/трекера
# http://naklon.info/rss/about.htm
# Author: sattellite
# License: MIT
use strict;
use warnings;
use utf8;
use open qw(:utf8 :std);

use CGI qw(:standard);
use XML::RAI;

my $uri =  $ENV{QUERY_STRING};
my $q = CGI->new;

my $rai = XML::RAI->parse_uri( "http://torrents.bks-tv.ru/forum/rss.php?$uri" );
my $topic = $rai->channel->title;
## Название топика, который сейчас парсится
print "\n\n",
    $q->div({-class => 'topic'}, big("$topic"));

## А это уже комментарии к просматриваемому топику
foreach my $item ( @{$rai->items} ) {
    my $i = $item->description;
    my $link = $item->link;
    print $q->start_div({-class => "comment"}),
    $q->a({-href=>"$link"},&t($item->title)),
    $q->span({-class=>"date"},&d(&pd($i))),
    $q->div({-class=>"author"},&au(&pd($i))),
    $q->div({-class=>"message"},&msg(&pd($i))),
    $q->end_div;
}

## Подпрограммы

## Создание массива, который все содержимое разбивает в элементы по строкам
sub pd 
{
    my ( $str ) = @_;
    my @content = split(/\n/, $str);
    return @content;
}

## Выпарсивание топика, а вернее обрезание Названия просматриваемой темы. Остается только сама тема
sub t
{
    my $title = $_[0];
    $title = (split(/::/, $title))[1];
    return $title;
}

## Выпарсивание автора комментария
sub au
{
    my $author = $_[0];
    $author =~ s/<br \/>//sg;
    return $author;
}

## Выпарсивание даты комментария
sub d
{
    my $dob = $_[1];
    $dob =~ /Добавлено: (.*) \(GMT/sg;
    my $data = $1;
    my ($day, $time) = split(/\s/, $data);
    my %d = ("01"=>"Янв","02"=>"Фев","03"=>"Мар","04"=>"Апр","05"=>"Май","06"=>"Июн","07"=>"Июл","08"=>"Авг","09"=>"Сен","10"=>"Окт","11"=>"Ноя","12"=>"Дек");
    my ($y, $m, $d) = split(/-/, $day);
    my $date = $d.'-'.$d{$m}.'-'.$y.' '.$time;
    return $date;
}

## Выпарсивание конкретно сообщения без лишних полей из RSS и тегов
sub msg
{
    my ($a, $b, @msg) = @_;
    my $msg = join("\n",@msg);
    $msg =~ s/<br \/>(<span.*span>)<br \/>/$1/sg;
    return $msg;
    # Сраная-срань. Массив выводить через функцию в цикле нельзя, поэтому используем костыль,
    # возвращающий скаляр в исходном виде. В &pd делили по переносу строки, а тут для красоты
    # восстанавливаем эти самые переносы.
}
