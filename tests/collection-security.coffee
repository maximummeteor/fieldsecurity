bootstrapCollection = (name, rules) ->
  Posts = new Mongo.Collection name

  if Meteor.isServer
    Posts.attachSecurity rules

    Meteor.publish name, ->
      Posts.find()

  if Meteor.isClient
    Meteor.subscribe name

  return posts = Posts

Tinytest.addAsync 'Collection-Security - allow all', (test, next) ->
  Posts = bootstrapCollection 'posts_1',
    name:
      allow: true

  if Meteor.isClient
    Posts.insert name: 'test', (err) ->
      test.isUndefined err, 'err should be empty'
      next()
  else
    next()

Tinytest.addAsync 'Collection-Security - allow only insert', (test, next) ->
  Posts = bootstrapCollection 'posts_2',
    name:
      allow:
        insert: true
        update: false
        remove: false

  if Meteor.isClient
    id = Posts.insert name: 'test', (err) ->
      test.isUndefined err, 'err should be empty'

    Posts.update id, $set: name: 'test2', null, (err) ->
      test.isNotNull err, 'err should not be empty'
      next()
  else
    next()

Tinytest.addAsync 'Collection-Security - deny all', (test, next) ->
  Posts = bootstrapCollection 'posts_3',
    name:
      deny: true

  if Meteor.isClient
    id = Posts.insert name: 'test', (err) ->
      test.isNotNull err, 'err should not be null'
      next()
  else
    next()

Tinytest.addAsync 'Collection-Security - invisible field (find)', (test, next) ->
  Posts = bootstrapCollection 'posts_4',
    name:
      allow: true
    test:
      allow: true
      visible: false

  if Meteor.isClient
    id = Posts.insert
      name: 'test'
      test: 'hello'
    posts = Posts.find _id: id
    post = posts.fetch()[0]

    test.isUndefined post.test, 'test should be null'
    next()
  else
    next()
