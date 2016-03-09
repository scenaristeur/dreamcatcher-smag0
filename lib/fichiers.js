
initFichiers=function ( sketch ) {
  // console.log("init Fichiers");

  var fileInput = document.querySelector('#file');
  var reader = new FileReader();
  fileInput.addEventListener('change', function() {
    var nomFichier=this.files[0].name
      // alert(nomFichier);

    reader = new FileReader();

    reader.addEventListener('load', function() {
      sketch.initnoeuds();
      var extension=nomFichier.split('.').pop();
      if ((extension=="ttl")||(extension=="n3")||(extension=="n3t")) {
        console.log("extension "+nomFichier+"  ttl");
        sketch.ttl2Xml(reader.result);
        //  websocketDreamCatcher.send('conversion'+reader.result);
        //    if (socketConnected) {
        // json=("{\"message\":\""+ reader.result+"\",\"type\":\"conversion\",\"formatIn\":\"ttl\",\"formatOut\":\"rdfXml\"}");
        // var testjson = JSON.stringify(eval("(" +  reader.result + ")"));
        /* var testjson = {
         type: 
         "conversion", formatIn:
         "ttl", formatOut:
         "rdfXml", message:
         reader.result
         };*/
        // e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
        //     json=("{\"type\":\"conversion\",\"formatIn\":\"ttl\",\"formatOut\":\"rdfXml\",\"message\":\""+ JSON.stringify(testjson)+"\"}");
        //   dreamcatcherServersend(JSON.stringify(testjson));
        // }
      } else {
        console.log("extension "+nomFichier+" non ttl");
        sketch.data2Xml(reader.result);
      }

      alert('Contenu du fichier "' + nomFichier + '" :\n\n' + reader.result);
    }
    , false);

    reader.readAsText(fileInput.files[0]);
  }
  , false);
  //chargement fichier monde
  //sketch.readerBuff = createReader(inputFileName);

  /* xml = new XMLElement(this, "smag0-monde.owl");
   console.log(xml);*/

  //  sketch.owl2xml("http://fuseki-smag0.rhcloud.com/ds/query?query=select+*+where+%7B%3Fs+%3Fp+%3Fo%7D&output=xml");
  sketch.owl2xml("smag0-monde.owl");

  ajouteUneClasse("Thing");
  ajouteUneClasse("Projet");
  ajouteUneClasse("Environnement");
  ajouteUneClasse("Acteur");
  ajouteUneClasse("Competence");
  ajouteUneClasse("Organisation");
  ajouteUneClasse("Role");
  ajouteUneClasse("Action");
  ajouteUneClasse("Evenement");
  ajouteUneClasse("Etape");

  //  loadProjets();
}

loadProjets=function () {
  sketch = Processing.getInstanceById( getProcessingSketchId() );
  sketch.loop();
  var messagesList = document.getElementById('messages');

  // Create a new WebSocket.
  var openshiftWebSocketPort = 8000; // Or use 8443 for wss
  //var wsUriListeProjets = "ws://" + window.location.hostname + ":" + openshiftWebSocketPort + "/listeprojetsws";
  var wsUriListeProjets = "ws://" + "smag-smag0.rhcloud.com" + ":" + openshiftWebSocketPort + "/listeprojetsws";
  var websocketListeProjets = new WebSocket(wsUriListeProjets);


  websocketListeProjets.onopen = function(event) {
    //socketStatusListe.innerHTML = 'Connected to: ' + event.currentTarget.url;
    //socketStatusListe.className = 'open';
    console.log("open");
    websocketListeProjets.send('100');
  };

  websocketListeProjets.onerror = function(error) {
    console.log('WebSocket Liste Error: ' + error);
  };


  // Show a disconnected message when the WebSocket is closed.
  websocketListeProjets.onclose = function(event) {
    console.log("close")//socketStatusListe.innerHTML = 'Disconnected from WebSocket ListeProjets.';
      //socketStatusListe.className = 'closed';
    };
    //recupere ListeProjets
    websocketListeProjets.onmessage = function(event) {
      var message = event.data;
      console.log(event.data);
      obj = JSON.parse(event.data);
      var i=0;
      projetClass=sketch.newSujet(null, "Projet");
      while (i<100) {
        for (var key in obj) {
          if (obj.hasOwnProperty(key)) {

            sujet=sketch.newSujet(null, obj[key].projet);
            titreLiteral=sketch.newSujet(null, obj[key].titre);
            titreLiteral.literal=true;

            sketch.nouvelleInformation(sujet, titreLiteral, "dc:title");
            sketch.nouvelleInformation(sujet, projetClass, "rdf:type");

            messagesList.innerHTML += '<li class="received"><span><a href=\"../projet.jsp?projet='+obj[key].projet+'\">'+obj[key].titre+'</a>'+
            /*'   ...   <a href=\"../projet.jsp?projet='+obj[key].projet+'\">Construction du projet '+obj[key].titre+'</a> :'+*/
            // a changer en post : http://www.journaldunet.com/developpeur/pratique/developpement/12260/comment-faire-une-requete-post-en-javascript-sans-avoir-recours-a-un-formulaire.html
            // '<a href=\"projet1.jsp?projet='+obj[key].projet+'\">(ancienne page projet) </a>'+
            '</span></br>' +
              obj[key].description + '\n latitude : ' +
              obj[key].lat + ' longitude : '+
              obj[key].lon + '</li>';
          }
          console
            i++;
        }
      }
    };
}


choisiNomLocalStorage=function () {
  var retVal = prompt("Choisissez un nom pour sauvegarder ce projet : ");
  if (retVal) {
    return retVal;
  }
}

//EXPORT https://thiscouldbebetter.wordpress.com/2012/12/18/loading-editing-and-saving-a-text-file-in-html5-using-javascrip/
saveTextAsFile=function ()
{
  var textToWrite = document.getElementById("inputTextToSave").value;
  var textFileAsBlob = new Blob([textToWrite], {
type:
    'text/turtle'
  }
  );
  var fileNameToSaveAs = document.getElementById("inputFileNameToSaveAs").value+".ttl";

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

saveTextAsFileRDF=function ()
{
  //voir http://mowl-power.cs.man.ac.uk:8080/converter/restful.jsp
  var textToWrite = document.getElementById("inputTextToSave").value;

  if (socketConnected) {
    // json=("{\"message\":\""+ reader.result+"\",\"type\":\"conversion\",\"formatIn\":\"ttl\",\"formatOut\":\"rdfXml\"}");
    // var testjson = JSON.stringify(eval("(" +  reader.result + ")"));
    var testjson = {
type: 
"conversion", formatIn:
"ttl", formatOut:
"rdfXml", expediteur:
"saveAsRDF", message:
      textToWrite
    };
    // e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
    //     json=("{\"type\":\"conversion\",\"formatIn\":\"ttl\",\"formatOut\":\"rdfXml\",\"message\":\""+ JSON.stringify(testjson)+"\"}");
    // dreamcatcherServersend(JSON.stringify(testjson));
    var messageJSON=JSON.stringify(testjson);
    //e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
    console.log("envoi vers websocketDreamCatcher de "+messageJSON);
    websocketDreamCatcher.send(messageJSON);
  }
}

destroyClickedElement=function (event)
{
  document.body.removeChild(event.target);
}

loadFileAsText=function ()
{
  var fileToLoad = document.getElementById("fileToLoad").files[0];

  var fileReader = new FileReader();
  fileReader.onload = function(fileLoadedEvent) 
  {
    var textFromFileLoaded = fileLoadedEvent.target.result;
    document.getElementById("inputTextToSave").value = textFromFileLoaded;
  };
  fileReader.readAsText(fileToLoad, "UTF-8");
}

transfertLocalStoreToEditor=function () {
}
/*
function exportData() {
 var data = '';
 for (var i=1;i<=2;i++) {
 var sep = '';
 for (var j=1;j<=4;j++) {
 data +=  sep + document.getElementById(i + '_' + j).value;
 sep = ',';
 }
 data += '\r\n';
 }
 var exportLink = document.createElement('a');
 exportLink.setAttribute('href', 'data:text/csv;base64,' + window.btoa(data));
 exportLink.appendChild(document.createTextNode('test.csv'));
 document.getElementById('results').appendChild(exportLink);
 }*/

/*
function XMLToString(oXML)
 {
 //code for IE
 if (window.ActiveXObject) {
 var oString = oXML.xml; return oString;
 } 
 // code for Chrome, Safari, Firefox, Opera, etc.
 else {
 return (new XMLSerializer()).serializeToString(oXML);
 }
 }
 
 function StringToXML(oString) {
 //code for IE
 if (window.ActiveXObject) { 
 var oXML = new ActiveXObject("Microsoft.XMLDOM"); oXML.loadXML(oString);
 return oXML;
 }
 // code for Chrome, Safari, Firefox, Opera, etc. 
 else {
 return (new DOMParser()).parseFromString(oString, "text/xml");
 }
 }*/
