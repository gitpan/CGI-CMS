my @t;
my $v = 0;
my $b = 10;
if($action eq 'news') {
    $v = $von;
    $b = $bis;
}
my $vr = $action eq 'news' ? $von : 0;

my @news = $database->readMenu('news', $right, $vr, $b, $settings->{cgi}{mod_rewrite});
unshift @t,
  {
    text    => $settings->{cgi}{title},
    href    => ($settings->{cgi}{mod_rewrite}) ? "/news.html" : "$ENV{SCRIPT_NAME}?action=news",
    subtree => [@news],
  };
my %parameter = (
    path   => $settings->{cgi}{bin} . '/templates',
    style  => $style,
    title  => "&#160;News&#160;&#160;",
    server => $settings->{cgi}{serverName},
    id     => "news1",
    class  => "sidebar",
);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
print '<tr id="trwnews1"><td valign="top">';
print $window->windowHeader();
print Tree(\@t, $style);
print $window->windowFooter();
print '</td></tr>';
