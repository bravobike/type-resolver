defmodule TypeResolver.UserTypes do
  require TypeResolver
  alias TypeResolver.Env

  def parse({user_type, _, args}, env) do
    case Env.get_user_type(env, user_type) do
      nil ->
        {:error, :cannot_parse}

      {t, params} ->
        with {:ok, args} <- parse_args(args, env) do
          lookup = TypeResolver.prepare_args(params, args)
          env = Env.with_args(env, lookup)
          TypeResolver.parse(t, env)
        end
    end
  end

  def parse(%_{} = s, _env) do
    {:ok, s}
  end

  def parse(_a, _env) do
    {:error, :cannot_parse}
  end

  def parse_args(args, env) when is_list(args) do
    Enum.reduce(args, {:ok, []}, fn
      arg, {:ok, ret} ->
        with {:ok, parsed} <- TypeResolver.parse(arg, env) do
          {:ok, [parsed | ret]}
        end

      _arg, {:error, _} = err ->
        err
    end)
  end
end
