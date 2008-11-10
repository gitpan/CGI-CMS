#!/usr/bin/perl -w
use strict;
# use lib qw(lib);
use CGI;
# use CGI::Ajax;
use CGI::CMS::GUI;

my $m_oCgi = new CGI;
# my $pjx = new CGI::Ajax(
#     'exported_func' => \&ajaxHandler,
#     'skip_header'   => 1,
#   );

ContentHeader("%PATH%/config/settings.pl");
print Body();
# print $pjx->build_html( $m_oCgi, \&Body) unless $m_oCgi->param('action') eq 'rss';

#Do your ajax stuff....

# sub ajaxHandler {
#     my $input = shift;
#     my $output = $input . " was the input!";
#     return( $output );
# }