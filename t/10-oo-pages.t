use lib qw(lib);
use HTML::Menu::Pages;
use Test::More tests => 1;
use Cwd;
my $cwd  = cwd();
my $test = new HTML::Menu::Pages;

my %needed = (

    start => '20',

    length => '345',

    style => 'Crystal',

    mod_rewrite => 1,

    action => 'dbs',

    linkspropage => 3,

);
ok(length($test->makePages(\%needed)) > 0);
