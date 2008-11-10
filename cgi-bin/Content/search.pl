use HTML::Menu::Pages;

sub fulltext {
    my $search    = param('query');
    my %parameter = (
        path     => $m_hrSettings->{cgi}{bin} . '/templates',
        style    => $m_sStyle,
        template => "wnd.htm",
        server   => $m_hrSettings->{serverName},
        id       => 'Search',
        class    => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= '<div align="center">';
    my @count
        = $search
        ? $m_oDatabase->fetch_array(
        "SELECT count(*) FROM news  where `right` <= $m_nRight and MATCH (title,body) AGAINST(?)",
        $search
        )
        : 0;
    if( $count[0] > 0 ) {
        my %needed = (
            start       => $m_nStart,
            length      => $count[0],
            style       => $m_sStyle,
            mod_rewrite => 1,
            action      => "fulltext",
            append      => "&query=$search"
        );

        $m_sContent .= makePages( \%needed );
        $m_sContent
            .= $m_oDatabase->fulltext( $search, 'news', $m_nRight, $m_nStart,
            $m_nEnd );

    } else {
        $m_sContent .= br() . $window->windowHeader();
        my $ts = translate('search');
        $m_sContent
            .= qq(<div align="center"><br/><a href="http://www.google.com/custom?q=$search&amp;sa=Google+Search&amp;&amp;domains=$m_hrSettings->{cgi}{serverName}&amp;sitesearch=$m_hrSettings->{cgi}{serverName}" class="menulink">Search with Google</a><br/><br/>
                <form action="$ENV{SCRIPT_NAME}" name="search">
                <input align="top" type="text" maxlength="100" size="16"  title="$ts" name="keyword" id="keyword" value="$search"/>
               <input  type="hidden" name="action"  value="fulltext"/>
               <input type="submit"  name="submit" value="$ts" size="12" maxlength="15" alt="$ts" align="left" />
               </form></div><br/>);
        $m_sContent .= $window->windowFooter();
    }
    $m_sContent .= '</div>';
    $m_sContent .= $window->windowFooter();
}
1;
