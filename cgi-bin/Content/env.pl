print '<h1>Envoirement Variables</h1>';
print '<table align ="center" border ="0" cellpadding ="2" cellspacing="2" summary="env">';
foreach my $key (keys %ENV) {
    print qq(<tr><td class="env" valign="top" width="100"><strong>$key</strong></td><td class="envValue" valign="top" width ="400">) . join("<br/>", split(/,/, $ENV{$key})) . '</td></tr>';
}
print '</table>';
