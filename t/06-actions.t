use CGI::CMS::Actions;
use strict;
use vars qw($actions);
*actions = \$CGI::CMS::Actions::actions;
$actions = {
    actions => "???actions.pl",
    Actions => "./actions.pl"
};
saveActions("./actions.pl");
loadActions("./actions.pl");
my $t1 = $actions->{actions};
my $t2 = $actions->{Actions};
use Test::More tests => 2;
ok($t1 eq "???actions.pl");
ok($t2 eq "./actions.pl");
system('rm ./actions.pl');
