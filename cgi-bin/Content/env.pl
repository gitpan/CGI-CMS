$m_sContent .= '<h1>Envoirement Variables</h1>';
$m_sContent
    .= '<table align ="center" border ="0" cellpadding ="2" cellspacing="2" summary="env">';
foreach my $key ( keys %ENV ) {
    $m_sContent
        .= qq(<tr><td class="env" valign="top" width="100"><strong>$key</strong></td><td class="envValue" valign="top" width ="400">)
        . join( "<br/>", split( /,/, $ENV{$key} ) )
        . '</td></tr>';
}
$m_sContent .= '</table>';
