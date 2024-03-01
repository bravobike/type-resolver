defmodule Helper do
  defmacro resolve({:__aliases__, _, _} = a) do
    res = Macro.expand(a, __ENV__)

    IO.inspect(res, label: "res")

    quote do
      unquote(res)
    end
  end

  defmacro resolve(a) do
    IO.inspect(a, label: "catch all")
    a
  end
end
