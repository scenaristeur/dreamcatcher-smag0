Template.statementSubmit.onCreated(function() {
  Session.set('statementSubmitErrors', {});
});

Template.statementSubmit.helpers({
  errorMessage: function(field) {
    return Session.get('statementSubmitErrors')[field];
  },
  errorClass: function (field) {
    return !!Session.get('statementSubmitErrors')[field] ? 'has-error' : '';
  }
});

Template.statementSubmit.events({
  'submit form': function(e, template) {
    e.preventDefault();

    var $sujet = $(e.target).find('[name=sujet]');
	var $propriete = $(e.target).find('[name=propriete]');
	var $objet = $(e.target).find('[name=objet]');
    var statement = {
      sujet: $sujet.val(),
	  propriete: $propriete.val(),
	  objet: $objet.val(),
      postId: template.data._id
    };

  /*  var errors = validateGraph(graphProperties);
    if (errors.sujet || errors.propriete || errors.objet)
      return Session.set('graphEditErrors', errors);
*/
	console.log (statement);
	
    Meteor.call('statementInsert', statement, function(error, statementId) {
      if (error){
        throwError(error.reason);
      } else {
        $sujet.val('');
		$propriete.val('');
		$objet.val('');
      }
    });
  }
});