Posts = new Meteor.Collection('posts')
Authors = new Meteor.Collection('authors')
if Meteor.isServer
  FieldSecurity.setLogging true
  Posts.attachRules
    name:
      allow: true
    createdAt:
      allow:
        insert: true
        update: false
        remove: true
    author:
      allow: (userId, doc) ->
        return false if doc.author is 'max'
        return true
    internal:
      deny: true
    hidden:
      visible: false
    secret:
      visible: (selector, options) ->
        return options?.security?.visible

  Authors.attachCRUD
    name:
      create:
        allow: true
        deny: false
      read: true
      update:
        allow: true
        deny: false
      delete:
        allow: true
        deny: false

  Meteor.publish 'posts', ->
    Posts.find {}, security: visible: true

  Meteor.publish 'authors', ->
    Authors.find()

if Meteor.isClient
  Meteor.subscribe 'posts', ->
    Tinytest.addAsync 'FieldSecurity - allow all', (test, next) ->
      Posts.insert name: 'test', (err) ->
        test.isUndefined err, 'err should be empty'
        next()

    Tinytest.addAsync 'FieldSecurity - allow only insert', (test, next) ->
      id = Posts.insert
        name: 'test'
        createdAt: new Date()
      , (err) ->
        test.isUndefined err, 'err should be empty'

        Posts.update id, $set: createdAt: new Date(), (err) ->
          test.isNotUndefined err, 'err should not be empty'
          next()

    Tinytest.addAsync 'FieldSecurity - allow insert with function', (test, next) ->
      id = Posts.insert
        name: 'test'
        author: 'max'
      , (err) ->
        test.isUndefined err, 'err should be empty'

        Posts.update id, $set: author: 'someone else', (err) ->
          test.isNotUndefined err, 'err should not be empty'
          next()

    Tinytest.addAsync 'FieldSecurity - deny all', (test, next) ->
      id = Posts.insert
        name: 'test'
        internal:
          foo: 'bar'
      , (err) ->
        test.isNotUndefined err, 'err should not be empty'
        next()

    Tinytest.addAsync 'FieldSecurity - hide field', (test, next) ->
      Posts.insert
        name: 'test'
        hidden: 'hello'
      , (err, id) ->
        posts = Posts.find _id: id
        post = posts.fetch()[0]

        test.isUndefined post.hidden, 'test should be empty'
        next()

    Tinytest.addAsync 'FieldSecurity - hide field with function', (test, next) ->
      Posts.insert
        name: 'test'
        secret: 'hello'
      , (err, id) ->
        posts = Posts.find _id: id
        post = posts.fetch()[0]

        test.equal post.secret, 'hello', 'secret should be "hello"'
        next()
  Meteor.subscribe 'authors', ->
    Tinytest.addAsync 'FieldSecurity - use CRUD', (test, next) ->
      Authors.insert
        name: 'test'
        secret: 'hello'
      , (err, id) ->
        authors = Authors.find _id: id
        author = authors.fetch()[0]

        test.equal author.secret, 'hello', 'secret should be "hello"'
        next()
