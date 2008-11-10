#!/usr/bin/perl
use strict;
use lib("../lib");
use lib(".");
use HTML::Window qw(:all);
use CGI::CMS qw(:all);
print header;
print start_html(-title => 'Window', -script => [{-type => 'text/javascript', -src => '/javascript/window.js'}], -style => '/style/Crystal/window.css',);
my %parameter = (path => "../cgi-bin/templates/", server => "http://localhost", id => "a", style => 'Crystal');
set_closeable(1);
set_moveable(1);
set_resizeable(1);
set_class('min');
set_style('Crystal');
set_title('Test');
initWindow(\%parameter);
print windowHeader();
print "Body", br();
print windowFooter();
print a({href => 'javascript:displayWindow()', style => "display:none", id => "showWindows"}, "show Window");
print end_html;

use showsource;&showSource($0);
