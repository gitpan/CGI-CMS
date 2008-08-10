package HTML::Editor::BBCODE;
use strict;
use warnings;
use vars qw(@EXPORT @ISA $currentstring @formatString);
require Exporter;
@HTML::Editor::BBCODE::EXPORT  = qw(BBCODE);
@ISA                           = qw(Exporter);
$HTML::Editor::BBCODE::VERSION = '0.35';
use HTML::Entities;

=head1 NAME

HTML::Editor::BBCODE - BBCODE for HTML::Editor

=head1 required Modules

HTML::Entities,

Syntax::Highlight::Engine::kate

=head1 SYNOPSIS

        use HTML::Editor::BBCODE;

        my $test = '

        [code=Perl]

        print "testIt";

        [/code]

        ';

        BBCODE(\$test);

        print $test;

=head1 DESCRIPTION

Supported BBCODE

     [left]left[/left]

     [center]center[/center]

     [right]right[/right]

     [b]bold[/b]

     [i]italic[/i]

     [s]strike[/s]

     [u]underline[/u]

     [sub]sub[/sub]

     [sup]sup[/sup]

     [img]http://url[/img]

     [url=http://url.de]link[/url]

     [email=email@url.de]mail me[/email]

     [color=red]color[/color]

     [google]lindnerei.de[/google]

     [blog=http://referer]text[/blog]

     [h1]h1[/h1]

     [h2]h2[/h2]

     [h3]h3[/h3]

     [h4]h4[/h4]

     [h5]h5[/h5]

     [ul]

     [li]1[/li]

     [li]2[/li]

     [li]3[/li]

     [/ul]

     [ol]

     [li]1[/li]

     [li]2[/li]

     [li]3[/li]

     [/ol]

     [hr]

Syntax Highlight tags

[code=lang]...[/code]

lang tags:

        Bash

        C++

        CSS

        HTML

        Java

        JavaScript

        PHP

        Perl

        Python

        Ruby

        XML

 en de tags


=head2 EXPORT

BBCODE()

=head2 BBCODE

=cut

=head1 Public

=head2 BBCODE

=cut

sub BBCODE {
    my $string          = shift;
    my $ACCEPT_LANGUAGE = shift;
    $ACCEPT_LANGUAGE = defined $ACCEPT_LANGUAGE ? $ACCEPT_LANGUAGE : 'de';
    my $rplc;
    $$string =~ s/\[(code)=(Perl|Java|C\+\+|XML|Ruby|Python|PHP|JavaScript|HTML|CSS|Bash)\](.*?)\[\/code\]/formatString($3,$2)/egs;
    $$string =~ s/\[code\](.*?)\[\/code\]/formatString($1,'Perl')/egs;
    $$string = encode_entities($$string);
    $$string =~ s:\[(u)\](.*?)\[/\1\]:<$1>$2</$1>:gs;
    $$string =~ s:\[(b)\](.*?)\[/\1\]:<$1>$2</$1>:gs;
    $$string =~ s/\[(b)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(i)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(ol)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(ul)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(li)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(h1)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(h2)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(h3)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(h4)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(h5)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(s)\]([^\[\/\1\]]*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(sub)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[(sup)\](.*?)\[\/\1\]/<$1>$2<\/$1>/gs;
    $$string =~ s/\[hr\]/<hr\/>/gs;
    $$string =~ s/\[color=(.*?)\](.*?)\[\/color\]/<span style="color:$1;background-color:#E6DADE;">$2<\/span>/gs;
    $$string =~ s/\[right\](.*?)\[\/right\]/<div align="right">$1<\/div>/gs;
    $$string =~ s/\[center\](.*?)\[\/center\]/<div align="center">$1<\/div>/gs;
    $$string =~ s/\[left\](.*?)\[\/left\]/<div align="left">$1<\/div>/gs;
    $$string =~ s/\[url=(.*?)\](.*?)\[\/url\]/<a style="color:#000000;background-color:#E6DADE;" href="$1">$2<\/a>/gs;
    $$string =~ s/\[email=(.*?)\](.*?)\[\/email\]/<a style="color:#000000;" target="_blank" href="mailto:$1">$2<\/a>/gs;
    $$string =~ s/\[(img)\](.*?)\[\/\1\]/<img border="0" src="$2" alt=""\/>/g;
    $$string =~ s/\[(google)\](.*?)\[\/\1\]/<a style="color:#000000;" target="_blank" href="http:\/\/www.google.de\/search?q=$2">Google:$2<\/a>/gs;
    $$string =~
      s/\[blog=(.*?)\](.*?)\[\/blog\]/<table  cellpadding="0" cellspacing="0" border="0"><tr><td><table  cellpadding="5" cellspacing="0"  border="0" class="blog"><tr><td>$2<\/td><\/tr><\/table><\/td><\/tr><tr><td><b><a href="$1" class="link">Quelle<\/a><\/b><\/td><\/tr><\/table>/gs;
    $$string =~ s/\n/\n<br\/>/ig;
    $$string =~ s/:\)/<img src="\/images\/smiley.gif" alt=":)" border="0"\/>/g;
    $$string =~ s/;D/<img src="\/images\/grin.gif" alt=";D" border="0"\/>/g;
    $$string =~ s/8\)/<img src="\/images\/cool.gif" alt="8)" border="0"\/>/g;
    $$string =~ s/:-\*/<img src="\/images\/kiss.gif" alt=":-*" border="0"\/>/g;
    $$string =~ s/:\(/<img src="\/images\/angry.gif" alt=":(" border="0"\/>/g;
    $$string =~ s/:\(/<img src="\/images\/angry.gif" alt=":(" border="0"\/>/g;
    $$string =~ s/\[Formatstring(\d+)\/\]/$formatString[$1]/egs;

    if($ACCEPT_LANGUAGE eq 'de') {
        $$string =~ s/\[en\](.*?)\[\/en\]//gs;
        $$string =~ s/\[de\](.*?)\[\/de\]/$1/gs;
    } else {
        $$string =~ s/\[en\](.*?)\[\/en\]/$1/gs;
        $$string =~ s/\[de\](.*?)\[\/de\]//gs;
    }
}

sub formatString {
    my ($string, $lang) = @_;
    use Syntax::Highlight::Engine::Kate;
    my $hl = new Syntax::Highlight::Engine::Kate(
        language      => $lang,
        substitutions => {
            "<" => "&lt;",
            ">" => "&gt;",
            "&" => "&amp;",

        },
        format_table => {
            Alert        => ["<span style=\"color:#0000ff\">",       "</span>"],
            BaseN        => ["<span style=\"color:#007f00\">",       "</span>"],
            BString      => ["<span style=\"color:#c9a7ff\">",       "</span>"],
            Char         => ["<span style=\"color:#ff00ff\">",       "</span>"],
            Comment      => ["<span style=\"color:#7f7f7f\"><i>",    "</i></span>"],
            DataType     => ["<span style=\"color:#0000ff\">",       "</span>"],
            DecVal       => ["<span style=\"color:#00007f\">",       "</span>"],
            Error        => ["<span style=\"color:#ff0000\"><b><i>", "</i></b></span>"],
            Float        => ["<span style=\"color:#00007f\">",       "</span>"],
            Function     => ["<span style=\"color:#007f00\">",       "</span>"],
            IString      => ["<span style=\"color:#ff0000\">",       ""],
            Keyword      => ["<b>",                                  "</b>"],
            Normal       => ["",                                     ""],
            Operator     => ["<span style=\"color:#ffa500\">",       "</span>"],
            Others       => ["<span style=\"color:#b03060\">",       "</span>"],
            RegionMarker => ["<span style=\"color:#96b9ff\"><i>",    "</i></span>"],
            Reserved     => ["<span style=\"color:#9b30ff\"><b>",    "</b></span>"],
            String       => ["<span style=\"color:#ff0000\">",       "</span>"],
            Variable     => ["<span style=\"color:#0000ff\"><b>",    "</b></span>"],
            Warning      => ["<span style=\"color:#0000ff\"><b><i>", "</b></i></span>"],
        },
    );
    my $rplc = $hl->highlightText($string);
    $currentstring++;
    $formatString[$currentstring] = qq(<div style="100%;overflow:auto"><pre>$rplc</pre></div>);
    return "[Formatstring$currentstring/]";
}

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 LICENSE

Copyright (C) 2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation;
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;
