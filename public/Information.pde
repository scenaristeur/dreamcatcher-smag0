class Information extends Spring {

  String infoHtml;
  String UUID;
  boolean selectionne=false;
  boolean on = true;
  Particle sujet, objet;
  String propriete;
  int scoreRecherche=0;
  String prefix;


  Information( Particle A, Particle B, float ks, float d, float r, String propriete) {
    super( A, B, ks, d, r);
    this.propriete=propriete;
    this.sujet=super.one;
    this.objet=super.b;
    UUID=generateUUID();
  }
  void actualiseActivite() {
    this.updateInfoHtml();
    ajouteInfo2Activite(this);
  }
  String updateInfoHtml() {
    this.infoHtml =this.sujet.uriCourte+"\n ";
    this.infoHtml+=this.propriete+"\n";
    this.infoHtml+=this.objet.uriCourte;
    return infoHtml;
  }
  void setSelectionne(boolean _selectionne) {
    selectionne=_selectionne;
  }
}

Information getInformation(String id) {
  Information resultat=new Information(null, null, null, null, null, null);
  for (int i=0; i<informations.size (); i++) {
    Information info=informations.get(i);
    if (info.UUID.equals(id)) {
      resultat=info;
      break;
    }
  }
  return resultat;
}

Information [] getInformations() {
  String [] informationsArray = informations.toArray(new Information[informations.size()]);
  return informationsArray;
}

void updateInformation(String id, String _sujet_name, String _proprieteNew, String _objetNew, boolean renomme) {
  console.log("update de "+id+" avec "+_sujet_name+" "+_proprieteNew+" "+_objetNew+" "+renomme);



  for (int i=0; i<informations.size (); i++) {
    Information info=informations.get(i);


    if (info.UUID.equals(id)) {
      console.log("INFO AVANT CHANGEMENT :"+info.sujet.uriCourte+" "+info.propriete+" "+info.objet.uriCourte);
      //remove le premier lien, creer le deuxième lien
      Information infoAModifier;
      console.log(informations);
      for (int n=0; n<physics.numberOfSprings (); n++) {
        Information infoTemp = informations.get(n);
        // console.log(.one.name+","+ s.b.name+","+s.propriete);
        if ((((infoTemp.sujet==info.sujet)&&(infoTemp.objet==info.objet)))&&(infoTemp.propriete.equals(info.propriete))) {  //||((s.one==info.objet)&&(s.b==info.sujet))
          console.log("BINGO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "+infoTemp.sujet.uriCourte+", "+infoTemp.propriete+", "+ infoTemp.objet.uriCourte);
          infoAModifier=infoTemp;
        }
      }

      if (renomme) {
        console.log("renomme");
        info.sujet.setName(_sujet_name);
        info.propriete=_proprieteNew;
        String name=info.objet.setName(_objetNew);
        console.log("update de "+id+" avec "+info.sujet.uriCourte+" "+info.propriete+" "+info.objet.uriCourte+ " TERMINE");

        info.actualiseActivite();
        break;
      } else {
        console.log("pas renomme");
        console.log ("recherche du noeud à rattacher");
        console.log("rechercher si un noeud correspondant à l'objet existe, si oui, le rattacher à la place de l'ancien, sinon, le créer et le rattacher");
        Noeud noeudTemp;
        for (int j=0; j<physics.numberOfParticles (); j++) {
          noeudTemp=physics.getParticle( j );
          //console.log(noeudCherche.UUID);

          if (noeudTemp.uriCourte=_objetNew) {
            console.log(noeudTemp.uriCourte);
            infoAModifier.objet=noeudTemp;
            physics.removeSpring(info);


            break;
            // noeudObjet=noeudCherche;
          }
        }
        console.log(infoAModifier);
        Information infoModifiee=new Information( infoAModifier.sujet, infoAModifier.objet, forceRessort*random(.5, 1), souplesseRessort*random(.5, 1), longueurRessort*random(.5, 1), _proprieteNew);
        // BUG POUR TROUVER LA BONNE INFO A RATTACHER
        infoModifiee.actualiseActivite();
        physics.springs.add(infoModifiee);
        // info.ks=10;
        // info.d=5;
        //  info.r=12;
        /*  for (int k=0;k<physics.springs.length;k++){
         Spring spTemp= physics.getSprings(k);
         console.log(stTemp); 
         
         }*/
        /* for (int j=0; j<informations.size (); j++) {
         Information info2=informations.get(j);
         //recherche d'un noeud correspondant à l'objet
         if (info2.objet.uriCourte=_objetNew) {
         Particle ObjetTrouve=info2.objet;
         console.log("Objet trouvé : ");
         console.log(ObjetTrouve);
         console.log("FIN Objet trouvé : ");
         //mise à jour de l'information en rattachant cet objet trouvé
         info.propriete=_proprieteNew;
         info.objet=ObjetTrouve;
         console.log("INFO MAJ :"+info.sujet.uriCourte+" "+info.propriete+" "+info.objet.uriCourte);
         info.actualiseActivite(); /// a modifier pour ne pas remplacer si non renomme
         infoAModifier.sujet=info.sujet;
         infoAModifier.objet=info.objet;
         infoAModifier.propriete=info.propriete;
         console.log("SPRING MODIFIE "+spAModifier.one.uriCourte+","+ spAModifier.b.uriCourte+","+spAModifier.propriete);
         //
         break;
         }
         }*/
      }
    }
  }
}

void checkInfosSelectionnees() {
  informationsSelectionnees=new ArrayList();
  for (int j=0; j<informations.size (); j++) {
    Information info=informations.get(j);
    if (info.selectionne) {
      console.log(" x:"+info.sujet.position.x+"\t y: "+info.sujet.position.y);
      informationsSelectionnees.add(info);
    }
  }
  //console.log(informationsSelectionnees.size());
}


void ajouteInformation(String sujetString, String proprieteString, String objetString) {
  console.log ( sujetString+"..."+proprieteString+"..."+ objetString);
  Noeud sujetNoeud=new Noeud();
  Noeud objetNoeud=new Noeud();

  for (i=0; i<physics.numberOfParticles (); i++) {
    Noeud noeudPropose=physics.getParticle( i );
    //   console.log("comparaison avec : "+noeudPropose.uriCourte);
    if (noeudPropose.uriCourte) {
      if (noeudPropose.uriCourte.equals(sujetString)) {
        sujetNoeud=noeudPropose;
        //     console.log("noeud connu "+noeudPropose.uriCourte);
      }
      if (noeudPropose.uriCourte.equals(objetString)) {
        objetNoeud=noeudPropose;
        //   console.log("noeud connu "+noeudPropose.uriCourte);
      }
    }
  }
  if (sujetNoeud.uriCourte==null) {
    sujetNoeud=new Noeud(massDefaut);
    sujetNoeud.setUriCourte(sujetString);
    physics.particles.add(sujetNoeud);
    //   console.log("noeud créé "+sujetNoeud.uriCourte);
  }
  if (objetNoeud.uriCourte==null) {
    objetNoeud=new Noeud(massDefaut);
    objetNoeud.setUriCourte(objetString);
    physics.particles.add(objetNoeud);
    //   console.log("noeud créé "+objetNoeud.uriCourte);
  }

  //  makeEdgeBetween( p, q, propriete);
  sujetNoeud.mass0++;
  objetNoeud.mass0++;
  sujetNoeud.position.x = objetNoeud.position.x + random( -10, 10 );
  sujetNoeud.position.y = objetNoeud.position.y + random( -10, 10 );
  sujetNoeud.position.z = 0;
  //if (socketConnected) {
  // String json=("{\"subject\":\""+ sujetNoeud.uriCourte+"\"}");
  // json.setString("predicate", proprieteString);
  // json.setString("object", objetNoeud.uriCourte);
  if (session.UUID!=null) {
    // session.send("nouvelleInfo",sujetNoeud.uriCourte,objetNoeud.uriCourte,proprieteString);
    dreamcatcherServersend("session", session.UUID, "NewInfo", sujetNoeud.uriCourte, objetNoeud.uriCourte, proprieteString);
  } else {
    Information information = new Information(sujetNoeud, objetNoeud, forceRessort*random(.5, 1), souplesseRessort*random(.5, 1), longueurRessort*random(.5, 1), proprieteString);
    physics.springs.add( information );
    // console.log(propriete);
    informations.add(information);
    information.actualiseActivite();
  }// console.log("AJOUTE INFORMATION : "+physics.numberOfParticles ());
  //sujetNoeud.update();
  //}
  //      testjson = {type: "nouveauNoeud",  message:      sujetNoeud.uriCourte    };
  // e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
  //     json=("{\"type\":\"conversion\",\"formatIn\":\"ttl\",\"formatOut\":\"rdfXml\",\"message\":\""+ JSON.stringify(testjson)+"\"}");
  // dreamcatcherServersend(JSON.stringify(testjson));
}

void ajouteInformationFromOthers(String sujetString, String proprieteString, String objetString) {
  console.log ( sujetString+"..."+proprieteString+"..."+ objetString);
  Noeud sujetNoeud=new Noeud();
  Noeud objetNoeud=new Noeud();

  for (i=0; i<physics.numberOfParticles (); i++) {
    Noeud noeudPropose=physics.getParticle( i );
    //   console.log("comparaison avec : "+noeudPropose.uriCourte);
    if (noeudPropose.uriCourte) {
      if (noeudPropose.uriCourte.equals(sujetString)) {
        sujetNoeud=noeudPropose;
        //     console.log("noeud connu "+noeudPropose.uriCourte);
      }
      if (noeudPropose.uriCourte.equals(objetString)) {
        objetNoeud=noeudPropose;
        //   console.log("noeud connu "+noeudPropose.uriCourte);
      }
    }
  }
  if (sujetNoeud.uriCourte==null) {
    sujetNoeud=new Noeud(massDefaut);
    sujetNoeud.setUriCourte(sujetString);
    physics.particles.add(sujetNoeud);
    //   console.log("noeud créé "+sujetNoeud.uriCourte);
  }
  if (objetNoeud.uriCourte==null) {
    objetNoeud=new Noeud(massDefaut);
    objetNoeud.setUriCourte(objetString);
    physics.particles.add(objetNoeud);
    //   console.log("noeud créé "+objetNoeud.uriCourte);
  }
  Information information = new Information(sujetNoeud, objetNoeud, forceRessort*random(.5, 1), souplesseRessort*random(.5, 1), longueurRessort*random(.5, 1), proprieteString);
  physics.springs.add( information );
  // console.log(propriete);
  informations.add(information);
  information.actualiseActivite();
  //  makeEdgeBetween( p, q, propriete);
  sujetNoeud.mass0++;
  objetNoeud.mass0++;
  sujetNoeud.position.x = objetNoeud.position.x + random( -10, 10 );
  sujetNoeud.position.y = objetNoeud.position.y + random( -10, 10 );
  sujetNoeud.position.z = 0;
  //if (socketConnected) {
  // String json=("{\"subject\":\""+ sujetNoeud.uriCourte+"\"}");
  // json.setString("predicate", proprieteString);
  // json.setString("object", objetNoeud.uriCourte);
  // dreamcatcherServersend("nouvelleInfo",sujetNoeud.uriCourte,objetNoeud.uriCourte,proprieteString);
  // console.log("AJOUTE INFORMATION : "+physics.numberOfParticles ());
  //sujetNoeud.update();
  //}
  //      testjson = {type: "nouveauNoeud",  message:      sujetNoeud.uriCourte    };
  // e.dataTransfer.setData("text/plain", JSON.stringify(testjson));
  //     json=("{\"type\":\"conversion\",\"formatIn\":\"ttl\",\"formatOut\":\"rdfXml\",\"message\":\""+ JSON.stringify(testjson)+"\"}");
  // dreamcatcherServersend(JSON.stringify(testjson));
}



Information nouvelleInformation(Particle sujetNoeud, Particle objetNoeud, String proprieteString) {
  Information information = new Information(sujetNoeud, objetNoeud, forceRessort*random(.5, 1), souplesseRessort*random(.5, 1), longueurRessort*random(.5, 1), proprieteString);
  sujetNoeud.mass0++;
  objetNoeud.mass0++;
  sujetNoeud.position.x = objetNoeud.position.x + random( -10, 10 );
  sujetNoeud.position.y = objetNoeud.position.y + random( -10, 10 );
  sujetNoeud.position.z = 0;
  physics.springs.add( information );
}

void rechercheInfoSimple(String _mySearch) {
  // effaceAfficheSelectionnes();
  console.log(_mySearch); 
  for ( int i = 0; i < physics.numberOfSprings (); ++i )
  {
    Information info = physics.getSpring( i );
    info.selectionne=false;
    info.scoreRecherche=0;
  }
  // effaceAfficheSelectionnes();

  for ( int i = 0; i < physics.numberOfSprings (); ++i )
  {//PVector location=new PVector();
    Information info = physics.getSpring( i );
    Noeud a = info.sujet;
    Noeud b = info.objet;
    if (b.uriCourte) {
      if (b.uriCourte.contains(_mySearch)) {
        info.selectionne=true;
        ajouteSelectionnes(info);
        console.log(b.position);
        //  position.x=b.position.x; //recupere la position de l'objet
        // position.y=b.position.y;
      }
    } else {
      console.log(b);
      console.log("n'a pas d'uriCourte");
    }
    if (a.uriCourte) {
      if (a.uriCourte.contains(_mySearch)) {
        ajouteSelectionnes(info);
        //console.log(a.uriCourte);
        a.couleur=color (255, 0, 0);
        console.log(a.position);
        // position.x=a.position.x; //recupere la position du sujet
        // position.y=a.position.y;
      }
    } else {
      console.log(a);
      console.log("n'a pas d'uriCourte");
    }
  }
  //initialiseZoom();
  /*
  zoom = 2;
   xo=xo-zoom*d-centroid.x();
   yo=yo-zoom*d-centroid.y();
   appliqueZoom();*/
  // xo = -centroid.x()-width/2;
  // yo = -centroid.y()-height/2;
  //appliqueZoom();
  //console.log(position.x);
  /*
 xo= -xo+position.x;
   yo=-yo+position.y;
   appliqueZoom();*/
  // translate( -xo, -yo );
  //  scale( centroid.z() );
  // translate( position.x, position.y );
}

void ajoute1pointRecherche(Information info) {
  ajouteSelectionnes(info);
  info.selectionne=true;
  info.scoreRecherche++;
};

void rechercheInfoComplexe(String _mySearchSujet, String _mySearchPropriete, String _mySerachObjet) {
  var mySearchSujet, mySearchPropriete, mySerachObjet =null;
  if (_mySearchSujet) {
    mySearchSujet=_mySearchSujet;
  }
  if (_mySearchPropriete) {
    mySearchPropriete=_mySearchPropriete;
  }
  if (_mySerachObjet) {
    mySerachObjet=_mySerachObjet;
  }
  console.log("recherche : "+mySearchSujet+" "+mySearchPropriete +" "+mySerachObjet);
  // HashMap<String,Integer> map = new HashMap<String,Integer>(); 
  HashMap<String, Integer> infosTrieesTemp=new HashMap<String, Integer>();
  ValueComparator comparateur = new ValueComparator(infosTrieesTemp);
  HashMap<String, Integer> infosTriees=new HashMap<String, Integer>();

  for ( int i = 0; i < physics.numberOfSprings (); ++i )
  {
    Information info = physics.getSpring( i );
    info.selectionne=false;
    info.scoreRecherche=0;
  }
  effaceAfficheSelectionnes();

  for ( int i = 0; i < physics.numberOfSprings (); ++i )
  {
    Information info = physics.getSpring( i );
    Noeud a = info.sujet;
    Noeud b = info.objet;
    String propriete=info.propriete;

    if ((mySearchSujet)&&(a.uriCourte)) {
      if (a.uriCourte==mySearchSujet) {
        ajoute1pointRecherche(info); //ajoute un pointRecherche
        info.scoreRecherche++ ; // supplémént un point si correspondance exacte
      } else if (a.uriCourte.contains(mySearchSujet)) {
        ajoute1pointRecherche(info);
      }
    }

    if ((mySearchPropriete)&&(propriete)) {
      if (propriete==mySearchPropriete) {
        ajoute1pointRecherche(info); //ajoute un pointRecherche
        info.scoreRecherche++ ; // supplémént un point si correspondance exacte
      } else if (propriete.contains(mySearchPropriete)) {
        ajoute1pointRecherche(info);
      }
    }

    if ((mySearchObjet)&&(b.uriCourte)) {
      if (b.uriCourte==mySearchObjet) {
        ajoute1pointRecherche(info); //ajoute un pointRecherche
        info.scoreRecherche++ ; // supplémént un point si correspondance exacte
      } else if (b.uriCourte.contains(mySearchObjet)) {
        ajoute1pointRecherche(info);
      }
    }

    // remplissage du tableaud'infos triées
    if (info.selectionne==true) {

      infosTrieesTemp.put(info.UUID, info.scoreRecherche);
      console.log(info.scoreRecherche);
      console.log (info);
    }

    /*
    if (b.uriCourte) {
     if (b.uriCourte.contains(mySearchSujet)||b.uriCourte.contains(mySearchPropriete)||b.uriCourte.contains(mySerachObjet)) {
     info.selectionne=true;
     ajouteSelectionnes(info);
     }
     } else {
     console.log(b);
     console.log("n'a pas d'uriCourte");
     }
     if (a.uriCourte) {
     if (a.uriCourte.contains(mySearchSujet)||a.uriCourte.contains(mySearchPropriete)||a.uriCourte.contains(mySerachObjet)) {
     ajouteSelectionnes(info);
     console.log(a.uriCourte);
     a.couleur=color (255, 0, 0);
     }
     } else {
     console.log(a);
     console.log("n'a pas d'uriCourte");
     }
     */
  }
  infosTriees.putAll(infosTrieesTemp);
  // console.log (infosTriees);
}

class ValueComparator implements Comparator<String> {
  Map<String, Integer> base;
  public ValueComparator(Map<String, Integer> base) {
    this.base = base;
  }

  public int compare(String a, String b) {
    if (base.get(a) >= base.get(b)) {
      return -1;
    } else {
      return 1;
    }
  }
}

