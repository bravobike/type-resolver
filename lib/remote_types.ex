defmodule TypeResolver.RemoteTypes do
  alias TypeResolver.Env
  require TypeResolver

  def parse({:remote_type, _, [{:atom, _, path}, {:atom, _, type}, args]}, env) do
    with {:ok, args} <- parse_args(args, env) do
      env = Env.with_target_module(env, path)
      TypeResolver.resolve_helper(env, type, args)
    end
  end

  def parse({{:., _, [mod, t]}, _, args}, env) do
    env = Env.with_target_module(env, mod)
    TypeResolver.resolve_helper(env, t, args)
  end

  def parse(_, _env) do
    {:error, :cannot_parse}
  end

  def parse_user_defined({:user_type, _, t, args}, env) do
    TypeResolver.resolve_helper(env, t, args)
  end

  def parse_user_defined(_, _) do
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
