#!/usr/bin/perl -w
use lib("lib");
use CGI::CMS qw(:all :lze);
use strict;
my $cgi = CGI::CMS->new();
print header;
$ENV{SCRIPT_NAME} = "test.pl";

# param(-name=>'query',-value => 'test');
if(param('query')) {
        my $pa = param('query');
        init("/srv/www/cgi-bin/config/settings.pl");
        print a({href => "$ENV{SCRIPT_NAME}"}, 'next');
        clearSession();
} else {
        init("/srv/www/cgi-bin/config/settings.pl");
        my %vars = (user => 'guest', action => 'main', file => "/srv/www/vhosts/api/LZE/cvs/examples/content.pl", sub => 'main');
        my $qstring = createSession(\%vars);
        print qq(Action wurde erzeugt.);
        print br(), a({href => "$ENV{SCRIPT_NAME}?query=$qstring"}, 'next');
}

