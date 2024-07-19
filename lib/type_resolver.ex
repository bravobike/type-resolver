defmodule TypeResolver do
  @moduledoc """
  Type resolver is a library to resolve spec-types at compile time.
  That is, reducing the specs to only native types by resolving user-defined,
  built-in and remote types. The result is a type expressed in easy to
  handle structs of types.

  ## Rational

  Often times we want to analyse spec-types in macros and derive functionality
  from these types. Analysing and working with AST from `Code.Typespec` or
  Erlang AST is challenging and cumbersome. Furthermore, there is no
  standalone library that resolves user-defined types, built-in types and
  remote-types. This library fills this gap.

  ## Usage

  The library offers the macro `TypeResolver.resolve/1` that can be used
  as follows:

      resolve(integer() | String.t())

  It returns the following representation:

      %TypeResolver.UnionT{
        inner: [%TypeResolver.Types.IntegerT{}, %TypeResolver.Types.BinaryT{}]
      }

  The library is also capable of resolving type parameters.

  For a complete list of result-types, see `TypeResolver.Types`.

  ## Type exporter

  To resolve remote types, we rely on `Code.Typespec.fetch_types/1`. For
  this function to work, the module has to be compiled into a beam file,
  which cannot always be ensured at macro expansion time.

  To handle this problem, we provide the module `TypeResolver.TypeExporter`.
  This module takes care of types being exported and makes them available
  at macro expansion time. The module has to be used in the remote module
  that contains the type, as follows: 

      defmodule MyRemoteModule do 
        use TypeResolver.TypeExporter

        @type my_remote_t :: ...
      end

  *Note, that this is not a problem for library code since for dependencies,
  all files have been compiled and written to beam-files before the compilation
  of our own code.*

  ## Limitations

  - Currently this library cannot handle recursive types and does not detect
    them. When using recursive times, compilation will be stuck in an infinite
    recursion.
  - Struct types don't get their member resolved 
  """

  alias TypeResolver.Env
  alias TypeResolver.ParseHelpers

  @type ast_t() :: tuple()

  @doc """
  This marco takes a spec expression and returns a struct-based representation
  of the types, resolved to only basic spec-types, e.g:

      resolve(integer() | String.t())

  returns the following representation:

      %TypeResolver.UnionT{
        inner: [%TypeResolver.Types.IntegerT{}, %TypeResolver.Types.BinaryT{}]
      }

  Raises if types cannot be resolved.
  """
  @spec resolve(ast_t()) :: TypeResolver.Types.t()
  defmacro resolve({{:., _, [first, second]}, _, args}) do
    target_module = first |> resolve_aliases(__CALLER__)
    second = resolve_aliases(second, __CALLER__)
    args = args |> resolve_aliases(__CALLER__)

    env = Env.make(target_module, Map.new())
    res = TypeResolver.ParseHelpers.resolve(env, second, args)

    quote do
      unquote(res |> Macro.escape())
    end
  end

  @spec resolve(ast_t()) :: TypeResolver.Types.t()
  defmacro resolve(other) do
    current_module = __CALLER__.module

    other = resolve_aliases(other, __CALLER__)

    local_user_types =
      Module.get_attribute(__CALLER__.module, :type)
      |> ParseHelpers.parse_user_types()
      |> Enum.map(fn {n, p} -> {n, resolve_aliases(p, __CALLER__)} end)
      |> Map.new()

    env = Env.make(current_module, local_user_types)
    res = ParseHelpers.parse(other, env)

    quote do
      unquote(res |> Macro.escape())
    end
  end

  defp resolve_aliases(ast, env) do
    {ast, _} =
      Macro.prewalk(ast, nil, fn
        {:__aliases__, _, _} = a, acc -> {Macro.expand(a, env), acc}
        a, acc -> {a, acc}
      end)

    ast
  end
end
