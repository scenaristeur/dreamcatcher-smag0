session=function () {

  var UUID=generateUUID();
  var testjson = {
type: 
"session", UUID:
UUID, action:
    "New"
  };
  var dataToSend=JSON.stringify(testjson);

  initSocket(dataToSend);
  console.log("CREATION session : "+UUID);
  var sketch = Processing.getInstanceById( getProcessingSketchId() );
  sketchSession=sketch.createSession(UUID);
  //sketchSession.setWs(ws);
  var session = document.getElementById('sessionMess');
  session.innerHTML=UUID;
 // console.log(websocketDreamCatcher);
}

join_session=function () {
  var retVal = prompt("Entrez un identifiant de session : ");
  if (retVal) {
    var UUID=retVal;
    var testjson = {
type: 
"session", UUID:
UUID, action:
      "Connect"
    };
    var dataToSend=JSON.stringify(testjson);
 initSocket(dataToSend);
    console.log("CONNECTION session : "+UUID);
    var sketch = Processing.getInstanceById( getProcessingSketchId() );
    sketchSession=sketch.createSession(UUID);
 // sketchSession.setWs(ws);
    var session = document.getElementById('sessionMess');
    session.innerHTML=UUID;
  }
}


initChatSocket=function (data) {
  var messagesList = document.getElementById('messages');
  var connectList = document.getElementById('connect');
  // Create a new WebSocket.
  var openshiftWebSocketPort = 8000; // Or use 8443 for wss
  var wsUriDreamChat = "ws://" + window.location.hostname + ":" + openshiftWebSocketPort + "/dreamcatcher";
  // var wsUriDreamCatcher = "ws://" + "smag-smag0.rhcloud.com" + ":" + openshiftWebSocketPort + "/dreamcatcher";
  wsUriDreamChat = new WebSocket(wsUriDreamChat);


  wsUriDreamChat.onopen = function(event) {
    //socketStatusListe.innerHTML = 'Connected to: ' + event.currentTarget.url;
    //socketStatusListe.className = 'open';
    socketConnected=true;
    connectList.innerHTML="<li>CONNECTE 1</li>";
    console.log("open");
    wsUriDreamChat.send(data);
  };

  wsUriDreamChat.onerror = function(error) {
    console.log('wsUriDreamChat Liste Error: ' + error);
  };


  // Show a disconnected message when the WebSocket is closed.
  wsUriDreamChat.onclose = function(event) {
    socketConnected=false;
    connectList.innerHTML="<li>DECONNECTE 1</li>";
    console.log("close")//socketStatusListe.innerHTML = 'Disconnected from WebSocket ListeProjets.';
      //socketStatusListe.className = 'closed';
    };

    //recupere ListeProjets
    wsUriDreamChat.onmessage = function(event) {
      var message = event.data;
      console.log(event.data);
      obj = JSON.parse(event.data);
      var i=0;
      for (var key in obj) {
        if (obj.hasOwnProperty(key)) {
          connectList.innerHTML = '<li class="received">'+obj["nombre"]+' utilisateurs connectes</li>';
          // messagesList.innerHTML='<li class="received">'+obj["message"]+'</li>';
          if (obj["type"]=="nouveauNoeud") {
            console.log("nouveauNoeud");
            var messageRetour=obj["message"];
            console.log("Retour "+messageRetour);
            messagesList.innerHTML=messageRetour;
          } else
            if (obj["type"]=="nouvelleInfo") {
            console.log("nouvelleInfo");
            var sujet=obj["sujet"];
            var propriete=obj["propriete"];
            var objet=obj["objet"];
            console.log("Retour "+sujet+" "+propriete+" "+objet);
            messagesList.innerHTML=sujet+" "+propriete+" "+objet;
            var sketch = Processing.getInstanceById( getProcessingSketchId() );
            sketch.ajouteInformationFromOthers(sujet, propriete, objet);
            break;
          }
        }
      }
      return wsUriDreamChat;
    };
}

dreamcatcherChatsend=function (newInfo, sujetUriCourte, objetUriCourte, propriete) {
  console.log("dreamcatcherChatsend "+wsUriDreamChat);
  if (wsUriDreamChat) {
   /* var dataJson={ sujet:
sujetUriCourte, propriete:
propriete, objet:
      objetUriCourte};*/
    var testjson = {
type: 
"session", action:
"Update",UUID:UUID, message:
      message
    };
    var messageJSON=JSON.stringify(testjson);
    //e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
    console.log("envoi vers wsUriDreamChat SESSION de "+messageJSON);
    wsUriDreamChat.send(messageJSON);
  }
}

