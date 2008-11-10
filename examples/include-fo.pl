#!/usr/bin/perl -w
use CGI::CMS;
use strict;
my $m_oCgi = CGI::CMS->new();
$m_oCgi->init();
print $m_oCgi->header;
if( param('include') ) {
    $m_oCgi->include();
    print $m_oCgi->a( { href => "$ENV{SCRIPT_NAME}" }, 'next' );
    $m_oCgi->clearSession();
} else {
    my %vars = (
        user   => 'guest',
        action => 'main',
        file   => "./content.pl",
        sub    => 'main'
    );
    my $qstring = $m_oCgi->createSession( \%vars );
    print qq(Action wurde erzeugt.);
    print $m_oCgi->br(),
        $m_oCgi->a( { href => "$ENV{SCRIPT_NAME}?include=$qstring" },
        'next' );
}
print "Content Source<br/>";
use showsource;
&showSource('./content.pl');
