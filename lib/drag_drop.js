

/* PROBLEME DOCUMENT METEOR
// initialize DnD, add event listeners
initDragDrop=function  ( sketch ) {
  var target = sketch.externals.canvas;
  var targetPosition = getElementPosition(target);
  var messageType = 'text/plain';
  var draggableType;
  var draggableId;


  var links = document.querySelectorAll('.draggables > div'), el = null;
  for (var i = 0; i < links.length; i++) {
    el = links[i];
    configureDraggableElement(el);
    configureContextMenu(el);
  }



  addEvent( target, 'dragenter', function (e) {
    if (e.preventDefault) e.preventDefault();
    sketch.dragEnter();

    return false;
  }
  );

  addEvent( target, 'dragover', function (e) {
    if (e.preventDefault) e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
    sketch.dragOver( e.pageX-targetPosition.x, 
    e.pageY-targetPosition.y );
    return false;
  }
  );

  addEvent( target, 'dragleave', function () {
    sketch.dragLeave();
  }
  );

  addEvent( target, 'drop', function (e) {
    if (e.stopPropagation) e.stopPropagation();
    if (e.preventDefault) e.preventDefault();
    var data = e.dataTransfer.getData("text/plain");
    var result=JSON.parse(data);
    console.log(result);
    var type=draggableType=result['type'];
    var id=draggableId=result['id'];
    var message=draggableMessage=result['message'];
    console.log(id);
    if ((type=='classes')||(type=='individuals')) {
      var sujet=messageUpdated(id);
      if (sujet) {
        console.log("nouveau "+type+" : "+sujet+" id : "+id);
        switch(id) {
        case "classe":
          sketch.ajouteInformation("smag:"+capitalizeFirstLetter(camelize(sujet)), "rdfs:subClassOf", "owl:Class");
          ajouteUneClasse(sujet);
          //  sketch.ajouteStatement(sujet, "rdfs:subClassOf", "owl:Class");
          break;
        case "thing" :
          sketch.ajouteInformation("smag:"+sujet, "rdf:type", "owl:Thing");
          //   sketch.ajouteStatement(sujet, "rdf:type", "owl:Thing");
          break;
        case "acteur":
          sketch.ajouteInformation("smag:"+sujet, "rdf:type", "smag:Acteur");
          //  sketch.ajouteStatement(sujet, "rdf:type", "smag:Acteur");
          break;
        case "environnement":
          sketch.ajouteInformation("smag:"+sujet, "rdf:type", "smag:Environnement");
          //   sketch.ajouteStatement(sujet, "rdf:type", "smag:Environnement");
          break;
        default :
          console.log("id non trouvé");
          sketch.ajouteInformation("smag:"+sujet, "rdf:type", "smag:"+message);
        }
      }
    } else if (id=='sauvegarder') {
      // console.log("bouton sauvegarder");
      sketch.sauvegarde();
    } else if (id=='charger') {
      console.log("bouton charger");
      sketch.charge();
    } else if (id=='session') {
      console.log("bouton session");
      session();
    } else if (id=='join_session') {
      console.log("bouton join session");
      join_session();
    } 
    else {
      open_infos('modif.html', 'aide', type, id);
      //   alert("prochaine fonctionnalité à implémenter : modification des informations, ajout d'une information, suppression d'une information ;-)");
      sketch.dragDrop( e.dataTransfer.getData(messageType), 
      e.pageX-targetPosition.x, 
      e.pageY-targetPosition.y, 
      draggableType, 
      draggableId);
      return false;
    }
  }
  );
} */
/*

PROBLEME METEOR AVEC DOCUMENT
// see: http://html5demos.com/drag
var addEvent = (function () {
  if (document.addEventListener) {
    return function (el, type, fn) {
      if (el && el.nodeName || el === window) {
        el.addEventListener(type, fn, false);
      } else if (el && el.length) {
        for (var i = 0; i < el.length; i++) {
          addEvent(el[i], type, fn);
        }
      }
    };
  } else {
    return function (el, type, fn) {
      if (el && el.nodeName || el === window) {
        el.attachEvent('on' + type, function () { 
          return fn.call(el, window.event);
        }
        );
      } else if (el && el.length) {
        for (var i = 0; i < el.length; i++) {
          addEvent(el[i], type, fn);
        }
      }
    };
  }
}
)();
*/

// see: http://www.quirksmode.org/js/findpos.html
getElementPosition=function  (obj) {
  var curleft = curtop = 0;
  if (obj.offsetParent) {
    do {
      curleft += obj.offsetLeft;
      curtop  += obj.offsetTop;
    } 
    while (obj = obj.offsetParent);
    return {
x:
curleft, y:
      curtop
    };
  }
  return undefined;
}

messageUpdated=function (message) {
  var retVal = prompt("Entrez un nom pour ce/cette "+message+" : ");
  if (retVal) {
    return retVal;
  }
}

configureContextMenu=function (el) {
/* supprimé car METEOR  PB AVEC DOCUMENT
  addEvent(el, 'contextmenu', function(e) {
    alert("You've tried to open context menu"); //here you draw your own menu
    e.preventDefault();
  }
  );*/
}

configureDraggableElement=function (el) {

  el.setAttribute('draggable', 'true');
  addEvent(el, 'dragstart', function (e) {
    e.dataTransfer.effectAllowed = 'copy';
    var message = this.textContent || this.innerHTML;
    draggableType=e.target.parentNode.id;
    draggableId=e.target.id;
    console.log("data start:"+draggableId +" "+draggableType);
    // e.dataTransfer.setData( messageType, message );
    var testjson = {
type: 
draggableType, id:
draggableId, message:
      message
    };
    var dataToSend=JSON.stringify(testjson);
      e.dataTransfer.setData("text/plain", dataToSend);
    return false;
  }
  );
  //ON TOUCH


  //     el.addEventListener("touchstart", handleStart, false);
  // el.addEventListener("touchend", handleEnd, false);
  // el.addEventListener("touchcancel", handleCancel, false);
  // el.addEventListener("touchleave", handleEnd, false);
  // el.addEventListener("touchmove", handleMove, false);
  /*   el.addEventListener('touchstart', function(e) {
   var touch = e.touches[0];
   // Place element where the finger is
   el.text=touch.pageX;
   el.style.left = touch.pageX + 'px';
   el.style.top = touch.pageY + 'px';  
   //  alert(message);
                                                      /* e.dataTransfer.effectAllowed = 'copy';
   var message = this.textContent || this.innerHTML;
   
   draggableType=e.target.parentNode.id;
   draggableId=e.target.id;
   var testjson = {type: draggableType ,id:draggableId,message:message};
   e.dataTransfer.setData("text/plain",JSON.stringify(testjson));
   e.dataTransfer.setData( messageType, message );*/
  /*
      return false;
   }
   , false);*/
}

