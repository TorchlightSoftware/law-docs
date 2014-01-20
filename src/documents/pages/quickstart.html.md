---
title: Quickstart
layout: page
pageOrder: 3
---

## Getting Started

```bash
npm install law
```

Before you can start using the facilities mentioned above in your app, you'll need to wire some things up.  This being a library intended to support a not-yet-released framework, no assumptions are made about the locations of your files.  You'll need something like the following to initialize and connect the services when your application starts.

### initLaw.coffee
```coffee-script
should = require 'should'
{join} = require 'path'

# lib stuff
connect = require 'connect'
{load, create, printFilters} = require 'law'

# files from the sample app
serviceLocation = join __dirname, '../sample/app/domain/auth/services'
argTypes = require '../sample/app/domain/auth/jargon'
policy = require '../sample/app/domain/auth/policy'

services = load serviceLocation
services = create {services, jargon, policy}
console.log "I am the law:", printFilters services
```

This gives you a hash of {serviceName, serviceDef}.  Now if you wanted to use that, say as connect middleware, you could write up some basic routing like so.

### connectAdapter.coffee
```
app = connect()
app.use (req, res) ->

  # find service to call, or return 404
  pathParts = req._parsedUrl.pathname.split('/').remove ''
  resourceName = pathParts[0]
  service = resourceMap[resourceName] or ->
    res.writeHead 404
    res.end()

  # call service
  service {
      url: req.url
      headers: req.headers
      query: req.query || {}
      pathParts: pathParts
      cookies: req.cookies
    }, res

```

## Further Reading

You can find [extended documentation here](/pages/api).
