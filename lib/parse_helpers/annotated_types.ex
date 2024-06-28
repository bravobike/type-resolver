defmodule TypeResolver.ParseHelpers.AnnotatedType do
  use TypedStruct

  alias TypeResolver.ParseHelpers

  def parse({:ann_type, _, [_type_name, t]}, env) do
    ParseHelpers.parse(env, t)
  end

  def parse(_, _env), do: {:error, :cannot_parse}
end
