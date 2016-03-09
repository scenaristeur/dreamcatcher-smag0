Template.statementList.onCreated(function() {
//https://www.w3.org/TR/rdf-sparql-json-res/#programmatic-utility

//http://data-gov.tw.rpi.edu/wiki/How_to_render_SPARQL_results_using_Google_Visualization_API
//https://github.com/ktym/d3sparql
//http://dev.data2000.no/sgvizler/

 // Session.set('postEditErrors', {});
// var requete="http://fuseki-smag0.rhcloud.com/ds/query?query=select+*+where{%0D%0A%0D%0A%3Fs+%3Fp+%3Fo}%20LIMIT%2010%0D%0A&output=json"
//var requete="http://fuseki-smag0.rhcloud.com/ds/query?query=select+*+where{%0D%0A%0D%0A%3Fs+%3Fp+<http%3A%2F%2Fsmag0.blogspot.fr%2Fns%2Fsmag0%23Projet>}%20LIMIT%2010%0D%0A&output=json";
//var prefixes= "PREFIX rdf:   %3Chttp://www.w3.org/1999/02/22-rdf-syntax-ns#%3E "; 
var endpoint="http://fuseki-smag0.rhcloud.com/";
var dataset="ds/";
var action="query?query=";
var requetePure="SELECT ?projet ?titre ?description WHERE { ?projet <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://smag0.blogspot.fr/ns/smag0#Projet> .  "
	requetePure+="?projet <http://purl.org/dc/elements/1.1/title> ?titre . \n"
	requetePure+="?projet <http://purl.org/dc/elements/1.1/description> ?description . \n"
	requetePure+="}";
	requetePure+=" LIMIT 5 ";
var requeteEncodee=encodeURIComponent(requetePure);
var requete=endpoint+dataset+action+requeteEncodee;  //+prefixes

console.log(requete);
httpGetAsync(requete,updateDiv);
});


function httpGetAsync(theUrl, callback)
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function() { 
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
           callback(xmlHttp.responseText);
            //console.log(xmlHttp.responseText);
             //document.getElementById("result").innerHTML = xhttp.responseText;
    }
    xmlHttp.open("GET", theUrl, true); // true for asynchronous 
    xmlHttp.send(null);
}

function updateDiv(data){
var myJSONOBJECT= eval('(' + data+ ')');
// ou var myJSONOBJECT= JSON.parse(data, reviver);
var champs=myJSONOBJECT.head.vars; //https://www.w3.org/TR/rdf-sparql-json-res/#programmatic-utility
console.log(champs);
var bindings = myJSONOBJECT.results.bindings;
//console.log("update");
//var resultat="";
var list = document.getElementById('resultats');
while (list.firstChild) {
    list.removeChild(list.firstChild);
}
for(i in bindings) {
  var binding = bindings[i];
   var entry = document.createElement('li');
   for(n in binding) {
    //alert(binding[n].value); // a nested for-loop to print binding values
	var champ=champs[n];
	var text=binding[n].value;
	
	  entry.appendChild(document.createTextNode(champ+" "+text));
	  entry.appendChild(document.createTextNode("  -> "));
  }
 /* var entry = document.createElement('li');

  for (j in champs){
	  var champ=champs[j];
	  console.log(champ);
	  text=binding.champ.value;
	  entry.appendChild(document.createTextNode(text));
	  entry.appendChild(document.createTextNode("  -> "));
  }*/
  //alert(binding); // a for-loop to print all the bindings
 /* sujet=binding.s.value.split("#")[1];
  prefixSujet=binding.s.value.split("#")[0];
  propriete=binding.p.value.split("#")[1];
  prefixPropriete=binding.p.value.split("#")[0];
  objet=binding.o.value.split("#")[1];
  prefixObjet=binding.o.value.split("#")[0];*/
//  resultat=sujet +" "+propriete+" "+objet;
 // console.log("resultat :"+resultat);

/*
entry.appendChild(document.createTextNode(sujet));
entry.appendChild(document.createTextNode(" ( "+prefixSujet+" ) "));
entry.appendChild(document.createTextNode("  -> "));
entry.appendChild(document.createTextNode(propriete));
entry.appendChild(document.createTextNode(" ( "+prefixPropriete+" ) "));
entry.appendChild(document.createTextNode("  -> "));
entry.appendChild(document.createTextNode(objet));
entry.appendChild(document.createTextNode(" ( "+prefixObjet+" ) "));*/
list.appendChild(entry);
}
//document.getElementById("result").innerHTML = resultat;

//var bindings = sr.results.bindings;

// JavaScript  for...in loop iterates
// through the properties of bindings array
// which are [0,1,length-1] as opposed to the
// array item.

//for(i in bindings) {
 // var binding = bindings[i];
 // alert(binding); // a for-loop to print all the bindings
//}

// The only difference here (a subtle one) is
// that the iterator variable is n as opposed to r
// n=name, r=row index
//for(i in bindings) {
  //var binding = bindings[i];
  //for(n in binding) {
  //  alert(binding[n].value); // a nested for-loop to print binding values
 // }
//}



}

