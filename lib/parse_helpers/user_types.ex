defmodule TypeResolver.ParseHelpers.UserTypes do
  alias TypeResolver.ParseHelpers
  alias TypeResolver.Env

  def parse({user_type, _, args}, env) do
    case Env.get_user_type(env, user_type) do
      nil ->
        {:error, :cannot_parse}

      {t, params} ->
        with {:ok, args} <- parse_args(args, env) do
          lookup = ParseHelpers.prepare_args(params, args)
          env = Env.with_args(env, lookup)
          ParseHelpers.parse(t, env)
        end
    end
  end

  def parse(_a, _env) do
    {:error, :cannot_parse}
  end

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
end
