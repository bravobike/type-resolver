defmodule TypeResolver.ParseHelpers.Literals do
  alias TypeResolver.ParseHelpers
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
  defp translate([{:..., _, nil}, type], env) do
    with {:ok, type} <- ParseHelpers.parse(type, env) do
      %Types.NonemptyListT{inner: type}
    end
  end

  defp translate([{:..., _, nil}], _env), do: %Types.NonemptyListT{inner: %Types.AnyT{}}

  # ranges
  defp translate({:.., _, [from, to]}, _env), do: %Types.RangeL{from: from, to: to}

  defp translate({:type, _, :range, [{_, _, from}, {_, _, to}]}, _env),
    do: %Types.RangeL{from: from, to: to}

  # funs
  defp translate({:type, _, :fun, [{:type, _, :product, args}, _]}, _env),
    do: %Types.FunctionL{arity: Enum.count(args)}

  defp translate({:type, _, :fun, [{:type, _, :any}, _]}, _env), do: %Types.FunctionL{arity: :any}
  defp translate({:type, _, :product, args}, _env), do: %Types.FunctionL{arity: Enum.count(args)}
  defp translate([{:->, _, [[{:..., _, _}], _]}], _env), do: %Types.FunctionL{arity: :any}
  defp translate([{:->, _, [args, _]}], _env), do: %Types.FunctionL{arity: Enum.count(args)}

  defp translate([], _env), do: %Types.EmptyListL{}
  # this seems like the empty list ast?
  defp translate({:type, _, nil, []}, _env), do: %Types.EmptyListL{}

  defp translate([t], env) do
    case ParseHelpers.parse(t, env) do
      {:ok, t} -> %Types.ListT{inner: t}
      {:error, _} = err -> err
    end
  end

  # arity
  defp translate({:type, _, :arity, []}, _env), do: %Types.RangeL{from: 0, to: 255}
  defp translate({:arity, _, []}, _env), do: %Types.RangeL{from: 0, to: 255}

  # integer
  defp translate(i, _env) when is_integer(i), do: %Types.IntegerL{value: i}
  defp translate({:integer, _, i}, _env), do: %Types.IntegerL{value: i}

  # empty bitstring
  defp translate({:type, _, :binary, [{:integer, _, 0}, {:integer, _, 0}]}, _env),
    do: %Types.EmptyBitstringL{}

  defp translate({:<<>>, _, []}, _env), do: %Types.EmptyBitstringL{}

  defp translate(
         {:<<>>, _,
          [
            {:"::", _, [{:_, _, _}, size]},
            {:"::", _, [{:_, _, _}, {:*, _, [{:_, _, _}, unit]}]}
          ]},
         _env
       ),
       do: %Types.SizedBitstringWithUnitL{size: size, unit: unit}

  # bit string with unit

  defp translate({:<<>>, _, [{:"::", _, [{:_, _, _}, {:*, _, [{:_, _, _}, unit]}]}]}, _env),
    do: %Types.BitstringWithUnitL{unit: unit}

  # sized bitstring
  defp translate({:type, _, :binary, [{:integer, _, num}, {:integer, _, 0}]}, _env),
    do: %Types.SizedBitstringL{size: num}

  defp translate({:<<>>, _, [{:"::", _, [{:_, _, _}, num]}]}, _env),
    do: %Types.SizedBitstringL{size: num}

  # bit string with unit

  defp translate({:type, _, :binary, [{:integer, _, 0}, {:integer, _, num}]}, _env),
    do: %Types.BitstringWithUnitL{unit: num}

  # sized bit string with unit

  defp translate({:type, _, :binary, [{:integer, _, size}, {:integer, _, unit}]}, _env),
    do: %Types.SizedBitstringWithUnitL{unit: unit, size: size}

  # atoms
  defp translate(false, _env), do: %Types.BooleanL{value: false}
  defp translate({:atom, _, false}, _env), do: %Types.BooleanL{value: false}

  defp translate(true, _env), do: %Types.BooleanL{value: true}
  defp translate({:atom, _, true}, _env), do: %Types.BooleanL{value: true}

  defp translate(nil, _env), do: %Types.NilL{}
  defp translate({:atom, _, nil}, _env), do: %Types.NilL{}

  defp translate(v, _env) when is_atom(v), do: %Types.AtomL{value: v}
  defp translate({:atom, _, v}, _env), do: %Types.AtomL{value: v}

  defp translate({:%{}, _, []}, _env), do: %Types.EmptyMapL{}

  defp translate({:%, _, [module, _]}, _env), do: %Types.StructL{module: module}

  defp translate({:%{}, _, args}, env) do
    with {:ok, types} <- ParseHelpers.parse_args(args, env) do
      inner =
        Enum.map(types, fn %Types.TupleT{inner: [a, b]} ->
          case a do
            %InternalRequired{value: t} ->
              make_exact_or_struct(t, b)

            %InternalOptional{value: t} ->
              %Types.MapFieldAssocL{k: t, v: b}

            t ->
              %Types.MapFieldExactL{k: t, v: b}
          end
        end)

      make_map_or_struct(inner)
    end
  end

  defp translate({:required, _, [t]}, env) do
    with {:ok, t} <- ParseHelpers.parse(t, env) do
      %InternalRequired{value: t}
    end
  end

  defp translate({:optional, _, [t]}, env) do
    with {:ok, t} <- ParseHelpers.parse(t, env) do
      %InternalOptional{value: t}
    end
  end

  defp translate({a, b}, env) do
    with {:ok, a} <- ParseHelpers.parse(a, env),
         {:ok, b} <- ParseHelpers.parse(b, env) do
      %Types.TupleT{inner: [a, b]}
    end
  end

  defp translate({:type, _, :map_field_assoc, [k, v]}, env) do
    with {:ok, a} <- ParseHelpers.parse(k, env),
         {:ok, b} <- ParseHelpers.parse(v, env) do
      %Types.MapFieldAssocL{k: a, v: b}
    end
  end

  defp translate({:type, _, :map_field_exact, [k, v]}, env) do
    with {:ok, a} <- ParseHelpers.parse(k, env),
         {:ok, b} <- ParseHelpers.parse(v, env) do
      make_exact_or_struct(a, b)
    end
  end

  defp translate({:type, _, :map, types}, env) do
    if is_struct_ast?(types) do
      module = struct_field(types) |> struct_field_module()
      %Types.StructL{module: module}
    else
      with {:ok, types} <- ParseHelpers.parse_args(types, env) do
        make_map_or_struct(types)
      end
    end
  end

  defp translate({:type, _, :bitstring, []}, _env) do
    %Types.BitstringWithUnitL{unit: 1}
  end

  defp translate({:bitstring, _, []}, _env) do
    %Types.BitstringWithUnitL{unit: 1}
  end

  defp translate({:type, _, :boolean, []}, _env) do
    %Types.BooleanT{}
  end

  defp translate({:boolean, _, []}, _env) do
    %Types.BooleanT{}
  end

  defp translate({:type, _, :byte, []}, _env) do
    %Types.RangeL{from: 0, to: 255}
  end

  defp translate({:byte, _, []}, _env) do
    %Types.RangeL{from: 0, to: 255}
  end

  defp translate({:type, _, :mfa, []}, _env) do
    %Types.TupleT{inner: [%Types.AtomT{}, %Types.AtomT{}, %Types.RangeL{from: 0, to: 255}]}
  end

  defp translate({:mfa, _, []}, _env) do
    %Types.TupleT{inner: [%Types.AtomT{}, %Types.AtomT{}, %Types.RangeL{from: 0, to: 255}]}
  end

  defp translate({:type, _, :module, []}, _env) do
    %Types.AtomT{}
  end

  defp translate({:module, _, []}, _env) do
    %Types.AtomT{}
  end

  defp translate({:type, _, :no_return, []}, _env) do
    %Types.NoneT{}
  end

  defp translate({:no_return, _, []}, _env) do
    %Types.NoneT{}
  end

  defp translate({:type, _, :node, []}, _env) do
    %Types.AtomT{}
  end

  defp translate({:node, _, []}, _env) do
    %Types.AtomT{}
  end

  defp translate({:type, _, :number, []}, _env) do
    %Types.UnionT{inner: [%Types.IntegerT{}, %Types.FloatT{}]}
  end

  defp translate({:number, _, []}, _env) do
    %Types.UnionT{inner: [%Types.IntegerT{}, %Types.FloatT{}]}
  end

  defp translate({:type, _, :timeout, []}, _env) do
    %Types.UnionT{inner: [%Types.AtomL{value: :infinity}, %Types.NonNegIntegerT{}]}
  end

  defp translate({:timeout, _, []}, _env) do
    %Types.UnionT{inner: [%Types.AtomL{value: :infinity}, %Types.NonNegIntegerT{}]}
  end

  defp translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :struct}, []]}, _env) do
    %Types.MapL{
      inner: [
        %Types.MapFieldExactL{k: %Types.AtomL{value: :__struct__}, v: %Types.AtomT{}},
        %Types.MapFieldAssocL{k: %Types.AtomT{}, v: %Types.AnyT{}}
      ]
    }
  end

  defp translate({:struct, _, []}, _env) do
    %Types.MapL{
      inner: [
        %Types.MapFieldExactL{k: %Types.AtomL{value: :__struct__}, v: %Types.AtomT{}},
        %Types.MapFieldAssocL{k: %Types.AtomT{}, v: %Types.AnyT{}}
      ]
    }
  end

  defp translate({:type, _, :char, []}, _env) do
    %Types.RangeL{from: 0, to: 0x10FFFF}
  end

  defp translate({:char, _, []}, _env) do
    %Types.RangeL{from: 0, to: 0x10FFFF}
  end

  defp translate({:type, _, :fun, []}, _env) do
    %Types.FunctionL{arity: :any}
  end

  defp translate({:fun, _, []}, _env) do
    %Types.FunctionL{arity: :any}
  end

  defp translate({:type, _, :function, []}, _env) do
    %Types.FunctionL{arity: :any}
  end

  defp translate({:list, _, []}, _env) do
    %Types.ListT{inner: [%Types.AnyT{}]}
  end

  defp translate({:type, _, :list, []}, _env) do
    %Types.ListT{inner: [%Types.AnyT{}]}
  end

  defp translate({:maybe_improper_list, _, []}, _env) do
    %Types.MaybeImproperListT{inner: [%Types.AnyT{}]}
  end

  defp translate({:type, _, :maybe_improper_list, []}, _env) do
    %Types.MaybeImproperListT{inner: [%Types.AnyT{}]}
  end

  defp translate({:type, _, :nonempty_maybe_improper_list, []}, _env) do
    %Types.NonemptyMaybeImproperListT{inner: [%Types.AnyT{}]}
  end

  defp translate({:nonempty_maybe_improper_list, _, []}, _env) do
    %Types.NonemptyMaybeImproperListT{inner: [%Types.AnyT{}]}
  end

  defp translate({:function, _, []}, _env) do
    %Types.FunctionL{arity: :any}
  end

  defp translate({:type, _, :iodata, []}, _env) do
    %Types.UnionT{inner: [io_list(), %Types.BinaryT{}]}
  end

  defp translate({:iodata, _, []}, _env) do
    %Types.UnionT{inner: [io_list(), %Types.BinaryT{}]}
  end

  defp translate({:type, _, :iolist, []}, _env), do: io_list()

  defp translate({:iolist, _, []}, _env), do: io_list()

  defp translate({:keyword, _, []}, _env) do
    %Types.ListT{inner: [%Types.TupleT{inner: [%Types.AtomT{}, %Types.AnyT{}]}]}
  end

  defp translate({:keyword, _, types}, env) do
    with {:ok, args} <- ParseHelpers.parse_args(types, env) do
      inner = Enum.map(args, fn arg -> %Types.TupleT{inner: [%Types.AtomT{}, arg]} end)
      %Types.ListT{inner: inner |> Enum.reverse()}
    end
  end

  defp translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :keyword}, []]}, _env) do
    %Types.ListT{inner: [%Types.TupleT{inner: [%Types.AtomT{}, %Types.AnyT{}]}]}
  end

  defp translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :keyword}, types]}, env) do
    with {:ok, args} <- ParseHelpers.parse_args(types, env) do
      inner = Enum.map(args, fn arg -> %Types.TupleT{inner: [%Types.AtomT{}, arg]} end)
      %Types.ListT{inner: inner |> Enum.reverse()}
    end
  end

  defp translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :charlist}, []]}, _env) do
    %Types.ListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
  end

  defp translate({:charlist, _, []}, _env) do
    %Types.ListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
  end

  defp translate({:nonempty_charlist, _, []}, _env) do
    %Types.NonemptyListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
  end

  defp translate(
         {:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :nonempty_charlist}, []]},
         _env
       ) do
    %Types.NonemptyListT{inner: %Types.RangeL{from: 0, to: 0x10FFFF}}
  end

  defp translate({:remote_type, _, [{:atom, _, :elixir}, {:atom, _, :as_boolean}, [arg]]}, env) do
    with {:ok, t} <- ParseHelpers.parse(arg, env) do
      t
    end
  end

  defp translate({:as_boolean, _, [arg]}, env) do
    with {:ok, t} <- ParseHelpers.parse(arg, env) do
      t
    end
  end

  defp translate(list, env) when is_list(list) do
    with {:ok, args} <- ParseHelpers.parse_args(list, env) do
      %Types.ListT{inner: args |> Enum.reverse()}
    end
  end

  defp translate(_a, _env) do
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

  defp is_struct_ast?(ast) do
    case struct_field(ast) do
      nil -> false
      _ -> true
    end
  end

  defp struct_field(fields) do
    fields
    |> Enum.find(fn
      {_, _, :map_field_exact, [{:atom, _, :__struct__}, _]} -> true
      _ -> false
    end)
  end

  defp struct_field_module({_, _, :map_field_exact, [_, {:atom, _, module}]}) do
    module
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
