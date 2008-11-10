my %parameter = (
    path   => $m_hrSettings->{cgi}{bin} . '/templates',
    style  => $m_sStyle,
    title  => "&#160;Suchen",
    server => $m_hrSettings->{cgi}{serverName},
    id     => "search1",
    class  => "sidbar",
);
my $window = new HTML::Window( \%parameter );
$window->set_closeable(0);
$window->set_moveable(1);
$window->set_resizeable(0);
$m_sContent .= '<tr id="trwsearch1"><td valign="top" class="sidebar">';
$m_sContent .= $window->windowHeader();
$m_sContent
    .= '<div align="center"><script src="/javascript/search.js" type="text/javascript" language="JavaScript"></script></div>';
$m_sContent .= $window->windowFooter();
$m_sContent .= '<br/></td></tr>';
