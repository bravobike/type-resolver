defmodule TypeResolver.ParseHelpers do
  alias TypeResolver.Env
  alias TypeResolver.ParseHelpers.AnnotatedType
  alias TypeResolver.ParseHelpers.Literals
  alias TypeResolver.ParseHelpers.ParametrizedType
  alias TypeResolver.ParseHelpers.RemoteTypes
  alias TypeResolver.ParseHelpers.SimpleType
  alias TypeResolver.ParseHelpers.UserTypes
  alias TypeResolver.ParseHelpers.Vars

  def parse(expr, env) do
    with {:error, :cannot_parse} <- SimpleType.parse(expr),
         {:error, :cannot_parse} <- AnnotatedType.parse(expr, env),
         {:error, :cannot_parse} <- ParametrizedType.parse(expr, env),
         {:error, :cannot_parse} <- Literals.parse(expr, env),
         {:error, :cannot_parse} <- RemoteTypes.parse(expr, env),
         {:error, :cannot_parse} <- RemoteTypes.parse_user_defined(expr, env),
         {:error, :cannot_parse} <- Vars.parse(expr, env),
         {:error, :cannot_parse} <- UserTypes.parse(expr, env),
         {:error, :cannot_parse} <- catch_struct(expr) do
      {:error, :cannot_parse}
    end
  end

  def resolve(env, type, args \\ []) do
    arity = Enum.count(args)

    {:type, {_name, t, vars}} =
      case Code.Typespec.fetch_types(env.target_module) do
        :error ->
          exported_module = Module.concat(env.target_module, ExportedTypes)

          case Code.ensure_compiled(exported_module) do
            {:module, _} ->
              exported_module.types()
              |> Enum.find(fn {:type, {t, _, args}} -> t == type && Enum.count(args) == arity end)

            {:error, _} ->
              raise "no types can be found for type #{type} in module #{env.target_module}. Env: #{inspect(env)}"
          end

        {:ok, specs} ->
          specs
          |> Enum.find(fn {:type, {t, _, args}} -> t == type && Enum.count(args) == arity end)
          |> case do
            nil ->
              raise "could not find type #{type} in types of module #{env.target_module}. Env: #{inspect(env)}"

            something ->
              something
          end
      end

    t
    |> parse(env |> Env.with_args(prepare_args(vars, args, t, env.target_module)))
  end

  def parse_user_types(types) do
    Enum.map(types, &parse_user_type/1)
  end

  def parse_user_type({:type, {:"::", _, [{name, _, params}, t]}, _}) do
    {name, {t, params}}
  end

  def prepare_args(nil, _values, _, _), do: %{}

  def prepare_args(vars, values, t, target_module) do
    if Enum.count(vars) != Enum.count(values) do
      raise "Arity mismatched between vars and args for type #{inspect(t)} with target module #{inspect(target_module)}: vars = #{inspect(vars)}, args = #{inspect(values)}"
    end

    vars
    |> Enum.map(fn
      {:var, _, name} -> name
      {name, _, nil} -> name
    end)
    |> Enum.zip(values)
    |> Map.new()
  end

  def parse_args(args, env) when is_list(args) do
    Enum.reduce(args, {:ok, []}, fn
      arg, {:ok, ret} ->
        with {:ok, parsed} <- parse(arg, env) do
          {:ok, [parsed | ret]}
        end

      _arg, {:error, _} = err ->
        err
    end)
  end

  def parse_args(_, _env), do: {:error, :cannot_parse}

  @doc !"""
       We catch structs since already parsed parts can end up in the
       expression. Only already parsed sub expressions are structs, else
       there are none in AST.
       """
  defp catch_struct(%_{} = s), do: {:ok, s}
  defp catch_struct(_), do: {:error, :cannot_parse}
end
