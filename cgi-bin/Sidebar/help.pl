my %parameter = (
    path   => $settings->{cgi}{bin} . '/templates',
    style  => $style,
    title  => translate('help'),
    server => $settings->{cgi}{serverName},
    id     => 'nlogin',
    class  => 'sidebar',
);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
$window->set_collapse(1);
print '<tr id="trwnhelp"><td valign="top">';
print $window->windowHeader();
print q(
<ul>
<li><a href="#inst">Installation</a></li>
<li><a href="#apache">Apache2 Config</a></li>
<li><a href="#video">Video Tutorials</a></li>
<li><a href="#dev">Developer</a></li>
<li><a href="#modules">Module Documentation</a></li>
<li><a href="#examples">Examples</a></li>
<li><a href="#bbcode">BBcode tags</a></li>
</ul>);
print $window->windowFooter();
print '</td></tr>';
1;
