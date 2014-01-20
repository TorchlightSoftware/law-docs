---
title: Tutorial
layout: page
pageOrder: 4
---

## Application Files

Following are some possible uses of Law.  Further options are described in the [full API documenation](/pages/api).

Here's an example service.  Law will construct a function from this which will enforce the required/optional parameters.  Both optional and required parameters will run any associated validations.

### getRole.coffee
```coffee-script
module.exports =
  required: ['sessionId']
  optional: ['specialKey']
  service: ({sessionId, specialKey}, done) ->

    # check the sessionId against the database

    done null, {role: 'Supreme Commander'}
```

Here's some example argument types, and their validations.  Law makes these available in the definition of services.  You can think of them as the language that a particular set of services share.  Whenever these names are used in service arguments, their meanings will be enforced by the rules you set here.

### jargon.coffee
```coffee-script
redisId = /[a-z0-9]{16}/
mongoId = /[a-f0-9]{24}/

module.exports = [
    typeName: 'String'
    validation: (arg, assert) ->
      assert typeof arg is 'string'
    defaultArgs: ['email', 'password', 'sessionId', 'userId']
  ,
    typeName: 'SessionId'
    validation: (arg, assert) ->
      assert arg.match redisId
    defaultArgs: ['sessionId']
  ,
    typeName: 'MongoId'
    validation: (arg, assert) ->
      assert arg.match mongoId
    defaultArgs: ['userId']
]
```

Here's an example policy file.  The filters named here are defined as regular services, but they are run in a slightly different context.  If they return an error, the filter stack stops and returns it, otherwise their results are merged into the argument stream and passed on to the next service in the stack.

### policy.coffee
```coffee-script
module.exports =
  filterPrefix: 'filters'
  rules:
    [
      {
        filters: ['isLoggedIn']
        except: [
          'getRole'
          'login'
        ]
      }

      {
        filters: ['setIsOnline']
        only: ['dashboard']
      }
    ]
```
