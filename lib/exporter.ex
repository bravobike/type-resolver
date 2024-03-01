defmodule TypeExporter do
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

defmodule B do
  use TypeExporter

  @type my_type :: non_neg_integer()
end
