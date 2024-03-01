defmodule TypeResolver.ParseHelpers.Vars do
  alias TypeResolver.ParseHelpers

  def parse({:var, _, name}, env) do
    expr = Map.fetch!(env.args, name)
    ParseHelpers.parse(expr, env)
  end

  def parse({name, _, nil}, env) do
    if env.args do
      case Map.fetch(env.args, name) do
        {:ok, expr} -> ParseHelpers.parse(expr, env)
        :error -> {:error, :cannot_parse}
      end
    else
      {:error, :cannot_parse}
    end
  end

  def parse(_, _env) do
    {:error, :cannot_parse}
  end
end
