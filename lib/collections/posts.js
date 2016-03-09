Posts = new Mongo.Collection('posts');

Posts.allow({
  update: function(userId, post) { return ownsDocument(userId, post); },
  remove: function(userId, post) { return ownsDocument(userId, post); },
});

Posts.deny({
  update: function(userId, post, fieldNames) {
    // may only edit the following two fields:
    return (_.without(fieldNames, 'url', 'title','description').length > 0);
  }
});

Posts.deny({
  update: function(userId, post, fieldNames, modifier) {
    var errors = validatePost(modifier.$set);
    return errors.title || errors.url || errors.description;
  }
});

validatePost = function (post) {
  var errors = {};

  if (!post.title)
    errors.title = "un petit lien ?";
  
  if (!post.url)
    errors.url =  "C'est mieux avec un titre ! ";

  if (!post.description)
    errors.description =  "STP, rajoute une description";

  return errors;
}





Meteor.methods({
  postInsert: function(postAttributes) {
    check(this.userId, String);
    check(postAttributes, {
      title: String,
      url: String,
	  description: String
    });
    
    var errors = validatePost(postAttributes);
    if (errors.title || errors.url || errors.description)
      throw new Meteor.Error('invalid-post', "You must set a title , URL  and description for your post");
    
    var postWithSameLink = Posts.findOne({url: postAttributes.url});
    if (postWithSameLink) {
      return {
        postExists: true,
        _id: postWithSameLink._id
      }
    }
	
	var postWithSameTitle = Posts.findOne({title: postAttributes.title});
    if (postWithSameTitle) {
      return {
        postExists: true,
        _id: postWithSameTitle._id
      }
    }
    
    var user = Meteor.user();
    var post = _.extend(postAttributes, {
      userId: user._id, 
      author: user.username, 
      submitted: new Date(),
      commentsCount: 0,
	  statementsCount: 0,
	  upvoters: [],
	  votes: 0
    });
    
    var postId = Posts.insert(post);
    
    return {
      _id: postId
    };
  },
  
    upvote: function(postId) {
    check(this.userId, String);
    check(postId, String);
	
	  var affected = Posts.update({
    _id: postId,
    upvoters: {$ne: this.userId}
  }, {
    $addToSet: {upvoters: this.userId},
    $inc: {votes: 1}
  });
  if (! affected)
    throw new Meteor.Error('invalid', "Vous n'avez pas pu voter pour ce post.");
	
  }
});

