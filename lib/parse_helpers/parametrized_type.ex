defmodule TypeResolver.ParseHelpers.ParametrizedType do
  alias TypeResolver.Types
  alias TypeResolver.ParseHelpers

  def parse({:type, _, n, args}, env), do: parse_helper(n, args, env)
  def parse({n, _, args}, env), do: parse_helper(n, args, env)
  def parse(_, _env), do: {:error, :cannot_parse}

  defp parse_helper(name, args, env) do
    with {:ok, resolved} <- parse_args(args, env) do
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

  def parse_args(args, env) when is_list(args) do
    Enum.reduce(args, {:ok, []}, fn
      arg, {:ok, ret} ->
        with {:ok, parsed} <- ParseHelpers.parse(arg, env) do
          {:ok, [parsed | ret]}
        end

      _arg, {:error, _} = err ->
        err
    end)
  end

  def parse_args(_, _env), do: {:error, :cannot_parse}
end
