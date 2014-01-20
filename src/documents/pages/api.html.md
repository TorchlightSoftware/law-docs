---
title: API
layout: page
pageOrder: 2
---

## `law`

### `create`
#### Description
This is a convenience method to wrap service definitions
in a complete middleware stack. This is what you will want
to use in most situations.

#### Accepts
- services
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
- jargon
- policy
- resolvers

#### Returns

### `load`
#### Description
#### Accepts
#### Returns

### `applyMiddleware`
#### Description
#### Accepts
#### Returns

### `applyPolicy`
#### Description
#### Accepts
#### Returns

### `applyDependencies`
#### Description
#### Accepts
#### Returns

### `printFilters`
#### Description
#### Accepts
#### Returns

### `graph`
#### Description

### `errors`
#### Description

## `law.graph`

### `adjacentDependencies`
#### Description
#### Accepts
#### Returns

### `adjacencyRelation`
#### Description
#### Accepts
#### Returns

### `connectedDependencies`
#### Description
#### Accepts
#### Returns

### `dotNotation`
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

### `LawError`
#### Description
Common parent type of errors within the Law library (and extensions).
Endowed with extra metadata couresty `tea-error`.

### `FailedArgumentLookupError`
#### Description
Unused.

### `InvalidArgumentError`
#### Description
An argument passed to a Law service exists, but has failed a validation.
Occurs at call time

### `InvalidArgumentsObjectError`
#### Description
The `args` argument of a service call was not an instance of `object`.
Occurs at call time.

### `InvalidServiceNameError`
#### Description
A serviceName that appears in the policy file has no referent amongst the actual
discovered services. Occurs when processing the policy file.

### `MissingArgumentError`
#### Description
A required argument was not present in the `args` object passed to the service.
Occurs at call time.

### `NoFilterArrayError`
#### Description
Thrown when a (malformed) rule in the policy file does not have any filters.
Occurs at setup time, when applying policy rules to services.

### `ServiceDefinitionNoCallableError`
#### Description
A service definition did not provide a callable (instance of `function`).
Occurs when when wrapping services at setup time.

### `ServiceDefinitionTypeError`
#### Description
The service definition was neither a function nor a richer service definition
object containing metadata and optional Law declarations. Occurs at setup time.

### `ServiceReturnTypeError`
#### Description
The return value of a service (chained in a computed stack of services) is
not an object. Occurs at call time.

### `UnresolvableDependencyError`
#### Description
A particular dependency in a valid (resolvable) dependency category could
not be resolved using the configuration given

### `UnresolvableDependencyTypeError`
#### Description
A service declared an unresolvable dependency category. For example, if the
resolver configuration doesn't define a way to resolve dependencies in a
`services` category, this error would be thrown. Occurs at setup time, when
resolving dependencies.
