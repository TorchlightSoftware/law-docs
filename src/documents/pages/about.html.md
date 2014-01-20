---
title: About
layout: page
pageOrder: 1
---

# Law

Less strictly constitutional and more strictly awesome.

This project was motivated by the desire to take a lot of validation and error handling logic out of our services, and put it in a declarative layer.

## Credit/Inspiration

Our approach to policies was inspired by the filter lifecycle from Ruby on Rails.  The argument validations take some ideas from Design By Contract, e.g. preconditions.  Applying validators to default names was suggested by @JosephJNK.  I am interested to see if this will be conducive to creating a 'ubiquitous language' as described by Eric Evans in Domain Driven Design.

The separation of Express and Connect has influenced our decision to do the same.  I think that while frameworks can lead to gains in terms of productivity, a library has greater potential for re-use.

Many thanks to @wearefractal (@amurray, @contra), @JosephJNK, and @uberscientist for conversations and collaboration on application design with functional and declarative programming.

## Dependencies

Since version 0.1.1 Law supports declarative dependency injection.  The two built in loaders are:

* services: call sibling services
* lib: a shortcut to require

This lets us do static analysis of dependencies, and can be used as a way of making side effects explicit.

```
module.exports =
  required: ['sessionId']
  dependencies:
    services: ['aHelperService']
    lib: ['lodash']

  service: (args, done, {services, require}) ->
    args = lib.lodash.merge {myOpt: 1}, args
    services.aHelperService args, done
```

To add more loaders, just plug in a resolvers object when you load your services:

```coffee-script
resolvers = {
  myLoader: (name) -> loadIt(name)
}

law.create {services, jargon, policy, resolvers}
```


## Value

Through this approach we accomplish the following:

1. Decoupling between validations and domain logic
2. Access control is described in one place
3. The preconditions for services are declarative

Because the structure binding these pieces together is declarative, we can easily make it visible for analysis and troubleshooting.  Here is a printout from the sample application.

```coffee-script
#> console.log law.printFilters services

{ dashboard: [ 'filters/isLoggedIn', 'filters/setIsOnline', 'dashboard' ],
  'filters/isLoggedIn':
   [ 'sessionId.exists',
     'sessionId.isValid(SessionId)',
     'filters/isLoggedIn' ],
  'filters/setIsOnline': [ 'filters/setIsOnline' ],
  getRole: [ 'sessionId.exists', 'sessionId.isValid(SessionId)', 'getRole' ],
  login: [ 'login' ] }
```

## Project Status

This should be considered an alpha release.  The API may change.  It was developed within an active project with the intent to only build the features which give us a clear advantage.  Additional features will be added as required for the parent project.

Discussion/feedback is welcome.  You can reach me on twitter @qbitmage.

Future goals/possibilities:

1. Unit tests for each component file.
2. Standard adapters for websocket RPC, REST
3. Enforce post-conditions?
4. Development of a contract-driven web framework.

## The Fine Print

(MIT License)

Copyright (c) 2013 Torchlight Software <info@torchlightsoftware.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
