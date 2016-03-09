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

