defmodule TypeResolver.ParseHelpers do
  alias TypeResolver.Env
  alias TypeResolver.ParseHelpers.RemoteTypes
  alias TypeResolver.ParseHelpers.Literals
  alias TypeResolver.ParseHelpers.ParametrizedType
  alias TypeResolver.ParseHelpers.SimpleType
  alias TypeResolver.ParseHelpers.UserTypes
  alias TypeResolver.ParseHelpers.Vars

  def parse(expr, env) do
    with {:error, :cannot_parse} <- SimpleType.parse(expr),
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

  def parse_user_types(types) do
    Enum.map(types, &parse_user_type/1)
  end

  def parse_user_type({:type, {:"::", _, [{name, _, params}, t]}, _}) do
    {name, {t, params}}
  end

  def prepare_args(nil, _values), do: %{}

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

  @doc !"""
       We catch structs since already parsed parts can end up in the
       expression. Only already parsed sub expressions are structs, else
       there are none in AST.
       """
  defp catch_struct(%_{} = s), do: {:ok, s}
  defp catch_struct(_), do: {:error, :cannot_parse}
end
