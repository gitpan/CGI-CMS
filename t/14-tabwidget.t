use lib qw(lib/);
use HTML::TabWidget qw(:all);
use Test::More tests => 3;
use Cwd;
my $cwd = cwd();
my %parameter = (
                 style   => 'Crystal',
                 path    => "$cwd/cgi-bin/templates",
                 anchors => [{text => 'HTML::TabWidget ', href => "href", class => 'currentLink', src => 'link.png'}, {text => 'Next', class => 'links',}, {text => 'Dynamic Tab', href => 'javascript:displayhidden()', class => 'javaScriptLink',}],
);
initTabWidget(\%parameter);
my $m   = Menu(\%parameter);
my $h   = tabwidgetHeader();
my $f   = tabwidgetFooter();
my $tbw = new HTML::TabWidget(\%parameter);
my $m2  = $tbw->Menu(\%parameter);
my $h2  = $tbw->tabwidgetHeader();
my $f2  = $tbw->tabwidgetFooter();
ok($m eq $m2);
ok($h eq $h2);
ok($f eq $f2);

