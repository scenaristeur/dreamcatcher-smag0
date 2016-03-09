Template.graphEdit.onCreated(function() {
  Session.set('graphEditErrors', {});
});

Template.graphEdit.helpers({
  errorMessage: function(field) {
    return Session.get('graphEditErrors')[field];
  },
  errorClass: function (field) {
    return !!Session.get('graphEditErrors')[field] ? 'has-error' : '';
  }
});

Template.graphEdit.events({
  'submit form': function(e) {
    e.preventDefault();
    
    var currentPostId = this._id;
    
    var graphProperties = {
      sujet: $(e.target).find('[name=sujet]').val(),
      propriete: $(e.target).find('[name=propriete]').val(),
	  objet: $(e.target).find('[name=objet]').val()
    }
    
    var errors = validateGraph(graphProperties);
    if (errors.sujet || errors.propriete || errors.objet)
      return Session.set('graphEditErrors', errors);
    
	console.log (currentPostId)
	console.log (graphProperties);
	Graphs.addStatement(currentPostId, {$set: graphProperties}, function(error) {
      if (error) {
        // display the error to the user
        throwError(error.reason);
      } else {
        Router.go('postPage', {_id: currentPostId});
      }
    });
  },
  

});