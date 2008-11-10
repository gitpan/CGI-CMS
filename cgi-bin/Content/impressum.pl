no warnings "uninitialized";
my %parameter = (
    path   => $m_hrSettings->{cgi}{bin} . '/templates',
    style  => $m_sStyle,
    title  => "",
    server => $m_hrSettings->{serverName},
    id     => 'ExecSql',
    class  => 'min',
);
my $window = new HTML::Window( \%parameter );
$m_sContent .= br() . $window->windowHeader();
$m_sContent .= qq|
<script type="text/javascript" language="JavaScript">
<!--

var imgs = new Array();|;
my $dir = "$m_hrSettings->{cgi}{DocumentRoot}/gallery/";
my $i   = 0;
my $firstone;

if( -d $dir ) {
    opendir DIR, $dir or die "files.pl sub readFiles: $dir $!";

    foreach my $d ( readdir(DIR) ) {
        if( $d =~ /\.je?pg|\.png|\.gif$/ ) {
            $firstone = "/gallery/$d" if $i== 0;
            $m_sContent .= qq| imgs[$i] = '/gallery/$d';|;
            $i++;
        }
    }
}
$m_sContent .= qq|
var i = 0;
function prevImage(){
       i =  (i > 0) ? i-1 : imgs.length-1 ;
       document.getElementById("b").src = imgs[i];
}
function nextImage(){
       i = ( i < imgs.length-1 )? i+1: 0;
       document.getElementById("b").src = imgs[i];
}
function nextprev(){
       document.write('<img src="/style/'+style+'/prev.png" onclick="prevImage()"/><img src="/style/'+style+'/next.png" onclick="nextImage()"/>');
}
-->
</script>
<div id="about"  align="center">|;
$m_sContent .= table(
    {   -align  => 'center',
        -border => 0
    },
    Tr( td( {   align => 'left',
                class => "image"
            },
            table(
                {   -border => 0,
                    -width  => '400'
                },
                Tr( td( {   -height => '325',
                            -align  => 'center',
                            -valign => 'middle'
                        },
                        img({   -id    => 'b',
                                alt    => '',
                                -src   => "$firstone",
                                hspace => "5",
                                vspace => "5",
                                align  => "top",
                                border => 0
                            }
                        ),

                    )
                ),
                Tr( td( {   -height => '25',
                            -align  => 'center',
                            -valign => 'middle'
                        },
                        script(
                            { type => 'text/javascript', }, "nextprev()"
                        )
                    )
                )
            )
        ),
        td( table(
                {   -align  => 'center',
                    -border => 0
                },
                Tr( td( {   align => 'left',
                            class => "label"
                        },
                        'ICQ'
                    ),
                    td( {   align => 'right',
                            class => "value"
                        },
                        img({   -src =>
                                    "http://status.icq.com/online.gif?icq=$m_hrSettings->{admin}{icq}&img=5",
                                alt    => '',
                                align  => 'right',
                                border => 0
                            }
                        )
                    ),
                    td( {   align => 'left',
                            class => 'value'
                        },
                        $m_hrSettings->{admin}{icq}
                    ),
                ),
                Tr( td( {   align => 'left',
                            class => "label"
                        },
                        'Skype'
                    ),
                    td( {   align => 'right',
                            class => "value"
                        },
                        img({   -src =>
                                    "http://mystatus.skype.com/smallicon/$m_hrSettings->{admin}{skype}",
                                alt    => '',
                                align  => "right",
                                border => 0
                            }
                        )
                    ),
                    td( {   align => 'left',
                            class => "value"
                        },
                        $m_hrSettings->{admin}{skype}
                    ),
                ),
                Tr( td( {   align => 'left',
                            class => "label"
                        },
                        'Email'
                    ),
                    td(),
                    td( {   align => 'left',
                            class => "value"
                        },
                        $m_hrSettings->{admin}{email}
                    ),
                ),
                Tr( td( {   align => 'left',
                            class => "label"
                        },
                        'Aim'
                    ),
                    td(),
                    td( {   align => 'left',
                            class => "value"
                        },
                        $m_hrSettings->{admin}{aim}
                    ),
                ),
                Tr( td( {   align => 'left',
                            class => "label"
                        },
                        'MSN'
                    ),
                    td(),
                    td( {   align => 'left',
                            class => "value"
                        },
                        $m_hrSettings->{admin}{msn}
                    ),
                ),
                Tr( td( {   align => 'left',
                            class => "label"
                        },
                        'Jabber'
                    ),
                    td(),
                    td( {   align => 'left',
                            class => "value"
                        },
                        $m_hrSettings->{admin}{jabber}
                    ),
                ),
                Tr( td( {   align => 'left',
                            class => "label"
                        },
                        'Yahoo'
                    ),
                    td( img({   -src =>
                                    "http://opi.yahoo.com/online?u=$m_hrSettings->{admin}{jahoo}&amp;m=g&amp;t=5",
                                align  => "top",
                                alt    => '',
                                border => 0
                            }
                        )
                    ),
                    td( {   align => 'left',
                            class => "value"
                        },
                        a(  {   href =>
                                    "ymsgr:sendim?$m_hrSettings->{admin}{jahoo}"
                            },
                            $m_hrSettings->{admin}{jahoo}
                        )
                    ),
                ),
                Tr( td( {   align => 'left',
                            class => "label"
                        },
                        'Telefon'
                    ),
                    td(),
                    td( {   align => 'left',
                            class => "value"
                        },
                        $m_hrSettings->{admin}{tel}
                    ),
                ),
                Tr( td( {   align => 'left',
                            class => "label"
                        },
                        'Anschrift'
                    ),
                    td(),
                    td( {   align => 'left',
                            class => "value"
                        },
                        qq|<a target="_blank" href="http://maps.google.com/maps?q=$m_hrSettings->{admin}{street}+$m_hrSettings->{admin}{number},+$m_hrSettings->{admin}{postcode}+$m_hrSettings->{admin}{town},+$m_hrSettings->{admin}{number}&amp;um=1&amp;sa=X&amp;oi=geocode_result&amp;resnum=1&amp;ct=title">$m_hrSettings->{admin}{street}.$m_hrSettings->{admin}{number}</a><br/>$m_hrSettings->{admin}{postcode} $m_hrSettings->{admin}{town}|
                    ),
                ),
            )
        )
    )
);

my $TITLE = translate('Direkt Kontakt');

use CGI::QuickFormR;
$m_sContent
    .= '<div style="width:50%;" align="center"><div align="right"><div align="left">';
show_form(
    -HEADER   => $TITLE,
    -ACCEPT   => \&on_valid_form,
    -CHECK    => ( param('checkForm') ? 1 : 0 ),
    -LANGUAGE => $ACCEPT_LANGUAGE,
    -FIELDS   => [
        {   -LABEL   => 'action',
            -default => 'mailme',
            -TYPE    => 'hidden',
        },
        {   -LABEL   => 'checkForm',
            -default => 'true',
            -TYPE    => 'hidden',
        },
        {   -LABEL    => translate('Name'),
            -VALIDATE => \&validName,
            -default  => translate("Dein Name"),
        },
        {   -LABEL   => translate('email'),
            -default => translate("optionale Email adresse"),
        },
        {   -LABEL     => translate('Nachricht'),
            -VALIDATE  => \&validBody,
            -default   => 'true',
            -TYPE      => 'textarea',
            -name      => 'body',
            -default   => translate('Schreib mir was'),
            -maxlength => 32766,
        },
    ],
    -BUTTONS => [ { -name => translate('Nachricht senden') }, ],
    -FOOTER  => '<br/>',
);
my $htm = GetHtml();
if( defined $htm ) {
    $m_sContent .= $htm;
}
sub validName { $_[0] =~ /^\w{3,}$/; }
sub validBody { $_[0] =~ /^.{3,32766}$/; }

sub on_valid_form {
    use Mail::Sendmail;
    my %mail = (
        To      => $m_hrSettings->{admin}{email},
        From    => $m_hrSettings->{admin}{email},
        subject => translate('kontaktsubjects')
            . param( translate('Name') )
            . ( translate('hat Dir geschrieben') ),
        Message => param( translate('body') )
    );
    sendmail(%mail) or warn $Mail::Sendmail::error;
}
$m_sContent .= "</div></div></div>";

$m_sContent .= qq|
<pre>$m_hrSettings->{admin}{signature}<pre>
|;
$m_sContent .= $window->windowFooter();
