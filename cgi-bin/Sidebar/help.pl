my %parameter = (
    path   => $m_hrSettings->{cgi}{bin} . '/templates',
    style  => $m_sStyle,
    title  => translate('help'),
    server => $m_hrSettings->{cgi}{serverName},
    id     => 'nlogin',
    class  => 'sidebar',
);
my $window = new HTML::Window( \%parameter );
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
$window->set_collapse(1);
$m_sContent .= '<tr id="trwnhelp"><td valign="top" class="sidebar">';
$m_sContent .= $window->windowHeader();
$m_sContent .= q(
<ul>
<li><a href="#inst">Installation</a></li>
<li><a href="#apache">Apache2 Config</a></li>
<li><a href="#video">Video Tutorials</a></li>
<li><a href="#dev">Developer</a></li>
<li><a href="#modules">Module Documentation</a></li>
<li><a href="#examples">Examples</a></li>
<li><a href="#bbcode">BBcode tags</a></li>
</ul>);
$m_sContent .= $window->windowFooter();
$m_sContent .= '<br/></td></tr>';
1;
