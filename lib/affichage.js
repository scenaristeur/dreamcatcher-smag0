ajouteInfo2Activite = function(information) {
  var messageType = 'text/plain';
  // si le div existe, on le reutilise
  var uuidExistant=document.getElementById(information.UUID);
  var affNoeud;
  if (uuidExistant) {
    console.log(uuidExistant);
    affNoeud=uuidExistant;
    while (affNoeud.firstChild) {
      affNoeud.removeChild(affNoeud.firstChild);
    }
  } else {
    affNoeud = document.createElement("DIV");
    affNoeud.id=information.UUID;
    configureContextMenu(affNoeud);
  }


  var div_activite=document.getElementById("activite");
  var t = document.createTextNode(information.infoHtml); 
  affNoeud.appendChild(t);

  affNoeud.setAttribute("draggable", "true");
  affNoeud.onclick = function() {     
    ajouteSelectionnes(information);
  }; 
  affNoeud.ondragstart=function(e) {
    // console.log(affNoeud.id+" "+affNoeud.parentNode.id);
    e.dataTransfer.effectAllowed = 'copy';
    var message = this.textContent || this.innerHTML;
    draggableType=e.target.parentNode.id;
    draggableId=e.target.id;
    // console.log("datadragstart :"+draggableId +" "+draggableType);
    var testjson = {
type: 
draggableType, id:
draggableId, message:
      message
    };
    e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
    // console.log("data :"+draggableId +" "+draggableType);
    //  return false;
  };

 // div_activite.insertBefore(affNoeud, div_activite.firstChild);
}

function ajouteSelectionnes(information) {

  var node_select=document.getElementById(information.UUID);
  if (node_select) {
    var parent =node_select.parentNode.id;
    console.log(parent);
    var div_select=null;
    if (parent=="activite") {
      div_select=document.getElementById("noeuds_select");
      information.setSelectionne(true);
      //  console.log("parent = "+document.getElementById(information.UUID).parentNode.id);
    } else if (parent=="noeuds_select") {
      div_select=document.getElementById("activite");
      information.setSelectionne(false);
      //   console.log("parent = "+document.getElementById(information.UUID).parentNode.id);
    }

   // div_select.insertBefore(node_select, div_select.firstChild);
  } else {
    console.log("pb d'UUID de l'information" + information.UUID);
  }
};

function effaceActivite() {
  var div_activite=document.getElementById("activite");
  while (div_activite.firstChild) {
    div_activite.removeChild(div_activite.firstChild);
  }
};
function effaceAfficheSelectionnes() {
  var div_select=document.getElementById("noeuds_select");
  while (div_select.firstChild) {
    div_select.removeChild(div_select.firstChild);
  }
};

function recherche(type) {
  var typerecherche=type;
  var sketch = Processing.getInstanceById( getProcessingSketchId() );
  if (typerecherche=="simple") {
    var mySearch=document.getElementById("mySearch").value;
     sketch.rechercheInfoSimple(mySearch);
     
  } else if  (typerecherche=="complexe") {
    
    var mySearchSujet=document.getElementById("mySearchSujet").value;
    var mySearchPropriete=document.getElementById("mySearchPropriete").value;
    var mySearchObjet=document.getElementById("mySearchObjet").value;
    // if (mySearch!=""){
    sketch.rechercheInfoComplexe(mySearchSujet, mySearchPropriete, mySearchObjet);
    //}
  } else {
    console.log("un pb avec le type de recherche");
  }
}

ajouteUneClasse=function (sujet){
   var individuals=document.getElementById("individuals");
   var newClasse = document.createElement("div");
   newClasse.id=sujet.toLowerCase().replace(/\s+/g, '');;
   newClasse.innerHTML=capitalizeFirstLetter(camelize(sujet));
   newClasse.className = "draggables";
   console.log(newClasse);
   individuals.appendChild(newClasse);
configureDraggableElement(newClasse);
}

camelize=function (str) {
  return str.replace(/(?:^\w|[A-Z]|\b\w)/g, function(letter, index) {
    return index == 0 ? letter.toLowerCase() : letter.toUpperCase();
  }).replace(/\s+/g, '');
}
capitalizeFirstLetter=function (string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}
