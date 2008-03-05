function setLang(lang){
        switch (lang){
                case 'Other':
                        visible("othLang");
                        break;
                default:
                        hide("othLang");
                        break;
        }
}
function setLicense(lang){
        switch (lang){
                case 'Other':
                        visible("otLi");
                        break;
                default:
                        hide("otLi");
                        break;
        }
}
var imgs = new Array();
imgs[0] = '/images/09-01-08.jpeg';
imgs[1] = '/images/09-01-08-2.jpg';
imgs[2] = '/images/dirk1.jpg';
imgs[3] = '/images/dirk2.jpg';
imgs[4] = '/images/dirk3.jpg';
var i = 0;
document.getElementById("b").src = imgs[1];
function prevImage(){
        i =  (i > 0) ? i-1 : imgs.length-1 ;
        document.getElementById("b").src = imgs[i];
}
function nextImage(){
        i = ( i < imgs.length-1 )? i+1: 0;
        document.getElementById("b").src = imgs[i];
}
function nextprev(){
        document.write('<img src="/style/Crystal/prev.png" onclick="prevImage()"/><img src="/style/Crystal/next.png" onclick="nextImage()"/>');
}