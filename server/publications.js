Meteor.publish('posts', function(options) {
check(options, {
    sort: Object,
    limit: Number
  });
  return Posts.find({}, options);
});

Meteor.publish('singlePost', function(id) {
  check(id, String)
  return Posts.find(id);
});

Meteor.publish('comments', function(postId) {
  check(postId, String);
  return Comments.find({postId: postId});
});

Meteor.publish('statements', function(postId) {
  check(postId, String);
  return Statements.find({postId: postId});
});

Meteor.publish('notifications', function() {
  return Notifications.find({userId: this.userId, read: false});
});

//Houston.add_collection(Meteor.posts);
//Houston.add_collection(Meteor.comments);
//Houston.add_collection(Meteor.users);
//Houston.add_collection(Houston._admins);