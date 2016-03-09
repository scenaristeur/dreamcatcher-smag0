import java.util.UUID;
import java.util.TreeMap;

// LES PREFIXES de output sont OK, ais revoir les prefixes de listeInfos . des objets + la creation des statements
ArrayList <Noeud>noeuds=new ArrayList();
ArrayList<Noeud> selectionnes=new ArrayList();
BufferedReader readerBuff;
//
final float NODE_SIZE = 5;  //node diameter 5
final float EDGE_LENGTH = 100;  //length of branching lines initially 10
final float EDGE_STRENGTH = .4;  //strength of spring (controls the amount of stretching possible) 0.4
final float SPACER_STRENGTH = 300;  // controls the amount of reo 300
float dMax;
float dMoy=0;
float dTot=0;
boolean connectionServeur=true;
boolean socketConnected=false;
Session session=new Session();

ParticleSystem       physics;
Smoother3D           centroid;
Particle             z;
Particle             anchor;
boolean              justStartingOut = false;
int                  SOMEdelay = 1000, 
i0 = 0;
StateButton          runStateButton;
StartPauseStopButton startPauseButton;
RestartButton        restartButton;
FichierButton        fichierButton;
boolean              locked  = false, 
running = false, 
genning = false;
int distancemin2noeuds=100;
float forceRessort=0.6;
float souplesseRessort=.1; //.2
float longueurRessort=120;
float massDefaut=10;
float facteurLongueurAttraction=1;

//ZOOM
Integer d = 40;
float xo;
float yo;
float zoom = 1;
float angle = 0;
float Ymin=0;
float Ymax=0;

//informations
ArrayList<Information> informations =new ArrayList();
ArrayList<Information> informationsSelectionnees=new ArrayList();

boolean demo=true;
String messageInterface;
boolean debug=true;
//int vitesse_update=100;
int noeud_update=0;


void setup() {
  size( 1000,600 );
  initialisation();
}


void draw() {
  background(#afd7e6); //  http://colorschemedesigner.com/csd-3.5/#3q11TezK6w0w0
  fill(0, 30);
  appliqueZoom();
  gestion_delai();
  gestion_boutons();
  gestion_translation();
  /* if (justStartingOut==false) {
   gestion_espacement();
   }*/
  checkInfosSelectionnees();
 // checkAttractionsAsupprimer();
  drawLines(); 
  drawNetwork();
  //drawParticules();

  if (justStartingOut)
  { 
    fill(0);
    text("Click here to update", -130, -65);
    text("Cliquez ici, dans l'espace de travail, pour actualiser", -130, -50);
    noLoop();
    justStartingOut = false;
  }
  if (messageInterface!=null) {
    text(messageInterface, -130, -65);
  }
}

void drawParticules() {
  noStroke();
  if (noeud_update< physics.numberOfParticles ()) {
    for (k=0; k<5; k++) { // update de 10 points à partir de noeud_update
      Particle particule= physics.getParticle( noeud_update );
      if (particule) {

        particule.draw();
      }
      noeud_update++;
      // console.log(noeud_update);
    }
  } else {
    noeud_update=0;
  }
}

Boolean rechercheConnectionServeur() {
  return this.connectionServeur;
}
void checkAttractionsAsupprimer(int facteurLongueurAttraction) {
  ArrayList<Attraction> attractionsASupprimer=new ArrayList();
  for (int n=0; n<physics.attractions.size (); n++) {
    Attraction attractionTemp = physics.attractions.get(n);
    Noeud a=attractionTemp.one;
    Noeud b = attractionTemp.b;
    float d=dist(a.position.x, a.position.y, a.position.z, b.position.x, b.position.y, b.position.z);

    if (d>distancemin2noeuds*30) { 
      attractionsASupprimer.add(n);
    }
  }
  
  for (Attraction a : attractionsASupprimer) {
    physics.removeAttraction(a);
 // console.log(  physics.attractions.size ());
  }
}

/*
Récupérer les variables de l'url
http://stackoverflow.com/questions/827368/using-the-get-parameter-of-a-url-in-javascript
Url = {
    get get(){
        var vars= {};
        if(window.location.search.length!==0)
            window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value){
                key=decodeURIComponent(key);
                if(typeof vars[key]==="undefined") {vars[key]= decodeURIComponent(value);}
                else {vars[key]= [].concat(vars[key], decodeURIComponent(value));}
            });
        return vars;
    }
};

Example The url ?param1=param1Value&param2=param2Value can be called like:

Url.get.param1 //"param1Value"
Url.get.param2 //"param2Value"


Source de fichiers TTL : https://stash.csiro.au/projects/EIS/repos/pizza-skos/browse/pizza.ttl
http://webdam.inria.fr/paris/yd_relations.ttl

http://www.iro.umontreal.ca/~lapalme/ift6281/RDF/
*/
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

void keyPressed()
{  
  if (key == CODED) {
    if (keyCode ==UP) {
      zoomIn();
    } else if (keyCode == DOWN) {
      zoomOut();
    } else if (keyCode == RIGHT) {
      angle += .03;
    } else if (keyCode == LEFT) {
      angle -= .03;
    }
  }
  if (key == ' ') {
    initialiseZoom();
  }

  if ( key == 'c' )  //clears screen and resets the script
  {
    initialize();
    loop();
    i0 = 0;
    running = true;
    return;
  }
    if ( key == 'e' )  //clears screen and resets the script
  {
   gestion_espacement();
}
  
    if ( key == 'n' )  //n create new graphe
  {
    demo=false;
  //  messageInterface="Glissez le bouton \"Particule\" dans l'espace de travail pour créer une nouvelle particule";
    initialize();
   // initialise_defaut();
    initialiseZoom();
    loop();
    i0 = 0;
    running = true;
    return;
  }
      if ( key == 'b' )  //n create new graphe
  {
    demo=false;
  //  messageInterface="Glissez le bouton \"Particule\" dans l'espace de travail pour créer une nouvelle particule";
    initialize();
    initialiseZoom();
    loop();
    i0 = 0;
    running = true;
    return;
  }
      if ( key == 'd' )  //n afficher le graphe de démo
  {
    demo=true;
    initialize();
    loop();
    i0 = 0;
    running = true;
    return;
  }

  if (key == 's')   //saves a jpeg of the screen when the s key is pressed
  {
    saveFrame ("nodes-####.jpg");
  }
  //if (key == 'r') pdfoutput = true;
}

void mouseDragged( ) {
  xo = xo +(mouseX - pmouseX);
  yo = yo+(mouseY - pmouseY);
}



void mousePressed()
{ //println("mousePressed()");
  i0 = 0;
console.log(mouseX+" "+mouseY+" " +width+" "+height);
  if (runStateButton.over())
  {
    running = !running;
    if (running)
    {
      loop();
      return;
    } else
    { 
      i0 = SOMEdelay; // let draw() put us to sleep
      return;
    }
  }    

  if (startPauseButton.over())    
  {
    genning = !genning;
    if (genning)
    { 
      running = true;
      loop();
    }  
    if (!running)
    { 
      running = true;
      i0 = SOMEdelay;
      loop();
    }  
    return;
  }
/*
Gerer differemment l'ouverture de fichiers
  if (fichierButton.over())    
  {
    genning = !genning;
    if (genning)
    { 
      println("fichier button genning");
      selectInput("Select a file to process:", "fileSelected");

      running = true;
      loop();
    }  
    if (!running)
    { 
      println("fichier button running");
      //  running = true;
      //  i0 = SOMEdelay;
      loop();
    }  
    return;
  }
*/
  if (restartButton.over())
  {
    physics = new ParticleSystem( 0, 1.0 );
    centroid = new Smoother3D( 0.8 );
    initialize();
    if (!running)
    { 
      running = true;
      i0 = SOMEdelay;
      loop();
    }  
    return;
  }  

  // addNode();

  running = true;
  loop();
}  
class Noeud extends Particle {

  String UUID;
  String uriCourte;
  String prefix;
  color couleur=color(100, 100, 100);

  Noeud (float m) {
    super(m);
    UUID=generateUUID();
  }


  //SETTER GETTER
  void setUriCourte(String _uriCourte) {
    this.uriCourte=_uriCourte;
  }
  void getUriCourte() {
    return this.uriCourte;
  }
  void setPrefix(String _prefix) {
    this.prefix=_prefix;
  }
  void getPrefix() {
    return this.prefix;
  }
  void setUUID(String _UUID) {
    this.UUID=_UUID;
  }
  void getUUID() {
    return this.UUID;
  }
  void setCouleur(color _couleur) {
    this.couleur=_couleur;
  }
  void getCouleur() {
    return this.couleur;
  }


  void update() {
    for ( int i = 0; i < physics.numberOfParticles (); ++i )
    {
      Particle b = physics.getParticle( i );
      float d=dist(this.position.x, this.position.y, this.position.z, b.position.x, b.position.y, b.position.z);
      if (b!=this) {
        if (d<=0) {
          b.position.x++;
        }
        if (d<distancemin2noeuds) { 
          //   d=dist(this.position.x, this.position.y, this.position.z, b.position.x, b.position.y, b.position.z);
          physics.makeAttraction( this, b, -SPACER_STRENGTH*this.mass0*2, d+longueurRessort+this.mass0*2 );
          //  console.log("Particule : "+physics.numberOfParticles()+"\t Springs : "+physics.numberOfSprings()+"\t Attractions : "+physics.attractions.size());

        //    physics.makeAttraction( this, b, -SPACER_STRENGTH*2, d*2+longueurRessort+this.mass0 );
        }
      }
    }
  }
}

void sauvegarde() {
  console.log("fonction sauvegarde");
  String[]listeInfos=new String[informations.size()];
  for (int i=0; i<informations.size (); i++) {
    Information info=informations.get(i);

    /*    String data="<Information"+i+"> <sujet> \""+info.sujet.uriCourte+"\" , \n"+       
     "<Information"+i+"> <propriete> \""+info.propriete+"\" , \n"+
     "<Information"+i+"> <objet> \""+info.objet.uriCourte+"\" .";
     */

    // ajout du préfix local si pas de préfix
    String sujetWithPrefix=info.sujet.uriCourte;
    String proprieteWithPrefix=info.propriete;
    String objetWithPrefix=info.objet.uriCourte;
    if (!info.sujet.uriCourte.contains(":")) {
      if (info.sujet.prefix!=null) {
        sujetWithPrefix=info.sujet.prefix+info.sujet.uriCourte;
      } else {
        sujetWithPrefix=":"+info.sujet.uriCourte;
      }
    }

    if (!info.propriete.contains(":")) {
      if (info.prefix!=null) {
        proprieteWithPrefix=info.prefix+info.propriete;
      } else {
        proprieteWithPrefix=":"+info.propriete;
      }
    }
    if (info.objet.uriCourte) {
      if (!info.objet.uriCourte.contains(":")) {
        if (info.objet.prefix!=null) {
          objetWithPrefix=info.objet.prefix+info.objet.uriCourte;
        } else {
          objetWithPrefix=":"+info.objet.uriCourte;
        }
      }
    }




    String data=sujetWithPrefix+" "+proprieteWithPrefix+" "+objetWithPrefix+" . \n";

    console.log(data);
    listeInfos[i]=data;
  }
  //  String[]listeSauvegarde=listeNoeuds.concat( listeInfos);
  saveStrings("smag0/sauve/last.txt", listeInfos);
  String nomFichier= choisiNomLocalStorage();
  saveStrings("smag0/sauve/"+nomFichier+".txt", listeInfos);
  String lines[] = loadStrings("smag0/sauve/"+nomFichier+".txt");

  console.log("there are " + lines.length + " lines");
  for (int i=0; i < lines.length; i++) {
    console.log(lines[i]);
  }
  String output="@prefix : <http://smag0.blogspot.fr/tempPrefix#> . \n";
  output+="@prefix owl: <http://www.w3.org/2002/07/owl#> . \n";
  output+="@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> . \n";
  output+="@prefix xml: <http://www.w3.org/XML/1998/namespace> . \n";
  output+="@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . \n";
  output+="@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> . \n";
  output+="@prefix smag: <http://smag0.blogspot.fr/tempPrefix#> . \n";
  output+="@base <http://smag0.blogspot.fr/tempPrefix> . \n";
  output+="<http://smag0.blogspot.fr/tempPrefix> rdf:type owl:Ontology ;  \n";
  output+="                    owl:versionIRI <http://smag0.blogspot.fr/tempPrefix/1.0.0> . \n";
  output+=" \n";
  output+="owl:Class rdfs:subClassOf owl:Thing .  \n";
  output+="owl:Ontology rdf:type owl:Thing .  \n";

  /*Code OK
   @prefix : <http://www.smag0/tempPrefix#> .
   @prefix : <http://www.smag0/tempPrefix#> .
   @prefix owl: <http://www.w3.org/2002/07/owl#> .
   @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
   @prefix xml: <http://www.w3.org/XML/1998/namespace> .
   @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
   @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
   @base <http://www.smag0/tempPrefix> .
   <http://www.smag0/tempPrefix> rdf:type owl:Ontology ; 
   owl:versionIRI <http://www.smag0/tempPrefix/1.0.0> .
   
   :Az rdfs:subClassOf :Personne .
   :Cz rdfs:subClassOf :Personne .
   :Qz rdf:type :Personne .
   */


  for (String str : listeInfos)
  { 
    // LES PREFIXES de output sont OK, ais revoir les prefixes de listeInfos . des objets + la creation des statements
    output=output+str;
  }
  //output+="###  Generated by DreamCatcher (version 1.0.0) http://smag-smag0.rhcloud.com/DreamCatcher/ \n";
  //System.out.println(output);
  document.getElementById("inputTextToSave").value =output;
  document.getElementById("inputFileNameToSaveAs").value =nomFichier;
}


void initnoeuds() {
  noeuds.clear();
  selectionnes.clear();
}
void data2Xml(String _dataString) {
  String dataString=_dataString;
  xml =  parseXML(dataString);
  createTableauxXml(xml);
}

void ttl2Xml(String _dataString) {
  HashMap<String, String> prefixes=new HashMap();
  String base=new String();
  console.log(_dataString);
  String[] lignes=_dataString.split("\n");
  String sujet=new String();
  String propriete=new String();
  String objet=new String();
  String separateur=new String();
  for (String ligne : lignes) {

    if (ligne.startsWith("@prefix ")) {
      String[] lignePrefix=ligne.split("@prefix ");
      String[] lignePrefixCuted=lignePrefix[1].split(": ");
      String prefix=trim(lignePrefixCuted[0]);
      String vpWithPoint=trim(lignePrefixCuted[1]);
      String valeurPrefix = trim(vpWithPoint.substring(0, vpWithPoint.length-1));
      if (prefix.equals("")) {
        prefix=":";
      }
      prefixes.put(prefix, valeurPrefix);
      // console.log(prefixes);
      //  console.log("PREFIX :\n\t "+prefix+"\t"+valeurPrefix);
    } else if (ligne.startsWith("@base ")) {
      // console.log(ligne);
      base=trim(ligne.split("@base ")[1]);
      base=trim(base.substring(0, base.length-1));
      // console.log("BASE => "+base);
    } else {
      ligne=trim(ligne);
      String[] ligneSplit=ligne.split(" ");
      console.log(ligneSplit.length);
      console.log(ligneSplit);
      Boolean ligneValide=false;
      switch(ligneSplit.length) { 
      case 5:
        console.log("A gérer, import avec graphe ?");
        ligneValide=false;
        break;
      case 4:
        sujet=ligneSplit[0];
        propriete=ligneSplit[1];
        objet=ligneSplit[2];
        separateur=ligneSplit[3];
        ligneValide=true;
        break;
      case 3 :
        if (separateur=";") {
          propriete=ligneSplit[0];
          objet=ligneSplit[1];
          separateur=ligneSplit[2];
          ligneValide=true;
        } else {
          ligneValide=false;
          console.log("PB avec ligneSplit 3");
        }
        break;
      case 2:
        if (separateur=",") {
          objet=ligneSplit[0];
          separateur=ligneSplit[1];
          ligneValide=true;
        } else {
          ligneValide=false;
          console.log("PB avec ligneSplit2");
        }
        break;
      case 1:
        ligneValide=false;
        console.log("un seul champ pour ligneSplit -> pas d'info");
        break;
      default :
        ligneValide=false;
        console.log("pb de ligne");
        //   sketch.ajouteInformation("smag:"+sujet, "rdf:type", "smag:"+message);
      }

      if (ligneValide) {
        console.log("Ajoute => "+sujet+" "+propriete+" "+objet);
        ajouteInformation(sujet,propriete,objet);
      }
      ligneValide=false;
    }
  }
  // fin du traitement des lignes
  //--> traitement des maps créées
  for (String key : prefixes.keySet ())
  {
    console.log(key + " -> " + prefixes.get(key));
  }
  console.log("BASE => "+base);
}

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

class Sujet extends Particle {

  String UUID;
  String uriCourte;
  String prefix;
  color couleur=color(100, 100, 100);
  Boolean literal=false;

  Sujet (float m) {
    super(m);
    UUID=generateUUID();
  }


  //SETTER GETTER
  void setUriCourte(String _uriCourte) {
    this.uriCourte=_uriCourte;
  }
  void getUriCourte() {
    return this.uriCourte;
  }
  void setPrefix(String _prefix) {
    this.prefix=_prefix;
  }
  void getPrefix() {
    return this.prefix;
  }
  void setUUID(String _UUID) {
    this.UUID=_UUID;
  }
  void getUUID() {
    return this.UUID;
  }
  void setCouleur(color _couleur) {
    this.couleur=_couleur;
  }
  void getCouleur() {
    return this.couleur;
  }

void draw(){
  this.update();
  
      ellipse( this.position.x, this.position.y, this.mass0, this.mass0 );
     // console.log("draw "+this.position.x+" "+ this.position.y);
}

  void update() {
    for ( int i = 0; i < physics.numberOfParticles (); ++i )
    {
      Particle b = physics.getParticle( i );
      float d=dist(this.position.x, this.position.y, this.position.z, b.position.x, b.position.y, b.position.z);
      if (b!=this) {
        if (d<=0) {
          b.position.x++;
        }
        if (d<distancemin2noeuds) { 
          d=dist(this.position.x, this.position.y, this.position.z, b.position.x, b.position.y, b.position.z);
          physics.makeAttraction( this, b, -longueurRessort*this.mass0*2, d+longueurRessort+this.mass0*2 );
        }
      }
    }
  }
}

Sujet newSujet(String newPrefix,String newUriCourte){
    Sujet sujetTemp=new Sujet();

  for (i=0; i<physics.numberOfParticles (); i++) {
    Sujet sujetPropose=physics.getParticle( i );
    //   console.log("comparaison avec : "+noeudPropose.uriCourte);
    if (sujetPropose.uriCourte) {
      if (sujetPropose.uriCourte.equals(newUriCourte)) {
        sujetTemp=sujetPropose;
        //     console.log("noeud connu "+noeudPropose.uriCourte);
      }
    }
  }
  if (sujetTemp.uriCourte==null) {
    sujetTemp=new Sujet(massDefaut);
    sujetTemp.setUriCourte(newUriCourte);
    physics.particles.add(sujetTemp);
      console.log("noeud créé "+sujetTemp.uriCourte);
  }
  i0=0;
  sujetTemp.draw();
  
  return sujetTemp;
}

void populateTest() {
  // commenter/decommenter pour tester des jeux de données
  populateTestSmag();
  //  populateTestDGFIP();
}

void populateTestDGFIP() {
  ajouteInformation("smag:DGFIP", "rdf:type", "smag:Organisation");
  ajouteInformation("smag:DGFIP", "rdf:label", "Direction Générale des Finances Publiques");
  ajouteInformation("smag:DGFIP", "smag:sigle", "DGFIP");
  ajouteInformation("smag:ProjetTestDGFIP", "rdf:type", "smag:Projet");
  ajouteInformation("smag:ProjetTestDGFIP", "smag:demandeur", "smag:DGFIP");
  ajouteInformation("smag:ProjetTestDGFIP", "smag:developpeur", "David");
}


void populateTestSmag() {
  /*
  ajouteInformation("owl:Class", "rdfs:subClassOf", "owl:Thing");
  ajouteInformation("smag:Acteur", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Environnement", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Competence", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Organisation", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Etape", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Evénement", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Action", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Role", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("foaf:Person", "rdfs:subClassOf", "owl:Class");
    ajouteInformation("smag:Projet", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Acteur", "rdf:type", "foaf:Person");
  ajouteInformation("Smag0", "rdf:type", "smag:Projet");
  ajouteInformation("Smag0", "smag:developpeur", "David");
  ajouteInformation("Smag0", "smag:demandeur", "Simon");
  ajouteInformation("Smag0", "smag:description", "Un robot qui range ma chambre");
  ajouteInformation("David", "rdf:type", "foaf:Person");
  ajouteInformation("David", "rdf:type", "smag:Acteur");
  ajouteInformation("David", "rdf:type", "Individual");
  ajouteInformation("Simon", "rdf:type", "foaf:Person");
  ajouteInformation("Simon", "smag:filsDe", "David");
  ajouteInformation("Smag0", "hasPart", "smag:PcduinoBot");
  ajouteInformation("Smag0", "hasPart", "smag:SpheroBot");
  ajouteInformation("Smag0", "hasPart", "smag:AppartDeDav");
  ajouteInformation("smag:PcduinoBot", "rdf:type", "smag:Robot");
  ajouteInformation("smag:SpheroBot", "rdf:type", "smag:Robot");
  ajouteInformation("smag:PcduinoBot", "smag:developpeur", "David");
  ajouteInformation("smag:SpheroBot", "smag:developpeur", "David");
  ajouteInformation("David", "smag:habite", "smag:AppartDeDav");
  ajouteInformation("smag:AppartDeDav", "hasPart", "smag:CuisineDeDav");
  ajouteInformation("smag:AppartDeDav", "rdf:type", "smag:Appartement");
  ajouteInformation("smag:Batiment", "rdf:subClassOf", "smag:Environnement");
  ajouteInformation("smag:Appartement", "rdf:subClassOf", "smag:Batiment");
  ajouteInformation("smag:Piece", "rdf:subClassOf", "smag:Environnement");
  ajouteInformation("smag:Batiment", "hasPart", "smag:Piece");
  ajouteInformation("smag:CuisineDeDav", "rdf:type", "smag:Piece");
  ajouteInformation("smag:SalonDeDav", "rdf:type", "smag:Piece");
  ajouteInformation("smag:ChambreDeSimon", "rdf:type", "smag:Piece");
  ajouteInformation("smag:ChambreDeSimon", "rdf:type", "smag:Piece");
  ajouteInformation("smag:ChambreDeLucie", "rdf:type", "smag:Piece");
  ajouteInformation("smag:SDBDav", "rdf:type", "smag:Piece");
  ajouteInformation("smag:ToilettesDav", "rdf:type", "smag:Piece");
  ajouteInformation("smag:CouloirDav", "rdf:type", "smag:Piece");
  ajouteInformation("smag:EntréeDav", "rdf:type", "smag:Piece");
  ajouteInformation("Simon", "smag:occupe", "smag:ChambreDeSimon");
  ajouteInformation("smag:PcduinoBot", "rdf:type", "smag:Projet");
  ajouteInformation("smag:SpheroBot", "rdf:type", "smag:Projet");

  ajouteInformation("smag:AppartDeDav", "hasPart", "smag:CuisineDeDav");
  ajouteInformation("smag:AppartDeDav", "hasPart", "smag:CouloirDav");
  ajouteInformation("smag:AppartDeDav", "hasPart", "smag:SalonDeDav");
  ajouteInformation("smag:AppartDeDav", "hasPart", "smag:ChambreDeLucie");
  ajouteInformation("smag:AppartDeDav", "hasPart", "smag:ChambreDeSimon");
  ajouteInformation("smag:AppartDeDav", "hasPart", "smag:SDBDav");
  ajouteInformation("smag:AppartDeDav", "hasPart", "smag:ToilettesDav");
  ajouteInformation("smag:AppartDeDav", "hasPart", "smag:CouloirDav");

  ajouteInformation("smag:EntréeDav", "smag:hasDoor", "smag:CouloirDav");
  ajouteInformation("smag:EntréeDav", "smag:hasDoor", "smag:SalonDeDav");
  ajouteInformation("smag:EntréeDav", "smag:hasDoor", "smag:CuisineDeDav");
  ajouteInformation("smag:EntréeDav", "smag:hasDoor", "smag:HallImmeuble");
  ajouteInformation("smag:CouloirDav", "smag:hasDoor", "smag:ChambreDeLucie");
  ajouteInformation("smag:CouloirDav", "smag:hasDoor", "smag:ChambreDeSimon");
  ajouteInformation("smag:CouloirDav", "smag:hasDoor", "smag:SDBDav");
  ajouteInformation("smag:CouloirDav", "smag:hasDoor", "smag:ToilettesDav");

  ajouteInformation("smag:UnePieceDeLego", "rdf:type", "owl:Thing");
  ajouteInformation("smag:UnePieceDeLego", "rdf:type", "smag:Jeu");
  ajouteInformation("smag:UnePieceDeLego", "smag:aPourProprietaire", "Simon");
  ajouteInformation("smag:Jeu", "rdfs:subClassOf", "owl:Thing");
  ajouteInformation("smag:UnePieceDeLego", "smag:emplacementDefaut", "smag:BoiteDeLego");
  ajouteInformation("smag:BoiteDeLego", "smag:emplacementDefaut", "smag:ChambreDeSimon");
  ajouteInformation("smag:BoiteDeLego", "rdf:type", "owl:Thing");

  ajouteInformation("Smag0", "smag:hasPart", "smag:SmagOrganisation");
  ajouteInformation("smag:SmagOrganisation", "rdf:type", "smag:Organisation");
  
  
  
    ajouteUneClasse("Competence");
  ajouteUneClasse("Organisation");
  ajouteUneClasse("Role");*/
}

void owl2xml(String owlFile) {
  //deuxième méthode pour charger un owl/xml
  xml = new XMLElement(this, owlFile);
  createTableauxXml(xml);
}


void createTableauxXml(XML[] _xml) {
  console.log(_xml.getChildCount());
  if (debug) {
    int enfants = _xml.getChildCount();
    console.log(enfants+" enfants dans le fichier chargé");
    for (int i = 0; i < enfants; i++) {

      XMLElement kid = _xml.getChild(i); 
      // console.log(kid.getName());
      console.log(kid);
    }
  }
  XML[] ontologie=_xml.getChildren("owl:Ontology");
  XML[] classes=_xml.getChildren("owl:Class");
  XML[] individuals=_xml.getChildren("owl:NamedIndividual");
  XML[] proprietes=_xml.getChildren("owl:ObjectProperty");
  XML[] comments=_xml.getChildren("#comment");

  Xml2Noeuds(ontologie, "ontologie");
  Xml2Noeuds(classes, "classe");
  Xml2Noeuds(individuals, "individual");
  Xml2Noeuds(proprietes, "propriete");
  Xml2Noeuds(comments, "comment");
}

void Xml2Noeuds(XML[] _datas, String _type) {
  XML datas=_datas;
  String type=_type;
  console.log(type);
  console.log(datas);

  for (int i = 0; i < datas.length; i++) {

    XML data = datas[i];
    if (type.equals("individual")) {
      //  console.log(data);
      String about =data.attributes[0].value;
      String[] easyCut  = split(about, '#'); 
      String sujetPrefix=easyCut[0];
      String sujetLocalName=easyCut[1];
      //  console.log("récupération des propriétés de "+localName);
      //récupération des propriétés 
      XML[]proprietes=data.getChildren();
      // console.log(children);
      for (int j=0; j<proprietes.length; j++) {
        XML [] proprieteXml=proprietes[j];
        //  console.log(proprieteXml);
        String proprieteString=proprieteXml.fullName;
        //  console.log("prop ="+proprieteString);
        if (proprieteString) {
          if (proprieteXml.attributes[0]) {
            String objetUri= proprieteXml.attributes[0].value;
            //   console.log(proprieteXml.fullName+" "+objetUri);
            String[] easyCut  = split(objetUri, '#'); 
            String objetPrefix=easyCut[0];
            String objetLocalName=easyCut[1];
            ajouteInformation(sujetLocalName, proprieteString, objetLocalName);
          } else {
            console.log("descendre encore d'un niveau");
          }
          //  console.log("--->"+child.attributes[0].value);
        } else {
          //  console.log("fullname non trouvé "+child);
        }
      }
      //   console.log(localName);
      /*   int nx=random(width);
       int ny = random(height);
       Noeud noeud=new Noeud(localName, nx, ny);
       noeud.prefix=prefix;
       noeud.type=type;
       noeuds.add(noeud);*/
      /*  Noeud  nouveauNoeud=new Noeud(massDefaut);
       nouveauNoeud.setUriCourte(localName);
       nouveauNoeud.setPrefix(prefix);
       physics.particles.add(nouveauNoeud);*/
    }

    // console.log(type);
    // récupérer les liens de chaque Noeud
    /*  if (type.equals("individual")) {
     console.log("-------------------------------------------------------Individuel" +localName);
     XML[]children=data.getChildren();
     for (int j=0; j<children.length; j++) {
     XML [] child=children[j];
     if (child.fullname) {
     console.log(child.fullname);
     console.log(child);
     //  console.log("--->"+child.attributes[0].value);
     } else {
     //  console.log("fullname non trouvé "+child);
     }
     }
     }
     */

    /*
    // get children
     if (type.equals("propriete")) {
     console.log("-------------------------------------------------------propriété" +localName);
     XML[]children=data.getChildren();
     for (int j=0; j<children.length; j++) {
     XML [] child=children[j];
     if (child.fullname) {
     console.log(child.fullname);
     //  console.log("--->"+child.attributes[0].value);
     } else {
     //  console.log("fullname non trouvé "+child);
     }
     }
     }*/
  }
}

void zoomIn() {
  zoom += 1; //.10
  xo=xo-zoom*d;
  yo=yo-zoom*d;
}

void zoomOut() {
  zoom -= 1; //.10
  xo=xo+zoom*d;
  yo=yo+zoom*d;
}

void initialiseZoom() {
  d = 40;
  zoom = 1;
  angle = 0;
  xo = 0;
  yo = 0;
}

void appliqueZoom() {
  translate(xo, yo);
  scale(zoom);
  rotate(angle);
}
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




void initialisation() {  
  // init_noeuds();
  smooth();
  //  frameRate(10);
  strokeWeight(1);
  ellipseMode( CENTER );      

  physics = new ParticleSystem( 0, 1.0 );
  centroid = new Smoother3D( 0.8 );
  initialize();

  runStateButton   = new StateButton         ( -5, -5, 20, 255, 153, 240); // basecolor, highlightcolor, backgroundcolor
  startPauseButton = new StartPauseStopButton(  2, 182, 16, 255, 153, 240); // basecolor, highlightcolor, backgroundcolor
  restartButton    = new RestartButton       ( 22, 182, 16, 255, 153, 240); // basecolor, highlightcolor, backgroundcolor
  fichierButton = new FichierButton(  2, 202, 16, 255, 153, 240); // basecolor, highlightcolor, backgroundcolor

  /* Gérer différemment le scroll
   wheel = new MouseWheelEventDemo();
   */
}


/*
void init_noeuds() {
 noeuds.clear();
 selectionnes.clear();
 }*/

void initialize() //this function clears the screen and resets function
{
  //  noeuds.clear();
  physics.clear();
  informations =new ArrayList();
  //effaceAfficheSelectionnes();
 // effaceActivite();
  centroid.setValue( 0, 0, 1.0 );

  if (demo) {
    populateTest();
  }
}
void initialise_defaut() {
  ajouteInformation("smag:Environnement", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("owl:Class", "rdfs:subClassOf", "owl:Thing");
  ajouteInformation("smag:Acteur", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Competence", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Organisation", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Etape", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Evénement", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Action", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Role", "rdfs:subClassOf", "owl:Class");
  ajouteInformation("smag:Humain", "rdfs:subClassOf", "smag:Acteur");
  ajouteInformation("smag:Robot", "rdfs:subClassOf", "smag:Acteur");
  ajouteInformation("smag:Projet", "rdfs:subClassOf", "smag:Organisation");
  ajouteInformation("smag:DreamCatcher", "rdf:type", "smag:Projet");
  ajouteInformation("smag:David", "smag:developpeurDe", "smag:DreamCatcher");
  ajouteInformation("smag:David", "rdf:type", "smag:Humain");
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
}

void gestion_delai() {
  if (i0>SOMEdelay)
  { 
    running = false;
    noLoop();
  }
  i0++;
  if (i0 < SOMEdelay)
  { 
    physics.tick( 1.0 ); //within physics library, creates a counter to continue to make more nodes
    if ( physics.numberOfParticles() > 1 )
      updateCentroid();
    centroid.tick();
    //  gestion_espacement();
  }
}

void gestion_boutons() {
  // Sets the red indicator
  runStateButton.display( running?runStateButton.STATEon:runStateButton.STATEoff, SOMEdelay-i0 ); // Tempered by how many cycles until we go to sleep

  // If we're generating nodes, show the pause icon. Otherwise show the run icon.
  startPauseButton.display( genning?startPauseButton.SHOWpause:startPauseButton.SHOWrun ); 
  fichierButton.display( genning?fichierButton.SHOWpause:fichierButton.SHOWrun ); 

  restartButton.display();
}

void gestion_translation() {
  translate( width/2, height/2 );
  scale( centroid.z() );
  translate( -centroid.x(), -centroid.y() );
}

void updateCentroid() // whenever system is reorganized or scaled, node positions have to be updated
{
  float xMin =  999999.9, //Float.POSITIVE_INFINITY,
  xMax = -999999.9, //Float.NEGATIVE_INFINITY,
  yMin =  999999.9, //Float.POSITIVE_INFINITY,
  yMax = -999999.9; //Float.NEGATIVE_INFINITY;

  for ( int i = 0; i < physics.numberOfParticles (); ++i )
  {
    Particle p = physics.getParticle( i );
    xMax = max( xMax, p.position.x );
    xMin = min( xMin, p.position.x );
    yMin = min( yMin, p.position.y );
    yMax = max( yMax, p.position.y );
  }

  float deltaX = xMax-xMin;
  float deltaY = yMax-yMin;
  if ( deltaY > deltaX )
    centroid.setTarget( xMin + 0.5*deltaX, yMin +0.5*deltaY, height/(deltaY+50) );
  else
    centroid.setTarget( xMin + 0.5*deltaX, yMin +0.5*deltaY, width/(deltaX+50) );
}

void drawNetwork()
{ //println("drawNetwork()");
  // finds a node within the system and draws a new node branching from that point
  noStroke();
 // if(physics.attractions.size()<(physics.numberOfParticles ()*10)){
    // facteurLongueurAttraction=1;
  if (noeud_update< physics.numberOfParticles ()) {
    for (k=0; k<10; k++) { // update de 10 noeuds à partir de noeud_update
      checkAttractionsAsupprimer();
      Noeud noeud= physics.getParticle( noeud_update );
      if (noeud) {
        noeud.update();
      }
      noeud_update++;
      // console.log(noeud_update);
    }
  } else {
    noeud_update=0;
    
  }

/*  }else{
    checkAttractionsAsupprimer(facteurLongueurAttraction);
    facteurLongueurAttraction=facteurLongueurAttraction+10;
  }*/

  for ( int i = 0; i < physics.numberOfParticles (); ++i )
  {
    Particle v = physics.getParticle( i );

    noStroke ();
    fill(100, 75);
    ellipse( v.position.x, v.position.y, NODE_SIZE+15, NODE_SIZE +15);
    fill(150, 30);
    ellipse( v.position.x, v.position.y, NODE_SIZE+55, NODE_SIZE +55);
    //stroke (255,0,0);
    if (v.mass0<4*NODE_SIZE) {
      fill(0, 30);
      ellipse( v.position.x, v.position.y, v.mass0, v.mass0 );
      fill(0, 150);
    } else {
      fill(255, 10);
      stroke(1); 
      ellipse( v.position.x, v.position.y, v.mass0, v.mass0 );
      fill(#1F007b);
    }
    stroke(0);
    strokeWeight (.75);
    for (int k=0; k<informationsSelectionnees.size (); k++) {
      Information infoK=informationsSelectionnees.get(k);
      if ((v==infoK.sujet)||(v==infoK.objet)) {
        if (v==infoK.sujet) {
          fill(#e62514); // http://colorschemedesigner.com/csd-3.5/#43400GZQFw0w0
          strokeWeight (1);
          /*   stroke(#D7D700);
           strokeWeight (2);*/
        } else {
          fill(#2514e6); //00D7D7
          /*   stroke(#00D700);
           strokeWeight (2);*/
        }
        // stroke(4);


        ellipse( v.position.x, v.position.y, v.mass0+NODE_SIZE+15, v.mass0+NODE_SIZE +15);
        // strokeWeight (5);
      }
    }
    if (v.uriCourte!=null) {
      if (v.uriCourte.equals("Methode")) {
        fill(245, 245, 0);
      }
      text(v.uriCourte, v.position.x+NODE_SIZE+15/2, v.position.y);
    }
  }

  // draw branching lines that connect each new node


  beginShape( LINES );
  for ( int i = 0; i < physics.numberOfSprings (); ++i )
  {
    Spring e = physics.getSpring( i );
    Particle a = e.getOneEnd();
    Particle b = e.getTheOtherEnd();
    vertex( a.position.x, a.position.y );
    vertex( b.position.x, b.position.y );
  }
  endShape();
}

// drawing connection lines based on a distance threshold for secondary organizations
void drawLines()
{ //println("drawLines()");

  String propriete=null;
  PVector milieuSens=new PVector();
  for (int i=0; i<physics.springs.size (); i++) {
    Spring spring=physics.getSpring(i );
    // PVector milieu=new PVector((spring.one.position.x+spring.b.position.x)/2,(spring.one.position.y+spring.b.position.y)/2); 
    milieuSens=new PVector((spring.one.position.x*3+spring.b.position.x)/4, (spring.one.position.y*3+spring.b.position.y)/4);

    propriete=spring.propriete;
    if (propriete!=null) {
      if (propriete.equals("rdf:type")) {
        fill(#f8003a, 80); //http://colorschemedesigner.com/csd-3.5/#43400GZQFw0w0
      } else
        if (propriete.equals("xhv:next")) {
        fill(0, 255, 0, 80);
      } else
        if (propriete.equals("dc:hasPart")) {
        fill(0, 0, 255, 80);
      } else
      {
        fill(0, 80);
      }
      for (int k=0; k<informationsSelectionnees.size (); k++) {
        Information infoK=informationsSelectionnees.get(k);
        if ((spring.one==infoK.sujet)&&(spring.b==infoK.objet)) {
          stroke(2);
          fill(#3b9f00); //http://colorschemedesigner.com/csd-3.5/#43400GZQFw0w0 // 5bf500
        }
      }
      // noStroke();
      ellipse(milieuSens.x, milieuSens.y, 3, 3);
      //  stroke(1);
      text(propriete, milieuSens.x, milieuSens.y);
      // fill(0, 80);
    }
  }
}

void gestion_espacement() {
  for ( int i = 0; i < physics.numberOfParticles (); ++i )
  {
    Particle b = physics.getParticle( i );
    b.update();
  }
}
/*
void makeEdgeBetween( Particle a, Particle b ) //creates a spring between node and new node
 {//force damping, longueur
 // physics.makeSpring( a, b, EDGE_STRENGTH, EDGE_STRENGTH, random(25, 40));
 physics.makeSpring( a, b, 0.1, .02, 50);
 }*/
/*
void makeEdgeBetween( Particle a, Particle b, String propriete) //creates a spring between node and new node
 {//force damping, longueur
 //OK de base (référence) physics.makeSpring( a, b, 0.3, .2, 60, propriete);
 physics.makeSpring( a, b, forceRessort, souplesseRessort, longueurRessort, propriete);
 }*/
/*
void ajouteStatement(String sujet, String propriete, String objet) {
 console.log ( sujet+"..."+propriete+"..."+ objet);
 Particle p=null;
 Particle q=null;
 if (!noeuds.contains(sujet)) {
 noeuds.add(sujet);
 p = physics.makeParticle();
 p.name=sujet;
 } else {
 
 for ( int i = 0; i < physics.numberOfParticles (); ++i )
 {
 Particle a = physics.getParticle( i );
 if(a.name){
 if (a.name.equals(sujet)) {
 p=a;
 break;
 }
 }}
 }
 if (!noeuds.contains(objet)) {
 noeuds.add(objet);
 q = physics.makeParticle();
 q.name=objet;
 } else {
 
 for ( int i = 0; i < physics.numberOfParticles (); ++i )
 {
 Particle b = physics.getParticle( i );
 if ((b.name!=null) && (b.name.equals(objet))) {
 q=b;
 break;
 }
 }
 }
 Information information = new Information(p, q, forceRessort, souplesseRessort, longueurRessort, propriete);
 physics.springs.add( information );
 // console.log(propriete);
 informations.add(information);
 information.actualiseActivite();
 //  makeEdgeBetween( p, q, propriete);
 p.mass0++;
 q.mass0++;
 p.position.x = q.position.x + random( -10, 10 );
 p.position.y = q.position.y + random( -10, 10 );
 p.position.z = 0;
 //console.log(physics.springs.size());
 }
 */
import java.util.Iterator;

// Traer Physics 3.0
// Terms from Traer's download page, http://traer.cc/mainsite/physics/
//   LICENSE - Use this code for whatever you want, just send me a link jeff@traer.cc
//
// traer3a_01.pde 
//   From traer.physics - author: Jeff Traer
//     Attraction              Particle                     
//     EulerIntegrator         ParticleSystem  
//     Force                   RungeKuttaIntegrator         
//     Integrator              Spring
//     ModifiedEulerIntegrator Vector3D          
//
//   From traer.animator - author: Jeff Traer   
//     Smoother                                       
//     Smoother3D                  
//     Tickable     
//
//   New code - author: Carl Pearson
//     UniversalAttraction
//     Pulse
//

// 13 Dec 2010: Copied 3.0 src from http://traer.cc/mainsite/physics/ and ported to Processingjs,
//              added makeParticle2(), makeAttraction2(), replaceAttraction(), and removeParticle(int) -mrn (Mike Niemi)
//  9 Feb 2011: Fixed bug in Euler integrators where they divided by time instead of 
//              multiplying by it in the update steps,
//              eliminated the Vector3D class (converting the code to use the native PVector class),
//              did some code compaction in the RK solver,
//              added a couple convenience classes, UniversalAttraction and Pulse, simplifying 
//              the Pendulums sample (renamed to dynamics.pde) considerably. -cap (Carl Pearson)
// 24 Mar 2011: Changed the switch statement in ParticleSystem.setIntegrator() to an if-then-else
//              to avoid an apparent bug introduced in Processing-1.1.0.js where the 
//              variable, RUNGE_KUTTA, was not visible inside the switch statement.
//              Changed ModifiedEulerIntegrator to use the documented PVector interfaces to work with pjs. -mrn
//  8 Jan 2013: Added "import java.util.Iterator" so it will now work in the Processing 2.0 IDE,
//              just flip the mode buttion in the upper right corner of the IDE between "JAVA" to "JAVASCRIPT".

//===========================================================================================
//                                      Attraction
//===========================================================================================
// attract positive repel negative
//package traer.physics;
public class Attraction implements Force
{
  Particle one;
  Particle b;
  float k;
  boolean on = true;
  float distanceMin;
  float distanceMinSquared;

  public Attraction( Particle a, Particle b, float k, float distanceMin )
  {
    this.one = a;
    this.b = b;
    this.k = k;
    this.distanceMin = distanceMin;
    this.distanceMinSquared = distanceMin*distanceMin;
  }

  protected void        setA( Particle p ) { 
    one = p;
  }
  protected void        setB( Particle p ) { 
    b = p;
  }
  public final float    getMinimumDistance() { 
    return distanceMin;
  }
  public final void     setMinimumDistance( float d ) { 
    distanceMin = d; 
    distanceMinSquared = d*d;
  }
  public final void     turnOff() { 
    on = false;
  }
  public final void     turnOn() { 
    on = true;
  }
  public final void     setStrength( float k ) { 
    this.k = k;
  }
  public final Particle getOneEnd() { 
    return one;
  }
  public final Particle getTheOtherEnd() { 
    return b;
  }

  public void apply() 
  { 
    if ( on && ( one.isFree() || b.isFree() ) )
    {
      PVector a2b = PVector.sub(one.position, b.position, new PVector());
      float a2bDistanceSquared = a2b.dot(a2b);

      if ( a2bDistanceSquared < distanceMinSquared )
        a2bDistanceSquared = distanceMinSquared;

      float force = k * one.mass0 * b.mass0 / (a2bDistanceSquared * (float)Math.sqrt(a2bDistanceSquared));

      a2b.mult( force );

      // apply
      if ( b.isFree() )
        b.force.add( a2b );  
      if ( one.isFree() ) {
        a2b.mult(-1f);
        one.force.add( a2b );
      }
    }
  }

  public final float   getStrength() { 
    return k;
  }
  public final boolean isOn() { 
    return on;
  }
  public final boolean isOff() { 
    return !on;
  }
} // Attraction

//===========================================================================================
//                                    UniversalAttraction
//===========================================================================================
// attract positive repel negative
public class UniversalAttraction implements Force {
  public UniversalAttraction( float k, float distanceMin, ArrayList targetList )
  {
    this.k = k;
    this.distanceMin = distanceMin;
    this.distanceMinSquared = distanceMin*distanceMin;
    this.targetList = targetList;
  }

  float k;
  boolean on = true;
  float distanceMin;
  float distanceMinSquared;
  ArrayList targetList;
  public final float    getMinimumDistance() { 
    return distanceMin;
  }
  public final void     setMinimumDistance( float d ) { 
    distanceMin = d; 
    distanceMinSquared = d*d;
  }
  public final void     turnOff() { 
    on = false;
  }
  public final void     turnOn() { 
    on = true;
  }
  public final void     setStrength( float k ) { 
    this.k = k;
  }
  public final float   getStrength() { 
    return k;
  }
  public final boolean isOn() { 
    return on;
  }
  public final boolean isOff() { 
    return !on;
  }


  public void apply() 
  { 
    if ( on ) {
      for (int i=0; i < targetList.size (); i++ ) {
        for (int j=i+1; j < targetList.size (); j++) {
          Particle a = (Particle)targetList.get(i);
          Particle b = (Particle)targetList.get(j);
          if ( a.isFree() || b.isFree() ) {
            PVector a2b = PVector.sub(a.position, b.position, new PVector());
            float a2bDistanceSquared = a2b.dot(a2b);
            if ( a2bDistanceSquared < distanceMinSquared )
              a2bDistanceSquared = distanceMinSquared;
            float force = k * a.mass0 * b.mass0 / (a2bDistanceSquared * (float)Math.sqrt(a2bDistanceSquared));
            a2b.mult( force );

            if ( b.isFree() ) b.force.add( a2b );  
            if ( a.isFree() ) {
              a2b.mult(-1f);
              a.force.add( a2b );
            }
          }
        }
      }
    }
  }
} //UniversalAttraction

//===========================================================================================
//                                    Pulse
//===========================================================================================
public class Pulse implements Force {
  public Pulse( float k, float distanceMin, PVector origin, float lifetime, ArrayList targetList )
  {
    this.k = k;
    this.distanceMin = distanceMin;
    this.distanceMinSquared = distanceMin*distanceMin;
    this.origin = origin;
    this.targetList = targetList;
    this.lifetime = lifetime;
  }

  float k;
  boolean on = true;
  float distanceMin;
  float distanceMinSquared;
  float lifetime;
  PVector origin;
  ArrayList targetList;

  public final void     turnOff() { 
    on = false;
  }
  public final void     turnOn() { 
    on = true;
  }
  public final boolean  isOn() { 
    return on;
  }
  public final boolean  isOff() { 
    return !on;
  }
  public final boolean  tick( float time ) { 
    lifetime-=time; 
    if (lifetime <= 0f) turnOff(); 
    return on;
  }

  public void apply() {
    if (on) {
      PVector holder = new PVector();
      int count = 0;
      for (Iterator i = targetList.iterator (); i.hasNext(); ) {
        Particle p = (Particle)i.next();
        if ( p.isFree() ) {
          holder.set( p.position.x, p.position.y, p.position.z );
          holder.sub( origin );
          float distanceSquared = holder.dot(holder);
          if (distanceSquared < distanceMinSquared) distanceSquared = distanceMinSquared;
          holder.mult(k / (distanceSquared * (float)Math.sqrt(distanceSquared)) );
          p.force.add( holder );
        }
      }
    }
  }
}//Pulse

//===========================================================================================
//                                      EulerIntegrator
//===========================================================================================
//package traer.physics;
public class EulerIntegrator implements Integrator
{
  ParticleSystem s;

  public EulerIntegrator( ParticleSystem s ) { 
    this.s = s;
  }
  public void step( float t )
  {
    s.clearForces();
    s.applyForces();

    for ( Iterator i = s.particles.iterator (); i.hasNext(); )
    {
      Particle p = (Particle)i.next();
      if ( p.isFree() )
      {
        p.velocity.add( PVector.mult(p.force, t/p.mass0) );
        p.position.add( PVector.mult(p.velocity, t) );
      }
    }
  }
} // EulerIntegrator

//===========================================================================================
//                                          Force
//===========================================================================================
// May 29, 2005
//package traer.physics;
// @author jeffrey traer bernstein
public interface Force
{
  public void    turnOn();
  public void    turnOff();
  public boolean isOn();
  public boolean isOff();
  public void    apply();
} // Force

//===========================================================================================
//                                      Integrator
//===========================================================================================
//package traer.physics;
public interface Integrator 
{
  public void step( float t );
} // Integrator

//===========================================================================================
//                                    ModifiedEulerIntegrator
//===========================================================================================
//package traer.physics;
public class ModifiedEulerIntegrator implements Integrator
{
  ParticleSystem s;
  public ModifiedEulerIntegrator( ParticleSystem s ) { 
    this.s = s;
  }
  public void step( float t )
  {
    s.clearForces();
    s.applyForces();

    float halft = 0.5f*t;
    //    float halftt = 0.5f*t*t;
    PVector a = new PVector();
    PVector holder = new PVector();

    for ( int i = 0; i < s.numberOfParticles (); i++ )
    {
      Particle p = s.getParticle( i );
      if ( p.isFree() )
      { // The following "was"s was the code in traer3a which appears to work in the IDE but not pjs
        // I couln't find the interface Carl used in the PVector documentation and have converted
        // the code to the documented interface. -mrn

        // was in traer3a: PVector.div(p.force, p.mass0, a);
        a.set(p.force.x, p.force.y, p.force.z);
        a.div(p.mass0);

        //was in traer3a: p.position.add( PVector.mult(p.velocity, t, holder) );
        holder.set(p.velocity.x, p.velocity.y, p.velocity.z);
        holder.mult(t);
        p.position.add(holder);

        //was in traer3a: p.position.add( PVector.mult(a, halft, a) );
        holder.set(a.x, a.y, a.z);
        holder.mult(halft); // Note that the original Traer code used halftt ( 0.5*t*t ) here -mrn
        p.position.add(holder);

        //was in traer3a: p.velocity.add( PVector.mult(a, t, a) );
        holder.set(a.x, a.y, a.z);
        holder.mult(t);
        p.velocity.add(a);
      }
    }
  }
} // ModifiedEulerIntegrator

//===========================================================================================
//                                         Particle
//===========================================================================================
//package traer.physics;
public class Particle
{
  PVector position = new PVector();
  PVector velocity = new PVector();
  PVector force = new PVector();
  protected float    mass0=5;
  protected float    age0 = 0;
  protected boolean  dead0 = false;
  boolean            fixed0 = false;
  String name;

  public Particle( float m )
  { 
    mass0 = m;
  }

  // @see traer.physics.AbstractParticle#distanceTo(traer.physics.Particle)
  public final float distanceTo( Particle p ) { 
    return this.position.dist( p.position );
  }

  // @see traer.physics.AbstractParticle#makeFixed()
  public final Particle makeFixed() {
    fixed0 = true;
    velocity.set(0f, 0f, 0f);
    force.set(0f, 0f, 0f);
    return this;
  }

  // @see traer.physics.AbstractParticle#makeFree()
  public final Particle makeFree() {
    fixed0 = false;
    return this;
  }

  // @see traer.physics.AbstractParticle#isFixed()
  public final boolean isFixed() { 
    return fixed0;
  }

  // @see traer.physics.AbstractParticle#isFree()
  public final boolean isFree() { 
    return !fixed0;
  }

  // @see traer.physics.AbstractParticle#mass()
  public final float mass() { 
    return mass0;
  }

  // @see traer.physics.AbstractParticle#setMass(float)
  public final void setMass( float m ) { 
    mass0 = m;
  }

  // @see traer.physics.AbstractParticle#age()
  public final float age() { 
    return age0;
  }

  protected void reset()
  {
    age0 = 0;
    dead0 = false;
    position.set(0f, 0f, 0f);
    velocity.set(0f, 0f, 0f);
    force.set(0f, 0f, 0f);
    mass0 = 1f;
  }


  void recadrage(){
    // pas terrible comme recadrage, a revoir ;-)
   if((this.position.y>=Ymax)||(this.position.y>physics.numberOfParticles ()*10)){
     console.log(Ymax);
     this.position.y=this.position.y-10;
    Ymax=this.position.y;
    Ymax=constrain(Ymax,physics.numberOfParticles ()*10,physics.numberOfParticles ()*100);
    
   } 
  }
  String setName(String _name){
   this.name=_name;
  return this.name; 
  }
} // Particle

//===========================================================================================
//                                      ParticleSystem
//===========================================================================================
// May 29, 2005
//package traer.physics;
//import java.util.*;
public class ParticleSystem
{
  public static final int RUNGE_KUTTA = 0;
  public static final int MODIFIED_EULER = 1;
  protected static final float DEFAULT_GRAVITY = 0;
  protected static final float DEFAULT_DRAG = 0.001f;  
  ArrayList  particles = new ArrayList();
  ArrayList  springs = new ArrayList();
  ArrayList  attractions = new ArrayList();
  ArrayList  customForces = new ArrayList();
  ArrayList  pulses = new ArrayList();
  Integrator integrator;
  PVector    gravity = new PVector();
  float      drag;
  boolean    hasDeadParticles = false;

  public final void setIntegrator( int which )
  {
    //switch ( which )
    //{
    //  case RUNGE_KUTTA:
    //    this.integrator = new RungeKuttaIntegrator( this );
    //    break;
    //  case MODIFIED_EULER:
    //    this.integrator = new ModifiedEulerIntegrator( this );
    //    break;
    //}
    if ( which==RUNGE_KUTTA )
      this.integrator = new RungeKuttaIntegrator( this );
    else
      if ( which==MODIFIED_EULER )
      this.integrator = new ModifiedEulerIntegrator( this );
  }

  public final void setGravity( float x, float y, float z ) { 
    gravity.set( x, y, z );
  }

  // default down gravity
  public final void     setGravity( float g ) { 
    gravity.set( 0, g, 0 );
  }
  public final void     setDrag( float d ) { 
    drag = d;
  }
  public final void     tick() { 
    tick( 1 );
  }
  public final void     tick( float t ) {
    integrator.step( t );
    for (int i = 0; i<pulses.size (); ) {
      Pulse p = (Pulse)pulses.get(i);
      p.tick(t);
      if (p.isOn()) { 
        i++;
      } else { 
        pulses.remove(i);
      }
    }
    if (pulses.size()!=0) for (Iterator i = pulses.iterator (); i.hasNext(); ) {
      Pulse p = (Pulse)(i.next());
      p.tick( t );
      if (!p.isOn()) i.remove();
    }
  }

  public final Particle makeParticle( float mass, float x, float y, float z )
  {
    Particle p = new Particle( mass );
    p.position.set( x, y, z );
    particles.add( p );
    return p;
  }

  public final int makeParticle2( float mass, float x, float y, float z )
  { // mrn
    makeParticle(mass, x, y, z);
    return particles.size()-1;
  }

  public final Particle makeParticle() { 
    return makeParticle( 1.0f, 0f, 0f, 0f );
  }

  public final Spring   makeSpring( Particle a, Particle b, float ks, float d, float r )
  {
    Spring s = new Spring( a, b, ks, d, r );
    springs.add( s );
    return s;
  }

  public final Spring   makeSpring( Particle a, Particle b, float ks, float d, float r, String propriete)
  {
    Spring s = new Spring( a, b, ks, d, r, propriete);
    springs.add( s );
    return s;
  }

  public final Attraction makeAttraction( Particle first, Particle b, float k, float minDistance )
  {
    Attraction m = new Attraction( first, b, k, minDistance );
    attractions.add( m );
    return m;
  }

  public final int makeAttraction2( Particle a, Particle b, float k, float minDistance )
  { // mrn
    makeAttraction(a, b, k, minDistance);
    return attractions.size()-1; // return the index
  }

  public final void replaceAttraction( int i, Attraction m )
  { // mrn
    attractions.set( i, m );
  }  

  public final void addPulse(Pulse pu) { 
    pulses.add(pu);
  }

  public final void clear()
  {
    particles.clear();
    springs.clear();
    attractions.clear();
    customForces.clear();
    pulses.clear();
  }

  public ParticleSystem( float g, float somedrag )
  {
    setGravity( 0f, g, 0f );
    drag = somedrag;
    integrator = new RungeKuttaIntegrator( this );
  }

  public ParticleSystem( float gx, float gy, float gz, float somedrag )
  {
    setGravity( gx, gy, gz );
    drag = somedrag;
    integrator = new RungeKuttaIntegrator( this );
  }

  public ParticleSystem()
  {
    setGravity( 0f, ParticleSystem.DEFAULT_GRAVITY, 0f );
    drag = ParticleSystem.DEFAULT_DRAG;
    integrator = new RungeKuttaIntegrator( this );
  }

  protected final void applyForces()
  {
    if ( gravity.mag() != 0f )
    {
      for ( Iterator i = particles.iterator (); i.hasNext(); )
      {
        Particle p = (Particle)i.next();
        if (p.isFree()) p.force.add( gravity );
      }
    }

    PVector target = new PVector();
    for ( Iterator i = particles.iterator (); i.hasNext(); )
    {
      Particle p = (Particle)i.next();
      if (p.isFree()) p.force.add( PVector.mult(p.velocity, -drag, target) );
    }

    applyAll(springs);
    applyAll(attractions);
    applyAll(customForces);
    applyAll(pulses);
  }

  private void applyAll(ArrayList forces) {
    if ( forces.size()!=0 ) { 
      // println(forces.size());
      // Iterator i = forces.iterator ();
      for  (int f=0; f<forces.size (); f++ ) { 
        Force force=(Force)forces.get(f);
        force.apply();
      }
    }
  }

  protected final void clearForces()
  {
    for (Iterator i = particles.iterator (); i.hasNext(); ) ((Particle)i.next()).force.set(0f, 0f, 0f);
  }

  public final int        numberOfParticles() { 
    return particles.size();
  }
  public final int        numberOfSprings() { 
    return springs.size();
  }
  public final int        numberOfAttractions() { 
    return attractions.size();
  }
  public final Particle   getParticle( int i ) { 
    return (Particle)particles.get( i );
  }
  public final Spring     getSpring( int i ) { 
    return (Spring)springs.get( i );
  }
  public final Attraction getAttraction( int i ) { 
    return (Attraction)attractions.get( i );
  }
  public final void       addCustomForce( Force f ) { 
    customForces.add( f );
  }
  public final int        numberOfCustomForces() { 
    return customForces.size();
  }
  public final Force      getCustomForce( int i ) { 
    return (Force)customForces.get( i );
  }
  public final Force      removeCustomForce( int i ) { 
    return (Force)customForces.remove( i );
  }
  public final void       removeParticle( int i ) { 
    particles.remove( i );
  } //mrn
  public final void       removeParticle( Particle p ) { 
    particles.remove( p );
  }
  public final Spring     removeSpring( int i ) { 
    return (Spring)springs.remove( i );
  }
  public final Attraction removeAttraction( int i ) { 
    return (Attraction)attractions.remove( i );
  }
  public final void       removeAttraction( Attraction s ) { 
    attractions.remove( s );
  }
  public final void       removeSpring( Spring a ) { 
    springs.remove( a );
  }
  public final void       removeCustomForce( Force f ) { 
    customForces.remove( f );
  }
} // ParticleSystem

//===========================================================================================
//                                      RungeKuttaIntegrator
//===========================================================================================
//package traer.physics;
//import java.util.*;
public class RungeKuttaIntegrator implements Integrator
{  
  ArrayList originalPositions = new ArrayList();
  ArrayList originalVelocities = new ArrayList();
  ArrayList k1Forces = new ArrayList();
  ArrayList k1Velocities = new ArrayList();
  ArrayList k2Forces = new ArrayList();
  ArrayList k2Velocities = new ArrayList();
  ArrayList k3Forces = new ArrayList();
  ArrayList k3Velocities = new ArrayList();
  ArrayList k4Forces = new ArrayList();
  ArrayList k4Velocities = new ArrayList();
  ParticleSystem s;

  public RungeKuttaIntegrator( ParticleSystem s ) { 
    this.s = s;
  }

  final void allocateParticles()
  {
    while ( s.particles.size () > originalPositions.size() ) {
      originalPositions.add( new PVector() );
      originalVelocities.add( new PVector() );
      k1Forces.add( new PVector() );
      k1Velocities.add( new PVector() );
      k2Forces.add( new PVector() );
      k2Velocities.add( new PVector() );
      k3Forces.add( new PVector() );
      k3Velocities.add( new PVector() );
      k4Forces.add( new PVector() );
      k4Velocities.add( new PVector() );
    }
  }

  private final void setIntermediate(ArrayList forces, ArrayList velocities) {
    s.applyForces();
    for ( int i = 0; i < s.particles.size (); ++i )
    {
      Particle p = (Particle)s.particles.get( i );
      if ( p.isFree() )
      {
        ((PVector)forces.get( i )).set( p.force.x, p.force.y, p.force.z );
        ((PVector)velocities.get( i )).set( p.velocity.x, p.velocity.y, p.velocity.z );
        p.force.set(0f, 0f, 0f);
      }
    }
  }

  private final void updateIntermediate(ArrayList forces, ArrayList velocities, float multiplier) {
    PVector holder = new PVector();

    for ( int i = 0; i < s.particles.size (); ++i )
    {
      Particle p = (Particle)s.particles.get( i );
      if ( p.isFree() )
      {
        PVector op = (PVector)(originalPositions.get( i ));
        p.position.set(op.x, op.y, op.z);
        p.position.add(PVector.mult((PVector)(velocities.get( i )), multiplier, holder));    
        PVector ov = (PVector)(originalVelocities.get( i ));
        p.velocity.set(ov.x, ov.y, ov.z);
        p.velocity.add(PVector.mult((PVector)(forces.get( i )), multiplier/p.mass0, holder));
      }
    }
  }

  private final void initialize() {
    for ( int i = 0; i < s.particles.size (); ++i )
    {
      Particle p = (Particle)(s.particles.get( i ));
      if ( p.isFree() )
      {    
        ((PVector)(originalPositions.get( i ))).set( p.position.x, p.position.y, p.position.z );
        ((PVector)(originalVelocities.get( i ))).set( p.velocity.x, p.velocity.y, p.velocity.z );
      }
      p.force.set(0f, 0f, 0f);  // and clear the forces
    }
  }

  public final void step( float deltaT )
  {  
    allocateParticles();
    initialize();       
    setIntermediate(k1Forces, k1Velocities);
    updateIntermediate(k1Forces, k1Velocities, 0.5f*deltaT );
    setIntermediate(k2Forces, k2Velocities);
    updateIntermediate(k2Forces, k2Velocities, 0.5f*deltaT );
    setIntermediate(k3Forces, k3Velocities);
    updateIntermediate(k3Forces, k3Velocities, deltaT );
    setIntermediate(k4Forces, k4Velocities);

    /////////////////////////////////////////////////////////////
    // put them all together and what do you get?
    for ( int i = 0; i < s.particles.size (); ++i )
    {
      Particle p = (Particle)s.particles.get( i );
      p.age0 += deltaT;
      if ( p.isFree() )
      {
        // update position
        PVector holder = (PVector)(k2Velocities.get( i ));
        holder.add((PVector)k3Velocities.get( i ));
        holder.mult(2.0f);
        holder.add((PVector)k1Velocities.get( i ));
        holder.add((PVector)k4Velocities.get( i ));
        holder.mult(deltaT / 6.0f);
        holder.add((PVector)originalPositions.get( i ));
        p.position.set(holder.x, holder.y, holder.z);

        // update velocity
        holder = (PVector)k2Forces.get( i );
        holder.add((PVector)k3Forces.get( i ));
        holder.mult(2.0f);
        holder.add((PVector)k1Forces.get( i ));
        holder.add((PVector)k4Forces.get( i ));
        holder.mult(deltaT / (6.0f * p.mass0 ));
        holder.add((PVector)originalVelocities.get( i ));
        p.velocity.set(holder.x, holder.y, holder.z);
      }
    }
  }
} // RungeKuttaIntegrator

//===========================================================================================
//                                         Spring
//===========================================================================================
// May 29, 2005
//package traer.physics;
// @author jeffrey traer bernstein
public class Spring implements Force
{
  float springConstant0;
  float damping0;
  float restLength0;
  Particle one, b;
  boolean on = true;


  public Spring( Particle A, Particle B, float ks, float d, float r )
  {
    springConstant0 = ks;
    damping0 = d;
    restLength0 = r;
    one = A;
    b = B;
  }
/*
  public Spring( Particle A, Particle B, float ks, float d, float r, String _propriete)
  {
    
    springConstant0 = ks;
    damping0 = d;
    restLength0 = r;
    one = A;
    b = B;
    console.log("prop du spring "+propriete);
  }*/

  public final void     turnOff() { 
    on = false;
  }
  public final void     turnOn() { 
    on = true;
  }
  public final boolean  isOn() { 
    return on;
  }
  public final boolean  isOff() { 
    return !on;
  }
  public final Particle getOneEnd() { 
    return one;
  }
  public final Particle getTheOtherEnd() { 
    return b;
  }
  public final float    currentLength() { 
    return one.distanceTo( b );
  }
  public final float    restLength() { 
    return restLength0;
  }
  public final float    strength() { 
    return springConstant0;
  }
  public final void     setStrength( float ks ) { 
    springConstant0 = ks;
  }
  public final float    damping() { 
    return damping0;
  }
  public final void     setDamping( float d ) { 
    damping0 = d;
  }
  public final void     setRestLength( float l ) { 
    restLength0 = l;
  }

  public final void apply()
  {  
    if ( on && ( one.isFree() || b.isFree() ) )
    {
      PVector a2b = PVector.sub(one.position, b.position, new PVector());

      float a2bDistance = a2b.mag();  

      if (a2bDistance!=0f) {
        a2b.div(a2bDistance);
      }

      // spring force is proportional to how much it stretched 
      float springForce = -( a2bDistance - restLength0 ) * springConstant0; 

      PVector vDamping = PVector.sub(one.velocity, b.velocity, new PVector());

      float dampingForce = -damping0 * a2b.dot(vDamping);

      // forceB is same as forceA in opposite direction
      float r = springForce + dampingForce;

      a2b.mult(r);

      if ( one.isFree() )
        one.force.add( a2b );
      if ( b.isFree() )
        b.force.add( PVector.mult(a2b, -1, a2b) );
    }
  }
  protected void setA( Particle p ) { 
    one = p;
  }
  protected void setB( Particle p ) { 
    b = p;
  }
} // Spring

//===========================================================================================
//                                       Smoother
//===========================================================================================
//package traer.animator;
public class Smoother implements Tickable
{
  public Smoother(float smoothness) { 
    setSmoothness(smoothness);  
    setValue(0.0);
  }
  public Smoother(float smoothness, float start) { 
    setSmoothness(smoothness); 
    setValue(start);
  }
  public final void     setSmoothness(float smoothness) { 
    a = -smoothness; 
    gain = 1.0 + a;
  }
  public final void     setTarget(float target) { 
    input = target;
  }
  public void           setValue(float x) { 
    input = x; 
    lastOutput = x;
  }
  public final float    getTarget() { 
    return input;
  }
  public final void     tick() { 
    lastOutput = gain * input - a * lastOutput;
  }
  public final float    getValue() { 
    return lastOutput;
  }
  public float a, gain, lastOutput, input;
} // Smoother

//===========================================================================================
//                                      Smoother3D
//===========================================================================================
//package traer.animator;
public class Smoother3D implements Tickable
{
  public Smoother3D(float smoothness)
  {
    x0 = new Smoother(smoothness);
    y0 = new Smoother(smoothness);
    z0 = new Smoother(smoothness);
  }
  public Smoother3D(float initialX, float initialY, float initialZ, float smoothness)
  {
    x0 = new Smoother(smoothness, initialX);
    y0 = new Smoother(smoothness, initialY);
    z0 = new Smoother(smoothness, initialZ);
  }
  public final void setXTarget(float X) { 
    x0.setTarget(X);
  }
  public final void setYTarget(float X) { 
    y0.setTarget(X);
  }
  public final void setZTarget(float X) { 
    z0.setTarget(X);
  }
  public final float getXTarget() { 
    return x0.getTarget();
  }
  public final float getYTarget() { 
    return y0.getTarget();
  }
  public final float getZTarget() { 
    return z0.getTarget();
  }
  public final void setTarget(float X, float Y, float Z)
  {
    x0.setTarget(X);
    y0.setTarget(Y);
    z0.setTarget(Z);
  }
  public final void setValue(float X, float Y, float Z)
  {
    x0.setValue(X);
    y0.setValue(Y);
    z0.setValue(Z);
  }
  public final void setX(float X) { 
    x0.setValue(X);
  }
  public final void setY(float Y) { 
    y0.setValue(Y);
  }
  public final void setZ(float Z) { 
    z0.setValue(Z);
  }
  public final void setSmoothness(float smoothness)
  {
    x0.setSmoothness(smoothness);
    y0.setSmoothness(smoothness);
    z0.setSmoothness(smoothness);
  }
  public final void tick() { 
    x0.tick(); 
    y0.tick(); 
    z0.tick();
  }
  public final float x() { 
    return x0.getValue();
  }
  public final float y() { 
    return y0.getValue();
  }
  public final float z() { 
    return z0.getValue();
  }
  public Smoother x0, y0, z0;
} // Smoother3D

//===========================================================================================
//                                      Tickable
//===========================================================================================
//package traer.animator;
public interface Tickable
{
  public abstract void tick();
  public abstract void setSmoothness(float f);
} // Tickable

// widgets.pde
//   Button       
//     StateButton  
//     StartPauseStopButton
//     RestartButton
//   HScrollbar
// 
// Last updated: 16 Dec 2010 16:43, Mike Niemi

class Button
{
  int       x, y, buttonSize, ibackgroundcolor, ihighlightcolor, ibasecolor;
  color     currentcolor;
  boolean   over0    = false,
            pressed0 = false,
            locked0  = false;   

  void update() 
  {
    if (over()) 
       currentcolor = color(ihighlightcolor);
    else 
       currentcolor = color(ibasecolor);
  }

  boolean pressed() 
  {
    if (over0) 
      {
        locked0 = true;
        return true;
      } 
    else 
      {
        locked0 = false;
        return false;
      }     
  }

  boolean over() 
  { return true; }

  boolean overRect(int x, int y, int width, int height) 
  {
    if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) 
       return true;
    else 
       return false;
  }

  boolean overCircle(int x, int y, int diameter) 
  {
    float disX = x - mouseX;
    float disY = y - mouseY;
    if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) 
       return true;
    else 
       return false;
  }

  boolean overArc(int x, int y, int width, int height) 
  {
    if (mouseX >= x && mouseX <= x+width && 
        mouseY >= (y-height/2) && mouseY <= (y-height/2)+height) 
       return true;
    else 
       return false;
  }
  
} // Button

class StateButton extends Button
{ 
  final static int STATEoff = 0, STATEon = 1;
  int cx, cy;
  
  StateButton(int ix, int iy, int isize, int icolor, int ihighlight, int ibackground) 
  {
    x = ix; // x and y are the upper left corner (like ellipseMode(CORNER))
    y = iy; 
    buttonSize = isize;
    cx = x + buttonSize/2; // cx and cy will be the center
    cy = y + buttonSize/2;
    ibasecolor = icolor;
    ihighlightcolor = ihighlight;
    currentcolor = color(ibasecolor);
    ibackgroundcolor = ibackground;
  }

  boolean over() 
  {
    if ( overCircle(cx, cy, buttonSize) ) 
      {
        over0 = true;
        return true;
      } 
    else 
      {
        over0 = false;
        return false;
      }
  }

  void display(int state, int numCyclesLeft) 
  {
    if (state == STATEon)
      { 
        stroke(128);
        
        if (numCyclesLeft < 20) // fade in the idled color
          { 
            float f0 = 1.0 - ((float)numCyclesLeft)/20.0; // 0.0 - 1.0
            float f1 = ibasecolor - f0 * (float)(ibasecolor-ibackgroundcolor);
            if (ibackgroundcolor == 0)
               fill(f1,0,0);
            else
              {   
                float f2 = f0 * 255.0;
                fill(f1,f2,f2);
              }  
          }    
        else
          fill(ibasecolor,0,0); 
          
        ellipse(cx, cy, buttonSize, buttonSize);
      }  
    else
      { 
        stroke(128);
        fill(color(ibackgroundcolor));
        ellipse(cx, cy, buttonSize, buttonSize);
      }  
  }
} // StateButton

class StartPauseStopButton extends Button
{ 
  final static int SHOWrun = 0, SHOWpause = 1, SHOWstop = 2; 
  
  StartPauseStopButton(int ix, int iy, int isize, 
                       int icolor, int ihighlight, int ibackground) 
  {
    x = ix; // x and y are the upper left corner
    y = iy;
    buttonSize = isize;
    ibasecolor = icolor;
    ihighlightcolor = ihighlight;
    currentcolor = color(ibasecolor);
    ibackgroundcolor = ibackground;
  }

  boolean over() 
  {
    if ( overRect(x, y, buttonSize, buttonSize) ) 
      {
        over0 = true;
        return true;
      } 
    else 
      {
        over0 = false;
        return false;
      }
  }

  void display(int whatToShow) 
  {
    if (whatToShow == SHOWstop)
      { 
        stroke(255, 80, 80);
        fill(255,0,0);
        rect(x, y, buttonSize, buttonSize);
      }  
    else
    if (whatToShow == SHOWpause)
      { 
        stroke(128);
        fill(0);
        rect(x+2,                y, buttonSize/4, buttonSize);
        rect(x+2*buttonSize/3-2, y, buttonSize/4, buttonSize);
      }  
    else
    if (whatToShow == SHOWrun)
      { 
        stroke(80, 255, 80);
        fill(0,255,0);
        triangle(x,y, x+buttonSize,y+buttonSize/2, x,y+buttonSize);
      }  
  }
} // StartPauseStopButton

class RestartButton extends Button
{ 
  int cx, cy;
  
  RestartButton(int ix, int iy, int isize, 
                int icolor, int ihighlight, int ibackground) 
  {
    x = ix;                // x and y are the upper left corner
    y = iy;
    buttonSize = isize;
    cx = x + buttonSize/2; // cx and cy will be the center
    cy = y + buttonSize/2;
    ibasecolor = icolor;
    ihighlightcolor = ihighlight;
    currentcolor = color(ibasecolor);
    ibackgroundcolor = ibackground;
  }

  boolean over() 
  {
    if ( overCircle(cx, cy, buttonSize) ) 
      {
        over0 = true;
        return true;
      } 
    else 
      {
        over0 = false;
        return false;
      }
  }

  void display() 
  {
    stroke(0);
    noFill();
    arc(cx, cy, buttonSize, buttonSize, PI/2, 2*PI);
    arc(cx, cy, buttonSize-10, buttonSize-10, PI/2, 2*PI);
    line(x+buttonSize-3, cy+5, x+buttonSize+4,  cy-3);
    line(x+buttonSize-3, cy+5, x+buttonSize-10, cy-3);
    line(cx, y+buttonSize-4, cx, y+buttonSize);
  }
} // RestartButton

class HScrollbar
{
  int     swidth, sheight;  // width and height of bar
  int     xpos, ypos;       // x and y position of bar
  float   spos, newspos;    // x position of slider
  int     sposMin, sposMax; // max and min values of slider
  int     loose;            // how loose/heavy
  boolean over0;            // is the mouse over the slider?
  boolean locked0;
  float   ratio;
  int     cyclesLeft = 9999;

  HScrollbar (int xp, int yp, int sw, int sh, int l) 
  {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    //spos = xpos + swidth/2 - sheight/2;
    spos = xpos;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  boolean update(int i) 
  {
    float oldNewspos = newspos;
    
    cyclesLeft = i;
      
    if (over()) 
       over0 = true;
    else 
       over0 = false;
        
    if (mousePressed && over0) 
       locked0 = true;
    
    if (!mousePressed) 
       locked0 = false;
    
    if (locked0) 
       newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    
    if (abs(newspos - spos) > 1) 
       spos = spos + (newspos-spos)/loose;
       
    return ( oldNewspos != newspos );
  }

  int constrain (int val, int minv, int maxv) 
  { return min(max(val, minv), maxv); }

  boolean over() 
  {
    over0 = (mouseX > xpos && mouseX < xpos+swidth && 
             mouseY > ypos && mouseY < ypos+sheight);
    return over0;
  }
  
  boolean locked()
  { 
    locked0 = over0 && mousePressed;
    return locked0; 
  }

  void display() 
  { 
    fill(255);
    rect(xpos, ypos, swidth, sheight);
    
    boolean quiescing = false;
    if ( cyclesLeft < 50 )
      {
        if (over0 || locked0)
          {
            float f = ((float)cyclesLeft)/50.0; // 1.0-0.0 .. fade-out over 50 cycles
            f = 102 + f*(200-102);
            fill(f,102,0);
            quiescing = true;
          }
      }
      
    if (!quiescing)  
      { if (over0 || locked0) 
           fill(200, 102, 0);
        else 
           fill(102, 102, 102);
      }     
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() 
  { return spos * ratio; } // 0 - total width of the scrollbar
  
  float getValue()
  { return (newspos-xpos)/(swidth-sheight); } // 0.0 - 1.0
} // HScrollbar


class FichierButton extends Button
{ 
  final static int SHOWrun = 0, SHOWpause = 1, SHOWstop = 2; 
  
  FichierButton(int ix, int iy, int isize, 
                       int icolor, int ihighlight, int ibackground) 
  {
    x = ix; // x and y are the upper left corner
    y = iy;
    buttonSize = isize;
    ibasecolor = icolor;
    ihighlightcolor = ihighlight;
    currentcolor = color(ibasecolor);
    ibackgroundcolor = ibackground;
  }

  boolean over() 
  {
    if ( overRect(x, y, buttonSize, buttonSize) ) 
      {
        over0 = true;
        return true;
      } 
    else 
      {
        over0 = false;
        return false;
      }
  }

  void display(int whatToShow) 
  {
    if (whatToShow == SHOWstop)
      { 
        stroke(255, 80, 80);
        fill(255,0,0);
        rect(x, y, buttonSize, buttonSize);
      }  
    else
    if (whatToShow == SHOWpause)
      { 
        stroke(128);
        fill(0);
        rect(x+2,                y, buttonSize/4, buttonSize);
        rect(x+2*buttonSize/3-2, y, buttonSize/4, buttonSize);
      }  
    else
    if (whatToShow == SHOWrun)
      { 
        stroke(80, 255, 80);
        fill(0,255,0);
        triangle(x+buttonSize/2,y, x+buttonSize,y+buttonSize, x,y+buttonSize);
      }  
  }
} // FichierButton

