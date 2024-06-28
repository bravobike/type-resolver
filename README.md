# TypeResolver

![Tests](https://github.com/bravobike/type-resolver/actions/workflows/main.yaml/badge.svg)
[![Hex version badge](https://img.shields.io/hexpm/v/type-resolver.svg)](https://hex.pm/packages/type-resolver)

Type resolver is a library to resolve spec-types at compile time.
That is, reducing the specs to only native types by resolving user-defined,
built-in and remote types. The result is a type expressed in easy to
handle structs of types.

## Rationale

Often times we want to analyse spec-types in macros and derive functionality
from these types. Analysing and working with AST from `Code.Typespec` or
Erlang AST is challenging and cumbersome. Furthermore, there is no
standalone library that resolves user-defined types, built-in types and
remote-types. This library fills this gap.

## Usage

The library offers the macro `TypeResolver.resolve/1` that can be used
as follows:

```elixir
TypeResolver.resolve(integer() | String.t())
```

It returns the following representation:


```elixir
%TypeResolver.UnionT{
  inner: [%TypeResolver.Types.IntegerT{}, %TypeResolver.Types.BinaryT{}]
}
```

## Type exporter

To resolve remote types, we rely on `Code.Typespec.fetch_types/1`. For
this function to work, the module has to be compiled into a beam file,
which cannot always be ensured at macro expansion time.

To handle this problem, we provide the module `TypeResolver.TypeExporter`.
This module takes care of types being exported and makes them available
at macro expansion time.

## Limitations

- Currently this library cannot handle recursive types and does not detect
  them. When using recursive times, compilation will be stuck in an infinite
  recursion.
- Struct types don't get their member resolved 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `type_resolver` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:type_resolver, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/type_resolver>.

## License
Copyright © 2024 Bravobike GmbH and Contributors

This project is licensed under the Apache 2.0 license.
