defmodule TypeExporter do
  @moduledoc """
  A module to export types to a submodule called __MODULE__.ExportedTypes.

  The generated module contains a functions `types` that returns all
  types of __MODULE__ as returned by `Code.Typespec.fetch_types/1`.

  Use this module to expose types of your module to be used with this library.
  Directly calling `Code.Typespec.fetch_types/1` onto the modules often
  returns errors, since it may have no beam file at the time.

  To use this module, call the use-Macro:

      defmodule MyModule do
        use TypeExporter 

        # module code ...
      end
  """

  defmacro __using__(_opts) do
    quote do
      @after_compile {TypeExporter, :export_types}
    end
  end

  def export_types(env, bytecode) do
    {:ok, specs} = Code.Typespec.fetch_types(bytecode)
    module = Module.concat(env.module, ExportedTypes)

    Code.eval_string("""
    defmodule #{module} do
      def types() do
        #{inspect(specs, limit: :infinity)}
      end
    end
    """)
  end
end
