
my %parameter = (
    path   => $settings->{cgi}{bin} . '/templates',
    style  => $style,
    title  => 'Impressum',
    server => $settings->{serverName},
    id     => 'umpres',
    class  => 'min',
);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(0);
$window->set_moveable(0);
$window->set_resizeable(0);
$window->set_collapse(0);

print br(), $window->windowHeader();
print qq(
<script type="text/javascript" language="JavaScript">
<!--
function showAbout(){
       document.getElementById("disclaimer").style.display ="none";
       document.getElementById("about").style.display ="";
       document.getElementById("site").style.display ="none";
}
function showDisclaimer(){
       document.getElementById("about").style.display ="none";
       document.getElementById("site").style.display ="none";
       document.getElementById("disclaimer").style.display ="";
}
function showquelle() {
       document.getElementById("disclaimer").style.display ="none";
       document.getElementById("about").style.display ="none";
       document.getElementById("site").style.display ="";

}

-->
</script>
<table align="center" class="layout" border="0" cellpadding="5" cellspacing="5" summary="layout" width="100%">
       <tr>
              <td class="back" id="tdBody" valign="top">
              <div  align="justify" id="disclaimer">
<h2>1. Inhalt des Onlineangebotes</h2><br /> Der Autor &#252;bernimmt keinerlei Gew&#228;hr f&#252;r die Aktualit&#228;t, Korrektheit, Vollst&#228;ndigkeit oder Qualit&#228;t der bereitgestellten Informationen.  Haftungsanspr&#252;che gegen den Autor,welche sich auf Sch&#228;den materieller oder ideeller Art beziehen,  die durch die Nutzung oder Nichtnutzung der dargebotenen Informationen bzw.  durch die Nutzung fehlerhafter und unvollst&#228;ndiger Informationen verursacht wurden, sind grunds&#228;tzlich ausgeschlossen, sofern seitens des Autors kein nachweislich vors&#228;tzliches oder grob fahrl&#228;ssiges Verschulden vorliegt. Alle Angebote sind freibleibend und unverbindlich. Der Autor beh&#228;lt es sich ausdr&#252;cklich vor,  Teile der Seiten oder das gesamte Angebot ohne gesonderte Ank&#252;ndigung zu ver&#228;ndern,
  zu erg&#228;nzen, zu l&#246;schen oder die Ver&#246;ffentlichung zeitweise oder endg&#252;ltig einzustellen.<br/>
<h2>2.Verweise und Links </h2><br/>
 Bei direkten oder indirekten Verweisen auf fremde Webseiten ("Hyperlinks"), die au&#223;erhalb des Verantwortungsbereiches des Autors liegen, w&#252;rde eine Haftungsverpflichtung ausschlie&#223;lich in dem Fall in Kraft treten, in dem der Autor vonden Inhalten Kenntnis hat und es ihm technisch m&#246;glich und zumutbar w&#228;re, die Nutzung im Falle rechtswidriger Inhalte zu verhindern. Der Autor erkl&#228;rt hiermit ausdr&#252;cklich, dass zum Zeitpunkt der Linksetzung keine illegalen  Inhalte auf den zu verlinkenden Seiten erkennbar waren. Auf die aktuelle und zuk&#252;nftige Gestaltung,
 die Inhalte oder die Urheberschaft der gelinkten/verkn&#252;pften Seiten hat der Autor keinerlei Einfluss.
 Deshalb distanziert er sich hiermit ausdr&#252;cklich von allen Inhalten aller gelinkten /verkn&#252;pften Seiten,
 die nach der Linksetzung ver&#228;ndert wurden. Diese Feststellung gilt f&#252;r alle innerhalb des eigenen Internetangebotes gesetzten Links und Verweise sowie f&#252;r Fremdeintr&#228;ge in vom Autor eingerichteten G&#228;steb&#252;chern,
 Diskussionsforen und Mailinglisten. F&#252;r illegale, fehlerhafte oder unvollst&#228;ndige Inhalte und insbesondere f&#252;r Sch&#228;den, die aus der Nutzung oder Nichtnutzung solcherart dargebotener Informationen entstehen,
 haftet allein der Anbieter der Seite, auf welche verwiesen wurde, nicht derjenige, der &#252;ber Links auf die jeweilige Ver&#246;ffentlichung lediglich verweist. <br/>
<h2>3.Urheber- und Kennzeichenrecht</h2><br/>
 Der Autor ist bestrebt, in allen Publikationen die Urheberrechte der verwendeten Grafiken, Tondokumente, Videosequenzen und Texte zu beachten, von ihm selbst erstellte Grafiken, Tondokumente, Videosequenzen und Texte zu nutzen oder auf lizenzfreie Grafiken, Tondokumente, Videosequenzen und Texte zur&#252;ckzugreifen. 
 Alle innerhalb des Internetangebotes genannten und ggf. durch Dritte gesch&#252;tzten Marken- und Warenzeichen unterliegen uneingeschr&#228;nkt den Bestimmungen des jeweils g&#252;ltigen Kennzeichenrechts und den Besitzrechten der jeweiligen eingetragenen Eigent&#252;mer. Allein aufgrund der blo&#223;en Nennung ist nicht der Schluss zu ziehen, dass Markenzeichen nicht durch Rechte Dritter gesch&#252;tzt sind! Das Copyright f&#252;r ver&#246;ffentlichte,vom Autor selbst erstellte Objekte bleibt allein beim Autor der Seiten. Eine Vervielf&#228;ltigung oder Verwendung solcher Grafiken, Tondokumente, Videosequenzen und Texte in anderen elektronischen oder gedruckten Publikationen ist ohne ausdr&#252;ckliche Zustimmung des Autors nicht gestattet. 
<br/>
<h2>Distanzierung I</h2><br/>
 Der Verfasser dieser Seite tr&#228;gt keine Verantwortung f&#252;r die Art, in der dir hier zur Verf&#252;gung gestellten Informationen genutzt werden. Dateien und alles andere auf dieser Seite sind nur f&#252;r den privaten Gebrauch bestimmt und sollten darum nicht runtergeladen oder gelesen werden. 
 Wenn Sie irgendwie in Verbindung mit der Regierung, Anti-Pirate Gruppen, der MPAA, CCA, Premiere,
 Mediavision oder anderen &#228;hnlichen Gruppen stehen, ist der Zugang zu den Dateien und das lesen der HTML Seiten verboten.
 Alle Objekte dieser Seite sind privater Eigentum und somit nicht zum lesen bestimmt. Es ist also verboten diese Seite zu betreten. wenn Sie diese Seite dennoch betreten , versto&#223;en Sie gegen den "Code 431.322.12 of the Internet Privacy Act",
 der 1995 von Bill Clinton verabschiedet wurde. Das hei&#223;t sie k&#246;nnen gegen die Personen, welche diese Dateien verwalten, nicht vorgehen. Wenn Sie dieser Vereinbarung nicht Zustimmen, sind Sie gezwungen diese Seiten wieder zu Verlassen. 
<br/>
<h2>Distanzierung II</h2><br/>  Mit Urteil vom 12. Mai 1998 hat das Landgericht Hamburg entschieden, dass man durch die Ausbringung eines Links die Inhalte der gelinkten Seite ggf. mit zu verantworten hat. Dies kann - so das Landgericht - nur dadurch verhindert werden, dass man sich ausdr&#252;cklich von diesen Inhalten distanziert. Ich habe auf meiner Homepage Links zu anderen Seiten im Internet gelegt. F&#252;r all diese Links gilt: Ich m&#246;chte ausdr&#252;cklich betonen, dass ich keinerlei Einfluss auf die Gestaltung und die Inhalte der gelinkten Seiten habe. 
 Deshalb distanziere ich mich hiermit ausdr&#252;cklich von allen Inhalten aller gelinkten Seiten auf meiner Homepage.
 Diese Erkl&#228;rung gilt f&#252;r alle auf meiner Homepage ausgebrachten Links. <br /></div>
<div id="about"  align="justify" style="display:none;height:400px;" ><br/><br/>
<table align="center" border="0" cellpadding="0" cellspacing="0"  summary="layout" width="100%">
       <tr>
              <td align="center">
              <img alt="$settings->{admin}{name}" src="/images/admin.jpg" />
              </td>
       </tr>
       <tr>
              <td height="1000" valign="top" width="450">
                     <table align="center" border="0" cellpadding="0" cellspacing="0" summary="layout" width="100%">
                     <tr>
                            <td>
                            Name:
                            </td>
                            <td>
                            $settings->{admin}{name}
                            </td>
                     </tr>
                     <tr>
                            <td>
                            Vorname:
                            </td>
                            <td>
                           $settings->{admin}{firstname}
                            </td>
                     </tr>
                     <tr>
                            <td>
                            Stra&#223;e:
                            </td>
                            <td>
                            $settings->{admin}{street}
                            </td>
                     </tr>
                     <tr>
                            <td>
                            PLZ/Ort:
                            </td>
                            <td>
                            $settings->{admin}{town}
                            </td>
                     </tr>
                     <tr>
                            <td>
                            <img alt="Email" src="/images/mail.png"/>
                            </td>
                            <td>
                            <a  href="mailto://$settings->{admin}{email}" target="_blank">$settings->{admin}{email}</a>
                            </td>
                     </tr>
                     </table>
              </td>
       </tr>
</table>
</div>
<div  id="site"  align="justify" style="display:none;" >
<h2>Quellen</h2>
1: Scripts.<br/>
Siehe <a href="http://www.lindnerei.de">Lindnerei</a>
Cpan Module:<br/>
<ul>
<li>CGI</li>
<li>DBI</li>
<li>LWP::UserAgent</li>
<li>XML:Twig</li>
<li>MD5</li>
<li>XML::RSS</li>
<li>HTML::Parser</li>
<li>CGI::QuickForm</li>
<li>HTML::Menu::TreeView</li>
<li>Syntax::Highlight::Perl</li>
<li>Test::More</li>
<li>Test::Signature</li>
<li>Module::Build</li>
<li>CGI::CMS</li>
</ul>
<br/>
Benutzte Software:<br/>
Perlscripts: Kate &amp; Vi.<br/>
Html: Quanta.<br/>
Bilder: Gimp.<br/>
Hosting:<br/>
Domainin- Serverinhaber: Dirk Lindner \@Strato
</div>
<br/>
</td>
</tr>
</table>
);
print $window->windowFooter(), br();

