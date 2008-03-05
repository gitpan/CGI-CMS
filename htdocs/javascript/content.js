//content.js
var dir =  "";
var style ="Crystal";
var right = 0;
var htmlright =2;
var bbcode = true;
var buttonClose = new Image();
buttonClose.src = dir+"/style/"+style+"/window/closewin.png";
var buttonCloseO = new Image();
buttonCloseO.src = dir+"/style/"+style+"/window/closewino.png";
var buttonCollapse = new Image();
buttonCollapse.src = dir+"/style/"+style+"/window/collapsewin.png";
var buttonCollapseO = new Image();
buttonCollapseO.src = dir+"/style/"+style+"/window/collapsewino.png";
var buttonExpand = new Image();
buttonExpand.src = dir+"/style/"+style+"/window/expandwin.png";
var buttonExpandO = new Image();
buttonExpandO.src = dir+"/style/"+style+"/window/expandwino.png";
var buttonMax = new Image();
buttonMax.src = dir+"/style/"+style+"/window/maxwin.png";
var buttonMaxO = new Image();
buttonMaxO.src = dir+"/style/"+style+"/window/maxwino.png";
var buttonResize = new Image();
buttonResize.src = dir+"/style/"+style+"/window/resize.png";
var buttonResizeO = new Image();
buttonResizeO.src = dir+"/style/"+style+"/window/resizeo.png";
var buttonDock = new Image();
buttonDock.src = dir+"/style/"+style+"/window/dockwin.png";
var buttonDockO= new Image();
buttonDockO.src = dir+"/style/"+style+"/window/dockwino.png";
var buttonUndock = new Image();
buttonUndock.src = dir+"/style/"+style+"/window/undockwin.png";
var buttonUndockO= new Image();
buttonUndockO.src = dir+"/style/"+style+"/window/undockwino.png";

//window.pm
function maxMin(id){
     if(document.getElementById(id).className == 'min'){
          document.getElementById(id).className ='max';
     }else{
          document.getElementById(id).className ='min';
     }
}


function undock(id){
     var wname = "window"+id
     var element = document.getElementById(wname);
     var caption = document.getElementById("tr"+id);
     var pos = element.style.position;
     var o = getElementPosition(wname);

     if(pos == "absolute"){
          element.style.position ="";
          caption.style.cursor ="pointer";
     }else{
          move(wname,o.x,o.y);
     }
}
function displayWin(id){
     var e = document.getElementById('messageBody'+id);
     class4Display('window'+id);
     var display = e.style.display;
     if(display == "none"){
          e.style.display = "";
     }else if(display == ""){
          e.style.display = "none";
     }
}
//opera fix
function class4Display(id){
     var cl  = document.getElementById(id).className;
     document.getElementById(id).className = cl;

}
//<<editor.pm
JString.prototype = new Array();
JString.prototype.constructor = JString;
JString.superclass = Array.prototype;

function JString(string){
     for(i = 0; i < string.length;i++){
          JString.prototype[i] = string[i];
     }
}
JString.prototype.splice = function(i,n,array){
     JString.superclass.splice.call(this,i,n,array);
     return this.join("");
}
JString.prototype.toString = function(){
     return this.join("");
}

var html = 0;

function enableHtml(){
     if(html ==  false){
          html = true;
          document.getElementById('htmlButton').checked = true;
     }else{
          html = false;
          document.getElementById('htmlButton').checked = false;
     }
}

function put(t){
     addText(t);
}

function preview(){
     var titel = document.getElementById('title').value;
     var txt = document.getElementById('txt').value;
     if(!html){
//#txt = escape(txt);
          txt = bb2html(txt);
     }
     var maxWidth = 200;
     if( txt.length > maxWidth ){
          var maxLength = maxWidth;
          var i = 0;
          while(i < txt.length){
               if("<" ==  txt.substr(i,1)){
                    maxLength = maxWidth;
                    do{
                         if(txt.substr(i,1))ret += txt.substr(i,1);
                         i++;
                    }while(">" !=  txt.substr(i,1)&& i < txt.length);
               }
               maxLength = (txt.substr(i,1)!= " ") ? maxLength--: maxWidth;

               if(txt.substr(i,1))ret += txt.substr(i,1);
               if(maxLength == 0){
                    ret += " ";
                    maxLength = maxWidth;
               }
               i++;
          }
     }
     visible('windowpreviewBox');
     setText('ptitel',"<b>"+titel+"</b>");
     setText('pbody',txt);
}
//<< bbcode buttons
function addText(text){
     var element = document.getElementById("txt")
     element.value += text;
     element.focus();
}
function align(a){
     if(html){
          insertT("div align=\""+a+"\"","div");
     }else{
          insertT(a,a);
     }
}
function left(){
     align("left");
}
function center(){
     align("center");
}
function aright(){
     align("right");
}
function justify(){
     align("justify");
}
function strike(){
     insertT("s");
}
function underline(){
     insertT("u");
}
function bold(){
     insertT("b");
}
function italicize(){
     insertT("i");
}
function subb(){
     insertT("sub");
}
function sup(){
     insertT("sup");
}

function img(){
     var textarea  = document.getElementById('txt');
     if(typeof document.selection != 'undefined'){
          var range = document.selection.createRange();
          var txt = range.text;
          range = document.selection.createRange();
          if(txt.length == 0){
               txt = prompt("Insert Image location");
               var o ="";
               if(html){
                    o = "<img src='"+txt+"'/>";
               }else{
                    o = "[img]"+txt+"[/img]";
               }
               textarea.value += o;
          }else{
               if(html){
                    range.text = "<img src='"+txt+"'/>";
               }else{
                    range.text = "[img]"+txt+"[/img]";
               }
               range.moveStart('character', txt.length + 11);
          }
          range.select();
     }else if(textarea.selectionEnd > textarea.selectionStart){
          var i = textarea.selectionStart;
          var n = textarea.selectionEnd;
          var img = textarea.value.substring(i,n);
          o = new JString(textarea.value);
          if(html){
               textarea.value = o.splice(i,(n-i),"<img src='"+img+"'/>");
          }else{
               textarea.value = o.splice(i,(n-i),"[img]"+img+"[/img]");
          }
     }else if(textarea.selectionStart &&(textarea.selectionEnd == textarea.selectionStart)){//insert at gecko
          var ia = textarea.selectionStart;
          var txta = prompt("Insert Image location:");
          var a = textarea.value.substring(0,ia);
          var b = textarea.value.substring(ia,textarea.value.length);
          if(html){
               textarea.value = a +"<img src='"+txta+"'/>"+b;
          }else{
               textarea.value = a +"[img]"+txta+"[/img]"+b;
          }
     }else{
         var imga = prompt("Insert Image location:");
          if(html){
               if(img){textarea.value += "<img src='"+imga+"'/>";}
          }else{
               if(img){textarea.value += "[img]"+imga+"[/img]";}
          }
     }
}
var color = "red";
function setCColor(c){
     color = c;
     document.getElementById("showColor").style.backgroundColor = color;
}
function showColor(){
     var e = document.getElementById("coloor");
     e.style.color = color;
     if(html){
          insertT("span style=\"color:"+color+"\"","span");
     }else{
          insertT("color="+color+"","color");
     }
}
function email(){
     var link = prompt("Insert a Email Address:");
     if(html){
          insertT("a href='mailto:"+link+"'","a");
     }else{
          insertT("email="+link,"email");
     }
}
function link(){
     var link = prompt("Insert a url:");
     if(html){
          insertT("a href=\""+link+"\"","a");
     }else{
          insertT("url="+link+"","url");
     }
}
function insertT(tag,tag2){
     if(!tag2)tag2 = tag;
     var textarea  = document.getElementById('txt');
     if(typeof document.selection != 'undefined'){ //IE6
          range = document.selection.createRange();
          var txt = range.text;
          if(txt.length == 0){
               txt = prompt("Insert text");
               if(txt.length > 0){
               var o ="";
               if(html){
                    o = "<"+tag+">"+txt+"</"+tag2+">";
               }else{
                    o = "["+tag+"]"+txt+"[/"+tag2+"]";
               }
               textarea.value += o;
               }
          }else{
               if(html){
                    range.text = "<"+tag+">"+txt+"</"+tag2+">";
               }else{
                    range.text = "["+tag+"]"+txt+"[/"+tag2+"]";
               }
               range.moveStart('character', tag.length + txt.length + tag2.length);
          }
          range.select();
     }else if(textarea.selectionEnd > textarea.selectionStart){//selektieren gecko
          var i = textarea.selectionStart;
          var n = textarea.selectionEnd;
          var txtb = textarea.value.substring(i,n);
          o = new JString(textarea.value);
          if(html){
               textarea.value = o.splice(i,(n-i),"<"+tag+">"+txtb+"</"+tag2+">");
          }else{
               textarea.value = o.splice(i,(n-i),"["+tag+"]"+txtb+"[/"+tag2+"]");
          }
     }else if(textarea.selectionStart &&(textarea.selectionEnd == textarea.selectionStart)){//insert at gecko
          var ia = textarea.selectionStart;
          var txta = prompt("Insert text");
          var a = textarea.value.substring(0,ia);
          var b = textarea.value.substring(ia,textarea.value.length);
          if(html){
               textarea.value = a +"<"+tag+">"+txta+"</"+tag+">"+b;
          }else{
               textarea.value =   a +"["+tag+"]"+txta+"[/"+tag2+"]"+b;
          }
     }else{//others
          var bol = prompt("insert text");
          if(html){
                    textarea.value += "<"+tag+">"+bol+"</"+tag2+">";
          }else{
                    textarea.value += "["+tag+"]"+bol+"[/"+tag2+"]";
          }
     }
}
function clearIt(){
     var element = document.getElementById("txt")
     element.value = "";
     element.focus();
}

function printButtons(){
    var txf ="<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"  ><tr><td  valign=\"middle\"><img onclick=\"smiley()\"  src=\"/images/smiley.gif\" align=\"middle\" alt=\"Smiley\" border=\"0\" style=\"cursor:pointer;\" title=\"Smiley\"/><td><img onclick=\"grin()\" src=\"/images/grin.gif\"  align=\"middle\" alt=\"Grin\" border=\"0\" style=\"cursor:pointer;\" title=\"Grin\" /><td><img onclick=\"cool()\" src=\"/images/cool.gif\"      align=\"middle\" alt=\"Cool\" border=\"0\" style=\"cursor:pointer;\" title=\"Cool\"/><td><img onclick=\"kuss()\" src=\"/images/kiss.gif\" align=\"middle\" alt=\"Kiss\" border=\"0\" style=\"cursor:pointer;\" title=\"Kiss\"/><td><img onclick=\"angry()\" src=\"/images/angry.gif\" align=\"middle\" alt=\"Angry\" border=\"0\" style=\"cursor:pointer;\" title=\"Angry\"/><td><img src=\"/style/"+style+"/buttons/left.png\" alt=\"left\" style =\"cursor:pointer;\" onclick=\"left();\" class=\"editorButtons\" title=\"left\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/center.png\" alt=\"center\" style =\"cursor:pointer;\" onclick=\"center();\" class=\"editorButtons\" title=\"center\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/right.png\" alt=\"right\" style =\"cursor:pointer;\" onclick=\"aright()\" class=\"editorButtons\" title=\"right\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/bold.png\" alt=\"bold\" style =\"cursor:pointer;\" onclick=\"bold();\" class=\"editorButtons\" title=\"bold\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/italic.png\" alt=\"italic\" style =\"cursor:pointer;\" onclick=\"italicize();\" class=\"editorButtons\" title=\"italic\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/strike.png\" alt=\"strike\" style =\"cursor:pointer;\" onclick=\"strike();\" class=\"editorButtons\" title=\"strike\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/under.png\" style =\"cursor:pointer;\" onclick=\"underline();\" class=\"editorButtons\" title=\"underline\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/sub.png\" style =\"cursor:pointer;\" onclick=\"subb();\" class=\"editorButtons\" title=\"sub\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/sup.png\" alt=\"sup\" style =\"cursor:pointer;\" onclick=\"sup();\" class=\"editorButtons\" title=\"sup\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/img.png\" alt=\"insert image\" style =\"cursor:pointer;\" onclick=\"img();\" class=\"editorButtons\" title=\"image \"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/link.png\" alt=\"link\" style =\"cursor:pointer;\" onclick=\"link();\" class=\"editorButtons\" title=\"link\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/email.png\" alt=\"email\" style =\"cursor:pointer;\" onclick=\"email();\" class=\"editorButtons\" title=\"email\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/clear.png\" style =\"cursor:pointer;\" onclick=\"clearIt();\" class=\"editorButtons\" title=\"clear\"  border=\"0\"/></td></td><td><select align=\"right\" id=\"coloor\" name=\"color\" onChange=\"setCColor(this.options[this.selectedIndex].value)\"><option value=\"black\">Black</option><option value=\"red\" style=\"background-color:Red;\" selected=\"selected\">Red</option><option value=\"Yellow\" style=\"background-color:Yellow;\">Yellow</option><option value=\"pink\" style=\"background-color:Pink;\">Pink</option><option value=\"Green\" style=\"background-color:Green;\">Green</option><option value=\"orange\" style=\"background-color:orange;\">Orange</option><option value=\"purple\" style=\"background-color:Purple;\">Purple</option><option value=\"Blue\" style=\"background-color:Blue;\">Blue</option><option value=\"brown\" style=\"background-color:Brown;\">Brown</option><option value=\"Teal\" style=\"background-color:Teal;\">Teal</option><option value=\"navy\" style=\"background-color:Navy;\">Navy</option><option value=\"Maroon\" style=\"background-color:Maroon;\">Maroon</option><option value=\"LimeGreen\" style=\"background-color:LimeGreen;\">Lime Green</option></select></td><td id =\"showColor\" style=\"background-color:red;\"><img src=\"/style/"+style+"/buttons/button.gif\" alt=\"left\" style =\"cursor:pointer;\" onclick=\"showColor();\" class=\"editorButtons\" title=\"left\"  border=\"0\"/></td>";
     document.write(txf);
     if(right >= htmlright && bbcode == true){
     	document.write('<td>HTML:<input type="checkbox" onclick="enableHtml()" id="htmlButton" name="format"/></td>');
     }
     document.write("</tr></table>");
}

function getValue(id){
     return document.getElementById(id).value;
}
function setValue(id,txt){
     document.getElementById(id).value = txt;
}

function smiley() {
     addText(":)");
}
function grin() {
     addText(";D");
}
function cool() {
     addText("8)");
}
function kuss() {
     addText(":-*");
}
function angry() {
     addText(":(");
}
//editor.pm

//login
function checkLogin(){
     var f = document.Login;
     var ret = true;
     var array = new Array();
     var error = false;
     if (f.user.value==""){
          array.push("Namen")
          ret = false;
          error = true;
     }
     if (f.password.value==""){
          array.push("Password")
          ret = false;
          error = true;
     }
     if(error){
          alert("Bitte geben Sie "+ array.join(" und ")+" an.");
     }
     return ret;
}
//<<API


//<<drag&drop
var dragobjekt = null;
var dragX = 0;
var dragY = 0;
var posX = 0;
var posY = 0;

document.onmousemove = drag;
document.onmouseup = drop;

function startdrag(element){
     dragobjekt = document.getElementById(element);
     dragX = posX - dragobjekt.offsetLeft;
     dragY = posY - dragobjekt.offsetTop;
}
function drop() {
     dragobjekt = null;
}
function drag(EVENT) {
     posX = document.all ? window.event.clientX : EVENT.pageX;
     posY = document.all ? window.event.clientY : EVENT.pageY;
     if(dragobjekt != null){
          dragobjekt.style.left = (posX - dragX)+"px";
          dragobjekt.style.top = (posY - dragY)+"px";
     }
}
//drag&drop
function displayTree(id){
     var e = document.getElementById(id);
     var display = e.style.display;
     if(display == "none"){
          e.style.display = "";
     }else if(display == ""){
          e.style.display = "none";
     }
}
// object.x - .y =  getElementPosition(id);
function getElementPosition(id){
     var node = document.getElementById(id);
      var offsetLeft = 0;
      var offsetTop = 0;
     while (node){
          offsetLeft += node.offsetLeft;
          offsetTop += node.offsetTop;
          node = node.offsetParent;
     }
     var position = new Object();
     position.x = offsetLeft;
     position.y = offsetTop;
     return position;

}
// move(Id, x, y)
function move(id,x,y){
     Element = document.getElementById(id);
     Element.style.position = "absolute";
     Element.style.left = x + "px";
     Element.style.top  = y + "px";
}
function leaveFrame(){
     if (parent.frames.length>0){
          parent.location.href = location.href;
     }
}
// Fenster maximieren
function maximize(){
     window.moveTo(0,0);
     var h = screen.availHeight;
     var w = screen.availWidth;
     window.resizeTo(w,h);
}


function resizePage(){
    var h = screen.availHeight;
    var w = screen.availWidth;
//     location.href =
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
function blogThis(){
     var referer = param("referer");
     var headline = param("headline");
     var q = param("quote");
     if(referer && headline && q){
     var t = "[blog="+unescape(referer)+"]\n"+unescape(q)+"\n[/blog]";
     document.getElementById('title').value = unescape(headline);
     document.getElementById('txt').value = t;
     }
}
// var d = datum();
function datum(){
     var z = new Date();
     var j = z.getYear();
     if(j < 999) j+=1900;
     var m = z.getMonth() + 1;
     var t = z.getDate();
     var d =  "Datum:"+t+"."+m+"."+j;
     return d;
}

//setText(Id, "text");
function setText(id,string){
     var element = document.getElementById(id);
     element.innerHTML = string;
}
// var text = getText(Id);
function getText(id){
     var element = document.getElementById(id);
     var string = element.innerHTML;
     return string;
}
// hide(Id)
function hide(id){
     document.getElementById(id).style.display = "none";
}
// visible(Id);
function visible(id){
     document.getElementById(id).style.display = "";
}
//API>>
function menu(id,moveable,collapse,resizeable,closeable){
     document.write("<table align=\"right\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" summary=\"layout buttons=\" width=\"*\"><tr>");
     if(moveable == 1 ){
          document.write("<td><img alt ='move' border='0'  src='/style/"+style+"/window/undockwin.png' style ='cursor:pointer;' title='Dock-Undock'  onmousedown =\"undock('"+id+"');if(this.src == buttonUndockO.src){this.src = buttonDock.src;}else{this.src = buttonUndock.src}\" onmouseout = \"if(this.src == buttonUndockO.src ){this.src = buttonUndock.src}if(this.src == buttonDockO.src){ this.src = buttonDock.src;};\" onmouseover =\"if(this.src == buttonDock.src ){this.src = buttonDockO.src;}if(this.src == buttonUndock.src){ this.src = buttonUndockO.src;}\"/></td>");
     }
     if(collapse == 1 ){
          document.write("<td><img alt ='minwin' border='0'  src = '/style/"+style+"/window/collapsewin.png' style ='cursor:pointer;' title='Fensterheber'  onclick =\"displayWin('"+id+"');if(document.getElementById('messageBody"+id+"').style.display  == 'none'){this.src = buttonExpand.src;}else{this.src =buttonCollapse.src;}\" onmouseout = \"if(this.src == buttonCollapseO.src ){this.src = buttonCollapse.src}if(this.src == buttonExpandO.src){ this.src = buttonExpand.src;};\" onmouseover =\"if(this.src == buttonCollapse.src ){this.src = buttonCollapseO.src;}if(this.src == buttonExpand.src){ this.src = buttonExpandO.src;}\"/></td>");
     }
     if(resizeable == 1){
          document.write("<td><img alt = 'maxwino' border='0'   src = '/style/"+style+"/window/maxwin.png' style = 'cursor:pointer;' title='Maximieren' onclick =\"maxMin('window"+id+"');if(this.src == buttonMaxO.src ){this.src = buttonResize.src}if(this.src == buttonResizeO.src){ this.src = buttonMax.src;}\" onmouseout =\"if(this.src == buttonMaxO.src ){this.src = buttonMax.src}if(this.src == buttonResizeO.src){ this.src = buttonResize.src;}\" onmouseover = \"if(this.src == buttonMax.src ){this.src = buttonMaxO.src;}if(this.src == buttonResize.src){ this.src = buttonResizeO.src;}\"/></td>");
     }
     if(closeable == 1){
            document.write("<td><img  style='cursor:pointer;'  src='/style/"+style+"/window/closewin.png'  onmouseover=\"this.src = buttonCloseO.src;\"  onmouseout='this.src = buttonClose.src'  alt='Close' title='Schliessen'  border='0' onclick=\"addWindow('"+id+"');this.src = buttonClose.src;\"/></td>");
     }
     document.write("</tr></table>");
}

var windows = new Array();
function addWindow(win){
if(document.getElementById('window'+win) && document.getElementById('tr'+win)){
     document.getElementById('window'+win).style.position ="absolute";
     windows.push(win);
     visible('dynamicTab1');
     visible('dynamicTab2');
     visible('dynamicTab3');
     document.getElementById('window'+win).style.visibility='hidden';
     document.getElementById('tr'+win).style.visibility='hidden';
     document.getElementById('window'+win).style.visibility='hidden';
     if(document.getElementById('trw'+win)) document.getElementById('trw'+win).style.display='none';
     }
}
function displayWindows(){
     hide('dynamicTab1');
     hide('dynamicTab2');
     hide('dynamicTab3');
     for(var i = 0; i < windows.length;i++){
      if( document.getElementById('window'+windows[i]) &&  document.getElementById('tr'+windows[i])){
          document.getElementById('window'+windows[i]).style.position ="";
          document.getElementById('tr'+windows[i]).style.position ="";
          document.getElementById('window'+windows[i]).style.visibility='';
          document.getElementById('tr'+windows[i]).style.visibility='';
          if(document.getElementById('trw'+windows[i])) document.getElementById('trw'+windows[i]).style.display='';
     }
     }
     document.cookie = 'windowStatus=n1; expires=Thu, 01-Jan-70 00:00:01 GMT;';
     windows = new Array();
}
function windowStatus(){
        var date = new Date();
        date = new Date(date.getTime() +1000*60*60*24*1);
        document.cookie = 'windowStatus='+windows.join(":")+'; expires='+date.toGMTString()+';'; 
}
function restoreStatus(){
        if(document.cookie){
        var co  = document.cookie;
        var wi = co.substr(co.search('windowStatus=')+13,co.search(';'));
        var w = wi.split(":");
                for(var i = 0; i < w.length;i++){
                 if( document.getElementById('window'+w[i]) )  addWindow(w[i]);
                }
                if(w.length > 1){
                        visible('dynamicTab1');
                        visible('dynamicTab2');
                        visible('dynamicTab3');
                }
        }
}
