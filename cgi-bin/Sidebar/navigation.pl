my @menu
    = $m_oDatabase->fetch_AoH(
    "select title,action,`submenu`,target from navigation where `right` <= $m_nRight order by position"
    );
my @t = fetchMenu(@menu);

sub fetchMenu {
    my @actions = @_;
    my @ret;
    for( my $i = 0; $i <= $#actions; $i++ ) {
        my $fm;
        unless ( $actions[$i]->{target} ) {
            $fm
                = ( $m_hrSettings->{cgi}{mod_rewrite} )
                ? "/$actions[$i]->{action}.html"
                : "$ENV{SCRIPT_NAME}?action=$actions[$i]->{action}";
        } else {
            $fm = $actions[$i]->{action};
        }
        if( $actions[$i]->{submenu} ) {
            my @sumenu = fetchMenu(
                $m_oDatabase->fetch_AoH(
                    "select * from $actions[$i]->{submenu} where `right` <= $m_nRight order by title"
                )
            );
            my $headline = translate( $actions[$i]->{title} );
            maxlength( 15, \$headline );
            push @ret,
                {
                text    => $headline,
                href    => $fm,
                subtree => [@sumenu],
                };
        } else {
            my $headline = translate( $actions[$i]->{title} );
            maxlength( 15, \$headline );
            push @ret,
                {
                text => $headline,
                href => $fm
                };
        }
    }
    return @ret;
}

loadTree( $m_hrSettings->{tree}{navigation} );
*m_aT1 = \@{ $HTML::Menu::TreeView::TreeView[0] };
push @t, @m_aT1;
my %parameter = (
    path   => $m_hrSettings->{cgi}{bin} . '/templates',
    style  => $m_sStyle,
    title  => "&#160;Navigation&#160;&#160;",
    server => $m_hrSettings->{cgi}{serverName},
    id     => "n1",
    class  => "sidebar",
);
my $window = new HTML::Window( \%parameter );
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
$m_sContent .= '<tr id="trwn1"><td valign="top" class="sidebar">';
$m_sContent .= $window->windowHeader();
$m_sContent .= Tree( \@t, $m_sStyle );
undef @m_aT1;
$m_sContent .= $window->windowFooter();
$m_sContent .= '<br/></td></tr>';

