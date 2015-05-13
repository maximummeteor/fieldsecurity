# Meteor Collection Security [![Build Status](https://travis-ci.org/maxnowack/meteor-collection-security.svg)](https://travis-ci.org/maxnowack/meteor-collection-security)

Meteor package that provides a simple way to define security rules for collections

## Installation

```
    meteor add maxnowack:collection-security
```

## Description

With this package, you can define your security rules in a more simple way.
Current Features are: defining allow/deny rules based on fields and control if specific fields can be exposed to the client.

## Usage

First, create your collection
```javascript
  var Posts = new Mongo.Collection('posts');
```

Now attach one or multiple security rules
```javascript  
  Posts.addSecurityRule({
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
|visible|Boolean/Function|Define if field should be visible on client. The parameters are the same as those of the corresponding "find" call.|

### Allow / Deny

Let's make the field 'name' writable
```javascript  
  Posts.addSecurityRule({
    name: { // fieldname
      allow: true // the field "name" is writable
    }
  });
```

You can also use the deny flag
```javascript  
  Posts.addSecurityRule({
    name: { // fieldname
      deny: true // the field "name" isn't writable
    }
  });
```

It's also possible, to break it down to insert/update/remove flags
```javascript  
  Posts.addSecurityRule({
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
  Posts.addSecurityRule({
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

### Client visibility

You're also able to define if fields are published to clients or not
```javascript  
  // Show field
  Posts.addSecurityRule({
    name: { // fieldname
      visible: true // will be exposed in a publication
    }
  });

  // Hide field
  Posts.addSecurityRule({
    name: { // fieldname
      visible: false // will be hidden in a publication
    }
  });
```

The 'visible' option can also be a function
```javascript  
  Posts.addSecurityRule({
    secret: { // fieldname
      visible: function(selector, options) {
        var userId = options.security.userId;        
        var user = Meteor.users.findOne(userId);

        return user.isAdmin();
      }
    }
  });
```
