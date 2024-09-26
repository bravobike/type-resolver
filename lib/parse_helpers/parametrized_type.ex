defmodule TypeResolver.ParseHelpers.ParametrizedType do
  alias TypeResolver.ParseHelpers
  alias TypeResolver.Types

  def parse({:type, _, :map, _args}, _env), do: {:error, :cannot_parse}
  def parse({:type, _, n, args}, env), do: parse_helper(n, args, env)
  def parse({n, _, args}, env), do: parse_helper(n, args, env)
  def parse(_, _env), do: {:error, :cannot_parse}

  defp parse_helper(name, args, env) do
    with {:ok, resolved} <- ParseHelpers.parse_args(args, env) do
      case translate(name, resolved |> Enum.reverse()) do
        {:error, _} = err -> err
        res -> {:ok, res}
      end
    end
  end

  defp translate(:list, [arg]), do: %Types.ListT{inner: arg}
  defp translate(:union, args), do: %Types.UnionT{inner: args}
  defp translate(:|, args), do: %Types.UnionT{inner: args}
  defp translate(:tuple, args), do: %Types.TupleT{inner: args}
  defp translate(:nonempty_list, []), do: %Types.NonemptyListT{inner: %Types.AnyT{}}

  defp translate(:nonempty_list, [arg]), do: %Types.NonemptyListT{inner: arg}
  defp translate(:{}, args), do: %Types.TupleT{inner: args}

  defp translate(:maybe_improper_list, [arg1, arg2]),
    do: %Types.MaybeImproperListT{inner: arg1, termination: arg2}

  defp translate(:nonempty_improper_list, [arg1, arg2]),
    do: %Types.NonemptyImproperListT{inner: arg1, termination: arg2}

  defp translate(:nonempty_maybe_improper_list, [arg1, arg2]),
    do: %Types.NonemptyMaybeImproperListT{inner: arg1, termination: arg2}

  defp translate(_, _), do: {:error, :cannot_parse}
end
