defmodule TypeResolver.ParseHelpers.UserTypes do
  alias TypeResolver.ParseHelpers
  alias TypeResolver.Env

  def parse({user_type, _, args}, env) do
    case Env.get_user_type(env, user_type) do
      nil ->
        {:error, :cannot_parse}

      {t, params} ->
        with {:ok, args} <- ParseHelpers.parse_args(args, env) do
          lookup = ParseHelpers.prepare_args(params, args)
          env = Env.with_args(env, lookup)
          ParseHelpers.parse(t, env)
        end
    end
  end

  def parse(_a, _env) do
    {:error, :cannot_parse}
  end
end
