
my %parameter = (
    path   => $settings->{cgi}{bin} . '/templates',
    style  => $style,
    title  => "&#160;Login",
    server => $settings->{cgi}{serverName},
    id     => 'nlogin',
    class  => 'sidebar',
);

my $window = new HTML::Window(\%parameter);
$window->set_closeable(1);
$window->set_moveable(0);
$window->set_resizeable(0);
$window->set_collapse(0);
print '<tr id="trwnlogin"><td valign="top">';
print $window->windowHeader();

if($user eq 'guest') {
    my $link    = $settings->{cgi}{mod_rewrite} ? "/reg.html" : "$ENV{SCRIPT_NAME}?action=reg";
    my $trlogin = translate('login');
    my $trreg   = translate('reg');

    print
      qq(<div align="center" id="form"><form  action=""  target="_parent" method="post"  name="Login"  onSubmit="return checkLogin()"><label for="user">Name</label><br/><input type="text" id="user" name="user" value="" size="18" maxlength="25" alt="Login" align="left"><br/><label for="password">Password</label><br/><input type="hidden" name="action" value="login"/><input type="password" id="password" name="pass" value ="" size="18" maxlength="50" alt="password" align="left"/><br/><br/><input type="submit"  name="submit" value="$trlogin" size="15" maxlength="15" alt="submit" align="left"/></form><a  class="link" href="$link">$trreg</a></div>);
} else {
    my $lg = $settings->{cgi}{mod_rewrite} ? '/logout.html' : "$ENV{SCRIPT_NAME}?action=logout";
    print qq(Willkommen, $user <br/><a  class="link" href="$lg">logout</a><br/>);
}
print $window->windowFooter();
print '</td></tr>';
1;
