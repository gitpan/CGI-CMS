use HTML::Menu::Pages;

sub fulltext {
    my $search = param('query');
    print '<div align="center">';
    my @count = $search ? $database->fetch_array("SELECT count(*) FROM news  where `right` <= $right and MATCH (title,body) AGAINST(?)", $search) : 0;
    if($count[0] > 0) {
        my %needed = (
            start       => $von,
            length      => $count[0],
            style       => $style,
            mod_rewrite => 1,
            action      => "fulltext",
            append      => "&query=$search"
        );
        print makePages(\%needed);
        print "<br/>", $database->fulltext("$search", 'news', $right, $von, $bis);
    } else {
        my %parameter = (
            path   => $settings->{cgi}{bin} . '/templates',
            style  => $style,
            title  => qq(<div style="white-space:nowrap">$tlt</div>),
            server => $settings->{cgi}{serverName},
            id     => "reg$id",
            class  => 'min',
        );
        my $window = new HTML::Window(\%parameter);
        $window->set_closeable(0);
        $window->set_moveable(1);
        $window->set_resizeable(1);
        print br(), $window->windowHeader();
        my $ts = translate('search');
        print
          qq(<div align="center"><br/><div align="center"><img src="http://www.google.com/intl/en_ALL/images/logo.gif" alt="admin" border="0"/></div><br/><a href="http://www.google.com/custom?q=$search&amp;sa=Google+Search&amp;&amp;domains=$settings->{cgi}{serverName}&amp;sitesearch=$settings->{cgi}{serverName}" class="menulink">Search with Google</a><br/><br/>
                <form action="$ENV{SCRIPT_NAME}" name="search">
                <input align="top" type="text" maxlength="100" size="16" style="vertical-align:top;width:100px;height:22px;" title="$ts" name="keyword" id="keyword" value="$search"/>
               <input  type="hidden" name="action"  value="fulltext"/>
               <input type="submit"  name="submit" value="$ts" size="12" maxlength="15" alt="$ts" align="left" style="height:22px;vertical-align:top;"/>
               </form></div><br/>);
        print $window->windowFooter();
    }
    print '</div>';
}
1;
