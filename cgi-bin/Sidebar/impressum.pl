my %parameter = (path => $settings->{cgi}{bin} . '/templates', style => $style, title => "&#160;$settings->{cgi}{title}&#160;", server => $settings->{cgi}{serverName}, id => 'n5', class => 'sidebar',);

my $window = new HTML::Window(\%parameter);
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
print '<tr id="trwn5"><td valign="top">';
print $window->windowHeader();
print qq(<h2 ><a href="index.html">$settings->{cgi}{title}</a></h2>
Konzept Design, und Realisierung:<br/>
 Siehe <a href="javascript:showAbout()"  >&#220;ber</a><br/>
<br/>
<a href="javascript:showDisclaimer()" >Haftungsauschluss</a><br/>
<a href="javascript:showquelle()" >Quellen</a><br/>
<ul>
<li>Benutze Software:</li>
<li>Module und Scripts</li>
<li>Bilder usw:</li>
<li>Sever &#038;  Domain</li>
</ul>);
print $window->windowFooter();
print '</td></tr>';
