var processingInstance;

Template.postPage.helpers({
  statements: function() {
	  console.log("set");
	  statements=Statements.find({postId: this._id});
	       if (!processingInstance) {
                 processingInstance = Processing.getInstanceById('sketch');
				 console.log('processing creation 2');
           }
		//   console.log(processingInstance);

		   
		   var statementsMap=statements.collection._docs._map;
			for (var id in statementsMap) {
				if (statementsMap.hasOwnProperty(id)) {
					  var statement=statementsMap[id];
					 
				   // console.log(id + " -> " );
					//console.log(statement);
					sujet=statement['sujet'];
					propriete=statement['propriete'];
					objet=statement['objet'];
				//	console.log(sujet+" -> "+propriete+" -> "+objet);
					 processingInstance.ajouteInformation(sujet,propriete,objet);
					//noeuds+=sujet;
				  }
}


	
	  Session.setJSON("json", statements);
    return Statements.find({postId: this._id});
  },
    comments: function() {
    return Comments.find({postId: this._id});
  }
});