my @menu = $database->fetch_array("show tables");
my @t;
my @dbs;
for(my $i = 0 ; $i <= $#menu ; $i++) {
        push @dbs, {text => $menu[$i], href => "$ENV{SCRIPT_NAME}?action=showEntry&amp;table=$menu[$i]",};
}
push @t, {text => "Tables", href => "/showTables.html", subtree => [@dbs],};
my %parameter = (path => $settings->{cgi}{bin} . '/templates', style => $style, title => "&#160;Datenbank&#160;&#160;&#160;&#160;", server => $settings->{cgi}{serverName}, id => "ndb1", class => "sidebar",);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
print '<tr id="trwndb1"><td valign="top">';
print $window->windowHeader();
print Tree(\@t, $style);
print $window->windowFooter();
print '</td></tr>';
