# use CGI::QuickForm;
my $TITLE = 'Profile';
my $utc   = $m_oDatabase->fetch_hashref(
    "select * from  users where user = '$m_sUser'");
show_form(
    -HEADER   => qq(<div style="align:center;">),
    -ACCEPT   => \&on_valid_form,
    -CHECK    => ( param('checkForm') ? 1 : 0 ),
    -LANGUAGE => $ACCEPT_LANGUAGE,
    -FIELDS   => [
        {   -LABEL    => 'Profile',
            -HEADLINE => 1,
            -COLSPAN  => 2,
            -END_ROW  => 1,
        },
        {   -LABEL   => 'action',
            -default => 'profile',
            -TYPE    => 'hidden',
        },
        {   -LABEL   => 'checkForm',
            -default => 'true',
            -TYPE    => 'hidden',
        },
        {   -LABEL   => 'validate',
            -default => 1,
            -TYPE    => 'hidden',
        },
        {   -LABEL    => translate('firstname'),
            -default  => $utc->{firstname},
            -VALIDATE => sub { $_[0] =~ /^\w{2,20}$/; },
        },
        {   -LABEL    => translate('name'),
            -default  => $utc->{name},
            -VALIDATE => sub { $_[0] =~ /^\w{2,20}$/; },
        },
        {   -LABEL    => translate('street'),
            -default  => $utc->{street},
            -VALIDATE => sub { $_[0] =~ /^.{2,100}$/; },
        },
        {   -LABEL    => translate('city'),
            -default  => $utc->{city},
            -VALIDATE => sub { $_[0] =~ /^\w{3,100}$/; },
        },
        {   -LABEL   => translate('postcode'),
            -default => $utc->{postcode},
        },
        {   -LABEL   => translate('phone'),
            -default => $utc->{phone},
        },
        {   -LABEL   => translate('pass'),
            -default => '',
            -TYPE    => 'password_field',
        },
        {   -LABEL   => translate('newpass'),
            -default => '',
            -TYPE    => 'password_field',
        },
        {   -LABEL   => translate('retry'),
            -default => '',
            -TYPE    => 'password_field',
        },
        {   -LABEL    => translate('email'),
            -default  => $utc->{email},
            -VALIDATE => sub {
                $_[0] =~ /^\S{3,100}$/;
            },
        },
    ],
    -BUTTONS => [
        { -name => translate('save'), },
    ],
    -FOOTER => '</div>',
);

my $gh = GetHtml();
if( defined $gh ) {
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => " ",
        server => $m_hrSettings->{serverName},
        id     => 'profile',
        class  => 'none',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= $window->windowHeader();
    $m_sContent .= table(
        {   align => 'center',
            width => '*'
        },
        Tr( td( GetHtml() ) )
    );
    $m_sContent .= $window->windowFooter();
}

sub on_valid_form {
    my $firstname = param( translate('firstname') );
    my $name      = param( translate('name') );
    my $street    = param( translate('street') );
    my $city      = param( translate('city') );
    my $postcode  = param( translate('postcode') );
    my $phone     = param( translate('phone') );
    my $pass      = param( translate('pass') );
    my $newpass   = param( translate('newpass') );
    my $retry     = param( translate('retry') );
    my $email     = param( translate('email') );
    my $md5       = new MD5;
    $md5->add($m_sUser);
    $md5->add($pass);
    my $cyrptpass = $md5->hexdigest();

    if(    $m_oDatabase->checkPass( $m_sUser, $cyrptpass )
        && $newpass eq $retry
        && $newpass =~ /^\S{2,50}$/ )
    {
        use MD5;
        my $md5 = new MD5;
        $md5->add($m_sUser);
        $md5->add($newpass);
        my $newpass = $md5->hexdigest();
        $m_oDatabase->void(
            "update `users` set `pass` = '$newpass',`email` = '$email',`name` = '$name',`firstname` ='$firstname',`street` ='$street',`city` = '$city',`postcode` = '$postcode',`phone` ='$phone' where user = '$m_sUser'"
        );
        $pass = $retry;
    } else {
        $m_oDatabase->void(
            "update `users` set `email` = '$email',`name` = '$name',`firstname` ='$firstname',`street` ='$street',`city` = '$city',`postcode` = '$postcode',`phone` ='$phone' where user = '$m_sUser'"
        );
    }
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => " ",
        server => $m_hrSettings->{serverName},
        id     => 'profile',
        class  => 'none',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= $window->windowHeader();
    $m_sContent
        .= '<b>'
        . translate('done')
        . '</b><br/><table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" align="center">
<tr><td align="left">'
        . translate('firstname')
        . '</td><td>'
        . $firstname
        . '</td></tr><tr><td align="left">'
        . translate('name')
        . '</td><td>'
        . $name
        . '</td></tr>
<tr><td align="left">'
        . translate('street')
        . '</td><td>'
        . $street
        . '</td></tr><tr><td align="left">'
        . translate('city')
        . '</td><td>'
        . $city
        . '</td></tr>
<tr><td align="left">'
        . translate('postcode')
        . '</td><td>'
        . $postcode
        . '</td></tr><tr><td align="left">'
        . translate('phone')
        . '</td><td>'
        . $phone
        . '</td></tr>
<tr><td align="left">'
        . translate('email') . '</td><td>' . $email . '</td></tr>';
    $m_sContent
        .= '<tr><td align="left">'
        . translate('newpass')
        . '</td><td>'
        . $pass
        . '</td></tr>'
        if( defined $newpass && defined $retry && $newpass eq $retry );
    $m_sContent .= '</table>'
        . a(
        {   href  => "$ENV{SCRIPT_NAME}?action=profile",
            class => 'links'
        },
        translate('next')
        );
    $m_sContent .= $window->windowFooter();

}

1;
