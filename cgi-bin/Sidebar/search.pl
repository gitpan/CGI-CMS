my %parameter = (
    path   => $settings->{cgi}{bin} . '/templates',
    style  => $style,
    title  => "&#160;Suchen",
    server => $settings->{cgi}{serverName},
    id     => "search1",
    class  => "sidbar",
);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(0);
$window->set_moveable(1);
$window->set_resizeable(0);
print '<tr id="trwsearch1"><td valign="top">';
print $window->windowHeader();
print '<div align="center"><script src="/javascript/search.js" type="text/javascript" language="JavaScript"></script></div>';
print $window->windowFooter();
print '</td></tr>';
