class CollectionSecurity
  @_utilities:
    any: (array, value) ->
      return true for element in array when element is value
      return false
  @_instances: []
  @_getInstance: (collection) ->
    identifier = collection._name

    # get existing instance
    return instance for instance in @_instances when instance.id is identifier

    # create a new instance if there is no existing one
    instance = new CollectionSecurity collection
    @_instances.push instance
    return instance

  constructor: (@collection) ->
    @id = @collection._name
    @rules = {}

    @collection.allow
      insert: @getSecFunction 'allow', 'insert'
      update: @getSecFunction 'allow', 'update'
      remove: @getSecFunction 'allow', 'remove'
    @collection.deny
      insert: @getSecFunction 'deny', 'insert'
      update: @getSecFunction 'deny', 'update'
      remove: @getSecFunction 'deny', 'remove'

    @collection.find = @buildSecureFind @collection.find

  getSecFunction: (scope, type) ->
    self = this
    (userId, doc, fieldNames, modifier) ->
      fields = fieldNames or []
      fields.push key for key, value of doc if fields.length is 0

      values = []
      for field, fieldRule of self.rules when field in fields
        if typeof fieldRule[scope] is 'object'
          rule = fieldRule[scope][type]
        else
          rule = fieldRule[scope]
        if rule?
          if typeof rule is 'function'
            values.push rule.apply @, arguments
          else
            values.push rule

      return CollectionSecurity._utilities.any values, true

  buildSecureFind: (original) ->
    self = this
    (selector, options) ->
      options = options or {}
      options.fields = options.fields or {}
      for field, fieldRule of self.rules when fieldRule['visible']?
        rule = fieldRule['visible']
        if typeof rule is 'function'
          value = rule.apply @, arguments
        else
          value = rule

        options.fields[field] = if value then 1 else 0

      val = original.apply @, [selector or {}, options]
      return val


  attachSecurity: (rules) ->
    @rules = _.extend @rules, rules



if Mongo?.Collection?
  Mongo.Collection.prototype.attachSecurity = (rules) ->
    instance = CollectionSecurity._getInstance @
    instance.attachSecurity rules

else
  Meteor.Collection.prototype.attachSecurity = (rules) ->
    instance = CollectionSecurity._getInstance @
    instance.attachSecurity rules
