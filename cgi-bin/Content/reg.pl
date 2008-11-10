sub reg {
    my $m_sUserRegName = param('username');
    $m_sUserRegName
        = ( $m_sUserRegName =~ /^(\w{3,10})$/ )
        ? $1
        : translate('insertname');
    $m_sUserRegName = lc $m_sUserRegName;
    my $email = param('email');
    my %vars  = (
        title  => 'reg',
        user   => 'guest',
        action => 'makeUser',
        file   => "$m_hrSettings->{cgi}{bin}/Content/reg.pl",
        sub    => 'make',
        right  => 0
    );
    my $qstring   = createSession( \%vars );
    my $register  = translate('register');
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => $register,
        server => $m_hrSettings->{cgi}{serverName},
        id     => "reg$id",
        class  => 'reg',
    );
    my $window    = new HTML::Window( \%parameter );
    my $t_regtext = translate('t_regtext');
    $m_sContent
        .= qq(<table  border="0" cellpadding="0" cellspacing="10" summary="contentLayout" width="100%"><tr><td valign="top" align="center">);
    $m_sContent
        .= br()
        . $window->windowHeader()
        . qq(<div align="center">$t_regtext<br/><form action="$ENV{SCRIPT_NAME}"  method="post"  name="Login" ><label for="username">Name</label><br/><input type="text" name="username" id="username" title="Bitte geben Sie ihren Namen  ein." value="$m_sUserRegName" size="20" maxlength="10" alt="Login" align="left"/><br/><label for="email">Email</label><br/><input type="text" name="email" value="$email" id="email" size="20" maxlength="200" alt="email" align="left"/><br/><input type="hidden" name="include" value="$qstring"/><br/><input type="submit"  name="submit" value="$register" size="15" alt="$register" align="left"/></form></div>)
        . $window->windowFooter();
    $m_sContent .= '</td></tr></table>';
}

sub make {
    my $fr             = 0;
    my $fingerprint    = param('fingerprint');
    my $m_sUserRegName = param('username');
    my $email          = param('email');
    my $imagedir       = $m_hrSettings->{'cgi'}{'DocumentRoot'} . '/images/';
    my $tlt            = translate('register');
    my %parameter      = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => $tlt,
        server => $m_hrSettings->{cgi}{serverName},
        id     => "reg$id",
        class  => 'reg',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
SWITCH: {

        if( defined $m_sUserRegName ) {
            if( $m_oDatabase->isMember($m_sUserRegName) ) {

                $m_sContent .= translate('userexits');
                $fr             = 1;
                $m_sUserRegName = undef;
            }
        } else {
            $m_sContent .= translate('wrongusername');
            $fr = 1;
        }
        if( $m_oDatabase->hasAcount($email) ) {
            $m_sContent .= translate('haveacount');
            $fr             = 1;
            $m_sUserRegName = undef;
        }
        unless ( defined $email ) {
            $m_sContent .= translate('nomail');
            $fr = 1;
        }
        &reg() if($fr);
        last SWITCH if($fr);
        use Mail::Sendmail;
        my $pass = int( rand(1000)+ 1 ) x 3;
        my %mail = (
            To      => "$email",
            From    => $m_hrSettings->{'admin'}{'email'},
            subject => translate('mailsubject'),
            Message => translate('regmessage')
                . translate('username')
                . ": $m_sUserRegName "
                . translate('password')
                . ":$pass"
        );
        sendmail(%mail) or warn $Mail::Sendmail::error;
        $m_oDatabase->addUser( $m_sUserRegName, $pass, $email );
        $m_sContent .= translate('mailsendet');
    }
    clearSession();
    $m_sContent .= $window->windowFooter();
}
1;
