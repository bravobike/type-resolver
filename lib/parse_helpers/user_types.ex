defmodule TypeResolver.ParseHelpers.UserTypes do
  alias TypeResolver.Env
  alias TypeResolver.ParseHelpers

  def parse({user_type, _, args}, env) do
    case Env.get_user_type(env, user_type) do
      nil ->
        {:error, :cannot_parse}

      {t, params} ->
        with {:ok, args} <- ParseHelpers.parse_args(args, env),
             lookup = ParseHelpers.prepare_args(params, args),
             env = Env.with_args(env, lookup),
             {:ok, t} <- ParseHelpers.parse(t, env) do
          {:ok,
           %TypeResolver.Types.NamedType{
             inner: t,
             module: env.target_module,
             name: user_type
           }}
        end
    end
  end

  def parse(_a, _env) do
    {:error, :cannot_parse}
  end
end
