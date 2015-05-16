# Meteor field-level Security [![Build Status](https://travis-ci.org/maxnowack/meteor-collection-security.svg)](https://travis-ci.org/maxnowack/meteor-collection-security)

Meteor package that provides defining field-level security rules

## Installation

```
    meteor add maxnowack:fieldlevelsec
```

## Description

With this package, you can define your security rules on field level.
Current Features are: defining allow/deny rules for specific fields and control if fields will be exposed in queries.

#### Sounds good, but for what could I need it?
Let me mention some examples:
1. Deny an update if a specific field is filled (but allow an insert)
2. Hide secret fields in publications, without specifying the `fields` option in all of your publications.
3. ...


## How it works

#### Allow/deny
A `allow` and a `deny` method will be automatically created for the collection, on which you adding some rules. This method iterates over the fields and will apply your rules.
The logic if a write will be allowed, is the same like in the normal allow/deny rules.
> Meteor allows the write only if no `deny` rules return `true` and at least one `allow` rule returns `true`.

#### Visibility
To enable the `visible` functionality, we are replacing the `find` method on collection. Before the original find will be called, we rules will be applied and the `fields` option will be filled automatically.

## Usage

First, create your collection
```javascript
  var Posts = new Mongo.Collection('posts');
```

Now attach one or multiple security rules
```javascript  
  Posts.attachRules({
    name: { // fieldname
      // see options below
    },
    secret: { // another fieldname
      // see options below
    }
  });
```

### Options
|Name|Type|Description|
|----|----|-----------|
|allow|Boolean/Object/Function|Define if a field is writable. Parameters if function defined: userId, doc, fieldNames, modifier (fieldNames and modifier are only filled on update)|
|[allow.insert]|Boolean/Function|Writable on insert. Parameters if function defined: userId, doc|
|[allow.update]|Boolean/Function|Writable on update. Parameters if function defined: userId, doc, fieldNames, modifier|
|[allow.remove]|Boolean/Function|Allow remove of documents with this field. Parameters if function defined: userId, doc|
|deny|Boolean/Object/Function|Define if a field is writable. Parameters if function defined: userId, doc, fieldNames, modifier (fieldNames and modifier are only filled on update)|
|[deny.insert]|Boolean/Function|Writable on insert. Parameters if function defined: userId, doc|
|[deny.update]|Boolean/Function|Writable on update. Parameters if function defined: userId, doc, fieldNames, modifier|
|[deny.remove]|Boolean/Function|Allow remove of documents with this field. Parameters if function defined: userId, doc|
|visible|Boolean/Function|Define if field should be visible (limit fields of a "find" call). The parameters are the same as those of the corresponding "find" call. WARNING! If you're hiding a field, the field will be hidden on the server also. It's better to define a function and only show the field, if a specific condition is met.|

### Allow / Deny

Let's make the field 'name' writable
```javascript  
  Posts.attachRules({
    name: { // fieldname
      allow: true // the field "name" is writable
    }
  });
```

You can also use the deny flag
```javascript  
  Posts.attachRules({
    name: { // fieldname
      deny: true // the field "name" isn't writable
    }
  });
```

It's also possible, to break it down to insert/update/remove flags
```javascript  
  Posts.attachRules({
    name: { // fieldname
      allow: {
        insert: true,   // the field 'name' is writable on inserts
        update: false,  // but not update
        remove: false   // if 'remove' returns 'false', the whole record cannot be deleted if the field is filled
      }
    }
  });
```


If you want it more complex, you can define functions
```javascript  
  Posts.attachRules({
    name: { // fieldname
      allow: {
        insert: true,
        update: function(userId, doc, fieldNames, modifier) {
          user = Meteor.users.findOne(userId);
          return user.isAdmin();
        },
        remove: true
      }
    }
  });
```

### Visibility

You're also able to define if fields are published to clients or not
```javascript  
  // Show field
  Posts.attachRules({
    name: { // fieldname
      visible: true // will be exposed in a publication
    }
  });

  // Hide field
  Posts.attachRules({
    name: { // fieldname
      visible: false // will be hidden in a publication
    }
  });
```

The 'visible' option can also be a function
```javascript  
  Posts.attachRules({
    secret: { // fieldname
      visible: function(selector, options) {
        var userId = options.security.userId;
        var user = Meteor.users.findOne(userId);

        return user.isAdmin();
      }
    }
  });
```
