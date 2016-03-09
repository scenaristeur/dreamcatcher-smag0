// the following events are not part of Processing API. they
// are being called from JavaScript, see ".js" tab

void dragEnter (String e)
{
  // currentColor = dragColor;
  // trail = new ArrayList();
    if (messageInterface!=null) {
    messageInterface=null;
  }
}

void dragOver ( int dragX, int dragY )
{
  /* trail.add(new int[] {    
   dragX, dragY
   }  
   );*/
}

void dragLeave ()
{
  //currentColor = normalColor;
}

void dragDrop ( String dropMessage, int dropX, int dropY, String draggableType, String draggableId)
{
  console.log("DRAGDROP test"+draggableType);

//!!! la gestion des evenements est déporté dans drag_drop.js addEvent(drop)
//
// A NETOYER !!
//
//////////////


  /*  if ((draggableType.equals("classes"))) {
   
   String sujet=messageUpdated(dropMessage);
   console.log("new class"+sujet);
   if (sujet) {
   ajouteStatement(sujet, "rdf:type", "owl:Class");
   }
   }*/
  /*
  if ((didactitielActif)&&(level==0)&&(draggableId.equals("projet"))) {
   level=1;
   messageTutoNumero=0;
   felicitationsLevel();
   didactitiel();
   }
  if (draggableId.equals("tutoriel")) {
    level=0;
    messageTutoNumero=0;
    localStorage.setItem( "level", level) ;
    didactitielActif=true;
    location.reload();
  }*/
 /* if (draggableType.equals("activite")) {
    console.log("Modif de activite"+draggableId);
  } else  if (draggableType.equals("noeuds_select")) {
    console.log("Modif de select"+draggableId);
  } else   if (draggableType.equals("propriete")) {
    //console.log("propriete : " +draggableId); 
    if (selectionnes.size()<2) {
      alert("Vous devez selectionner au moins deux noeuds pour les relier par une propriété, utilisez CTRL");
    } else if (selectionnes.get(0)==null) {
      alert("Il n'y a pas de noeud d'origine dans votre selection");
    } else {
      creationLiens(selectionnes, draggableId);
    }
  } else 
    if (draggableType.equals("outils")) {
    if (draggableId.equals("sauvegarde")) {
      sauvegarde();
    } else    if (draggableId.equals("chargement")) {
      chargement();
    }
  } else {
    message = dropMessage;
    if (message.equals("Charger Fichier")) {
      // console.log("charger");
      Fichier fichierACharger=new Fichier();
      fichierACharger.selectionneFichier();
    } else if (message.equals("Sauvegarder")) {
      console.log("sauvegarder");
    } else {

      nx = dropX;
      ny = dropY;
      String nouveauNom=messageUpdated(message);
      if (nouveauNom) {
        String sujet=nouveauNom;
      //  console.log(sujet+" "+draggableType);
        if (draggableType.equals("classes")) {
          ajouteStatement(sujet, "rdfs:subClassOf", "owl:Class");
        } else
          if (draggableType.equals("individuals")) {

          if (draggableId.equals("thing")) {
            ajouteStatement(sujet, "rdf:type", "owl:Thing");
          }
          if (draggableId.equals("acteur")) {
            ajouteStatement(sujet, "rdf:type", "smag:Acteur");
          }
          if (draggableId.equals("environnement")) {
            ajouteStatement(sujet, "rdf:type", "smag:Environnement");
          }
        }
      }
    }
  }*/
  loop();
  i0 = 0;
  running = true;
}




