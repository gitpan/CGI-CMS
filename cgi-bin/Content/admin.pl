my $serverdir = $settings->{cgi}{serverName};
my %parameter = (path => $settings->{cgi}{bin} . '/templates', style => $style, title => '&#160;Admin Center', server => $settings->{cgi}{serverName}, id => 'aboutWindow', class => 'max',);
my $window    = new HTML::Window(\%parameter);
$window->set_closeable(0);
$window->set_moveable(0);
$window->set_resizeable(0);
print '<br/>';
print $window->windowHeader();
print
  qq(<table align="center" border="0" cellpadding="0" cellspacing="0" summary="adminlayout" width="100%"><tr><td align="center"><a href="$ENV{SCRIPT_NAME}?action=settings">Settings</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=showTables">Database</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=editTreeview">Navigation</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=links&amp;dump=links">Links</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=showFiles">Files</a><br/><a href="$ENV{SCRIPT_NAME}?action=errorlog">Error Log</a>&#160;|&#160;<a href="$ENV{SCRIPT_NAME}?action=env">Envoirement Variables</a></td></tr></table><br>);
&showExploits() unless ($action eq 'deleteexploit');
print $window->windowFooter();

sub deleteExploit {
        my $id = param('id');
        $database->void("DELETE FROM exploit where id  = ?", $id);
        &showExploits();
}

sub showExploits {
        my @exploit = $database->fetch_AoH("select * from exploit");

        print "<h3>Exploits</h3>";
        for(my $i = 0 ; $i <= $#exploit ; $i++) {
                print "<hr/>";
                foreach my $key (keys %{$exploit[$i]}) {
                        print "<b>$key:</b> ", $exploit[$i]->{$key}, br();
                }
                print qq(<a href="$ENV{SCRIPT_NAME}?action=deleteExploit&amp;id=$exploit[$i]->{id}">Delete</a>);
        }

}
