Statements = new Mongo.Collection('statements');

Meteor.methods({
  statementInsert: function(statementAttributes) {
    check(this.userId, String);
    check(statementAttributes, {
      postId: String,
      sujet: String,
	  propriete: String,
	  objet: String
    });
    var user = Meteor.user();
    var post = Posts.findOne(statementAttributes.postId);
    if (!post)
      throw new Meteor.Error('invalid-statement', 'Vous devez statementer sur un post');
    statement = _.extend(statementAttributes, {
      userId: user._id,
      author: user.username,
      submitted: new Date()
    });
	// update the post with the number of statements
	Posts.update(statement.postId, {$inc: {statementsCount: 1}});
       // crée le statementaire et enregistre l'id
    statement._id = Statements.insert(statement);
    // crée maintenant une notification, informant l'utilisateur qu'il y a eu un statementaire
    createStatementNotification(statement);
    return statement._id;
  }
});