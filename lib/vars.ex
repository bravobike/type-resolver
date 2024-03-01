defmodule TypeResolver.Vars do
  require TypeResolver

  def parse({:var, _, name}, env) do
    expr = Map.fetch!(env.args, name)
    TypeResolver.parse(expr, env)
  end

  def parse({name, _, nil}, env) do
    if env.args do
      case Map.fetch(env.args, name) do
        {:ok, expr} -> TypeResolver.parse(expr, env)
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
