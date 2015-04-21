Posts = new Mongo.Collection('posts');

if (Meteor.isServer) {
  Posts.attachSecurity({
    name: {
      allow: true,
      deny: false
    },
    test: {
      allow: true,
      deny: false,
      visible: false
    }
  });

  Meteor.publish('posts', function(){
    return Posts.find();
  });

  Meteor.startup(function () {
    // code to run on server at startup
  });
}

if (Meteor.isClient) {
  Meteor.subscribe('posts');
  Template.hello.helpers({
    posts: function () {
      return Posts.find()
    }
  });

  Template.hello.events({
    'click button': function () {
      // increment the counter when button is clicked
      Posts.insert({name:'test',test:'hello'});
    }
  });
}
