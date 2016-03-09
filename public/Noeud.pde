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

