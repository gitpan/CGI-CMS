#!/usr/bin/perl -w
use lib qw(lib);
use strict;
use CGI::CMS::GUI::Main;
my %set = (path => "./templates", size => 16, style => "Crystal", title => "CGI::CMS::GUI::Main", server => "http://localhost", login => "",);
my $main = new CGI::CMS::GUI::Main(\%set);
use CGI::CMS qw(header);
print header;
print $main->Header();
use showsource;
&showSource("./main.pl");
print $main->Footer();
