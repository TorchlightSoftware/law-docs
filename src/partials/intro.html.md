# Law

## Role

Law is a middleware layer that can be applied to business services, or any kind
of service API.  When writing services, there is often a lot of code duplication
involved in:

1. Argument validation
2. Information lookup
3. Access controls

Law addresses these challenges by providing:

1. A formal signature for services
2. Argument validations and lookups
3. An access control (filter) policy

All of these components follow a JSON-like declarative format that is readable,
easy to work with, and easy to plug into various architectures.

## Architecture

The following diagram shows where Law fits in with other technologies.

![Law Architecture](/images/law-arch.svg)

*Service definitions* are the functions that contain domain logic. They are meant to be small, testable,
and composable. They can share and reuse the same data concepts, transformations, and expectations.
The *Jargon* and *Policy* files let you pull the repetitious noise of assumption-validation *out*
of the service bodies and into a single description of a service's expectations.

The *Jargon* file is where you declare these shared data concepts. Different static and
runtime expectations can be written once, here, and referred to by services.

The *Policy* file is where broader preconditions (such as access control) can be declared.
This lets you record the assumptions of your services in one place, explicitly, and easily
modified as your application grows.

## Problems solved

## Rationale

### Problems live in domains

We build applications to solve problems. These problems don't live in a vacuum.
They exist in real-world *domains*, with their own concepts, rules, and processes.
When we write software, we often need to *model* and *simulate* these domains.
These models are described via *computational* language, like JavaScript.
The actual computational machinery we build is expressed in one of these languages,
and it can be hard to make them match.

### We need to organize our machinery

When we build a system, we need to make sure our concepts are true to the domain.
We can check this "manually" with lots of conditional logic, double-checking---bookkeeping.
But this is easily scattered across the codebase, making it hard to modify and maintain.

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



## Inspiration and Foundations
Our approach to policies was inspired by the filter lifecycle from Ruby on Rails.
The argument validations take some ideas from Design By Contract, e.g.
preconditions. Applying validators to default names was suggested by @JosephJNK.
I am interested to see if this will be conducive to creating a 'ubiquitous
language' as described by Eric Evans in Domain Driven Design.

The separation of Express and Connect has influenced our decision to do the same.
I think that while frameworks can lead to gains in terms of productivity, a
library has greater potential for re-use.
