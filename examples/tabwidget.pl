#!/usr/bin/perl -w
use lib qw(../lib);
use CGI::CMS qw(:all);
init();
print header;
print start_html(
    -title  => 'HTML::TabWidget',
    -script => [
        {   -type => 'text/javascript',
            -src  => '/javascript/tabwidget.js'
        }
    ],
    -style => '/style/Crystal/tabwidget.css',
);

use HTML::TabWidget qw(:all);

my %parameter = (
    style   => 'Crystal',
    path    => "../templates",
    anchors => [
        {   text  => 'HTML::TabWidget ',
            src   => 'link.png',
            href  => $ENV{SCRIPT_NAME},
            class => 'link',
        },
        {   text  => 'Next',
            href  => "$ENV{SCRIPT_NAME}?do=1",
            class => 'link',
        },
    ],
);
initTabWidget( \%parameter );
    print Menu( \%parameter );
    print tabwidgetHeader();
    print Menu( \%parameter );
    print tabwidgetHeader();
     print tabwidgetFooter();
    print tabwidgetFooter();
if( param('do') ) {
    $parameter{anchors}[1]{class} = 'currentLink';
    $parameter{anchors}[1]{text}  = 'Current Page';

    do("./content.pl");
} else {
    $parameter{anchors}[0]{class} = 'currentLink';
    print Menu( \%parameter );
    print tabwidgetHeader();
    print "Body";
}
use showsource;
&showSource($0);

print end_html;

