document.write('<form action="javascript:pressEnter()" name="searchWorld" onsubmit="return false;">');
document.write('<input align="top" type="text"  onkeydown="checkInput()" maxlength="100" size="16" style="vertical-align:top;width:140px;height:18px;" title="Bitte Suchbegriff eingeben" name="keyword" id="keyword" value=""/>');
document.write('<select  style="vertical-align:top;width:140px;height:22px;" onchange="setEngine(this.options[this.options.selectedIndex].value)" id="chooseSite" name="chooseSite">');
document.write('<option value="get:/fulltext.html&query=%KEYWORD%">Suchen</option>');
document.write('<option value="get:http://www.google.com/custom?q=%KEYWORD%&sa=Google+Search&domains=www.lindnerei.de&sitesearch=www.lindnerei.de">Google Lindnerei</option>');
document.write('<option value="get:http://search.cpan.org/search?query=%KEYWORD%&mode=all">Search Cpan</option>');
document.write('<option value="get:http://perldoc.perl.org/search.html?q=%KEYWORD%">Perldoc</option>');
document.write('<option value="get:http://www.mysql.com/search/?q=%KEYWORD%&=Search">Mysql.com</option>');
document.write('<option value="get:http://www.perlboard.de/cgi-bin/suche.pl?muster=%KEYWORD%&treffer_anzahl=1000000&max_tiefe=2&submit=suche+starten">Perlguide</option>');
document.write('<option value="get:http://board.perl-community.de/perl-bin/board.pl?words=%KEYWORD%&boards=all&searchfrom=all&action=search">perl-community</option>');
document.write('<option value="get:http://suche.de.selfhtml.org/cgi-bin/such.pl?suchausdruck=%KEYWORD%&case=on&feld=alle&index_1=on&hits=101">selfhtml</option>');
document.write('<option value="get:http://cpan.uwinnipeg.ca/search?query=%KEYWORD%&mode=module">Cpan&#160;Modules</option>');
document.write('<option value="get:http://cpan.uwinnipeg.ca/search?query=%KEYWORD%&mode=dist">Cpan&#160;Distributions</option>');
document.write('<option value="get:http://cpan.uwinnipeg.ca/search?query=%KEYWORD%&mode=author">Cpan&#160;Authors</option>');
document.write('<option value="get:http://cpan.uwinnipeg.ca/search?query=%KEYWORD%&mode=dist">Cpan&#160;Distributions</option>');
document.write('<option value="get:http://www.google.com/search?q=site:cppreference.com %KEYWORD%">CPP Reference</option>');
document.write('<option value="get:http://trolltech.com/search?SearchableText=%KEYWORD%">Qt Trolltech</option>');
document.write('<option value="get:http://www.heise.de/newsticker/search.shtml?T=%KEYWORD%&button=los%21">Heise.de</option>');
document.write('<option value="get:http://www.google.de/search?hl=de&ie=UTF-8&q=%KEYWORD%&btnG=Suche&meta=lr%3Dlang_de">Google</option>');
document.write('<option value="get:http://sourceforge.net/search/?type_of_search=soft&type_of_search=soft&words=%KEYWORD%">Sourceforge</option>');
document.write('<option value="get: http://www.google.com/custom?q=%KEYWORD%&sa=Google+Search&cof=LW%3A179%3BL%3Ahttp%3A%2F%2Fwww.debian.org%2FPics%2Fdebian.jpg%3BLH%3A61%3BAH%3Acenter%3BAWFID%3Ab092bd86f7b55508%3B&domains=www.debian.org&sitesearch=www.debian.org">Debian</option>');
document.write('<option value="get:http://www.google.com/translate_t?langpair=en|de&text=%KEYWORD%">Translate en|de</option>');
document.write('</select> ');
document.write('</form>');
var uA = navigator.userAgent;
var MSIE = uA.match(/MSIE/g);
if(!MSIE){
window.captureEvents(Event.KEYDOWN);
}
document.onkeydown = pressEnter;
var inputk = 0;
var s = 0;
var searchEngine = "get:/fulltext.html&query=%KEYWORD%";
function pressEnter(Event){
if(inputk == 1 ){
if(!MSIE){
if (Event.which == 13 ) {
searchIT();
}
}else{
if (window.event.keyCode == 13) {
searchIT();
}
}
}
}
function setEngine(engine){
searchEngine = engine;
searchIT();
}
function checkInput(){
var g = document.getElementById("keyword").value;
if(g.length < "3"){
inputk = 0;
}else{
inputk = 1;
}
}
function searchIT(){
value = searchEngine;
var i = 0;
var method = "get";
while (i < value.length){
if (value.substring(i, i+3) == "get"){
get(value.substring(i+4,value.length));
i = value.length;
}
if(value.substring(i, i+4) == "post"){
var j = i+5;
while(j < value.length){
if(value.substring(j, j+4) == "::::"){
var formi = value.substring(i+5,j);
var pid = value.substring(j+4,value.length);
post(formi,pid);
i = value.length;
j = value.length;
}
j++;
}
}
i++;
}
}
var q = param('query');
if(q)
     document.getElementById("keyword").value = param('query');
var info = "Suchbegriff ins Feld eingeben auf die gewuenschte Suchmaschine auswahlen.";
function get(Url){
Submit = "GET";
var gesucht = document.getElementById("keyword").value;
if(gesucht.length == "0"){
alert(info);
return;
}
Url = Url.replace("%KEYWORD%",gesucht);
if( searchEngine == "get:/fulltext.html&query=%KEYWORD%"){
        location.href = Url;
}else{
        window.open(Url);
}

}
function post(frm, SubInput){
var gesucht = document.getElementById("keyword").value;
if(gesucht.length == "0"){
alert(info);
return;
}
document.getElementById(SubInput).value = gesucht;
document.forms[frm].submit();
}
function param(name){
     var lo = location.href;
     var i = 0;
     var suche = name+"="
     while (i< lo.length){
          if (lo.substring(i, i+suche.length)==suche){
               var ende = lo.indexOf(";", i+suche.length);
               ende = (ende>-1) ? ende : lo.length;
               var cook = lo.substring(i+suche.length, ende);
               return unescape(cook);
          }
          i++;
     }
     return 0;
}