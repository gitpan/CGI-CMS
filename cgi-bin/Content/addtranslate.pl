# use CGI::QuickForm;
# CGI::CMS::Settings::loadSettings("$settings->{cgi}{bin}/config/settings.pl");

my $TITLE = 'Edit Translation';
use CGI::CMS::Translate;
loadTranslate($settings->{translate});
*lng = \$CGI::CMS::Translate::lang;
my @l;
foreach my $key (sort keys %{$lng}) {
        push @l, $key;
}
print start_form(-method => "POST", -action => "$ENV{SCRIPT_NAME}",), hidden({-name => 'action'}, 'showaddTranslation'), hidden({-name => 'do', -default => '1'}, 'true'),
  table(
        {-align => 'center', -border => 0, width => "70%"},
        caption('Add translation'),
        Tr({-align => 'left', -valign => 'top'}, td("Key"), td(textfield({-style => "width:100%", -name => 'key'}, 'name'))),
        Tr({-align => 'left', -valign => 'top'}, td("Txt"), td(textfield({-style => "width:100%", -name => 'txt'}, 'txt'))),
        Tr({-align => 'left',  -valign => 'top'}, td("Language "), td(popup_menu(-onchange => "setLang(this.options[this.options.selectedIndex].value)", -name => 'lang', -values => [@l], -style => "width:100%"),)),
        Tr({-align => 'right', -valign => 'top'}, td({colspan      => 2},                  submit(-value                                                 => 'Add Translation')))
  ),
  end_form;
if(param('do')) {
        my $key = param('key');
        my $txt = param('txt');
        my $lgn = param('lang');
        unless (defined $lng->{$lgn}{$key}) {
                $lng->{$lgn}{$key} = $txt;
                print "Translation added $lgn<br/>$key:  $lng->{$lgn}{$key}<br/>";
                saveTranslate("$settings->{cgi}{bin}/config/translate.pl");
                loadTranslate("$settings->{cgi}{bin}/config/translate.pl");
        } else {
                print "Key already defined<br/>$key:  $lng->{$lgn}{$key}<br/>";
        }

}

1;
