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

