---
title: Tutorials
layout: page
tags: ['intro','page']
pageOrder: 3
---
# API tutorial

We will demonstrate the process of building a simple API using Law.

## Problem

First, a problem: we want to store some contact information. We will build an API
to set, get, and delete phone number records from a toy in-memory data store.

## Data model

For simplicity's sake, we will assume that contact names are unique. Our toy
database will then simply be a key-value mapping, with names as the keys, and phone
numbers as the values. We will also assume that we need to only store US-style
phone numbers, roughly of the form `(xxx)-xxx-xxxx`.

## Project structure

We create our initial project directory structure:

```
/app/
 /main.coffee
 /db.coffee
 /services
   /contacts/
     /set.coffee
     /get.coffee
     /delete.coffee
```

Inside the `app/services` directory, we'll include each of our services as
separate files. In particular, we will place all of our contact CRUD services
inside the `contacts` subdirectory. This is not obligatory, but provides a nice,
modular way of organizing our service definitions. It will also have the effect
of namespacing the resulting services

The file `db` will simply export a mutable JavaScript object that will act as
our toy in-memory database for both user sessions and contact data.

The contents of db.coffee will look like this:

```
# app/db.coffee

module.exports = {sessions: {}, contacts: {}}
```

## Sessions

We will suppose that a login/session management API is implemented elsewhere in
the application, and that we can check the validity of a `sessionId` by checking
to see if it maps to the string 'valid' in `db.sessions`. We'll assume that
a `sessionId` is a 16-digit hexadecimal string.

## Our first service

Let's start with our `contact/set` service. This attempts to create a new
contact record if it is not already there, or update one if it exists.
Semantically, it is meant to behave like the HTTP `PUT` method.

We will first write a naive implementation of this service, then show how
it can be refactored using the machinery of Law. This refactoring will then
have immediate benefits, which we will see in our implementation of the remaining
services.

Our `contact/set` service should accept an `args` object containing values for
`name` and `number` properties, as well as a `sessionId` token, to ensure that
only logged-in users can edit the contact list.

```
# app/services/contacts/set.coffee

db = require '../../db'

module.exports = ({sessionId, contactName, phoneNumber}, done) ->
  # Check for existence of required arguments
  unless sessionId
    return done new Error('Missing required argument: sessionId')

  unless contactName
    return done new Error('Missing required argument: name')

  unless number
    return done new Error('Missing required argument: phoneNumber')

  # Make sure that sessionId is a string
  unless typeof sessionId is 'string'
    return done new Error('sessionId must be a string')

  # Check that sessionId is what we expect--a 16-digit hex string.
  sessionIdFormat = /[a-z0-9]{16}/
  unless sessionIdFormat.test(sessionId)
    return done new Error('Malformed sessionId')

  # Make sure the service request comes from a logged-in user
  unless db.sessions[sessionId] is 'valid'
    return done new Error('sessionId not valid')

  # Make sure the contact name is a string
  unless typeof contactName is 'string'
    return done new Error('contactName must be a string')

  # Make sure that `phoneNumber` is well-formed
  # [Source]
  #   http://coffeescriptcookbook.com/chapters/regular_expressions/heregexes
  phoneNumberFormat = ///
    ^\(?(\d{3})\)? # Capture area code, ignore optional parens
    [-\s]?(\d{3})  # Capture prefix, ignore optional dash or space
    -?(\d{4})      # Capture line-number, ignore optional dash
  ///
  unless phoneNumberFormat.test(phoneNumber)
    return done new Error('phoneNumber not well-formed')

  # Finally! We've made it through all our validation conditionals.
  # Our arguments all exist, and are valid.
  # We can finally implement the basic business logic.
  db.contacts[contactName] = phoneNumber

  # We are done, so we simply relinquish control flow
  return done()
```

Interesting. It looks like the meat of our service consists of just one line.
Most of the function body is checking preconditions. We'll come back to that
in a moment.

To call this service *through* Law, we create a `services` object. Law offers
a helper function that lets us simply specify the directory containing all our
services. Thus, the relevant part of our `main.coffee` file would look like this:

```
# app/main.coffee

law = require 'law'

# [...omitted]

# Load service definitions from the filesystem
serviceDefs = law.load './services'

# Wire everything up. We can now call `contact/set` via
# invoking the (callable) value of `services['contact/set']`.
services = law.create {services: serviceDefs}

# [...omitted]
```

So far, it isn't at all clear what benefit we get from calling our function
as a Law service. We are about to see it, however, because now we want to
write our other services. These services will need to check many of the same
runtime preconditions. Law gives us tools to factor this logic out.

First, we wil rewrite our `contact/set` service definition to have an enriched
Law signature. The definition itself will no longer be directly callable, but
the enriched *service* will be via `services['contacts/set']`.

```
db = require '../../db'

module.exports =
  required: ['sessionId', 'contactName', 'phoneNumber']
  service: ({sessionId, contactName, phoneNumber}, done) ->

  # We no longer need to check that our required arguments exist!
  # The rest of the validations are still required, though (for now).

  # Make sure the service request comes from a logged-in user
  unless db.sessions[sessionId] is 'valid'
    return done new Error('sessionId not valid')

  # [...omitted]
```

This is an improvement, but we can do better. Let's make a Jargon file!
We'll use this to define a mapping of argument names (keys to the first
argument of our service) to validations.

```
# app/jargon.coffee

module.exports = [
  # This type simply requires the value to be a string.
  typeName: 'String'
  validation: (arg, assert) ->
    # Note that `assert` is just a callback!
    # We call it `assert` here just for the sake of making our validation
    # function look more like a mini-EDSL.
    assert typeof arg is 'string'
  # In our application, this validation actually applies all of the
  # argument types we've looked at so far.
  defaultArgs: ['sessionId', 'contactName', 'phoneNumber']
 ,
  # Now we have a more specific argument type. Here is where we will
  # place our sessionId well-formedness logic. We'll save the login
  # status check for elsewhere, though.
  typeName: 'SessionId'
  validation: (arg, assert) ->
    sessionIdFormat = /[a-z0-9]{16}/
    assert sessionIdFormat.test(arg)
  defaultArgs: ['sessionId']
 ,
  # Last one! Just the same regex check from earlier.
  typeName: 'PhoneNumber'
  validation: (arg, assert) ->
    phoneNumberFormat = ///
      ^\(?(\d{3})\)? # Capture area code, ignore optional parens
      [-\s]?(\d{3})  # Capture prefix, ignore optional dash or space
      -?(\d{4})      # Capture line-number, ignore optional dash
    ///
    assert phoneNumberFormat.test(arg)
]
```

Alright! Now, when we wire up our Law services, we just require
the Jargon file and pass the resulting data structure to `law.create`:

```
# app/main.coffee

# [...omitted]

services = law.create {
  # Load service definitions from the filesystem
  services: law.load('./services'),
  # Load the exports of our Jargon file
  jargon: require('./jargon')
}

# [...omitted]
```

Since our existence and well-formedness validations are now handled
by Law, our service definition has been simplified to the following:


```
# app/services/contacts/set.coffee

db = require '../../db'

module.exports =
  required: ['sessionId', 'contactName', 'phoneNumber']
  service: ({sessionId, contactName, phoneNumber}, done) ->

  # We no longer need to check that our required arguments exist,
  # are the correct JavaScript type, or are well-formed!

  # We still need to make sure the service request comes
  # from a logged-in user.
  unless db.sessions[sessionId] is 'valid'
    return done new Error('sessionId not valid')

  # The actual act of data storage
  db.contacts[contactName] = phoneNumber

  # We are done, so we simply relinquish control flow
  return done()
```

This is much nicer, and all of our previous validations have
been (1) associated with named concepts in the Jargon file, (2)
are immediately applied to other services with the same argument names.

We can still do better. Law lets us define a Policy file for access
control. This will let us factor out the login check into a service of
its own, and declare its application in one place in our project.

Here is what our `policy.coffee` file will look like:

```
# app/policy.coffee

module.exports =
  # This just indicates that the filter services are not just in the
  # `services` subdirectory of our project, are further kept together
  # in a `filters` subdirectory, and namespaced with `services/filters`.
  filterPrefix: 'filters'
  rules: [
    # We expect a filtering service called `isLoggedIn` to be called
    # before every service
    filters: ['isLoggedIn']
    # ...except for the actual `login` service, which we will not
    # define in this tutorial
    except: ['login']
  ]
```

We modify our Law setup to use the Policy file:

```
# app/main.coffee

services = law.create {
  # Load service definitions from the filesystem
  services: law.load('./services'),
  # Load the exports of our Jargon file
  jargon: require('./jargon')
  # Load the exported Policy data structure, too
  policy: require('./policy')
}
```

And define our `isLoggedIn` filter as a service in the appropriate directory,
which we also indicated in our Policy file:

```
# app/services/filters/isLoggedIn.coffee
db = require '../../db.coffee'

module.exports =
  required: ['sessionId']
  service: ({sessionId}, done) ->

    if db.sessions[sessionId] is 'valid'
      return done()
    else
      return done new Error('sessionId not valid')
```

Now, we have the final form of our `contact/set` service:

```
# app/services/contacts/set.coffee

db = require '../../db'

module.exports =
  required: ['sessionId', 'contactName', 'phoneNumber']
  service: ({contactName, phoneNumber}, done) ->

  # As before, we no longer need to check that our required arguments
  # exist, are the correct JavaScript type, or are well-formed!

  # We can also be sure that the service is being called by a logged-in
  # user with a valid `sessionId`, so we no longer need to pull it out
  # of the first args object of the service.

  # The ONLY code in our service is the actual act of data storage!
  # If this were, say, an asynchronous call to a database driver, that
  # complexity would be easier to approach, test, and worry about on its
  # own, without the validation code.

  db.contacts[contactName] = phoneNumber

  return done()
```

So, after all that work, what about our other services? Thanks to our use of
Law to declare our validation logic (and expose it to all services), the rest
of our services are almost trivial to write correctly:

```
# app/services/contacts/get.coffee

db = require '../../db'

module.exports =
  required: ['sessionId', 'contactName']
  service: ({contactName}), done) ->

    phoneNumber = db[contactName]

    if phoneNumber
      return done err, {phoneNumber}
    else
      return done new Error("No number found for contact '#{contactName}'")
```

```
# app/services/contacts/delete.coffee

db = require '../../db'

module.exports =
  required: ['sessionId', 'contactName']
  service: ({contactName}), done) ->

    success = delete db[contactName]

    if success
      return done()
    else
      return done new Error("Could not delete contact '#{contactName}'")
```

And to recap, our final directory structure looks like this:

```
/app/
 /main.coffee
 /db.coffee
 /jargon.coffee
 /policy.coffee
 /services
   /filters/
     /isLoggedIn.coffee
   /contacts/
     /set.coffee
     /get.coffee
     /delete.coffee
```
