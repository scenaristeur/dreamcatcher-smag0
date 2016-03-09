
generateUUID=function () {
  var d = new Date().getTime();
  var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = (d + Math.random()*16)%16 | 0;
    d = Math.floor(d/16);
    return (c=='x' ? r : (r&0x3|0x8)).toString(16);
  }
  );
  return uuid;
};

/*

// wait for document to load ...
var websocketDreamCatcher;
//var wsUriDreamChat;
window.onload = function () {

  tryLinkSketch();
  preventSauvegarde();
}

// try and find the sketch
tryLinkSketch=function () {
  var sketch = Processing.getInstanceById( getProcessingSketchId() );
  if ( sketch == undefined )
    setTimeout(tryLinkSketch, 200); 
  else {
    initDragDrop(sketch);

    initFichiers(sketch);
    initTouch(sketch);
    initRecherche();
    console.log("valeur test connection socket "+sketch.rechercheConnectionServeur());
    //if (sketch.rechercheConnectionServeur()) {
  var testjson = {
type: 
"test"
  };
  var dataToSend=JSON.stringify(testjson);

  initSocket(dataToSend);
    //  console.log("initsoscket");
    //} 


    // getParametres(); ne semble pas fonctionner avec Processing en local ??? peut être sur le serveru / A revoir pour charger des données
  }
}

preventSauvegarde=function () {
  window.addEventListener("beforeunload", function(e) {
    sketch.sauvegarde();
  }
  , false);
}

initSocket=function (data) {


  //recuperation des projets
  var messagesList = document.getElementById('messages');
  var connectList = document.getElementById('connect');
  // Create a new WebSocket.
  var openshiftWebSocketPort = 8000; // Or use 8443 for wss
  //var wsUriDreamCatcher = "ws://" + window.location.hostname + ":" + openshiftWebSocketPort + "/dreamcatcher";
   var wsUriDreamCatcher = "ws://" + "smag-smag0.rhcloud.com" + ":" + openshiftWebSocketPort + "/dreamcatcher";
  websocketDreamCatcher = new WebSocket(wsUriDreamCatcher);


  websocketDreamCatcher.onopen = function(event) {
    //socketStatusListe.innerHTML = 'Connected to: ' + event.currentTarget.url;
    //socketStatusListe.className = 'open';
    socketConnected=true;
    connectList.innerHTML="<li>CONNECTE</li>";
    console.log("open");
     websocketDreamCatcher.send(data);
  };

  websocketDreamCatcher.onerror = function(error) {
    console.log('WebSocket Liste Error: ' + error);
  };


  // Show a disconnected message when the WebSocket is closed.
  websocketDreamCatcher.onclose = function(event) {
    socketConnected=false;
    var sketch = Processing.getInstanceById( getProcessingSketchId() );
    sketch.session=null;
    connectList.innerHTML="<li>DECONNECTE</li>";
    console.log("close")//socketStatusListe.innerHTML = 'Disconnected from WebSocket ListeProjets.';
      //socketStatusListe.className = 'closed';
    };

    //recupere ListeProjets
    websocketDreamCatcher.onmessage = function(event) {
      var message = event.data;
      console.log(event.data);
      obj = JSON.parse(event.data);
      var i=0;
      for (var key in obj) {
        if (obj.hasOwnProperty(key)) {
          connectList.innerHTML = '<li class="received">'+obj["nombre"]+' utilisateurs connectes</li>';
         // messagesList.innerHTML='<li class="received">'+obj["message"]+'</li>';
                  if (obj["type"]=="synchro"){
          delete obj["type"];
          console.log("reponse de synchro après add ");
          for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
            
              console.log ( obj[key].sujet+" "+obj[key].propriete+" "+obj[key].objet);
           var sujet= obj[key].sujet;
            var propriete=obj[key].propriete;
            var objet=obj[key].objet;
            console.log("Retour "+sujet+" "+propriete+" "+objet);
            messagesList.innerHTML=sujet+" "+propriete+" "+objet;
            var sketch = Processing.getInstanceById( getProcessingSketchId() );
            sketch.ajouteInformationFromOthers(sujet,propriete,objet) ;
          };
        }
        
        
          }else
          if (obj["type"]=="nouveauNoeud") {
            console.log("nouveauNoeud");
            var messageRetour=obj["message"];
            console.log("Retour "+messageRetour);
            messagesList.innerHTML=messageRetour;
          }else
                    if (obj["type"]=="nouvelleInfo") {
            console.log("nouvelleInfo");
            var sujet=obj["sujet"];
            var propriete=obj["propriete"];
            var objet=obj["objet"];
            console.log("Retour "+sujet+" "+propriete+" "+objet);
            messagesList.innerHTML=sujet+" "+propriete+" "+objet;
              var sketch = Processing.getInstanceById( getProcessingSketchId() );
              sketch.ajouteInformationFromOthers(sujet,propriete,objet);
              break;
          }else
                    if (obj["type"]=="conversion") {
                      console.log("retour Conversion");
                      
                      retourConversionexport("test");
                      break;
                    }
        }
      }
      return websocketDreamCatcher;
    };

retourConversionexport=function (textToWrite){
 
  
  var textFileAsBlob = new Blob([textToWrite], {
type:
    'text/turtle'
  }
  );
  var fileNameToSaveAs = document.getElementById("inputFileNameToSaveAs").value+".owl";

  var downloadLink = document.createElement("a");
  downloadLink.download = fileNameToSaveAs;
  downloadLink.innerHTML = "Download File";
  if (window.webkitURL != null)
  {
    // Chrome allows the link to be clicked
    // without actually adding it to the DOM.
    downloadLink.href = window.webkitURL.createObjectURL(textFileAsBlob);
  } else
  {
    // Firefox requires the link to be added to the DOM
    // before it can be clicked.
    downloadLink.href = window.URL.createObjectURL(textFileAsBlob);
    downloadLink.onclick = destroyClickedElement;
    downloadLink.style.display = "none";
    document.body.appendChild(downloadLink);
  }

  downloadLink.click(); 
  
}

  //recuperation des parametres de l'URL
getParameterByName=  function (name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"), 
    results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
  }

sendMessage=  function () {
    console.log("socket :"+websocketDreamCatcher);
    if (websocketDreamCatcher) {

      var message = $('#username').val() + ":" + $('#message').val();
      websocketDreamCatcher.send(message);
      $('#message').val('');
    }
  }
}
initRecherche=function () {
  var rechercheDiv= document.getElementById("recherche");
  var rechercheDivSimple= document.getElementById("rechercheDivSimple");
  var rechercheDivComplexe= document.getElementById("rechercheDivComplexe");
  rechercheDivComplexe.style.visibility="hidden";
  rechercheDivComplexe.style.height=0;
  rechercheDivSimple.style.visibility="visible";
}
changeRecherche=function (id) {
  var rechercheDiv= document.getElementById("recherche");
  var rechercheDivSimple= document.getElementById("rechercheDivSimple");
  var rechercheDivComplexe= document.getElementById("rechercheDivComplexe");
  if (id=="complexe") {
    rechercheDivComplexe.style.visibility="visible";
    rechercheDivComplexe.style.height="auto";
    rechercheDivSimple.style.visibility="hidden"; 
    rechercheDivSimple.style.height=0;
    console.log("complexe");
  } else {
    console.log("simple");
    rechercheDivSimple.style.visibility="visible";
    rechercheDivSimple.style.height="auto";
    rechercheDivComplexe.style.visibility="hidden"; 
    rechercheDivComplexe.style.height=0;
  }
};

getParametres=function () {
  Url = {
    get get() {
      var vars= {
      };
      if (window.location.search.length!==0)
        window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
          key=decodeURIComponent(key);
          if (typeof vars[key]==="undefined") {
            vars[key]= decodeURIComponent(value);
          } else {
            vars[key]= [].concat(vars[key], decodeURIComponent(value));
          }
        }
      );
      return vars;
    }
  };
  console.log("data : "+Url.get.param1);
};



open_infos=function (page, nom, type, id)
{
  width = 1024;
  height = 600;
  if (window.innerWidth)
  {
    var left = (window.innerWidth-width)/2;
    var top = (window.innerHeight-height)/2;
  } else
  {
    var left = (document.body.clientWidth-width)/2;
    var top = (document.body.clientHeight-height)/2;
  }

  var popup= window.open(page, nom, 'menubar=no, scrollbars=no, top='+top+', left='+left+', width='+width+', height='+height+'');
  //  console.log("valeur "+id);
  var windowHasLoaded = false;
  popup.onload = function () {
    windowHasLoaded = true;
    //  console.log("windowHasLoaded = true");
  }
  popup.onload = function () {
    windowHasLoaded = true;
    //  console.log("windowHasLoaded = true");
  }

doSomethingWhenWindowHasLoaded=  function () {
    if (!windowHasLoaded) {
      //    console.log("popup non chargée"); // pb lorsque l'on demande une nouvelle modif sans avoir fermé la première
      // onload event hasn't fired yet, wait 100ms and check again 
      myTimeout =window.setTimeout(doSomethingWhenWindowHasLoaded, 100);
    } else {
      // onload event has already fired, so we can continue
      //   console.log("popup chargée");
      clearTimeout(myTimeout);
      //  var div_test = popup.document.createElement("DIV");
      var div_test2=popup.document.getElementById("test");
      var t = popup.document.createTextNode(id); 
      while (div_test2.hasChildNodes ()) { //vider le div
        div_test2.removeChild(div_test2.firstChild);
      }
      div_test2.appendChild(t);
      chargementInfo(popup, id);
    }
  }

  doSomethingWhenWindowHasLoaded();
}

chargementInfo=function (popup, id) {
  var principal_sujet=popup.document.getElementById("principal_sujet");
  var principal_propriete=popup.document.getElementById("principal_propriete");
  var principal_objet=popup.document.getElementById("principal_objet");
  var principal_sujet_ajoute=popup.document.getElementById("principal_sujet_ajoute");
  var principal_sujet_ajoute2=popup.document.getElementById("principal_sujet_ajoute2");
  var principal_modification=popup.document.getElementById("principal_modification");
  var boutonValide= ajouteBoutonModifPrincipal(principal_modification);
  var sketch = Processing.getInstanceById( getProcessingSketchId() );
  var resultat= sketch.getInformation(id);
  console.log(resultat);

  var sujet=resultat['sujet'];
  var propriete=resultat['propriete'];
  var objet=resultat['objet'];
  console.log('############');
  console.log(sujet);
  console.log(propriete);
  console.log(objet);
  console.log('############');
  principal_sujet.innerHTML=sujet['uriCourte'];
  principal_propriete.innerHTML=propriete;
  principal_objet.innerHTML=objet['uriCourte'];

  principal_sujet_ajoute.innerHTML=sujet['uriCourte'];
  principal_sujet_ajoute2.innerHTML=sujet['uriCourte'];
  console.log(id+" "+principal_sujet.innerHTML+" "+principal_propriete.innerHTML+" "+principal_objet.innerHTML);
  var modificationObjet=false;
  var modificationPropriete=false;
  informations=sketch.getInformations();
  principal_objet.onclick=function() {
    if (!modificationObjet) {
      modificationObjet=true;
      console.log("modif objet "+principal_objet.innerHTTML);


      var selectObjet = document.createElement("SELECT");
      var optionDefaut = document.createElement("option");
      optionDefaut.text = principal_objet.innerHTML;
      selectObjet.add(optionDefaut);
      var optionDefaut = document.createElement("option");
      optionDefaut.text = "NOUVEL OBJET";
      selectObjet.add(optionDefaut);
      for (var i = 0; i<informations.length; i++) {
        var information=informations[i];
        //  console.log(information);
        var nomSujet=information['sujet']['uriCourte'];
        var nomObjet=information['objet']['uriCourte'];
        var exist=optionExists( nomSujet, selectObjet );
        if (!exist) {
          var opt = document.createElement('option');
          // opt.value = i;
          opt.text = nomSujet;
          selectObjet.appendChild(opt);
        }
        var exist=optionExists( nomObjet, selectObjet );
        if (!exist) {
          var opt = document.createElement('option');
          // opt.value = i;
          opt.text = nomObjet;
          selectObjet.appendChild(opt);
        }
      }
      var br = document.createElement("BR");
      principal_objet.appendChild(br);
      principal_objet.appendChild(selectObjet);
      //principal_modification.innerHTML="";
      // var boutonValide= ajouteBoutonModifPrincipal(principal_modification);
      //
      var inputValObjet;
      // console.log(principal_propriete);
      selectObjet.onchange=function() {
        console.log(selectObjet.value+ " selectionné");
        //principal_propriete.remove(select);
        if (selectObjet.value=="NOUVEL OBJET") {
          console.log("afficher input objet");
          var br = document.createElement("BR");
          inputObjet = document.createElement("INPUT");
          inputObjet.setAttribute("type", "text");
          principal_objet.id="newObjet";
          principal_objet.appendChild(br);
          principal_objet.appendChild(inputObjet);
        } else {
          principal_objet.innerHTML=selectObjet.value;
          modificationObjet=false;
          inputValObjet=principal_objet.innerHTML;
          inputObjet.innerHTML="";
        }
      };
      //
      //checkbox choix renommage / modification de lien
      var checkboxRenomme = document.createElement("INPUT");
      checkboxRenomme.setAttribute("type", "checkbox"); 
      checkboxRenomme.setAttribute("value", "renomme");
      checkboxRenomme.setAttribute("name", "renomme"); 
      checkboxRenomme.setAttribute("id", "checkboxRenomme");
      principal_modification.appendChild(br); 
      principal_modification.appendChild(checkboxRenomme);
      //
    } else {
      console.log(modificationObjet);
    }
  };

  principal_propriete.onclick= function() { 
    if (!modificationPropriete) {
      modificationPropriete=true;
      var select = document.createElement("SELECT");
      var optionDefaut = document.createElement("option");
      optionDefaut.text = principal_propriete.innerHTML;
      select.add(optionDefaut);
      var optionDefaut = document.createElement("option");
      optionDefaut.text = "NOUVELLE PROPRIETE";
      select.add(optionDefaut);
      for (var i = 0; i<informations.length; i++) {
        var information=informations[i];
        //  console.log(information);
        var exist=optionExists( information['propriete'], select );
        if (!exist) {
          var opt = document.createElement('option');
          // opt.value = i;
          opt.text = information['propriete'];
          select.appendChild(opt);
        }
      }

      // console.log(select);
      var br = document.createElement("BR");
      principal_propriete.appendChild(br);
      principal_propriete.appendChild(select);
      // principal_modification.innerHTML="";
      // var boutonValide= ajouteBoutonModifPrincipal(principal_modification);
      var inputValProp;
      // console.log(principal_propriete);
      select.onchange=function() {
        console.log(select.value+ " selectionné");
        //principal_propriete.remove(select);
        if (select.value=="NOUVELLE PROPRIETE") {
          console.log("afficher input");
          var br = document.createElement("BR");
          inputProp = document.createElement("INPUT");
          inputProp.setAttribute("type", "text");
          inputProp.id="newProp";
          principal_propriete.appendChild(br);
          principal_propriete.appendChild(inputProp);
        } else {
          principal_propriete.innerHTML=select.value;
          modificationPropriete=false;
          inputValProp=principal_propriete.innerHTML;
          inputProp.innerHTML="";
        }
      };
    } else {
      console.log(modificationPropriete);
    }
  };

  boutonValide.onclick=function () {   
    var newProp_propriete=popup.document.getElementById("newProp");
    var newObjet_objet=popup.document.getElementById("newObjet");
    var checkboxRenomme=popup.document.getElementById("checkboxRenomme");
    var proprieteNew;
    var objetNew;
    if ((newProp_propriete)&&(newProp_propriete!="")) {
      proprieteNew=newProp_propriete.value;
    } else {
      var principal_propriete=popup.document.getElementById("principal_propriete").innerHTML;
      proprieteNew=principal_propriete;
    }


    if ((newObjet_objet)&&(newObjet_objet!="")) {
      objetNew=newObjet_objet.value;
    } else {
      var principal_objet=popup.document.getElementById("principal_objet").innerHTML;
      objetNew=principal_objet;
    }
    var renomme=checkboxRenomme.checked;
    console.log("checkboxRenomme = "+renomme);
    console.log("lancement validation par le bouton " +id+" "+sujet['uriCourte']+" "+proprieteNew+ " "+objetNew);
    sketch.updateInformation(id, sujet['uriCourte'], proprieteNew, objetNew, renomme);
    var resultat= sketch.getInformation(id);
    var resultatHtml=resultat.infoHtml;
    // console.log(resultatHtml);

  };
}

optionExists=function  ( needle, haystack )
{
  var optionExists = false, 
  optionsLength = haystack.length;

  while ( optionsLength-- )
  {
    if ( haystack.options[ optionsLength ].value === needle )
    {
      optionExists = true;
      break;
    }
  }
  return optionExists;
}


ajouteBoutonModifPrincipal=function (emplacement) {
  console.log("ajouteBoutonModifPrincipal");
  var celluleModifPPAL=emplacement;
  console.log(celluleModifPPAL);
  var boutonValide = document.createElement("button");
  boutonValide.setAttribute("type", "submit");
  boutonValide.innerHTML="Valider";
  emplacement.appendChild(boutonValide);
  return boutonValide;
}

dreamcatcherServersend=function (message) {
  if (websocketDreamCatcher) {
    console.log("envoi vers websocketDreamCatcher");
    websocketDreamCatcher.send(message);
  }
}

dreamcatcherServersend=function (type, message) {
  if (websocketDreamCatcher) {
    var testjson = {
      type: 
type, message:
      message
    };
    var messageJSON=JSON.stringify(testjson);
    //e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
    console.log("envoi vers websocketDreamCatcher de "+messageJSON);
    websocketDreamCatcher.send(messageJSON);
  }
}

dreamcatcherServersend=function (type, sujetUriCourte, objetUriCourte, propriete) {
  if (websocketDreamCatcher) {
    var testjson = {
type: 
type, sujet:
sujetUriCourte, propriete:
propriete, objet:
      objetUriCourte
    };
    var messageJSON=JSON.stringify(testjson);
    //e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
    console.log("envoi vers websocketDreamCatcher de "+messageJSON);
    websocketDreamCatcher.send(messageJSON);
  }
}

dreamcatcherServersend=function    (type,UUID,action,sujetUriCourte,objetUriCourte,propriete){
    if (websocketDreamCatcher) {
    var testjson = {
type: 
type, UUID:UUID,
action:action,sujet:
sujetUriCourte, propriete:
propriete, objet:
      objetUriCourte
    };
    var messageJSON=JSON.stringify(testjson);
    //e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
    console.log("envoi vers websocketDreamCatcher de "+messageJSON);
    websocketDreamCatcher.send(messageJSON);
  }
};
*/
