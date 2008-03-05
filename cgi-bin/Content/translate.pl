# my $ACCEPT_LANGUAGE = 'de';

use CGI::QuickForm;
CGI::CMS::Settings::loadSettings("$settings->{cgi}{bin}/config/settings.pl");

my $TITLE = 'Edit Translation';
use CGI::CMS::Translate;
loadTranslate($settings->{translate});
*lng = \$CGI::CMS::Translate::lang;
my @translate;
my $lg = param('lang') ? param('lang') : "de";

foreach my $key (keys %{$lng->{$lg}}) {
        push @translate, {-LABEL => $key, -TYPE => '', '-values' => $lng->{$lg}{$key},};
}
my @l;
foreach my $key (keys %{$lng}) {
        push @l, $key;
        print a({href => "$ENV{SCRIPT_NAME}?action=translate&lang=$key"}, "$key"), "&#160;";
}

show_form(
          -HEADER   => qq(<br/><h2>Edit Translations</h2>),
          -ACCEPT   => \&on_valid_form,
          -CHECK    => (param('checkForm') ? 1 : 0),
          -LANGUAGE => $ACCEPT_LANGUAGE,
          -FIELDS   => [{-LABEL => 'action', -default => 'translate', -TYPE => 'hidden',}, {-LABEL => 'checkForm', -default => 'true', -TYPE => 'hidden',}, @translate,],
          -BUTTONS => [{-name => translate('save')},],
          -FOOTER  => '<br/>',
);

print start_form(-method => "GET", -action => "$ENV{SCRIPT_NAME}?action=addTranslation",), hidden('action', "addTranslation"),
  table(
        {-align => 'center', -border => 0, width => "70%"},
        caption('Add translation'),
        Tr({-align => 'left', -valign => 'top'}, td("Key"), td(textfield({-style => "width:100%", -name => 'key'}, 'name'))),
        Tr({-align => 'left', -valign => 'top'}, td("Txt"), td(textfield({-style => "width:100%", -name => 'txt'}, 'txt'))),
        Tr({-align => 'left',  -valign => 'top'}, td("Language "), td(popup_menu(-onchange => "setLang(this.options[this.options.selectedIndex].value)", -name => 'lang', -values => [@l], -style => "width:100%"),)),
        Tr({-align => 'right', -valign => 'top'}, td({colspan      => 2},                  submit(-value                                                 => 'Add Translation')))
  ),
  end_form;

sub on_valid_form {

        foreach my $key (keys %{$lng->{$lg}}) {
                $lng->{$lg}{$key} = param($key);
        }
        saveTranslate("$settings->{cgi}{bin}/config/translate.pl");
        print '<div align="center"><b>Done</b><br/>';
        my @entrys = param();
        for(my $i = 0 ; $i <= $#entrys ; $i++) {
                print "$entrys[$i]: ", param($entrys[$i]), '<br/>';
        }
        my $rs = ($settings->{cgi}{mod_rewrite}) ? '/translate.html' : "$ENV{SCRIPT_NAME}?action=translate";
        print qq(<a href="$rs">) . translate('next') . '</a></div>';

}

sub addTranslation {
        my $key = param('key');
        my $txt = param('txt');
        my $lg  = param('lang');
        unless (defined $lng->{$lg}{$key}) {
                $lng->{$lg}{$key} = $txt;
                print "Translation added $lg<br/>$key:  $lng->{$lg}{$key}<br/>";
                saveTranslate("$settings->{cgi}{bin}/config/translate.pl");

        } else {
                print "Key already defined<br/>$key:  $lng->{$lg}{$key}<br/>";
        }
}

1;
