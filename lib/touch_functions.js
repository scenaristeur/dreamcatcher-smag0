initTouch=function ( sketch ) {
//  console.log("init Touch");

  //PREVENIR LE SCROLL DU ONTOUCH
  document.body.addEventListener('touchmove', function(event) {
    console.log(event.touches.length);
    if (event.touches.length == 1) {
      event.preventDefault();
    }
  }
  , false); 
  startup();
}


startup=function () {
  var links = document.querySelectorAll('.draggables > div'), el = null;
  for (var i = 0; i < links.length; i++) {
    el = links[i];

    // el.setAttribute('draggable', 'true');
    el.addEventListener("touchstart", handleStart, false);
    el.addEventListener("touchend", handleEnd, false);
    el.addEventListener("touchcancel", handleCancel, false);
    el.addEventListener("touchleave", handleEnd, false);
    el.addEventListener("touchmove", handleMove, false);
    //  log("initialized."+ el);
    /* addEvent(el, 'touchstart', function (e) {
     e.dataTransfer.effectAllowed = 'copy';
     var message = this.textContent || this.innerHTML;
     log("initialized." +message);
     draggableType=e.target.parentNode.id;
     draggableId=e.target.id;
     e.dataTransfer.setData( messageType, message );
     return false;
     }
     );*/
  }
  // var el = document.getElementsByTagName("canvas")[1];
  // el.addEventListener("touchstart", handleStart, false);
  //  el.addEventListener("touchend", handleEnd, false);
  //  el.addEventListener("touchcancel", handleCancel, false);
  //  el.addEventListener("touchleave", handleEnd, false);
  //  el.addEventListener("touchmove", handleMove, false);
}

handleStart=function (e) {
  e.preventDefault();
  // e.dataTransfer.effectAllowed = 'copy';
  var message = this.textContent || this.innerHTML; // evt.target

  draggableType=e.target.parentNode.id;
  draggableId=e.target.id;
  // e.dataTransfer.setData( messageType, message );
  log("touchstart."+draggableType+" "+draggableId+" "+message);
  return false;
  /* var el = document.getElementsByTagName("canvas")[1];
   var ctx = el.getContext("2d");
   var touches = evt.changedTouches;
   
   for (var i = 0; i < touches.length; i++) {
   log("touchstart:" + i + "...");
   ongoingTouches.push(copyTouch(touches[i]));
   var color = colorForTouch(touches[i]);
   ctx.beginPath();
   ctx.arc(touches[i].pageX, touches[i].pageY, 4, 0, 2 * Math.PI, false);  // a circle at the start
   ctx.fillStyle = color;
   ctx.fill();
   log("touchstart:" + i + ".");
   }*/
}

handleMove=function (evt) {
  evt.preventDefault();
  var message = this.textContent || this.innerHTML; // evt.target

  // draggableType=e.target.parentNode.id;
  draggableId=e.target.id;
  // e.dataTransfer.setData( messageType, message );
  log("touchmove."+draggableId+" "+message);
  /*
  var el = document.getElementsByTagName("canvas")[1("canvas")[1]];
   var ctx = el.getContext("2d");
   var touches = evt.changedTouches;
   
   for (var i = 0; i < touches.length; i++) {
   var color = colorForTouch(touches[i]);
   var idx = ongoingTouchIndexById(touches[i].identifier);
   
   if (idx >= 0) {
   log("continuing touch "+idx);
   ctx.beginPath();
   log("ctx.moveTo(" + ongoingTouches[idx].pageX + ", " + ongoingTouches[idx].pageY + ");");
   ctx.moveTo(ongoingTouches[idx].pageX, ongoingTouches[idx].pageY);
   log("ctx.lineTo(" + touches[i].pageX + ", " + touches[i].pageY + ");");
   ctx.lineTo(touches[i].pageX, touches[i].pageY);
   ctx.lineWidth = 4;
   ctx.strokeStyle = color;
   ctx.stroke();
   
   ongoingTouches.splice(idx, 1, copyTouch(touches[i]));  // swap in the new touch record
   log(".");
   } else {
   log("can't figure out which touch to continue");
   }
   }*/
}

handleEnd=function (e) {
  e.preventDefault();
  var message = this.textContent || this.innerHTML; // evt.target
  draggableType=e.target.parentNode.id;
  draggableId=e.target.id;//
  //OK
  //result= messageUpdated(message); // OK sans passer par sketch  --> reprendre les fonctions
  //
  alert("les fonctions pour mobile sont en cours d'implémentation, \n en attendant, vous pouvez utilisez cette appli sur un PC,\n avec Google Chrome ou Firefox :-)");
  /*
    if (e.stopPropagation) e.stopPropagation();
   if (e.preventDefault) e.preventDefault();
   sketch.dragDrop( e.dataTransfer.getData(messageType), 
   e.pageX-targetPosition.x, 
   e.pageY-targetPosition.y, 
   draggableType, 
   draggableId);
   return false;
   */
  // draggableId=e.target.id;
  
 // creationResultat=sketch.createNoeud(result);

  // e.pageX-targetPosition.x, 
  // e.pageY-targetPosition.y, 
  // draggableType, 
  // draggableId);
  log("touchend/touchleave. "+creationResultat);
  /*
  var el = document.getElementsByTagName("canvas")[1];
   var ctx = el.getContext("2d");
   var touches = evt.changedTouches;
   
   for (var i = 0; i < touches.length; i++) {
   var color = colorForTouch(touches[i]);
   var idx = ongoingTouchIndexById(touches[i].identifier);
   
   if (idx >= 0) {
   ctx.lineWidth = 4;
   ctx.fillStyle = color;
   ctx.beginPath();
   ctx.moveTo(ongoingTouches[idx].pageX, ongoingTouches[idx].pageY);
   ctx.lineTo(touches[i].pageX, touches[i].pageY);
   ctx.fillRect(touches[i].pageX - 4, touches[i].pageY - 4, 8, 8);  // and a square at the end
   ongoingTouches.splice(idx, 1);  // remove it; we're done
   } else {
   log("can't figure out which touch to end");
   }
   }*/
}

handleCancel=function (evt) {
  evt.preventDefault();
  var message = this.textContent || this.innerHTML; // evt.target

  // draggableType=e.target.parentNode.id;
  //  draggableId=e.target.id;
  log("touchcancel. "+message);
  /*
  var touches = evt.changedTouches;
   
   for (var i = 0; i < touches.length; i++) {
   ongoingTouches.splice(i, 1);  // remove it; we're done
   }*/
}

colorForTouch=function (touch) {
  var r = touch.identifier % 16;
  var g = Math.floor(touch.identifier / 3) % 16;
  var b = Math.floor(touch.identifier / 7) % 16;
  r = r.toString(16); // make it a hex digit
  g = g.toString(16); // make it a hex digit
  b = b.toString(16); // make it a hex digit
  var color = "#" + r + g + b;
  log("color for touch with identifier " + touch.identifier + " = " + color);
  return color;
}

copyTouch=function (touch) {
  return { 
identifier: 
touch.identifier, pageX: 
touch.pageX, pageY: 
    touch.pageY
  };
}

ongoingTouchIndexById=function (idToFind) {
  for (var i = 0; i < ongoingTouches.length; i++) {
    var id = ongoingTouches[i].identifier;

    if (id == idToFind) {
      return i;
    }
  }
  return -1;    // not found
}

log=function (msg) {
  var p = document.getElementById('log');
  p.innerHTML = msg + "\n" + p.innerHTML;
}
/*
function onTouch(evt) {
 evt.preventDefault();
 if (evt.touches.length > 1 || (evt.type == "touchend" && evt.touches.length > 0))
 return;
 
 var newEvt = document.createEvent("MouseEvents");
 var type = null;
 var touch = null;
 
 switch (evt.type) {
 case "touchstart": 
 type = "mousedown";
 touch = evt.changedTouches[0];
 break;
 case "touchmove":
 type = "mousemove";
 touch = evt.changedTouches[0];
 break;
 case "touchend":        
 type = "mouseup";
 touch = evt.changedTouches[0];
 break;
 }
 
 newEvt.initMouseEvent(type, true, true, evt.originalTarget.ownerDocument.defaultView, 0, 
 touch.screenX, touch.screenY, touch.clientX, touch.clientY, 
 evt.ctrlKey, evt.altKey, evt.shiftKey, evt.metaKey, 0, null);
 evt.originalTarget.dispatchEvent(newEvt);
 }*/
