package HTML::Editor::BBCODE;
use strict;
use warnings;
use vars qw(@EXPORT @ISA );
require Exporter;
@HTML::Editor::BBCODE::EXPORT  = qw(BBCODE);
@ISA                           = qw(Exporter);
$HTML::Editor::BBCODE::VERSION = '0.29';
use HTML::Entities;

=head1 NAME

HTML::Editor::BBCODE

=head1 required Modules

HTML::Entities,

Syntax::Highlight::Perl

=head1 SYNOPSIS

        use HTML::Editor::BBCODE;

        my $test = '

        [code]

        print "testIt";

        [/code]

        ';

        BBCODE(\$test);

        print $test;

=head1 DESCRIPTION

bbcode to html

=head2 EXPORT

BBCODE()

=head2 BBCODE

=cut

=head1 Public

=head2 BBCODE

=cut

sub BBCODE {
        my $string = shift;
        my $eval   = shift;
        $eval = defined $eval ? $eval : 0;
        my $rplc;
        if($$string =~ /\[code\](.*?)\[\/code\]/gs) {
                use Syntax::Highlight::Perl ':FULL';
                my $color_Keys = {
                                  'Variable_Scalar'   => 'Variable_ # or Scalar',
                                  'Variable_Array'    => 'Variable_Array',
                                  'Variable_Hash'     => 'Variable_Hash',
                                  'Variable_Typeglob' => 'Variable_Typeglob',
                                  'Subroutine'        => 'Subroutine',
                                  'Quote'             => 'Quote',
                                  'String'            => 'String',
                                  'Comment_Normal'    => 'Comment_Normal',
                                  'Comment_POD'       => 'Comment_POD',
                                  'Bareword'          => 'Bareword',
                                  'Package'           => 'Package',
                                  'Number'            => 'Number',
                                  'Operator'          => 'Operator',
                                  'Symbol'            => 'Symbol',
                                  'Character'         => 'Character',
                                  'Directive'         => 'Directive',
                                  'Label'             => 'Label',
                                  'Line'              => 'Line',
                };
                my $formatter = new Syntax::Highlight::Perl;
                $formatter->define_substitution('<' => '&lt;', '>' => '&gt;', '&' => '&amp;',);    # HTML escapes.
                while(my ($type, $style) = each %{$color_Keys}) {
                        $formatter->set_format($type, [qq|<span class="$style">|, '</span>']);
                }
                my $perldoc_Keys = {'Builtin_Operator' => 'Builtin_Operator', 'Builtin_Function' => 'Builtin_Function', 'Keyword' => 'Keyword',};
                while(my ($type, $style) = each %{$perldoc_Keys}) {
                        $formatter->set_format($type, [qq|<a onclick="window.open('http://perldoc.perl.org/search.html?q='+this.innerHTML)" class="$style">|, "</a>"]);
                }
                $rplc = $formatter->format_string($1);
                $rplc    =~ qq(<div  style="width:100%;overlow:scroll;"><pre>$rplc</pre></div>);
                $$string =~ s/\[code\](.*?)\[\/code\]/\[Formatstring\/\]/gs;
        }
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
        $$string =~ s/\[Formatstring\/\]/$rplc/gs;
}

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation; 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;

