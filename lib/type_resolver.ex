defmodule TypeResolver do
  @moduledoc """
  Documentation for `TypeResolver`.
  """
  require Helper

  alias TypeResolver.Env
  alias TypeResolver.RemoteTypes
  alias TypeResolver.Literals
  alias TypeResolver.ParametrizedType
  alias TypeResolver.SimpleType
  alias TypeResolver.UserTypes
  alias TypeResolver.Vars

  defmacro resolve(module, type) do
    caller_module = __CALLER__.module

    target_module =
      case module do
        {:__aliases__, _, _} = a -> Macro.expand(a, __CALLER__)
        e -> e
      end

    quote do
      env = Env.make(unquote(target_module), unquote(caller_module), Map.new())
      TypeResolver.resolve_helper(env, unquote(type))
    end
  end

  defmacro resolve({{:., _, [first, second]}, _, args}) do
    caller_module = __CALLER__.module

    target_module =
      case first do
        {:__aliases__, _, _} = a -> Macro.expand(a, __CALLER__)
        e -> e
      end

    args = Macro.escape(args)

    quote do
      env = Env.make(unquote(target_module), unquote(caller_module), Map.new())
      TypeResolver.resolve_helper(env, unquote(second), unquote(args))
    end
  end

  defmacro resolve(other) do
    current_module = __CALLER__.module

    {other, nil} =
      Macro.prewalk(other, nil, fn
        {:__aliases__, _, _} = a, nil ->
          {Macro.expand(a, __CALLER__), nil}

        a, nil ->
          {a, nil}
      end)

    local_user_types =
      Module.get_attribute(__CALLER__.module, :type)
      |> parse_user_types()
      |> Map.new()

    env = Env.make(current_module, nil, local_user_types)
    res = parse(other, env)

    quote do
      unquote(Macro.escape(res))
    end
  end

  def resolve_helper(env, type, args \\ []) do
    Code.ensure_compiled(env.target_module)

    {:type, {_name, t, vars}} =
      case Code.Typespec.fetch_types(env.target_module) do
        :error ->
          exported_module = Module.concat(env.target_module, ExportedTypes)

          case Code.ensure_compiled(exported_module) do
            {:module, _} ->
              apply(exported_module, :export_types, [])
              |> Enum.find(fn {:type, {t, _, _}} -> t == type end)

            {:error, _} ->
              raise "no types can be found"
          end

        {:ok, specs} ->
          specs |> Enum.find(fn {:type, {t, _, _}} -> t == type end)
      end

    t |> parse(env |> Env.with_args(prepare_args(vars, args)))
  end

  def parse(expr, env) do
    with {:error, :cannot_parse} <- SimpleType.parse(expr),
         {:error, :cannot_parse} <- ParametrizedType.parse(expr, env),
         {:error, :cannot_parse} <- Literals.parse(expr, env),
         {:error, :cannot_parse} <- RemoteTypes.parse(expr, env),
         {:error, :cannot_parse} <- RemoteTypes.parse_user_defined(expr, env),
         {:error, :cannot_parse} <- Vars.parse(expr, env),
         {:error, :cannot_parse} <- UserTypes.parse(expr, env) do
      {:error, :cannot_parse}
    end
  end

  def parse_user_types(types) do
    Enum.map(types, &parse_user_type/1)
  end

  def parse_user_type({:type, {:"::", _, [{name, _, params}, t]}, _}) do
    {name, {t, params}}
  end

  def prepare_args(nil, _values) do
    %{}
  end

  def prepare_args(vars, values) do
    if Enum.count(vars) != Enum.count(values) do
      raise "Error when counting var and args"
    end

    vars
    |> Enum.map(fn
      {:var, _, name} -> name
      {name, _, nil} -> name
    end)
    |> Enum.zip(values)
    |> Map.new()
  end
end
