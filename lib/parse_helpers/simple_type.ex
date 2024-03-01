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

  def translate(:any), do: Types.AnyT
  def translate(:term), do: Types.AnyT
  def translate(:binary), do: Types.BinaryT
  def translate(:none), do: Types.NoneT
  def translate(:atom), do: Types.AtomT
  def translate(:pid), do: Types.PidT
  def translate(:port), do: Types.PortT
  def translate(:reference), do: Types.ReferenceT
  def translate(:map), do: Types.MapAnyT
  def translate(:empty_map), do: Types.EmptyMapL
  def translate(:tuple), do: Types.TupleAnyT
  def translate(:float), do: Types.FloatT
  def translate(:integer), do: Types.IntegerT
  def translate(:non_neg_integer), do: Types.NonNegIntegerT
  def translate(:neg_integer), do: Types.NegIntegerT
  def translate(:pos_integer), do: Types.PosIntegerT
  def translate(_), do: {:error, :cannot_parse}
end
