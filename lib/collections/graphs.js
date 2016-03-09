validateGraph = function (graphe) {
  var errors = {};

  if (!graphe.sujet)
    errors.sujet = "on a besoin d'un sujet";
  
  if (!graphe.propriete)
    errors.propriete =  "avec une propriete ! ";

  if (!graphe.objet)
    errors.objet =  "STP, rajoute un objet";

  return errors;
}