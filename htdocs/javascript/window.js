var dir ="";
var style ='Crystal';
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
         document.write("<td><img  style='cursor:pointer;'  src='/style/"+style+"/window/closewin.png'  onmouseover=\"this.src = buttonCloseO.src;\"  onmouseout='this.src = buttonClose.src'  alt='Close' title='Schliessen'  border='0' onclick=\"addWindow('window"+id+"');this.src = buttonClose.src\"/></td>");
     }
     document.write("</tr></table>");
}
//opera fix
function class4Display(id){
     var cl  = document.getElementById(id).className;
     document.getElementById(id).className = cl;

}
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
                    addWindow(w[i]);
                }
                if(w.length > 1){
                        visible('dynamicTab1');
                        visible('dynamicTab2');
                        visible('dynamicTab3');
                }
        }
}