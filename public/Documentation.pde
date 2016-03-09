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
