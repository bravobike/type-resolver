defmodule TypeResolver.ParseHelpers.RemoteTypes do
  alias TypeResolver.Env
  alias TypeResolver.ParseHelpers

  def parse({:remote_type, _, [{:atom, _, path}, {:atom, _, type}, args]}, env) do
    with {:ok, args} <- ParseHelpers.parse_args(args, env) do
      env = Env.with_target_module(env, path) |> Env.clear_user_types()

      with {:ok, t} <- ParseHelpers.resolve(env, type, args) do
        {:ok, %TypeResolver.Types.RemoteType{inner: t, module: path, name: type}}
      end
    end
  end

  def parse({{:., _, [mod, name]}, _, args}, env) do
    with {:ok, args} <- ParseHelpers.parse_args(args, env) do
      env = Env.with_target_module(env, mod) |> Env.clear_user_types()

      with {:ok, t} <- ParseHelpers.resolve(env, name, args) do
        {:ok, %TypeResolver.Types.RemoteType{inner: t, module: mod, name: name}}
      end
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
