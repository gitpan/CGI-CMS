my %parameter = (path => $settings->{cgi}{bin} . '/templates', style => $style, title => "&#160;Valid&#160;HTML&#160;", server => $settings->{cgi}{serverName}, id => 'validwin', class => 'sidebar',);

my $window = new HTML::Window(\%parameter);
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
$window->set_collapse(1);
print '<tr id="trwvalidwin"><td valign="top">';
print $window->windowHeader();
print
  '<div align="center"><a target="_blank" href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10-blue" alt="Valid HTML " height="31" width="88" border="0"/></a><br/><a target="_blank" href="http://jigsaw.w3.org/css-validator/validator?uri=referer"><img src="http://www.w3.org/Icons/valid-css-blue.png" alt="Valid HTML Css2" height="31" width="88" border="0"/></a><br/>';
print $ENV{MOD_PERL} if $mod_perl;
print '</div>';
print $window->windowFooter();
print '</td></tr>';
