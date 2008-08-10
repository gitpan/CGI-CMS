use strict;
use vars qw($lang);
use CGI::CMS qw(:lze param);
init("t/settings.pl");
*lang = \$CGI::CMS::lng;
use Test::More tests => 7;
$ENV{HTTP_ACCEPT_LANGUAGE} = "de";
ok(translate('firstname') eq 'Vorname');
$ENV{HTTP_ACCEPT_LANGUAGE} = "en";
ok(translate('username')  eq 'User');
ok($lang->{de}{firstname} eq 'Vorname');
ok($lang->{en}{username}  eq 'User');
init("t/settings.pl");
my %vars = (
    user   => 'guest',
    action => 'main',
    file   => "t/content.pl",
    sub    => 'main'
);
my $qstring = createSession(\%vars);
param(
    -name  => 'include',
    -value => $qstring
);
include($qstring);
ok($params->{test} eq "OK");
clearSession();
ok(sessionValidity()== 120);
sessionValidity(12);
ok(sessionValidity()== 12);
