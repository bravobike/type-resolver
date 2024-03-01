defmodule TypeResolver do
  @moduledoc """
  Documentation for `TypeResolver`.
  """

  alias TypeResolver.ParseHelpers
  alias TypeResolver.Env

  defmacro resolve(module, type) do
    caller_module = __CALLER__.module

    target_module =
      case module do
        {:__aliases__, _, _} = a -> Macro.expand(a, __CALLER__)
        e -> e
      end

    quote do
      env = Env.make(unquote(target_module), unquote(caller_module), Map.new())
      TypeResolver.ParseHelpers.resolve(env, unquote(type))
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
      TypeResolver.ParseHelpers.resolve(env, unquote(second), unquote(args))
    end
  end

  defmacro resolve(other) do
    current_module = __CALLER__.module

    {other, _} =
      Macro.prewalk(other, nil, fn
        {:__aliases__, _, _} = a, acc -> {Macro.expand(a, __CALLER__), acc}
        a, acc -> {a, acc}
      end)

    local_user_types =
      Module.get_attribute(__CALLER__.module, :type)
      |> ParseHelpers.parse_user_types()
      |> Map.new()

    env = Env.make(current_module, nil, local_user_types)
    res = ParseHelpers.parse(other, env)

    quote do
      unquote(Macro.escape(res))
    end
  end
end
