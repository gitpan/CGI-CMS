package showsource;
use strict;
use warnings;
require Exporter;
use vars qw($color_Keys $formatter $perldoc_Keys @EXPORT @ISA );
@ISA                = qw(Exporter);
@showsource::EXPORT = qw(showSource);
use lib qw(../lib);
use Syntax::Highlight::Perl ':FULL';    # or ':FULL'

sub showSource {

$color_Keys = {
'Variable_Scalar'   => 'red',
'Variable_Array'    => '#a44848',
'Variable_Hash'     => '#a44848',
'Variable_Typeglob' => '#a44848',
'Subroutine'        => '#000000',
'Quote'             => '#ff9090',
'String'            => '#000000',
'Comment_Normal'    => 'red',
'Comment_POD'       => 'gray',
'Bareword'          => 'blue',
'Package'           => 'black',
'Number'            => 'blue',
'Operator'          => '#178b17',
'Symbol'            => 'red',
'Character'         => 'black',
'Directive'         => '#178b17',
'Label'             => '#178b17',
'Line'              => '#178b17',
};
$formatter = new Syntax::Highlight::Perl;
$formatter->define_substitution('<' => '&lt;', '>' => '&gt;', '&' => '&amp;',);    # HTML escapes.

while(my ($type, $style) = each %{$color_Keys}) {
$formatter->set_format($type, [qq|<span style="color:$style;">|, '</span>']);
}
$perldoc_Keys = {'Builtin_Operator' => 'blue', 'Builtin_Function' => 'blue', 'Keyword' => 'blue',};
while(my ($type, $style) = each %{$perldoc_Keys}) {
$formatter->set_format($type, [qq|<a onclick="window.open('http://perldoc.perl.org/search.html?q='+this.innerHTML)" style="color:$style">|, "</a>"]);
}
# local $/;
my ($file, $out) = @_;
open (IN, "$file") or die "$!: $file";
my @lines;
while(<IN>){
$_=~s|#!/usr/bin/perl ?-?w?||;
push @lines, $_
}
print q(<div  align="center"><div align="left" style="width:600px;overflow:auto;"><pre>) . $formatter->format_string("@lines") . "</pre></div></div>";
print $@ if $@;
}


1;
