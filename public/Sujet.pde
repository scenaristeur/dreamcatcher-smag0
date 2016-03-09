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

