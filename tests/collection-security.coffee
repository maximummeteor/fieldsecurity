Posts = new Meteor.Collection('posts')
if Meteor.isServer
  CollectionSecurity.setLogging true
  Posts.attachSecurity
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

  Meteor.publish 'posts', ->
    Posts.find {}, security: visible: true

if Meteor.isClient
  Meteor.subscribe 'posts', ->
    Tinytest.addAsync 'Collection-Security - allow all', (test, next) ->
      Posts.insert name: 'test', (err) ->
        test.isUndefined err, 'err should be empty'
        next()

    Tinytest.addAsync 'Collection-Security - allow only insert', (test, next) ->
      id = Posts.insert
        name: 'test'
        createdAt: new Date()
      , (err) ->
        test.isUndefined err, 'err should be empty'

        Posts.update id, $set: createdAt: new Date(), (err) ->
          test.isNotUndefined err, 'err should not be empty'
          next()

    Tinytest.addAsync 'Collection-Security - allow insert with function', (test, next) ->
      id = Posts.insert
        name: 'test'
        author: 'max'
      , (err) ->
        test.isUndefined err, 'err should be empty'

        Posts.update id, $set: author: 'someone else', (err) ->
          test.isNotUndefined err, 'err should not be empty'
          next()

    Tinytest.addAsync 'Collection-Security - deny all', (test, next) ->
      id = Posts.insert
        name: 'test'
        internal:
          foo: 'bar'
      , (err) ->
        test.isNotUndefined err, 'err should not be empty'
        next()

    Tinytest.addAsync 'Collection-Security - hide field', (test, next) ->
      Posts.insert
        name: 'test'
        hidden: 'hello'
      , (err, id) ->
        posts = Posts.find _id: id
        post = posts.fetch()[0]

        test.isUndefined post.hidden, 'test should be empty'
        next()

    Tinytest.addAsync 'Collection-Security - hide field with function', (test, next) ->
      Posts.insert
        name: 'test'
        secret: 'hello'
      , (err, id) ->
        posts = Posts.find _id: id
        post = posts.fetch()[0]
        console.log post

        test.equal post.secret, 'hello', 'secret should be "hello"'
        next()
