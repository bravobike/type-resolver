defmodule TypeResolver.ParseHelpers.SimpleType do
  use TypedStruct
  alias TypeResolver.Types

  def parse({t, _, []}) do
    parse_helper(t)
  end

  def parse({_, _, :map, []}) do
    parse_helper(:empty_map)
  end

  def parse({_, _, t, []}) do
    parse_helper(t)
  end

  def parse({_, _, :map, :any}) do
    parse_helper(:map)
  end

  def parse({_, _, :tuple, :any}) do
    parse_helper(:tuple)
  end

  def parse({:type, _, t}) do
    parse_helper(t)
  end

  def parse(_) do
    {:error, :cannot_parse}
  end

  defp parse_helper(t) do
    case translate(t) do
      {:error, _} = err -> err
      module -> {:ok, struct(module, [])}
    end
  end

  defp translate(:any), do: Types.AnyT
  defp translate(:term), do: Types.AnyT
  defp translate(:binary), do: Types.BinaryT
  defp translate(:none), do: Types.NoneT
  defp translate(:atom), do: Types.AtomT
  defp translate(:pid), do: Types.PidT
  defp translate(:port), do: Types.PortT
  defp translate(:reference), do: Types.ReferenceT
  defp translate(:map), do: Types.MapAnyT
  defp translate(:empty_map), do: Types.EmptyMapL
  defp translate(:tuple), do: Types.TupleAnyT
  defp translate(:float), do: Types.FloatT
  defp translate(:integer), do: Types.IntegerT
  defp translate(:non_neg_integer), do: Types.NonNegIntegerT
  defp translate(:neg_integer), do: Types.NegIntegerT
  defp translate(:pos_integer), do: Types.PosIntegerT
  defp translate(_), do: {:error, :cannot_parse}
end
