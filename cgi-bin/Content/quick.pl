# my $ACCEPT_LANGUAGE = 'de';

# disable diagnostics;
use CGI::QuickForm;
CGI::CMS::Settings::loadSettings("$settings->{cgi}{bin}/config/settings.pl");

my $TITLE = 'Edit Configuration';
my @boxes;
my @a = $database->fetch_AoH('select * from box ');
my %options = ('left' => ['left', 'right', 'disabled'], 'right' => ['right', 'left', 'disabled'], 'disabled' => ['disabled', 'left', 'right'],);
foreach (my $i = 0 ; $i <= $#a ; $i++) {
        push @boxes, {-LABEL => $a[$i]->{name}, -TYPE => 'scrolling_list', '-values' => $options{$a[$i]->{position}}, -size => 1, -multiples => 0, -VALIDATE => \&validBox,};
}
show_form(
        -HEADER   => qq(<br/><div style="padding-left:50px;"><h2>$TITLE</h2>),
        -ACCEPT   => \&on_valid_form,
        -CHECK    => (param('checkForm') ? 1 : 0),
        -LANGUAGE => $ACCEPT_LANGUAGE,
        -FIELDS   => [
                {-LABEL => 'Boxen', -HEADLINE => 1, -COLSPAN => 2, -END_ROW => 1,},
                @boxes,
                {-LABEL => 'action',    -default  => 'settings', -TYPE    => 'hidden',},
                {-LABEL => 'checkForm', -default  => 'true',     -TYPE    => 'hidden',},
                {-LABEL => 'Default',   -HEADLINE => 1,          -COLSPAN => 2, -END_ROW => 1,},
                {-LABEL => 'sidebarLeft',  -TYPE => 'scrolling_list', '-values' => [($settings->{sidebar}{left})  ? ('Enabled', 'Disabled') : ('Disabled', 'Enabled')], -size => 1, -multiples => 0, -VALIDATE => \&enabledDisabled,},
                {-LABEL => 'sidebarRight', -TYPE => 'scrolling_list', '-values' => [($settings->{sidebar}{right}) ? ('Enabled', 'Disabled') : ('Disabled', 'Enabled')], -size => 1, -multiples => 0, -VALIDATE => \&enabledDisabled,},
                {-LABEL => 'language',      -default => $settings->{language},      -VALIDATE => \&acceptLanguage,},
                {-LABEL => 'defaultAction', -default => $settings->{defaultAction}, -VALIDATE => \&validDefaultAction,},
                {-LABEL => 'CGI',            -HEADLINE => 1, -COLSPAN => 2, -END_ROW => 1,},
                {-LABEL => 'Homepage Title', -default  => $settings->{cgi}{title},},
                {-LABEL => 'DocumentRoot', -VALIDATE => \&exits,          -default => $settings->{cgi}{DocumentRoot},},
                {-LABEL => 'cgi-bin',      -VALIDATE => \&exits,          -default => $settings->{cgi}{bin},},
                {-LABEL => 'Style',        -VALIDATE => \&validStyle,     -default => $settings->{cgi}{style},},
                {-LABEL => 'CookiePath',   -default  => $settings->{cgi}{cookiePath},},
                {-LABEL => 'expires',      -VALIDATE => \&validExpires,   -default => $settings->{cgi}{expires},},
                {-LABEL => 'size',         -VALIDATE => \&validSize,      -default => $settings->{size},},
                {-LABEL => 'mod_rewrite',  -VALIDATE => \&validRewrite,   -default => $settings->{cgi}{mod_rewrite},},
                {-LABEL => 'htmlright',    -VALIDATE => \&validhtmlright, -default => $settings->{htmlright},},
                {-LABEL => 'Error Log',    -default  => $settings->{cgi}{error_log},},
                {-LABEL => 'Server Name',  -default  => $settings->{cgi}{serverName},},
                {-LABEL => 'Database',     -HEADLINE => 1, -COLSPAN => 2, -END_ROW => 1,},
                {-LABEL => 'Databasehost', -default  => $settings->{database}{host},},
                {-LABEL => 'Databaseuser', -default  => $settings->{database}{user},},
                {-LABEL => 'Databasepassword', -TYPE    => 'password_field', -default => $settings->{database}{password},},
                {-LABEL => 'Databasename',     -default => $settings->{database}{name},},
                {-LABEL => 'admin',      -HEADLINE => 1, -COLSPAN => 2, -END_ROW => 1,},
                {-LABEL => 'Email',      -default  => $settings->{admin}{email},},
                {-LABEL => 'Name',       -default  => $settings->{admin}{name},},
                {-LABEL => 'First Name', -default  => $settings->{admin}{firstname},},
                {-LABEL => 'Street',     -default  => $settings->{admin}{street},},
                {-LABEL => 'Town',       -default  => $settings->{admin}{town},},
                {-LABEL => 'News',       -HEADLINE => 1, -COLSPAN => 2, -END_ROW => 1,},
                {-LABEL => 'maxlength',  -default  => $settings->{news}{maxlength},},
                {-LABEL => 'Uploads',    -HEADLINE => 1, -COLSPAN => 2, -END_ROW => 1,},
                {-LABEL => 'activates', -TYPE => 'scrolling_list', '-values' => [($settings->{uploads}{enabled}) ? ('Enabled', 'Disabled') : ('Disabled', 'Enabled')], -size => 1, -multiples => 0, -VALIDATE => \&enabledDisabled,},
                {-LABEL => 'Max Upload size',    -default => $settings->{uploads}{maxlength},},
                {-LABEL => 'Upload Chmod',       -default => $settings->{uploads}{'chmod'},},
                {-LABEL => 'time between Posts', -default => $settings->{floodtime},},

        ],
        -BUTTONS => [{-name => translate('save')},],
        -FOOTER  => '</div><br/>',
);

sub on_valid_form {
        my $p1 = param('Style');
        $settings->{cgi}{style} = $p1;
        my $p2 = param('Homepage Title');
        $settings->{cgi}{title} = $p2;
        my $p3 = param('DocumentRoot');
        $settings->{cgi}{DocumentRoot} = $p3;
        my $p4 = param('cgi-bin');
        $settings->{cgi}{bin} = $p4;
        my $expires = param('expires');
        $settings->{cgi}{expires} = $expires;
        my $s = param('size');
        $settings->{size} = $s;
        my $p5 = param('Email');
        $settings->{admin}{email}     = $p5;
        $settings->{admin}{name}      = param('Name');
        $settings->{admin}{firstname} = param('First Name');
        $settings->{admin}{street}    = param('Street');
        $settings->{admin}{tonwn}     = param('Town');
        my $p6 = param('CookiePath');
        $settings->{cgi}{cookiePath} = $p6;
        my $p7 = param('mod_rewrite');
        $settings->{cgi}{mod_rewrite} = $p7;
        my $p8 = param('Server Name');
        $settings->{cgi}{serverName} = $p8;
        my $p10 = param('Databasehost');
        $settings->{database}{host} = $p10;
        my $p11 = param('Databaseuser');
        $settings->{database}{user} = $p11;
        my $p12 = param('Databasepassword');
        $settings->{database}{password} = $p12;
        my $p13 = param('Databasename');
        $settings->{database}{name} = $p13;
        my $p14 = param('sidebarLeft');
        $settings->{sidebar}{left} = ($p14 eq 'Enabled') ? 1 : 0;
        my $p15 = param('sidebarRight');
        $settings->{sidebar}{right} = ($p15 eq 'Enabled') ? 1 : 0;
        my $htmlright = param('htmlright');
        $settings->{htmlright} = $htmlright;
        my $floodtime = param('time between Posts');
        $settings->{floodtime} = $floodtime;

        #general
        my $p16 = param('language');
        $settings->{language} = $p16;
        my $p17 = param('defaultAction');
        $settings->{defaultAction} = $p17;
        $settings->{news}{maxlength} = param('maxlength');

        #boxes
        for(my $i = 0 ; $i <= $#a ; $i++) {$database->void("update box set `position`= '" . param($a[$i]->{name}) . "'  where name= '" . $a[$i]->{name} . "'");}
        CGI::CMS::Settings::saveSettings("$settings->{cgi}{bin}/config/settings.pl");
        $style = $p1;
        print '<div align="center"><b>Done</b><br/>';
        my @entrys = param();
        for(my $i = 0 ; $i <= $#entrys ; $i++) {
                print "$entrys[$i]: ", param($entrys[$i]), '<br/>';
        }
        my $rs = ($settings->{cgi}{mod_rewrite}) ? '/settings.html' : "$ENV{SCRIPT_NAME}?action=settings";
        print qq(<a href="$rs">) . translate('next') . '</a></div>';

}

sub validRewrite {return (($_[0]== 0) or ($_[0]== 1)) ? 1 : 0;}
sub validStyle         {return -e "$settings->{cgi}{DocumentRoot}/style/$_[0]";}
sub exits              {return -e $_[0];}
sub enabledDisabled    {$_[0] =~ /^(Enabled|Disabled)$/;}
sub acceptLanguage     {$_[0] =~ /^\w\w-?\w?\w?$/;}
sub validDefaultAction {$_[0] =~ /^\w+$/;}
sub validBox           {$_[0] =~ /^(left|right|disabled)$/;}
sub validExpires       {$_[0] =~ /^(\+\d\d?m|\+\d\d?y|\+\d\d?d|\+\d\d?h|\+\d\d?s)$/;}
sub validSize          {$_[0] =~ /^(16|22|32|48|64|128)$/;}
sub validhtmlright     {$_[0] =~ /^\d+$/;}
1;
