class Session {
  String UUID;
  String ws;
  Session(String UUID) {
    this.UUID=UUID;
    console.log("creation session "+UUID);
  }
  
  void send(String newInfo,String sujetUriCourte,String objetUriCourte,String propriete ){
    console.log("send session "+this.UUID);
   dreamcatcherChatsend(newInfo,sujetUriCourte,objetUriCourte,propriete);
  }// "nouvelleInfo",sujetNoeud.uriCourte,objetNoeud.uriCourte,proprieteString);
    //dreamcatcherServersend("nouvelleInfo",sujetNoeud.uriCourte,objetNoeud.uriCourte,proprieteString);
   
   void setWs (String ws){
    this.ws=ws;
   console.log("ws de session ="+this.ws); 
   }
}

Session createSession(String UUID) {
  session=new Session(UUID);

    demo=false;
  //  messageInterface="Glissez le bouton \"Particule\" dans l'espace de travail pour créer une nouvelle particule";
    initialize();
    initialiseZoom();
    loop();
    i0 = 0;
    running = true;
    return session;
}

