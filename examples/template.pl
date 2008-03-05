#!/usr/bin/perl -w
use strict;
my @data = ({name => 'Header'}, {name => 'link', text => "Website", href => "http://lindnerei.de"}, {name => 'link', text => "Cpan", href => "http://search.cpan.org/~lze"}, {name => 'Footer'});

use Template::Quick;
my $temp = new Template::Quick({path => "./", template => "template.html"});
print $temp->initArray(\@data), $/;
