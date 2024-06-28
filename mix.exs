defmodule TypeResolver.MixProject do
  use Mix.Project

  def project do
    [
      app: :type_resolver,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/resources"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    []
  end

  defp deps do
    [
      {:typed_struct, "~> 0.3.0"}
    ]
  end
end
