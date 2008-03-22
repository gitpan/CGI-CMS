sub reg {
        my $userRegName = param('username');
        $userRegName = ($userRegName =~ /^(\w{3,10})$/) ? $1 : translate('insertname');
        $userRegName = lc $userRegName;
        my $email     = param('email');
        my %vars      = (title => 'reg', user => 'guest', action => 'makeUser', file => "$settings->{cgi}{bin}/Content/reg.pl", sub => 'make', right => 0);
        my $qstring   = createSession(\%vars);
        my $register  = translate('register');
        my $tlt       = translate('register');
        my %parameter = (path => $settings->{cgi}{bin} . '/templates', style => $style, title => $tlt, server => $settings->{cgi}{serverName}, id => "reg$id", class => 'reg',);
        my $window    = new HTML::Window(\%parameter);
        $window->set_closeable(0);
        $window->set_moveable(1);
        $window->set_resizeable(0);
        my $t_regtext = translate('t_regtext');
        print qq(<table  border="0" cellpadding="0" cellspacing="10" summary="contentLayout" width="100%"><tr><td valign="top" align="center">);
        print br(), $window->windowHeader(),
          qq(<div align="center">$t_regtext<br/><form action="$ENV{SCRIPT_NAME}"  method="post"  name="Login" ><label for="username">Name</label><br/><input type="text" name="username" id="username" title="Bitte geben Sie ihren Namen  ein." value="$userRegName" size="20" maxlength="10" alt="Login" align="left"/><br/><label for="email">Email</label><br/><input type="text" name="email" value="$email" id="email" size="20" maxlength="200" alt="email" align="left"/><br/><input type="hidden" name="include" value="$qstring"/><br/><input type="submit"  name="submit" value="$register" size="15" alt="$register" align="left"/></form></div>),
          $window->windowFooter();
        print '</td></tr></table>';

}

sub make {
        my $fr          = 0;
        my $fingerprint = param('fingerprint');
        my $userRegName = param('username');
        my $email       = param('email');
        my $imagedir    = $settings->{'cgi'}{'DocumentRoot'} . '/images/';
        my $tlt         = translate('register');
        my %parameter   = (path => $settings->{cgi}{bin} . '/templates', style => $style, title => $tlt, server => $settings->{cgi}{serverName}, id => "reg$id", class => 'reg',);
        my $window      = new HTML::Window(\%parameter);
        $window->set_closeable(0);
        $window->set_moveable(1);
        $window->set_resizeable(0);
        print br(), $window->windowHeader();
      SWITCH: {

                if(defined $userRegName) {
                        if($database->isMember($userRegName)) {

                                print translate('userexits');
                                $fr          = 1;
                                $userRegName = undef;
                        }
                } else {
                        print translate('wrongusername');
                        $fr = 1;
                }
                if($database->hasAcount($email)) {
                        print translate('haveacount');
                        $fr          = 1;
                        $userRegName = undef;
                }
                unless (defined $email) {
                        print translate('nomail');
                        $fr = 1;
                }
                &reg()      if($fr);
                last SWITCH if($fr);
                use Mail::Sendmail;
                my $pass = int(rand(1000)+ 1) x 3;
                my %mail = (To => "$email", From => $settings->{'admin'}{'email'}, subject => translate('mailsubject'), Message => translate('regmessage') . translate('username') . ": $userRegName " . translate('password') . ":$pass");
                sendmail(%mail) or warn $Mail::Sendmail::error;
                $database->addUser($userRegName, $pass, $email);
                print translate('mailsendet');
        }
        clearSession();
        print $window->windowFooter();
}
1;
