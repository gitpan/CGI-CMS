my @t;
my $v = 0;
my $b = 10;
if( $m_hrAction eq 'news' ) {
    $v = $m_nStart;
    $b = $m_nEnd;
}
my $vr = $m_hrAction eq 'news' ? $m_nStart : 0;
$b = param('links_pro_page') ? $m_nStart+ param('links_pro_page') : $b;
my @news = $m_oDatabase->readMenu( 'news', $m_nRight, $vr, $b,
    $m_hrSettings->{cgi}{mod_rewrite} );
unshift @t,
    {
    text => $m_hrSettings->{cgi}{title},
    href => ( $m_hrSettings->{cgi}{mod_rewrite} )
    ? "/news.html"
    : "$ENV{SCRIPT_NAME}?action=news",
    subtree => [@news],
    };
my %parameter = (
    path   => $m_hrSettings->{cgi}{bin} . '/templates',
    style  => $m_sStyle,
    title  => "&#160;News&#160;&#160;",
    server => $m_hrSettings->{cgi}{serverName},
    id     => "news1",
    class  => "sidebar",
);
my $window = new HTML::Window( \%parameter );
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
$m_sContent .= '<tr id="trwnews1"><td valign="top" class="sidebar">';
$m_sContent .= $window->windowHeader();
$m_sContent .= Tree( \@t, $m_sStyle );
$m_sContent .= $window->windowFooter();
$m_sContent .= '<br/></td></tr>';
