# Law

## Overview

### Use Case
You have a service-oriented architecture, implemented as a collection of related functions,
some interdependent, meant to collectively operate a shared domain of data types.

Law is a middleware layer for tying together:

1. A set of services
2. Argument validations and lookups
3. An access control policy

### Value

Through this approach we accomplish the following:

1. Decoupling between validations and domain logic
2. Access control is described in one place
3. The preconditions for services are declarative

## Rationale

### Problems live in domains

We build applications to solve problems. These problems don't live in a vacuum.
They exist in *domains*, with their own concepts, rules, and processes.
When we write software, we often need to *model* and *simulate* these domains.
We do this so we can consistently extend, choreograph, and automate their processes.

These models are described via *computational* language, like JavaScript.
Our challenge in program and API design is then to make this computational model
faithful to the rules of the domain. Many strategies for doing this come from the
paradigm of object-orientation: we want to model postal service, so we create
`Mailman`, `Letter`, and `Address` classes with a `deliver(<Letter>, <Address>)` method.
However, the invariants and rules that define valid behavior for these data are
often dependent on runtime state, or easily scattered throughout a codebase.
If the validations logic is attached to the object implementation, it can be hard
to compose this logic with the broader application lifecycle.

### We need to organize our machinery

In solving problems, we build a lot of scaffolding and moving parts. We need to
do this in a way that is maintainable and extensible. The strategies for writing
a manageable codebase include decomposition, encapsulation, and separating concerns.
But these *engineering principles* are connected to implementation details, and can be at
odds with faithful representations of the problem domain we are working in. Real
problems often have cross-cutting concerns, which can be hard to maintainably *and* faithfully
represent.

### JavaScript's types cannot directly encode many constraints

JavaScript's typing regime is incredibly flexible, but at a cost. Suppose we create
a constructor for a class representing an email address. This task might be more complex
than it sounds. Ultimately, what we want is a subset of all possible instances of
`String`. We can make instances of this class correct by construction by *validating*
the constructor arguments.

But, though methods on an object have at least self-knowledge, functions generally must
still must validate all of their explicit inputs. This can lead to a codebase whose
function bodies are littered with guards and validation calls. The problem is only
exacerbated when we attempt ad hoc polymorphism. Furthermore, we may have validations
which depend entirely upon runtime state. Such validations frequently end up as conditional
test-and-dispatch logic embedded in the cracks of a codebase.

Law is an effort to make our domain modeling readable, extensible, and semantic.

## Architectural Role

Law is a middleware library for building web services. Its goal is to let you write composable
services that contain only business logic, with error handling and preconditions expressed
*declaratively* and enforced *outside of* a given service's definition.

In any service-oriented architecture in which you expose functions via an API, Law lets
you factor out preconditions into a declarative layer. Additionally, it lets you write
your services such that, at call time, the arguments satisfy arbitrary *runtime* validations,
not just *typing* validations. For example, you can ensure that a string argument representing
a session token is not only well-formed, but corresponds to an *active* session. The
correspondence precondition likely appears in many services.

Law gives you 3 concepts to use in structuring your application:

1. Service definitions
2. Jargon
3. Policy

*Service definitions* are the functions that contain domain logic. They are meant to be small, testable,
and composable. They can share and reuse the same data concepts, transformations, and expectations.
The *Jargon* and *Policy* files let you pull the repetitious noise of assumption-validation *out*
of the service bodies and into a single description of a service's expectations.

The *Jargon* file is where you declare these shared data concepts. Different static and
runtime expectations can be written once, here, and referred to by services.

The *Policy* file is where broader preconditions (such as access control) can be declared.
This lets you record the assumptions of your services in one place, explicitly, and easily
modified as your application grows.

Wired together, these three objects provide an object mapping service names to "smart" functions,
which can be exposed through any mechanism you like--HTTP, RPC, the command line--any way
you can expose an API.

## Inspiration and Foundations
Our approach to policies was inspired by the filter lifecycle from Ruby on Rails.
The argument validations take some ideas from Design By Contract, e.g.
preconditions. Applying validators to default names was suggested by @JosephJNK.
I am interested to see if this will be conducive to creating a 'ubiquitous
language' as described by Eric Evans in Domain Driven Design.

The separation of Express and Connect has influenced our decision to do the same.
I think that while frameworks can lead to gains in terms of productivity, a
library has greater potential for re-use.

Many thanks to @wearefractal (@amurray, @contra), @JosephJNK, and @uberscientist
for conversations and collaboration on application design with functional and
declarative programming.
