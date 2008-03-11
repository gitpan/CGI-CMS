#!/usr/bin/perl -w
use lib qw(../lib);
use CGI::CMS;
use strict;
my $cgi = CGI::CMS->new();
print $cgi->header;
if($cgi->param('include')) {
        $cgi->include();
        print $cgi->a({href => "$ENV{SCRIPT_NAME}"}, 'next');
        $cgi->clearSession();
} else {
        my %vars = (user => 'guest', action => 'main', file => "./content.pl", sub => 'main');
        my $qstring = $cgi->createSession(\%vars);
        print qq(Action wurde erzeugt.);
        print $cgi->br(), $cgi->a({href => "$ENV{SCRIPT_NAME}?include=$qstring"}, 'next');
}

use showsource;
&showSource($0);

