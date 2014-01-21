---
title: API
layout: page
pageOrder: 2
---
## Definition formats
Law primarily consumes and operates on three important data structures,
which define services, application-specific types and validations ("jargon"),
and the application of policies to the various services ("policy"). These
are described below.

### Services
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

### Jargon
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

### Policy

## `law`

### `create`
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


### `load`
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

<a name="applyMiddleware"></a>
### [`applyMiddleware`](#applyMiddleware)
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

<a name="applyPolicy"></a>
### [`applyPolicy`](#applyPolicy)
#### Description
#### Accepts
#### Returns

### [`applyDependencies`](#applyDependencies)
#### Description
#### Accepts
#### Returns

### [`printFilters`](#printFilters)
#### Description
#### Accepts
#### Returns

### [`graph`](#graph)
#### Description

### [`errors`](#errors)
#### Description

## `law.graph`

### [`adjacentDependencies`](#adjacentDependencies)
#### Description
#### Accepts
#### Returns

### [`adjacencyRelation`](#adjacencyRelation)
#### Description
#### Accepts
#### Returns

### [`connectedDependencies`](#connectedDependencies)
#### Description
#### Accepts
#### Returns

### [`dotNotation`](#dotNotation)
#### Description
#### Accepts
#### Returns

## `law.errors`
### Description

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
