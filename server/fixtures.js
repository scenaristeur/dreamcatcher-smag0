// Données de préinstallation
// HOUSTON? REINITIALISER L'ADMIN :  db.houston_admins.drop(), https://github.com/gterrono/houston/issues/345
//GEO, PHOTO : https://www.meteor.com/utilities
if (Posts.find().count() === 0) {
  var now = new Date().getTime();

  // Créer deux utilisateurs
 /* var davId = Meteor.users.insert({
	  profile: {name: 'David'}},
	  emails.0.address: scenaristeur@gmail.com
	  );*/
 /*  var tomId = Meteor.users.insert({
    profile: { name: 'Tom Coleman',email: 'tom.col@test.fr',type: 'Personne', geo: '45,45' }
  });
 var tomId = Meteor.users.insert({
    profile: { name: 'Tom Coleman',email: 'tom.col@test.fr',type: 'Personne', geo: '45,45' }
  });
  var tom = Meteor.users.findOne(tomId);
  var sachaId = Meteor.users.insert({
    profile: { name: 'Sacha Greif',email: 'Sac0.Gr@test.fr',type: 'Personne', geo: '44,44' }
  });
  var sacha = Meteor.users.findOne(sachaId); 

  var telescopeId = Posts.insert({
    title: 'Introducing Telescope',
    userId: sacha._id,
    author: sacha.profile.name,
    url: 'http://sachagreif.com/introducing-telescope/',
    submitted: new Date(now - 7 * 3600 * 1000),
    commentsCount: 2,
    upvoters: [],
    votes: 0,
	description : 'une petite description'
  });

  Comments.insert({
    postId: telescopeId,
    userId: tom._id,
    author: tom.profile.name,
    submitted: new Date(now - 5 * 3600 * 1000),
    body: "C'est un projet intéressant Sacha, est-ce-que je peux y participer ?"
  });

  Comments.insert({
    postId: telescopeId,
    userId: sacha._id,
    author: sacha.profile.name,
    submitted: new Date(now - 3 * 3600 * 1000),
    body: 'Bien sûr Tom !'
  });

  Posts.insert({
    title: 'Meteor',
    userId: tom._id,
    author: tom.profile.name,
    url: 'http://meteor.com',
    submitted: new Date(now - 10 * 3600 * 1000),
    commentsCount: 0,
    upvoters: [],
    votes: 0,
	description : 'une grande description'
  });

  Posts.insert({
    title: 'The Meteor Book',
    userId: tom._id,
    author: tom.profile.name,
    url: 'http://themeteorbook.com',
    submitted: new Date(now - 12 * 3600 * 1000),
    commentsCount: 0,
    upvoters: [],
    votes: 0,
	description : 'une petite description oulalla'
  });

  for (var i = 0; i < 10; i++) {
    Posts.insert({
      title: 'Test post #' + i,
      author: sacha.profile.name,
      userId: sacha._id,
      url: 'http://google.com/?q=test-' + i,
      submitted: new Date(now - i * 3600 * 1000 + 1),
      commentsCount: 0,
      upvoters: [],
      votes: 0,
	  description : 'une petite description'+i
    });
  }*/
}