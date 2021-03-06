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

