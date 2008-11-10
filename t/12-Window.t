use strict;
use warnings;
use lib("../lib");
use HTML::Window;
my %parameter = (
    path   => "cgi-bin/templates",
    server => "http://localhost",
);
my $window = new HTML::Window();
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
$window->set_class('sidebar');
$window->set_style('Crystal');
$window->set_title('Test');
$window->set_collapse(1);
$window->initWindow( \%parameter );
my $h1 = $window->windowHeader();
my $h2 = $window->windowFooter();

# $window->set_closeable();
# $window->set_moveable();
# $window->set_resizeable();
# $window->set_class();
# $window->set_style();
# $window->set_title();
# $window->set_collapse();

use Test::More tests => 3;
ok( length($h1) > 0 );
ok( length($h2) > 0 );
ok( length($h1) > length($h2) );
