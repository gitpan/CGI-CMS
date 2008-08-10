#!/usr/bin/perl -w
use CGI::CMS;
use strict;
my $cgi = CGI::CMS->new();
$cgi->init("/srv/www/cgi-bin/config/settings.pl");
print $cgi->header;
if(param('include')) {
    $cgi->include();
    print $cgi->a({href => "$ENV{SCRIPT_NAME}"}, 'next');
    $cgi->clearSession();
} else {
    my %vars = (
        user   => 'guest',
        action => 'main',
        file   => "./content.pl",
        sub    => 'main'
    );
    my $qstring = $cgi->createSession(\%vars);
    print qq(Action wurde erzeugt.);
    print $cgi->br(), $cgi->a({href => "$ENV{SCRIPT_NAME}?include=$qstring"}, 'next');
}
print "Content Source<br/>";
use showsource;
&showSource('./content.pl');
