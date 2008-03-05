var hidden = new Array();
function addHidden(id){
     document.getElementById(id).style.position ="absolute";
     hidden.push(id);
     visible('dynamicTab1');
     visible('dynamicTab2');
     visible('dynamicTab3');
     document.getElementById(id).style.visibility='hidden';
}
function displayhidden(){
     hide('dynamicTab1');
     hide('dynamicTab2');
     hide('dynamicTab3');
     for(i = 0; i < hidden.length;i++){
          document.getElementById(hidden[i]).style.position ="";
          document.getElementById(hidden[i]).style.visibility='';
     }
}
