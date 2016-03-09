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
  effaceAfficheSelectionnes();
  effaceActivite();
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
