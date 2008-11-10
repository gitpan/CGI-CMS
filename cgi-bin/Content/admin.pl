my $serverdir = $m_hrSettings->{cgi}{serverName};
my %parameter = (
    path   => $m_hrSettings->{cgi}{bin} . '/templates',
    style  => $m_sStyle,
    title  => '&#160;Admin Center',
    server => $m_hrSettings->{cgi}{serverName},
    id     => 'aboutWindow',
    class  => 'max',
);
my $window = new HTML::Window( \%parameter );
$window->set_closeable(0);
$window->set_moveable(0);
$window->set_resizeable(0);
$m_sContent .= br();
$m_sContent .= $window->windowHeader();
$m_sContent
    .= qq(<table align="center" border="0" cellpadding="0" cellspacing="0" summary="adminlayout" width="100%"><tr><td align="center"><a href="$ENV{SCRIPT_NAME}?action=settings">Settings</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=showTables">Database</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=editTreeview">Navigation</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=links&amp;dump=links">Links</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=showFiles">Files</a><br/><a href="$ENV{SCRIPT_NAME}?action=errorlog">Error Log</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=env">Envoirement Variables</a></td></tr></table><br>);
&showExploits() unless ( $m_hrAction eq 'deleteexploit' );
$m_sContent .= $window->windowFooter();

sub deleteExploit {
    my $id = param('id');
    $m_oDatabase->void( "DELETE FROM exploit where id  = ?", $id );
    &showExploits();
}

sub showExploits {
    my @exploit = $m_oDatabase->fetch_AoH("select * from exploit");

    $m_sContent
        .= q(<div align="center" style="width:95%;overflow:auto;"><h3>Exploits</h3>);
    for( my $i = 0; $i <= $#exploit; $i++ ) {
        $m_sContent .= "<hr/>";
        foreach my $key ( keys %{ $exploit[$i] } ) {
            $m_sContent .= "<b>$key:</b> " . $exploit[$i]->{$key} . br();
        }
        $m_sContent
            .= qq(<a href="$ENV{SCRIPT_NAME}?action=deleteExploit&amp;id=$exploit[$i]->{id}">Delete</a>);
    }
    $m_sContent .= q(</div>);
}
