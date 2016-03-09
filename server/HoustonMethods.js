//CUSTOMISATION https://atmospherejs.com/houston/admin

Houston.methods("Posts", {
  "Publish": function (post) {
    Posts.update(post._id, {$set: {published: true}});
    return post.name + " published successfully.";
  }
});
//template
Houston.menu({
  'type': 'template',
  'use': 'my_analytics_template',
  'title': 'Analytics'
},
 {  'type': 'template',
  'use': 'my_graphe_template',
  'title': 'Graphe'}
  );
  //lien
 Houston.menu({
  'type': 'link',
  'use': 'http://google.com',
  'title': 'Google',
  'target': 'blank'
});