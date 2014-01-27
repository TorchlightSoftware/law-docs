---
title: API
layout: page
pageOrder: 1
---
<a name="contents"></a>
## [Contents](#contents)
-  [Usage](#usage)
  -  [Initializing services](#initializing-services)
-  [Definition formats](#definition-formats)
  -  [Services](#services)
  -  [Jargon](#jargon)
  -  [Policy](#policy)
-  [`law`](#law)
  -  [`create`](#law.create)
  -  [`load`](#law.load)
  -  [`applyMiddleware`](#law.applyMiddleware)
  -  [`applyPolicy`](#law.applyPolicy)
  -  [`applyDependencies`](#law.applyDependencies)
  -  [`printFilters`](#law.printFilters)
  -  [`graph`](#law.graph)
  -  [`errors`](#law.errors)

<a name="usage"></a>
## [Usage](#usage)
<a name="initializing-services"></a>
### [Initializing services](#a-basic-service)
Here we will demonstrate how to define a basic Law service
called `echo` which simply returns its input *if the arguments
contain a well-formed argument called `sessionId`.*

First, we need to create an object which maps *service names*
to *service definitions*. The simplest possible way of doing this
is as follows:
```
services =
  echo: (args, next) ->
    # The callback `next` has signature `(err, data)`.
    # Given an object `arg` of named arguments and a callback `next`
    # with signature `(err, data)`, simply return while calling
    # `next` with a `null` first argument (meaning no error occurred).
    next null, args
```
At this point, all we have is a function. We would then use `law.create`
to take this

<a name="definition-formats"></a>
## [Definition formats](#definition-formats)
Law primarily consumes and operates on three important data structures,
which define services, application-specific types and validations ("jargon"),
and the application of policies to the various services ("policy"). These
are described below.

<a name="services"></a>
### [Services](#services)
Array of service definitions, which are objects
of the form `{serviceName: serviceDef}`.

The `serviceDef` can either a function with signature `(args, callback)`,
or an object of the form:
```
{
  required: [] # array of required arguments
  dependencies:
    # Key is a resolvable dependency category
    # Value is an array of valid dependency names
    depCategory: ['depName1', 'depName2', ...]
  # Actual async function defining the service
  service: (args, done) -> ...
}
```

<a name="jargon"></a>
### [Jargon](#jargon)
A "jargon" definition, which is an array of type definitions of the form:
```
{
  # Name of the type being defined
  typeName: "nameOfType # String

  # Validation function with signature `(arg, assert)`
  validation: (arg, assert) -> ...

  defaultArgs: ...
}
```

<a name="policy"></a>
### [Policy](#policy)

<a name="law"></a>
## [`law`](#law)

<a name="law.create"></a>
### [`create`](#law.create)
#### Description
This is a convenience method to wrap service definitions
in a complete middleware stack. This is what you will want
to use in most situations.

#### Accepts
- `Object` :
  - `services` : `<ServiceDefs>`
  - `jargon` : `<JargonDef>`
  - `policy` : `<PolicyDef>`
  - `resolvers` : `<Object>`

    Object mapping dependency categories to means of resolving.

#### Returns
An object of the form:
```
{
  serviceName: <ServiceObject>
}
```
Where `ServiceObject` is the function from the service definition, but
endowed with validations and runtime dependency injection.

<a name="law.create"></a>
### [`load`](#law.load)
#### Description
Loads service definitions from a directory in the file system.
Services are assumed to be defined in separate files.

#### Accepts
- `folder` : `String`

  Path to the folder containing the service definitions as modules.

- `[prefix]` : `String` (Optional)

  Optional prefix for the resulting service names.

#### Returns
- `serviceDefs` : `<Object(ServiceName, ServiceDef)>`

  Where `serviceDefs` is an object mapping a `ServiceName` : `String` to
  the service definition exported by each discovered module in `folder`.

<a name="law.applyMiddleware"></a>
### [`applyMiddleware`](#law.applyMiddleware)
#### Description
Wraps services with access/lookup policy.

#### Accepts
- `services` : `<ServiceDefs>`
- `jargon` : `<JargonDef>`

#### Returns
- `<Object>` :

  ```
  {
    serviceName: <ServiceObject>
  }
  ```
Where `ServiceObject` is the function from the service definition, but
endowed with call-time validations defined by the jargon file.

<a name="law.applyPolicy"></a>
### [`applyPolicy`](#law.applyPolicy)
#### Description
#### Accepts
#### Returns

<a name="law.applyDependencies"></a>
### [`applyDependencies`](#law.applyDependencies)
#### Description
#### Accepts
#### Returns

<a name="law.printFilters"></a>
### [`printFilters`](#law.printFilters)
#### Description
#### Accepts
#### Returns

<a name="law.graph"></a>
### [`graph`](#law.graph)
#### Description



<a name="law.graph"></a>
## [`law.graph`](`graph`)

<a name="law.graph.adjacentDependencies"></a>
### [`adjacentDependencies`](#law.graph.adjacentDependencies)
#### Description
#### Accepts
#### Returns

<a name="law.graph.adjacencyRelation"></a>
### [`adjacencyRelation`](#law.graph.adjacencyRelation)
#### Description
#### Accepts
#### Returns

<a name="law.graph.connectedDependencies"></a>
### [`connectedDependencies`](#law.graph.connectedDependencies)
#### Description
#### Accepts
#### Returns

<a name="law.graph.dotNotation"></a>
### [`dotNotation`](#law.graph.dotNotation)
#### Description
#### Accepts
#### Returns

<a name="law.errors"></a>
### [`errors`](#law.errors)
#### Description

Law provides standard subtypes of `Error`, enriched using the `tea-error`
library (https://github.com/qualiancy/tea-error). This means a `properties`
object can be attached to the `Error` instance upon construction, as well
as an indicator of the function that the stack trace should start from.

We provide a `LawError` subtype of `Error` that acts as a common parent to
all the more specific error subtypes. Extensions to Law should extend this
type to obtain the benefits of `tea-error`, as well as permitting distinction
between instances of Law errors from application errors.


### [`LawError`](#LawError)
#### Description
Common parent type of errors within the Law library (and extensions).
Endowed with extra metadata couresty `tea-error`.

### [`FailedArgumentLookupError`](#FailedArgumentLookupError)
#### Description
Unused.

### [`InvalidArgumentError`](#InvalidArgumentError)
#### Description
An argument passed to a Law service exists, but has failed a validation.
Occurs at call time

### [`InvalidArgumentsObjectError`](#InvalidArgumentsObjectError)
#### Description
The `args` argument of a service call was not an instance of `object`.
Occurs at call time.

### [`InvalidServiceNameError`](#InvalidServiceNameError)
#### Description
A serviceName that appears in the policy file has no referent amongst the actual
discovered services. Occurs when processing the policy file.

### [`MissingArgumentError`](#MissingArgumentError)
#### Description
A required argument was not present in the `args` object passed to the service.
Occurs at call time.

### [`NoFilterArrayError`](#NoFilterArrayError)
#### Description
Thrown when a (malformed) rule in the policy file does not have any filters.
Occurs at setup time, when applying policy rules to services.

### [`ServiceDefinitionNoCallableError`](#ServiceDefinitionNoCallableError)
#### Description
A service definition did not provide a callable (instance of `function`).
Occurs when when wrapping services at setup time.

### [`ServiceDefinitionTypeError`](#ServiceDefinitionTypeError)
#### Description
The service definition was neither a function nor a richer service definition
object containing metadata and optional Law declarations. Occurs at setup time.

### [`ServiceReturnTypeError`](#ServiceReturnTypeError)
#### Description
The return value of a service (chained in a computed stack of services) is
not an object. Occurs at call time.

### [`UnresolvableDependencyError`](#UnresolvableDependencyError)
#### Description
A particular dependency in a valid (resolvable) dependency category could
not be resolved using the configuration given

### [`UnresolvableDependencyTypeError`](#UnresolvableDependencyTypeError)
#### Description
A service declared an unresolvable dependency category. For example, if the
resolver configuration doesn't define a way to resolve dependencies in a
`services` category, this error would be thrown. Occurs at setup time, when
resolving dependencies.
