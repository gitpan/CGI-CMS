use strict;
use CGI::CMS::Session;
use vars qw($session);
*session = \$CGI::CMS::Session::session;
$session = {
    query => "???Query.pl",
    Query => "./Query.pl"
};
saveSession("./Query.pl");
undef $session;
use Test::More tests => 3;
my $t1 = $session->{query};
ok( not defined $t1 );
loadSession("./Query.pl");
*session = \$CGI::CMS::Session::session;
$t1      = $session->{query};
my $t2 = $session->{Query};
ok( $t1 eq "???Query.pl" );
ok( $t2 eq "./Query.pl" );
system('rm ./Query.pl');
