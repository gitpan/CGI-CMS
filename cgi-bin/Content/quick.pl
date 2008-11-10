CGI::CMS::Settings::loadSettings(
    "$m_hrSettings->{cgi}{bin}/config/settings.pl");

my $TITLE = 'Edit Configuration';
my @boxes;
my @a       = $m_oDatabase->fetch_AoH('select * from box ');
my %options = (
    'left'     => [ 'left',     'right', 'disabled' ],
    'right'    => [ 'right',    'left',  'disabled' ],
    'disabled' => [ 'disabled', 'left',  'right' ],
);
foreach ( my $i = 0; $i <= $#a; $i++ ) {
    push @boxes,
        {
        -LABEL     => $a[$i]->{name},
        -TYPE      => 'scrolling_list',
        '-values'  => $options{ $a[$i]->{position} },
        -size      => 1,
        -multiples => 0,
        -VALIDATE  => \&validBox,
        };
}

show_form(
    -HEADER   => qq(<div style="padding-left:50px;"><h2>$TITLE</h2>),
    -ACCEPT   => \&on_valid_form,
    -CHECK    => ( param('checkForm') ? 1 : 0 ),
    -LANGUAGE => $ACCEPT_LANGUAGE,
    -FIELDS   => [
        {   -LABEL    => 'Boxen',
            -HEADLINE => 1,
            -COLSPAN  => 2,
            -END_ROW  => 1,
        },
        @boxes,
        {   -LABEL   => 'action',
            -default => 'm_hrSettings',
            -TYPE    => 'hidden',
        },
        {   -LABEL   => 'checkForm',
            -default => 'true',
            -TYPE    => 'hidden',
        },
        {   -LABEL    => 'Default',
            -HEADLINE => 1,
            -COLSPAN  => 2,
            -END_ROW  => 1,
        },
        {   -LABEL    => 'sidebarLeft',
            -TYPE     => 'scrolling_list',
            '-values' => [
                ( $m_hrSettings->{sidebar}{left} ) ? ( 'Enabled', 'Disabled' )
                : ( 'Disabled', 'Enabled' )
            ],
            -size      => 1,
            -multiples => 0,
            -VALIDATE  => \&enabledDisabled,
        },
        {   -LABEL    => 'sidebarRight',
            -TYPE     => 'scrolling_list',
            '-values' => [
                  ( $m_hrSettings->{sidebar}{right} )
                ? ( 'Enabled', 'Disabled' )
                : ( 'Disabled', 'Enabled' )
            ],
            -size      => 1,
            -multiples => 0,
            -VALIDATE  => \&enabledDisabled,
        },
        {   -LABEL    => 'language',
            -default  => $m_hrSettings->{language},
            -VALIDATE => \&acceptLanguage,
        },
        {   -LABEL    => 'defaultAction',
            -default  => $m_hrSettings->{defaultAction},
            -VALIDATE => \&validDefaultAction,
        },
        {   -LABEL    => 'CGI',
            -HEADLINE => 1,
            -COLSPAN  => 2,
            -END_ROW  => 1,
        },
        {   -LABEL   => 'Homepage Title',
            -default => $m_hrSettings->{cgi}{title},
        },
        {   -LABEL    => 'DocumentRoot',
            -VALIDATE => \&exits,
            -default  => $m_hrSettings->{cgi}{DocumentRoot},
        },
        {   -LABEL    => 'cgi-bin',
            -VALIDATE => \&exits,
            -default  => $m_hrSettings->{cgi}{bin},
        },
        {   -LABEL    => 'Style',
            -VALIDATE => \&validStyle,
            -default  => $m_hrSettings->{cgi}{style},
        },
        {   -LABEL   => 'CookiePath',
            -default => $m_hrSettings->{cgi}{cookiePath},
        },
        {   -LABEL    => 'expires',
            -VALIDATE => \&validExpires,
            -default  => $m_hrSettings->{cgi}{expires},
        },
        {   -LABEL    => 'size',
            -VALIDATE => \&validSize,
            -default  => $m_hrSettings->{size},
        },
        {   -LABEL    => 'mod_rewrite',
            -VALIDATE => \&validRewrite,
            -default  => $m_hrSettings->{cgi}{mod_rewrite},
        },
        {   -LABEL    => 'htmlright',
            -VALIDATE => \&validhtmlright,
            -default  => $m_hrSettings->{htmlright},
        },
        {   -LABEL   => 'Error Log',
            -default => $m_hrSettings->{cgi}{error_log},
        },
        {   -LABEL   => 'Server Name',
            -default => $m_hrSettings->{cgi}{serverName},
        },
        {   -LABEL    => 'Database',
            -HEADLINE => 1,
            -COLSPAN  => 2,
            -END_ROW  => 1,
        },
        {   -LABEL   => 'Databasehost',
            -default => $m_hrSettings->{database}{host},
        },
        {   -LABEL   => 'Databaseuser',
            -default => $m_hrSettings->{database}{user},
        },
        {   -LABEL   => 'Databasepassword',
            -TYPE    => 'password_field',
            -default => $m_hrSettings->{database}{password},
        },
        {   -LABEL   => 'Databasename',
            -default => $m_hrSettings->{database}{name},
        },
        {   -LABEL    => 'admin',
            -HEADLINE => 1,
            -COLSPAN  => 2,
            -END_ROW  => 1,
        },
        {   -LABEL   => 'Email',
            -default => $m_hrSettings->{admin}{email},
        },
        {   -LABEL   => 'Name',
            -default => $m_hrSettings->{admin}{name},
        },
        {   -LABEL   => 'First Name',
            -default => $m_hrSettings->{admin}{firstname},
        },
        {   -LABEL   => 'Street',
            -default => $m_hrSettings->{admin}{street},
        },
        {   -LABEL   => 'House Number',
            -default => $m_hrSettings->{admin}{number},
        },
        {   -LABEL   => 'postcode',
            -default => $m_hrSettings->{admin}{postcode},
        },
        {   -LABEL   => 'Town',
            -default => $m_hrSettings->{admin}{town},
        },
        {   -LABEL   => 'country',
            -default => $m_hrSettings->{admin}{country},
        },
        {   -LABEL   => 'phonenumber',
            -default => $m_hrSettings->{admin}{tel},
        },
        {   -LABEL   => 'signature',
            -default => $m_hrSettings->{admin}{signature},
        },
        {   -LABEL   => 'jabber',
            -default => $m_hrSettings->{admin}{jabber},
        },
        {   -LABEL   => 'icq',
            -default => $m_hrSettings->{admin}{icq},
        },
        {   -LABEL   => 'msn',
            -default => $m_hrSettings->{admin}{msn},
        },
        {   -LABEL   => 'jahoo',
            -default => $m_hrSettings->{admin}{jahoo},
        },
        {   -LABEL   => 'skype',
            -default => $m_hrSettings->{admin}{skype},
        },
        {   -LABEL   => 'aim',
            -default => $m_hrSettings->{admin}{aim},
        },

        {   -LABEL    => 'News',
            -HEADLINE => 1,
            -COLSPAN  => 2,
            -END_ROW  => 1,
        },
        {   -LABEL   => 'maxlength',
            -default => $m_hrSettings->{news}{maxlength},
        },
        {   -LABEL    => 'Uploads',
            -HEADLINE => 1,
            -COLSPAN  => 2,
            -END_ROW  => 1,
        },
        {   -LABEL    => 'activates',
            -TYPE     => 'scrolling_list',
            '-values' => [
                  ( $m_hrSettings->{uploads}{enabled} )
                ? ( 'Enabled', 'Disabled' )
                : ( 'Disabled', 'Enabled' )
            ],
            -size      => 1,
            -multiples => 0,
            -VALIDATE  => \&enabledDisabled,
        },
        {   -LABEL   => 'Max Upload size',
            -default => $m_hrSettings->{uploads}{maxlength},
        },
        {   -LABEL   => 'Upload Chmod',
            -default => $m_hrSettings->{uploads}{'chmod'},
        },
        {   -LABEL   => 'time between Posts',
            -default => $m_hrSettings->{floodtime},
        },

    ],
    -BUTTONS => [ { -name => translate('save') }, ],
    -FOOTER  => '</div>',
);
sleep 2;
my $htm = GetHtml();
if( defined $htm ) {
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => translate('m_hrSettings'),
        server => $m_hrSettings->{serverName},
        id     => 'quickpl',
        class  => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= $window->windowHeader();
    $m_sContent .= qq|<div align="left">$htm</div></div>|;
    $m_sContent .= $window->windowFooter();
}

sub on_valid_form {
    my $p1 = param('Style');
    $m_hrSettings->{cgi}{style} = $p1;
    my $p2 = param('Homepage Title');
    $m_hrSettings->{cgi}{title} = $p2;
    my $p3 = param('DocumentRoot');
    $m_hrSettings->{cgi}{DocumentRoot} = $p3;
    my $p4 = param('cgi-bin');
    $m_hrSettings->{cgi}{bin} = $p4;
    my $expires = param('expires');
    $m_hrSettings->{cgi}{expires} = $expires;
    my $s = param('size');
    $m_hrSettings->{size} = $s;
    my $p5 = param('Email');
    $m_hrSettings->{admin}{email}     = $p5;
    $m_hrSettings->{admin}{name}      = param('Name');
    $m_hrSettings->{admin}{firstname} = param('First Name');
    $m_hrSettings->{admin}{street}    = param('Street');
    $m_hrSettings->{admin}{tonwn}     = param('Town');
    $m_hrSettings->{admin}{number}    = param('House Number');
    $m_hrSettings->{admin}{tel}       = param('phonenumber');
    $m_hrSettings->{admin}{jabber}    = param('jabber');
    $m_hrSettings->{admin}{icq}       = param('icq');
    $m_hrSettings->{admin}{msn}       = param('msn');
    $m_hrSettings->{admin}{country}   = param('country');
    $m_hrSettings->{admin}{skype}     = param('skype');
    $m_hrSettings->{admin}{aim}       = param('aim');
    $m_hrSettings->{admin}{postcode}  = param('postcode');
    $m_hrSettings->{admin}{signature} = param('signature');
    $m_hrSettings->{admin}{jahoo}     = param('jahoo');
    my $p6 = param('CookiePath');
    $m_hrSettings->{cgi}{cookiePath} = $p6;
    my $p7 = param('mod_rewrite');
    $m_hrSettings->{cgi}{mod_rewrite} = $p7;
    my $p8 = param('Server Name');
    $m_hrSettings->{cgi}{serverName} = $p8;
    my $p10 = param('Databasehost');
    $m_hrSettings->{database}{host} = $p10;
    my $p11 = param('Databaseuser');
    $m_hrSettings->{database}{user} = $p11;
    my $p12 = param('Databasepassword');
    $m_hrSettings->{database}{password} = $p12;
    my $p13 = param('Databasename');
    $m_hrSettings->{database}{name} = $p13;
    my $p14 = param('sidebarLeft');
    $m_hrSettings->{sidebar}{left} = ( $p14 eq 'Enabled' ) ? 1 : 0;
    my $p15 = param('sidebarRight');
    $m_hrSettings->{sidebar}{right} = ( $p15 eq 'Enabled' ) ? 1 : 0;
    my $htmlright = param('htmlright');
    $m_hrSettings->{htmlright} = $htmlright;
    my $floodtime = param('time between Posts');
    $m_hrSettings->{floodtime} = $floodtime;

    #general
    my $p16 = param('language');
    $m_hrSettings->{language} = $p16;
    my $p17 = param('defaultAction');
    $m_hrSettings->{defaultAction} = $p17;
    $m_hrSettings->{news}{maxlength} = param('maxlength');

    #boxes
    for( my $i = 0; $i <= $#a; $i++ ) {
        $m_oDatabase->void( "update box set `position`= '"
                . param( $a[$i]->{name} )
                . "'  where name= '"
                . $a[$i]->{name}
                . "'" );
    }
    CGI::CMS::Settings::saveSettings(
        "$m_hrSettings->{cgi}{bin}/config/settings.pl");
    $m_sStyle = $p1;
    my $htm = GetHtml();
    my $rs
        = ( $m_hrSettings->{cgi}{mod_rewrite} )
        ? '/settings.html'
        : "$ENV{SCRIPT_NAME}?action=settings";
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => translate('translate'),
        server => $m_hrSettings->{serverName},
        id     => 'translate',
        class  => 'max',
    );
    my $window = new HTML::Window( \%parameter );

    $m_sContent
        .= '<div align="center"><b>Done</b><br/>'
        . qq(<a href="$rs">)
        . translate('next') . '</a>';
    my @entrys = param();
    $m_sContent .= $window->windowHeader();
    for( my $i = 0; $i <= $#entrys; $i++ ) {
        $m_sContent .= "$entrys[$i]: " . param( $entrys[$i] ) . '<br/>';
    }
    $m_sContent .= $window->windowFooter();
    $m_sContent .= qq(<a href="$rs">) . translate('next') . '</a></div>';

}

sub validRewrite { return ( ( $_[0]== 0 ) or ( $_[0]== 1 ) ) ? 1 : 0; }
sub validStyle { return -e "$m_hrSettings->{cgi}{DocumentRoot}/style/$_[0]"; }
sub exits      { return -e $_[0]; }
sub enabledDisabled { $_[0] =~ /^(Enabled|Disabled)$/; }
sub acceptLanguage     { $_[0] =~ /^\w\w-?\w?\w?$/; }
sub validDefaultAction { $_[0] =~ /^\w+$/; }
sub validBox           { $_[0] =~ /^(left|right|disabled)$/; }

sub validExpires {
    $_[0] =~ /^(\+\d\d?m|\+\d\d?y|\+\d\d?d|\+\d\d?h|\+\d\d?s)$/;
}
sub validSize      { $_[0] =~ /^(16|22|32|48|64|128)$/; }
sub validhtmlright { $_[0] =~ /^\d+$/; }
1;
