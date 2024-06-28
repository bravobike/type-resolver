defmodule TypeResolver.ParseHelpers.RemoteTypes do
  alias TypeResolver.Env
  alias TypeResolver.ParseHelpers

  def parse({:remote_type, _, [{:atom, _, path}, {:atom, _, type}, args]}, env) do
    with {:ok, args} <- ParseHelpers.parse_args(args, env) do
      env = Env.with_target_module(env, path) |> Env.clear_user_types()
      ParseHelpers.resolve(env, type, args)
    end
  end

  def parse({{:., _, [mod, t]}, _, args}, env) do
    with {:ok, args} <- ParseHelpers.parse_args(args, env) do
      env = Env.with_target_module(env, mod) |> Env.clear_user_types()
      ParseHelpers.resolve(env, t, args)
    end
  end

  def parse(_, _env) do
    {:error, :cannot_parse}
  end

  def parse_user_defined({:user_type, _, t, args}, env) do
    ParseHelpers.resolve(env, t, args)
  end

  def parse_user_defined(_, _) do
    {:error, :cannot_parse}
  end
end
