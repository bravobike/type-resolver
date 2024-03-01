defmodule TypeResolver.Literals do
  alias TypeResolver.ParametrizedType
  alias TypeResolver.Types

  use TypedStruct

  typedstruct module: InternalRequired do
    field(:value, any())
  end

  typedstruct module: InternalOptional do
    field(:value, any())
  end

  typedstruct module: InternalStruct do
    field(:value, any())
  end

  def parse(t, env) do
    case translate(t, env) do
      {:error, _} = err -> err
      res -> {:ok, res}
    end
  end

  # non empty list
  def translate([{:..., _, nil}, type], env) do
    with {:ok, type} <- TypeResolver.parse(type, env) do
      %Types.NonemptyListT{inner: type}
    end
  end

  def translate([{:..., _, nil}], _env), do: %Types.NonemptyListT{inner: %Types.AnyT{}}

  # ranges
  def translate({:.., _, [from, to]}, _env), do: %Types.RangeL{from: from, to: to}

  def translate({:type, _, :range, [{_, _, from}, {_, _, to}]}, _env),
    do: %Types.RangeL{from: from, to: to}

  # funs
  def translate({:type, _, :fun, [{:type, _, :product, args}, _]}, _env),
    do: %Types.FunctionL{arity: Enum.count(args)}

  def translate({:type, _, :fun, [{:type, _, :any}, _]}, _env), do: %Types.FunctionL{arity: :any}
  def translate({:type, _, :product, args}, _env), do: %Types.FunctionL{arity: Enum.count(args)}
  def translate([{:->, _, [[{:..., _, _}], _]}], _env), do: %Types.FunctionL{arity: :any}
  def translate([{:->, _, [args, _]}], _env), do: %Types.FunctionL{arity: Enum.count(args)}

  def translate([], _env), do: %Types.EmptyListL{}
  # this seems like the empty list ast?
  def translate({:type, _, nil, []}, _env), do: %Types.EmptyListL{}

  def translate([t], env) do
    case TypeResolver.parse(t, env) do
      {:ok, t} -> %Types.ListT{inner: t}
      {:error, _} = err -> err
    end
  end

  # arity
  def translate({:type, _, :arity, []}, _env), do: %Types.RangeL{from: 0, to: 255}
  def translate({:arity, _, []}, _env), do: %Types.RangeL{from: 0, to: 255}

  # integer
  def translate(i, _env) when is_integer(i), do: %Types.IntegerL{value: i}
  def translate({:integer, _, i}, _env), do: %Types.IntegerL{value: i}

  # empty bitstring
  def translate({:type, _, :binary, [{:integer, _, 0}, {:integer, _, 0}]}, _env),
    do: %Types.EmptyBitstringL{}

  def translate({:<<>>, _, []}, _env), do: %Types.EmptyBitstringL{}

  def translate(
        {:<<>>, _,
         [
           {:"::", _, [{:_, _, _}, size]},
           {:"::", _, [{:_, _, _}, {:*, _, [{:_, _, _}, unit]}]}
         ]},
        _env
      ),
      do: %Types.SizedBitstringWithUnitL{size: size, unit: unit}

  # bit string with unit

  def translate({:<<>>, _, [{:"::", _, [{:_, _, _}, {:*, _, [{:_, _, _}, unit]}]}]}, _env),
    do: %Types.BitstringWithUnitL{unit: unit}

  # sized bitstring
  def translate({:type, _, :binary, [{:integer, _, num}, {:integer, _, 0}]}, _env),
    do: %Types.SizedBitstringL{size: num}

  def translate({:<<>>, _, [{:"::", _, [{:_, _, _}, num]}]}, _env),
    do: %Types.SizedBitstringL{size: num}

  # bit string with unit

  def translate({:type, _, :binary, [{:integer, _, 0}, {:integer, _, num}]}, _env),
    do: %Types.BitstringWithUnitL{unit: num}

  # sized bit string with unit

  def translate({:type, _, :binary, [{:integer, _, size}, {:integer, _, unit}]}, _env),
    do: %Types.SizedBitstringWithUnitL{unit: unit, size: size}

  # atoms
  def translate(false, _env), do: %Types.BooleanL{value: false}
  def translate({:atom, _, false}, _env), do: %Types.BooleanL{value: false}

  def translate(true, _env), do: %Types.BooleanL{value: true}
  def translate({:atom, _, true}, _env), do: %Types.BooleanL{value: true}

  def translate(nil, _env), do: %Types.NilL{}
  def translate({:atom, _, nil}, _env), do: %Types.NilL{}

  def translate(v, _env) when is_atom(v), do: %Types.AtomL{value: v}
  def translate({:atom, _, v}, _env), do: %Types.AtomL{value: v}

  def translate({:%{}, _, []}, _env), do: %Types.EmptyMapL{}

  def translate({:%, _, [module, _]}, _env), do: %Types.StructL{module: module}

  def translate({:%{}, _, args}, env) do
    with {:ok, types} <- ParametrizedType.parse_args(args, env) do
      inner =
        Enum.map(types, fn %Types.TupleT{inner: [a, b]} ->
          case a do
            %InternalRequired{value: t} -> make_exact_or_struct(t, b)
            %InternalOptional{value: t} -> %Types.MapFieldAssocL{k: t, v: b}
            t -> %Types.MapFieldExactL{k: t, v: b}
          end
        end)

      make_map_or_struct(inner)
    end
  end

  def translate({:required, _, [t]}, env) do
    with {:ok, t} <- TypeResolver.parse(t, env) do
      %InternalRequired{value: t}
    end
  end

  def translate({:optional, _, [t]}, env) do
    with {:ok, t} <- TypeResolver.parse(t, env) do
      %InternalOptional{value: t}
    end
  end

  def translate({a, b}, env) do
    with {:ok, a} <- TypeResolver.parse(a, env),
         {:ok, b} <- TypeResolver.parse(b, env) do
      %Types.TupleT{inner: [a, b]}
    end
  end

  def translate({:type, _, :map_field_assoc, [k, v]}, env) do
    with {:ok, a} <- TypeResolver.parse(k, env),
         {:ok, b} <- TypeResolver.parse(v, env) do
      %Types.MapFieldAssocL{k: a, v: b}
    end
  end

  def translate({:type, _, :map_field_exact, [k, v]}, env) do
    with {:ok, a} <- TypeResolver.parse(k, env),
         {:ok, b} <- TypeResolver.parse(v, env) do
      make_exact_or_struct(a, b)
    end
  end

  def translate({:type, _, :map, types}, env) do
    with {:ok, types} <- ParametrizedType.parse_args(types, env) do
      make_map_or_struct(types)
    end
  end

  def translate({:type, _, :bitstring, []}, _env) do
    %Types.BitstringWithUnitL{unit: 1}
  end

  def translate({:bitstring, _, []}, _env) do
    %Types.BitstringWithUnitL{unit: 1}
  end

  def translate({:type, _, :boolean, []}, _env) do
    %Types.BooleanT{}
  end

  def translate({:boolean, _, []}, _env) do
    %Types.BooleanT{}
  end

  def translate({:type, _, :byte, []}, _env) do
    %Types.RangeL{from: 0, to: 255}
  end

  def translate({:byte, _, []}, _env) do
    %Types.RangeL{from: 0, to: 255}
  end

  def translate({:type, _, :mfa, []}, _env) do
    %Types.TupleT{inner: [%Types.AtomT{}, %Types.AtomT{}, %Types.RangeL{from: 0, to: 255}]}
  end

  def translate({:mfa, _, []}, _env) do
    %Types.TupleT{inner: [%Types.AtomT{}, %Types.AtomT{}, %Types.RangeL{from: 0, to: 255}]}
  end

  def translate({:type, _, :module, []}, _env) do
    %Types.AtomT{}
  end

  def translate({:module, _, []}, _env) do
    %Types.AtomT{}
  end

  def translate({:type, _, :no_return, []}, _env) do
    %Types.NoneT{}
  end

  def translate({:no_return, _, []}, _env) do
    %Types.NoneT{}
  end

  def translate({:type, _, :node, []}, _env) do
    %Types.AtomT{}
  end

  def translate({:node, _, []}, _env) do
    %Types.AtomT{}
  end

  def translate({:type, _, :number, []}, _env) do
    %Types.UnionT{inner: [%Types.IntegerT{}, %Types.FloatT{}]}
  end

  def translate({:number, _, []}, _env) do
    %Types.UnionT{inner: [%Types.IntegerT{}, %Types.FloatT{}]}
  end

  def translate({:type, _, :timeout, []}, _env) do
    %Types.UnionT{inner: [%Types.AtomL{value: :infinity}, %Types.NonNegIntegerT{}]}
  end

  def translate({:timeout, _, []}, _env) do
    %Types.UnionT{inner: [%Types.AtomL{value: :infinity}, %Types.NonNegIntegerT{}]}
  end

  def translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :struct}, []]}, _env) do
    %Types.MapL{
      inner: [
        %Types.MapFieldExactL{k: %Types.AtomL{value: :__struct__}, v: %Types.AtomT{}},
        %Types.MapFieldAssocL{k: %Types.AtomT{}, v: %Types.AnyT{}}
      ]
    }
  end

  def translate({:struct, _, []}, _env) do
    %Types.MapL{
      inner: [
        %Types.MapFieldExactL{k: %Types.AtomL{value: :__struct__}, v: %Types.AtomT{}},
        %Types.MapFieldAssocL{k: %Types.AtomT{}, v: %Types.AnyT{}}
      ]
    }
  end

  def translate({:type, _, :char, []}, _env) do
    %Types.RangeL{from: 0, to: 0x10FFFF}
  end

  def translate({:char, _, []}, _env) do
    %Types.RangeL{from: 0, to: 0x10FFFF}
  end

  def translate({:type, _, :fun, []}, _env) do
    %Types.FunctionL{arity: :any}
  end

  def translate({:fun, _, []}, _env) do
    %Types.FunctionL{arity: :any}
  end

  def translate({:type, _, :function, []}, _env) do
    %Types.FunctionL{arity: :any}
  end

  def translate({:list, _, []}, _env) do
    %Types.ListT{inner: [%Types.AnyT{}]}
  end

  def translate({:type, _, :list, []}, _env) do
    %Types.ListT{inner: [%Types.AnyT{}]}
  end

  def translate({:maybe_improper_list, _, []}, _env) do
    %Types.MaybeImproperListT{inner: [%Types.AnyT{}]}
  end

  def translate({:type, _, :maybe_improper_list, []}, _env) do
    %Types.MaybeImproperListT{inner: [%Types.AnyT{}]}
  end

  def translate({:type, _, :nonempty_maybe_improper_list, []}, _env) do
    %Types.NonemptyMaybeImproperListT{inner: [%Types.AnyT{}]}
  end

  def translate({:nonempty_maybe_improper_list, _, []}, _env) do
    %Types.NonemptyMaybeImproperListT{inner: [%Types.AnyT{}]}
  end

  def translate({:function, _, []}, _env) do
    %Types.FunctionL{arity: :any}
  end

  def translate({:type, _, :iodata, []}, _env) do
    %Types.UnionT{inner: [io_list(), %Types.BinaryT{}]}
  end

  def translate({:iodata, _, []}, _env) do
    %Types.UnionT{inner: [io_list(), %Types.BinaryT{}]}
  end

  def translate({:type, _, :iolist, []}, _env), do: io_list()

  def translate({:iolist, _, []}, _env), do: io_list()

  def translate({:keyword, _, []}, _env) do
    %Types.ListT{inner: [%Types.TupleT{inner: [%Types.AtomT{}, %Types.AnyT{}]}]}
  end

  def translate({:keyword, _, types}, env) do
    with {:ok, args} <- ParametrizedType.parse_args(types, env) do
      inner = Enum.map(args, fn arg -> %Types.TupleT{inner: [%Types.AtomT{}, arg]} end)
      %Types.ListT{inner: inner |> Enum.reverse()}
    end
  end

  def translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :keyword}, []]}, _env) do
    %Types.ListT{inner: [%Types.TupleT{inner: [%Types.AtomT{}, %Types.AnyT{}]}]}
  end

  def translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :keyword}, types]}, env) do
    with {:ok, args} <- ParametrizedType.parse_args(types, env) do
      inner = Enum.map(args, fn arg -> %Types.TupleT{inner: [%Types.AtomT{}, arg]} end)
      %Types.ListT{inner: inner |> Enum.reverse()}
    end
  end

  def translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :charlist}, []]}, _env) do
    %Types.ListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
  end

  def translate({:charlist, _, []}, _env) do
    %Types.ListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
  end

  def translate({:nonempty_charlist, _, []}, _env) do
    %Types.NonemptyListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
  end

  def translate(
        {:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :nonempty_charlist}, []]},
        _env
      ) do
    %Types.NonemptyListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
  end

  def translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :as_boolean}, [arg]]}, env) do
    with {:ok, t} <- TypeResolver.parse(arg, env) do
      t
    end
  end

  def translate({:as_boolean, _, [arg]}, env) do
    with {:ok, t} <- TypeResolver.parse(arg, env) do
      t
    end
  end

  def translate(list, env) when is_list(list) do
    with {:ok, args} <- ParametrizedType.parse_args(list, env) do
      %Types.ListT{inner: args |> Enum.reverse()}
    end
  end

  def translate(_a, _env) do
    {:error, :cannot_parse}
  end

  defp make_exact_or_struct(k, v) do
    case k do
      %Types.AtomL{value: :__struct__} -> %InternalStruct{value: v.value}
      _ -> %Types.MapFieldExactL{k: k, v: v}
    end
  end

  defp make_map_or_struct(inner) do
    maybe_struct_field =
      Enum.find(inner, fn
        %InternalStruct{} -> true
        _ -> false
      end)

    case maybe_struct_field do
      nil -> %Types.MapL{inner: Enum.reverse(inner)}
      something -> %Types.StructL{module: something.value}
    end
  end

  defp io_list() do
    %Types.UnionT{
      inner: [
        %Types.MaybeImproperListT{
          inner: %Types.UnionT{
            inner: [
              # byte
              %Types.RangeL{from: 0, to: 255},
              # binary
              %Types.BinaryT{}
              # bla
              # TODO: rec
            ]
          },
          termination: %Types.UnionT{
            inner: [%Types.BinaryT{}, %Types.EmptyListL{}]
          }
        }
      ]
    }
  end
end
