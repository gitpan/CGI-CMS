# use CGI::QuickFormR;
# use CGI::CMS::Translate;
#todo createVars benutzen.
use vars qw($lang)
loadTranslate( $m_hrSettings->{translate} );
*lng = \$CGI::CMS::Translate::lang;
my $TITLE = translate('Edit Translation');
my @translate;
my $lg = param('lang') ? param('lang') : 'de';
foreach my $key ( sort keys %{ $m_hrLng->{$lg} } ) {
    push @translate,
        {
        -LABEL  => $key,
        -TYPE   => '',
        -values => $m_hrLng->{$lg}{$key},
        }
        unless $key eq 'action';
}
my @l;
$m_sContent .= '<div align="center" style="width:100%;">';
foreach my $key ( sort keys %{$m_hrLng} ) {
    push @l, $key;
    $m_sContent
        .= a( { href => "$ENV{SCRIPT_NAME}?action=translate&lang=$key" },
        $key )
        . '&#160;|&#160;';
}
$m_sContent .= a( { href => "$ENV{SCRIPT_NAME}?action=showaddTranslation" },
    translate('addTranslation') )
    . '&#160;';

show_form(
    -HEADER   => qq(<br/><h2>$TITLE</h2>),
    -ACCEPT   => \&on_valid_form,
    -CHECK    => ( param('checkFormsddfsds') ? 1 : 0 ),
    -LANGUAGE => $ACCEPT_LANGUAGE,
    -FIELDS   => [
        {   -LABEL   => 'action',
            -default => 'translate',
            -TYPE    => 'hidden',
        },
        {   -LABEL   => 'checkFormsddfsds',
            -default => 'true',
            -TYPE    => 'hidden',
        },
        {   -LABEL   => 'lang',
            -default => $lg,
            -TYPE    => 'hidden',
        },
        @translate,
    ],
    -BUTTONS => [ { -name => translate('save') }, ],
    -FOOTER  => '<br/>',
);
my $htm = GetHtml();
if( defined $htm ) {
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => translate('translate'),
        server => $m_hrSettings->{serverName},
        id     => 'translate',
        class  => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= $window->windowHeader();
    $m_sContent .= qq|<div align="left">$htm</div></div>|;
    $m_sContent .= $window->windowFooter();
}

sub on_valid_form {

    my $rs
        = ( $m_hrSettings->{cgi}{mod_rewrite} )
        ? '/translate.html'
        : "$ENV{SCRIPT_NAME}?action=translate";
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => translate('savetranslate'),
        server => $m_hrSettings->{serverName},
        id     => 'savetranslate',
        class  => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= $window->windowHeader();
    $m_sContent
        .= '<br/><div align="center" style="width:75%;"><b>'
        . translate('Done')
        . qq(&#160;<a href="$rs">)
        . translate('next')
        . '</a></b><br/><div align="left">';
    my @entrys = param();
    for( my $i = 0; $i <= $#entrys; $i++ ) {
        my $rkey = lc $entrys[$i];
        delete $m_hrLng->{$lg}{ $entrys[$i] };
        $m_sContent .= "$rkey: " . param( $entrys[$i] ) . '<br/>'
            unless ( ( $rkey eq 'action' )
            or ( $rkey eq 'checkFormsddfsds' ) );
        $m_hrLng->{$lg}{$rkey} = param( $entrys[$i] )
            unless ( $rkey eq 'action' or ( $rkey eq 'checkFormsddfsds' ) );
    }
    saveTranslate( $m_hrSettings->{translate} );
    $m_sContent .= '</div></div>';
    $m_sContent .= $window->windowFooter();
}

1;
